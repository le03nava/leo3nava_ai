---
name: sdd-review-security
description: "Validate mandatory security-design evidence and persist review-security-report.md. Trigger: orchestrator launches review-security after non-blocking sdd-review."
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

Validate the mandatory `security-design.md` matrix after general review and before verification. Consume `review-report.md`, apply/task evidence, changed-file context, and the security catalog; persist `review-security-report.md` with row-level verdicts, evidence, observations, blockers, exceptions, and next routing.

## Phase Artifact Contract

Common backend mechanics: follow `skills/_shared/persistence-contract.md` through **Section B** (retrieval) and **Section C** (persistence) in `skills/_shared/sdd-phase-common.md`.

| Concern | Contract |
| --- | --- |
| Required inputs | Structured status plus mandatory `security-design.md`, non-blocking `review-report.md`, tasks/apply progress or completed task evidence, changed-file context, `test-design.md` when available, `skills/_shared/security-guideline-catalog.md`, and `skills/_shared/sdd-security-contract.md`. |
| Produced artifact | `sdd/{change-name}/review-security-report` or `openspec/changes/{change-name}/review-security-report.md`. |
| Mutates | None outside the produced security review report artifact. |
| Matrix contract | Validate every security-design guideline/category row with `Complies` / answer values `Yes`, `No`, or `N/A`, evidence location, observations, and lifecycle status from the catalog vocabulary. |
| Boundary | Do not replace `sdd-review` and do not duplicate the 96-control matrix. Cite `review-report.md` as supporting evidence only. |
| Safe evidence | Evidence and observations must use paths, section refs, summaries, or redacted placeholders; do not copy secrets, credentials, PAN, PII, or unnecessary confidential values. |
| Success routing | Non-blocking verdict: `next_recommended: verify`. |
| Failure routing | Missing mandatory evidence, incomplete exceptions, blocked rows, or security blockers: `next_recommended: apply` or `resolve-blockers` according to whether remediation is implementation work or artifact/config repair. |

## Decision Gates

| Situation | Action |
| --- | --- |
| `security-design.md` is missing or unreadable | Return `blocked` with `next_recommended: resolve-blockers`; security review cannot run. |
| `review-report.md` is missing, unreadable, ambiguous, or blocking | Return `blocked` with `next_recommended: resolve-blockers` for missing/ambiguous evidence or `next_recommended: apply` for blocking review findings. |
| Changed-file/apply evidence is absent or ambiguous | Return `blocked` with `next_recommended: resolve-blockers`; row evidence cannot be scoped safely. |
| A security-design row uses unsupported `Yes`/`No`/`N/A` or lifecycle status vocabulary | Fix the report draft if possible; otherwise return `blocked`. |
| Applicable mandatory guideline lacks implementation evidence and lacks a complete approved exception | Persist a blocking report, mark the row `No` and `blocked`, and return `next_recommended: apply`. |
| N/A row lacks rationale/evidence proving irrelevance | Persist a blocking report and return `next_recommended: resolve-blockers` unless implementation remediation is required. |
| Approved exception is incomplete | Mark blocking and return `next_recommended: apply` or `resolve-blockers`. |
| Only non-blocking warnings exist | Persist `PASS WITH WARNINGS` and return `next_recommended: verify`. |

## Execution Steps

1. Load supplemental skills via shared SDD Section A.
2. Resolve and read mandatory inputs from the selected backend or `contextFiles`.
3. Confirm `review-report.md` is non-blocking and cite its verdict, blocking summary, and relevant evidence without copying its full matrix.
4. Parse each `security-design.md` guideline/category row, controls, evidence expectations, exceptions, carried risks, and archive gates.
5. Compare rows against changed files, tasks/apply evidence, test-design coverage, and general review evidence.
6. Produce `review-security-report.md` with report metadata, verdict, row validation matrix, implementation evidence, safe observations, blockers/non-blockers, exceptions, unavailable tooling when relevant, and `nextRecommended: verify|apply|resolve-blockers`.
7. Validate report shape, safe evidence, vocabulary, complete N/A rationale, complete exception fields, and routing consistency.
8. Persist and read back the report before returning.

## Report Format

````markdown
# Review Security Report: {Change Title}

```yaml
schemaName: gentle-ai.sdd-review-security-report
schemaVersion: 1
changeName: {change-name}
verdict: PASS | PASS WITH WARNINGS | FAIL
sourceSecurityDesign: {path-or-topic}
sourceReviewReport: {path-or-topic}
nextRecommended: verify | apply | resolve-blockers
```

## Summary

{Verdict, security-design rows validated, blockers/non-blockers, and evidence constraints.}

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
- ALWAYS require `security-design.md`; no-impact still has N/A rows to validate.
- NEVER duplicate the full 96-control general review matrix.
- NEVER print raw secrets, credentials, PAN, PII, or unnecessary confidential values in evidence.
- Missing runtime tooling must be reported as unavailable, not passed.
- Return `next_recommended: verify` only for non-blocking security review verdicts.
