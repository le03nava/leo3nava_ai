# SDD Security Contract

Shared schema and vocabulary for mandatory `design.md#secure-development-design`, `test-design.md`, `review-security-report.md`, downstream evidence, archive checks, approved exceptions, lifecycle/status vocabulary, and safe-evidence rules.

## Artifact Ownership Boundary

This contract keeps secure-design artifacts slim while preserving full corporate Source ID auditability.

| Artifact / phase | Owns | Must not own |
| --- | --- | --- |
| `skills/_shared/security-guideline-catalog.md` | Authoritative corporate Source ID inventory, snapshot metadata, expanded Source ID ranges, compact `SEC-*` mappings, expected count, and shared evidence vocabulary. | Per-change evidence verdicts or phase routing decisions. |
| `design.md#secure-development-design` | Security classification, compact eight-control `SEC-*` decisions, catalog snapshot/path, `expectedSourceIdCount`, grouped source-row coverage, lifecycle status, evidence owners, safe-evidence policy, N/A policy, exception policy, and downstream traceability. | The full 155-row Source ID matrix or the general 96-control review matrix. |
| `test-design.md` | Static/manual/automated check plan derived from slim design coverage, including grouped coverage checks, unavailable tooling substitution, N/A evidence expectations, and warning preservation expectations. | Exhaustive Source ID verdict rows. |
| `apply` evidence | Changed-file references and static/manual proof that implemented contracts preserve catalog authority, slim design references, blocker routing, safe evidence, N/A, warning, and exception semantics. | Review-security verdicts or exhaustive Source ID materialization. |
| `review-security-report.md` | The only active new-change artifact that materializes the exhaustive Source ID matrix and validates every expected Source ID exactly once. | Re-defining compact taxonomy authority or duplicating the general 96-control review matrix. |
| `verify` / `archive` | Consumption and preservation of non-blocking security review verdicts, catalog identity, expected count, compact mappings, warnings, exceptions, evidence refs, and report links. | Re-validating, redefining, or copying the full Source ID matrix when `review-security-report.md` already owns it. |

Boundary rules:

- New changes MUST use the catalog as the source of truth for the 155 concrete Source IDs and compact mappings.
- Slim artifacts MAY cite grouped ranges and counts, but MUST NOT copy the exhaustive Source ID inventory when the catalog is available.
- `review-security-report.md` is the exclusive active owner of exhaustive exact-once Source ID expansion and row-level verdicts.
- Missing, duplicate, unknown, malformed, unmapped, unsafe, or unsupported `N/A` source-row evidence MUST route according to the source-row routing table in this contract.
- Warning-only evidence MAY route forward only when mandatory evidence is complete and warnings remain visible to verify/archive.

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
| `sourceRows[].sourceId` | Stable dotted numeric ID from `skills/_shared/security-guideline-catalog.md#full-corporate-guideline-snapshot`, for example `1.1` |
| `sourceRows[].mappedCompactGuidelineIds[]` | Existing compact `SEC-*` IDs only |
| `sourceRows[].complies` | `planned`, `Yes`, `No`, `N/A` |
| `sourceRows[].lifecycleStatus` | `not-started`, `planned`, `implemented`, `verified`, `not-applicable`, `exception-approved`, `blocked` |
| `sourceRows[].finding` | `none`, `blocker`, `warning` |
| `sourceRows[].route` | `test-design`, `apply`, `resolve-blockers`, `verify`, `archive` |

Operational severity is not review severity. Security artifacts MUST use only `blocking`, `conditional`, and `advisory`; labels such as `Menor`, `Media`, or `Mayor` are review findings and MUST NOT control security routing.

Evidence fields MUST be review-safe. Use artifact paths, section anchors, changed-file references, command summaries, sanitized examples, or redacted placeholders. Do not copy raw secrets, credentials, PAN, PII, connection strings, private keys, tokens, or unnecessary confidential data into SDD artifacts, review reports, verify reports, or archive reports.

## `design.md#secure-development-design` Schema

The `## Secure Development Design` section is mandatory inside `design.md` for every new change and is the active security design authority. It owns classification, catalog identity, the compact eight-control guideline matrix, controls, expected evidence, lifecycle status, N/A rationale, exceptions, validation metadata or manual/static validation notes, grouped source-row coverage by reference, and archive gates. No-impact changes still record justified `N/A` / `not-applicable` rows. It MUST NOT materialize the exhaustive 155-row Source ID matrix when the shared catalog is available.

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
sourceRowCoverage:
  inventoryAuthority: skills/_shared/security-guideline-catalog.md#corporate-source-row-operational-inventory
  expectedSourceIdCount: 155
  coverageRule: Review-security expands every catalog Source ID exactly once.
  validCompactGuidelineIds: []
  groups: []
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
- Source-row coverage in design MUST include catalog authority, expected count, grouped coverage references, compact mappings, owner phases, lifecycle state, exact-once downstream rule, safe-evidence policy, N/A policy, and exception policy.
- Design MUST use grouped references for Source IDs when the catalog inventory exists; copying all 155 Source IDs into design is a contract violation.
- `blocking` and true `conditional` obligations MUST become controls, downstream evidence expectations, risks, or complete approved exceptions.
- `advisory` obligations SHOULD remain downstream-visible as risk or guidance and archive-readable even when they do not block.
- Mandatory controls MUST include expected evidence owned by `test-design`, `apply`, `review-security`, `verify`, or `archive`.
- N/A rows MUST include rationale and evidence proving why the category, platform, API, data class, or workflow is out of scope. Absence of runtime behavior is not enough unless tied to evidence.
- Applicable safe-evidence controls for `SEC-DATA-001`, `SEC-SECRET-001`, `SEC-ACCESS-001`, and `SEC-LOG-001` MUST avoid raw sensitive values and cite paths, sections, summaries, or redacted placeholders.
- Carried risks MUST be resolved or carried forward with an owner phase and evidence expectation.

