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

Run after `sdd-apply` completes implementation work and before `sdd-review-security`. Produce durable review evidence; do not fix issues and do not replace verification, embedded secure-design authority, or security review ownership. Verification consumes both review reports after security review completes.

## Phase Artifact Contract

Common backend mechanics: follow `skills/_shared/persistence-contract.md` through **Section B** (retrieval) and **Section C** (persistence) in `skills/_shared/sdd-phase-common.md`.
Common post-apply gates, safe-evidence rules, matrix ownership boundaries, routing defaults, and persistence/read-back expectations are defined in `skills/_shared/sdd-post-apply-gates.md`.

| Concern | Contract |
| --- | --- |
| Required inputs | Structured status plus proposal, specs, design with mandatory `## Secure Development Design`, mandatory `test-design`, tasks/apply progress, and changed-file context from the selected backend. Standalone `security-design.md` is legacy/read-only compatibility data only. |
| Produced artifact | `sdd/{change-name}/review` or `openspec/changes/{change-name}/review-report.md`. |
| Mutates | None outside the produced review report artifact. |
| Review catalog | Use the stable 96-control corporate checklist catalog in `references/control-catalog.md`; every `REV-CORP-001..REV-CORP-096` Item ID must appear exactly once in the matrix. |
| Matrix contract | The matrix header must be exactly: `Item`, `Artifact/Deliverable`, `Requirement`, `Reviewer`, `Standard`, `Severity`, `Complies`, `Affected Requirement`, `Evidence Location`, `Observations/Comments`. Do not add a Category column. |
| Complies values | `Complies` is limited to `Yes`, `No`, or `N/A`. Every `N/A` row must include Evidence Location proving irrelevance and Observations/Comments explaining scope. |
| Operational evidence review | Validate present/planned operational evidence for traceability, no-invention behavior, exact markers, evidence refs, unavailable-tooling notes, and unresolved gaps outside the fixed 96-control matrix. Do not add operational rows or columns to the matrix, and do not require absent readiness categories. |
| Security boundary | Review rows may cite security guideline IDs or source IDs in `Standard`, but `design.md#secure-development-design`, `review-security-report.md`, and `skills/sdd-review-security/references/security-guideline-catalog.md` remain authoritative for classification, mandatory controls, row evidence, and exceptions. |
| Security handoff | `review-report.md` must include changed-file context, implementation evidence summaries, finding context, `design.md#secure-development-design` references, and operational refs/gaps when present, sufficient for `sdd-review-security` to validate security handoff evidence without duplicating the 96-control matrix or owning leakage verdicts. |
| Success routing | No blocking failures: `next_recommended: review-security`. Non-blocking findings must remain in the report as warnings. |
| Failure routing | Critical, blocking, or explicitly blocking failed controls: `next_recommended: apply`; list failed controls and affected requirements. |
| Block routing | Follow `skills/_shared/sdd-post-apply-gates.md`; invalid catalog shape also routes to `resolve-blockers`. |

## Decision Gates

| Situation | Action |
| --- | --- |
| Common post-apply dependency, context, safe-evidence, or persistence gate fails | Follow `skills/_shared/sdd-post-apply-gates.md`; name the concrete missing/unsafe artifact or context. |
| Catalog does not contain exactly 96 unique Item IDs | Return `blocked`; do not write a passing report. |
| Any matrix row uses a `Complies` value outside `Yes`, `No`, `N/A` | Fix before persistence, or return `blocked`. |
| Any `N/A` lacks Evidence Location or comment | Fix before persistence, or return `blocked`. |
| Operational evidence checks are inserted into the 96-control matrix or change its header/row count | Fix before persistence, or return `blocked`; operational evidence belongs in a separate section when applicable. |
| Operational evidence contains unsupported invented operational values | Treat as blocking or route to `resolve-blockers`; review must not require real operational data disclosure. |
| Blocking or critical control fails | Persist the report with verdict `FAIL`, return `next_recommended: apply`, and identify failed controls plus affected requirements. |
| Only non-blocking findings exist | Persist the report with verdict `PASS WITH WARNINGS` and return `next_recommended: review-security`. |

## Execution Steps

1. Load supplemental skills according to `skills/_shared/skill-resolver.md` and the shared SDD Section A executor minimum.
2. Apply `skills/_shared/sdd-post-apply-gates.md` and read the selected change status plus all required inputs from the active artifact store.
3. Read `references/control-catalog.md` and confirm 96 unique Item IDs mapped one-to-one to corporate checklist source items 1 through 96.
4. Inspect applied changes, task evidence, specs, design including `design.md#secure-development-design` narrative rules, and test-design cases. Treat standalone `security-design.md` as optional legacy/archive context only.
5. Fill `review-report.md` using `references/report-template.md` and one matrix row per catalog Item ID, including changed-file/security handoff evidence for `sdd-review-security`.
5a. Add a separate operational evidence section when operational considerations, planned checks, evidence, gaps, or warnings exist. Validate safe evidence, exact `Pendiente de confirmar:` / `No aplica.` markers, traceability/no-invention/unavailable-tooling notes, and hand off refs plus unresolved gaps to `sdd-review-security` for leakage validation.
6. Classify findings as blocking or non-blocking. Blocking/critical findings prevent verify; non-blocking findings proceed as warnings.
7. Validate the report before persistence: required sections present, exact matrix header, 96 unique rows, valid `Complies`, complete `N/A` evidence, failed controls tied to affected requirements, and next recommendation matching verdict.
8. Persist the review artifact and return the Section D envelope from `skills/_shared/sdd-phase-common.md`.

## Output Contract

Return the Section D envelope. Put `## Review Report Summary` in `detailed_report` with change, inputs inspected, verdict, blocking summary, evidence summary, operational evidence summary outside the 96-control matrix when applicable, changed-file/security handoff summary including operational refs/gaps when present, matrix row count, catalog validation result, security-boundary notes, unavailable runtime/coverage/lint/typecheck/format checks when relevant, next route to review-security, and the persisted artifact path/topic.

## References

- [references/control-catalog.md](references/control-catalog.md) — stable 96-control review catalog and manual count evidence.
- [references/report-template.md](references/report-template.md) — required `review-report.md` contract/template.
- `../sdd-review-security/references/security-guideline-catalog.md` — security guideline IDs, taxonomy, evidence model, and authority boundary.
- `../_shared/skill-resolver.md` — supplemental skill loading and `skill_resolution` protocol.
- `../_shared/sdd-phase-common.md` — phase retrieval, persistence, and return envelope.
- `../_shared/sdd-post-apply-gates.md` — common post-apply gates, routing defaults, safe evidence, and matrix ownership boundaries.
