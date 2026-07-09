# SDD Operational Readiness Contract

Shared contract for planning, collecting, reviewing, verifying, archiving, and manually consuming operational-readiness evidence. The rule is simple: readiness evaluation is mandatory; disclosure of real operational data is not.

## Purpose

Use this contract whenever an SDD artifact needs operational readiness evidence. It defines the evidence categories, exact unresolved/inapplicable markers, restricted-data boundary, phase ownership, archive handoff, manual operational document boundary, and review-safe examples.

Operational fields MUST end in one of these states:

| State | Meaning |
| --- | --- |
| Safe evidence | The artifact cites review-safe evidence such as paths, section anchors, sanitized summaries, changed-file references, command summaries, or redacted placeholders. |
| `Pendiente de confirmar:` | The field applies, but safe evidence is unavailable, incomplete, unsafe to disclose, or must be supplied later by the user. |
| `No aplica.` | The field is genuinely out of scope. Optional rationale MAY follow, but the marker text and punctuation MUST remain exact. |

## Evidence Categories

Every SDD change MUST evaluate these categories. A category can be safely evidenced, pending, or inapplicable, but it cannot be silently skipped.

| Category | Required evaluation |
| --- | --- |
| Product and support ownership | Product owner, technical/support owner, escalation path, and responsibility boundaries. |
| Logs and error evidence | Log categories, error evidence, redaction expectations, and where safe evidence can be inspected. Raw sensitive logs are forbidden. |
| Monitoring mechanisms | Dashboards, alerts, jobs, traces, scripts, documented manual checks, or SQL where appropriate. Monitoring MUST be mechanism-oriented and MUST NOT be SQL-only by default. |
| Administration operations | Quarantine/stop, restart/resume, operator controls, periodic activities, and administrative safety notes. |
| Reprocessing and recovery | Retry/reprocess paths, recovery ownership, expected evidence, and unresolved recovery gaps. |
| Backup, retention, cleanup, and generated artifacts | Backup/retention/cleanup expectations plus generated artifact handling through references or summaries, not embedded bytes. |
| Final operational document inputs and unresolved gaps | Values or references needed by the manual final document, including gaps that must remain pending until explicitly supplied by the user. |

## Exact Marker Contract

Use the markers exactly as written:

- `Pendiente de confirmar:` — use when a field applies but safe evidence is unavailable, incomplete, unsafe to disclose, or requires explicit user-provided final-document input.
- `No aplica.` — use when a field is genuinely out of scope. Optional rationale may follow after the marker.

Do not replace either marker with synonyms, lowercase variants, missing punctuation, translated alternatives, or shorter forms. Exact marker usage is valid safe evidence for an unresolved or inapplicable field, but it does not replace required proof that restricted data was not leaked.

## Restricted Operational Data Boundary

Ordinary SDD evidence, code, tests, fixtures, examples, review reports, verify reports, archive reports, and generated evidence snippets MUST NOT include restricted operational data.

Restricted operational data includes:

- production hostnames, IP addresses, ports, SID/service names, and equivalent environment-specific identifiers
- credentials, tokens, private keys, connection strings, secret values, and secret-like values
- raw logs, raw traces, stack traces with sensitive payloads, user identifiers, confidential operational context, and sensitive payloads
- full ID lists, exported data lists, PAN, PII, confidential values, or unnecessary sensitive operational context
- generated file bytes, full exported file contents, environment-specific payloads, or binary/document payload copies

Allowed ordinary SDD evidence includes:

- artifact paths and section anchors
- changed-file references
- sanitized summaries and command summaries
- redacted placeholders
- safe mechanism names such as "dashboard", "alert", "job", "trace", "script", "documented manual check", or "SQL check where appropriate"
- exact `Pendiente de confirmar:` and `No aplica.` marker states

Final operational documentation MAY include restricted operational values only when the user explicitly provides them for that final manual document. Those values MUST NOT be backfilled into SDD evidence, archive summaries, review reports, examples, fixtures, or apply/verify evidence.

## Phase Ownership Boundary

