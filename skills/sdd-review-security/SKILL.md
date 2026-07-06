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

## Activation Contract

Run after non-blocking `sdd-review` and before `sdd-verify`. Validate the mandatory `design.md#secure-development-design` matrix, consume `review-report.md`, apply/task evidence, changed-file context, test-design coverage, and the security catalog; persist `review-security-report.md` with row-level verdicts, evidence, observations, blockers, exceptions, and next routing.

## Phase Artifact Contract

Common backend mechanics: follow `skills/_shared/persistence-contract.md` through **Section B** (retrieval) and **Section C** (persistence) in `skills/_shared/sdd-phase-common.md`.

| Concern | Contract |
| --- | --- |
| Required inputs | Structured status plus mandatory `design.md#secure-development-design`, non-blocking `review-report.md`, tasks/apply progress or completed task evidence, changed-file context, `test-design.md`, `skills/_shared/security-guideline-catalog.md`, and `skills/_shared/sdd-security-contract.md`. |
| Produced artifact | `sdd/{change-name}/review-security` or `openspec/changes/{change-name}/review-security-report.md`. |
| Mutates | None outside the produced security review report artifact. |
| Matrix contract | Validate every compact security guideline ID from `skills/_shared/security-guideline-catalog.md` exactly once against the embedded secure-design evidence, with `Complies` / answer values `Yes`, `No`, or `N/A`, evidence location, observations, and lifecycle status from the catalog vocabulary. Missing, duplicate, or unknown guideline IDs are blocking. Missing applicable evidence or incomplete exceptions are `No` / `blocked`; `N/A` rows require evidence and justification. |
| Source-row contract | When corporate source-row validation applies, validate every expanded Source ID from `skills/_shared/security-guideline-catalog.md#corporate-source-row-operational-inventory` exactly once against `design.md#secure-development-design`, `test-design.md`, completed tasks/apply evidence, changed-file context, and `review-report.md`. Rows MUST cite compact `SEC-*` mappings, applicability/compliance status, lifecycle status, evidence location, observations, finding, and route. A row MUST NOT pass merely because it is listed. |
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
| `test-design.md` is missing, unreadable, or ambiguous | Return `blocked` with `next_recommended: resolve-blockers`; security review cannot judge planned evidence coverage safely. |
| Changed-file/apply evidence is absent or ambiguous | Return `blocked` with `next_recommended: resolve-blockers`; row evidence cannot be scoped safely. |
| A new-change review attempts to require `scripts/validate_security_design.ps1` or a standalone security artifact | Treat that requirement as invalid for the active flow; validate against the catalog, embedded rows, and persisted artifact evidence instead. |
| Embedded secure-design rows have missing, duplicate, or unknown compact guideline IDs | Persist no passing report; return `blocked` with `next_recommended: resolve-blockers` because upstream design evidence must be repaired. |
| An embedded secure-design row uses a matrix value outside `Yes`, `No`, or `N/A`, or lifecycle status outside the catalog vocabulary | Persist no passing report; return `blocked` with `next_recommended: resolve-blockers` because upstream design evidence must be repaired. |
| Source-row coverage has missing, duplicate, or unknown Source IDs | Persist no passing report; return `blocked` with `next_recommended: resolve-blockers` because the source-row inventory or report shape must be repaired. |
| A source row has malformed schema, unsupported allowed values, or missing/unknown compact `SEC-*` mappings | Persist no passing report; return `blocked` with `next_recommended: resolve-blockers`. |
| Source-row evidence contains secrets, credentials, PAN, PII, tokens, connection strings, private keys, or confidential values | Reject the evidence, persist no passing report, and return `blocked` with `next_recommended: resolve-blockers` unless remediation is implementation work. |
| Applicable mandatory guideline lacks implementation evidence and lacks a complete approved exception | Persist a blocking report, mark the row `No` and `blocked`, and return `next_recommended: apply`. |
| Applicable source row lacks corroborating implementation/apply/changed-file evidence | Persist a blocking report, mark the row `No` and `blocker`, and return `next_recommended: apply` when remediation is file, prompt, or contract work. |
| N/A row lacks rationale/evidence proving irrelevance | Persist a blocking report and return `next_recommended: resolve-blockers` unless implementation remediation is required. |
| Approved exception is incomplete | Mark blocking and return `next_recommended: apply` or `resolve-blockers`. |
| Only non-blocking warnings exist | Persist `PASS WITH WARNINGS` and return `next_recommended: verify`. |

## Source-Row Review Rules

Use the source-row layer as operational security evidence below the compact `SEC-*` layer. Do not promote Source IDs into new compact controls.

| Rule | Requirement |
| --- | --- |
| Exact-once coverage | Expand catalog ranges before validation and require every expected Source ID exactly once in `review-security-report.md`. Missing, duplicate, or unknown IDs are blockers routed to `resolve-blockers`. |
| Evidence correlation | Compare each row to design expectations, test-design checks, completed tasks/apply evidence, changed files, and relevant `review-report.md` citations. A listed-only row fails. |
| Compact mapping | Each row must map to one or more known compact IDs: `SEC-AUTH-001`, `SEC-SESS-001`, `SEC-DATA-001`, `SEC-SECRET-001`, `SEC-ACCESS-001`, `SEC-FILE-001`, `SEC-DB-001`, or `SEC-LOG-001`. Missing or unknown mappings route to `resolve-blockers`. |
| Safe evidence | Evidence and observations cite paths, section refs, changed-file refs, command summaries, sanitized summaries, or redacted placeholders only. Unsafe evidence routes to `resolve-blockers` unless implementation remediation is required. |
| N/A evidence | `N/A` rows require evidence and `naJustification` proving irrelevance by category, platform, API, data class, or workflow. Unsupported `N/A` routes to `resolve-blockers`. |
| Implementation gaps | Applicable rows that lack implementation evidence route to `apply` when the fix is code, skill, prompt, contract, or task evidence work. |
| Warnings-only progression | Warning rows may proceed to `verify` only when mandatory source-row evidence is complete, safe, mapped, and non-blocking. |

