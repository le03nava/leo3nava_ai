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
| `1.1` | `1. Authentication` | `PCI Req 6.5.8, 6.5.10` | `skills/sdd-review-security/references/security-guideline-catalog.md#full-corporate-guideline-snapshot (Source ID 1.1)` | `SEC-AUTH-001` | Yes/No/N/A | Yes/No/N/A | `implemented`/... | `implementation-reference`/... | `path#section` | none/blocker/warning | apply/review-security/verify | verify/apply/resolve-blockers |

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

## Matrix Rules

- Expand every compact guideline from `references/security-guideline-catalog.md` exactly once in `## Security Row Validation`.
- When corporate source-row validation applies, expand every expected Source ID from `references/security-guideline-catalog.md` exactly once in `## Corporate Source Row Validation`.
- `Applies` and `Complies` values are limited to `Yes`, `No`, or `N/A` unless the security contract explicitly allows a planning value for a non-report artifact.
- `N/A` rows require focused justification with evidence proving irrelevance.
- Evidence must be review-safe: cite paths, sections, summaries, command outcomes, or redacted placeholders only.
