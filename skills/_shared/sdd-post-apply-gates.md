# SDD Post-Apply Gates Contract

Shared execution contract for phases that run after implementation: `sdd-review`, `sdd-review-security`, `sdd-verify`, and `sdd-archive`.

This contract centralizes common dependency gates, review-evidence handling, archive readiness, routing, matrix ownership boundaries, safe-evidence rules, unavailable-tooling language, and persistence expectations. Phase skills still own their phase-specific catalogs, report schemas, validation logic, final verdict semantics, and archive filesystem/spec-sync mechanics.

## Phase Scope

| Phase | Owns | Consumes | Must not own |
| --- | --- | --- | --- |
| `sdd-review` | General applied-change review and the 96-control `review-report.md` matrix. | Status, design/test-design/tasks/apply evidence, changed-file context. | Security-review row verdicts, exhaustive compact security matrix, exhaustive Source ID matrix, final runtime verification. |
| `sdd-review-security` | Security review, compact `SEC-*` validation, exhaustive Source ID validation, `review-security-report.md`. | Non-blocking `review-report.md`, narrative secure design, test-design, tasks/apply evidence, changed-file context. | The general 96-control review matrix, final runtime verification, archive readiness. |
| `sdd-verify` | Final implementation/spec/test-design/security evidence verification and `verify-report.md`. | Non-blocking `review-report.md` and `review-security-report.md`, implementation evidence, runtime/static command evidence. | Reproducing or re-scoring either review matrix, owning exhaustive Source ID rows, fixing implementation. |
| `sdd-archive` | Final source-of-truth sync, archive move/report, and audit-trail preservation. | Passing `verify-report`, non-blocking review reports, completed tasks/apply evidence, mandatory security evidence, status/action context. | Re-scoring reviews, re-running verification, fixing implementation, or owning review matrices. |

Operational readiness evidence follows `skills/_shared/sdd-operational-readiness-contract.md`. Post-apply phases consume that evidence as safe summaries, refs, exact `Pendiente de confirmar:` markers, exact `No aplica.` markers, unresolved gaps, warnings, unavailable-tooling notes, and archive/manual-document handoff boundaries.

## Common Required Context

Every post-apply phase MUST resolve the structured SDD status and confirm the selected change before judging evidence.

Common inputs:

- selected `changeName`
- selected `artifact_store.mode`
- structured status compatible with `skills/_shared/sdd-status-contract.md`
- `design.md#secure-development-design` for active new changes
- `test-design.md`
- tasks and apply-progress or completed task evidence
- operational readiness evidence, unresolved gaps, warning carry-forward, and unavailable-tooling notes when the change includes readiness obligations
- changed-file context when the phase judges changed-file evidence directly
- safe `actionContext` / workspace context
- selected backend references following `skills/_shared/persistence-contract.md`

Additional phase-specific inputs:

| Phase | Additional required input |
| --- | --- |
| `sdd-review` | Proposal/specs when available, 96-control review catalog. |
| `sdd-review-security` | Non-blocking `review-report.md`, security guideline catalog, security contract. |
| `sdd-verify` | Non-blocking `review-report.md`, non-blocking `review-security-report.md`, testing capabilities/config. |
| `sdd-archive` | Passing `verify-report`, complete task state, state artifact, archive destination context, and any explicit partial/stale-checkbox reconciliation approval. |

## Common Blocking Rules

Return `status: blocked` with `next_recommended: resolve-blockers` when the phase cannot safely judge evidence because of infrastructure, context, or artifact integrity:

- required artifacts are missing, unreadable, ambiguous, or materially conflicting
- changed-file context is absent or ambiguous for a phase that judges changed-file evidence directly
- selected backend has unresolved hybrid conflicts
- workspace/action context is unsafe, outside allowed roots, or planning-only for a phase that needs repo evidence
- required report evidence is missing, unreadable, malformed, or ambiguous
- persistence or read-back verification fails after no useful durable artifact can be trusted
- evidence contains secrets, credentials, PAN, PII, tokens, private keys, connection strings, or unnecessary confidential values
- operational readiness evidence contains restricted production identifiers, raw logs/payloads, generated file bytes, final-document-only values outside the final manual document, or invented operational details
- required readiness fields are missing instead of carrying safe evidence, exact `Pendiente de confirmar:`, or exact `No aplica.`
- unavailable tooling is treated as passing evidence instead of being reported as unavailable

