<#
.SYNOPSIS
Legacy/archive-only validator for SDD security-applicability.md artifacts.

.DESCRIPTION
This validator is retained only for explicit legacy/archive compatibility checks.
It MUST NOT block new-change routing or phase success. New SDD changes classify
security impact inside design.md#secure-development-design and are validated by
review-security against the shared catalog and artifact evidence. This validator intentionally avoids
runtime security scanning and checks only the historical Markdown YAML fence
contract, routing consistency, category matrix completeness, no-impact proof,
guideline/source references, override safety, severity values, and validation
metadata required by archived SDD security applicability artifacts.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path,

    [switch]$AllowManualPending
)

$ErrorActionPreference = 'Stop'

$ExpectedSnapshotId = 'security-guidelines-initial-user-snapshot-2026-06-30'
$ExpectedTaxonomyVersion = '1'
$ExpectedValidator = 'scripts/validate_security_applicability.ps1'

$SupportedCategories = @(
    'authentication',
    'sessions',
    'sensitive-data-pan',
    'secrets',
    'permissions-access-control',
    'files',
    'database-access',
    'sensitive-logging'
)

$AllowedDecisions = @('applicable', 'not-applicable', 'unknown')
$AllowedSeverity = @('blocking', 'conditional', 'advisory')
$AllowedValidationStatuses = @('pass', 'fail', 'manual-pending')
$AllowedOverrideKeys = @('extraPrompts', 'strictSourceCoverage', 'validatorMode', 'categorySeverity')
$AllowedOverrideSafety = @('accepted-stricter', 'rejected-unsafe', 'ignored-unsafe')

$Guidelines = @{
    'SEC-AUTH-001'   = @{ Category = 'authentication'; SourceIds = @('1.1-1.10', '2.1-2.23', '6.3', '14.8'); Severity = 'blocking' }
    'SEC-SESS-001'   = @{ Category = 'sessions'; SourceIds = @('7.1-7.13'); Severity = 'blocking' }
    'SEC-DATA-001'   = @{ Category = 'sensitive-data-pan'; SourceIds = @('4.1', '13.1-13.9', '15.1-15.2'); Severity = 'blocking' }
    'SEC-SECRET-001' = @{ Category = 'secrets'; SourceIds = @('2.1', '4.2', '4.8', '5.5', '6.1', '13.5'); Severity = 'blocking' }
    'SEC-ACCESS-001' = @{ Category = 'permissions-access-control'; SourceIds = @('1.4', '6.2-6.4', '6.12', '13.1', '14.1-14.9'); Severity = 'blocking' }
    'SEC-FILE-001'   = @{ Category = 'files'; SourceIds = @('9.1-9.12', '14.7'); Severity = 'blocking' }
    'SEC-DB-001'     = @{ Category = 'database-access'; SourceIds = @('5.1-5.12', '11.1-11.16', '12.2'); Severity = 'blocking' }
    'SEC-LOG-001'    = @{ Category = 'sensitive-logging'; SourceIds = @('3.1-3.11', '8.1-8.5'); Severity = 'blocking' }
}

function Add-RangeIds {
    param(
        [hashtable]$Set,
        [int]$Section,
        [int]$Start,
        [int]$End
    )

    for ($i = $Start; $i -le $End; $i++) {
        $Set["$Section.$i"] = $true
    }
}

$ValidSourceIds = @{}
Add-RangeIds $ValidSourceIds 1 1 10
Add-RangeIds $ValidSourceIds 2 1 23
Add-RangeIds $ValidSourceIds 3 1 11
Add-RangeIds $ValidSourceIds 4 1 8
Add-RangeIds $ValidSourceIds 5 1 12
Add-RangeIds $ValidSourceIds 6 1 14
Add-RangeIds $ValidSourceIds 7 1 13
Add-RangeIds $ValidSourceIds 8 1 5
Add-RangeIds $ValidSourceIds 9 1 12
Add-RangeIds $ValidSourceIds 10 1 6
Add-RangeIds $ValidSourceIds 11 1 16
Add-RangeIds $ValidSourceIds 12 1 5
Add-RangeIds $ValidSourceIds 13 1 9
Add-RangeIds $ValidSourceIds 14 1 9
Add-RangeIds $ValidSourceIds 15 1 2

$Errors = New-Object System.Collections.Generic.List[string]

function Add-ValidationError {
    param([string]$Message)
    $Errors.Add($Message) | Out-Null
}

