$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
    throw 'USERPROFILE is not set. Set USERPROFILE to a valid Windows user profile path before syncing opencode prompts.'
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceAgentsPath = Join-Path -Path $repoRoot -ChildPath 'agents'

if (-not (Test-Path -LiteralPath $sourceAgentsPath -PathType Container)) {
    throw "Source agents directory not found: $sourceAgentsPath"
}

$opencodeDirectory = Join-Path -Path $env:USERPROFILE -ChildPath '.config\opencode'
$destinationAgentsPath = Join-Path -Path $opencodeDirectory -ChildPath 'prompts'

New-Item -ItemType Directory -Path $destinationAgentsPath -Force | Out-Null
Get-ChildItem -LiteralPath $sourceAgentsPath -Force | Copy-Item -Destination $destinationAgentsPath -Recurse -Force

"Synced opencode prompts."
"Source: $sourceAgentsPath"
"Destination: $destinationAgentsPath"
