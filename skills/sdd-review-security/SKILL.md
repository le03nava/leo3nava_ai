---
name: sdd-review-security
description: "Validate embedded secure-design evidence and persist review-security-report.md. Trigger: orchestrator launches review-security after non-blocking sdd-review."
disable-model-invocation: true
user-invocable: false
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  delegate_only: true
---

> **ORCHESTRATOR GATE**: Follow `skills/_shared/executor-boundary.md`.
> This skill is for the dedicated `sdd-review-security` executor only.

## Language Domain Contract

Follow `skills/_shared/language-domain-contract.md`.

## Purpose

Validate the mandatory `design.md#secure-development-design` matrix after general review and before verification. Consume `review-report.md`, apply/task evidence, changed-file context, test-design coverage, and the security catalog; persist `review-security-report.md` with row-level verdicts, evidence, observations, blockers, exceptions, and next routing.

## Phase Artifact Contract

Common backend mechanics: follow `skills/_shared/persistence-contract.md` through **Section B** (retrieval) and **Section C** (persistence) in `skills/_shared/sdd-phase-common.md`.

| Concern | Contract |
| --- | --- |
| Required inputs | Structured status plus mandatory `design.md#secure-development-design`, non-blocking `review-report.md`, tasks/apply progress or completed task evidence, changed-file context, `test-design.md`, `skills/_shared/security-guideline-catalog.md`, and `skills/_shared/sdd-security-contract.md`. |
| Produced artifact | `sdd/{change-name}/review-security-report` or `openspec/changes/{change-name}/review-security-report.md`. |
| Mutates | None outside the produced security review report artifact. |
| Matrix contract | Validate every embedded secure-design guideline/category row against `skills/_shared/security-guideline-catalog.md` with `Complies` / answer values `Yes`, `No`, or `N/A`, evidence location, observations, and lifecycle status from the catalog vocabulary. Missing applicable evidence or incomplete exceptions are `No` / `blocked`; `N/A` rows require evidence and justification. |
| Boundary | Do not replace `sdd-review` and do not duplicate the 96-control matrix. Cite `review-report.md` as supporting evidence only. |
| Active validation | New-change security review validates embedded design rows and artifact evidence directly; it does not require `scripts/validate_security_design.ps1` or separate standalone security artifacts. |
| Safe evidence | Evidence and observations must use paths, section refs, summaries, or redacted placeholders; do not copy secrets, credentials, PAN, PII, or unnecessary confidential values. |
| Success routing | Non-blocking verdict: `next_recommended: verify`. |
| Failure routing | Missing mandatory evidence, incomplete exceptions, blocked rows, or security blockers: `next_recommended: apply` or `resolve-blockers` according to whether remediation is implementation work or artifact/config repair. |

## Decision Gates

| Situation | Action |
| --- | --- |
| `design.md#secure-development-design` is missing or unreadable | Return `blocked` with `next_recommended: resolve-blockers`; persist no passing report and keep verify/archive unavailable until embedded design evidence exists. |
| `review-report.md` is missing, unreadable, ambiguous, or blocking | Return `blocked` with `next_recommended: resolve-blockers` for missing/ambiguous evidence or `next_recommended: apply` for blocking review findings. |
| Changed-file/apply evidence is absent or ambiguous | Return `blocked` with `next_recommended: resolve-blockers`; row evidence cannot be scoped safely. |
| A new-change review attempts to require `scripts/validate_security_design.ps1` or a standalone security artifact | Treat that requirement as invalid for the active flow; validate against the catalog, embedded rows, and persisted artifact evidence instead. |
| An embedded secure-design row uses unsupported `Yes`/`No`/`N/A` or lifecycle status vocabulary | Fix the report draft if possible; otherwise return `blocked`. |
| Applicable mandatory guideline lacks implementation evidence and lacks a complete approved exception | Persist a blocking report, mark the row `No` and `blocked`, and return `next_recommended: apply`. |
| N/A row lacks rationale/evidence proving irrelevance | Persist a blocking report and return `next_recommended: resolve-blockers` unless implementation remediation is required. |
| Approved exception is incomplete | Mark blocking and return `next_recommended: apply` or `resolve-blockers`. |
| Only non-blocking warnings exist | Persist `PASS WITH WARNINGS` and return `next_recommended: verify`. |

