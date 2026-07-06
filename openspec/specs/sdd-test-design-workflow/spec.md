# sdd-test-design-workflow Specification

## Purpose

Define the mandatory `sdd-test-design` phase that produces `test-design.md` after technical design with embedded secure development design and before task planning in the SDD workflow.

## Requirements

### Requirement: Mandatory Phase Order

The SDD workflow MUST run `sdd-test-design` after `sdd-design` succeeds for every new change. `sdd-design` MUST include embedded secure development design, and `sdd-tasks` MUST be blocked until `test-design.md` exists or the phase explicitly blocks.

#### Scenario: Design routes through test design

- GIVEN an SDD change has completed `sdd-design`
- WHEN the phase returns a successful envelope
- THEN the next recommended phase MUST be `test-design` or `sdd-test-design`
- AND `security-design` MUST NOT be the direct successor for new changes.

#### Scenario: Tasks requested too early

- GIVEN `test-design.md` is missing for an active change
- WHEN `sdd-tasks` is launched
- THEN the launch MUST be rejected or returned as blocked
- AND the blocker MUST name the missing `sdd-test-design` phase or artifact.

#### Scenario: Test design requires embedded secure design

- GIVEN `design.md` lacks `## Secure Development Design` for a new active change
- WHEN `sdd-test-design` is launched
- THEN the launch MUST be rejected or returned as blocked
- AND the blocker MUST name the missing embedded secure design section.

### Requirement: test-design.md Artifact Contract

The `sdd-test-design` phase MUST create `test-design.md` for every change. The artifact MUST map spec scenarios, design risks, and embedded `design.md` secure development rows to planned automated, manual, or static checks; mark each case as mandatory or non-mandatory; state expected evidence; and document justified no-impact assessments. The phase artifact contract MUST preserve mandatory artifact creation and downstream consumption while delegating common artifact-store mode semantics, artifact resolution, and persistence verification to the shared persistence authority. Common persistence behavior MUST remain delegated to the shared persistence authority.

#### Scenario: Behavior-impacting change

- GIVEN specs or design describe behavior, contracts, routing, or compatibility changes
- WHEN `sdd-test-design` runs
- THEN `test-design.md` MUST list planned checks linked to those inputs
- AND each check MUST include type, severity, and expected evidence.

#### Scenario: Security matrix is consumed

- GIVEN `design.md` lists secure development rows and lifecycle statuses
- WHEN `sdd-test-design` runs
- THEN `test-design.md` MUST include checks or justified non-test evidence for applicable mandatory rows
- AND blocked security rows MUST remain blockers.

#### Scenario: No-impact matrix rows are handled

- GIVEN all security rows are `not-applicable` with evidence
- WHEN `sdd-test-design` runs
- THEN it MUST cite that assessment
- AND it MUST still produce `test-design.md`.

#### Scenario: No-impact change

- GIVEN the change has no behavior, security, or testability impact
- WHEN `sdd-test-design` runs
- THEN `test-design.md` MUST state a no-impact assessment
- AND downstream phases MUST treat the artifact as complete rather than absent.

#### Scenario: Persistence boundary is delegated

- GIVEN `sdd-test-design` writes or resolves `test-design.md` in any supported artifact-store mode
- WHEN backend behavior is required
- THEN it MUST follow the shared persistence authority
- AND it MUST keep the mandatory artifact contract local to the phase.

### Requirement: Check Types and Severity

Test-design cases MUST support automated checks, manual checks, and static/file-contract checks. Mandatory cases MUST be treated as verification-blocking; non-mandatory cases MUST be advisory and reported as warnings when uncovered.

#### Scenario: Mandatory case uncovered

- GIVEN `test-design.md` marks a case as mandatory
- WHEN `sdd-verify` finds no matching implementation, execution, or justified skip evidence
- THEN verification MUST fail or report a blocking issue for that case

#### Scenario: Non-mandatory case uncovered

- GIVEN `test-design.md` marks a case as non-mandatory
- WHEN `sdd-verify` finds no matching evidence
- THEN verification MUST report a warning
- AND verification MUST NOT fail solely because of that uncovered non-mandatory case

### Requirement: Downstream Consumption

Downstream phases MUST use `test-design.md` as the test-planning source of truth and MUST preserve links to embedded secure development design evidence. `sdd-tasks` MUST derive implementation and verification tasks from it; `sdd-apply` SHOULD follow planned cases or report justified deviations; `sdd-verify` MUST compare evidence against both test cases and security evidence obligations. Updates to persistence contract wording MUST NOT weaken this downstream consumption requirement or route tasks directly from design without the required test-design artifact.

