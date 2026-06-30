$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
    throw 'USERPROFILE is not set. Set USERPROFILE to a valid Windows user profile path before syncing opencode skills.'
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceSkillsPath = Join-Path -Path $repoRoot -ChildPath 'skills'

if (-not (Test-Path -LiteralPath $sourceSkillsPath -PathType Container)) {
    throw "Source skills directory not found: $sourceSkillsPath"
}

$opencodeDirectory = Join-Path -Path $env:USERPROFILE -ChildPath '.config\opencode'
$destinationSkillsPath = Join-Path -Path $opencodeDirectory -ChildPath 'skills'

New-Item -ItemType Directory -Path $destinationSkillsPath -Force | Out-Null
Get-ChildItem -LiteralPath $sourceSkillsPath -Force | Copy-Item -Destination $destinationSkillsPath -Recurse -Force

"Synced opencode skills."
"Source: $sourceSkillsPath"
"Destination: $destinationSkillsPath"
