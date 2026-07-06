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

Run after non-blocking `sdd-review` and before `sdd-verify`. Parse narrative `design.md#secure-development-design` category rules and omissions, expand the mandatory security catalog, consume `review-report.md`, apply/task evidence, changed-file context, and test-design coverage; persist `review-security-report.md` with its own schema, compact matrix, source-row matrix, row-level verdicts, evidence, observations, blockers, exceptions, and next routing. For corporate source-row validation, `review-security-report.md` is the only active new-change artifact that materializes the exhaustive compact-control matrix and exhaustive 155 Source ID matrix.

## Phase Artifact Contract

Common backend mechanics: follow `skills/_shared/persistence-contract.md` through **Section B** (retrieval) and **Section C** (persistence) in `skills/_shared/sdd-phase-common.md`.

| Concern | Contract |
| --- | --- |
| Required inputs | Structured status plus mandatory narrative `design.md#secure-development-design`, non-blocking `review-report.md`, tasks/apply progress or completed task evidence, changed-file context, `test-design.md`, `skills/_shared/security-guideline-catalog.md`, and `skills/_shared/sdd-security-contract.md`. |
| Produced artifact | `sdd/{change-name}/review-security` or `openspec/changes/{change-name}/review-security-report.md`. |
| Mutates | None outside the produced security review report artifact. |
| Matrix contract | Expand every compact security guideline ID from `skills/_shared/security-guideline-catalog.md` and materialize each compact row exactly once in `review-security-report.md`, with `Complies` / answer values `Yes`, `No`, or `N/A`, evidence location, observations, and lifecycle status from the catalog vocabulary. Narrative design may omit non-applicable rows; review-security validates those omissions instead of requiring design to list them. Missing, duplicate, or unknown compact rows in the produced report are blocking. Missing applicable evidence, missed applicable design controls, or incomplete exceptions are `No` / `blocked`; `N/A` rows require evidence and justification in the report. |
| Source-row contract | When corporate source-row validation applies, expand the authoritative catalog inventory and materialize all 155 expected Source IDs exactly once in `review-security-report.md`. Validate each row against narrative `design.md#secure-development-design`, omitted-category analysis, `test-design.md`, completed tasks/apply evidence, changed-file context, and `review-report.md`. Rows MUST cite corporate section, PCI alignment, compact `SEC-*` mappings, applicability/compliance status, lifecycle status, evidence type, evidence location, finding, owner phase, and route. Detailed observations and `N/A` justification belong in focused follow-up sections so the 155-row matrix stays reviewable. A row MUST NOT pass merely because it is listed or because design omitted it. |
| Boundary | Do not replace `sdd-review` and do not duplicate the 96-control matrix. Cite `review-report.md` as supporting evidence only. Do not require design, test-design, apply evidence, verify, archive, or general review artifacts to carry the exhaustive compact-control matrix or exhaustive 155-row Source ID matrix; they may only cite catalog references, summaries, evidence links, warnings, exceptions, or report rows. |
| Active validation | New-change security review parses narrative design rules and validates report rows against artifact evidence directly; it does not require design YAML/schema/matrices, `scripts/validate_security_design.ps1`, or separate standalone security artifacts. |
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
| A new active design attempts to satisfy review-security by embedding YAML, schema fields, compact matrices, Source ID matrices, machine-readable applicability fields, or all-row `N/A` bookkeeping | Treat it as stale/legacy-shaped evidence; route upstream contract repair to `apply` or `resolve-blockers` unless it is explicitly historical compatibility data. |
| Proposal, specs, changed files, apply evidence, test-design, or review evidence show an omitted compact control or Source ID was applicable | Persist a blocking report, mark the row as missed applicable control with `No` / `blocked`, and return `next_recommended: apply` when remediation is file, prompt, contract, or task evidence work; otherwise route to `resolve-blockers`. |
| The produced compact-control matrix omits, duplicates, or invents compact guideline IDs | Persist no passing report; return `blocked` with `next_recommended: resolve-blockers` because `review-security-report.md` failed exhaustive compact materialization. |
| Source-row coverage has missing, duplicate, or unknown Source IDs | Persist no passing report; return `blocked` with `next_recommended: resolve-blockers` because the source-row inventory or report shape must be repaired. |
| A source row has malformed schema, unsupported allowed values, or missing/unknown compact `SEC-*` mappings | Persist no passing report; return `blocked` with `next_recommended: resolve-blockers`. |
| Source-row evidence contains secrets, credentials, PAN, PII, tokens, connection strings, private keys, or confidential values | Reject the evidence, persist no passing report, and return `blocked` with `next_recommended: resolve-blockers` unless remediation is implementation work. |
| Another active artifact is treated as the owner of the exhaustive 155-row Source ID matrix | Treat that ownership as a contract violation; keep the full matrix in `review-security-report.md` only and route upstream contract repair to `resolve-blockers` when the boundary is ambiguous. |
| Applicable mandatory guideline lacks implementation evidence and lacks a complete approved exception | Persist a blocking report, mark the row `No` and `blocked`, and return `next_recommended: apply`. |
| Applicable source row lacks corroborating implementation/apply/changed-file evidence | Persist a blocking report, mark the row `No` and `blocker`, and return `next_recommended: apply` when remediation is file, prompt, or contract work. |
| N/A row lacks rationale/evidence proving irrelevance | Persist a blocking report and return `next_recommended: resolve-blockers` unless implementation remediation is required. |
| Approved exception is incomplete | Mark blocking and return `next_recommended: apply` or `resolve-blockers`. |
| Only non-blocking warnings exist | Persist `PASS WITH WARNINGS` and return `next_recommended: verify`. |

