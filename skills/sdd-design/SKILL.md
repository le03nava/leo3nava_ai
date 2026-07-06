---
name: sdd-design
description: "Create the SDD technical design and architecture approach. Trigger: orchestrator launches design for a change."
disable-model-invocation: true
user-invocable: false
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  delegate_only: true
---

> **ORCHESTRATOR GATE**: Follow `skills/_shared/executor-boundary.md`.
> This skill is for the dedicated `sdd-design` executor only.

## Language Domain Contract

Follow `skills/_shared/language-domain-contract.md`.

## Purpose

You are a sub-agent responsible for TECHNICAL DESIGN and embedded secure development design. You take the proposal and specs, then produce a `design.md` that captures HOW the change will be implemented — architecture decisions, data flow, file changes, security guideline classification, controls, expected evidence, and technical rationale.

## What You Receive

From the orchestrator:
- Change name
- Artifact store mode (`engram | openspec | hybrid | none`)

## Phase Artifact Contract

Common backend mechanics: follow `skills/_shared/persistence-contract.md`.

| Concern | Contract |
| --- | --- |
| Required inputs | Proposal and specs: `sdd/{change-name}/{proposal|spec}` or OpenSpec change-folder equivalents, plus `skills/_shared/security-guideline-catalog.md` and `skills/_shared/sdd-security-contract.md`. |
| Produced artifact | `sdd/{change-name}/design` or `openspec/changes/{change-name}/design.md`. |
| Mutates | None outside the produced design artifact. |
| Secure design authority | For every new change, `design.md#secure-development-design` is the active classification, compact control, Source ID coverage, lifecycle, evidence-owner, residual-risk, N/A rationale, and exception authority. It includes all eight compact SEC IDs from the catalog exactly once. |
| Source-row coverage | When the catalog declares corporate source rows, the embedded section MUST declare slim expected Source ID coverage below the compact controls: catalog snapshot identity/path, `expectedSourceIdCount: 155`, source section/group references, compact mappings, lifecycle status, evidence owners, N/A evidence/justification policy, safe-evidence policy, downstream traceability, and `review-security` as the full-expansion owner. It MUST NOT copy the exhaustive 155-row Source ID inventory when the catalog is available. |
| Secure design schema | The embedded section MUST include the minimum YAML fields from `skills/_shared/sdd-security-contract.md` (`schemaName`, `schemaVersion`, `changeName`, `classification`, `securityImpact`, `sourceInputs`, `catalog`, `taxonomyEvaluation`, `controls`, optional/required source-row coverage metadata when applicable, `notApplicableGuidelines`, `exceptions`, `carriedRisks`, `validation`, `archiveGateNotes`, `nextRecommended`). A compact human table MUST precede or immediately summarize source-row coverage for reviewability, but the YAML contract is authoritative. |
| Success routing | `next_recommended: test-design`; the next active phase is `sdd-test-design`. |
| Block routing | `next_recommended: resolve-blockers` for missing proposal/specs, missing code context, testing capability ambiguity, or unresolved architecture decisions. |

