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

When SDD rules are duplicated, ambiguous, or conflicting, the system MUST preserve current behavior unless an approved spec change explicitly redesigns DAG, artifact, routing, status, or persistence semantics. Explicit redesigns MUST define compatibility rules for old artifacts and MUST NOT silently invalidate archives. Historical exhaustive secure-design matrices MAY remain readable as archives, but new changes MUST treat narrative `design.md#secure-development-design` plus machine-readable `review-security-report.md` as the active boundary. Status tokens, resolver rows, and persisted refs MAY preserve historical `security-applicability` data for read/display behavior, but MUST NOT normalize it into a runnable phase, launchable agent, active security authority, or required new-change successor.

#### Scenario: Explicit DAG redesign is applied

- GIVEN an approved spec changes phase order
- WHEN contracts are updated
- THEN the new DAG MUST be authoritative for new changes
- AND older artifacts MUST remain readable only under documented compatibility rules.

#### Scenario: Compatibility is preserved

- GIVEN existing persisted SDD state or artifacts use established keys, paths, routing tokens, exhaustive design rows, or status fields
- WHEN the contracts are updated
- THEN existing consumers MUST continue to resolve those artifacts and states without migration.

#### Scenario: Historical token is not launchable

- GIVEN persisted state or status contains `security-applicability`
- WHEN routing or agent resolution is computed
- THEN the token MAY be interpreted as historical data state
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

The SDD DAG for new changes MUST route `design -> test-design -> tasks -> apply -> review -> review-security -> verify -> archive`. Apply success MUST recommend review, non-blocking review MUST recommend review-security, non-blocking security review MUST recommend verify, and blocking findings MUST route to apply or resolve-blockers.

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

#### Scenario: Design routes directly to test design

- GIVEN `design.md` includes `## Secure Development Design`
- WHEN phase routing is evaluated
- THEN `test-design` MUST be the direct successor
- AND `security-design` MUST NOT be an active new-change successor.

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

For new changes, persistence and status contracts MUST include `design.md` with narrative secure development rules and `review-security-report.md` refs, dependency states, `review-security` token, and archive gates. Design MUST persist classification rationale, changed-surface inventory, applicable category rules, evidence owners, residual risks, exceptions, and safe-evidence policy. It MUST NOT require YAML, schemas, compact matrices, Source ID matrices, exhaustive applicability, or `N/A` rows. Those machine-readable artifacts MUST persist in `review-security-report.md`. `security-design.md` and `security-applicability.md` MAY appear only as historical refs.

#### Scenario: New state exposes security refs

- GIVEN a new change is persisted
- WHEN status or continuation reads state
- THEN artifact refs MUST include design and security review report slots
- AND active dependencies MUST NOT include `security-design` or `security-applicability`.

#### Scenario: Legacy refs are preserved as data

- GIVEN an archived change contains `artifactRefs.securityDesign`, `artifactRefs.securityApplicability`, or exhaustive design rows
- WHEN status or continuation displays historical evidence
- THEN the ref MAY remain visible as read-only data
- AND continuation MUST route active work through narrative design and review-security.

### Requirement: Active Security Validator Removal

New-change contracts MUST use catalog and artifact evidence for security validation. Active status, continuation, review-security, verify, and archive gating MUST NOT depend on retired validator scripts.

#### Scenario: Retired validators do not participate

- GIVEN retired validator scripts are absent from the active workflow
- WHEN a new change reaches review-security, verify, or archive
- THEN the workflow MUST use catalog and artifact evidence instead
- AND retired validator availability MUST NOT be a blocker.

### Requirement: Source Row Persistence Compatibility

The SDD contracts MUST preserve corporate source-row evidence across OpenSpec, Engram, hybrid, and none modes according to the shared persistence contract. Backend behavior MUST NOT redefine source-row semantics. Source-row artifacts MUST remain recoverable through established review-security, verify, and archive keys/paths. Persistence MUST allow narrative designs and archived exhaustive designs to coexist without migration; verify/archive MUST require narrative design evidence plus the review-security report schema, not design YAML. New reports may persist summary-mode coverage metadata plus focused findings instead of the full 155-row matrix unless audit/full-matrix mode is explicitly requested.

#### Scenario: OpenSpec mode preserves rows

- GIVEN a change runs in OpenSpec mode
- WHEN source-row artifacts are persisted
- THEN coverage metadata, section summaries, focused findings, and audit-mode full rows when requested MUST be stored in `review-security-report.md`
- AND downstream phases MUST read that report as source-row evidence.

#### Scenario: Engram or hybrid mode preserves rows

- GIVEN Engram or hybrid mode is selected
- WHEN source-row artifacts are persisted
- THEN Engram keys MUST use the shared artifact naming contract
- AND hybrid mode MUST reconcile backend disagreements before continuing.

#### Scenario: None mode is explicit

- GIVEN none mode is selected
- WHEN source-row evidence is produced inline
- THEN no project files or Engram observations MUST be written
- AND downstream recovery limits MUST be reported.

### Requirement: Verify Source Row Consumption

`sdd-verify` MUST consume non-blocking `review-security-report.md` source-row evidence and validate that no source-row blockers remain. Verify MUST cite the security review verdict, catalog snapshot/count, compact mappings, warnings, exceptions, and evidence references without owning or duplicating the full source-row matrix.

#### Scenario: Security source blocker remains

- GIVEN review-security reports a blocking source row
- WHEN verify runs
- THEN verification MUST block
- AND it MUST route to apply or resolve-blockers according to the blocker cause.

#### Scenario: Warnings only after security review

