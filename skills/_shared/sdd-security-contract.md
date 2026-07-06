# SDD Security Contract

Shared vocabulary and ownership rules for mandatory narrative `design.md#secure-development-design`, `test-design.md`, `review-security-report.md`, downstream evidence, archive checks, approved exceptions, lifecycle/status vocabulary, and safe-evidence rules.

## Artifact Ownership Boundary

This contract keeps design artifacts narrative while preserving full corporate Source ID auditability in security review.

| Artifact / phase | Owns | Must not own |
| --- | --- | --- |
| `skills/_shared/security-guideline-catalog.md` | Authoritative corporate Source ID inventory, snapshot metadata, expanded Source ID ranges, compact `SEC-*` mappings, expected count, lifecycle/status vocabulary, exception fields, and safe-evidence vocabulary. | Per-change applicability verdicts, evidence verdicts, or phase routing decisions. |
| `design.md#secure-development-design` | Human-readable changed-surface classification and narrative development rules for applicable security categories, including evidence owners, residual risks, exceptions, safe-evidence policy, and downstream traceability. | YAML, JSON, schema blocks, control tables, compact matrices, Source ID matrices, machine-readable applicability fields, exhaustive compact-control `N/A` bookkeeping, the full 155-row Source ID matrix, per-source `N/A` decisions, or the general 96-control review matrix. |
| `test-design.md` | Static/manual/automated evidence plan for applicable narrative category rules and changed-surface risks, including unavailable tooling substitution, warning preservation expectations, and exception follow-up checks. | Design schema parsing, exhaustive compact-control `N/A` planning, compact matrices, Source ID matrices, or exhaustive Source ID verdict rows. |
| `apply` evidence | Changed-file references and static/manual proof that implemented contracts preserve catalog authority, selective design references, blocker routing, safe evidence, N/A validation ownership, warning, and exception semantics. | Review-security verdicts or exhaustive Source ID materialization. |
| `review-security-report.md` | Exhaustive compact-control and 155 Source ID applicability validation, exact-once Source ID expansion, `Yes`/`No`/`N/A` decisions, N/A evidence/justification, missed applicable control blockers, unsafe-evidence blockers, and warning-only routing. | Re-defining compact taxonomy authority or duplicating the general 96-control review matrix. |
| `verify` / `archive` | Consumption and preservation of non-blocking security review verdicts, catalog identity, expected count, compact mappings, warnings, exceptions, evidence refs, and report links. | Re-validating, redefining, or copying the full Source ID matrix when `review-security-report.md` already owns it. |

Boundary rules:

- New changes MUST use the catalog as the source of truth for the 155 concrete Source IDs and compact mappings.
- Design and test-design artifacts MAY cite catalog category names and grouped context in prose, but MUST NOT copy the exhaustive Source ID inventory or encode machine-readable applicability fields when the catalog is available.
- `design.md#secure-development-design` MUST NOT pass by omission alone; it records classification and applicable narrative rules, then `review-security-report.md` validates omitted categories and blocks missed applicable controls.
- `review-security-report.md` is the exclusive active owner of exhaustive compact applicability, exact-once Source ID expansion, row-level verdicts, N/A decisions, and missed applicable control blockers.
- Missing, duplicate, unknown, malformed, unmapped, unsafe, unsupported `N/A`, or missed applicable source-row evidence MUST route according to the source-row routing table in this contract.
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
| `sourceRows[].corporateSection` | Corporate section inherited from the source inventory, for example `1. Authentication` |
| `sourceRows[].guidelineTextRef` | Review-safe reference to the catalog snapshot plus Source ID, for example `skills/_shared/security-guideline-catalog.md#full-corporate-guideline-snapshot (Source ID 1.1)` |
| `sourceRows[].pciAlignment` | PCI alignment inherited from the catalog corporate section, or `N/A` when the section has no alignment |
| `sourceRows[].mappedCompactGuidelineIds[]` | Existing compact `SEC-*` IDs only |
| `sourceRows[].applies` | `Yes`, `No`, `N/A` |
| `sourceRows[].complies` | `planned`, `Yes`, `No`, `N/A` |
| `sourceRows[].lifecycleStatus` | `not-started`, `planned`, `implemented`, `verified`, `not-applicable`, `exception-approved`, `blocked` |
| `sourceRows[].evidenceType` | `implementation-reference`, `static-inspection`, `test-evidence`, `approved-exception`, `n/a-evidence` |
| `sourceRows[].finding` | `none`, `blocker`, `warning` |
| `sourceRows[].ownerPhase` | `design`, `test-design`, `tasks`, `apply`, `review`, `review-security`, `verify`, `archive` |
| `sourceRows[].route` | `test-design`, `apply`, `resolve-blockers`, `verify`, `archive` |

