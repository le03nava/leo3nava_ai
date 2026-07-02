# sdd-execution-persistence-contracts Specification

## Purpose

Define the authoritative boundary between shared SDD execution contracts, shared persistence contracts, and phase-local artifact contracts.

## Requirements

### Requirement: Authoritative Persistence Boundary

The SDD contract set MUST define one shared persistence authority for artifact-store modes, backend read/write semantics, artifact resolution, hybrid conflict handling, and persistence verification. Phase and execution contracts MUST reference that authority instead of redefining detailed mode behavior.

#### Scenario: Shared persistence owns mode behavior

- GIVEN an SDD phase runs in `engram`, `openspec`, `hybrid`, or `none` mode
- WHEN the executor resolves read or write behavior
- THEN it MUST follow the shared persistence contract for backend semantics
- AND phase-local text MUST NOT introduce contradictory mode rules.

#### Scenario: Backend convention files remain scoped

- GIVEN backend convention files document Engram or OpenSpec details
- WHEN those files describe artifact storage
- THEN they SHOULD stay backend-specific references
- AND they MUST NOT compete with the shared persistence authority.

### Requirement: Execution Contract Boundary

The shared SDD phase contract MUST own executor boundary, supplemental skill loading, return envelope shape, routing-token conventions, artifact naming reminders, and review workload guard. It MUST NOT duplicate detailed persistence algorithms already owned by the persistence authority.

#### Scenario: Executor returns a stable envelope

- GIVEN a phase completes, partially completes, or blocks
- WHEN it returns to the orchestrator
- THEN it MUST use the shared Section D envelope fields
- AND routing tokens MUST remain normalizable through existing native/status mappings.

### Requirement: Phase Artifact Contracts

Each phase skill MUST keep a compact artifact contract that states required inputs, produced artifacts, artifact keys, OpenSpec paths, mutations, conditional behavior, and success/block routing. Phase contracts MAY define phase-specific validation or mutation semantics, but MUST delegate common persistence mechanics to the shared persistence authority.

#### Scenario: Phase-specific mutation is preserved

- GIVEN `sdd-apply`, `sdd-archive`, or `sdd-init` mutates existing artifacts or project state
- WHEN its phase contract is written
- THEN mutation semantics MUST remain explicit in that phase
- AND generic backend persistence mechanics MUST remain delegated.

### Requirement: Conflict and Ambiguity Resolution

When existing SDD rules are duplicated, ambiguous, or conflicting, the system MUST preserve current behavior unless a clarification is required to make the rule well-defined. Clarifications MUST identify the authoritative owner and MUST NOT redesign the SDD DAG, backend formats, artifact keys, OpenSpec paths, routing tokens, status fields, or native state names.

#### Scenario: Duplicated rule is homologated

- GIVEN a phase skill and shared contract describe the same persistence behavior differently
- WHEN the rule is homologated
- THEN the shared persistence contract MUST become authoritative
- AND the phase skill MUST retain only phase-local artifact obligations.

#### Scenario: Compatibility is preserved

- GIVEN existing persisted SDD state or artifacts use established keys, paths, routing tokens, or status fields
- WHEN the contracts are updated
- THEN existing consumers MUST continue to resolve those artifacts and states without migration.

### Requirement: Review Phase Artifact Contract

The SDD contract set MUST define `review-report.md` as the first-class artifact produced by `sdd-review` after apply and before verify. OpenSpec mode MUST store it at `openspec/changes/{change-name}/review-report.md`; Engram or hybrid modes MUST use the stable artifact key `sdd/{change-name}/review`. State and status contracts MUST expose review artifact refs, paths, verdict, blocking-failure state, and `nextRecommended` routing.

#### Scenario: Review artifact is resolved

- GIVEN a downstream phase needs review evidence
- WHEN it resolves artifacts for a change
- THEN it MUST find `review-report.md` or the matching backend artifact key
- AND missing review evidence MUST block verify or archive.

### Requirement: Apply Review Verify Routing

The SDD DAG MUST route `apply -> review -> verify -> archive`. Apply success MUST recommend review, review success without blocking failures MUST recommend verify, blocking review failures MUST recommend apply, and unsafe or incomplete review context MUST recommend `resolve-blockers`.

#### Scenario: Mandatory review route is enforced

- GIVEN implementation has completed
- WHEN phase routing is evaluated
- THEN verify MUST NOT be the direct successor of apply
- AND review MUST be the required successor.

#### Scenario: Review cannot safely run

- GIVEN required artifacts or changed-file context are missing
- WHEN review evaluates readiness
- THEN it MUST return `resolve-blockers`
- AND it MUST state the missing or unsafe input.

### Requirement: Verify and Archive Review Consumption

Verify MUST consume `review-report.md` as evidence and MUST NOT own the full 96-control review matrix. Archive MUST require both non-blocking review and passing verification before completing a change.

#### Scenario: Verify consumes review evidence

- GIVEN review produced a non-blocking report
- WHEN verify runs
- THEN it MUST cite the review report as evidence
- AND it MUST NOT duplicate the full review matrix.

#### Scenario: Archive checks review readiness

- GIVEN verification passes
- WHEN archive evaluates readiness
- THEN it MUST also require a non-blocking review report
- AND blocking review findings MUST prevent archive.