## Execution Steps

1. Load supplemental skills via shared SDD Section A.
2. Resolve and read mandatory inputs from the selected backend or `contextFiles`.
3. Confirm `design.md#secure-development-design` exists before evaluating evidence. If it is missing, stop with a blocking result and route to `resolve-blockers`.
4. Confirm `review-report.md` is non-blocking and cite its verdict, blocking summary, and relevant evidence without copying its full matrix.
5. Parse each `design.md#secure-development-design` guideline/category row, controls, evidence expectations, lifecycle status, exceptions, carried risks, and archive gates; compare IDs and vocabulary against `skills/_shared/security-guideline-catalog.md`, requiring every compact guideline ID exactly once.
6. When source-row validation applies, build the expected expanded Source ID universe from the catalog operational inventory, then validate that the security report rows cover that universe exactly once with known compact mappings and allowed schema values.
7. Compare compact and source rows against changed files, tasks/apply evidence, test-design coverage, and general review handoff evidence. Mark applicable mandatory rows with missing implementation evidence or incomplete exceptions as `No` and lifecycle `blocked`; mark source rows with missing corroboration as `blocker`; justify every `N/A` row with evidence proving irrelevance.
8. Produce `review-security-report.md` with report metadata, verdict, compact row validation matrix, source-row validation matrix when applicable, implementation evidence, safe observations, blockers/non-blockers, exceptions, unavailable tooling when relevant, and artifact metadata `nextRecommended: verify|apply|resolve-blockers`.
9. Validate report shape, source-row exact-once coverage, safe evidence, vocabulary, complete N/A rationale, complete exception fields, and routing consistency. Do not invoke or require `scripts/validate_security_design.ps1` for this validation.
10. Persist and read back the report before returning.

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

## Corporate Source Row Validation

| Source ID | Corporate Section | Compact Mapping | Applies | Complies | Lifecycle Status | Evidence Location | Observations | Finding | Route |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `1.1` | `1. Authentication` | `SEC-AUTH-001` | Yes/No/N/A | Yes/No/N/A | `implemented`/... | `path#section` | Safe summary | none/blocker/warning | verify/apply/resolve-blockers |

The source-row matrix is security-specific and bounded to the corporate Source ID inventory. It MUST NOT copy the general 96-control `sdd-review` matrix.

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

## Routing Contract

- Non-blocking report verdict `PASS` or `PASS WITH WARNINGS` -> return phase envelope `next_recommended: verify`.
- Persisted report verdict `FAIL` caused by implementation/security evidence gaps -> return phase envelope `next_recommended: apply`.
- Missing, ambiguous, unreadable, duplicate, or malformed upstream artifacts -> return phase envelope `status: blocked` and `next_recommended: resolve-blockers`.
- Missing/duplicate/unknown Source IDs, malformed source-row schema, missing mappings, unsafe evidence, or unsupported `N/A` -> return phase envelope `status: blocked` and `next_recommended: resolve-blockers`.
- Applicable source rows missing implementation evidence -> return phase envelope `next_recommended: apply` when remediation is file, prompt, contract, or task evidence work.
- Warnings-only source-row findings with complete mandatory evidence -> return phase envelope `next_recommended: verify`.
- Persistence failure after producing a useful report -> return phase envelope `status: partial` with `next_recommended: resolve-blockers` and include the report in `detailed_report` when safe.
- Do not return camelCase `nextRecommended` from the phase envelope. CamelCase is for artifact/status/state metadata only.

## Rules

- ALWAYS run after non-blocking `sdd-review` and before `sdd-verify` for new changes.
- ALWAYS require `design.md#secure-development-design`; no-impact still has N/A rows to validate.
- Validate new-change security evidence through embedded design rows, catalog vocabulary, and artifact evidence; do not require `scripts/validate_security_design.ps1` or standalone security artifacts.
- For corporate source-row changes, validate every expanded Source ID exactly once against design, test-design, apply evidence, changed files, and `review-report.md` citations.
- Source-row rows must be corroborated by safe evidence; row presence alone is not compliance evidence.
- NEVER duplicate the full 96-control general review matrix.
- NEVER print raw secrets, credentials, PAN, PII, or unnecessary confidential values in evidence.
- Missing runtime tooling must be reported as unavailable, not passed.
- Return `next_recommended: verify` only for non-blocking security review verdicts.

## References

- `../_shared/sdd-phase-common.md` — skill loading, retrieval, persistence, and return envelope.
- `../_shared/persistence-contract.md` — artifact keys, backend behavior, hybrid conflict policy, and read-back verification.
- `../_shared/security-guideline-catalog.md` — compact SEC guideline IDs, taxonomy, vocabulary, and safe-evidence rules.
- `../_shared/sdd-security-contract.md` — embedded secure-design and review-security report schema contracts.