Operational severity is not review severity. Security artifacts MUST use only `blocking`, `conditional`, and `advisory`; labels such as `Menor`, `Media`, or `Mayor` are review findings and MUST NOT control security routing.

Evidence fields MUST be review-safe. Use artifact paths, section anchors, changed-file references, command summaries, sanitized examples, or redacted placeholders. Do not copy raw secrets, credentials, PAN, PII, connection strings, private keys, tokens, or unnecessary confidential data into SDD artifacts, review reports, verify reports, or archive reports.

## `design.md#secure-development-design` Narrative Contract

The `## Secure Development Design` section is mandatory inside `design.md` for every new active change and is the active design-time security planning authority. It is a human-readable narrative section, not a machine-readable security artifact. It owns changed-surface classification, applicable category rules, evidence owners, residual risks, exceptions, safe-evidence policy, and downstream traceability.

New active designs MUST NOT contain security YAML, JSON, schema blocks, control tables, compact matrices, Source ID matrices, machine-readable applicability fields, all-row `N/A` bookkeeping, or exhaustive Source ID inventories. No-impact changes record changed-surface rationale in prose instead of an all-row `N/A` matrix.

Recommended narrative shape:

- `### Classification and Changed Surface` — explain whether the change is security-impacting or no-impact, which artifacts/behaviors are touched, which runtime surfaces are not touched, and which catalog context was considered.
- `### <Applicable Category> Rules` — one subsection for each applicable category, such as Authentication, Sessions, Sensitive Data/PAN, Secrets, Permissions/Access Control, Files, Database Access, or Sensitive Logging.
- Each applicable category subsection states development rules, prohibited unsafe patterns, evidence owners, expected evidence in review-safe prose, residual risks, exception handling, and safe-evidence policy.
- Omitted categories are reviewable omissions, not design-time passing rows. `review-security-report.md` validates omissions, reports non-applicable decisions, and blocks missed applicable controls.

Rules:

- New selective designs MUST state applicable category rules only. They MUST NOT require every compact guideline ID exactly once, all Source IDs, or per-row `N/A` evidence for omitted rows. Historical schema-based artifacts with exhaustive rows remain readable compatibility evidence only.
- Embedded secure development design for new changes MUST preserve catalog context, safe-evidence policy, evidence owners, and validation/manual-review notes in prose.
- Source-row coverage in design MAY be described as catalog context for applicable categories, but exact-once expansion, matrix fields, lifecycle/status fields, and `N/A` decisions belong to `review-security-report.md`.
- Design MUST use prose references when the catalog inventory exists; copying all 155 Source IDs into design is a contract violation.
- `blocking` and true `conditional` obligations MUST become narrative rules, downstream evidence expectations, risks, or complete approved exceptions.
- `advisory` obligations SHOULD remain downstream-visible as risk or guidance and archive-readable even when they do not block.
- Mandatory applicable category rules MUST include expected evidence owned by `test-design`, `apply`, `review-security`, `verify`, or `archive`.
- Design omission is not itself a passing `N/A` verdict. `review-security-report.md` MUST validate omitted compact categories and Source IDs, record N/A rationale/evidence where it reports N/A, and block missed applicable controls.
- Applicable safe-evidence controls for `SEC-DATA-001`, `SEC-SECRET-001`, `SEC-ACCESS-001`, and `SEC-LOG-001` MUST avoid raw sensitive values and cite paths, sections, summaries, or redacted placeholders.
- Carried risks MUST be resolved or carried forward with an owner phase and evidence expectation.

### Source Row Operational Layer

The compact controls above remain the architectural control layer. Source rows are an operational evidence layer derived from `skills/_shared/security-guideline-catalog.md#corporate-source-row-operational-inventory` and MUST NOT create replacement compact guidelines.

`design.md#secure-development-design` MAY summarize applicable source context in prose when the full expanded inventory is already present in the shared catalog, but it MUST NOT define source-row schema fields, lifecycle/status fields, matrices, or exhaustive `N/A` decisions. Those belong to `review-security-report.md`.

`test-design.md`, apply evidence, verify reports, and archive reports MUST consume applicable narrative category rules, evidence owners, and review-security report links. They MUST NOT become additional owners of the full 155-row matrix or exhaustive N/A decisions.

The row shape below is a review-security report schema example, not a design or test-design requirement:

