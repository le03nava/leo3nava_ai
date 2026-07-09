# sdd-security-guideline-catalog Specification

## Purpose

Define the in-repo corporate security guideline snapshot, compact taxonomy, matrix vocabulary, and evidence model used by narrative secure development design, security review, verification, and archive checks.

## Requirements

### Requirement: In-Repo Guideline Snapshot

The repository MUST maintain the corporate security guideline catalog as an in-repo snapshot based on the user-provided text. The catalog MUST preserve source text, identifiers, version metadata, and matrix vocabulary needed by narrative secure development design in `design.md#secure-development-design` and exhaustive `review-security-report.md` validation until an official external versioned source replaces it.

#### Scenario: Catalog snapshot is available

- GIVEN an SDD design or security review phase needs guideline context
- WHEN it reads the catalog
- THEN it MUST find guideline identifiers, source snapshot metadata, and applicable summaries
- AND it MUST support narrative secure design and security-review matrices.

#### Scenario: Catalog source changes later

- GIVEN an official external guideline source becomes available
- WHEN the catalog is updated
- THEN the change MUST preserve migration/audit metadata
- AND existing archived evidence MUST remain understandable.

### Requirement: Compact Security Taxonomy

The catalog MUST expose a compact taxonomy for phase prompts. The taxonomy MUST include authentication, sessions, sensitive data or PAN, secrets, permissions or access control, files, database access, and sensitive logging categories. `sdd-design` MUST use the taxonomy selectively for changed-surface planning; `sdd-review-security` MUST use it exhaustively for applicability validation.

#### Scenario: Security design uses taxonomy

- GIVEN a change modifies session behavior
- WHEN design maps the change
- THEN it MUST be able to select the sessions category
- AND it SHOULD avoid injecting unrelated full guideline text.

#### Scenario: Multiple categories apply

- GIVEN a change touches secrets and database access
- WHEN design maps guidelines
- THEN it MUST record both categories
- AND downstream security review MUST receive both mappings.

### Requirement: Mandatory Evidence Model

Each catalog guideline MUST declare whether it is mandatory when applicable and what evidence is expected across design, implementation, test/static/manual checks, security review, archive, or approved exceptions.

#### Scenario: Mandatory guideline has evidence expectations

- GIVEN a guideline is mandatory when applicable
- WHEN embedded secure development design consumes it
- THEN the guideline MUST provide expected evidence types
- AND security review MUST be able to verify coverage.

#### Scenario: Exception fields are required

- GIVEN mandatory evidence is unavailable
- WHEN an exception is recorded
- THEN it MUST include approver, guideline, accepted-risk rationale, and mitigation or follow-up
- AND archive MUST reject incomplete exception evidence.

### Requirement: Review Control Cross-References

The security guideline catalog MUST support cross-references from `sdd-review` controls and `sdd-review-security` rows to applicable guideline identifiers. These references MUST help reviewers cite standards without transferring guideline authority away from embedded secure development design and security review.

#### Scenario: Review cites a security guideline

- GIVEN a review checklist control evaluates a security concern
- WHEN the control maps to a catalog guideline
- THEN the review control SHOULD cite that guideline identifier
- AND embedded design/review-security MUST remain authoritative for required controls and final security verdict.

### Requirement: Review-Safe Security Evidence

The catalog SHOULD identify evidence types suitable for review rows, including implementation reference, static inspection, test evidence, approved exception, or N/A evidence. N/A MUST include evidence proving the category, platform, framework, API, or data class is irrelevant.

#### Scenario: Security row is N/A

- GIVEN a guideline row is marked N/A
- WHEN security review validates it
- THEN evidence MUST show why it is out of scope
- AND observations MUST explain why no security design control is required.

### Requirement: Catalog Boundary Preservation

The catalog MUST remain the source for security guideline identifiers, taxonomy, mandatory evidence expectations, exception fields, lifecycle statuses, matrix vocabulary, compact-control inventory, Source ID inventory, and safe-evidence policy. `sdd-review` MAY reference catalog entries but MUST NOT duplicate, redefine, or replace guideline text. Active authority MUST remain split between narrative design rules and exhaustive `review-security-report.md` validation. The catalog MUST NOT require design YAML, schema, matrices, exhaustive applicability, or `N/A` decisions.

#### Scenario: Catalog authority is preserved

- GIVEN embedded design and security review reference a guideline
- WHEN downstream verification compares evidence
- THEN catalog identifiers and statuses MUST remain consistent
- AND conflicts MUST resolve through narrative design context plus exhaustive review-security results.

