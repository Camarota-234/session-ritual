#!/usr/bin/env bash
# session-hook.sh — SessionStart hook shipped by the session-ritual plugin.
# Reads the hook event JSON on stdin (source, cwd). On "startup" and "compact", when cwd is
# inside a git repo that has SESSION_STATE.md at its root, prints the session-start script
# output so the briefing never depends on the model remembering to run it. Pull only on
# startup. Any other source, or a repo without STATE, prints nothing. Exit 0 always.
set -u

dir="${SESSION_RITUAL_SCRIPT_DIR:-$(cd "$(dirname "$0")" && pwd)}"
input=$(cat 2> /dev/null || true)
source=$(printf '%s' "$input" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
cwd=$(printf '%s' "$input" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
[ -n "$source" ] || source=startup
[ -n "$cwd" ] || cwd="$PWD"
cwd=$(printf '%s' "$cwd" | sed 's/\\\\/\\/g')
if command -v cygpath > /dev/null 2>&1; then cwd=$(cygpath -u "$cwd" 2> /dev/null || printf '%s' "$cwd"); fi

case "$source" in startup | compact) ;; *) exit 0 ;; esac
[ -d "$cwd" ] || exit 0
root=$(git -C "$cwd" rev-parse --show-toplevel 2> /dev/null) || exit 0
[ -n "$root" ] && [ -f "$root/SESSION_STATE.md" ] || exit 0

echo "# Session start by hook ($source) — $root"
echo
if [ "$source" = compact ]; then
    echo "The conversation was compacted: this reloads the mechanical state. Re-read SESSION_STATE.md before continuing."
else
    echo "Step 1 of /session-start (script) already ran here. Still to do: read SESSION_STATE.md and the top of SESSION_LOG.md and build the briefing."
fi
echo

ps=""
command -v pwsh > /dev/null 2>&1 && ps=pwsh
[ -z "$ps" ] && command -v powershell > /dev/null 2>&1 && ps=powershell
if [ -n "$ps" ] && [ -f "$dir/session-start.ps1" ]; then
    script="$dir/session-start.ps1"; repo="$root"
    if command -v cygpath > /dev/null 2>&1; then script=$(cygpath -wl "$script"); repo=$(cygpath -wl "$root"); fi
    if [ "$source" = compact ]; then
        "$ps" -NoProfile -ExecutionPolicy Bypass -File "$script" -Repo "$repo" -NoPull 2>&1
    else
        "$ps" -NoProfile -ExecutionPolicy Bypass -File "$script" -Repo "$repo" 2>&1
    fi
elif [ -f "$dir/session-start.sh" ]; then
    if [ "$source" = compact ]; then
        bash "$dir/session-start.sh" --repo "$root" --no-pull 2>&1
    else
        bash "$dir/session-start.sh" --repo "$root" 2>&1
    fi
else
    echo "session-start script not found in $dir."
fi
exit 0
