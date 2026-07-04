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

When SDD rules are duplicated, ambiguous, or conflicting, the system MUST preserve current behavior unless an approved spec change explicitly redesigns DAG, artifact, routing, status, or persistence semantics. Explicit redesigns MUST define compatibility rules for old artifacts and MUST NOT silently invalidate archives. Status tokens, resolver rows, and persisted refs MAY preserve legacy `security-applicability` data, but MUST NOT normalize it into a runnable phase, launchable agent, or required new-change successor.

#### Scenario: Explicit DAG redesign is applied

- GIVEN an approved spec changes phase order
- WHEN contracts are updated
- THEN the new DAG MUST be authoritative for new changes
- AND legacy artifacts MUST remain readable only under documented compatibility rules.

#### Scenario: Compatibility is preserved

- GIVEN existing persisted SDD state or artifacts use established keys, paths, routing tokens, or status fields
- WHEN the contracts are updated
- THEN existing consumers MUST continue to resolve those artifacts and states without migration.

#### Scenario: Legacy token is not launchable

- GIVEN persisted state or status contains `security-applicability`
- WHEN routing or agent resolution is computed
- THEN the token MAY be interpreted as legacy data state
- AND it MUST NOT map to `sdd-security-applicability` or any runnable successor.

### Requirement: Review Phase Artifact Contract

The SDD contract set MUST define `review-report.md` as the first review artifact after apply and before `sdd-review-security`. OpenSpec mode MUST store it at `openspec/changes/{change-name}/review-report.md`; Engram or hybrid modes MUST use the stable artifact key `sdd/{change-name}/review`. State and status contracts MUST expose review refs, verdict, blocking-failure state, and routing to security review when non-blocking.

#### Scenario: Review artifact is resolved

- GIVEN a downstream phase needs review evidence
- WHEN it resolves artifacts for a change
- THEN it MUST find `review-report.md` or the matching backend artifact key
- AND missing review evidence MUST block verify or archive.

#### Scenario: Security review resolves review artifact

- GIVEN `sdd-review-security` needs review evidence
- WHEN it resolves artifacts for a change
- THEN it MUST find `review-report.md` or the matching backend key
- AND missing review evidence MUST block security review, verify, and archive.

### Requirement: Apply Review Verify Routing

The SDD DAG for new changes MUST route `apply -> review -> review-security -> verify -> archive`. Apply success MUST recommend review, non-blocking review MUST recommend review-security, non-blocking security review MUST recommend verify, and blocking findings MUST route to apply or resolve-blockers.

#### Scenario: Mandatory review route is enforced

- GIVEN implementation has completed
- WHEN phase routing is evaluated
- THEN verify MUST NOT be the direct successor of apply
- AND review MUST be the required successor.

#### Scenario: Mandatory security review route is enforced

- GIVEN implementation and general review have completed
- WHEN phase routing is evaluated
- THEN verify MUST NOT be the direct successor of review
- AND `review-security` MUST be the required successor.

#### Scenario: Review cannot safely run

- GIVEN required artifacts or changed-file context are missing
- WHEN review evaluates readiness
- THEN it MUST return `resolve-blockers`
- AND it MUST state the missing or unsafe input.

### Requirement: Verify and Archive Review Consumption

Verify MUST consume both `review-report.md` and `review-security-report.md` as evidence and MUST NOT own either review matrix. Archive MUST require passing verification plus non-blocking general and security review reports for new changes.

#### Scenario: Verify consumes review evidence

- GIVEN review produced a non-blocking report
- WHEN verify runs
- THEN it MUST cite the review report as evidence
- AND it MUST NOT duplicate the full review matrix.

#### Scenario: Verify consumes both review artifacts

- GIVEN both review reports are non-blocking
- WHEN verify runs
- THEN it MUST cite both reports as evidence
- AND it MUST NOT duplicate their full matrices.

#### Scenario: Archive checks review readiness

- GIVEN verification passes
- WHEN archive evaluates readiness
- THEN it MUST also require a non-blocking review report
- AND blocking review findings MUST prevent archive.

### Requirement: Mandatory Security Artifacts and Status

For new changes, persistence and status contracts MUST include mandatory `security-design.md` and `review-security-report.md` refs, paths, dependency states, native/status token `review-security`, and archive gates. `security-applicability.md` and `securityApplicability` fields MAY appear only as legacy archived data refs and MUST NOT be active dependencies, produced artifacts, or phase-launch inputs.

#### Scenario: New state exposes security refs

- GIVEN a new change is persisted
- WHEN status or continuation reads state
- THEN artifact refs MUST include security design and security review report slots
- AND active dependencies MUST NOT include `security-applicability`.

#### Scenario: Legacy refs are preserved as data

- GIVEN an archived change contains `artifactRefs.securityApplicability`
- WHEN status or continuation displays historical evidence
- THEN the ref MAY remain visible as read-only data
- AND continuation MUST route active work through `design` or `security-design` instead of applicability.