### Requirement: Formal Source Coverage Mapping

Each compact `SEC-*` guideline MUST declare formal corporate source coverage through stable Source IDs from the in-repo snapshot. Source coverage MUST be treated as an audit obligation, not best-effort commentary, and each mapping MUST preserve catalog snapshot identity and version metadata.

#### Scenario: Guideline maps to corporate sources

- GIVEN a compact `SEC-*` guideline is listed in the catalog
- WHEN review-security validates source coverage
- THEN the guideline MUST expose one or more valid Source IDs
- AND the report MUST be able to cite those IDs as evidence refs.

#### Scenario: Source mapping is missing

- GIVEN a compact guideline lacks Source IDs
- WHEN catalog validation is performed
- THEN validation MUST fail for strict source coverage
- AND the missing mapping MUST be reported by guideline ID.

### Requirement: Operational Severity Vocabulary

The catalog MUST define operational applicability severity with only `blocking`, `conditional`, and `advisory`. `blocking` obligations MUST prevent phase success when unresolved, `conditional` obligations MUST apply when stated predicates are true, and `advisory` obligations SHOULD be preserved as downstream risk or guidance. The catalog MUST NOT use review labels such as `Menor`, `Media`, or `Mayor` for applicability blocking behavior.

#### Scenario: Blocking obligation prevents success

- GIVEN an applicable guideline has unresolved `blocking` evidence
- WHEN embedded design or security review evaluates completion
- THEN the phase MUST block
- AND the blocker MUST name the guideline and missing evidence.

#### Scenario: Conditional obligation predicate is false

- GIVEN a guideline is `conditional` and its predicate is not met
- WHEN embedded design evaluates the guideline
- THEN review-security MAY mark it not applicable
- AND it MUST record the predicate rationale.

### Requirement: Catalog Validator Contract

The catalog MUST support static validation of guideline IDs, taxonomy categories, Source IDs, severity values, lifecycle statuses, matrix values, mandatory evidence fields, and exception fields used by narrative `design.md` secure development rules and `review-security-report.md`. Validation MUST compare artifact references against the same catalog snapshot identity recorded in the artifact.

#### Scenario: Artifact references current catalog snapshot

- GIVEN a security artifact records a catalog snapshot identity
- WHEN static validation checks guideline and source references
- THEN references MUST resolve within that snapshot
- AND mismatched or unknown references MUST fail validation.

#### Scenario: Advisory evidence is preserved

- GIVEN an advisory guideline is applicable
- WHEN design records it
- THEN downstream phases SHOULD preserve it as risk or guidance
- AND archive evidence MUST remain understandable even if it does not block.

### Requirement: Security Matrix Vocabulary

The catalog MUST define matrix-facing values `Yes`, `No`, and `N/A` plus lifecycle statuses `not-started`, `planned`, `implemented`, `verified`, `not-applicable`, `exception-approved`, and `blocked` for review-security rows.

#### Scenario: Matrix row uses valid vocabulary

- GIVEN security review writes a matrix row
- WHEN validation runs
- THEN its answer and lifecycle status MUST use catalog vocabulary
- AND unsupported values MUST fail validation.

### Requirement: Corporate Source Row Inventory

The catalog MUST own the authoritative exhaustive corporate source-row inventory derived from `Full Corporate Guideline Snapshot`. The inventory MUST contain 155 expanded Source IDs, snapshot identity/version metadata, section grouping, guideline text, PCI alignment or `N/A`, mapped compact `SEC-*` guideline IDs, matrix vocabulary, and safe-evidence expectations. Range notation such as `1.1-1.10` MUST be expanded in the catalog before downstream validation. Design and test-design MUST reference applicable category guidance; review-security MUST expand the inventory exhaustively.

#### Scenario: Ranges expand before coverage

- GIVEN the snapshot contains a source range
- WHEN catalog coverage is validated
- THEN every concrete Source ID in the range MUST be represented exactly once
- AND missing, duplicate, or unknown Source IDs MUST block.

#### Scenario: PCI alignment is preserved

- GIVEN a corporate section heading includes PCI alignment
- WHEN source rows are produced
- THEN each row from that section MUST preserve the PCI requirement
- AND rows without alignment MUST state `N/A`.

#### Scenario: Selective artifacts reference catalog inventory

- GIVEN design or test-design needs source-row context
- WHEN it records coverage obligations
- THEN it MUST cite catalog snapshot/context and applicable category guidance instead of copying all 155 rows
- AND review-security MUST use the catalog to expand the exhaustive matrix.

