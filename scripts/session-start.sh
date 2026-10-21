#!/usr/bin/env bash
# session-start.sh — mechanical part of the session start (session-ritual plugin).
# Same output, line by line, as scripts/session-start.ps1 (see that header for the
# contract). Usage: session-start.sh [--repo <path>] [--no-pull]. Exit 0 always.
set -u

repo="$PWD"
pull=1
while [ $# -gt 0 ]; do
    case "$1" in
        --repo) repo="${2:-}"; shift 2 ;;
        --no-pull) pull=0; shift ;;
        *) shift ;;
    esac
done

host="${COMPUTERNAME:-$(hostname 2>/dev/null || echo unknown)}"

to_posix_path() { # Windows path → Git Bash path when cygpath exists
    if command -v cygpath > /dev/null 2>&1; then cygpath -u "$1"; else printf '%s' "$1"; fi
}
display_path() { # path as the host shows it (Windows long form under Git Bash)
    if command -v cygpath > /dev/null 2>&1; then cygpath -wl "$1"; else printf '%s' "$1"; fi
}
read_state() { # lines of SESSION_STATE.md without CR; nothing if absent
    [ -f "$1/SESSION_STATE.md" ] && sed 's/\r$//' "$1/SESSION_STATE.md"
}
main_branch() {
    local head
    head=$(git -C "$1" symbolic-ref -q --short refs/remotes/origin/HEAD 2> /dev/null)
    if [ -n "$head" ]; then printf '%s' "${head#origin/}"; return; fi
    local b
    for b in main master; do
        if git -C "$1" show-ref --verify -q "refs/heads/$b" 2> /dev/null; then printf '%s' "$b"; return; fi
    done
}
siblings() {
    local line p
    line=$(read_state "$1" | grep -E '^\*\*(Sibling repos|Repos-irm)' | head -n 1)
    [ -n "$line" ] || return 0
    printf '%s\n' "$line" | grep -oE '`[^`]+`' | tr -d '`' | while IFS= read -r p; do
        p=$(to_posix_path "$(printf '%s' "$p" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')")
        [ -d "$p/.git" ] && (cd "$p" && pwd)
    done
}
last_session_date() {
    read_state "$1" | grep -oE '^(last-session|ultima-sessao):[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}$'
}
is_legacy_state() {
    [ -f "$1/SESSION_STATE.md" ] && ! read_state "$1" | grep -qx '## In progress'
}
trim() { sed 's/^[[:space:]]*//;s/[[:space:]]*$//'; }

report() { # report <root> <pull 0|1>
    local root="$1" dopull="$2"
    echo "### $(basename "$root")"
    echo "- Path: \`$(display_path "$root")\`"
    if [ ! -d "$root/.git" ]; then
        echo "- Not a git repository."
        echo
        return
    fi
    local out rc sb head branch pos main date after count mod n
    if [ -z "$(git -C "$root" remote 2> /dev/null)" ]; then
        echo "- No remote."
    elif [ "$dopull" = 1 ]; then
        out=$(git -C "$root" pull --ff-only 2>&1); rc=$?
        if [ $rc -ne 0 ]; then
            echo "- **Pull failed** — the repo may be out of date: $(printf '%s' "$out" | tr -s '[:space:]' ' ' | trim)"
        else
            echo "- Pull: $(printf '%s\n' "$out" | sed '/^[[:space:]]*$/d' | tail -n 1 | trim)"
        fi
    else
        echo "- Pull: Not run (--no-pull)."
    fi
    sb=$(git -C "$root" status -sb 2> /dev/null)
    head=$(printf '%s\n' "$sb" | head -n 1)
    branch=$(git -C "$root" symbolic-ref -q --short HEAD 2> /dev/null)
    [ -n "$branch" ] || branch='(detached)'
    pos=""
    n=$(printf '%s' "$head" | grep -oE 'ahead [0-9]+' | grep -oE '[0-9]+'); [ -n "$n" ] && pos="$pos — **$n commit(s) ahead of remote**"
    n=$(printf '%s' "$head" | grep -oE 'behind [0-9]+' | grep -oE '[0-9]+'); [ -n "$n" ] && pos="$pos — **$n commit(s) behind remote**"
    echo "- Branch: $branch$pos"
    main=$(main_branch "$root")
    if [ "$branch" != '(detached)' ] && [ -n "$main" ] && [ "$branch" != "$main" ]; then
        echo "- Feature branch: STATE is owned by \`$main\`; this branch writes only its \`## In progress\` block and the LOG."
    fi
    echo "- Last commit: $(git -C "$root" log --oneline -1 2> /dev/null)"
    if is_legacy_state "$root"; then
        echo "- **STATE in 1.x format** — migrate before the briefing: see references/adoption.md."
    fi
    date=$(last_session_date "$root")
    if [ -n "$date" ]; then
        after=$(git -C "$root" log --oneline --since="$date 23:59:59" 2> /dev/null | sed '/^$/d')
        count=$(printf '%s' "$after" | grep -c '' || true)
        if [ "$count" -gt 0 ]; then
            echo "- **Commits after the last \`/session-end\` ($date): $count** — STATE may be stale:"
            printf '%s\n' "$after" | head -n 5 | sed 's/^/  - /'
        fi
    fi
    mod=$(printf '%s\n' "$sb" | tail -n +2 | sed '/^$/d')
    count=$(printf '%s' "$mod" | grep -c '' || true)
    if [ "$count" -gt 0 ]; then
        echo "- Modified files ($count):"
        printf '%s\n' "$mod" | head -n 15 | while IFS= read -r line; do echo "  - \`$(printf '%s' "$line" | trim)\`"; done
        [ "$count" -gt 15 ] && echo "  - …"
    else
        echo "- Modified files: clean"
    fi
    echo "- Recent commits:"
    git -C "$root" log --oneline -5 2> /dev/null | sed 's/^/  - /'
    echo
}

repo_posix=$(to_posix_path "$repo")
if [ ! -e "$repo_posix" ]; then
    echo "## Repository — path does not exist: \`$repo\` (host \`$host\`)"
    exit 0
fi
root=$(cd "$repo_posix" && pwd)
echo "## Repository — $(date '+%Y-%m-%d %H:%M') — host \`$host\`"
echo
report "$root" "$pull"
siblings "$root" | while IFS= read -r sibling; do
    [ "$sibling" != "$root" ] && report "$sibling" "$pull"
done
exit 0