## Output Contract

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`. Put the design summary in `detailed_report`.

Routing rules for `next_recommended`:
- **Successful design**: return `next_recommended: test-design`. The orchestrator normalizes this into state `nextRecommended: test-design` before routing or persisting state.
- **Blocked design**: return `next_recommended: resolve-blockers` and include the exact missing proposal, spec, code context, testing capability, or architecture decision in `risks` / `detailed_report`.
- **Partial design**: return `next_recommended: resolve-blockers` unless the same design artifact can be safely retried without new user input.
- Do not return camelCase `nextRecommended` from the phase envelope. CamelCase is for status/state artifacts only.

## Decision Gates

| Situation | Action |
| --- | --- |
| Required proposal is missing | Return `blocked` with `next_recommended: resolve-blockers`; do not write design. |
| Specs are missing | Return `blocked` with `next_recommended: resolve-blockers`; do not write design. |
| Affected code cannot be identified | Return `partial` with `next_recommended: resolve-blockers` if useful design context was produced; otherwise return `blocked` with `next_recommended: resolve-blockers`. Do not invent paths. |
| Open questions block implementation decisions | Return `blocked` with `next_recommended: resolve-blockers` and list the blocking questions. |
| Security classification cannot be proven from proposal/specs/code context | Return `blocked` with `next_recommended: resolve-blockers`; do not guess `security-impacting` or `no-impact`. |
| Data sensitivity is unknown for touched inputs, outputs, storage, logs, exports, or external interfaces | Treat as a design-changing unknown for `SEC-DATA-001`; return `blocked` unless the design can prove safe classification with review-safe evidence. |
| Any `N/A` / `not-applicable` security row lacks evidence proving category/platform/API/data/workflow irrelevance | Fix before persistence, or return `blocked` with `next_recommended: resolve-blockers`. |
| Any applicable mandatory guideline lacks control, downstream evidence owner, expected evidence, residual-risk statement, or archive expectation | Fix before persistence, or return `blocked` with `next_recommended: resolve-blockers`. |
| Required corporate Source ID coverage is missing, unmapped, lacks lifecycle/evidence owners, or omits N/A evidence/justification | Fix before persistence, or return `blocked` with `next_recommended: resolve-blockers`. |
| Any exception lacks approver, approvedAt, accepted-risk rationale, mitigation/follow-up, or evidence gap | Return `blocked`; incomplete exceptions cannot satisfy design or archive readiness. |
| `engram` mode | Do not create `openspec/`; persist only `sdd/{change-name}/design`. |
| `openspec` mode | Write only `openspec/changes/{change-name}/design.md`; do not call `mem_save`. |
| `hybrid` mode | Write OpenSpec design and persist the Engram artifact. |
| `none` mode | Return inline only; do not write files and do not call `mem_save`. |
| Design draft fails validation | Fix it before persistence; if it cannot be fixed, return `blocked` with `next_recommended: resolve-blockers`. |

## What to Do

### Step 1: Load Skills
Follow **Section A** from `skills/_shared/sdd-phase-common.md`.

### Step 2: Read the Codebase

Before making claims about existing behavior, read the actual code that will be affected:
- Entry points and module structure
- Existing patterns and conventions
- Dependencies and interfaces
- Test infrastructure (if any)

Build a compact design-time security inventory before writing the secure section:
- Trust boundaries and external inputs crossed by the change.
- Data classes touched: public, internal, confidential, PII, PAN, credentials, tokens, keys, or unknown.
- Authentication, session, authorization, file, database, logging, error-reporting, export, and configuration/secrets touchpoints.
- Existing controls that are preserved, changed, removed, or newly required.
- Evidence locations that prove `N/A` rows without exposing secrets, PAN, PII, tokens, private keys, connection strings, or confidential values.

Also read before writing:
- `skills/_shared/sdd-security-contract.md` and `skills/_shared/security-guideline-catalog.md` for the mandatory embedded secure development design row contract.
- For new changes, classify security impact and plan evidence only in `design.md#secure-development-design`; the design phase does not create a separate security-design artifact.

Also read testing capabilities when available:
- Engram: `sdd/{project}/testing-capabilities`
- OpenSpec: `openspec/config.yaml` `testing` section

If affected code or testing capabilities cannot be found, state that limitation in the return envelope instead of guessing.

### Step 3: Write design.md

**IF mode is `openspec` or `hybrid`:** Create the design document:

```
openspec/changes/{change-name}/
├── proposal.md
├── specs/
└── design.md              ← You create this
```

**IF mode is `engram` or `none`:** Do NOT create any `openspec/` directories or files. Compose the design content in memory; persist it only if the mode allows persistence.

#### Design Document Format

````markdown
# Design: {Change Title}

## Technical Approach