| Phase | Owns | Must not own |
| --- | --- | --- |
| `sdd-design` | Operational strategy, expected safe evidence, unresolved markers, `No aplica.` rationale, restricted-data boundary, and downstream owners. | Real production data disclosure, review verdicts, or final operational document values. |
| `sdd-test-design` | Static, documentary, manual, or automated checks for marker exactness, traceability, monitoring mechanism coverage, unavailable-tooling substitutions, and restricted-data absence. | Treating unavailable runtime tooling as a pass or requiring real operational values. |
| `sdd-tasks` | Concrete work for evidence collection, marker validation, safe-evidence checks, unavailable-tooling notes, and archive handoff. | Leaving readiness work implicit. |
| `sdd-apply` | Implementation/static/manual evidence for assigned tasks, changed-file references, unavailable-tooling notes, and unresolved gaps discovered during implementation. | Security-review verdicts or unassigned downstream phase work. |
| `sdd-review` | Existence, traceability, no-invention behavior, exact placeholder usage, evidence refs, and unresolved gap handoff outside the fixed 96-control matrix. | Leakage verdicts, security row decisions, or changing the 96-control matrix shape. |
| `sdd-review-security` | Leakage validation for restricted operational data, secrets, logs/payloads, generated bytes, final-doc-only values, safe placeholders, and future exception evidence. | General review matrix ownership or requiring real restricted data to pass. |
| `sdd-verify` | Completeness confirmation that every readiness field has safe evidence, `Pendiente de confirmar:`, or `No aplica.`, plus warning and unavailable-tooling carry-forward. | Re-scoring review matrices or inventing missing operational values. |
| `sdd-archive` | Preservation of readiness status, evidence refs, unresolved gaps, warnings, exceptions, unavailable-tooling notes, and manual-document handoff. | Re-running review/verify or requiring `sdd-operational-doc` execution. |
| `sdd-operational-doc` | Manual post-archive generation from archived readiness evidence and explicit user-provided final values. | Creating archive readiness, becoming a required DAG phase, or backfilling SDD evidence. |

## Design Artifact Section Contract

Every active `design.md` MUST include `## Operational Readiness` for SDD changes. The section MUST evaluate the evidence categories above and state one of the allowed field states for each applicable field.

Recommended shape:

```markdown
## Operational Readiness

### Strategy
<How the change will be operated, observed, administered, recovered, and handed off.>

### Evidence Plan
| Category | Expected safe evidence | Owner phase | Status |
| --- | --- | --- | --- |
| Logs and error evidence | `path-or-section-anchor` / sanitized summary / `Pendiente de confirmar:` / `No aplica.` | design/test-design/review-security | <state> |

### Restricted Data Boundary
<State that production identifiers, secrets, payloads, full ID lists, and generated bytes stay out of ordinary SDD evidence.>

### Unresolved Gaps
- `Pendiente de confirmar:` <field and owner/follow-up when known>
```

## Test/Task/Review/Verify/Archive Handoff

Post-design phases MUST keep readiness evidence visible and safe:

1. `sdd-test-design` plans checks for every required category, exact markers, traceability, monitoring mechanism coverage, restricted-data absence, and unavailable-tooling substitutions.
2. `sdd-tasks` turns those checks into concrete collection/validation work, including archive handoff and unavailable-tooling notes.
3. `sdd-apply` reports assigned-task evidence, files changed, unresolved gaps, unavailable tooling, and any deviation from planned static/manual checks.
4. `sdd-review` validates readiness existence, traceability, no invention, and exact marker usage outside the fixed 96-control matrix; it hands off refs and gaps to `sdd-review-security`.
5. `sdd-review-security` validates restricted-data absence and confirms placeholders are safe without requiring real operational values.
6. `sdd-verify` confirms each readiness field has safe evidence, `Pendiente de confirmar:`, or `No aplica.`, and carries unresolved warnings forward.
7. `sdd-archive` preserves readiness status, evidence refs, unresolved gaps, warning carry-forward, unavailable-tooling notes, exceptions, and manual-document handoff boundaries.

## Manual Operational Document Boundary

`sdd-operational-doc` is a manual post-archive utility. It is not a required DAG phase and archive completion MUST NOT require running it.

When invoked manually, the utility MUST:

- read archived readiness evidence first
- preserve operational document sections 1-9 and diagrams R1-R4
- keep unresolved fields as exact `Pendiente de confirmar:`
- keep inapplicable fields as exact `No aplica.` when applicable
- use restricted operational values only when the user explicitly provides them for the final document
- never backfill final-document-only values into SDD evidence or archive summaries

## Safe Evidence Examples

| Need | Safe example | Unsafe example |
| --- | --- | --- |
| Ownership | `Support owner: Pendiente de confirmar:` | Inventing a person's name or escalation account. |
| Logs | `Logs: sanitized summary in review-report.md#readiness-evidence` | Copying raw logs, payloads, user IDs, or stack traces with secrets. |
| Monitoring | `Monitoring: dashboard/alert/job mechanism described; link redacted` | Requiring SQL-only checks by default or exposing production dashboard URLs. |
| Administration | `Restart/resume: documented manual check in ops runbook section anchor` | Exposing production hostnames, ports, or service SIDs. |
| Reprocessing | `Reprocessing: job path and sanitized command summary` | Copying connection strings, tokens, or production payload IDs. |
| Generated artifacts | `Generated output: file type summary and safe path reference` | Embedding generated file bytes or full exported file contents. |
| Final document input | `Production endpoint: Pendiente de confirmar:` | Backfilling a user-provided final endpoint into SDD apply/review/archive evidence. |
| Inapplicable field | `No aplica. This change has no generated operational artifacts.` | Omitting the category without explanation. |
