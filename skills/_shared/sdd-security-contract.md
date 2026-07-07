# SDD Security Contract

Shared cross-phase contract for narrative secure design, downstream security evidence, routing boundaries, approved exceptions, and review-safe evidence. This file defines what every SDD phase may rely on. Operational catalog inventory, compact `SEC-*` rows, Source ID expansion, PCI mappings, and report matrix schemas belong to `skills/sdd-review-security/references/`.

## Phase Ownership Boundary

| Artifact / phase | Owns | Must not own |
| --- | --- | --- |
| `design.md#secure-development-design` | Human-readable changed-surface classification, applicable security category rules, evidence owners, residual risks, exceptions, and safe-evidence policy. | YAML/JSON schemas, control tables, compact matrices, Source ID matrices, machine-readable applicability fields, exhaustive `N/A` bookkeeping, or the 96-control general review matrix. |
| `test-design.md` | Evidence plan for applicable narrative category rules and changed-surface risks, including static/manual/automated coverage expectations and unavailable-tooling substitutions. | Security catalog expansion, design schema parsing, compact/source matrices, or exhaustive `N/A` planning. |
| `apply` evidence | Changed-file references and implementation/static/manual proof for the narrative rules and planned evidence. | Security-review verdicts, Source ID materialization, or exception approval. |
| `review-report.md` | General applied-change review and security handoff context. | Security row verdicts, exhaustive compact/source matrices, or final verification. |
| `review-security-report.md` | Security review verdicts, compact-control validation, Source ID validation when applicable, row-level evidence, `N/A` decisions, missed-applicable blockers, unsafe-evidence blockers, and warning carry-forward. | Redefining shared phase boundaries or duplicating the general 96-control review matrix. |
| `verify` / `archive` | Consume and preserve non-blocking review/security-review verdicts, warnings, exceptions, evidence refs, and report links. | Re-scoring review matrices, copying full Source ID matrices, or fixing implementation. |

Boundary rules:

- Design is narrative: it plans applicable category rules; it does not prove all omitted categories.
- Omitted categories are reviewable omissions. `review-security-report.md` validates omissions and blocks missed applicable controls.
- Exhaustive compact-control and Source ID materialization belong only to `review-security-report.md`.
- Warning-only evidence may route forward only when mandatory evidence is complete and warnings stay visible to verify/archive.
- Missing, malformed, unsafe, unsupported, or conflicting security evidence blocks downstream phases until routed to `apply` or `resolve-blockers`.

## Shared Vocabulary

Use this vocabulary across design, test-design, apply evidence, review-security, verify, and archive.

| Field | Allowed values |
| --- | --- |
| `classification` | `security-impacting`, `no-impact` |
| `securityImpact` | `true`, `false` |
| `securityCategory` / `taxonomyCategory` | `authentication`, `sessions`, `sensitive-data-pan`, `secrets`, `permissions-access-control`, `files`, `database-access`, `sensitive-logging` |
| `decision` | `applicable`, `not-applicable`, `unknown` |
| `matrixAnswer` / `applies` / `complies` | `Yes`, `No`, `N/A` |
| `evidenceStatus` | `not-started`, `planned`, `implemented`, `verified`, `not-applicable`, `exception-approved`, `blocked` |
| `evidenceType` | `implementation-reference`, `static-inspection`, `test-evidence`, `approved-exception`, `n/a-evidence` |
| `finding` | `none`, `blocker`, `warning` |
| `ownerPhase` | `design`, `test-design`, `tasks`, `apply`, `review`, `review-security`, `verify`, `archive` |
| `route` | `apply`, `resolve-blockers`, `verify`, `archive` |
| `operationalSeverity` | `blocking`, `conditional`, `advisory` |

Operational severity is not general review severity. Labels such as `Menor`, `Media`, or `Mayor` may appear in general review findings, but they MUST NOT control security routing.

## Narrative Secure Design Contract