#### Scenario: Verify compares security evidence

- GIVEN test design references embedded secure development design evidence
- WHEN `sdd-verify` runs
- THEN it MUST evaluate matching evidence or justified exceptions
- AND missing mandatory evidence MUST remain blocking.

#### Scenario: Tasks derive testing work

- GIVEN `test-design.md` contains planned checks
- WHEN `sdd-tasks` creates implementation tasks
- THEN tasks MUST include corresponding testing or evidence work
- AND omitted mandatory cases MUST be reported as blockers

#### Scenario: Apply deviates from plan

- GIVEN implementation cannot follow a planned case exactly
- WHEN `sdd-apply` records evidence
- THEN it SHOULD document the deviation and replacement evidence
- AND `sdd-verify` MUST evaluate that justification against the planned case

#### Scenario: Persistence refactor preserves consumption

- GIVEN common persistence rules move to a shared authority
- WHEN downstream phases resolve test-planning inputs
- THEN they MUST still consume `test-design.md` from the established key or path
- AND they MUST NOT treat the artifact as optional.

### Requirement: Continuation, State, and Status Contracts

SDD state, status, continuation, and artifact refs MUST include `test-design.md` and the `sdd-test-design` dependency edge. Continuation MUST recover from persisted state without routing from design directly to tasks.

#### Scenario: Continuation after design

- GIVEN persisted state has design complete and test design incomplete
- WHEN continuation or status is requested
- THEN the next recommended phase MUST be `test-design` or `sdd-test-design`
- AND status MUST show tasks blocked by test design

#### Scenario: Artifact refs persisted

- GIVEN `test-design.md` has been created
- WHEN state or status is generated
- THEN artifact refs and paths MUST include the test-design artifact
- AND downstream launches MUST receive that ref when available

### Requirement: Native Token Compatibility

The workflow MUST remain compatible with native dispatcher and status-token handling. Implementations MUST define a bounded mapping between phase-agent token `sdd-test-design`, native/status token `test-design`, and any persisted field names required by native tooling.

#### Scenario: Native dispatcher supports test-design

- GIVEN native status or dispatcher tooling accepts a bounded `test-design` token
- WHEN the orchestrator routes after design
- THEN it MUST use that native token consistently in state and status

#### Scenario: Native dispatcher lacks test-design token

- GIVEN native tooling rejects or omits `test-design`
- WHEN the workflow is updated
- THEN design MUST specify compatibility handling before apply
- AND prompts MUST NOT claim unsupported native status behavior without a mapping

### Requirement: Source Row Test Planning

`sdd-test-design` MUST plan static, manual, or automated checks from the slim `design.md#secure-development-design` coverage contract. It MUST consume catalog snapshot identity/path, `expectedSourceIdCount: 155`, section/group coverage, compact `SEC-*` mappings, applicability, evidence owners, lifecycle states, and N/A/exception policy. It MUST NOT require design to carry the full 155-row matrix, but MUST preserve enough planned evidence for review-security to expand every Source ID exactly once.

#### Scenario: Applicable source group receives checks

- GIVEN design marks a source group or compact mapping applicable
- WHEN test design is produced
- THEN `test-design.md` MUST include planned checks or justified non-test evidence
- AND each check MUST cite the catalog reference and compact `SEC-*` mapping.

#### Scenario: No runtime runner exists

- GIVEN repository testing capabilities report no runner
- WHEN source-row checks are planned
- THEN test design MUST use static or manual evidence where appropriate
- AND it MUST report unavailable runtime automation explicitly.

#### Scenario: Mandatory coverage lacks planned evidence

- GIVEN applicable mandatory source coverage has no check or evidence plan
- WHEN `sdd-test-design` validates readiness
- THEN the phase MUST block
- AND the blocker MUST name the affected Source ID, group, or compact mapping and missing evidence plan.

### Requirement: Source Row N/A and Warning Evidence

`sdd-test-design` MUST preserve evidence expectations for `N/A` source coverage and warning-only coverage from the slim design contract. `N/A` requires proof of irrelevance; warnings require planned observation evidence but MUST NOT block solely when mandatory evidence is complete.

#### Scenario: N/A coverage is planned for review

- GIVEN design marks a source group or compact mapping `N/A`
- WHEN test design maps security evidence
- THEN it MUST include the irrelevance evidence to be checked
- AND missing justification MUST remain blocking.

#### Scenario: Warning-only coverage is tracked

- GIVEN source coverage has warning classification only
- WHEN test design records checks
- THEN it MUST preserve the warning and expected evidence
- AND it MUST allow downstream routing when no blockers exist.
