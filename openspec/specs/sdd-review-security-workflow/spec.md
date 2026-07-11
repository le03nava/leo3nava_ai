# sdd-review-security-workflow Specification

## Purpose

Define the mandatory post-review security evidence gate that parses narrative secure design and exhaustively validates compact controls and corporate Source IDs before verification, while reporting source-row evidence in summary mode by default and full-matrix mode only when explicitly requested for audit.

## Requirements

### Requirement: Mandatory Security Review Gate

The SDD workflow MUST run `sdd-review-security` after non-blocking `sdd-review` and before `sdd-verify` for every new change.

#### Scenario: General review routes to security review

- GIVEN canonical `review-report.json` has no blocking findings and derived `review-report.md` is readable or not required by the selected backend
- WHEN routing is computed
- THEN the next required phase MUST be `sdd-review-security`
- AND `sdd-verify` MUST remain blocked until security review evidence exists.

#### Scenario: General review is blocking

- GIVEN `sdd-review` reports blocking findings
- WHEN routing is computed
- THEN `sdd-review-security` MUST NOT run
- AND the workflow MUST route back to `sdd-apply` or `resolve-blockers`.

### Requirement: Security Review Artifact

`sdd-review-security` MUST persist canonical `review-security-report.json` as the source of truth and derived `review-security-report.md` / `sdd/{change-name}/review-security` as a compatibility view generated from that JSON. The canonical JSON MUST own the machine-readable schema, exhaustive compact and Source ID validation results, `Yes`/`No`/`N/A` decisions, evidence, blockers, exceptions, missed-category validation, coverage metadata, artifact parity/read-back metadata, and next recommendation. It MAY parse narrative category rules from design, but MUST NOT require design YAML, schema, matrices, or machine-readable fields. Source-row validation MUST cover all expected Source IDs; full 155-row materialization is required only when audit/full-matrix mode is explicitly requested.

#### Scenario: Report is persisted

- GIVEN `design.md` and canonical `review-report.json` are readable
- WHEN security review completes
- THEN `review-security-report.json` MUST be written and read back first
- AND derived `review-security-report.md` MUST be generated from JSON, written, read back, and parity-checked
- AND both artifacts MUST state the same verdict, with JSON authoritative on conflict.

#### Scenario: Embedded secure design is required

- GIVEN a new change lacks `design.md#secure-development-design`
- WHEN security review evaluates readiness
- THEN it MUST block with missing embedded design evidence
- AND verify/archive MUST remain unavailable.

### Requirement: Security Matrix Validation

Security review MUST expand the full compact security catalog and validate every compact control and Source ID using `Yes`, `No`, or `N/A`, evidence, observations, and lifecycle status. It MUST decide/report non-applicable rows, compare validation results against narrative design rules, validate missed categories, and block applicable omissions. The report MAY summarize validated Source IDs by section unless audit/full-matrix mode is requested.

#### Scenario: Mandatory evidence is missing

- GIVEN an applicable mandatory guideline lacks implementation evidence or approved exception
- WHEN security review validates the matrix
- THEN the report MUST mark the row `No` and `blocked`
- AND verify/archive MUST be blocked.

#### Scenario: Not applicable row is justified

- GIVEN security review marks a guideline or Source ID `N/A`
- WHEN it validates the row
- THEN evidence MUST prove irrelevance
- AND observations MUST explain the scope decision.

#### Scenario: Design omitted an applicable control

- GIVEN proposal, specs, changed files, or evidence show a category applies
- WHEN design did not include that category/control
- THEN security review MUST report a missed applicable control
- AND the verdict MUST be blocking.

### Requirement: Boundary with General Review

Security review MUST NOT replace `sdd-review` or duplicate the 96-control matrix. It MUST focus on security guideline evidence and MAY cite general review findings as supporting evidence.

#### Scenario: General review evidence is reused

- GIVEN a review row supports a security guideline
- WHEN security review records evidence
- THEN it MAY cite that review row
- AND it MUST keep the security verdict in canonical `review-security-report.json`.

### Requirement: Exhaustive Source Row Security Review

`sdd-review-security` MUST be the only active phase that validates the exhaustive corporate source-row universe for a new change. It MUST expand every expected Source ID exactly once and validate rows against catalog inventory, narrative design rules, `test-design.md`, apply evidence, changed files, and canonical `review-report.json`. By default, it MUST write coverage metadata, section-level summaries, focused findings, `N/A` justifications, warnings, exceptions, and blockers in canonical `review-security-report.json` and render Markdown summaries from JSON without duplicating the 96-control matrix. It MUST write the full 155-row matrix only when audit/full-matrix mode is explicitly requested.

#### Scenario: Complete validation is summarized

