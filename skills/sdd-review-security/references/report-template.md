# Review Security Report Template

This file is the derived Markdown presentation contract for `sdd-review-security`. The canonical security-review artifact is `review-security-report.json`; `review-security-report.md` / `sdd/{change-name}/review-security` is generated from that JSON and kept for human/downstream compatibility.

`sourceRowValidation.rows` in canonical JSON is the only active security matrix. Markdown MUST NOT be hand-authored as the source of truth. If JSON and Markdown disagree, JSON wins and Markdown generation/parity must be repaired. Stale or parity-failed Markdown MUST route to `resolve-blockers` and MUST NOT be consumed as current evidence by `sdd-verify` or `sdd-archive`.

## JSON Field Mapping

| Markdown Section | Source JSON Field(s) |
| --- | --- |
| `# Review Security Report: {Change Title}` | `changeName` |
| `## Verdict` | `changeName`, `status`, `verdict`, `nextRecommended`, `artifactMetadata.canonicalJsonRef` |
| `## Totals` | `totals` |
| `## General Review Reference` | `generalReviewRef` |
| `## Unavailable Tooling` | `unavailableTooling[]` |
| `## Exceptions` | `exceptions[]` |
| `## Artifact Metadata` | `artifactMetadata` |
| `## Security Review Summary` | `rows[]` grouped by catalog `controlDomain` (join by `sourceId`); `totals` |
| `## Recommendation` | `verdict`, `nextRecommended`, `totals.blockers` |
| `## Matrix` | `rows[]` joined with catalog `sourceRows[]` by `sourceId` |

## Required Structure

````markdown
# Review Security Report: {changeName}

## Verdict

| Field | Value |
| --- | --- |
| Change | `{changeName}` |
| Status | success \| blocked \| partial |
| Verdict | PASS \| PASS WITH WARNINGS \| FAIL |
| Next recommendation | verify \| apply \| resolve-blockers |
| JSON authority | `{artifactMetadata.canonicalJsonRef}` |
| Markdown authority | derived compatibility view |

## Totals

| Metric | Value |
| --- | --- |
| Total source rows (155) | `{totals.sourceRowCount}` |
| Validated | `{totals.validated}` |
| Passing | `{totals.passing}` |
| Failing | `{totals.failing}` |
| N/A | `{totals.notApplicable}` |
| Blockers | `{totals.blockers}` |
| Warnings | `{totals.warnings}` |
| Exceptions | `{totals.exceptions}` |

## General Review Reference

- General review JSON: `{generalReviewRef}`
- (Consumed as handoff authority; not re-scored here)

## Unavailable Tooling

{List from `unavailableTooling[]` or "None"}

## Exceptions

| Source ID | Approver | Approved At | Accepted Risk | Mitigation | Evidence Gap |
| --- | --- | --- | --- | --- | --- |
| `{sourceId}` | `{approver}` | `{approvedAt}` | `{acceptedRiskRationale}` | `{mitigationOrFollowUp}` | `{evidenceGap}` |

(or "None")

## Artifact Metadata

| Check | Result |
| --- | --- |
| Canonical JSON ref | `{artifactMetadata.canonicalJsonRef}` |
| Derived Markdown ref | `{artifactMetadata.derivedMarkdownRef}` |
| JSON persisted / read back | `{artifactMetadata.jsonPersisted}` / `{artifactMetadata.jsonReadBack}` |
| Markdown generated / persisted / read back | `{artifactMetadata.markdownGenerated}` / `{artifactMetadata.markdownPersisted}` / `{artifactMetadata.markdownReadBack}` |
| JSON/Markdown parity | `{artifactMetadata.parityStatus}` |
| JSON authority | canonical |
| Markdown authority | derived |

## Security Review Summary

Summary by control domain. Derived from `rows[]` joined with catalog `controlDomain` by `sourceId`. Passing = rows where `complies: Yes` or `lifecycleStatus: not-applicable` or `lifecycleStatus: exception-approved`. Blockers = rows where `finding: blocker`.

| Control Domain | Passing/Total | Blockers |
| --- | --- | --- |
| authorization-access-control | `{N}/{total}` | `{count or 0}` |
| credential-secrets | `{N}/{total}` | `{count or 0}` |
| cryptography-data-protection | `{N}/{total}` | `{count or 0}` |
| database-access | `{N}/{total}` | `{count or 0}` |
| file-handling | `{N}/{total}` | `{count or 0}` |
| identity-authentication | `{N}/{total}` | `{count or 0}` |
| input-validation | `{N}/{total}` | `{count or 0}` |
| memory-safety | `{N}/{total}` | `{count or 0}` |
| observability-logging | `{N}/{total}` | `{count or 0}` |
| output-encoding | `{N}/{total}` | `{count or 0}` |
| pan-test-data | `{N}/{total}` | `{count or 0}` |
| safe-error-handling | `{N}/{total}` | `{count or 0}` |
| secure-coding | `{N}/{total}` | `{count or 0}` |
| sensitive-data-protection | `{N}/{total}` | `{count or 0}` |
| session-management | `{N}/{total}` | `{count or 0}` |

**Overall**: `{totals.passing}/{totals.sourceRowCount}` passing · `{totals.blockers}` blockers · `{totals.warnings}` warnings · `{totals.exceptions}` exceptions

## Recommendation

- Next: `{nextRecommended}`
- {route-specific follow-up text}

## Matrix

Full 155-row table rendered last. Join `rows[].sourceId` with catalog `sourceRows[].sourceId` to get Corporate Section, Control Domain, PCI Alignment, Guideline, and Applies When columns.

| Source ID | Corporate Section | Control Domain | PCI Alignment | Guideline | Applies When | Applies | Complies | Lifecycle Status | Evidence Type | Evidence Location | Justification | Finding | Owner Phase | Route |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `{sourceId}` | `{catalog join}` | `{catalog join}` | `{catalog join}` | `{catalog join}` | `{catalog join}` | Yes/No/N/A | Yes/No/N/A | `{lifecycleStatus}` | `{evidenceType}` | `{evidenceLocation}` | `{justification}` | none/blocker/warning | `{ownerPhase}` | `{route}` |
````

## Matrix Rules

- Table header must match exactly; 155 rows required, all source IDs exactly once
- `applies` and `complies` must be Yes, No, or N/A
- N/A rows require non-empty justification and evidenceLocation
- Rows with `finding=blocker` make verdict FAIL unless `lifecycleStatus=exception-approved`
- Rendered Markdown must be read back and compared to JSON for verdict/routing/counts and source-row coverage

## Safe Evidence Rules

- Evidence may cite paths, section anchors, sanitized summaries, command outcomes, and redacted placeholders only
- Must not include secrets, credentials, tokens, connection strings, PAN, PII, raw logs, sensitive payloads, production identifiers, generated bytes, or final-document-only values
- Missing runtime tooling is recorded in `unavailableTooling[]`, never as passing evidence
