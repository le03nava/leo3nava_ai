# Review Security Report Template

`sdd-review-security` writes this artifact to `openspec/changes/{change-name}/review-security-report.md` in OpenSpec mode or to `sdd/{change-name}/review-security` in Engram/hybrid mode.

## Required Structure

````markdown
# Review Security Report: {Change Title}

```yaml
schemaName: sdd.review-security-report
schemaVersion: 1
changeName: {change-name}
verdict: PASS | PASS WITH WARNINGS | FAIL
sourceSecureDesign: {path-or-topic}#secure-development-design
sourceReviewReport: {path-or-topic}
sourceRowExpectedCount: 155
sourceRowValidatedCount: 155
sourceRowCoverage: complete | incomplete
catalogOperationalSource: skills/sdd-review-security/references/security-guideline-catalog.operational.json
catalogHumanSnapshot: skills/sdd-review-security/references/security-guideline-catalog.md
sourceRowReportMode: summary | full-matrix
sourceRowFullMatrix: omitted-audit-only | included
sourceRowMatrixOwner: review-security-report.md when sourceRowReportMode=full-matrix
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

Expected Source ID count: `155`. Security review MUST validate every expected Source ID exactly once. The default report shape is summary mode: prove full validation coverage without printing the full 155-row matrix. Use full-matrix mode only when an explicit audit/export requires every row inline.

### Coverage Summary

| Corporate Section | Expected | Validated | Blockers | Warnings | N/A | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `1. Authentication` | 10 | 10 | 0 | 0 | 10 | Safe summary |

### Focused Source Row Details

Include rows that need reviewer attention: blockers, warnings, approved exceptions, missing evidence, unsafe evidence rejections, and `N/A` decisions requiring explicit justification. Do not bury actionable findings in a full table.

| Source ID | Corporate Section | PCI Alignment | Guideline Ref | Compact Mapping | Applies | Complies | Lifecycle Status | Evidence Type | Evidence Location | Finding | Owner Phase | Route |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `1.1` | `1. Authentication` | `PCI Req 6.5.8, 6.5.10` | `skills/sdd-review-security/references/security-guideline-catalog.md#full-corporate-guideline-snapshot (Source ID 1.1)` | `SEC-AUTH-001` | Yes/No/N/A | Yes/No/N/A | `implemented`/... | `implementation-reference`/... | `path#section` | none/blocker/warning | apply/review-security/verify | verify/apply/resolve-blockers |

### Full Source Row Matrix — Audit Mode Only

When `sourceRowReportMode: full-matrix`, include every expected Source ID exactly once using the same columns as Focused Source Row Details. Otherwise state: `Omitted in summary mode; sourceRowValidatedCount proves complete validation coverage.`

The source-row validation is security-specific and bounded to the corporate Source ID inventory. It MUST NOT copy the general 96-control `sdd-review` matrix, and other phase artifacts MUST NOT copy the full 155-row matrix.

## Source Row Findings

Group actionable source-row findings instead of burying them inside the 155-row matrix.

### Blockers

{Rows with `Finding = blocker`, grouped by route and owner phase. Include safe evidence and required action. Use "None" when empty.}

### Warnings

{Rows with `Finding = warning`, grouped by risk and carry-forward owner. Use "None" when empty.}

### N/A Justifications

{Every `N/A` decision must be justified. In summary mode, rows with the same rationale MAY be grouped by corporate section, Source ID range/list, category, platform, API, data class, or workflow, with expected/validated counts and one safe evidence location. In full-matrix mode, every `N/A` row must appear individually. Use "None" only when there are no `N/A` decisions.}

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

## Matrix Rules

- Validate every compact guideline from `references/security-guideline-catalog.operational.json` exactly once in `## Security Row Validation`.
- When corporate source-row validation applies, validate every expected Source ID from `references/security-guideline-catalog.operational.json` exactly once and report `sourceRowExpectedCount`, `sourceRowValidatedCount`, and `sourceRowCoverage`.
- In summary mode, include section-level coverage plus focused source-row details only for rows that need review attention.
- In full-matrix mode, include every expected Source ID exactly once.
- `Applies` and `Complies` values are limited to `Yes`, `No`, or `N/A` unless the security contract explicitly allows a planning value for a non-report artifact.
- `N/A` decisions require focused justification with evidence proving irrelevance; summary mode may group equivalent decisions, full-matrix mode lists each row individually.
- Evidence must be review-safe: cite paths, sections, summaries, command outcomes, or redacted placeholders only.
