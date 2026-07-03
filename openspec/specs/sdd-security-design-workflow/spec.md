# sdd-security-design-workflow Specification

## Purpose

Define the conditional security design phase that translates applicable guidelines into design controls, evidence expectations, and downstream verification obligations.

## Requirements

### Requirement: Conditional Security Design Phase

The SDD workflow MUST run `sdd-security-design` only when `security-applicability.md` marks a change as security-impacting. The workflow MUST NOT require `security-design.md` for explicit no-impact changes.

#### Scenario: Applicable change requires security design

- GIVEN `security-applicability.md` marks the change as security-impacting
- WHEN technical design completes
- THEN the next required phase MUST be `sdd-security-design`
- AND task planning MUST remain blocked until `security-design.md` exists or the phase is blocked.

#### Scenario: No-impact change skips security design

- GIVEN `security-applicability.md` records no-impact evidence
- WHEN technical design completes
- THEN the workflow MUST skip `sdd-security-design`
- AND downstream phases MUST NOT treat missing `security-design.md` as a blocker.

### Requirement: Security Design Artifact Contract

`sdd-security-design` MUST create `security-design.md` for security-impacting changes. The artifact MUST map applicable guidelines to required controls, expected evidence, mandatory status, residual risks, and downstream test-design obligations. The phase artifact contract MUST preserve conditional artifact creation and existing artifact identity while delegating common artifact-store mode semantics, artifact resolution, and persistence verification to the shared persistence authority.

#### Scenario: Guidelines become controls

- GIVEN applicability identified mandatory authentication or access-control guidelines
- WHEN `sdd-security-design` runs
- THEN `security-design.md` MUST define the required controls
- AND it MUST state evidence expected from apply, test-design, and verify phases.

#### Scenario: Applicability risks are carried forward

- GIVEN applicability recorded minor evidence gaps as risks
- WHEN security design is written
- THEN `security-design.md` MUST either resolve each risk or preserve it with an owner-facing evidence expectation.

#### Scenario: Conditional artifact behavior is preserved

- GIVEN `security-applicability.md` records explicit no-impact evidence
- WHEN the workflow evaluates required artifacts
- THEN it MUST NOT require `security-design.md`
- AND this compatibility MUST hold across supported artifact-store modes.

#### Scenario: Persistence boundary is delegated

- GIVEN `sdd-security-design` persists or resolves `security-design.md`
- WHEN backend behavior is needed
- THEN the phase MUST follow the shared persistence authority
- AND phase-local rules MUST only define conditional creation, contents, and routing obligations.

### Requirement: Mandatory Evidence and Exceptions

Security design MUST identify mandatory applicable guideline evidence. Archive MUST be treated as blocked when mandatory evidence is missing unless an approved exception records approver, guideline, accepted-risk rationale, and mitigation or follow-up.

#### Scenario: Missing mandatory evidence blocks archive

- GIVEN an applicable mandatory guideline has no evidence or approved exception
- WHEN archive readiness is evaluated
- THEN archive MUST be blocked
- AND the blocker MUST name the guideline and missing evidence.

#### Scenario: Approved exception allows archive

- GIVEN mandatory evidence is missing but an exception records approver, guideline, accepted-risk rationale, and mitigation or follow-up
- WHEN archive readiness is evaluated
- THEN archive MAY proceed
- AND the exception MUST remain in the audit trail.

### Requirement: Enriched Applicability Consumption

`sdd-security-design` MUST consume enriched applicability fields for security-impacting changes, including catalog snapshot identity, evaluated categories, decision matrix rows, source evidence refs, operational severity, and validation metadata. It MUST translate applicable `blocking` and `conditional` obligations into controls, evidence expectations, risks, or approved exceptions.

#### Scenario: Security-impacting artifact provides enriched fields

- GIVEN `security-applicability.md` marks a change as security-impacting
- WHEN `sdd-security-design` runs
- THEN it MUST use the decision matrix and source refs to build controls
- AND it MUST preserve catalog snapshot identity in `security-design.md`.

#### Scenario: Conditional obligation becomes design predicate

- GIVEN an applicable guideline has `conditional` severity
- WHEN security design maps controls
- THEN it MUST state the predicate and required evidence
- AND unresolved true predicates MUST remain trackable downstream.

### Requirement: No-Impact Compatibility Preservation

The workflow MUST preserve no-impact routing compatibility. Enriched applicability fields MUST NOT cause `security-design.md` to be required when `security-applicability.md` contains valid explicit no-impact proof and routes security design as skipped.

#### Scenario: Valid no-impact still skips security design

- GIVEN applicability records complete no-impact proof and validation metadata
- WHEN technical design completes
- THEN the workflow MUST skip `sdd-security-design`
- AND missing `security-design.md` MUST NOT block tasks, verify, or archive.

#### Scenario: Invalid no-impact does not silently skip

- GIVEN no-impact proof is incomplete or validator metadata reports failure
- WHEN downstream routing is evaluated
- THEN the workflow MUST NOT rely on the no-impact classification
- AND orchestration MUST route to resolve the applicability blocker before design proceeds.