## Source-Row Review Rules

Use the source-row layer as operational security evidence below the compact `SEC-*` layer. Do not promote Source IDs into new compact controls.

| Rule | Requirement |
| --- | --- |
| Report-only compact expansion | Expand the catalog compact guideline set during review-security and write every compact guideline exactly once in `review-security-report.md`. Design/test-design may remain narrative and MUST NOT be repaired by copying an exhaustive compact matrix into those artifacts. |
| Omission validation | Treat omitted design controls as reviewable decisions. Correlate proposal/specs/changed files/apply/test-design/review evidence to decide whether the omitted compact guideline or Source ID is truly irrelevant. Missed applicable omissions are blockers. |
| Exact-once coverage | Expand catalog ranges before validation and require all 155 expected Source IDs exactly once in `review-security-report.md`. Missing, duplicate, or unknown IDs are blockers routed to `resolve-blockers`. |
| Evidence correlation | Compare each row to narrative design expectations, test-design checks, completed tasks/apply evidence, changed files, and relevant `review-report.md` citations. A listed-only row fails. |
| Compact mapping | Each row must map to one or more known compact IDs: `SEC-AUTH-001`, `SEC-SESS-001`, `SEC-DATA-001`, `SEC-SECRET-001`, `SEC-ACCESS-001`, `SEC-FILE-001`, `SEC-DB-001`, or `SEC-LOG-001`. Missing or unknown mappings route to `resolve-blockers`. |
| PCI alignment | Each row must preserve the PCI alignment inherited from its catalog corporate section, or `N/A` when the catalog section has no PCI alignment. |
| Reviewable table shape | Keep the main 155-row matrix compact. Use the matrix for exact-once coverage and status, then add focused sections for blockers, warnings, `N/A` justifications, missing evidence, unsafe evidence rejections, and warning carry-forward. |
| Matrix ownership | `review-security-report.md` is the only produced artifact that may contain the exhaustive 155-row Source ID matrix. Other phase artifacts may provide catalog refs, summaries, and evidence links only. |
| Safe evidence | Evidence locations, summaries, and detail sections cite paths, section refs, changed-file refs, command summaries, sanitized summaries, or redacted placeholders only. Unsafe evidence routes to `resolve-blockers` unless implementation remediation is required. |
| Evidence typing | Each row must classify evidence as `implementation-reference`, `static-inspection`, `test-evidence`, `approved-exception`, or `n/a-evidence` so reviewers can distinguish proof from rationale. |
| N/A evidence | `N/A` rows require evidence and `naJustification` proving irrelevance by category, platform, API, data class, or workflow. Unsupported `N/A` routes to `resolve-blockers`. |
| Owner phase | Each row must state the owner phase responsible for remediation or carry-forward: `design`, `test-design`, `tasks`, `apply`, `review`, `review-security`, `verify`, or `archive`. |
| Implementation gaps | Applicable rows that lack implementation evidence route to `apply` when the fix is code, skill, prompt, contract, or task evidence work. |
| Warnings-only progression | Warning rows may proceed to `verify` only when mandatory source-row evidence is complete, safe, mapped, and non-blocking. |

