#!/usr/bin/env bash
# Tests for scripts/session-hook.sh: when it prints the session start and when it stays silent.
# Run: bash tests/session-hook.tests.sh   (no network: fixtures have no remote or a local bare one)
here=$(cd "$(dirname "$0")" && pwd)
. "$here/lib.sh"
hook="$here/../scripts/session-hook.sh"
export SESSION_RITUAL_SCRIPT_DIR="$here/../scripts"
run() { # run <source> <cwd>
    printf '{"source":"%s","cwd":"%s","hook_event_name":"SessionStart"}' "$1" "$2" | bash "$hook" 2>&1
}
state20='---
last-session: 2000-01-01
---
## In progress
## Now'

r=$(make_repo withstate); make_state "$r" "$state20"; mkdir -p "$r/sub"

o=$(run startup "$r")
assert_match "$o" '^# Session start by hook \(startup\) — ' 'startup in repo with STATE: header'
assert_match "$o" 'Step 1 of /session-start \(script\) already ran here\.' 'startup: instruction line'
assert_match "$o" '^## Repository — ' 'startup: repository block'
assert_match "$o" '^- No remote\.$' 'startup: ran the start script (no remote in fixture)'

r2=$(make_repo withremote); make_state "$r2" "$state20"
bare="$TEST_BASE/withremote.git"; git clone -q --bare "$r2" "$bare"; git -C "$r2" remote add origin "$bare"; git -C "$r2" fetch -q origin
o=$(run compact "$r2")
assert_match "$o" '^# Session start by hook \(compact\) — ' 'compact: header'
assert_match "$o" 'Re-read SESSION_STATE.md before continuing\.' 'compact: re-read instruction'
assert_match "$o" '^- Pull: Not run \(--no-pull\)\.$' 'compact adds no-pull'

for s in resume fork clear; do
    o=$(run "$s" "$r"); expect "$([ -z "$o" ]; echo $?)" "$s is silent"
done

r3=$(make_repo nostate)
expect "$([ -z "$(run startup "$r3")" ]; echo $?)" 'repo without STATE is silent'
r4=$(make_repo declared); sf="$TEST_BASE/declared-files"; mkdir -p "$sf"; make_state "$sf" "$state20"
sfw=$(cygpath -wl "$sf" 2> /dev/null || printf '%s' "$sf") # the hook may run the .ps1, which needs the Windows form
printf '%s
' "**Session files:** \`$sfw\` — personal." > "$r4/CLAUDE.local.md"
o=$(run startup "$r4")
assert_match "$o" '^# Session start by hook \(startup\) — ' 'session files declared elsewhere: hook prints'
assert_match "$o" '^- Session files: `' 'session files declared elsewhere: the script resolved the folder'
mkdir -p "$TEST_BASE/plain"
expect "$([ -z "$(run startup "$TEST_BASE/plain")" ]; echo $?)" 'folder without git is silent'

o=$(run startup "$r/sub")
assert_match "$o" "^# Session start by hook \(startup\) — .*withstate\$" 'subfolder resolves to root'

if command -v cygpath > /dev/null 2>&1; then
    win=$(cygpath -w "$r" | sed 's/\\/\\\\/g')
    o=$(run startup "$win")
    assert_match "$o" '^# Session start by hook \(startup\) — ' 'windows cwd with escaped backslashes resolves'
else
    skip 'windows cwd (no cygpath)'
fi

o=$(cd "$r" && bash "$hook" < /dev/null 2>&1)
assert_match "$o" '^# Session start by hook \(startup\) — ' 'empty stdin defaults to startup and PWD'

echo garbage | bash "$hook" > /dev/null 2>&1; expect $? 'garbage stdin exits 0'

finish
