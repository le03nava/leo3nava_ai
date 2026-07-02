# sdd-security-guideline-catalog Specification

## Purpose

Define the in-repo corporate security guideline snapshot, compact taxonomy, and evidence model used by security applicability, security design, verification, and archive checks.

## Requirements

### Requirement: In-Repo Guideline Snapshot

The repository MUST maintain the initial corporate security guideline catalog as an in-repo snapshot based on the user-provided text. The catalog MUST preserve enough source text, identifiers, and version metadata for auditability until an official external versioned source replaces it.

#### Scenario: Catalog snapshot is available

- GIVEN an SDD security phase needs guideline context
- WHEN it reads the catalog
- THEN it MUST find guideline identifiers, source snapshot metadata, and applicable guideline text or summaries
- AND it MUST NOT depend on unavailable external policy documents.

#### Scenario: Catalog source changes later

- GIVEN an official external guideline source becomes available
- WHEN the catalog is updated
- THEN the change MUST preserve migration/audit metadata
- AND existing archived evidence MUST remain understandable.

### Requirement: Compact Security Taxonomy

The catalog MUST expose a compact taxonomy for phase prompts. The taxonomy MUST include authentication, sessions, sensitive data or PAN, secrets, permissions or access control, files, database access, and sensitive logging categories.

#### Scenario: Applicability uses taxonomy

- GIVEN a change modifies session behavior
- WHEN applicability maps the change
- THEN it MUST be able to select the sessions category
- AND it SHOULD avoid injecting unrelated full guideline text.

#### Scenario: Multiple categories apply

- GIVEN a change touches secrets and database access
- WHEN applicability maps guidelines
- THEN it MUST record both categories
- AND security design MUST receive both mappings.

### Requirement: Mandatory Evidence Model

Each catalog guideline MUST declare whether it is mandatory when applicable and what evidence is expected. Mandatory evidence MAY include design controls, implementation references, tests, static checks, manual review, or explicit approved exceptions.

#### Scenario: Mandatory guideline has evidence expectations

- GIVEN a guideline is mandatory when applicable
- WHEN security design consumes it
- THEN the guideline MUST provide expected evidence types
- AND downstream phases MUST be able to verify coverage.

#### Scenario: Exception fields are required

- GIVEN mandatory evidence is unavailable
- WHEN an exception is recorded
- THEN it MUST include approver, guideline, accepted-risk rationale, and mitigation or follow-up
- AND archive MUST reject incomplete exception evidence.

### Requirement: Review Control Cross-References

The security guideline catalog MUST support cross-references from `sdd-review` controls to applicable guideline identifiers. These references MUST help reviewers cite security standards in `review-report.md` without transferring security applicability, security design, or exception authority to review.

#### Scenario: Review cites a security guideline

- GIVEN a review checklist control evaluates a security concern
- WHEN the control maps to a catalog guideline
- THEN the review control SHOULD cite that guideline identifier
- AND security applicability/design MUST remain authoritative for applicability and required controls.

### Requirement: Review-Safe Security Evidence

The catalog SHOULD identify evidence types suitable for code review rows, including implementation reference, static inspection, test evidence, approved exception, or N/A evidence. N/A for platform-specific security controls MUST include evidence that the platform, framework, API, or data class is irrelevant to the change.

#### Scenario: Platform-specific security control is N/A

- GIVEN a security review control applies only to an unused platform
- WHEN review marks the control N/A
- THEN the evidence MUST show the platform is out of scope
- AND the comment MUST explain why no security design control is required.

### Requirement: Catalog Boundary Preservation

The catalog MUST remain the source for security guideline identifiers, taxonomy, mandatory evidence expectations, and exception fields. `sdd-review` MAY reference catalog entries but MUST NOT duplicate or redefine catalog guideline text.

#### Scenario: Catalog authority is preserved

- GIVEN review and security design both reference a guideline
- WHEN downstream verification compares evidence
- THEN catalog identifiers MUST remain consistent
- AND conflicts MUST be resolved in favor of security applicability/design outputs.
