# Shared helpers for the bash test scripts. Source it; do not run it.
# No framework: `expect`, `assert_match`, `assert_no_match`, fixtures under a temp dir.
set -u
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
failures=0
skips=0
TEST_BASE=$(mktemp -d "${TMPDIR:-/tmp}/ssr-test-XXXXXX")

expect() { # expect <exit-status> <message>
    if [ "$1" -eq 0 ]; then echo "ok    $2"; else echo "FAIL  $2"; failures=$((failures + 1)); fi
}
assert_match() { # assert_match <text> <ERE> <message>
    printf '%s' "$1" | grep -qE -- "$2"; expect $? "$3"
}
assert_no_match() { # assert_no_match <text> <ERE> <message>
    if printf '%s' "$1" | grep -qE -- "$2"; then expect 1 "$3"; else expect 0 "$3"; fi
}
skip() { echo "skip  $1"; skips=$((skips + 1)); }

make_repo() { # make_repo <name> [branch] → prints the repo path
    local r="$TEST_BASE/$1" branch="${2:-main}"
    mkdir -p "$r"
    git -C "$r" init -q -b "$branch"
    git -C "$r" config core.autocrlf false
    echo hello > "$r/README.md"
    git -C "$r" add -A && git -C "$r" commit -q -m init
    printf '%s' "$r"
}
make_state() { # make_state <repo> <content> [crlf]
    if [ "${3:-}" = crlf ]; then printf '%s\n' "$2" | sed 's/$/\r/' > "$1/SESSION_STATE.md"
    else printf '%s\n' "$2" > "$1/SESSION_STATE.md"; fi
}
finish() {
    rm -rf "$TEST_BASE"
    if [ "$failures" -gt 0 ]; then echo "$failures failure(s)"; exit 1; fi
    if [ "$skips" -gt 0 ]; then echo "all green ($skips skipped)"; else echo "all green"; fi
}
