# SDD Security Contract

Shared schema and vocabulary for `security-applicability.md`, `security-design.md`, downstream evidence, and archive checks.

## Shared Vocabulary

| Field | Allowed values |
| --- | --- |
| `classification` | `security-impacting`, `no-impact` |
| `securityImpact` | `true`, `false` |
| `catalog.snapshotId` | Stable catalog snapshot identifier from `skills/_shared/security-guideline-catalog.md` |
| `catalog.taxonomyVersion` | Supported taxonomy version from the catalog |
| `taxonomyCategory` | `authentication`, `sessions`, `sensitive-data-pan`, `secrets`, `permissions-access-control`, `files`, `database-access`, `sensitive-logging` |
| `categoryDecisionMatrix[].decision` | `applicable`, `not-applicable`, `unknown` |
| `operationalSeverity` / `categoryDecisionMatrix[].severity` | `blocking`, `conditional`, `advisory` |
| `evidenceStatus` | `not-started`, `planned`, `implemented`, `verified`, `not-applicable`, `exception-approved`, `blocked` |
| `ownerPhase` | `security-applicability`, `design`, `security-design`, `test-design`, `tasks`, `apply`, `verify`, `archive` |
| `mandatoryWhenApplicable` | `true`, `false` |
| `validation.status` | `pass`, `fail`, `manual-pending` |

Operational severity is not review severity. Applicability artifacts MUST use only `blocking`, `conditional`, and `advisory`; labels such as `Menor`, `Media`, or `Mayor` are review findings and MUST NOT control security applicability routing.

## `security-applicability.md` Schema

The applicability artifact is always required after specs and before technical design.

```yaml
schemaName: gentle-ai.sdd-security-applicability
schemaVersion: 1
changeName: <change-name>
classification: security-impacting | no-impact
securityImpact: true | false
catalog:
  snapshotId: <security-guideline-catalog snapshot id>
  taxonomyVersion: 1
  source: skills/_shared/security-guideline-catalog.md
taxonomyCategories: []
applicableGuidelines: []
categoryDecisionMatrix:
  - category: authentication | sessions | sensitive-data-pan | secrets | permissions-access-control | files | database-access | sensitive-logging
    decision: applicable | not-applicable | unknown
    severity: blocking | conditional | advisory
    rationale: <why this category decision was made>
    evidenceRefs: []
    guidelineIds: []
    sourceIds: []
noImpactProof:
  status: not-applicable | complete | incomplete
  summary: <positive no-impact proof, or why no-impact does not apply>
  evidenceRefs: []
overridesApplied:
  - source: openspec/config.yaml rules.security-applicability
    key: extraPrompts | strictSourceCoverage | validatorMode | categorySeverity
    effect: <what was added or made stricter>
    safety: accepted-stricter | rejected-unsafe | ignored-unsafe
validation:
  validator: scripts/validate_security_applicability.ps1
  status: pass | fail | manual-pending
  checkedAt: <iso-8601-or-manual>
  notes: <static validation notes, unavailable-tooling note, or failure summary>
evidenceSummary:
  - <proposal/spec evidence used for classification>
designChangingUnknowns: []
nonBlockingRisks: []
nextRecommended: design
```

Rules:

