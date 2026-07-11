# Review Report Template

This file is the derived Markdown presentation contract for `sdd-review`. The canonical review artifact is `review-report.json`; `review-report.md` is generated from that JSON and kept for human/downstream compatibility.

`sdd-review` writes canonical JSON to `openspec/changes/{change-name}/review-report.json` in OpenSpec mode or `sdd/{change-name}/review-report.json` in Engram/hybrid mode, then renders this Markdown presentation to `openspec/changes/{change-name}/review-report.md` or `sdd/{change-name}/review`.

Markdown MUST NOT be hand-authored as the source of truth. If JSON and Markdown disagree, JSON wins and Markdown generation/parity must be repaired. Stale Markdown MUST route to `resolve-blockers` and MUST NOT be consumed as current evidence.

## JSON Field Mapping

| Markdown Section | Source JSON Field(s) |
| --- | --- |
| `# Review Report: {Change Title}` | `changeName` |
| `## Verdict` | `changeName`, `verdict`, `blockingFailureCount`, `nonBlockingFindingCount`, `nextRecommended` |
| `## Blocking Summary` | `blockingSummary[]` |
| `## Evidence Summary` | `inputsInspected[]`, `evidenceSummary`, `runtimeChecks`, `sourceCatalogRef`, `sourceCatalogSnapshotId` |
| `## Review Matrix` | `reviewMatrix[]` using only rendered matrix columns from `presentation.matrixColumns` |
| `## Operational Evidence Summary` | `operationalEvidenceSummary` |
| `## Changed-File / Security Handoff` | `changedFileSecurityHandoff` |
| `## Matrix Validation` | `validation`, `presentation` |
| `## Recommendation` | `verdict`, `nextRecommended`, blocking/warning counts |

## Required Structure

```markdown
# Review Report: {Change Title}

## Verdict

| Field | Value |
| --- | --- |
| Change | `{change-name}` |
| Verdict | PASS \| PASS WITH WARNINGS \| FAIL |
| Blocking failures | {count} |
| Non-blocking findings | {count} |
| Next recommendation | review-security \| apply \| resolve-blockers |

## Blocking Summary

| Item | Severity | Affected Requirement | Evidence Location | Required Follow-up |
| --- | --- | --- | --- | --- |
| {Item ID or None} | {Critical/Blocking/High/etc.} | {Spec/task/control reference} | {Path/topic/line/command} | {Action for apply or blocker resolution} |

## Evidence Summary

- Inputs inspected: {proposal/specs/design with secure-development-design/test-design/tasks/apply-progress/changed files; optional legacy security-design/security-applicability only for old/archive compatibility context}.
- Catalog coverage: 96 unique review controls from canonical `skills/sdd-review/references/review-control-catalog.json` snapshot `{sourceCatalogSnapshotId}`.
- Security boundary: review cites security guideline/source IDs where applicable; `design.md#secure-development-design`, `skills/sdd-review-security/references/security-guideline-catalog.operational.json`, and canonical `review-security-report.json` remain authoritative for new changes. Derived `review-security-report.md` / `sdd/{change-name}/review-security` and `skills/sdd-review-security/references/security-guideline-catalog.md` are human/audit compatibility views. Legacy `security-design.md` or `security-applicability.md` may be cited only as optional old/archive compatibility evidence and must not replace embedded secure design or security review evidence.
- Runtime checks: {commands executed or explicit unavailable-runner statement from config}.

## Review Matrix

| Item | Artifact/Deliverable | Requirement | Reviewer | Standard | Severity | Complies | Affected Requirement | Evidence Location | Observations/Comments |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| REV-CORP-001 | {file/artifact} | {catalog requirement summary} | {reviewer} | {corporate checklist standard/security guideline ID when applicable} | {severity} | Yes | {spec/task/design reference} | {path/topic/line/command} | {concise evidence note} |
```

Append these required compatibility sections after the matrix:

```markdown
## Operational Evidence Summary

- Summary: {operationalEvidenceSummary.summary}
- Items: {operationalEvidenceSummary.items or None}

## Changed-File / Security Handoff

- Summary: {changedFileSecurityHandoff.summary}
- Items: {changedFileSecurityHandoff.items or None}

## Matrix Validation

| Check | Result |
| --- | --- |
| Catalog controls | {validation.catalogControlCount}/{validation.expectedControlCount} |
| Unique Item IDs | {validation.uniqueItemIds} |
| Complete Item ID sequence | {validation.completeItemIdSequence} |
| Complete source item sequence | {validation.completeSourceItemSequence} |
| Allowed Complies vocabulary | {validation.allowedCompliesVocabulary} |
| N/A rows have evidence and rationale | {validation.naRowsHaveEvidenceAndRationale} |
| Blocking counts match verdict | {validation.blockingCountsMatchVerdict} |
| Derived Markdown generated | {validation.derivedMarkdownGenerated} |
| Derived Markdown read back | {validation.derivedMarkdownReadBack} |
| Derived Markdown parity | {validation.derivedMarkdownParity} |
| Safe evidence checked | {validation.safeEvidenceChecked} |

## Recommendation

- Next recommendation: `{nextRecommended}`
- Follow-up: {route-specific summary}
```

## Matrix Rules

- The Review Matrix header MUST match exactly and MUST NOT add a Category column.
- Include every catalog Item ID from canonical JSON exactly once: 96 rows total.
- `Complies` MUST be exactly `Yes`, `No`, or `N/A`.
- `N/A` requires both:
  - Evidence Location proving the platform, framework, API, data class, artifact, or workflow is irrelevant.
  - Observations/Comments explaining the scope decision.
- `No` rows with `Critical`, `Blocking`, or explicitly blocking severity MUST make the verdict `FAIL` and route to `apply`.
- Non-blocking `No` rows MAY route to `review-security` only when they are captured in the Evidence Summary as warning evidence and do not hide failed mandatory controls. General review MUST NOT route directly to `verify`.
- Rendered Markdown MUST be read back and compared to `review-report.json` for required sections, exact matrix header, 96 rows, verdict/routing/counts, and key matrix facts.
- Any Markdown generation, persistence, read-back, or JSON parity failure MUST route to `resolve-blockers`; downstream phases must not consume stale Markdown.

## Safe Evidence Rules

- Evidence may cite paths, section anchors, sanitized summaries, and unavailable-tooling statements only.
- Evidence MUST NOT include secrets, credentials, tokens, connection strings, PAN, PII, raw logs, sensitive payloads, production IDs/production identifiers, generated bytes, or final-document-only values.
- Missing runtime/build/lint/type-check/format/coverage tooling is recorded as unavailable evidence, never as passing evidence.
- This template does not define or require Excel, Python, script, spreadsheet, or workbook generation.