## Execution Steps

1. Load supplemental skills via shared SDD Section A.
2. Resolve and read mandatory inputs from the selected backend or `contextFiles`.
3. Confirm `design.md#secure-development-design` exists before evaluating evidence. If it is missing, stop with a blocking result and route to `resolve-blockers`.
4. Confirm `review-report.md` is non-blocking and cite its verdict, blocking summary, and relevant evidence without copying its full matrix.
5. Parse narrative `design.md#secure-development-design` changed-surface classification, applicable category rules, evidence expectations, exceptions, carried risks, and archive gates; do not require or expect design YAML/schema/matrix fields.
6. Expand the complete compact guideline catalog, compare it with narrative design and changed-file evidence, and materialize every compact guideline exactly once in `review-security-report.md`; report omitted rows as `N/A`, `No`, or missed-applicable blockers based on corroborated evidence.
7. When source-row validation applies, build the expected expanded Source ID universe from the catalog operational inventory, confirm the expected count is 155, then materialize and validate that exact universe in `review-security-report.md` with known compact mappings and allowed schema values.
8. Compare compact and source rows against changed files, tasks/apply evidence, test-design coverage, and general review handoff evidence. Mark applicable mandatory rows with missing implementation evidence or incomplete exceptions as `No` and lifecycle `blocked`; mark missed applicable omitted controls as blockers; mark source rows with missing corroboration as `blocker`; justify every `N/A` row with evidence proving irrelevance.
9. Produce `review-security-report.md` with report metadata, verdict, compact row validation matrix, the only exhaustive source-row validation matrix when applicable, implementation evidence, focused findings sections, safe observations, blockers/non-blockers, exceptions, unavailable tooling when relevant, and artifact metadata `nextRecommended: verify|apply|resolve-blockers`.
10. Validate report shape, compact exact-once coverage, source-row exact-once coverage, PCI alignment preservation, guideline refs, evidence types, owner phases, applies/complies/lifecycle consistency, omission decisions, safe evidence, vocabulary, complete N/A rationale, complete exception fields, and routing consistency. Do not invoke or require `scripts/validate_security_design.ps1` for this validation.
11. Persist and read back the report before returning.

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
sourceRowExpectedCount: 155
sourceRowMatrixOwner: review-security-report.md
nextRecommended: verify | apply | resolve-blockers
```

## Summary

{Verdict, narrative secure-design rules parsed, blockers/non-blockers, and evidence constraints.}

## Security Row Validation

This section is report-only exhaustive compact materialization. It validates all catalog compact controls exactly once; design/test-design remain narrative inputs and MUST NOT be expanded to match this table.

| Guideline ID | Category | Design Applies | Lifecycle Status | Complies | Evidence Location | Observations | Finding |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SEC-...` | `category` | Yes/No/N/A | `implemented`/... | Yes/No/N/A | `path#section` | Safe summary | None/blocking/warning |

## Corporate Source Row Validation

Expected Source ID count: `155`. This section is the only active new-change artifact that materializes the exhaustive Source ID matrix; every expected Source ID from the catalog MUST appear exactly once.

| Source ID | Corporate Section | PCI Alignment | Guideline Ref | Compact Mapping | Applies | Complies | Lifecycle Status | Evidence Type | Evidence Location | Finding | Owner Phase | Route |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `1.1` | `1. Authentication` | `PCI Req 6.5.8, 6.5.10` | `skills/_shared/security-guideline-catalog.md#full-corporate-guideline-snapshot (Source ID 1.1)` | `SEC-AUTH-001` | Yes/No/N/A | Yes/No/N/A | `implemented`/... | `implementation-reference`/... | `path#section` | none/blocker/warning | apply/review-security/verify | verify/apply/resolve-blockers |

The source-row matrix is security-specific and bounded to the corporate Source ID inventory. It MUST NOT copy the general 96-control `sdd-review` matrix, and other phase artifacts MUST NOT copy this exhaustive 155-row matrix.