- `classification: security-impacting` MUST set `securityImpact: true`, include at least one taxonomy category, and identify guideline IDs from `security-guideline-catalog.md`.
- `classification: no-impact` MUST set `securityImpact: false`, record explicit no-impact proof, and leave `applicableGuidelines` empty unless a guideline is intentionally marked `not-applicable` with rationale.
- `catalog` fields are additive and MUST preserve artifact identity: `schemaName`, `schemaVersion: 1`, path/topic key, `classification`, `securityImpact`, existing `SEC-*` IDs, and no-impact routing remain compatible with archived artifacts.
- `categoryDecisionMatrix` MUST contain every supported taxonomy category exactly once. Missing or duplicate category rows make the artifact invalid.
- A `blocking` row with `decision: unknown` is design-changing and MUST block phase success with the missing category evidence named.
- `security-impacting` artifacts SHOULD mark applicable categories as `applicable` and map the matching `guidelineIds` and `sourceIds` when known.
- `no-impact` artifacts MUST mark every category `not-applicable`, provide rationale and evidence refs for each row, set `noImpactProof.status: complete`, have no design-changing unknowns, and pass validation.
- Absence of mapped guidelines, empty evidence, or missing rationale MUST NOT be treated as no-impact proof.
- Supported `rules.security-applicability` overrides are limited to extra prompts, stricter source coverage, validator mode, and stricter category severity. Overrides MUST NOT disable required categories, weaken source coverage, downgrade `blocking`, or bypass no-impact proof.
- Unsafe overrides MUST be rejected or ignored in favor of the stricter base contract and recorded in `overridesApplied`.
- `validation` metadata MUST be recorded before phase success. When executable validation is unavailable, the artifact MUST say so explicitly with `manual-pending` or a failure status; missing runtime tooling is not pass evidence.
- `designChangingUnknowns` blocks applicability only when missing information could change security design decisions.
- `nonBlockingRisks` carries minor evidence gaps into `security-design.md`.

## `security-design.md` Schema

The security design artifact is required only when applicability records `securityImpact: true`.

```yaml
schemaName: gentle-ai.sdd-security-design
schemaVersion: 1
changeName: <change-name>
sourceApplicability: <path-or-topic-key>
controls:
  - guidelineId: SEC-...
    taxonomyCategory: <taxonomyCategory>
    mandatoryWhenApplicable: true
    operationalSeverity: blocking | conditional | advisory
    sourceRefs: []
    requiredControl: <control description>
    expectedEvidence:
      - type: design-control | implementation-reference | test-design-check | verification-evidence | approved-exception
        ownerPhase: <ownerPhase>
        status: <evidenceStatus>
        detail: <expected or observed evidence>
    residualRisk: <none-or-risk>
    exception: null
carriedRisks: []
nextRecommended: test-design
```

Rules:

- Every applicable guideline ID MUST become a control or be explicitly marked `not-applicable` with rationale.
- Security design for impacting changes MUST preserve applicability `catalog` identity, decision-matrix evidence, source refs, operational severity, and validation metadata when available.
- `blocking` and true `conditional` obligations MUST become controls, downstream evidence expectations, risks, or complete approved exceptions.
- `advisory` obligations SHOULD remain downstream-visible as risk or guidance and archive-readable even when they do not block.
- Mandatory controls MUST include expected evidence owned by `test-design`, `apply`, `verify`, or `archive`.
- Applicability `nonBlockingRisks` MUST be resolved or carried forward with an owner phase and evidence expectation.

## Approved Exception Fields

Archive MAY proceed with missing mandatory evidence only when the exception is complete.

```yaml
exception:
  status: exception-approved
  guidelineId: SEC-...
  approver: <human-or-authoritative-role>
  approvedAt: <iso-8601-or-date>
  acceptedRiskRationale: <why risk is accepted>
  mitigationOrFollowUp: <mitigation, issue, expiry, or follow-up plan>
  evidenceGap: <missing mandatory evidence>
```

Incomplete exceptions MUST NOT satisfy archive readiness.

Exception rules:

- Exceptions apply to missing mandatory evidence only after an authoritative approval is recorded.
- Exceptions MUST NOT remove category rows, source refs, validation metadata, or no-impact proof requirements.
- Exceptions for `blocking` or true `conditional` obligations MUST remain visible through verify and archive evidence.

## PR 1 Compatibility Notes

This schema hardening is additive for TD-001 through TD-009 and TD-022. It intentionally defines the shared contract before the catalog metadata and executable validator slices land. Downstream phases MUST preserve existing no-impact routing compatibility: enriched fields do not make `security-design.md` mandatory when `security-applicability.md` records valid explicit no-impact proof and validation metadata.
