# sdd-test-design-workflow Specification

## Purpose

Define the mandatory `sdd-test-design` phase that produces `test-design.md` after technical design and before task planning in the SDD workflow.

## Requirements

### Requirement: Mandatory Phase Order

The SDD workflow MUST run `sdd-test-design` after `sdd-design` succeeds and after required `sdd-security-design` succeeds for security-impacting changes. `sdd-tasks` MUST be blocked until the required test-design artifact exists or the phase is explicitly blocked.

#### Scenario: Successful design routes to security design or test design

- GIVEN an SDD change has completed `sdd-design`
- WHEN the phase returns a successful envelope
- THEN the next recommended phase MUST be `security-design` or `sdd-security-design` when security applicability is impacting
- AND otherwise the next recommended phase MUST be `test-design` or `sdd-test-design`.

#### Scenario: Tasks requested too early

- GIVEN `test-design.md` is missing for an active change
- WHEN `sdd-tasks` is launched
- THEN the launch MUST be rejected or returned as blocked
- AND the blocker MUST name the missing `sdd-test-design` phase or artifact.

#### Scenario: Security design required before test design

- GIVEN security applicability marks a change as security-impacting and `security-design.md` is missing
- WHEN `sdd-test-design` is launched
- THEN the launch MUST be rejected or returned as blocked
- AND the blocker MUST name the missing `sdd-security-design` phase or artifact.

### Requirement: test-design.md Artifact Contract

The `sdd-test-design` phase MUST create `test-design.md` for every change. The artifact MUST map spec scenarios, design risks, and required security-design controls to planned automated, manual, or static checks; mark each case as mandatory or non-mandatory; state expected evidence; and document no-impact assessments when no behavior, security, or testability impact exists. The phase artifact contract MUST preserve mandatory artifact creation and downstream consumption while delegating common artifact-store mode semantics, artifact resolution, and persistence verification to the shared persistence authority.

#### Scenario: Behavior-impacting change

- GIVEN specs or design describe behavior, contracts, routing, or compatibility changes
- WHEN `sdd-test-design` runs
- THEN `test-design.md` MUST list planned checks linked to those inputs
- AND each check MUST include type, severity, and expected evidence.

#### Scenario: Security-impacting change

- GIVEN `security-design.md` lists required controls or mandatory evidence
- WHEN `sdd-test-design` runs
- THEN `test-design.md` MUST include planned checks or justified non-test evidence for each required control
- AND uncovered mandatory security evidence MUST be reported as a blocker.

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

Downstream phases MUST use `test-design.md` as the test-planning source of truth. `sdd-tasks` MUST derive implementation and verification tasks from it; `sdd-apply` SHOULD follow planned cases or report justified deviations; `sdd-verify` MUST compare evidence against it. Updates to persistence contract wording MUST NOT weaken this downstream consumption requirement or route tasks directly from design without the required test-design artifact.

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
