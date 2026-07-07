# sdd-review-workflow Specification

## Purpose

Define `sdd-review` as the mandatory post-apply code-review gate that produces `review-report.md` before security review and verification.

## Requirements

### Requirement: Mandatory Review Gate

The SDD workflow MUST route completed implementation through `sdd-review` before `sdd-review-security` and `sdd-verify`. Review MUST inspect applied changes, required new-change SDD artifacts, and task evidence, then route non-blocking results to security review rather than directly to verify. `security-applicability.md` and standalone `security-design.md` MUST NOT be default required new-change inputs.

#### Scenario: Apply routes to review

- GIVEN all apply tasks are complete
- WHEN apply returns a success route
- THEN the next phase MUST be `sdd-review`
- AND verify MUST NOT run until both review gates are non-blocking.

#### Scenario: Blocking review returns to apply

- GIVEN review finds any blocking failure
- WHEN the review phase completes
- THEN it MUST route to `sdd-apply`
- AND `sdd-review-security` MUST NOT run yet.

#### Scenario: Legacy applicability is optional evidence

- GIVEN a new change has proposal, specs, design with `## Secure Development Design` narrative rules, test design, tasks, and apply evidence
- WHEN review resolves required inputs
- THEN missing `security-applicability.md` or standalone `security-design.md` MUST NOT block review
- AND any such artifact present MUST be treated only as legacy or archive evidence.

### Requirement: Review Report Artifact

`sdd-review` MUST persist `review-report.md` as a first-class artifact at `openspec/changes/{change-name}/review-report.md`. Missing required artifacts, unknown changed files, unsafe workspace context, or persistence failure MUST route to `resolve-blockers`.

#### Scenario: Report is persisted

- GIVEN review can resolve all required inputs
- WHEN review completes
- THEN it MUST write `review-report.md`
- AND the report MUST include verdict, matrix, evidence summary, and next recommendation.

### Requirement: Code-Review Validation Matrix

`review-report.md` MUST include a matrix with exactly these columns: Item, Artifact/Deliverable, Requirement, Reviewer, Standard, Severity, Complies, Affected Requirement, Evidence Location, Observations/Comments. The 96 source checklist controls MUST have stable IDs and categories. Category MUST be preserved by a stable control catalog or by the Item ID prefix without adding matrix columns. `Complies` MUST support Yes, No, and N/A. N/A MUST include evidence proving the control is irrelevant, especially for platform-specific controls.

#### Scenario: All controls are represented

- GIVEN the source checklist contains 96 controls
- WHEN review writes the matrix
- THEN every control MUST appear once with a stable Item ID
- AND every row MUST use the exact required columns.

#### Scenario: Platform control is irrelevant

- GIVEN a control targets an unused platform or technology
- WHEN review marks it N/A
- THEN Evidence Location MUST prove irrelevance
- AND Observations/Comments MUST explain the scope decision.

### Requirement: Severity and Routing Semantics

Review MUST classify each failed control severity. Critical or explicitly blocking failures MUST prevent security review and verify. Non-blocking findings MAY proceed to `sdd-review-security` as warnings.

#### Scenario: Non-blocking review proceeds

- GIVEN review has no blocking failures
- WHEN it returns its envelope
- THEN next_recommended MUST be `sdd-review-security`
- AND the security review phase MUST consume the review report as evidence.

### Requirement: Security Boundary

Security-related review controls MUST cross-reference the security guideline catalog where applicable. Review MUST NOT replace embedded secure development design or mandatory security review ownership. Legacy applicability or standalone security-design evidence MAY be cited only for archived or old changes and MUST NOT displace `design.md` or `review-security-report.md` as new-change security authorities.

#### Scenario: Security control is reviewed

- GIVEN a review control maps to a catalog guideline
- WHEN review records the matrix row
- THEN Standard SHOULD cite the guideline identifier
- AND embedded `design.md` security rows and `review-security-report.md` MUST remain the security authorities.

#### Scenario: Applicability does not replace security evidence

- GIVEN a reviewer finds a legacy `security-applicability.md` or `security-design.md` artifact
- WHEN reviewing a new change
- THEN the reviewer MAY cite it only as compatibility context
- AND MUST require embedded `design.md` secure development rows for authoritative classification.

### Requirement: Security Review Handoff

`review-report.md` MUST provide enough changed-file, evidence, finding context, and `design.md` references for `sdd-review-security` to validate embedded secure development implementation evidence without duplicating the 96-control matrix.

#### Scenario: Handoff evidence is available

- GIVEN review completed without blockers
- WHEN security review starts
- THEN it MUST be able to read `review-report.md` and `design.md`
- AND missing readable review or design evidence MUST route to `resolve-blockers`.
