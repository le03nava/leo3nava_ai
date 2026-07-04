<#
.SYNOPSIS
Validates a mandatory SDD security-design.md artifact with static Markdown/YAML checks.

.DESCRIPTION
This validator intentionally avoids runtime security scanning. It checks only the
Markdown YAML fence contract, mandatory security-design schema identity, catalog
snapshot, compact guideline IDs, taxonomy categories, matrix vocabulary,
lifecycle/evidence statuses, exception completeness, archive gate notes, and
new-change routing metadata required by the SDD security design workflow.
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
$ExpectedValidator = 'scripts/validate_security_design.ps1'

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

$AllowedAppliesValues = @('Yes', 'No', 'N/A')
$AllowedDecisions = @('applicable', 'not-applicable', 'unknown')
$AllowedSeverity = @('blocking', 'conditional', 'advisory')
$AllowedLifecycleStatuses = @('not-started', 'planned', 'implemented', 'verified', 'not-applicable', 'exception-approved', 'blocked')
$AllowedValidationStatuses = @('pass', 'fail', 'manual-pending')
$AllowedOwnerPhases = @('design', 'security-design', 'test-design', 'tasks', 'apply', 'review', 'review-security', 'verify', 'archive')
$AllowedEvidenceTypes = @('design-control', 'implementation-reference', 'test-design-check', 'verification-evidence', 'approved-exception')

$Guidelines = @{
    'SEC-AUTH-001'   = @{ Category = 'authentication' }
    'SEC-SESS-001'   = @{ Category = 'sessions' }
    'SEC-DATA-001'   = @{ Category = 'sensitive-data-pan' }
    'SEC-SECRET-001' = @{ Category = 'secrets' }
    'SEC-ACCESS-001' = @{ Category = 'permissions-access-control' }
    'SEC-FILE-001'   = @{ Category = 'files' }
    'SEC-DB-001'     = @{ Category = 'database-access' }
    'SEC-LOG-001'    = @{ Category = 'sensitive-logging' }
}

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

function Test-NonEmptyText {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value -match '^<.*>$') { return $false }
    return $true
}

function Get-ScalarMatches {
    param(
        [string]$Yaml,
        [string]$Name
    )

    return @([regex]::Matches($Yaml, "(?m)^\s*$([regex]::Escape($Name)):\s*(.+?)\s*$") | ForEach-Object { $_.Groups[1].Value.Trim().Trim('"').Trim("'") })
}