{Concise description of the overall technical strategy.
How does this map to the proposal's approach? Reference specs.}

## Architecture Decisions

### Decision: {Decision Title}

**Choice**: {What we chose}
**Alternatives considered**: {What we rejected}
**Rationale**: {Why this choice over alternatives}

### Decision: {Decision Title}

**Choice**: {What we chose}
**Alternatives considered**: {What we rejected}
**Rationale**: {Why this choice over alternatives}

## Data Flow

{Describe how data moves through the system for this change.
Use ASCII diagrams when helpful.}

    Component A ──→ Component B ──→ Component C
         │                              │
         └──────── Store ───────────────┘

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `path/to/new-file.ext` | Create | {What this file does} |
| `path/to/existing.ext` | Modify | {What changes and why} |
| `path/to/old-file.ext` | Delete | {Why it's being removed} |

## Interfaces / Contracts

{Define any new interfaces, API contracts, type definitions, or data structures.
Use code blocks with the project's language.}

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit | {What} | {How} |
| Integration | {What} | {How} |
| E2E | {What} | {How} |

## Migration / Rollout

{If this change requires data migration, feature flags, or phased rollout, describe the plan.
If not applicable, state "No migration required."}

## Open Questions

- [ ] {Any unresolved technical question}
- [ ] {Any decision that needs team input}

## Secure Development Design

```yaml
schemaName: gentle-ai.sdd-embedded-secure-design
schemaVersion: 1
changeName: {change-name}
classification: security-impacting | no-impact
securityImpact: true | false
securityImpactRationale: {why this classification is proven from proposal/specs/code context}
sourceInputs:
  proposal: {path-or-topic-key}
  specs:
    - {path-or-topic-key}
  design: {path-or-topic-key}#secure-development-design
catalog:
  snapshotId: security-guidelines-initial-user-snapshot-2026-06-30
  catalogVersion: 1
  taxonomyVersion: 1
  source: skills/_shared/security-guideline-catalog.md
taxonomyEvaluation:
  - category: authentication
    guidelineId: SEC-AUTH-001
    applies: Yes | N/A
    decision: applicable | not-applicable
    lifecycleStatus: planned | not-applicable | exception-approved | blocked
    rationale: {why it applies or review-safe evidence proving out-of-scope}
    evidenceRefs: [{path-or-section-or-topic}]
controls:
  - guidelineId: SEC-AUTH-001
    taxonomyCategory: authentication
    mandatoryWhenApplicable: true
    operationalSeverity: blocking
    sourceRefs: [{catalog source IDs}]
    requiredControl: {control description or N/A preservation statement}
    expectedEvidence:
      - type: design-control | implementation-reference | test-design-check | verification-evidence | approved-exception
        ownerPhase: test-design | tasks | apply | review-security | verify | archive
        status: planned | not-applicable | exception-approved | blocked
        detail: {review-safe expected evidence}
    residualRisk: none | {risk carried forward}
    exception: null | {complete approved exception fields}
sourceRowCoverage:
  schema: corporate-source-row-operational-layer
  inventoryAuthority: skills/_shared/security-guideline-catalog.md#corporate-source-row-operational-inventory
  expectedSourceIdCount: {number from catalog when applicable}
  expectedSourceUniverse: {catalog-owned universe summary; do not duplicate the full inventory}
  coverageRule: {exact-once coverage and compact mapping rule; full expansion belongs to review-security}
  validCompactGuidelineIds: [SEC-AUTH-001, SEC-SESS-001, SEC-DATA-001, SEC-SECRET-001, SEC-ACCESS-001, SEC-FILE-001, SEC-DB-001, SEC-LOG-001]
  lifecycleStatus: planned | not-applicable | exception-approved | blocked
  evidenceOwners: [design | test-design | apply | review-security | verify | archive]
  downstreamTraceability: {Source ID -> compact SEC-* -> design -> test-design -> apply -> review-security -> verify -> archive}
  safeEvidencePolicy: {review-safe evidence policy}
  notApplicablePolicy: {N/A evidence and justification policy}
  exceptionPolicy: {complete approved exception policy}
  fullExpansionOwner: review-security
  groups:
    - corporateSection: {section name}
      pciAlignment: {PCI requirement or N/A}
      sourceIdRef: {range or grouped reference backed by catalog inventory}
      count: {group count from catalog}
      mappedCompactGuidelineIds: [SEC-...]
      lifecycleStatus: planned | not-applicable | exception-approved | blocked
      evidenceOwners: [design | test-design | apply | review-security | verify | archive]
notApplicableGuidelines:
  - guidelineId: SEC-...
    taxonomyCategory: {taxonomyCategory}
    applies: N/A
    lifecycleStatus: not-applicable
    rationale: {positive out-of-scope rationale with evidence}
exceptions: null | [{complete approved exception fields}]
carriedRisks: []
validation:
  method: design.md#secure-development-design static/manual review
  status: pass | fail | manual-pending
  checkedAt: {iso-8601-or-manual}
  notes: {validation notes, unavailable-tooling note, or blocker summary}
archiveGateNotes: []
nextRecommended: test-design
```

Compact matrix summary:

| Guideline | Applies / lifecycle | Rationale | Secure design decision / control | Evidence owner / expected evidence | Residual risk / exception |
| --- | --- | --- | --- | --- | --- |
| `SEC-AUTH-001` | `Yes`/`N/A` / `<lifecycle>` | <rationale> | <control or N/A preservation> | <owner phase and evidence> | <risk or none / exception details> |
| `SEC-SESS-001` | `Yes`/`N/A` / `<lifecycle>` | <rationale> | <control or N/A preservation> | <owner phase and evidence> | <risk or none / exception details> |
| `SEC-DATA-001` | `Yes`/`N/A` / `<lifecycle>` | <rationale> | <control or N/A preservation> | <owner phase and evidence> | <risk or none / exception details> |
| `SEC-SECRET-001` | `Yes`/`N/A` / `<lifecycle>` | <rationale> | <control or N/A preservation> | <owner phase and evidence> | <risk or none / exception details> |
| `SEC-ACCESS-001` | `Yes`/`N/A` / `<lifecycle>` | <rationale> | <control or N/A preservation> | <owner phase and evidence> | <risk or none / exception details> |
| `SEC-FILE-001` | `Yes`/`N/A` / `<lifecycle>` | <rationale> | <control or N/A preservation> | <owner phase and evidence> | <risk or none / exception details> |
| `SEC-DB-001` | `Yes`/`N/A` / `<lifecycle>` | <rationale> | <control or N/A preservation> | <owner phase and evidence> | <risk or none / exception details> |
| `SEC-LOG-001` | `Yes`/`N/A` / `<lifecycle>` | <rationale> | <control or N/A preservation> | <owner phase and evidence> | <risk or none / exception details> |
````

Secure development design rules:

- Include all eight guideline IDs exactly once: `SEC-AUTH-001`, `SEC-SESS-001`, `SEC-DATA-001`, `SEC-SECRET-001`, `SEC-ACCESS-001`, `SEC-FILE-001`, `SEC-DB-001`, and `SEC-LOG-001`.
- Treat `## Secure Development Design` as the active security authority for the change: classification, category applicability, controls, evidence owners, lifecycle statuses, residual risks, and exceptions all live in this section.
- The YAML block is the authoritative machine-readable contract. The compact matrix is reviewer-facing summary and MUST NOT contradict the YAML block.
- Keep the compact eight-control summary visible before source-row coverage references. Source rows are evidence detail below compact controls, not replacement controls.
- When corporate source-row validation applies, declare expected Source ID coverage from the catalog snapshot/path, `expectedSourceIdCount: 155`, grouped section references, compact `SEC-*` mapping, lifecycle status, evidence owners, downstream traceability, and safe-evidence/N/A policies in `design.md#secure-development-design`.
- Source-row coverage SHOULD be grouped by corporate section when the full expanded inventory is already present in the shared catalog. The design MUST preserve expected count, exact-once rule, valid compact mappings, evidence ownership, lifecycle/N/A status, and `review-security` full-expansion ownership without materializing every concrete Source ID.
- Do NOT duplicate the general 96-control `sdd-review` matrix or the exhaustive 155-row Source ID matrix in design. Cite compact `SEC-*` controls, catalog snapshot/path, grouped source references, and expected count for secure-design planning.
- Use only matrix values `Yes` or `N/A` during design. `No` is reserved for review-security when required evidence is missing or failing.
- Use only lifecycle statuses from the catalog: `not-started`, `planned`, `implemented`, `verified`, `not-applicable`, `exception-approved`, or `blocked`.
- Each guideline row MUST preserve `taxonomyCategory`, `mandatoryWhenApplicable`, `operationalSeverity`, source refs/source IDs, evidence refs, lifecycle status, and downstream owner-phase evidence expectations.
- Every `N/A` / `not-applicable` row MUST include rationale and evidence proving why the category, platform, API, data class, or workflow is out of scope.
- Applicable rows MUST identify secure design decisions/controls, downstream evidence owners, expected evidence, residual risks, and archive expectations.
- Exception rows MUST include approver, approvedAt, accepted-risk rationale, mitigation/follow-up, and evidence gap. Incomplete exceptions do not satisfy archive readiness.
- Evidence MUST be review-safe: cite paths, sections, summaries, command outputs, or redacted placeholders; never include raw secrets, credentials, PAN, PII, tokens, private keys, connection strings, or confidential values.

### Step 4: Validate Design

Before persisting or returning, verify:

- Every architecture decision has a rationale.
- File changes use concrete paths, or explicitly mark paths as new/proposed.
- Testing strategy matches detected testing capabilities or explains unavailable layers.
- `## Secure Development Design` is present, records catalog snapshot/version metadata, includes all eight SEC rows exactly once, preserves N/A rationale/evidence, and uses valid lifecycle vocabulary.
- When the catalog requires corporate source-row coverage, the secure design declares the expected Source ID universe by catalog reference, valid compact mappings, lifecycle status, evidence owners, safe-evidence policy, N/A evidence/justification policy, and downstream traceability from Source ID -> compact SEC-* -> test-design/apply/review-security/verify/archive evidence.
- Compact `SEC-*` summary remains readable before grouped source-row coverage, and the design does not copy the general 96-control review matrix or the exhaustive 155-row Source ID matrix.
- The embedded YAML follows `skills/_shared/sdd-security-contract.md` minimum fields and the compact table does not contradict it.
- Security classification is evidence-backed; unknown data sensitivity, auth/session/access boundaries, secret/config handling, file/database behavior, or sensitive logging implications block success rather than being guessed.
- Applicable rows include controls, evidence owners, expected evidence, residual risk, and archive expectations; exception rows include complete exception fields.
- Every applicable mandatory guideline has a downstream evidence owner in `test-design`, `tasks`, `apply`, `review-security`, `verify`, or `archive`.
- Safe-evidence rules are followed for `SEC-DATA-001`, `SEC-SECRET-001`, `SEC-ACCESS-001`, and `SEC-LOG-001`.
- Migration / Rollout states `No migration required.` when not applicable.
- Blocking open questions set the return status to `blocked`.
- Keep narrative design content compact. The 800-word budget applies to narrative sections and does not justify omitting mandatory secure-design YAML fields, all eight SEC rows, exception data, or evidence obligations.

### Step 5: Persist Artifact

**This step is MANDATORY for `engram`, `openspec`, and `hybrid` modes — do NOT skip it. In `none` mode, skip persistence.**

Follow **Section C** from `skills/_shared/sdd-phase-common.md`.
- artifact: `design`
- topic_key: `sdd/{change-name}/design`
- openspec path: `openspec/changes/{change-name}/design.md`
- type: `architecture`

After persistence succeeds, route directly to `sdd-test-design` / `test-design`. Do not produce a standalone security-design artifact as part of the new-change DAG.

### Step 6: Return Summary

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`. Put this design summary in `detailed_report`:

```markdown
## Design Created

**Change**: {change-name}
**Location**: `openspec/changes/{change-name}/design.md` (openspec/hybrid) | Engram `sdd/{change-name}/design` (engram) | inline (none)

### Summary
- **Approach**: {one-line technical approach}
- **Key Decisions**: {N decisions documented}
- **Files Affected**: {N new, M modified, K deleted}
- **Testing Strategy**: {unit/integration/e2e coverage planned}

### Open Questions
{List any unresolved questions, or "None"}

### Next Step
Ready for test design (`sdd-test-design`).
```

## Rules

- Read real code before making claims about existing behavior; never guess about the codebase.
- For new changes, keep security classification and secure design evidence inside `design.md#secure-development-design`; the next active phase after successful design is `sdd-test-design`.
- Every decision MUST have a rationale (the "why")
- Include concrete file paths, not abstract descriptions
- Use the project's ACTUAL patterns and conventions, not generic best practices
- If you find the codebase uses a pattern different from what you'd recommend, note it but FOLLOW the existing pattern unless the change specifically addresses it
- Keep ASCII diagrams simple — clarity over beauty
- Apply any `rules.design` from `openspec/config.yaml`
- On successful design only, return `next_recommended: test-design`; blocked or partial results MUST route to `resolve-blockers` unless the same design artifact can be safely retried without new user input.
- If you have open questions that BLOCK the design, say so clearly — don't guess
- **Size budget**: Keep narrative sections around 800 words when practical. Architecture decisions as tables (option | tradeoff | decision). Code snippets only for non-obvious patterns. Do not omit mandatory secure-design schema fields, SEC rows, evidence obligations, or exception data to satisfy the narrative budget.
- Return the Section D envelope per `skills/_shared/sdd-phase-common.md`; the design summary belongs in `detailed_report`.