- GIVEN review-security is non-blocking with warnings only
- WHEN verify records evidence
- THEN it MUST preserve the warnings
- AND verification MAY proceed if all mandatory evidence is complete.

#### Scenario: Verify preserves boundary evidence

- GIVEN review-security is non-blocking and cites narrative design coverage
- WHEN verify records final evidence
- THEN it MUST preserve catalog identity, expected count, compact mappings, and report links
- AND it MUST rely on embedded secure design plus review-security evidence.

### Requirement: Archive Source Row Preservation

`sdd-archive` MUST require passing verification plus non-blocking source-row security review for new changes. Archive MUST preserve source-row coverage summaries, catalog snapshot identity/path, expected count, compact `SEC-*` mappings, warnings, exceptions, and evidence references without copying the full review-security matrix into design/archive summaries unless audit/full-matrix mode was explicitly requested.

#### Scenario: Archive checks no source blockers remain

- GIVEN verification passes
- WHEN archive evaluates readiness
- THEN it MUST confirm no source-row blockers remain
- AND missing mandatory source-row evidence MUST prevent archive.

#### Scenario: Archive preserves audit trail

- GIVEN archive completes
- WHEN future readers inspect the archived change
- THEN source-row coverage summaries and evidence references MUST remain understandable
- AND compact `SEC-*` mappings MUST still be traceable.

#### Scenario: Archive avoids matrix duplication

- GIVEN `review-security-report.md` contains the exhaustive source-row matrix
- WHEN archive writes final records
- THEN it MUST link or summarize the matrix instead of duplicating it
- AND archived evidence MUST remain readable through embedded secure design and review-security evidence.

#### Scenario: Archive consumes summary-mode source evidence

- GIVEN `review-security-report.md` uses summary mode with complete source-row validation coverage
- WHEN archive writes final records
- THEN it MUST preserve coverage metadata, section summaries, focused findings, warnings, exceptions, and report links
- AND it MUST NOT require the full 155-row matrix unless audit/full-matrix mode was explicitly requested.

### Requirement: Operational Readiness Evidence Persistence

SDD persistence, status, verify, and archive contracts MUST preserve operational considerations, evidence, placeholders, gaps, and artifact references when they exist in design, test-design, tasks, apply, review, security review, verify, or archive evidence. Verify and archive MUST consume actual evidence rather than a shared operational-readiness contract. They MUST NOT require mandatory operational category completeness or disclosure of real operational data.

#### Scenario: Operational refs survive workflow

- GIVEN any SDD artifact records operational considerations or gaps
- WHEN status, verify, or archive resolves artifacts
- THEN those refs and unresolved gaps MUST remain readable.

#### Scenario: Verify checks applicable evidence

- GIVEN design or downstream artifacts make operational evidence applicable
- WHEN verify runs
- THEN each applicable item MUST have safe evidence, `Pendiente de confirmar:`, or `No aplica.`.

#### Scenario: No applicable evidence exists

- GIVEN design marks operational considerations not applicable or omits them safely
- WHEN verify or archive runs
- THEN missing readiness categories MUST NOT block completion.

### Requirement: Manual Operational Document Boundary

The DAG MUST NOT treat `sdd-operational-doc` as a required phase. The utility MUST remain manual, post-archive, and archive-consuming. It MUST generate from archived evidence, MUST NOT invent data, and MUST mark absent inapplicable values as `No aplica.` or unresolved applicable values as pending while preserving operational document sections 1-9 and diagrams R1-R4.

#### Scenario: Archive completes without operational doc

- GIVEN verify passes and archive criteria are met
- WHEN archive runs
- THEN completion MUST NOT require `sdd-operational-doc` execution.

#### Scenario: Manual utility consumes archive

- GIVEN an archived change contains operational evidence or gaps
- WHEN `sdd-operational-doc` is invoked manually
- THEN it MUST read archived evidence first
- AND absent values MUST remain pending or `No aplica.` without invention.

### Requirement: Manual Technical Document Boundary

The DAG MUST NOT treat `sdd-technical-doc` as a required phase. The utility MUST remain manual, post-archive, and archive-consuming, analogous to `sdd-operational-doc`. It MUST NOT change phase order, status routing, dependency graph, verify gates, archive gates, or required persistence artifacts. It MUST generate from archived evidence only, MUST NOT invent data, MUST mark inapplicable sections as `No aplica.`, and MUST mark unavailable applicable information explicitly.

#### Scenario: Archive completes without technical document

- GIVEN verify passes and archive criteria are met
- WHEN archive runs
- THEN completion MUST NOT require `sdd-technical-doc` execution
- AND missing technical documentation MUST NOT block archive.

#### Scenario: Status does not expose a required phase

- GIVEN status or continuation evaluates an active SDD change
- WHEN successor phases or required artifacts are computed
- THEN `sdd-technical-doc` MUST NOT appear as a required phase, DAG token, status dependency, verify input, or archive input.

#### Scenario: Manual utility consumes archived evidence

- GIVEN an archived change exists
- WHEN `sdd-technical-doc` is invoked manually
- THEN it MUST read archived evidence as its source of truth
- AND absent or inapplicable values MUST be represented without invention.

### Requirement: Final Documentation Restricted Data Boundary

Production hostnames, IPs, ports, SID/service names, and similar operational identifiers MAY be included only in final operational documentation when explicitly provided by the user. Ordinary SDD evidence and examples MUST preserve safe placeholders or references for applicable operational considerations.

#### Scenario: User provides final operational values

- GIVEN the user explicitly provides production operational identifiers for the manual document
- WHEN documentation is generated
- THEN the final operational document MAY include them
- AND SDD evidence artifacts MUST NOT be backfilled with those values.