Every new active `design.md` MUST include `## Secure Development Design`.

Recommended shape:

- `### Classification and Changed Surface` — security-impacting or no-impact classification; touched artifacts/behaviors; untouched runtime surfaces; evidence supporting the classification; omitted categories left for review-security validation.
- `### <Applicable Security Category> Rules` — one subsection per applicable category. Each subsection states development rules, prohibited unsafe patterns, evidence owners, expected review-safe evidence, residual risks, exception handling, and safe-evidence policy.
- `### Exception and Evidence Policy` — complete exceptions when needed, otherwise state that no exceptions are planned.

Rules:

- New active designs MUST be human-readable Markdown prose only.
- New active designs MUST NOT contain security YAML, JSON, schema blocks, control tables, compact matrices, Source ID matrices, machine-readable applicability fields, exhaustive Source ID inventories, or all-row `N/A` bookkeeping.
- No-impact designs record changed-surface rationale in prose; they do not prove no-impact with exhaustive `N/A` rows.
- Unknown data sensitivity, auth/session/access boundaries, secret/config handling, file/database behavior, or sensitive logging implications block design success until clarified.
- Applicable category rules MUST identify controls, evidence owners, expected evidence, residual risks, and archive expectations.
- Incomplete exceptions do not satisfy design, verification, or archive readiness.

## Review-Security Contract

`sdd-review-security` runs after non-blocking general review and before verify. It owns the operational security catalog and report schema through its local `references/` files.

Rules:

- It validates narrative design rules, test-design coverage, apply evidence, changed files, and review-report handoff evidence.
- It materializes exhaustive compact rows and Source ID rows only in `review-security-report.md` when applicable.
- Row presence alone is not compliance evidence; rows require review-safe corroborating evidence or complete `N/A` justification.
- Missed applicable controls, unsafe evidence, unsupported `N/A`, malformed rows, or incomplete mandatory evidence block downstream phases.
- Non-blocking security review verdicts route to `verify`; implementation/security evidence gaps route to `apply`; artifact/schema/context repair routes to `resolve-blockers`.

## Approved Exception Contract

Archive MAY proceed with missing mandatory evidence only when the exception is complete and remains visible through verify/archive.

Required fields:

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

Exception rules:

- Exceptions apply only after authoritative approval is recorded.
- Exceptions MUST NOT remove category rows, source refs, validation metadata, or no-impact proof requirements.
- Incomplete exceptions are blockers.

## Safe-Evidence Rules

Evidence in SDD artifacts, review reports, verify reports, and archive reports MUST be review-safe.

Allowed evidence:

- artifact paths and section anchors
- changed-file references
- command summaries or sanitized outputs
- data-flow summaries
- redacted placeholders
- issue/follow-up references

Forbidden evidence:

- raw secrets, credentials, tokens, private keys, connection strings
- PAN, PII, confidential values, or unnecessary sensitive operational context
- raw sensitive payloads in logs/errors/traces

Mandatory category reminders:

- `sensitive-data-pan`: cite data-flow, masking/encryption, retention, or redacted examples only.
- `secrets`: cite secret/config names, storage mechanisms, or ownership notes only; never values.
- `permissions-access-control`: cite workflow gates and denial-by-default evidence without exposing hidden policy data.
- `sensitive-logging`: cite redaction rules, log locations, or sanitized summaries only.

## Routing Semantics

| Condition | Route |
| --- | --- |
| Remediation requires code, prompt, task, contract, or apply-evidence work | `apply` |
| Remediation requires missing context, artifact repair, schema/catalog repair, backend reconciliation, configuration repair, or unsafe-evidence cleanup | `resolve-blockers` |
| Mandatory evidence is complete and only warning rows remain | `verify` |
| Verify confirms non-blocking security evidence | `archive` |

Downstream phases MUST NOT advance past unresolved blockers or CRITICAL security evidence gaps.
