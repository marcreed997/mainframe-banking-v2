#requires -Version 5.1
<#
.SYNOPSIS
  Create the local V2 tree on this Windows workstation. Never writes into V1.

.DESCRIPTION
  Default: git clone https://github.com/marcreed997/mainframe-banking-v2
  into D:\AIcomp\mainframe-banking-v2

  Does NOT modify:
    D:\AIcomp\testcpl                  (V1 COBOL)
    D:\AIcomp\agents                   (live agent tree)
    D:\AIcomp\modernized\bank-system-java
    D:\AIcomp\grok                     (if present)

  Expected after a successful clone (commit b113ca7 or later):
    67  *.cbl
    35  *.cpy
    14  *.bms
    docs\LOC-REPORT.md total = 10397

.PARAMETER Root
  Lab parent. Default D:\AIcomp

.PARAMETER RepoUrl
  V2 GitHub URL.

.PARAMETER TargetName
  Folder name under Root.

.PARAMETER SkeletonOnly
  Create empty directories only. No git. Use only if git is not installed.

.PARAMETER PullIfExists
  If Target is already this repo, git pull --ff-only.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\Setup-MainframeBankingV2.ps1

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\Setup-MainframeBankingV2.ps1 -PullIfExists
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string] $Root = 'D:\AIcomp',
    [string] $RepoUrl = 'https://github.com/marcreed997/mainframe-banking-v2.git',
    [string] $TargetName = 'mainframe-banking-v2',
    [switch] $SkeletonOnly,
    [switch] $PullIfExists
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step([string] $Msg) {
    Write-Host ("`n=== {0} ===" -f $Msg) -ForegroundColor Cyan
}

function Assert-NotV1([string] $Path) {
    $full = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
    $forbidden = @(
        (Join-Path $Root 'testcpl'),
        (Join-Path $Root 'agents'),
        (Join-Path $Root 'modernized')
    ) | ForEach-Object { [System.IO.Path]::GetFullPath($_).TrimEnd('\') }

    foreach ($f in $forbidden) {
        if ($full.Equals($f, [StringComparison]::OrdinalIgnoreCase) -or
            $full.StartsWith($f + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to write under protected path: $f"
        }
    }
}

$Target = Join-Path $Root $TargetName
Assert-NotV1 $Target

$layout = @(
    'copybook',
    'cobol\online',
    'cobol\batch',
    'cics',
    'db2',
    'docs',
    'jcl\jobs',
    'jcl\proc',
    'jcl\ctl',
    'testdata'
)

Write-Step "1. Parent lab folder"
if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    if ($PSCmdlet.ShouldProcess($Root, 'Create directory')) {
        New-Item -ItemType Directory -Path $Root | Out-Null
        Write-Host "Created $Root"
    }
} else {
    Write-Host "Exists: $Root"
}

Write-Host "Protected (untouched):"
@(
    (Join-Path $Root 'testcpl'),
    (Join-Path $Root 'agents'),
    (Join-Path $Root 'modernized\bank-system-java')
) | ForEach-Object {
    if (Test-Path -LiteralPath $_) { Write-Host "  OK  $_" -ForegroundColor Green }
    else { Write-Host "  --  $_ (not present; not created)" -ForegroundColor Yellow }
}

if ($SkeletonOnly) {
    Write-Step "2. Skeleton directories only (no clone)"
    foreach ($rel in $layout) {
        $p = Join-Path $Target $rel
        if ($PSCmdlet.ShouldProcess($p, 'Create directory')) {
            New-Item -ItemType Directory -Force -Path $p | Out-Null
        }
    }
    Write-Host "Empty tree at $Target"
    Write-Host "Re-run WITHOUT -SkeletonOnly once git is available to fill the files."
    exit 0
}

Write-Step "2. git"
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    throw @"
git.exe not found on PATH.
Install Git for Windows, then re-run this script.
Or run with -SkeletonOnly to create empty folders only (not recommended).
"@
}
git --version

Write-Step "3. Clone or reuse $Target"
if (Test-Path -LiteralPath (Join-Path $Target '.git')) {
    Push-Location $Target
    try {
        $origin = (git remote get-url origin).Trim()
        Write-Host "Existing clone origin=$origin"
        if ($origin -notmatch 'mainframe-banking-v2') {
            throw "Refusing: $Target origin is not the V2 repo ($origin)"
        }
        if ($PullIfExists) {
            if ($PSCmdlet.ShouldProcess($Target, 'git pull --ff-only')) {
                git pull --ff-only
            }
        } else {
            Write-Host "Already cloned. Pass -PullIfExists to fast-forward."
        }
        git log -1 --oneline
    } finally {
        Pop-Location
    }
} elseif (Test-Path -LiteralPath $Target) {
    $any = Get-ChildItem -LiteralPath $Target -Force | Select-Object -First 1
    if ($any) {
        throw @"
$Target already exists and is not a git clone.
Move/rename it, or pass a different -TargetName.
This script will not overwrite a non-git folder.
"@
    }
    if ($PSCmdlet.ShouldProcess($Target, "git clone $RepoUrl")) {
        git clone $RepoUrl $Target
    }
} else {
    if ($PSCmdlet.ShouldProcess($Target, "git clone $RepoUrl")) {
        git clone $RepoUrl $Target
    }
}

Write-Step "4. Verify inventory"
if (-not (Test-Path -LiteralPath (Join-Path $Target 'docs\LOC-REPORT.md'))) {
    throw "Clone looks incomplete: docs\LOC-REPORT.md missing"
}

$counts = [ordered]@{
    cbl = @(Get-ChildItem -LiteralPath $Target -Recurse -Filter '*.cbl' -File).Count
    cpy = @(Get-ChildItem -LiteralPath $Target -Recurse -Filter '*.cpy' -File).Count
    bms = @(Get-ChildItem -LiteralPath $Target -Recurse -Filter '*.bms' -File).Count
    sql = @(Get-ChildItem -LiteralPath $Target -Recurse -Filter '*.sql' -File).Count
}
$counts.GetEnumerator() | ForEach-Object { Write-Host ("  {0,4}  {1}" -f $_.Value, $_.Key) }

$expect = @{ cbl = 67; cpy = 35; bms = 14; sql = 1 }
$bad = @()
foreach ($k in $expect.Keys) {
    if ($counts[$k] -lt $expect[$k]) {
        $bad += "{0}={1} (expected >= {2})" -f $k, $counts[$k], $expect[$k]
    }
}

$locLine = Select-String -LiteralPath (Join-Path $Target 'docs\LOC-REPORT.md') `
    -Pattern 'Total counted source lines:\*\*\s*(\d+)' | Select-Object -First 1
if ($locLine) {
    $n = [int]$locLine.Matches[0].Groups[1].Value
    Write-Host "  LOC-REPORT total = $n"
    if ($n -lt 9000 -or $n -gt 12000) {
        $bad += "LOC-REPORT $n not in 9000-12000"
    }
} else {
    $bad += 'Could not parse docs\LOC-REPORT.md'
}

if ($bad.Count -gt 0) {
    Write-Host "VERIFY FAILED:" -ForegroundColor Red
    $bad | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host "`nVERIFY OK  $Target" -ForegroundColor Green
Write-Host @"

Do not convert V2 with runner.py yet.
Do not rewrite D:\AIcomp\testcpl (V1).
Next lab step: ingest V2 *jobs + wait edges* into Memgraph (BL-060 shaped), not V1.
"@
exit 0