function Get-ScalarValue {
    param(
        [string]$Yaml,
        [string]$Name
    )

    $match = [regex]::Match($Yaml, "(?m)^\s*$([regex]::Escape($Name)):\s*(.+?)\s*$")
    if (-not $match.Success) { return $null }
    return ($match.Groups[1].Value.Trim().Trim('"').Trim("'"))
}

function Get-BlockText {
    param(
        [string]$Yaml,
        [string]$Name
    )

    $lines = $Yaml -split "`r?`n"
    $start = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^$([regex]::Escape($Name)):\s*$") {
            $start = $i + 1
            break
        }
    }
    if ($start -lt 0) { return '' }

    $result = New-Object System.Collections.Generic.List[string]
    for ($i = $start; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^\S[^:]*:\s*' -and $line -notmatch '^\s+-') { break }
        $result.Add($line) | Out-Null
    }
    return ($result -join "`n")
}

function Get-ListValues {
    param(
        [string]$Yaml,
        [string]$Name
    )

    $inline = [regex]::Match($Yaml, "(?m)^\s*$([regex]::Escape($Name)):\s*\[(.*?)\]\s*$")
    if ($inline.Success) {
        $value = $inline.Groups[1].Value.Trim()
        if ([string]::IsNullOrWhiteSpace($value)) { return @() }
        return @($value -split ',' | ForEach-Object { $_.Trim().Trim('"').Trim("'") } | Where-Object { $_ })
    }

    $block = Get-BlockText $Yaml $Name
    if ([string]::IsNullOrWhiteSpace($block)) { return @() }
    return @([regex]::Matches($block, '(?m)^\s*-\s+(.+?)\s*$') | ForEach-Object { $_.Groups[1].Value.Trim().Trim('"').Trim("'") })
}

function Test-SourceId {
    param([string]$SourceId)

    if ($SourceId -match '^(\d+)\.(\d+)-(\d+)\.(\d+)$') {
        if ($matches[1] -ne $matches[3]) { return $false }
        $section = [int]$matches[1]
        $start = [int]$matches[2]
        $end = [int]$matches[4]
        if ($start -gt $end) { return $false }
        for ($i = $start; $i -le $end; $i++) {
            if (-not $ValidSourceIds.ContainsKey("$section.$i")) { return $false }
        }
        return $true
    }

    return $ValidSourceIds.ContainsKey($SourceId)
}

function Get-MatrixRows {
    param([string]$Yaml)

    $block = Get-BlockText $Yaml 'categoryDecisionMatrix'
    $rows = New-Object System.Collections.Generic.List[hashtable]
    if ([string]::IsNullOrWhiteSpace($block)) { return $rows }

    $current = $null
    foreach ($line in ($block -split "`r?`n")) {
        if ($line -match '^\s*-\s+category:\s*(.+?)\s*$') {
            if ($null -ne $current) { $rows.Add($current) | Out-Null }
            $current = @{ category = $matches[1].Trim().Trim('"').Trim("'") }
            continue
        }

        if ($null -eq $current) { continue }
        if ($line -match '^\s+(decision|severity|rationale):\s*(.+?)\s*$') {
            $current[$matches[1]] = $matches[2].Trim().Trim('"').Trim("'")
            continue
        }
        if ($line -match '^\s+(evidenceRefs|guidelineIds|sourceIds):\s*\[(.*?)\]\s*$') {
            $items = @()
            if (-not [string]::IsNullOrWhiteSpace($matches[2])) {
                $items = @($matches[2] -split ',' | ForEach-Object { $_.Trim().Trim('"').Trim("'") } | Where-Object { $_ })
            }
            $current[$matches[1]] = $items
            continue
        }
        if ($line -match '^\s+(evidenceRefs|guidelineIds|sourceIds):\s*$') {
            $current[$matches[1]] = @()
            continue
        }
        if ($line -match '^\s+-\s+(.+?)\s*$') {
            foreach ($key in @('evidenceRefs', 'guidelineIds', 'sourceIds')) {
                if ($current.ContainsKey($key) -and $current[$key].Count -eq 0) {
                    $current[$key] = @($current[$key] + $matches[1].Trim().Trim('"').Trim("'"))
                    break
                }
            }
        }
    }
    if ($null -ne $current) { $rows.Add($current) | Out-Null }
    Write-Output -NoEnumerate $rows.ToArray()
}

function Test-NonEmptyText {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value -match '^<.*>$') { return $false }
    return $true
}

