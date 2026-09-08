# session-start.ps1 — parte mecânica do início de sessão (plugin session-ritual).
# Para cada repo (o atual + os declarados em **Repos-irmãos:** do SESSION_STATE.md):
# pull --ff-only (salvo -NoPull), status -sb com ahead/behind, últimos 5 commits.
# Saída: bloco Markdown pronto para a seção "Repositório" do briefing. Exit 0 sempre.
[CmdletBinding()]
param(
    [string]$Repo = (Get-Location).Path,
    [switch]$NoPull
)

$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-Irmaos([string]$raiz) {
    $state = Join-Path $raiz 'SESSION_STATE.md'
    if (-not (Test-Path $state)) { return @() }
    $linha = Get-Content $state -Encoding UTF8 | Where-Object { $_ -match '^\*\*Repos-irm' } | Select-Object -First 1
    if (-not $linha) { return @() }
    $m = [regex]::Matches($linha, '`([^`]+)`')
    $out = @()
    foreach ($x in $m) {
        $p = $x.Groups[1].Value.Trim()
        if (Test-Path (Join-Path $p '.git')) { $out += (Resolve-Path $p).Path }
    }
    return $out
}

function Relatar([string]$raiz, [bool]$pull) {
    $nome = Split-Path $raiz -Leaf
    Write-Output "### $nome"
    Write-Output "- Caminho: ``$raiz``"
    if (-not (Test-Path (Join-Path $raiz '.git'))) {
        Write-Output "- Não é repositório Git."
        Write-Output ""
        return
    }
    $temRemote = (@(git -C $raiz remote 2>$null) | Measure-Object).Count -gt 0
    if ($pull -and $temRemote) {
        $saida = (git -C $raiz pull --ff-only 2>&1 | Out-String)
        if ($LASTEXITCODE -ne 0) {
            Write-Output "- **Pull falhou** — o repo pode estar desatualizado: $($saida.Trim() -replace '\s+', ' ')"
        } else {
            $ln = (($saida.Trim() -split "`n") | Select-Object -Last 1)
            Write-Output "- Pull: $ln"
        }
    } elseif (-not $temRemote) {
        Write-Output "- Sem remote."
    } else {
        Write-Output "- Pull: não rodado (-NoPull)."
    }
    $sb = @(git -C $raiz status -sb 2>$null)
    $cab = $sb | Select-Object -First 1
    $branch = ($cab -replace '^## ', '') -replace '\.\.\..*$', ''
    $ahead = 0; $behind = 0
    if ($cab -match 'ahead (\d+)') { $ahead = [int]$Matches[1] }
    if ($cab -match 'behind (\d+)') { $behind = [int]$Matches[1] }
    $pos = ''
    if ($ahead -gt 0) { $pos += " — **$ahead commit(s) à frente do remote**" }
    if ($behind -gt 0) { $pos += " — **$behind commit(s) atrás do remote**" }
    Write-Output "- Branch: $branch$pos"
    $ult = git -C $raiz log --oneline -1 2>$null
    Write-Output "- Último commit: $ult"
    $mod = @($sb | Select-Object -Skip 1)
    if ($mod.Count -gt 0) {
        Write-Output "- Arquivos modificados ($($mod.Count)):"
        $mod | Select-Object -First 15 | ForEach-Object { Write-Output "  - ``$($_.Trim())``" }
        if ($mod.Count -gt 15) { Write-Output "  - …" }
    } else {
        Write-Output "- Arquivos modificados: limpo"
    }
    Write-Output "- Últimos commits:"
    git -C $raiz log --oneline -5 2>$null | ForEach-Object { Write-Output "  - $_" }
    Write-Output ""
}

if (-not (Test-Path $Repo)) {
    Write-Output "## Repositório — caminho não existe: ``$Repo`` (máquina ``$env:COMPUTERNAME``)"
    exit 0
}
$raiz = (Resolve-Path $Repo).Path
Write-Output "## Repositório — $(Get-Date -Format 'yyyy-MM-dd HH:mm') — máquina ``$env:COMPUTERNAME``"
Write-Output ""
Relatar $raiz (-not $NoPull)
foreach ($irmao in (Get-Irmaos $raiz)) {
    if ($irmao -ne $raiz) { Relatar $irmao (-not $NoPull) }
}
exit 0