### Source Row Operational Layer

The compact controls above remain the architectural control layer. Source rows are an operational evidence layer derived from `skills/_shared/security-guideline-catalog.md#corporate-source-row-operational-inventory` and MUST NOT create replacement compact guidelines.

`design.md#secure-development-design` MAY summarize source rows by corporate section when the full expanded inventory is already present in the shared catalog, but it MUST preserve the expected Source ID universe, compact mappings, lifecycle status, evidence owners, safe-evidence policy, N/A policy, and downstream traceability.

`test-design.md`, apply evidence, verify reports, and archive reports MUST consume source-row obligations by catalog reference, grouped coverage, evidence owner, and review-security report links. They MUST NOT become additional owners of the full 155-row matrix.

```yaml
sourceRows:
  - sourceId: "1.1"
    corporateSection: "1. Authentication"
    guidelineTextRef: "skills/_shared/security-guideline-catalog.md#source-1.1"
    pciAlignment: "PCI Req 6.5.8, 6.5.10" # or "N/A"
    mappedCompactGuidelineIds: ["SEC-AUTH-001"]
    applies: Yes # Yes | No | N/A
    complies: planned # planned | Yes | No | N/A
    lifecycleStatus: planned
    evidenceLocation: "openspec/changes/<change>/design.md#secure-development-design"
    observations: "Review-safe summary only."
    finding: none # none | blocker | warning
    route: test-design # test-design | apply | resolve-blockers | verify | archive
    naJustification: null
```

Source row rules:

- Every Source ID from the catalog's operational inventory MUST be expanded before validation and represented exactly once in security review matrices.
- `mappedCompactGuidelineIds` MUST contain one or more known compact IDs. Missing, empty, or unknown mappings route to `resolve-blockers`.
- `applies` MUST be `Yes`, `No`, or `N/A`. Design normally uses `Yes` or `N/A`; review-security may use `No` when a row applies but lacks valid evidence.
- `complies` MUST be phase-appropriate: `planned` during design/test-design planning, `Yes` or `No` during review/verify evidence, and `N/A` only with complete irrelevance evidence.
- `N/A` rows MUST include both evidence and `naJustification` proving irrelevance by category, platform, API, data class, or workflow. Unsupported `N/A` routes to `resolve-blockers`.
- Applicable rows MUST cite review-safe evidence when the owning phase has produced evidence. Missing implementation evidence routes to `apply` when remediation is file, prompt, or contract work.
- Evidence and observations MUST NOT include secrets, PII, PAN, tokens, connection strings, private keys, or confidential values.
- Source row traceability MUST remain: Source ID -> mapped compact `SEC-*` -> design control -> test-design check -> apply evidence -> review-security row verdict -> verify prerequisite -> archive audit trail.

## `review-security-report.md` Contract

`sdd-review-security` MUST validate `design.md#secure-development-design` after non-blocking general review and persist `review-security-report.md` before verify.

Required report content:

- Verdict: blocking or non-blocking.
- Source refs: `design.md#secure-development-design`, `review-report.md`, changed-file/task/apply evidence.
- One validation row per compact guideline ID with answer `Yes`, `No`, or `N/A`, lifecycle status, evidence location, observations, and exception reference when applicable.
- One source-row validation row per expanded corporate Source ID when the change requires source-row security review. Rows MUST cite compact mapping, applicability/compliance status, lifecycle status, evidence location, observations, finding, and route.
- Blocking findings for applicable mandatory rows with missing evidence or incomplete exceptions.
- Review-safe evidence only: paths, section refs, sanitized command summaries, and redacted placeholders.
- `nextRecommended: verify` for non-blocking reports, or `apply` / `resolve-blockers` for blockers.

Review-security MUST cite `review-report.md` findings when they support source-row evidence, but it MUST NOT duplicate the general 96-control review matrix. The source-row matrix is security-specific and bounded to the corporate Source ID inventory.

## Source Row Routing and Persistence Semantics

| Condition | Required route |
| --- | --- |
| Missing, duplicate, or unknown Source ID | `resolve-blockers` |
| Malformed source-row schema or unsupported allowed value | `resolve-blockers` |
| Missing or unknown compact `SEC-*` mapping | `resolve-blockers` |
| Unsafe evidence or missing `N/A` evidence/justification | `resolve-blockers` |
| Applicable row lacks implementation evidence and remediation is file, prompt, or contract work | `apply` |
| Mandatory evidence is complete and only warning rows remain | `verify` |
| Verify confirms non-blocking review-security evidence | `archive` |

Persistence mode changes storage, not source-row semantics:

| Mode | Source-row behavior |
| --- | --- |
| OpenSpec | Store rows in established change files and reports; downstream phases read those files. |
| Engram | Store rows under established SDD artifact topic keys from `skills/_shared/persistence-contract.md`. |
| hybrid | Store rows in both OpenSpec and Engram; reconcile material disagreements before continuing. |
| none | Return rows inline only and report recovery limits; do not write files or Engram observations. |

No active source-row validation path requires `scripts/validate_security_design.ps1`; static/manual validation uses catalog, embedded design, test-design, apply evidence, review reports, and persistence-contract read-back evidence.

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
