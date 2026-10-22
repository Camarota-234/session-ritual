#!/usr/bin/env bash
# Contract tests for the written format: the skills and references must agree on the STATE
# sections (`## To exercise` included), the skills stay within their body caps, and this repo's
# own SESSION_STATE.md follows the format it defines. Text checks only; nothing here runs git.
# Run: bash tests/format-contract.tests.sh
here=$(cd "$(dirname "$0")" && pwd)
. "$here/lib.sh"
root="$here/.."
files="$root/references/files.md"
state_headers='In progress|Current state|To exercise|Now|Blocked|Deferred|Debt'

body_lines() { awk '/^---$/ { c++; if (c == 2) { f = 1; next } } f { n++ } END { print n + 0 }' "$1"; }
# headers (`## x`) of the STATE template in files.md (the first markdown fence that has any), joined by '|'
template_headers() { awk '/^```markdown/ { t = 1; h = ""; sep = ""; next } /^```/ { if (t && h != "" && !done) { print h; done = 1 } t = 0 } t && /^## / { sub(/^## /, ""); h = h sep $0; sep = "|" }' "$files"; }

# body caps (spec: start 80, checkpoint 50, end 100)
expect "$([ "$(body_lines "$root/skills/session-start/SKILL.md")" -le 80 ]; echo $?)" 'cap: session-start body <= 80 lines'
expect "$([ "$(body_lines "$root/skills/session-checkpoint/SKILL.md")" -le 50 ]; echo $?)" 'cap: session-checkpoint body <= 50 lines'
expect "$([ "$(body_lines "$root/skills/session-end/SKILL.md")" -le 100 ]; echo $?)" 'cap: session-end body <= 100 lines'

# files.md: template order, quota row, LOG link
assert_match "$(template_headers)" '^In progress\|Current state\|To exercise\|Now\|Blocked\|Deferred\|Debt$' 'files.md: template sections in order, To exercise between Current state and Now'
assert_match "$(grep -E '^\| ' "$files")" '`## To exercise`' 'files.md: quota table has a To exercise row'
assert_match "$(grep -F 'Done, not exercised' "$files")" 'To exercise' 'files.md: LOG bullet "Done, not exercised" points to the section'
assert_match "$(grep -E '^## ' "$files")" '^## To exercise$' 'files.md: has a To exercise rules section'

# every skill knows the section; branches.md keeps it off feature branches
for s in session-start session-checkpoint session-end; do
    assert_match "$(cat "$root/skills/$s/SKILL.md")" 'To exercise' "skill $s mentions To exercise"
done
assert_match "$(cat "$root/references/branches.md")" '`## To exercise`' 'branches.md: feature branch writes nothing in To exercise'

# files that live outside the repo, and 1.x STATEs met at the end
assert_match "$(grep -E '^## ' "$files")" '^## Where the files live$' 'files.md: has a "Where the files live" section'
assert_match "$(cat "$files")" '\*\*Session files:\*\*' 'files.md: documents the Session files declaration'
for s in session-start session-checkpoint session-end; do
    assert_match "$(cat "$root/skills/$s/SKILL.md")" 'Session files' "skill $s knows the Session files folder"
done
assert_match "$(cat "$root/skills/session-end/SKILL.md")" 'adoption\.md' 'session-end: migrates a 1.x STATE through adoption.md'
assert_match "$(cat "$root/skills/session-end/SKILL.md")" '1\.x' 'session-end: checks for a 1.x STATE'
assert_match "$(cat "$root/references/branches.md")" 'Session files' 'branches.md: the feature-branch rule does not apply to files kept elsewhere'

# 1.4.0 name: only the migration table may carry the Portuguese header
leak=$(grep -rl '## A exercitar' "$root/skills" "$root/references" "$root/scripts" 2> /dev/null | grep -v 'references/adoption.md' || true)
expect "$([ -z "$leak" ]; echo $?)" 'no "## A exercitar" outside adoption.md'
assert_match "$(cat "$root/references/adoption.md")" '## A exercitar.*## To exercise' 'adoption.md: maps the 1.4.0 header'

# this repo's own STATE follows the format
state="$root/SESSION_STATE.md"
expect "$([ "$(wc -l < "$state")" -le 80 ]; echo $?)" 'own STATE: <= 80 lines'
unknown=$(grep -E '^## ' "$state" | sed 's/^## //' | grep -vE "^($state_headers)$" || true)
expect "$([ -z "$unknown" ]; echo $?)" "own STATE: only fixed section headers${unknown:+ (found: $unknown)}"
order=$(grep -E '^## ' "$state" | sed 's/^## //' | tr '\n' '|')
if printf '%s' "$order" | grep -q 'To exercise'; then
    assert_match "$order" 'Current state\|To exercise\|Now' 'own STATE: To exercise sits between Current state and Now'
fi

finish
