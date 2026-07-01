# SDD Security Contract

Shared schema and vocabulary for `security-applicability.md`, `security-design.md`, downstream evidence, and archive checks.

## Shared Vocabulary

| Field | Allowed values |
| --- | --- |
| `classification` | `security-impacting`, `no-impact` |
| `securityImpact` | `true`, `false` |
| `taxonomyCategory` | `authentication`, `sessions`, `sensitive-data-pan`, `secrets`, `permissions-access-control`, `files`, `database-access`, `sensitive-logging` |
| `evidenceStatus` | `not-started`, `planned`, `implemented`, `verified`, `not-applicable`, `exception-approved`, `blocked` |
| `ownerPhase` | `security-applicability`, `design`, `security-design`, `test-design`, `tasks`, `apply`, `verify`, `archive` |
| `mandatoryWhenApplicable` | `true`, `false` |

## `security-applicability.md` Schema

The applicability artifact is always required after specs and before technical design.

```yaml
schemaName: gentle-ai.sdd-security-applicability
schemaVersion: 1
changeName: <change-name>
classification: security-impacting | no-impact
securityImpact: true | false
taxonomyCategories: []
applicableGuidelines: []
evidenceSummary:
  - <proposal/spec evidence used for classification>
designChangingUnknowns: []
nonBlockingRisks: []
nextRecommended: design
```

Rules:

- `classification: security-impacting` MUST set `securityImpact: true`, include at least one taxonomy category, and identify guideline IDs from `security-guideline-catalog.md`.
- `classification: no-impact` MUST set `securityImpact: false`, record explicit no-impact evidence, and leave `applicableGuidelines` empty unless a guideline is intentionally marked `not-applicable` with rationale.
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
