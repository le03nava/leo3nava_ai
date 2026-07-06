# sdd-review-security-workflow Specification

## Purpose

Define the mandatory post-review security evidence gate that validates embedded `design.md#secure-development-design` rows and produces `review-security-report.md` before verification.

## Requirements

### Requirement: Mandatory Security Review Gate

The SDD workflow MUST run `sdd-review-security` after non-blocking `sdd-review` and before `sdd-verify` for every new change.

#### Scenario: General review routes to security review

- GIVEN `review-report.md` has no blocking findings
- WHEN routing is computed
- THEN the next required phase MUST be `sdd-review-security`
- AND `sdd-verify` MUST remain blocked until security review evidence exists.

#### Scenario: General review is blocking

- GIVEN `sdd-review` reports blocking findings
- WHEN routing is computed
- THEN `sdd-review-security` MUST NOT run
- AND the workflow MUST route back to `sdd-apply` or `resolve-blockers`.

### Requirement: Security Review Artifact

`sdd-review-security` MUST persist `review-security-report.md`. The report MUST validate embedded `design.md#secure-development-design` rows, include verdict, row-level evidence locations, observations, blocking findings, exceptions, and next recommendation, and MUST NOT depend on `scripts/validate_security_design.ps1` or standalone security artifacts for active new-change evidence.

#### Scenario: Report is persisted

- GIVEN `design.md` and `review-report.md` are readable
- WHEN security review completes
- THEN `review-security-report.md` MUST be written and read back
- AND it MUST state a blocking or non-blocking verdict.

#### Scenario: Embedded secure design is required

- GIVEN a new change lacks `design.md#secure-development-design`
- WHEN security review evaluates readiness
- THEN it MUST block with missing embedded design evidence
- AND verify/archive MUST remain unavailable.

### Requirement: Security Matrix Validation

Security review MUST validate every embedded `design.md` secure development row using `Yes`, `No`, or `N/A`, evidence location, observations, and lifecycle status: `not-started`, `planned`, `implemented`, `verified`, `not-applicable`, `exception-approved`, or `blocked`.

#### Scenario: Mandatory evidence is missing

- GIVEN an applicable mandatory guideline lacks implementation evidence or approved exception
- WHEN security review validates the matrix
- THEN the report MUST mark the row `No` and `blocked`
- AND verify/archive MUST be blocked.

#### Scenario: Not applicable row is justified

- GIVEN a guideline is marked `N/A`
- WHEN security review validates it
- THEN evidence MUST prove irrelevance
- AND observations MUST explain the scope decision.

### Requirement: Boundary with General Review

Security review MUST NOT replace `sdd-review` or duplicate the 96-control matrix. It MUST focus on security guideline evidence and MAY cite general review findings as supporting evidence.

#### Scenario: General review evidence is reused

- GIVEN a review row supports a security guideline
- WHEN security review records evidence
- THEN it MAY cite that review row
- AND it MUST keep the security verdict in `review-security-report.md`.

### Requirement: Active Security Validator Retirement

The active new-change workflow MUST remove `scripts/validate_security_design.ps1` as a required validator. Any remaining parser or archive references MUST NOT block new-change routing, review-security, verify, or archive.

#### Scenario: New change does not invoke validator

- GIVEN `sdd-review-security` validates a new change
- WHEN it checks secure development evidence
- THEN it MUST validate against the corporate catalog and embedded `design.md` section
- AND it MUST NOT require `scripts/validate_security_design.ps1` execution.

### Requirement: Exhaustive Source Row Security Review

`sdd-review-security` MUST validate every corporate source row against catalog inventory, `design.md#secure-development-design`, `test-design.md`, apply evidence, changed files, and `review-report.md`. It MUST generate a full security source-row matrix without duplicating the 96-control general review matrix.

#### Scenario: Full matrix is generated

- GIVEN design, test-design, apply evidence, changed files, and review report are readable
- WHEN security review succeeds
- THEN `review-security-report.md` MUST include every expected Source ID exactly once
- AND each row MUST show mapping, status, evidence, observations, and finding.

#### Scenario: General review is cited, not duplicated

- GIVEN a general review finding supports a source row
- WHEN security review records evidence
- THEN it MAY cite the review-report row
- AND it MUST NOT reproduce the full 96-control matrix.

### Requirement: Source Row Blocking Rules

Security review MUST block missing, duplicate, or unknown Source IDs; missing compact mappings; malformed source-row schema; missing design, test-design, apply, changed-file, or review artifacts; unsafe evidence; and missing `N/A` evidence or justification.

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

Security review MUST correlate source rows with design expectations, test-design checks, apply evidence, changed files, and review findings. A row MUST NOT pass solely because it is listed; evidence must support applicability, compliance, or justified `N/A`.

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