```yaml
sourceRows:
  - sourceId: "1.1"
    corporateSection: "1. Authentication"
    guidelineTextRef: "skills/_shared/security-guideline-catalog.md#full-corporate-guideline-snapshot (Source ID 1.1)"
    pciAlignment: "PCI Req 6.5.8, 6.5.10" # or "N/A"
    mappedCompactGuidelineIds: ["SEC-AUTH-001"]
    applies: Yes # Yes | No | N/A
    complies: planned # planned | Yes | No | N/A
    lifecycleStatus: planned
    evidenceType: implementation-reference # implementation-reference | static-inspection | test-evidence | approved-exception | n/a-evidence
    evidenceLocation: "openspec/changes/<change>/review-security-report.md#corporate-source-row-validation"
    observations: "Review-safe summary only."
    finding: none # none | blocker | warning
    ownerPhase: test-design # design | test-design | tasks | apply | review | review-security | verify | archive
    route: test-design # test-design | apply | resolve-blockers | verify | archive
    naJustification: null
```

Source row rules:

- Every Source ID from the catalog's operational inventory MUST be expanded before validation and represented exactly once in security review matrices.
- Each source row MUST preserve `corporateSection`, `guidelineTextRef`, and `pciAlignment` from the catalog so reviewers can audit the row without copying the full guideline text into the matrix.
- `mappedCompactGuidelineIds` MUST contain one or more known compact IDs. Missing, empty, or unknown mappings route to `resolve-blockers`.
- `applies` MUST be `Yes`, `No`, or `N/A`. Review-security records `Yes`, `No`, and `N/A` verdicts during exhaustive validation and may use `No` when a row applies but lacks valid evidence.
- `complies` MUST be phase-appropriate: `planned` during design/test-design planning, `Yes` or `No` during review/verify evidence, and `N/A` only with complete irrelevance evidence.
- `evidenceType` MUST classify evidence as `implementation-reference`, `static-inspection`, `test-evidence`, `approved-exception`, or `n/a-evidence`.
- `ownerPhase` MUST name the phase responsible for remediation or carry-forward.
- `N/A` rows MUST include both evidence and `naJustification` proving irrelevance by category, platform, API, data class, or workflow. Unsupported `N/A` routes to `resolve-blockers`.
- `Applies`, `complies`, and `lifecycleStatus` MUST be internally consistent. For example, `Applies = N/A` requires `complies = N/A`, `lifecycleStatus = not-applicable`, `evidenceType = n/a-evidence`, evidence, and `naJustification`; `complies = Yes` requires implemented, verified, or exception-approved evidence; `finding = blocker` must route to `apply` or `resolve-blockers`.
- Applicable rows MUST cite review-safe evidence when the owning phase has produced evidence. Missing implementation evidence routes to `apply` when remediation is file, prompt, or contract work.
- Evidence and observations MUST NOT include secrets, PII, PAN, tokens, connection strings, private keys, or confidential values.
- Source row traceability MUST remain: Source ID -> mapped compact `SEC-*` -> narrative design category context when applicable -> test-design evidence plan for applicable rules -> apply evidence -> review-security exhaustive row verdict/N/A decision -> verify prerequisite -> archive audit trail.

## `review-security-report.md` Contract

`sdd-review-security` MUST validate `design.md#secure-development-design` after non-blocking general review and persist `review-security-report.md` before verify.

Required report content:

- Verdict: blocking or non-blocking.
- Source refs: `design.md#secure-development-design`, `review-report.md`, changed-file/task/apply evidence.
- One validation row per compact guideline ID with answer `Yes`, `No`, or `N/A`, lifecycle status, evidence location, observations, N/A justification/evidence when reported, missed-applicable-control finding when applicable, and exception reference when applicable.
- One source-row validation row per expanded corporate Source ID when the change requires source-row security review. Rows MUST cite corporate section, PCI alignment, guideline ref, compact mapping, applicability/compliance status, lifecycle status, evidence type, evidence location, finding, owner phase, and route.
- Focused source-row finding sections for blockers, warnings, `N/A` justifications, missing evidence rows, unsafe evidence rejections, and warning carry-forward. These sections keep the 155-row matrix compact while preserving audit detail.
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
| Missing PCI alignment, invalid evidence type, invalid owner phase, invalid guideline ref, or inconsistent applies/complies/lifecycle values | `resolve-blockers` |
| Unsafe evidence, missing `N/A` evidence/justification, or missed applicable control caused by narrative design omission | `resolve-blockers` |
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