When a useful report was produced but persistence/read-back failed, return `status: partial` with `next_recommended: resolve-blockers` and include the safe report content or recovery path in `detailed_report`.

## Common Routing Rules

Use these routes consistently:

| Condition | Route |
| --- | --- |
| Remediation requires code, prompt, task, contract, or apply-evidence work | `next_recommended: apply` |
| Remediation requires missing context, artifact repair, backend reconciliation, unsafe evidence cleanup, schema/catalog repair, or configuration repair | `next_recommended: resolve-blockers` |
| Current phase produced non-blocking review evidence | next DAG phase only: `review-security`, `verify`, or `archive` |
| Current phase found CRITICAL/blocking issues | never advance to a downstream phase |
| Archive readiness fails because general review is missing or unreadable | `next_recommended: review` |
| Archive readiness fails because security review is missing or unreadable | `next_recommended: review-security` |
| Archive readiness fails because verification is missing or non-passing | `next_recommended: verify` |
| Archive readiness fails because implementation tasks/evidence are incomplete | `next_recommended: apply` |

Phase envelopes use snake_case `next_recommended`. Persisted status/state uses camelCase `nextRecommended` only where required by `skills/_shared/sdd-status-contract.md`.

## Review Evidence Consumption

- `sdd-review-security` MUST consume `review-report.md` as supporting evidence only. It MUST NOT duplicate or recreate the 96-control matrix.
- `sdd-verify` MUST consume exactly one non-blocking general review report and one non-blocking security review report from the selected backend.
- `sdd-archive` MUST consume exactly one non-blocking general review report and one non-blocking security review report from the selected backend, plus a passing verify report.
- Missing, ambiguous, unreadable, or blocking review evidence blocks dependent phases.
- Downstream phases cite report verdicts, blocker summaries, warning summaries, evidence summaries, catalog identity/counts, exceptions, and report links. They do not copy full matrices.

Operational readiness consumption:

| Phase | Must consume | Must preserve or hand off |
| --- | --- | --- |
| `sdd-review` | Design/test-design/tasks/apply readiness evidence, exact markers, changed-file refs, unavailable-tooling notes, and unresolved gaps. | Readiness findings outside the 96-control matrix plus refs/gaps for `sdd-review-security`. |
| `sdd-review-security` | General-review readiness refs/gaps, secure design rules, safe-evidence policy, changed files, and apply evidence. | Leakage verdicts for restricted operational identifiers, secrets, logs/payloads, generated bytes, final-doc-only values, safe placeholders, and future exception evidence. |
| `sdd-verify` | Non-blocking review and security-review readiness evidence, warning summaries, unavailable-tooling notes, and implementation evidence. | Completeness verdict that every readiness field has safe evidence, `Pendiente de confirmar:`, or `No aplica.`, with unresolved warnings carried forward. |
| `sdd-archive` | Passing verify readiness evidence, non-blocking review/security-review readiness summaries, completed task state, warnings, exceptions, and unavailable-tooling notes. | Readiness status, evidence refs, unresolved gaps, warning carry-forward, final-document handoff boundaries, and confirmation that `sdd-operational-doc` remains manual post-archive. |

## Archive Readiness

`sdd-archive` MUST prove final readiness before syncing specs, moving folders, or recording cycle completion.

Archive may proceed only when all required evidence is readable in the selected backend:

- proposal, specs, design with `## Secure Development Design`, test-design, tasks, apply-progress or completed task evidence, state, non-blocking `review-report`, non-blocking `review-security-report`, and passing `verify-report`
- all implementation tasks are complete in the persisted task artifact, unless explicit stale-checkbox reconciliation is approved and backed by apply-progress plus verify-report proof
- mandatory applicable security evidence is complete or covered by complete approved exceptions
- readiness evidence is complete for every required field as safe evidence, exact `Pendiente de confirmar:`, or exact `No aplica.`
- readiness evidence refs, unresolved gaps, warning carry-forward, unavailable-tooling notes, and manual-document handoff boundaries are preserved without requiring `sdd-operational-doc` execution
- review/security-review reports contain no blocking findings, and verify contains no CRITICAL issues or failing verdict
- action context is repo-safe for archive operations; workspace-planning mode cannot move folders or edit linked repos

Allowed archive exceptions are narrow:

