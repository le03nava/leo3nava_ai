# sdd-security-applicability-workflow Specification

## Purpose

Define legacy security applicability compatibility after new-change classification moved into mandatory `sdd-security-design`.

## Requirements

### Requirement: Legacy-Only Applicability Classification

The SDD workflow MUST NOT provide, launch, or require a repo-local `sdd-security-applicability` executor or skill for new changes. Applicability classification MUST live in mandatory `sdd-security-design`. Legacy `security-applicability.md` artifacts MAY be read as historical data for archived or old changes and MUST NOT create active routing authority, artifact production, or executor availability for new changes.

#### Scenario: New change excludes applicability phase

- GIVEN a new SDD change completes `sdd-spec`
- WHEN routing is computed
- THEN the next planning phase MUST be `sdd-design`
- AND `sdd-security-applicability` MUST NOT appear in the active DAG.

#### Scenario: Legacy artifact is read-only

- GIVEN an archived change contains `security-applicability.md`
- WHEN compatibility readers inspect the archive
- THEN they MAY read it as historical evidence
- AND they MUST NOT require rerunning the phase.

#### Scenario: Executor and skill are absent

- GIVEN active repo-local SDD agents and skills are enumerated
- WHEN launchable security phases are resolved
- THEN no `sdd-security-applicability` executor or skill MUST be offered
- AND legacy artifacts MUST remain readable without launching one.

### Requirement: Blocking and Risk Rules

Security applicability blockers MUST be evaluated inside `sdd-security-design` for new changes. Legacy applicability blockers MAY remain visible when reading old artifacts, but MUST NOT block a new-change DAG edge.

#### Scenario: Design-changing information is missing

- GIVEN security-relevant scope is ambiguous in a way that could change required controls
- WHEN `sdd-security-design` evaluates classification
- THEN it MUST block or record risk there
- AND no `security-applicability.md` MUST be created.

#### Scenario: Minor evidence gap exists

- GIVEN a security impact is known but a non-decisive detail is incomplete
- WHEN `sdd-security-design` evaluates classification
- THEN it SHOULD continue when the gap is non-blocking
- AND it MUST record the gap as a security-design risk.

### Requirement: Artifact and Routing Contract

New changes MUST NOT produce `security-applicability.md`. The canonical classification artifact for new changes MUST be `security-design.md`, and routing MUST be `spec -> design -> security-design -> test-design`. Legacy compatibility readers MAY continue resolving old applicability artifact paths as data references without making them authoritative or mapping them to a runnable phase.

#### Scenario: Artifact is not produced

- GIVEN a new change needs security classification
- WHEN planning artifacts are persisted
- THEN `security-design.md` MUST contain classification
- AND `security-applicability.md` MUST be absent.

#### Scenario: Legacy data reference is resolved

- GIVEN an old change has `security-applicability.md`
- WHEN a reader resolves historical artifacts
- THEN the path MAY be resolved as legacy data
- AND no runnable applicability executor or skill MUST be required.

### Requirement: Complete Category Decision Matrix

For new changes, the complete category/guideline matrix MUST be recorded in `security-design.md`. Legacy applicability matrices MAY be parsed for archive readability only.

#### Scenario: Every category is evaluated

- GIVEN the catalog exposes supported taxonomy categories
- WHEN `sdd-security-design` writes its artifact
- THEN every category/guideline MUST be represented there
- AND applicability artifacts MUST NOT be authoritative.

#### Scenario: Unknown decision is design-changing

- GIVEN a category is marked `unknown` with `blocking` severity
- WHEN `sdd-security-design` evaluates the matrix
- THEN it MUST return blocked
- AND it MUST identify the missing evidence or decision.

### Requirement: Explicit No-Impact Proof

No-impact proof for new changes MUST be recorded as `not-applicable` matrix rows in `security-design.md`; absence of `security-design.md` MUST NOT prove no impact. Legacy no-impact proof remains readable only for old artifacts.

#### Scenario: Valid no-impact artifact

- GIVEN every category is `not-applicable` with evidence and rationale
- WHEN the new workflow runs
- THEN `security-design.md` MUST still be created
- AND `sdd-security-design` MUST NOT be skipped.

#### Scenario: Absence of evidence is insufficient

- GIVEN a change has no mapped guidelines but lacks no-impact rationale for one category
- WHEN `sdd-security-design` evaluates the matrix
- THEN `security-design.md` MUST NOT classify the change as no-impact
- AND the missing proof MUST be recorded as a blocker or risk by severity.

### Requirement: Supported Applicability Overrides

`openspec/config.yaml` MAY define legacy `rules.security-applicability` overrides only for reading old artifacts. New-change security-design overrides MUST NOT disable required categories, weaken formal source coverage, downgrade `blocking` obligations, bypass no-impact proof, or restore the applicability phase.

#### Scenario: Safe override is applied

- GIVEN config adds an extra design-changing unknown prompt
- WHEN security design evaluates a new change
- THEN the prompt MUST be considered in the matrix
- AND `security-design.md` MUST record the override source.

#### Scenario: Unsafe weakening is rejected

- GIVEN config attempts to disable source coverage or remove a required category
- WHEN security design loads overrides
- THEN the override MUST be rejected
- AND the phase MUST continue with the stricter base contract or block if ambiguity remains.

### Requirement: Static Applicability Validator

Static validation for new changes MUST target `security-design.md`. Any applicability validator MAY remain only for legacy archive checks and MUST NOT be required for new phase success.

#### Scenario: Legacy validator remains compatible

- GIVEN an archive contains old applicability evidence
- WHEN legacy validation is requested
- THEN the validator MAY check old schema fields
- AND it MUST NOT affect new-change routing.
