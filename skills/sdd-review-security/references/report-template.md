# Review Security Report Template

This file is the derived Markdown presentation contract for `sdd-review-security`. The canonical security-review artifact is `review-security-report.json`; `review-security-report.md` / `sdd/{change-name}/review-security` is generated from that JSON and kept for human/downstream compatibility.

`sdd-review-security` writes canonical JSON to `openspec/changes/{change-name}/review-security-report.json` in OpenSpec mode or `sdd/{change-name}/review-security-report.json` in Engram/hybrid mode, then renders this Markdown presentation to `openspec/changes/{change-name}/review-security-report.md` or `sdd/{change-name}/review-security`.

Markdown MUST NOT be hand-authored as the source of truth. If JSON and Markdown disagree, JSON wins and Markdown generation/parity must be repaired. Stale or parity-failed Markdown MUST route to `resolve-blockers` and MUST NOT be consumed as current evidence by `sdd-verify` or `sdd-archive`.

## JSON Field Mapping

| Markdown Section | Source JSON Field(s) |
| --- | --- |
| `# Review Security Report: {Change Title}` | `changeName` |
| `## Verdict` | `changeName`, `status`, `verdict`, `blockerCount`, `warningCount`, `nextRecommended` |
| `## Source References` | `sourceRefs`, `catalogRefs` |
| `## General Review Handoff` | `generalReviewHandoff` |
| `## Compact Control Validation` | `compactControlValidation` |
| `## Corporate Source Row Validation` | `sourceRowValidation` |
| `## Source Row Findings` | `blockers[]`, `warnings[]`, `unsafeEvidenceRejections[]`, `warningCarryForward[]` |
| `## Exceptions` | `exceptions[]` |
| `## Unavailable Tooling` | `unavailableTooling[]` |
| `## Artifact Metadata` | `artifactMetadata` |
| `## Recommendation` | `verdict`, `nextRecommended`, blockers/warnings |

## Required Structure

````markdown
# Review Security Report: {Change Title}

## Verdict

| Field | Value |
| --- | --- |
| Change | `{change-name}` |
| Status | success \| blocked \| partial |
| Verdict | PASS \| PASS WITH WARNINGS \| FAIL |
| Blocking findings | {blockerCount} |
| Non-blocking warnings | {warningCount} |
| Next recommendation | verify \| apply \| resolve-blockers |
| JSON authority | `{review-security-report.json ref}` |
| Markdown authority | derived compatibility view |

## Source References

- Secure design: `{sourceRefs.secureDesign}`
- Test design: `{sourceRefs.testDesign}`
- Tasks/apply evidence: `{sourceRefs.tasks}`, `{sourceRefs.applyProgress}`
- Changed-file context: `{sourceRefs.changedFiles}`
- General review JSON: `{generalReviewHandoff.canonicalJsonRef}`
- General review Markdown compatibility: `{generalReviewHandoff.derivedMarkdownRef}`
- Catalog JSON: `{catalogRefs.operationalJson}` snapshot `{catalogRefs.snapshotId}`
- Catalog human view: `{catalogRefs.humanMarkdown}`

## General Review Handoff

{Render `generalReviewHandoff` verdict, non-blocking state, relevant security/operational handoff summaries, and source refs only. Do not duplicate or re-score the 96-control general review matrix. Canonical `review-report.json` is authoritative; Markdown is compatibility only.}

## Compact Control Validation

| Guideline ID | Category | Design Applies | Lifecycle Status | Complies | Evidence Location | Observations | Finding |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SEC-...` | `category` | Yes/No/N/A | `implemented`/... | Yes/No/N/A | `path#section` | Safe summary | none/blocker/warning |

## Corporate Source Row Validation

Expected Source ID count: `{sourceRowValidation.expectedCount}`. Validated Source ID count: `{sourceRowValidation.validatedCount}`. Coverage: `{sourceRowValidation.coverageStatus}`. Security review MUST validate every expected Source ID exactly once. The default report shape is summary mode: prove full validation coverage without printing the full 155-row matrix. Use full-matrix mode only when an explicit audit/export requires every row inline.

### Coverage Summary

| Corporate Section | Expected | Validated | Blockers | Warnings | N/A | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `1. Authentication` | 10 | 10 | 0 | 0 | 10 | Safe summary |

### Focused Source Row Details

Include rows that need reviewer attention: blockers, warnings, approved exceptions, missing evidence, unsafe evidence rejections, and `N/A` decisions requiring explicit justification. Do not bury actionable findings in a full table.

