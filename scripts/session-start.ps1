# session-start.ps1 — mechanical part of the session start (session-ritual plugin).
# For each repo (the current one plus those listed on the **Sibling repos:** line of
# SESSION_STATE.md): pull --ff-only (unless -NoPull), branch with ahead/behind, main-branch
# ownership note on feature branches, 1.x STATE detection, commits after the last
# /session-end, modified files, last 5 commits.
# Output: a Markdown block ready for the "Repository" section of the briefing.
# Same output, line by line, as scripts/session-start.sh. Exit 0 always.
[CmdletBinding()]
param(
    [string]$Repo = (Get-Location).Path,
    [switch]$NoPull
)

$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Read-State([string]$root) {
    $state = Join-Path $root 'SESSION_STATE.md'
    if (-not (Test-Path $state)) { return $null }
    return @(Get-Content $state -Encoding UTF8 | ForEach-Object { $_ -replace "`r$", '' })
}

function Get-MainBranch([string]$root) {
    $head = git -C $root symbolic-ref -q --short refs/remotes/origin/HEAD 2>$null
    if ($head) { return ($head -replace '^origin/', '') }
    foreach ($b in @('main', 'master')) {
        git -C $root show-ref --verify -q "refs/heads/$b" 2>$null
        if ($LASTEXITCODE -eq 0) { return $b }
    }
    return ''
}

function Get-Siblings([string]$root) {
    $lines = Read-State $root
    if ($null -eq $lines) { return @() }
    $line = $lines | Where-Object { $_ -match '^\*\*(Sibling repos|Repos-irm)' } | Select-Object -First 1
    if (-not $line) { return @() }
    $out = @()
    foreach ($m in [regex]::Matches($line, '`([^`]+)`')) {
        $p = $m.Groups[1].Value.Trim()
        if (Test-Path (Join-Path $p '.git')) { $out += (Resolve-Path $p).Path }
    }
    return $out
}

function Get-LastSessionDate([string]$root) {
    $lines = Read-State $root
    if ($null -eq $lines) { return $null }
    foreach ($l in $lines) {
        if ($l -match '^(last-session|ultima-sessao):\s*(\d{4}-\d{2}-\d{2})') { return $Matches[2] }
    }
    return $null
}

function Test-LegacyState([string]$root) {
    $lines = Read-State $root
    if ($null -eq $lines) { return $false }
    return -not ($lines | Where-Object { $_ -match '^## In progress$' })
}

function Report([string]$root, [bool]$pull) {
    $name = Split-Path $root -Leaf
    Write-Output "### $name"
    Write-Output "- Path: ``$root``"
    if (-not (Test-Path (Join-Path $root '.git'))) {
        Write-Output "- Not a git repository."
        Write-Output ""
        return
    }
    $hasRemote = (@(git -C $root remote 2>$null) | Measure-Object).Count -gt 0
    if (-not $hasRemote) {
        Write-Output "- No remote."
    } elseif ($pull) {
        # "$_" keeps only the stderr text; Out-String would append the ErrorRecord noise
        $out = ((git -C $root pull --ff-only 2>&1 | ForEach-Object { "$_" }) -join "`n")
        if ($LASTEXITCODE -ne 0) {
            Write-Output "- **Pull failed** — the repo may be out of date: $($out.Trim() -replace '\s+', ' ')"
        } else {
            Write-Output "- Pull: $((($out.Trim() -split "`n") | Select-Object -Last 1).Trim())"
        }
    } else {
        Write-Output "- Pull: Not run (--no-pull)."
    }
    $sb = @(git -C $root status -sb 2>$null)
    $head = $sb | Select-Object -First 1
    $branch = git -C $root symbolic-ref -q --short HEAD 2>$null
    if (-not $branch) { $branch = '(detached)' }
    $pos = ''
    if ($head -match 'ahead (\d+)') { $pos += " — **$($Matches[1]) commit(s) ahead of remote**" }
    if ($head -match 'behind (\d+)') { $pos += " — **$($Matches[1]) commit(s) behind remote**" }
    Write-Output "- Branch: $branch$pos"
    $main = Get-MainBranch $root
    if ($branch -ne '(detached)' -and $main -and $branch -ne $main) {
        Write-Output "- Feature branch: STATE is owned by ``$main``; this branch writes only its ``## In progress`` block and the LOG."
    }
    Write-Output "- Last commit: $(git -C $root log --oneline -1 2>$null)"
    if (Test-LegacyState $root) {
        Write-Output "- **STATE in 1.x format** — migrate before the briefing: see references/adoption.md."
    }
    $date = Get-LastSessionDate $root
    if ($date) {
        $after = @(git -C $root log --oneline --since="$date 23:59:59" 2>$null)
        if ($after.Count -gt 0) {
            Write-Output "- **Commits after the last ``/session-end`` ($date): $($after.Count)** — STATE may be stale:"
            $after | Select-Object -First 5 | ForEach-Object { Write-Output "  - $_" }
        }
    }
    $mod = @($sb | Select-Object -Skip 1)
    if ($mod.Count -gt 0) {
        Write-Output "- Modified files ($($mod.Count)):"
        $mod | Select-Object -First 15 | ForEach-Object { Write-Output "  - ``$($_.Trim())``" }
        if ($mod.Count -gt 15) { Write-Output "  - …" }
    } else {
        Write-Output "- Modified files: clean"
    }
    Write-Output "- Recent commits:"
    git -C $root log --oneline -5 2>$null | ForEach-Object { Write-Output "  - $_" }
    Write-Output ""
}

if (-not (Test-Path $Repo)) {
    Write-Output "## Repository — path does not exist: ``$Repo`` (host ``$env:COMPUTERNAME``)"
    exit 0
}
$root = (Resolve-Path $Repo).Path
Write-Output "## Repository — $(Get-Date -Format 'yyyy-MM-dd HH:mm') — host ``$env:COMPUTERNAME``"
Write-Output ""
Report $root (-not $NoPull)
foreach ($sibling in (Get-Siblings $root)) {
    if ($sibling -ne $root) { Report $sibling (-not $NoPull) }
}
exit 0
