---
name: sdd-review
description: "Trigger: SDD review phase, code-review gate, review-report.md. Validate applied changes against the 96-control matrix."
disable-model-invocation: true
user-invocable: false
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  delegate_only: true
---

> **ORCHESTRATOR GATE**: Follow `skills/_shared/executor-boundary.md`.
> This skill is for the dedicated `sdd-review` executor only.

## Language Domain Contract

Follow `skills/_shared/language-domain-contract.md`.

## Activation Contract

Run after `sdd-apply` completes implementation work and before `sdd-review-security` / `sdd-verify`. Produce durable review evidence; do not fix issues and do not replace verification, embedded secure-design authority, or security review ownership.

## Phase Artifact Contract

Common backend mechanics: follow `skills/_shared/persistence-contract.md` through **Section B** (retrieval) and **Section C** (persistence) in `skills/_shared/sdd-phase-common.md`.

| Concern | Contract |
| --- | --- |
| Required inputs | Structured status plus proposal, specs, design with mandatory `## Secure Development Design`, mandatory `test-design`, tasks/apply progress, and changed-file context from the selected backend. Standalone `security-design.md` is legacy/read-only compatibility data only. |
| Produced artifact | `sdd/{change-name}/review` or `openspec/changes/{change-name}/review-report.md`. |
| Mutates | None outside the produced review report artifact. |
| Review catalog | Use the stable 96-control corporate checklist catalog in `references/control-catalog.md`; every `REV-CORP-001..REV-CORP-096` Item ID must appear exactly once in the matrix. |
| Matrix contract | The matrix header must be exactly: `Item`, `Artifact/Deliverable`, `Requirement`, `Reviewer`, `Standard`, `Severity`, `Complies`, `Affected Requirement`, `Evidence Location`, `Observations/Comments`. Do not add a Category column. |
| Complies values | `Complies` is limited to `Yes`, `No`, or `N/A`. Every `N/A` row must include Evidence Location proving irrelevance and Observations/Comments explaining scope. |
| Security boundary | Review rows may cite security guideline IDs or source IDs in `Standard`, but `design.md#secure-development-design`, `review-security-report.md`, and `skills/_shared/security-guideline-catalog.md` remain authoritative for classification, mandatory controls, row evidence, and exceptions. |
| Security handoff | `review-report.md` must include changed-file context, implementation evidence summaries, finding context, and `design.md#secure-development-design` references sufficient for `sdd-review-security` to validate embedded rows without duplicating the 96-control matrix. |
| Success routing | No blocking failures: `next_recommended: review-security`. Non-blocking findings must remain in the report as warnings. |
| Failure routing | Critical, blocking, or explicitly blocking failed controls: `next_recommended: apply`; list failed controls and affected requirements. |
| Block routing | Missing required artifacts, unknown changed files, unsafe workspace context, invalid catalog shape, or persistence failure: `next_recommended: resolve-blockers`. |

## Decision Gates

| Situation | Action |
| --- | --- |
| Required artifact cannot be resolved | Return `blocked` with `next_recommended: resolve-blockers`; name the missing artifact. |
| Changed-file context is absent or ambiguous | Return `blocked` with `next_recommended: resolve-blockers`; review cannot safely scope evidence. |
| Workspace context is unsafe or outside allowed roots | Return `blocked` with `next_recommended: resolve-blockers`. |
| Catalog does not contain exactly 96 unique Item IDs | Return `blocked`; do not write a passing report. |
| Any matrix row uses a `Complies` value outside `Yes`, `No`, `N/A` | Fix before persistence, or return `blocked`. |
| Any `N/A` lacks Evidence Location or comment | Fix before persistence, or return `blocked`. |
| Blocking or critical control fails | Persist the report with verdict `FAIL`, return `next_recommended: apply`, and identify failed controls plus affected requirements. |
| Only non-blocking findings exist | Persist the report with verdict `PASS WITH WARNINGS` and return `next_recommended: review-security`. |

## Execution Steps

1. Load supplemental skills via shared SDD Section A.
2. Read the selected change status and all required inputs from the active artifact store.
3. Read `references/control-catalog.md` and confirm 96 unique Item IDs mapped one-to-one to corporate checklist source items 1 through 96.
4. Inspect applied changes, task evidence, specs, design including embedded secure development rows, and test-design cases. Treat standalone `security-design.md` as optional legacy/archive context only.
5. Fill `review-report.md` using `references/report-template.md` and one matrix row per catalog Item ID, including changed-file/security handoff evidence for `sdd-review-security`.
6. Classify findings as blocking or non-blocking. Blocking/critical findings prevent verify; non-blocking findings proceed as warnings.
7. Validate the report before persistence: required sections present, exact matrix header, 96 unique rows, valid `Complies`, complete `N/A` evidence, failed controls tied to affected requirements, and next recommendation matching verdict.
8. Persist the review artifact and return the Section D envelope from `skills/_shared/sdd-phase-common.md`.

## Output Contract

Return the Section D envelope. Put `## Review Report Summary` in `detailed_report` with change, inputs inspected, verdict, blocking summary, evidence summary, changed-file/security handoff summary, matrix row count, catalog validation result, security-boundary notes, unavailable runtime/coverage/lint/typecheck/format checks when relevant, next route to review-security, and the persisted artifact path/topic.

## References

- [references/control-catalog.md](references/control-catalog.md) — stable 96-control review catalog and manual count evidence.
- [references/report-template.md](references/report-template.md) — required `review-report.md` contract/template.
- `../_shared/security-guideline-catalog.md` — security guideline IDs, taxonomy, evidence model, and authority boundary.
- `../_shared/sdd-phase-common.md` — skill loading, retrieval, persistence, and return envelope.