### Requirement: Compact SEC Mapping Coverage

Every corporate source row MUST map to one or more existing compact `SEC-*` guideline IDs. The compact eight-control taxonomy MUST remain the architectural control layer and MUST NOT be replaced by per-source controls.

#### Scenario: Source row maps to compact controls

- GIVEN a Source ID is in the inventory
- WHEN catalog validation runs
- THEN it MUST resolve at least one valid compact `SEC-*` mapping
- AND unknown or missing mappings MUST block.

#### Scenario: Compact taxonomy is preserved

- GIVEN source rows are validated
- WHEN downstream phases consume the catalog
- THEN they MUST trace Source ID to compact `SEC-*`
- AND they MUST NOT create replacement compact controls.

### Requirement: Safe Source Row Evidence

Source-row evidence MUST be review-safe. Evidence locations and observations MUST NOT include secrets, PII, PAN, tokens, connection strings, private keys, or confidential values. Design MUST state safe-evidence policy for applicable category rules. `review-security-report.md` MUST justify every `N/A` row.

#### Scenario: Applicable row lacks safe evidence

- GIVEN a source row applies
- WHEN evidence is missing or unsafe
- THEN the row MUST be non-compliant and blocking
- AND the report MUST identify the unsafe or absent evidence.

#### Scenario: N/A row is justified

- GIVEN review-security marks a source row `N/A`
- WHEN validation reviews the row
- THEN evidence MUST prove irrelevance
- AND missing justification MUST block.

### Requirement: Shared Security Contract Source Row Schema

`skills/_shared/sdd-security-contract.md` MUST define the review-security report schema, allowed values, traceability, artifact boundary, narrative design obligations, exhaustive review-security obligations, safe-evidence policy, and routing. It MUST state that catalog owns inventory, design owns narrative category rules, test-design owns planned checks, review-security owns schema/matrix validation, and verify/archive preserve evidence without design YAML.

#### Scenario: Contract consumers share schema

- GIVEN a phase writes or validates source rows
- WHEN it reads the shared security contract
- THEN it MUST use the same row fields, allowed values, and artifact ownership boundary
- AND backend-specific storage MUST follow the persistence contract.

#### Scenario: Routing semantics are defined

- GIVEN source-row validation finds blockers or warnings
- WHEN a phase computes next routing
- THEN implementation blockers MUST route to apply, contract/artifact/N/A evidence blockers MUST route to resolve-blockers, and warnings-only results MAY route forward.

### Requirement: Operational Safe-Evidence Policy

The security guideline catalog MUST define safe-evidence policy for operational considerations when they apply. It SHOULD cover applicable logs/errors, monitoring mechanisms, administration operations, reprocessing/recovery, backup/retention/cleanup/generated artifacts, unresolved gaps, and final documentation boundaries. Monitoring evidence MUST be mechanism-oriented and MUST NOT be limited to SQL-only checks. The policy MUST NOT imply mandatory operational categories for every change.

#### Scenario: Monitoring evidence is categorized

- GIVEN a change requires operational monitoring evidence
- WHEN the catalog is consulted
- THEN it MUST support monitoring mechanisms such as dashboards, alerts, jobs, traces, scripts, or documented manual checks
- AND it MUST NOT require SQL-only evidence.

#### Scenario: Operational gap is safe

- GIVEN operational evidence is unavailable
- WHEN catalog policy is applied
- THEN exact `Pendiente de confirmar:` MUST be an accepted safe state for ordinary SDD evidence.

#### Scenario: Operational category is not applicable

- GIVEN design states an operational concern does not apply
- WHEN catalog policy is applied
- THEN exact `No aplica.` with optional rationale MUST satisfy the safe-evidence state.

### Requirement: Restricted Operational Data Classification

The catalog MUST classify production hostnames, IPs, ports, SID/service names, credentials, tokens, payloads, full ID lists, generated file bytes, and equivalent environment-specific operational details as restricted for ordinary SDD evidence, code, tests, fixtures, and examples. Final operational documentation MAY include user-provided restricted operational values. This classification MUST protect present operational evidence without creating mandatory readiness completeness gates.

#### Scenario: Restricted data appears in evidence

- GIVEN an SDD artifact cites restricted operational data
- WHEN catalog-based review-security validation runs
- THEN the evidence MUST be unsafe unless it is scoped to final user-provided operational documentation.

#### Scenario: Safe evidence is enough

- GIVEN a field is inapplicable
- WHEN catalog policy is applied
- THEN exact `No aplica.` with optional rationale MUST satisfy the safe-evidence state.