function Get-ObjectBlocksWithKey {
    param(
        [string]$Yaml,
        [string]$Key
    )

    return @([regex]::Matches($Yaml, "(?ms)^\s*-\s+$([regex]::Escape($Key)):\s*.*?(?=^\s*-\s+\w+:|^\S[^:]*:\s*|\z)") | ForEach-Object { $_.Value })
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

        if ($schemaName -ne 'gentle-ai.sdd-security-design') { Add-ValidationError 'schemaName must be gentle-ai.sdd-security-design.' }
        if ($schemaVersion -ne '1') { Add-ValidationError 'schemaVersion must be 1.' }
        if (-not (Test-NonEmptyText $changeName)) { Add-ValidationError 'changeName is required.' }
        if (@('security-impacting', 'no-impact') -notcontains $classification) { Add-ValidationError 'classification must be security-impacting or no-impact.' }
        if (@('true', 'false') -notcontains $securityImpact) { Add-ValidationError 'securityImpact must be true or false.' }
        if ($classification -eq 'security-impacting' -and $securityImpact -ne 'true') { Add-ValidationError 'security-impacting classification must set securityImpact: true.' }
        if ($classification -eq 'no-impact' -and $securityImpact -ne 'false') { Add-ValidationError 'no-impact classification must set securityImpact: false.' }
        if ($nextRecommended -ne 'test-design') { Add-ValidationError 'nextRecommended must be test-design for the mandatory security design artifact.' }

        $catalogBlock = Get-BlockText $yaml 'catalog'
        if ($catalogBlock -notmatch "(?m)^\s+snapshotId:\s*$([regex]::Escape($ExpectedSnapshotId))\s*$") { Add-ValidationError "catalog.snapshotId must be $ExpectedSnapshotId." }
        if ($catalogBlock -notmatch "(?m)^\s+taxonomyVersion:\s*$ExpectedTaxonomyVersion\s*$") { Add-ValidationError "catalog.taxonomyVersion must be $ExpectedTaxonomyVersion." }

        foreach ($guidelineId in $Guidelines.Keys) {
            $count = [regex]::Matches($yaml, [regex]::Escape($guidelineId)).Count
            if ($count -eq 0) { Add-ValidationError "Missing compact guideline ID: $guidelineId" }
        }

        foreach ($guidelineMatch in [regex]::Matches($yaml, '\bSEC-[A-Z]+-\d{3}\b')) {
            $guidelineId = $guidelineMatch.Value
            if (-not $Guidelines.ContainsKey($guidelineId)) { Add-ValidationError "Unknown compact guideline ID: $guidelineId" }
        }

        foreach ($category in $SupportedCategories) {
            if ($yaml -notmatch "\b$([regex]::Escape($category))\b") { Add-ValidationError "Missing taxonomy category: $category" }
        }

        foreach ($categoryMatch in [regex]::Matches($yaml, '(?m)^\s+(category|taxonomyCategory):\s*(.+?)\s*$')) {
            $category = $categoryMatch.Groups[2].Value.Trim().Trim('"').Trim("'")
            if ($SupportedCategories -notcontains $category) { Add-ValidationError "Unsupported taxonomy category: $category" }
        }

        foreach ($applies in Get-ScalarMatches $yaml 'applies') {
            if ($AllowedAppliesValues -notcontains $applies) { Add-ValidationError "Invalid applies value: $applies" }
        }

        foreach ($decision in Get-ScalarMatches $yaml 'decision') {
            if ($AllowedDecisions -notcontains $decision) { Add-ValidationError "Invalid decision value: $decision" }
        }

        foreach ($severity in Get-ScalarMatches $yaml 'operationalSeverity') {
            if ($AllowedSeverity -notcontains $severity) { Add-ValidationError "Invalid operationalSeverity value: $severity" }
        }

        foreach ($status in Get-ScalarMatches $yaml 'lifecycleStatus') {
            if ($AllowedLifecycleStatuses -notcontains $status) { Add-ValidationError "Invalid lifecycleStatus value: $status" }
        }

        foreach ($statusMatch in [regex]::Matches($yaml, '(?m)^\s+status:\s*(.+?)\s*$')) {
            $status = $statusMatch.Groups[1].Value.Trim().Trim('"').Trim("'")
            if (($AllowedLifecycleStatuses + $AllowedValidationStatuses) -notcontains $status) { Add-ValidationError "Invalid status value: $status" }
            if ($status -eq 'fail') { Add-ValidationError 'validation.status reports fail.' }
            if ($status -eq 'manual-pending' -and -not $AllowManualPending) { Add-ValidationError 'validation.status manual-pending requires -AllowManualPending.' }
        }

        foreach ($ownerPhase in Get-ScalarMatches $yaml 'ownerPhase') {
            if ($AllowedOwnerPhases -notcontains $ownerPhase) { Add-ValidationError "Invalid ownerPhase value: $ownerPhase" }
        }

        foreach ($evidenceType in Get-ScalarMatches $yaml 'type') {
            if ($AllowedEvidenceTypes -notcontains $evidenceType) { Add-ValidationError "Invalid expectedEvidence type: $evidenceType" }
        }

        foreach ($unexpectedAnswer in [regex]::Matches($yaml, '(?m)^\s+(?!applies:|complies:|defaultComplies:|matrixAnswer:)[A-Za-z][A-Za-z0-9_-]*:\s*(Yes|No|N/A)\s*$')) {
            Add-ValidationError "Yes/No/N/A values are only allowed for applies/Complies-style answer fields: $($unexpectedAnswer.Value.Trim())"
        }

        $evaluationBlocks = Get-ObjectBlocksWithKey $yaml 'category'
        foreach ($block in $evaluationBlocks) {
            if ($block -match '(?m)^\s+guidelineId:\s*(SEC-[A-Z]+-\d{3})\s*$') {
                $guidelineId = $matches[1]
                if ($Guidelines.ContainsKey($guidelineId) -and $block -match '(?m)^\s+category:\s*(.+?)\s*$') {
                    $category = $matches[1].Trim().Trim('"').Trim("'")
                    if ($category -ne $Guidelines[$guidelineId].Category) { Add-ValidationError "Guideline $guidelineId belongs to $($Guidelines[$guidelineId].Category), not $category." }
                }
                if ($block -notmatch '(?m)^\s+rationale:\s*\S+') { Add-ValidationError "Missing rationale for $guidelineId." }
                if ($block -notmatch '(?m)^\s+evidenceRefs:\s*$' -and $block -notmatch '(?m)^\s+evidenceRefs:\s*\[') { Add-ValidationError "Missing evidenceRefs for $guidelineId." }
            }
        }

        $controlBlocks = Get-ObjectBlocksWithKey $yaml 'guidelineId'
        foreach ($block in $controlBlocks) {
            if ($block -match '(?m)^\s*-\s+guidelineId:\s*(SEC-[A-Z]+-\d{3})\s*$' -or $block -match '(?m)^\s+guidelineId:\s*(SEC-[A-Z]+-\d{3})\s*$') {
                $guidelineId = $matches[1]
                if ($block -match '(?m)^\s+applies:\s*(Yes|No)\s*$') {
                    foreach ($required in @('requiredControl', 'expectedEvidence')) {
                        $requiredPattern = "(?m)^\s+$([regex]::Escape($required)):\s*"
                        if ($block -notmatch $requiredPattern) { Add-ValidationError "Control $guidelineId is missing $required." }
                    }
                }
            }
        }

        $notApplicableBlock = Get-BlockText $yaml 'notApplicableGuidelines'
        foreach ($guidelineId in @('SEC-AUTH-001', 'SEC-SESS-001', 'SEC-FILE-001', 'SEC-DB-001')) {
            if ($notApplicableBlock -notmatch [regex]::Escape($guidelineId)) { Add-ValidationError "Missing N/A guideline record: $guidelineId" }
        }
        foreach ($naBlock in Get-ObjectBlocksWithKey $notApplicableBlock 'guidelineId') {
            if ($naBlock -notmatch '(?m)^\s+applies:\s*N/A\s*$') { Add-ValidationError 'N/A guideline records must set applies: N/A.' }
            if ($naBlock -notmatch '(?m)^\s+lifecycleStatus:\s*not-applicable\s*$') { Add-ValidationError 'N/A guideline records must set lifecycleStatus: not-applicable.' }
            if ($naBlock -notmatch '(?m)^\s+rationale:\s*\S+') { Add-ValidationError 'N/A guideline records must include rationale.' }
        }

        if ($yaml -match '(?m)^\s+(status|lifecycleStatus):\s*exception-approved\s*$') {
            foreach ($required in @('status', 'guidelineId', 'approver', 'approvedAt', 'acceptedRiskRationale', 'mitigationOrFollowUp', 'evidenceGap')) {
                $requiredPattern = "(?m)^\s+$([regex]::Escape($required)):\s*\S+"
                if ($yaml -notmatch $requiredPattern) { Add-ValidationError "exception-approved records must include $required." }
            }
        }

        $validationBlock = Get-BlockText $yaml 'validation'
        $validator = $null
        $checkedAt = $null
        if ($validationBlock -match '(?m)^\s+validator:\s*(.+?)\s*$') { $validator = $matches[1].Trim().Trim('"').Trim("'") }
        if ($validationBlock -match '(?m)^\s+checkedAt:\s*(.+?)\s*$') { $checkedAt = $matches[1].Trim().Trim('"').Trim("'") }
        if ($validator -ne $ExpectedValidator) { Add-ValidationError "validation.validator must be $ExpectedValidator." }
        if (-not (Test-NonEmptyText $checkedAt)) { Add-ValidationError 'validation.checkedAt is required.' }

        $archiveGateNotes = Get-BlockText $yaml 'archiveGateNotes'
        if ([string]::IsNullOrWhiteSpace($archiveGateNotes)) { Add-ValidationError 'archiveGateNotes are required.' }
        if ($archiveGateNotes -notmatch '(?m)^\s*-\s+\S+') { Add-ValidationError 'archiveGateNotes must contain at least one note.' }
    }
}

if ($Errors.Count -gt 0) {
    foreach ($errorItem in $Errors) { Write-Error -Message $errorItem -ErrorAction Continue }
    exit 1
}

Write-Host "PASS: security design artifact is valid: $Path"
exit 0
