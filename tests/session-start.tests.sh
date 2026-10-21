#!/usr/bin/env bash
# Tests for scripts/session-start.sh: same scenarios as the .ps1 tests, plus Windows
# sibling paths and a parity diff against the .ps1 when PowerShell is available.
# Run: bash tests/session-start.tests.sh
here=$(cd "$(dirname "$0")" && pwd)
. "$here/lib.sh"
script="$here/../scripts/session-start.sh"
run() { bash "$script" --repo "$1" --no-pull 2>&1; }

state1x='---
ultima-sessao: 2000-01-01
---
# Estado
## Estado atual
- x
## Pendências
- y
## Próxima sessão
1. z'
state20='---
last-session: 2000-01-01
last-full-end: 2000-01-01
---
# State
## In progress
## Current state
- x
## Now
1. z'

# clean repo
r=$(make_repo clean); o=$(run "$r")
assert_match "$o" '^## Repository — [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2} — host `' 'clean repo: header line'
assert_match "$o" '^- Branch: main$' 'clean repo: branch main without ahead/behind'
assert_match "$o" '^- Modified files: clean$' 'clean repo: modified files clean'
assert_match "$o" '^- Last commit: [0-9a-f]{7} init$' 'clean repo: last commit'
assert_match "$o" '^  - [0-9a-f]{7} init$' 'clean repo: recent commits'
assert_no_match "$o" 'Feature branch' 'clean repo: no feature-branch line'
assert_no_match "$o" '1\.x format' 'clean repo without STATE: no legacy line'

# ahead of remote
r=$(make_repo ahead); bare="$TEST_BASE/ahead.git"
git clone -q --bare "$r" "$bare"; git -C "$r" remote add origin "$bare"; git -C "$r" fetch -q origin
git -C "$r" branch -q --set-upstream-to=origin/main main
echo b > "$r/b.txt"; git -C "$r" add -A; git -C "$r" commit -q -m second
o=$(run "$r")
assert_match "$o" '\*\*1 commit\(s\) ahead of remote\*\*' 'ahead of remote: ahead line'
assert_match "$o" '^- Pull: Not run \(--no-pull\)\.$' 'ahead of remote: pull not run with a remote present'

# no remote
r=$(make_repo noremote); assert_match "$(run "$r")" '^- No remote\.$' 'no remote: line'

# not a git folder
mkdir -p "$TEST_BASE/plain"; o=$(run "$TEST_BASE/plain")
assert_match "$o" '^- Not a git repository\.$' 'not a git folder: line'
assert_no_match "$o" '^- Branch:' 'not a git folder: stops there'

# STATE 1.x / 2.0
r=$(make_repo legacy); make_state "$r" "$state1x"
assert_match "$(run "$r")" '^- \*\*STATE in 1\.x format\*\* — migrate before the briefing: see references/adoption\.md\.$' 'STATE 1.x: legacy line'
r=$(make_repo modern); make_state "$r" "$state20"
assert_no_match "$(run "$r")" '1\.x format' 'STATE 2.0: no legacy line'

# commits after last end
r=$(make_repo after-legacy); make_state "$r" "$state1x"; o=$(run "$r")
assert_match "$o" 'Commits after the last `/session-end` \(2000-01-01\): 1' 'commits after last end: ultima-sessao key'
assert_match "$o" '^  - [0-9a-f]{7} init$' 'commits after last end: lists the commit'
r=$(make_repo after-modern); make_state "$r" "$state20"
assert_match "$(run "$r")" 'Commits after the last `/session-end` \(2000-01-01\): 1' 'commits after last end: last-session key'

# CRLF state
r=$(make_repo crlf); make_state "$r" "$state20" crlf; o=$(run "$r")
assert_no_match "$o" '1\.x format' 'CRLF state: still detected as 2.0'
assert_match "$o" '\(2000-01-01\)' 'CRLF state: last-session still read'

# feature branch
r=$(make_repo feature); git -C "$r" checkout -q -b feat/x; o=$(run "$r")
assert_match "$o" '^- Branch: feat/x$' 'feature branch: branch name'
assert_match "$o" '^- Feature branch: STATE is owned by `main`; this branch writes only its `## In progress` block and the LOG\.$' 'feature branch: ownership line'

# master as main
r=$(make_repo master master); o=$(run "$r")
assert_match "$o" '^- Branch: master$' 'master as main: branch'
assert_no_match "$o" 'Feature branch' 'master as main: no feature line'

# detached HEAD
r=$(make_repo detached); git -C "$r" checkout -q --detach; o=$(run "$r")
assert_match "$o" '^- Branch: \(detached\)$' 'detached HEAD: branch line'
assert_no_match "$o" 'Feature branch' 'detached HEAD: no feature line'

# sibling repos (both spellings)
sib=$(make_repo sibling)
r=$(make_repo withsib); make_state "$r" "$(printf -- '---\nlast-session: 2000-01-01\n---\n**Sibling repos:** `%s` — the other half.\n## In progress' "$sib")"
o=$(run "$r")
expect "$([ "$(printf '%s\n' "$o" | grep -c '^### ')" -eq 2 ]; echo $?)" 'sibling repos (Sibling repos:): two blocks'
assert_match "$o" '^### sibling$' 'sibling repos: sibling block named'
r=$(make_repo withsib-pt); make_state "$r" "$(printf -- '---\nultima-sessao: 2000-01-01\n---\n**Repos-irmãos:** `%s` — a outra metade.\n## Próxima sessão' "$sib")"
expect "$([ "$(run "$r" | grep -c '^### ')" -eq 2 ]; echo $?)" 'sibling repos (Repos-irmãos:): two blocks'

# windows sibling path
if command -v cygpath > /dev/null 2>&1; then
    r=$(make_repo withsib-win); make_state "$r" "$(printf -- '---\nlast-session: 2000-01-01\n---\n**Sibling repos:** `%s` — windows path.\n## In progress' "$(cygpath -w "$sib")")"
    expect "$([ "$(run "$r" | grep -c '^### ')" -eq 2 ]; echo $?)" 'windows sibling path: two blocks'
else
    skip 'windows sibling path (no cygpath)'
fi

# missing repo path
o=$(bash "$script" --repo "$TEST_BASE/nope" --no-pull 2>&1); rc=$?
assert_match "$o" 'path does not exist' 'missing repo path: message'
expect "$rc" 'missing repo path: exit 0'

# parity with ps1
ps=""; command -v pwsh > /dev/null 2>&1 && ps=pwsh; [ -z "$ps" ] && command -v powershell > /dev/null 2>&1 && ps=powershell
if [ -n "$ps" ] && command -v cygpath > /dev/null 2>&1; then
    r=$(make_repo parity); make_state "$r" "$(printf -- '---\nlast-session: 2000-01-01\n---\n**Sibling repos:** `%s` — the other half.\n## In progress' "$(cygpath -wl "$sib")")"
    echo c > "$r/c.txt"
    a=$("$ps" -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -wl "$here/../scripts/session-start.ps1")" -Repo "$(cygpath -wl "$r")" -NoPull 2>&1 | tr -d '\r' | tail -n +2)
    b=$(run "$(cygpath -wl "$r")" | tail -n +2)
    if d=$(diff <(printf '%s\n' "$a") <(printf '%s\n' "$b")); then expect 0 'parity with ps1'; else expect 1 'parity with ps1'; printf '%s\n' "$d" | head -20; fi
else
    skip 'parity with ps1 (no PowerShell or cygpath)'
fi

finish