| Source ID | Corporate Section | PCI Alignment | Guideline Ref | Compact Mapping | Applies | Complies | Lifecycle Status | Evidence Type | Evidence Location | Finding | Owner Phase | Route |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `1.1` | `1. Authentication` | `PCI Req 6.5.8, 6.5.10` | `skills/sdd-review-security/references/security-guideline-catalog.operational.json#sourceRows (Source ID 1.1); human view: skills/sdd-review-security/references/security-guideline-catalog.md#full-corporate-guideline-snapshot` | `SEC-AUTH-001` | Yes/No/N/A | Yes/No/N/A | `implemented`/... | `implementation-reference`/... | `path#section` | none/blocker/warning | apply/review-security/verify | verify/apply/resolve-blockers |

### Full Source Row Matrix — Audit Mode Only

When `sourceRowValidation.reportMode: full-matrix`, include every expected Source ID exactly once using the same columns as Focused Source Row Details. Otherwise state: `Omitted in summary mode; sourceRowValidation.validatedCount proves complete validation coverage.`

The source-row validation is security-specific and bounded to the corporate Source ID inventory. It MUST NOT copy the general 96-control `sdd-review` matrix, and other phase artifacts MUST NOT copy the full 155-row matrix.

## Source Row Findings

### Blockers

{Rows with `finding = blocker`, grouped by route and owner phase. Include safe evidence and required action. Use "None" when empty.}

### Warnings

{Rows with `finding = warning`, grouped by risk and carry-forward owner. Use "None" when empty.}

### N/A Justifications

{Every `N/A` decision must be justified. In summary mode, rows with the same rationale MAY be grouped by corporate section, Source ID range/list, category, platform, API, data class, or workflow, with expected/validated counts and one safe evidence location. In full-matrix mode, every `N/A` row must appear individually. Use "None" only when there are no `N/A` decisions.}

### Missing Evidence Rows

{Applicable rows missing required implementation, test, review, exception, or verification evidence. Include owner phase and route. Use "None" when empty.}

### Unsafe Evidence Rejections

{Rows where evidence was rejected because it exposed or attempted to expose secrets, credentials, PAN, PII, tokens, connection strings, private keys, or confidential values. Use "None" when empty.}

### Warning Carry-Forward

{Non-blocking source-row warnings that must remain visible to `sdd-verify` and archive, with report links and owner phase. Use "None" when empty.}

## Exceptions

{Complete approved exceptions or "None".}

## Blockers and Non-Blocking Findings

{Grouped findings with guideline IDs, owner, route, and safe evidence.}

## Unavailable Tooling

{Runtime test/lint/type/format/coverage unavailable evidence when applicable; missing tools are not passing evidence.}

## Artifact Metadata

| Check | Result |
| --- | --- |
| Canonical JSON ref | `{artifactMetadata.canonicalJsonRef}` |
| Derived Markdown ref | `{artifactMetadata.derivedMarkdownRef}` |
| JSON persisted/read back | `{artifactMetadata.jsonPersisted}` / `{artifactMetadata.jsonReadBack}` |
| Markdown generated/read back | `{artifactMetadata.markdownGenerated}` / `{artifactMetadata.markdownReadBack}` |
| JSON/Markdown parity | `{artifactMetadata.parityStatus}` |
| JSON authority | canonical |
| Markdown authority | derived |

## Recommendation

- Next recommendation: `{nextRecommended}`
- Follow-up: {route-specific summary}
````

## Matrix Rules

- Validate every compact guideline from `references/security-guideline-catalog.operational.json` exactly once in canonical JSON and render compact validation summaries from JSON.
- When corporate source-row validation applies, validate every expected Source ID from `references/security-guideline-catalog.operational.json` exactly once and record `sourceRowValidation.expectedCount`, `sourceRowValidation.validatedCount`, and `sourceRowValidation.coverageStatus` in JSON.
- In summary mode, include section-level coverage plus focused source-row details only for rows that need review attention. Do not print the full 155-row matrix in summary mode.
- In full-matrix mode, include every expected Source ID exactly once.
- `Applies` and `Complies` values are limited to `Yes`, `No`, or `N/A` unless the security contract explicitly allows a planning value for a non-report artifact.
- `N/A` decisions require focused justification with evidence proving irrelevance; summary mode may group equivalent decisions, full-matrix mode lists each row individually.
- Evidence must be review-safe: cite paths, sections, summaries, command outcomes, or redacted placeholders only.
- Rendered Markdown MUST be read back and compared to `review-security-report.json` for required sections, verdict/routing/counts, source-row coverage counts, blocker/warning counts, and artifact parity metadata.
- Any Markdown generation, persistence, read-back, or JSON parity failure MUST route to `resolve-blockers`; downstream phases must not consume stale Markdown.
