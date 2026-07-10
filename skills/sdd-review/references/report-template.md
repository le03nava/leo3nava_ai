# Review Report Template

`sdd-review` writes this artifact to `openspec/changes/{change-name}/review-report.md` in OpenSpec mode or to `sdd/{change-name}/review` in Engram/hybrid mode.

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
- Catalog coverage: 96 unique review controls from `skills/sdd-review/references/control-catalog.md`.
- Security boundary: review cites security guideline/source IDs where applicable; `design.md#secure-development-design`, `skills/sdd-review-security/references/security-guideline-catalog.operational.json`, and `review-security-report.md` remain authoritative for new changes. `skills/sdd-review-security/references/security-guideline-catalog.md` is the derived human/audit catalog view. Legacy `security-design.md` or `security-applicability.md` may be cited only as optional old/archive compatibility evidence and must not replace embedded secure design or security review evidence.
- Runtime checks: {commands executed or explicit unavailable-runner statement from config}.

## Review Matrix

| Item | Artifact/Deliverable | Requirement | Reviewer | Standard | Severity | Complies | Affected Requirement | Evidence Location | Observations/Comments |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| REV-CORP-001 | {file/artifact} | {catalog requirement summary} | {reviewer} | {corporate checklist standard/security guideline ID when applicable} | {severity} | Yes | {spec/task/design reference} | {path/topic/line/command} | {concise evidence note} |
```

## Matrix Rules

- The Review Matrix header MUST match exactly and MUST NOT add a Category column.
- Include every catalog Item ID exactly once: 96 rows total.
- `Complies` MUST be exactly `Yes`, `No`, or `N/A`.
- `N/A` requires both:
  - Evidence Location proving the platform, framework, API, data class, artifact, or workflow is irrelevant.
  - Observations/Comments explaining the scope decision.
- `No` rows with `Critical`, `Blocking`, or explicitly blocking severity MUST make the verdict `FAIL` and route to `apply`.
- Non-blocking `No` rows MAY route to `review-security` only when they are captured in the Evidence Summary as warning evidence and do not hide failed mandatory controls. General review MUST NOT route directly to `verify`.
