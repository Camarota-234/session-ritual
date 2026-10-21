# Tests for scripts/session-start.ps1: the 2.0 output contract.
# Run: powershell -NoProfile -ExecutionPolicy Bypass -File tests\session-start.tests.ps1
# No network needed: every run passes -NoPull; remotes are local bare repos.
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$script = Join-Path $PSScriptRoot '..\scripts\session-start.ps1'
$base = Join-Path $env:TEMP ('ssr-test-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force $base | Out-Null
$env:GIT_AUTHOR_NAME = 'test'; $env:GIT_AUTHOR_EMAIL = 'test@example.com'
$env:GIT_COMMITTER_NAME = 'test'; $env:GIT_COMMITTER_EMAIL = 'test@example.com'

$script:failures = 0
function Expect([bool]$ok, [string]$msg) {
    if ($ok) { Write-Output "ok    $msg" } else { Write-Output "FAIL  $msg"; $script:failures++ }
}
function Run([string]$repo) {
    (& powershell -NoProfile -ExecutionPolicy Bypass -File $script -Repo $repo -NoPull 2>&1 | Out-String)
}
function New-Repo([string]$name, [string]$branch = 'main') {
    $r = Join-Path $base $name
    New-Item -ItemType Directory -Force $r | Out-Null
    git -C $r init -q -b $branch
    Set-Content (Join-Path $r 'README.md') 'hello' -Encoding UTF8
    git -C $r add -A; git -C $r commit -q -m 'init'
    return $r
}
function Set-State([string]$repo, [string]$content, [bool]$crlf = $false) {
    $text = if ($crlf) { ($content -replace "`r?`n", "`r`n") } else { ($content -replace "`r?`n", "`n") }
    [IO.File]::WriteAllText((Join-Path $repo 'SESSION_STATE.md'), $text, (New-Object Text.UTF8Encoding $false))
}
$state1x = @"
---
ultima-sessao: 2000-01-01
---
# Estado
## Estado atual
- x
## Pendências
- y
## Próxima sessão
1. z
"@
$state20 = @"
---
last-session: 2000-01-01
last-full-end: 2000-01-01
---
# State
## In progress
## Current state
- x
## Now
1. z
"@

try {
    # clean repo
    $r = New-Repo 'clean'
    $o = Run $r
    Expect ($o -match '(?m)^## Repository — \d{4}-\d{2}-\d{2} \d{2}:\d{2} — host `') 'clean repo: header line'
    Expect ($o -match '(?m)^- Branch: main\s*$') 'clean repo: branch main without ahead/behind'
    Expect ($o -match '- Modified files: clean') 'clean repo: modified files clean'
    Expect ($o -match '- Last commit: [0-9a-f]{7} init') 'clean repo: last commit'
    Expect ($o -match '- Recent commits:\s*\n\s*- [0-9a-f]{7} init') 'clean repo: recent commits'
    Expect ($o -notmatch 'Feature branch') 'clean repo: no feature-branch line'
    Expect ($o -notmatch '1\.x format') 'clean repo without STATE: no legacy line'

    # ahead of remote
    $r = New-Repo 'ahead'
    $bare = Join-Path $base 'ahead.git'
    git clone -q --bare $r $bare
    git -C $r remote add origin $bare
    git -C $r fetch -q origin
    git -C $r branch -q --set-upstream-to=origin/main main
    Set-Content (Join-Path $r 'b.txt') 'b'; git -C $r add -A; git -C $r commit -q -m 'second'
    $o = Run $r
    Expect ($o -match '\*\*1 commit\(s\) ahead of remote\*\*') 'ahead of remote: ahead line'
    Expect ($o -match '- Pull: Not run \(--no-pull\)\.') 'ahead of remote: pull not run with a remote present'

    # no remote
    $r = New-Repo 'noremote'
    Expect ((Run $r) -match '(?m)^- No remote\.') 'no remote: line'

    # not a git folder
    $d = Join-Path $base 'plain'; New-Item -ItemType Directory -Force $d | Out-Null
    $o = Run $d
    Expect ($o -match '- Not a git repository\.') 'not a git folder: line'
    Expect ($o -notmatch '- Branch:') 'not a git folder: stops there'

    # STATE 1.x
    $r = New-Repo 'legacy'; Set-State $r $state1x
    Expect ((Run $r) -match '\*\*STATE in 1\.x format\*\* — migrate before the briefing: see references/adoption\.md\.') 'STATE 1.x: legacy line'

    # STATE 2.0
    $r = New-Repo 'modern'; Set-State $r $state20
    Expect ((Run $r) -notmatch '1\.x format') 'STATE 2.0: no legacy line'

    # commits after last end (ultima-sessao)
    $r = New-Repo 'after-legacy'; Set-State $r $state1x
    $o = Run $r
    Expect ($o -match 'Commits after the last `/session-end` \(2000-01-01\): 1') 'commits after last end: ultima-sessao key'
    Expect ($o -match '(?m)^  - [0-9a-f]{7} init') 'commits after last end: lists the commit'

    # commits after last end (last-session)
    $r = New-Repo 'after-modern'; Set-State $r $state20
    Expect ((Run $r) -match 'Commits after the last `/session-end` \(2000-01-01\): 1') 'commits after last end: last-session key'

    # CRLF state
    $r = New-Repo 'crlf'; Set-State $r $state20 $true
    $o = Run $r
    Expect ($o -notmatch '1\.x format') 'CRLF state: still detected as 2.0'
    Expect ($o -match '\(2000-01-01\)') 'CRLF state: last-session still read'

    # feature branch
    $r = New-Repo 'feature'; git -C $r checkout -q -b feat/x
    $o = Run $r
    Expect ($o -match '(?m)^- Branch: feat/x') 'feature branch: branch name'
    Expect ($o -match 'Feature branch: STATE is owned by `main`; this branch writes only its `## In progress` block and the LOG\.') 'feature branch: ownership line'

    # master as main
    $r = New-Repo 'master' 'master'
    $o = Run $r
    Expect ($o -match '(?m)^- Branch: master\s*$') 'master as main: branch'
    Expect ($o -notmatch 'Feature branch') 'master as main: no feature line'

    # detached HEAD
    $r = New-Repo 'detached'; git -C $r checkout -q --detach
    $o = Run $r
    Expect ($o -match '(?m)^- Branch: \(detached\)') 'detached HEAD: branch line'
    Expect ($o -notmatch 'Feature branch') 'detached HEAD: no feature line'

    # sibling repos (both spellings)
    $sib = New-Repo 'sibling'
    $bt = [char]96
    $r = New-Repo 'withsib'; Set-State $r (@('---', 'last-session: 2000-01-01', '---', ('**Sibling repos:** ' + $bt + $sib + $bt + ' — the other half.'), '## In progress') -join "`n")
    $o = Run $r
    Expect (([regex]::Matches($o, '(?m)^### ')).Count -eq 2) 'sibling repos (Sibling repos:): two blocks'
    Expect ($o -match '(?m)^### sibling') 'sibling repos: sibling block named'
    $r = New-Repo 'withsib-pt'; Set-State $r (@('---', 'ultima-sessao: 2000-01-01', '---', ('**Repos-irmãos:** ' + $bt + $sib + $bt + ' — a outra metade.'), '## Próxima sessão') -join "`n")
    Expect (([regex]::Matches((Run $r), '(?m)^### ')).Count -eq 2) 'sibling repos (Repos-irmãos:): two blocks'

    # missing repo path
    $o = (& powershell -NoProfile -ExecutionPolicy Bypass -File $script -Repo (Join-Path $base 'nope') -NoPull 2>&1 | Out-String)
    Expect ($o -match 'path does not exist') 'missing repo path: message'
    Expect ($LASTEXITCODE -eq 0) 'missing repo path: exit 0'
} finally {
    Remove-Item -Recurse -Force $base -ErrorAction SilentlyContinue
}
if ($script:failures -gt 0) { Write-Output "$($script:failures) failure(s)"; exit 1 }
Write-Output 'all green'
