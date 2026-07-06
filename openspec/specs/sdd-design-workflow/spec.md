# sdd-design-workflow Specification

## Purpose

Define `sdd-design` as the mandatory technical design phase that also owns secure development design for new changes.

## Requirements

### Requirement: Embedded Secure Development Design

`sdd-design` MUST persist `design.md` for every new change. The artifact MUST include a `## Secure Development Design` section that is the active classification and secure-design authority and evaluates all catalog rows: `SEC-AUTH-001`, `SEC-SESS-001`, `SEC-DATA-001`, `SEC-SECRET-001`, `SEC-ACCESS-001`, `SEC-FILE-001`, `SEC-DB-001`, and `SEC-LOG-001`.

#### Scenario: Design contains all security rows

- GIVEN proposal and specs are readable
- WHEN `sdd-design` succeeds
- THEN `design.md` MUST include `## Secure Development Design`
- AND the section MUST contain all 8 catalog guideline IDs.

#### Scenario: No-impact change records rationale

- GIVEN no security category applies
- WHEN `design.md` is written
- THEN every row MUST be marked `N/A` or `not-applicable`
- AND each row MUST include rationale and evidence proving irrelevance.

### Requirement: Secure Development Design Row Contract

Each secure design row MUST state applicability, rationale, secure design decision, controls, evidence owner, expected evidence, lifecycle status, residual risk, and exception data when evidence cannot be produced.

#### Scenario: Applicable guideline has obligations

- GIVEN a guideline applies to the change
- WHEN `sdd-design` records the row
- THEN it MUST identify controls and expected downstream evidence
- AND unresolved mandatory evidence MUST remain visible to test design, review-security, verify, and archive.

#### Scenario: Exception is required

- GIVEN mandatory evidence cannot be planned
- WHEN the row records an exception
- THEN it MUST include approver, accepted-risk rationale, mitigation or follow-up, and evidence gap.

### Requirement: Direct Routing to Test Design

For new changes, successful `sdd-design` MUST route directly to `sdd-test-design`; it MUST NOT require, launch, or produce a standalone security-design phase or artifact.

#### Scenario: Design routes to test design

- GIVEN `design.md` includes the secure development section
- WHEN the phase returns a successful envelope
- THEN `next_recommended` MUST be `sdd-test-design` or `test-design`
- AND no standalone security-design artifact MUST be required for the new change.

### Requirement: Secure Design Source ID Coverage

`sdd-design` MUST require `design.md#secure-development-design` to declare expected corporate Source ID coverage alongside compact `SEC-*` rows. The section MUST show traceability from Source ID to mapped compact guideline, expected evidence, applicability, lifecycle status, residual risk, and any planned exception or `N/A` justification.

#### Scenario: Design declares expected coverage

- GIVEN proposal and specs require security validation
- WHEN `sdd-design` succeeds
- THEN `design.md#secure-development-design` MUST include expected Source ID coverage
- AND each listed Source ID MUST reference one or more compact `SEC-*` IDs.

#### Scenario: Applicable row has evidence plan

- GIVEN a Source ID applies to the change
- WHEN design records the row
- THEN it MUST name expected downstream evidence and owner
- AND unresolved mandatory evidence MUST remain visible to test-design and review-security.

#### Scenario: N/A row has design rationale

- GIVEN a Source ID is expected to be not applicable
- WHEN design records the row
- THEN it MUST include evidence and justification for irrelevance
- AND missing `N/A` evidence MUST block design completion.

### Requirement: Design Preserves Compact Summary

`sdd-design` MUST keep the compact eight-control summary readable while adding source-row detail as a bounded operational matrix. It MUST NOT duplicate the general 96-control review matrix or replace compact guidelines with per-source controls.

#### Scenario: Compact and source layers coexist

- GIVEN a change has multiple corporate Source IDs
- WHEN reviewers inspect secure design
- THEN the compact `SEC-*` summary MUST remain visible
- AND detailed source rows MUST be traceable below it.

#### Scenario: General review matrix is not copied

- GIVEN secure design documents source coverage
- WHEN design is persisted
- THEN it MUST avoid reproducing the 96-control review matrix
- AND it MUST focus on security source-row planning only.
