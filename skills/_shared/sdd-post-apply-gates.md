# SDD Post-Apply Gates Contract

Shared execution contract for phases that run after implementation: `sdd-review`, `sdd-review-security`, and `sdd-verify`.

This contract centralizes common dependency gates, review-evidence handling, routing, matrix ownership boundaries, safe-evidence rules, unavailable-tooling language, and persistence expectations. Phase skills still own their phase-specific catalogs, report schemas, validation logic, and final verdict semantics.

## Phase Scope

| Phase | Owns | Consumes | Must not own |
| --- | --- | --- | --- |
| `sdd-review` | General applied-change review and the 96-control `review-report.md` matrix. | Status, design/test-design/tasks/apply evidence, changed-file context. | Security-review row verdicts, exhaustive compact security matrix, exhaustive Source ID matrix, final runtime verification. |
| `sdd-review-security` | Security review, compact `SEC-*` validation, exhaustive Source ID validation, `review-security-report.md`. | Non-blocking `review-report.md`, narrative secure design, test-design, tasks/apply evidence, changed-file context. | The general 96-control review matrix, final runtime verification, archive readiness. |
| `sdd-verify` | Final implementation/spec/test-design/security evidence verification and `verify-report.md`. | Non-blocking `review-report.md` and `review-security-report.md`, implementation evidence, runtime/static command evidence. | Reproducing or re-scoring either review matrix, owning exhaustive Source ID rows, fixing implementation. |

## Common Required Context

Every post-apply phase MUST resolve the structured SDD status and confirm the selected change before judging evidence.

Common inputs:

- selected `changeName`
- selected `artifact_store.mode`
- structured status compatible with `skills/_shared/sdd-status-contract.md`
- `design.md#secure-development-design` for active new changes
- `test-design.md`
- tasks and apply-progress or completed task evidence
- changed-file context
- safe `actionContext` / workspace context
- selected backend references following `skills/_shared/persistence-contract.md`

Additional phase-specific inputs:

| Phase | Additional required input |
| --- | --- |
| `sdd-review` | Proposal/specs when available, 96-control review catalog. |
| `sdd-review-security` | Non-blocking `review-report.md`, security guideline catalog, security contract. |
| `sdd-verify` | Non-blocking `review-report.md`, non-blocking `review-security-report.md`, testing capabilities/config. |

## Common Blocking Rules

Return `status: blocked` with `next_recommended: resolve-blockers` when the phase cannot safely judge evidence because of infrastructure, context, or artifact integrity:

- required artifacts are missing, unreadable, ambiguous, or materially conflicting
- changed-file context is absent or ambiguous
- selected backend has unresolved hybrid conflicts
- workspace/action context is unsafe, outside allowed roots, or planning-only for a phase that needs repo evidence
- required report evidence is missing, unreadable, malformed, or ambiguous
- persistence or read-back verification fails after no useful durable artifact can be trusted
- evidence contains secrets, credentials, PAN, PII, tokens, private keys, connection strings, or unnecessary confidential values
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

Phase envelopes use snake_case `next_recommended`. Persisted status/state uses camelCase `nextRecommended` only where required by `skills/_shared/sdd-status-contract.md`.

## Review Evidence Consumption

- `sdd-review-security` MUST consume `review-report.md` as supporting evidence only. It MUST NOT duplicate or recreate the 96-control matrix.
- `sdd-verify` MUST consume exactly one non-blocking general review report and one non-blocking security review report from the selected backend.
- Missing, ambiguous, unreadable, or blocking review evidence blocks dependent phases.
- Downstream phases cite report verdicts, blocker summaries, warning summaries, evidence summaries, catalog identity/counts, exceptions, and report links. They do not copy full matrices.

## Matrix Ownership Boundary

- `sdd-review` is the only active owner of the general 96-control review matrix.
- `sdd-review-security` is the only active owner of exhaustive compact `SEC-*` row materialization and the exhaustive 155 Source ID matrix.
- `sdd-verify` validates that the review reports are present, non-blocking, internally credible, and consumed as prerequisites. It MUST NOT reproduce or re-score either matrix.
- `sdd-archive` preserves links, verdicts, warning summaries, exceptions, and audit references only.

## Source-Row Consumption Boundary

For corporate source-row changes:

- `sdd-review-security` expands, materializes, and validates every expected Source ID exactly once.
- `sdd-verify` consumes the security-review source-row verdict, warning summary, catalog snapshot identity/path, expected Source ID count, compact mapping status, safe-evidence status, `N/A` justification status, exceptions, evidence references, blocker absence, and report links.
- `sdd-verify` blocks unresolved source-row blockers but does not duplicate the full Source ID matrix.
- Source-row routing follows `skills/_shared/sdd-security-contract.md#routing-semantics`.

## Safe Evidence and Unavailable Tooling

Evidence must be review-safe:

- cite paths, section anchors, changed-file refs, command summaries, sanitized summaries, or redacted placeholders
- never copy raw secrets, credentials, PAN, PII, connection strings, private keys, tokens, or unnecessary confidential data
- report unavailable runtime/build/lint/type/format/coverage tooling explicitly
- never invent commands or mark unavailable tooling as passing evidence

## Persistence and Return Envelope

Every post-apply phase MUST:

1. Load supplemental skills via `skills/_shared/sdd-phase-common.md` Section A.
2. Resolve/read dependencies through `skills/_shared/persistence-contract.md`.
3. Persist only its owned artifact.
4. Read back its artifact before reporting `status: success` in persistent modes.
5. Return the Section D phase envelope from `skills/_shared/sdd-phase-common.md`.

Do not call `mem_session_summary` from a phase executor. The final output must be text containing the phase envelope, not a final tool call.