if (-not (Test-Path -LiteralPath $Path)) {
    Add-ValidationError "Artifact not found: $Path"
} else {
    $content = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $Path))
    $fence = [regex]::Match($content, '(?s)```yaml\s*(.*?)\s*```')
    if (-not $fence.Success) {
        Add-ValidationError 'No fenced yaml block found.'
    } else {
        $yaml = $fence.Groups[1].Value

        $schemaName = Get-ScalarValue $yaml 'schemaName'
        $schemaVersion = Get-ScalarValue $yaml 'schemaVersion'
        $changeName = Get-ScalarValue $yaml 'changeName'
        $classification = Get-ScalarValue $yaml 'classification'
        $securityImpact = Get-ScalarValue $yaml 'securityImpact'
        $nextRecommended = Get-ScalarValue $yaml 'nextRecommended'

        if ($schemaName -ne 'gentle-ai.sdd-security-applicability') { Add-ValidationError 'schemaName must be gentle-ai.sdd-security-applicability.' }
        if ($schemaVersion -ne '1') { Add-ValidationError 'schemaVersion must be 1.' }
        if (-not (Test-NonEmptyText $changeName)) { Add-ValidationError 'changeName is required.' }
        if (@('security-impacting', 'no-impact') -notcontains $classification) { Add-ValidationError 'classification must be security-impacting or no-impact.' }
        if (@('true', 'false') -notcontains $securityImpact) { Add-ValidationError 'securityImpact must be true or false.' }
        if ($classification -eq 'security-impacting' -and $securityImpact -ne 'true') { Add-ValidationError 'security-impacting classification must set securityImpact: true.' }
        if ($classification -eq 'no-impact' -and $securityImpact -ne 'false') { Add-ValidationError 'no-impact classification must set securityImpact: false.' }
        if ($nextRecommended -and $nextRecommended -ne 'design') { Add-ValidationError 'nextRecommended must remain design for the applicability artifact.' }

        $catalogBlock = Get-BlockText $yaml 'catalog'
        if ($catalogBlock -notmatch "(?m)^\s+snapshotId:\s*$([regex]::Escape($ExpectedSnapshotId))\s*$") { Add-ValidationError "catalog.snapshotId must be $ExpectedSnapshotId." }
        if ($catalogBlock -notmatch "(?m)^\s+taxonomyVersion:\s*$ExpectedTaxonomyVersion\s*$") { Add-ValidationError "catalog.taxonomyVersion must be $ExpectedTaxonomyVersion." }

        $applicableGuidelines = Get-ListValues $yaml 'applicableGuidelines'
        foreach ($guidelineId in $applicableGuidelines) {
            if (-not $Guidelines.ContainsKey($guidelineId)) { Add-ValidationError "Unknown applicable guideline: $guidelineId" }
        }
        if ($classification -eq 'security-impacting' -and $applicableGuidelines.Count -eq 0) {
            Add-ValidationError 'security-impacting artifacts must include at least one applicable guideline.'
        }
        if ($classification -eq 'no-impact' -and $applicableGuidelines.Count -gt 0) {
            Add-ValidationError 'no-impact artifacts must not list applicableGuidelines.'
        }

        $rows = Get-MatrixRows $yaml
        if ($rows.Count -ne $SupportedCategories.Count) {
            Add-ValidationError "categoryDecisionMatrix must contain exactly $($SupportedCategories.Count) rows. Found $($rows.Count)."
        }

        $seenCategories = @{}
        foreach ($row in $rows) {
            $category = $row['category']
            if ($SupportedCategories -notcontains $category) { Add-ValidationError "Unsupported matrix category: $category" }
            if ($seenCategories.ContainsKey($category)) { Add-ValidationError "Duplicate matrix category: $category" } else { $seenCategories[$category] = $true }

            if ($AllowedDecisions -notcontains $row['decision']) { Add-ValidationError "Invalid decision for ${category}: $($row['decision'])" }
            if ($AllowedSeverity -notcontains $row['severity']) { Add-ValidationError "Invalid severity for ${category}: $($row['severity'])" }
            if (-not (Test-NonEmptyText $row['rationale'])) { Add-ValidationError "Missing rationale for $category." }
            foreach ($key in @('evidenceRefs', 'guidelineIds', 'sourceIds')) {
                if (-not $row.ContainsKey($key)) { Add-ValidationError "Missing $key for $category." }
            }
            if ($row['decision'] -eq 'unknown' -and $row['severity'] -eq 'blocking') {
                Add-ValidationError "Blocking unknown decision for $category must prevent success and name missing evidence."
            }

            foreach ($guidelineId in @($row['guidelineIds'])) {
                if (-not $Guidelines.ContainsKey($guidelineId)) {
                    Add-ValidationError "Unknown guidelineId in $category row: $guidelineId"
                } elseif ($Guidelines[$guidelineId].Category -ne $category) {
                    Add-ValidationError "Guideline $guidelineId belongs to $($Guidelines[$guidelineId].Category), not $category."
                }
            }
            foreach ($sourceId in @($row['sourceIds'])) {
                if (-not (Test-SourceId $sourceId)) { Add-ValidationError "Unknown or invalid Source ID in $category row: $sourceId" }
            }
            if ($row['decision'] -eq 'applicable' -and (@($row['guidelineIds']).Count -eq 0 -or @($row['sourceIds']).Count -eq 0)) {
                Add-ValidationError "Applicable category $category must include guidelineIds and sourceIds."
            }
        }
        foreach ($category in $SupportedCategories) {
            if (-not $seenCategories.ContainsKey($category)) { Add-ValidationError "Missing matrix category: $category" }
        }

        $noImpactBlock = Get-BlockText $yaml 'noImpactProof'
        $noImpactStatus = $null
        if ($noImpactBlock -match '(?m)^\s+status:\s*(.+?)\s*$') { $noImpactStatus = $matches[1].Trim().Trim('"').Trim("'") }
        if ($classification -eq 'no-impact') {
            if ($noImpactStatus -ne 'complete') { Add-ValidationError 'no-impact artifacts must set noImpactProof.status: complete.' }
            foreach ($row in $rows) {
                if ($row['decision'] -ne 'not-applicable') { Add-ValidationError "No-impact row $($row['category']) must be not-applicable." }
                if (@($row['evidenceRefs']).Count -eq 0) { Add-ValidationError "No-impact row $($row['category']) must include evidenceRefs." }
            }
            $unknowns = Get-ListValues $yaml 'designChangingUnknowns'
            if ($unknowns.Count -gt 0) { Add-ValidationError 'no-impact artifacts must not contain designChangingUnknowns.' }
        }

        $overrideBlock = Get-BlockText $yaml 'overridesApplied'
        if (-not [string]::IsNullOrWhiteSpace($overrideBlock)) {
            foreach ($entry in [regex]::Matches($overrideBlock, '(?ms)^\s*-\s+source:.*?(?=^\s*-\s+source:|\z)')) {
                $text = $entry.Value
                $key = $null
                $safety = $null
                if ($text -match '(?m)^\s+key:\s*(.+?)\s*$') { $key = $matches[1].Trim().Trim('"').Trim("'") }
                if ($text -match '(?m)^\s+safety:\s*(.+?)\s*$') { $safety = $matches[1].Trim().Trim('"').Trim("'") }
                if ($key -and $AllowedOverrideKeys -notcontains $key) { Add-ValidationError "Unsupported override key: $key" }
                if ($safety -and $AllowedOverrideSafety -notcontains $safety) { Add-ValidationError "Unsupported override safety: $safety" }
                if ($safety -eq 'accepted-stricter' -and $text -match '(?i)disable|weaken|downgrade|bypass|remove|required category') {
                    Add-ValidationError 'Unsafe weakening override cannot be accepted as stricter.'
                }
            }
        }

        $validationBlock = Get-BlockText $yaml 'validation'
        $validator = $null
        $status = $null
        $checkedAt = $null
        if ($validationBlock -match '(?m)^\s+validator:\s*(.+?)\s*$') { $validator = $matches[1].Trim().Trim('"').Trim("'") }
        if ($validationBlock -match '(?m)^\s+status:\s*(.+?)\s*$') { $status = $matches[1].Trim().Trim('"').Trim("'") }
        if ($validationBlock -match '(?m)^\s+checkedAt:\s*(.+?)\s*$') { $checkedAt = $matches[1].Trim().Trim('"').Trim("'") }
        if ($validator -ne $ExpectedValidator) { Add-ValidationError "validation.validator must be $ExpectedValidator." }
        if ($AllowedValidationStatuses -notcontains $status) { Add-ValidationError 'validation.status must be pass, fail, or manual-pending.' }
        if ($status -eq 'fail') { Add-ValidationError 'validation.status reports fail.' }
        if ($status -eq 'manual-pending' -and -not $AllowManualPending) { Add-ValidationError 'validation.status manual-pending requires -AllowManualPending.' }
        if (-not (Test-NonEmptyText $checkedAt)) { Add-ValidationError 'validation.checkedAt is required.' }
    }
}

if ($Errors.Count -gt 0) {
    foreach ($errorItem in $Errors) { Write-Error -Message $errorItem -ErrorAction Continue }
    exit 1
}

Write-Host "PASS: security applicability artifact is valid: $Path"
exit 0