- **Intentional partial archive**: allowed only for missing non-critical planning artifacts when explicitly approved and recorded in the archive report.
- **Stale-checkbox reconciliation**: allowed only when the orchestrator provides explicit approval and apply-progress plus verify-report prove every stale unchecked task is complete.
- **Approved security exception**: allowed only when every required exception field from `skills/_shared/sdd-security-contract.md` is complete.

Archive MUST block on:

| Condition | Route |
| --- | --- |
| Missing/unreadable/ambiguous `review-report` | `review` |
| Blocking general review finding or verdict | `apply` |
| Missing/unreadable/ambiguous `review-security-report` | `review-security` |
| Blocking security review finding, unresolved source-row blocker, unsafe evidence, unsupported `N/A`, missing mandatory source-row evidence, malformed source-row schema, or missing compact mapping | `apply` or `resolve-blockers` according to remediation ownership |
| Missing `verify-report` | `verify` |
| Verify verdict `FAIL`, CRITICAL issue, or non-passing report | `apply` |
| Missing readiness refs, unresolved gaps not carried forward, missing unavailable-tooling notes, or final-document handoff boundary absent | `apply` or `verify` according to remediation ownership |
| Readiness evidence contains restricted operational data, invented values, raw logs/payloads, generated bytes, or final-document-only values outside the final manual document | `apply` or `resolve-blockers` according to remediation ownership |
| Unchecked persisted implementation tasks without approved stale-checkbox reconciliation | `apply` |
| Missing mandatory embedded secure design, test-design, or mandatory security evidence without complete approved exception | `resolve-blockers` |
| Unsafe action context, destination conflict, backend conflict, or archive operation outside allowed roots | `resolve-blockers` |

## Matrix Ownership Boundary

- `sdd-review` is the only active owner of the general 96-control review matrix.
- `sdd-review-security` is the only active owner of exhaustive compact `SEC-*` row materialization and the exhaustive 155 Source ID matrix.
- `sdd-verify` validates that the review reports are present, non-blocking, internally credible, and consumed as prerequisites. It MUST NOT reproduce or re-score either matrix.
- `sdd-archive` preserves links, verdicts, warning summaries, exceptions, and audit references only.

## Source-Row Consumption Boundary

For corporate source-row changes:

- `sdd-review-security` expands, materializes, and validates every expected Source ID exactly once.
- `sdd-verify` consumes the security-review source-row verdict, warning summary, catalog snapshot identity/path, expected Source ID count, compact mapping status, safe-evidence status, `N/A` justification status, exceptions, evidence references, blocker absence, and report links.
- `sdd-archive` preserves source-row coverage summaries, catalog identity/path, exact-once coverage status, compact mappings, warnings, exceptions, safe evidence references, `N/A` evidence/justification status, review-security verdict, verify consumption, and report links.
- `sdd-verify` and `sdd-archive` block unresolved source-row blockers but do not duplicate the full Source ID matrix.
- Source-row routing follows `skills/_shared/sdd-security-contract.md#routing-semantics`.

## Safe Evidence and Unavailable Tooling

Evidence must be review-safe:

- cite paths, section anchors, changed-file refs, command summaries, sanitized summaries, or redacted placeholders
- never copy raw secrets, credentials, PAN, PII, connection strings, private keys, tokens, or unnecessary confidential data
- never copy production hostnames, IP addresses, ports, SID/service names, sensitive payloads, full ID lists, generated file bytes, or final-document-only values into ordinary SDD evidence
- preserve readiness gaps with exact `Pendiente de confirmar:` and inapplicable fields with exact `No aplica.`
- report unavailable runtime/build/lint/type/format/coverage tooling explicitly
- never invent commands or mark unavailable tooling as passing evidence

## Persistence and Return Envelope

Every post-apply phase MUST:

1. Load supplemental skills according to `skills/_shared/skill-resolver.md` and `skills/_shared/sdd-phase-common.md` Section A executor minimum.
2. Resolve/read dependencies through `skills/_shared/persistence-contract.md`.
3. Persist only its owned artifact.
4. Read back its artifact before reporting `status: success` in persistent modes.
5. Return the Section D phase envelope from `skills/_shared/sdd-phase-common.md`.

Do not call `mem_session_summary` from a phase executor. The final output must be text containing the phase envelope, not a final tool call.