- GIVEN design, test-design, apply evidence, changed files, and review report are readable
- WHEN security review succeeds
- THEN canonical `review-security-report.json` MUST state `sourceRowExpectedCount`, `sourceRowValidatedCount`, coverage status, catalog snapshot, and section-level coverage
- AND focused details MUST include blockers, warnings, exceptions, missing evidence, unsafe evidence, and `N/A` justifications that need reviewer attention.

#### Scenario: Full matrix is audit-only

- GIVEN audit/full-matrix mode is explicitly requested
- WHEN security review writes source-row evidence
- THEN canonical `review-security-report.json` MUST validate every expected Source ID exactly once and derived Markdown MUST include every row only when generated in audit/full-matrix mode
- AND each row MUST show mapping, status, evidence, observations, and finding.

#### Scenario: Design remains selective

- GIVEN design contains narrative changed-surface rationale and applicable category rules
- WHEN security review expands source rows
- THEN source-row validation results MUST be written only in canonical `review-security-report.json` and its derived Markdown view
- AND missed applicable design categories MUST block as contract evidence gaps.

#### Scenario: General review is cited, not duplicated

- GIVEN a general review finding supports a source row
- WHEN security review records evidence
- THEN it MAY cite the review-report row
- AND it MUST NOT reproduce the full 96-control matrix.

### Requirement: Source Row Blocking Rules

Security review MUST block missing, duplicate, or unknown Source IDs during validation; missing compact mappings; malformed report schema; missing artifacts; unsafe evidence; missing `N/A` justification in report evidence; and missed applicable design categories/controls. Design MUST NOT be blocked for lacking YAML, schema, or matrix fields.

#### Scenario: Coverage or schema blocker exists

- GIVEN source-row coverage is incomplete or malformed
- WHEN security review validates rows
- THEN the verdict MUST be blocking
- AND next recommendation MUST be `resolve-blockers`.

#### Scenario: Implementation evidence is missing

- GIVEN a source row applies and remediation requires code or instruction changes
- WHEN review finds missing implementation evidence
- THEN the row MUST be blocking
- AND next recommendation MUST be `apply`.

#### Scenario: Warnings only remain

- GIVEN all mandatory rows have safe evidence and only warnings remain
- WHEN security review computes routing
- THEN the verdict MAY be non-blocking
- AND next recommendation MUST be `verify`.

### Requirement: Source Row Evidence Correlation

Security review MUST correlate source rows with narrative design rules, test-design checks, apply evidence, changed files, and review findings. A row MUST NOT pass solely because it is listed or omitted from design; evidence MUST support applicability, compliance, justified `N/A`, or approved exception.

#### Scenario: Listed row has no corroboration

- GIVEN a source row appears in the matrix
- WHEN no supporting design, test, apply, changed-file, review, or exception evidence exists
- THEN the row MUST fail validation
- AND the report MUST identify the missing corroboration.

#### Scenario: Evidence is unsafe

- GIVEN evidence contains secret-like or confidential values
- WHEN security review validates the row
- THEN it MUST reject the evidence as unsafe
- AND route to `resolve-blockers` unless implementation remediation is required.

### Requirement: Operational Evidence Leakage Review

`sdd-review-security` MUST validate leakage boundaries for operational evidence that exists in design, test-design, tasks, apply evidence, review output, code, tests, fixtures, examples, or archived evidence. It MUST focus on restricted production identifiers, secrets, payloads, full ID lists, and generated bytes. It MUST NOT require operational-readiness category completeness when no applicable evidence exists.

#### Scenario: Restricted production identifier is found

- GIVEN ordinary SDD evidence contains a production hostname, IP, port, SID/service name, credential, token, payload, full ID list, or generated file bytes
- WHEN security review evaluates operational evidence
- THEN it MUST report unsafe evidence as blocking
- AND route to `resolve-blockers` unless implementation remediation is required.

#### Scenario: Operational document is the target

- GIVEN the user explicitly provides production operational values for final documentation
- WHEN security review evaluates ordinary SDD artifacts
- THEN those values MUST remain outside SDD evidence, code, tests, fixtures, and examples.

#### Scenario: No operational evidence exists

- GIVEN design and review evidence show no operational considerations apply
- WHEN security review runs
- THEN it MUST NOT block for missing readiness categories.

### Requirement: Safe Placeholder Security Boundary

Security review MUST accept exact `Pendiente de confirmar:` and exact `No aplica.` placeholders as safer than invented operational details for applicable operational evidence. It MUST NOT require disclosure of real operational data to pass. Placeholders MUST NOT be used to hide required security proof when non-leakage evidence is applicable.

#### Scenario: Missing value uses safe placeholder

- GIVEN operational data is unavailable
- WHEN security review validates the evidence boundary
- THEN exact placeholder usage MUST NOT be treated as a leakage failure.

#### Scenario: Placeholder hides required security evidence

- GIVEN a security obligation still requires proof of non-leakage
- WHEN only a placeholder is present
- THEN security review MUST require safe evidence of the boundary, not real operational values.