## Source Row Findings

Group actionable source-row findings instead of burying them inside the 155-row matrix.

### Blockers

{Rows with `Finding = blocker`, grouped by route and owner phase. Include safe evidence and required action. Use "None" when empty.}

### Warnings

{Rows with `Finding = warning`, grouped by risk and carry-forward owner. Use "None" when empty.}

### N/A Justifications

{Every row with `Applies = N/A` or `Complies = N/A` must appear here with Source ID, evidence location, and `naJustification` proving irrelevance by category, platform, API, data class, or workflow. Use "None" only when there are no `N/A` rows.}

### Missing Evidence Rows

{Applicable rows missing required implementation, test, review, exception, or verification evidence. Include owner phase and route. Use "None" when empty.}

### Unsafe Evidence Rejections

{Rows where evidence was rejected because it exposed or attempted to expose secrets, credentials, PAN, PII, tokens, connection strings, private keys, or confidential values. Use "None" when empty.}

### Warning Carry-Forward

{Non-blocking source-row warnings that must remain visible to `sdd-verify` and archive, with report links and owner phase. Use "None" when empty.}

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
- Missed applicable controls discovered from narrative design omissions -> return phase envelope `next_recommended: apply` when remediation is implementation, skill, prompt, contract, or task evidence work; otherwise `resolve-blockers`.
- Missing/duplicate/unknown Source IDs, malformed source-row schema, missing mappings, missing PCI alignment, invalid evidence type, invalid owner phase, unsafe evidence, invalid applies/complies/lifecycle combination, or unsupported `N/A` -> return phase envelope `status: blocked` and `next_recommended: resolve-blockers`.
- Applicable source rows missing implementation evidence -> return phase envelope `next_recommended: apply` when remediation is file, prompt, contract, or task evidence work.
- Warnings-only source-row findings with complete mandatory evidence -> return phase envelope `next_recommended: verify`.
- Persistence failure after producing a useful report -> return phase envelope `status: partial` with `next_recommended: resolve-blockers` and include the report in `detailed_report` when safe.
- Do not return camelCase `nextRecommended` from the phase envelope. CamelCase is for artifact/status/state metadata only.

## Rules

- ALWAYS run after non-blocking `sdd-review` and before `sdd-verify` for new changes.
- ALWAYS require narrative `design.md#secure-development-design`; no-impact rationale is prose, while report-level `N/A` rows are produced and justified by review-security.
- Validate new-change security evidence through narrative design rules, catalog vocabulary, and artifact evidence; do not require design YAML/schema/matrices, `scripts/validate_security_design.ps1`, or standalone security artifacts.
- For new narrative designs, expand all compact controls in `review-security-report.md`, validate omitted compact categories against proposal/specs/changed files/apply/test-design/review evidence, and block missed applicable omissions.
- For corporate source-row changes, validate every expanded Source ID exactly once against design, test-design, apply evidence, changed files, and `review-report.md` citations.
- For corporate source-row changes, materialize all 155 expected Source IDs exactly once in `review-security-report.md` and nowhere else in the active new-change artifact set.
- NEVER require design or test-design to materialize all compact controls, all Source IDs, or all N/A rows for new narrative changes.
- Source-row rows must be corroborated by safe evidence; row presence alone is not compliance evidence.
- Source-row rows must preserve PCI alignment, guideline refs, evidence type, owner phase, and applies/complies/lifecycle consistency so reviewers can audit quickly without reconstructing the catalog.
- NEVER duplicate the full 96-control general review matrix.
- NEVER print raw secrets, credentials, PAN, PII, or unnecessary confidential values in evidence.
- Missing runtime tooling must be reported as unavailable, not passed.
- Return `next_recommended: verify` only for non-blocking security review verdicts.

## References

- `../_shared/sdd-phase-common.md` — skill loading, retrieval, persistence, and return envelope.
- `../_shared/persistence-contract.md` — artifact keys, backend behavior, hybrid conflict policy, and read-back verification.
- `../_shared/security-guideline-catalog.md` — compact SEC guideline IDs, taxonomy, vocabulary, and safe-evidence rules.
- `../_shared/sdd-security-contract.md` — narrative secure-design and review-security report schema contracts.