## Execution Steps

1. Load supplemental skills via shared SDD Section A.
2. Resolve and read mandatory inputs from the selected backend or `contextFiles`.
3. Confirm `design.md#secure-development-design` exists before evaluating evidence. If it is missing, stop with a blocking result and route to `resolve-blockers`.
4. Confirm `review-report.md` is non-blocking and cite its verdict, blocking summary, and relevant evidence without copying its full matrix.
5. Parse each `design.md#secure-development-design` guideline/category row, controls, evidence expectations, lifecycle status, exceptions, carried risks, and archive gates; compare IDs and vocabulary against `skills/_shared/security-guideline-catalog.md`.
6. Compare rows against changed files, tasks/apply evidence, test-design coverage, and general review handoff evidence. Mark applicable mandatory rows with missing implementation evidence or incomplete exceptions as `No` and lifecycle `blocked`; justify every `N/A` row with evidence proving irrelevance.
7. Produce `review-security-report.md` with report metadata, verdict, row validation matrix, implementation evidence, safe observations, blockers/non-blockers, exceptions, unavailable tooling when relevant, and `nextRecommended: verify|apply|resolve-blockers`.
8. Validate report shape, safe evidence, vocabulary, complete N/A rationale, complete exception fields, and routing consistency. Do not invoke or require `scripts/validate_security_design.ps1` for this validation.
9. Persist and read back the report before returning.

## Report Format

````markdown
# Review Security Report: {Change Title}

```yaml
schemaName: gentle-ai.sdd-review-security-report
schemaVersion: 1
changeName: {change-name}
verdict: PASS | PASS WITH WARNINGS | FAIL
sourceSecureDesign: {path-or-topic}#secure-development-design
sourceReviewReport: {path-or-topic}
nextRecommended: verify | apply | resolve-blockers
```

## Summary

{Verdict, embedded secure-design rows validated, blockers/non-blockers, and evidence constraints.}

## Security Row Validation

| Guideline ID | Category | Design Applies | Lifecycle Status | Complies | Evidence Location | Observations | Finding |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SEC-...` | `category` | Yes/No/N/A | `implemented`/... | Yes/No/N/A | `path#section` | Safe summary | None/blocking/warning |

## General Review Handoff

{Cite `review-report.md` verdict and relevant row/evidence summaries only. Do not duplicate the 96-control matrix.}

## Exceptions

{Complete approved exceptions or "None".}

## Blockers and Non-Blocking Findings

{Grouped findings with guideline IDs, owner, route, and safe evidence.}

## Unavailable Tooling

{Runtime test/lint/type/format/coverage unavailable evidence when applicable; missing tools are not passing evidence.}
````

## Output Contract

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`. Put `## Security Review Report Summary` in `detailed_report` with change, inputs inspected, verdict, row count, blockers, non-blockers, safe-evidence notes, unavailable tooling, persisted path/topic, and next route.

## Rules

- ALWAYS run after non-blocking `sdd-review` and before `sdd-verify` for new changes.
- ALWAYS require `design.md#secure-development-design`; no-impact still has N/A rows to validate.
- Validate new-change security evidence through embedded design rows, catalog vocabulary, and artifact evidence; do not require `scripts/validate_security_design.ps1` or standalone security artifacts.
- NEVER duplicate the full 96-control general review matrix.
- NEVER print raw secrets, credentials, PAN, PII, or unnecessary confidential values in evidence.
- Missing runtime tooling must be reported as unavailable, not passed.
- Return `next_recommended: verify` only for non-blocking security review verdicts.
