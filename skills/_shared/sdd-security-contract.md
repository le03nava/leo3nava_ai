# SDD Security Contract

Shared schema and vocabulary for mandatory `design.md#secure-development-design`, `review-security-report.md`, downstream evidence, archive checks, approved exceptions, lifecycle/status vocabulary, and safe-evidence rules.

## Shared Vocabulary

| Field | Allowed values |
| --- | --- |
| `classification` | `security-impacting`, `no-impact` |
| `securityImpact` | `true`, `false` |
| `catalog.snapshotId` | Stable catalog snapshot identifier from `skills/_shared/security-guideline-catalog.md` |
| `catalog.taxonomyVersion` | Supported taxonomy version from the catalog |
| `taxonomyCategory` | `authentication`, `sessions`, `sensitive-data-pan`, `secrets`, `permissions-access-control`, `files`, `database-access`, `sensitive-logging` |
| `matrixAnswer` / `applies` | `Yes`, `No`, `N/A` |
| `taxonomyEvaluation[].decision` | `applicable`, `not-applicable`, `unknown` |
| `operationalSeverity` | `blocking`, `conditional`, `advisory` |
| `evidenceStatus` | `not-started`, `planned`, `implemented`, `verified`, `not-applicable`, `exception-approved`, `blocked` |
| `ownerPhase` | `design`, `test-design`, `tasks`, `apply`, `review`, `review-security`, `verify`, `archive` |
| `mandatoryWhenApplicable` | `true`, `false` |
| `validation.status` | `pass`, `fail`, `manual-pending` |

Operational severity is not review severity. Security artifacts MUST use only `blocking`, `conditional`, and `advisory`; labels such as `Menor`, `Media`, or `Mayor` are review findings and MUST NOT control security routing.

Evidence fields MUST be review-safe. Use artifact paths, section anchors, changed-file references, command summaries, sanitized examples, or redacted placeholders. Do not copy raw secrets, credentials, PAN, PII, connection strings, private keys, tokens, or unnecessary confidential data into SDD artifacts, review reports, verify reports, or archive reports.

## `design.md#secure-development-design` Schema

The `## Secure Development Design` section is mandatory inside `design.md` for every new change and is the active security design authority. It owns classification, catalog identity, every guideline matrix row, controls, expected evidence, lifecycle status, N/A rationale, exceptions, validation metadata or manual/static validation notes, and archive gates. No-impact changes still record justified `N/A` / `not-applicable` rows.

```yaml
schemaName: gentle-ai.sdd-embedded-secure-design
schemaVersion: 1
changeName: <change-name>
classification: security-impacting | no-impact
securityImpact: true | false
securityImpactRationale: <why this classification was chosen>
sourceInputs:
  proposal: <path-or-topic-key>
  specs: []
  design: <path-or-topic-key>#secure-development-design
catalog:
  snapshotId: security-guidelines-initial-user-snapshot-2026-06-30
  catalogVersion: 1
  taxonomyVersion: 1
  source: skills/_shared/security-guideline-catalog.md
taxonomyEvaluation:
  - category: <taxonomyCategory>
    guidelineId: SEC-...
    applies: Yes | No | N/A
    decision: applicable | not-applicable | unknown
    lifecycleStatus: not-started | planned | implemented | verified | not-applicable | exception-approved | blocked
    rationale: <why this guideline applies or is out of scope>
    evidenceRefs: []
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
notApplicableGuidelines:
  - guidelineId: SEC-...
    taxonomyCategory: <taxonomyCategory>
    applies: N/A
    lifecycleStatus: not-applicable
    rationale: <positive out-of-scope rationale>
exceptions: null
carriedRisks: []
validation:
  method: design.md#secure-development-design static/manual review
  status: pass | fail | manual-pending
  checkedAt: <iso-8601-or-manual>
  notes: <static validation notes, unavailable-tooling note, or failure summary>
archiveGateNotes: []
nextRecommended: test-design
```

Rules:

- Every compact catalog guideline ID MUST appear exactly once in the matrix/evaluation, either as applicable (`Yes`) or with explicit `N/A` rationale and evidence. `No` is reserved for security review/reporting when required evidence is missing or failing.
- Embedded secure development design for new changes MUST preserve catalog identity, source refs, matrix evidence, operational severity, and validation/manual-review metadata.
- `blocking` and true `conditional` obligations MUST become controls, downstream evidence expectations, risks, or complete approved exceptions.
- `advisory` obligations SHOULD remain downstream-visible as risk or guidance and archive-readable even when they do not block.
- Mandatory controls MUST include expected evidence owned by `test-design`, `apply`, `review-security`, `verify`, or `archive`.
- N/A rows MUST include rationale and evidence proving why the category, platform, API, data class, or workflow is out of scope. Absence of runtime behavior is not enough unless tied to evidence.
- Applicable safe-evidence controls for `SEC-DATA-001`, `SEC-SECRET-001`, `SEC-ACCESS-001`, and `SEC-LOG-001` MUST avoid raw sensitive values and cite paths, sections, summaries, or redacted placeholders.
- Carried risks MUST be resolved or carried forward with an owner phase and evidence expectation.

## `review-security-report.md` Contract

`sdd-review-security` MUST validate `design.md#secure-development-design` after non-blocking general review and persist `review-security-report.md` before verify.

Required report content:

- Verdict: blocking or non-blocking.
- Source refs: `design.md#secure-development-design`, `review-report.md`, changed-file/task/apply evidence.
- One validation row per compact guideline ID with answer `Yes`, `No`, or `N/A`, lifecycle status, evidence location, observations, and exception reference when applicable.
- Blocking findings for applicable mandatory rows with missing evidence or incomplete exceptions.
- Review-safe evidence only: paths, section refs, sanitized command summaries, and redacted placeholders.
- `nextRecommended: verify` for non-blocking reports, or `apply` / `resolve-blockers` for blockers.

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

## Safe-Evidence Rules for Mandatory Security Controls

- `SEC-DATA-001`: Evidence MUST minimize sensitive context. Cite artifact paths, section refs, data-flow summaries, masking/encryption decisions, or redacted examples instead of PAN, PII, credentials, or confidential values.
- `SEC-SECRET-001`: Evidence MUST NOT commit, echo, log, or reproduce secret values. Cite secret/config names, storage locations, owner notes, or redacted placeholders only.
- `SEC-ACCESS-001`: Evidence MUST prove denial-by-default workflow gates and blocker routing using artifact refs and status/routing examples, not hidden policy data.
- `SEC-LOG-001`: Review, verify, and archive evidence MUST remain useful audit records without raw secrets, PAN, credentials, tokens, or unnecessary sensitive operational context.
