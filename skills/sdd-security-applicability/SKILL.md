---
name: sdd-security-applicability
description: "Classify SDD security applicability and write security-applicability.md. Trigger: orchestrator launches security-applicability after specs."
disable-model-invocation: true
user-invocable: false
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  delegate_only: true
---

> **ORCHESTRATOR GATE**: Follow `skills/_shared/executor-boundary.md`.
> This skill is for the dedicated `sdd-security-applicability` executor only.

## Language Domain Contract

Follow `skills/_shared/language-domain-contract.md`.

## Purpose

Classify every new SDD change after specs and before technical design. Produce `security-applicability.md` with either explicit no-impact evidence or mapped security guideline impact.

## Inputs

Read before writing:
- Proposal and specs from the selected artifact store.
- `skills/_shared/security-guideline-catalog.md` for taxonomy, guideline IDs, mandatory flags, and expected evidence.
- `skills/_shared/sdd-security-contract.md` for schema, vocabulary, and exception/evidence rules.
- `openspec/config.yaml` when in OpenSpec or hybrid mode.

## Phase Artifact Contract

Common backend mechanics: follow `skills/_shared/persistence-contract.md` through **Section B** (retrieval) and **Section C** (persistence) in `skills/_shared/sdd-phase-common.md`.

| Concern | Contract |
| --- | --- |
| Required inputs | Proposal and specs from the selected backend, plus `skills/_shared/security-guideline-catalog.md`, `skills/_shared/sdd-security-contract.md`, and OpenSpec config when applicable. |
| Produced artifact | `sdd/{change-name}/security-applicability` or `openspec/changes/{change-name}/security-applicability.md`. |
| Mutates | None outside the produced security applicability artifact. |
| Artifact identity | Preserve `schemaName: gentle-ai.sdd-security-applicability`, `schemaVersion`, `changeName`, `classification`, `securityImpact`, taxonomy categories, guideline mappings, evidence summary, unknowns, risks, and artifact-local `nextRecommended`. |
| Classification behavior | No-impact changes require explicit no-impact proof for every supported category and keep `securityImpact: false`; any applicable taxonomy category classifies the change as security-impacting and maps catalog guideline IDs. |
| Routing behavior | Artifact-local `nextRecommended` remains `design`; downstream orchestrator routing uses `securityImpact` to skip or require `sdd-security-design` after technical design. Missing `security-design.md` is not a blocker for no-impact changes. |
| Success routing | `next_recommended: design`. |
| Block routing | `next_recommended: resolve-blockers` for missing required inputs, design-changing unknowns, invalid guideline IDs, unsafe overrides, incomplete no-impact proof, unsupported severity, or validation failures. |

## Decision Gates

| Situation | Action |
| --- | --- |
| Proposal, specs, catalog, or contract is missing | Return `blocked` with `next_recommended: resolve-blockers`; do not write the artifact. |
| Missing information could change required security controls | Return `blocked`; name the missing decision area. |
| Security impact is known but a non-decisive detail is incomplete | Continue and record the gap in `nonBlockingRisks`. |
| No plausible security impact exists | Write a no-impact artifact with explicit evidence. |
| Any taxonomy category applies | Classify as `security-impacting` and map guideline IDs from the catalog. |
| A taxonomy category remains `unknown` with `blocking` severity | Return `blocked`; name the category and missing evidence. |
| Config attempts to weaken required categories, source coverage, blocking severity, or no-impact proof | Reject or ignore the override in favor of the base contract; block if ambiguity remains. |

Design-changing decision areas are: `authentication`, `sessions`, `sensitive-data-pan`, `secrets`, `permissions-access-control`, `files`, `database-access`, and `sensitive-logging`.

## Config Overrides

When OpenSpec config is available, inspect `rules.security-applicability` before writing the artifact.

Supported overrides are intentionally narrow and may only make evaluation stricter or more explicit:

- `extraPrompts`: additional design-changing unknown prompts to consider in category rationale.
- `strictSourceCoverage`: stricter source-reference requirements for mapped guidelines.
- `validatorMode`: stricter validator behavior or manual/static validation mode metadata.
- `categorySeverity`: category severity overrides only when they keep or increase strictness.

Unsupported or weakening overrides MUST NOT change the base contract. They must be recorded in `overridesApplied` with `safety: rejected-unsafe` or `safety: ignored-unsafe`, and the phase must block if the attempted override leaves security applicability ambiguous.

## Artifact Format

Use this structure:

````markdown
# Security Applicability: {Change Title}

```yaml
schemaName: gentle-ai.sdd-security-applicability
schemaVersion: 1
changeName: {change-name}
classification: security-impacting | no-impact
securityImpact: true | false
catalog:
  snapshotId: {catalog-snapshot-id}
  taxonomyVersion: 1
  source: skills/_shared/security-guideline-catalog.md
taxonomyCategories: []
applicableGuidelines: []
categoryDecisionMatrix:
  - category: authentication
    decision: applicable | not-applicable | unknown
    severity: blocking | conditional | advisory
    rationale: <proposal/spec/config evidence for this category>
    evidenceRefs: []
    guidelineIds: []
    sourceIds: []
  - category: sessions
    decision: applicable | not-applicable | unknown
    severity: blocking | conditional | advisory
    rationale: <proposal/spec/config evidence for this category>
    evidenceRefs: []
    guidelineIds: []
    sourceIds: []
  - category: sensitive-data-pan
    decision: applicable | not-applicable | unknown
    severity: blocking | conditional | advisory
    rationale: <proposal/spec/config evidence for this category>
    evidenceRefs: []
    guidelineIds: []
    sourceIds: []
  - category: secrets
    decision: applicable | not-applicable | unknown
    severity: blocking | conditional | advisory
    rationale: <proposal/spec/config evidence for this category>
    evidenceRefs: []
    guidelineIds: []
    sourceIds: []
  - category: permissions-access-control
    decision: applicable | not-applicable | unknown
    severity: blocking | conditional | advisory
    rationale: <proposal/spec/config evidence for this category>
    evidenceRefs: []
    guidelineIds: []
    sourceIds: []
  - category: files
    decision: applicable | not-applicable | unknown
    severity: blocking | conditional | advisory
    rationale: <proposal/spec/config evidence for this category>
    evidenceRefs: []
    guidelineIds: []
    sourceIds: []
  - category: database-access
    decision: applicable | not-applicable | unknown
    severity: blocking | conditional | advisory
    rationale: <proposal/spec/config evidence for this category>
    evidenceRefs: []
    guidelineIds: []
    sourceIds: []
  - category: sensitive-logging
    decision: applicable | not-applicable | unknown
    severity: blocking | conditional | advisory
    rationale: <proposal/spec/config evidence for this category>
    evidenceRefs: []
    guidelineIds: []
    sourceIds: []
noImpactProof:
  status: not-applicable | complete | incomplete
  summary: <positive no-impact proof, or why no-impact does not apply>
  evidenceRefs: []
overridesApplied: []
validation:
  validator: scripts/validate_security_applicability.ps1
  status: pass | fail | manual-pending
  checkedAt: <iso-8601-or-manual>
  notes: <static validation result or unavailable-validator note>
evidenceSummary:
  - <proposal/spec evidence used for classification>
designChangingUnknowns: []
nonBlockingRisks: []
nextRecommended: design
```

## Classification Rationale
{Why this classification follows from proposal/spec evidence.}

## Guideline Mapping
| Guideline ID | Category | Mandatory When Applicable | Evidence | Source Coverage Evidence |
| --- | --- | --- | --- | --- |
| `SEC-...` | `category` | Yes/No | {proposal/spec evidence} | {Source IDs or PR 2 pending note} |

## No-Impact Evidence
{Required for no-impact changes; otherwise say "Not applicable."}

## Overrides Applied
{Supported `rules.security-applicability` overrides applied, rejected, or ignored. If none, say "None."}

## Validation Evidence
{Validator metadata, static/manual inspection result, or explicit reason validation could not run yet. Missing runtime tooling is not pass evidence.}

## Blocking Unknowns
{Design-changing unknowns, or "None."}

## Security-Design Risks
{Non-blocking risks to carry forward, or "None."}
````

## Validation

Before persisting or returning, verify:
- `classification` and `securityImpact` agree.
- `catalog.snapshotId` and `catalog.taxonomyVersion` are present.
- `categoryDecisionMatrix` includes every supported category exactly once: `authentication`, `sessions`, `sensitive-data-pan`, `secrets`, `permissions-access-control`, `files`, `database-access`, and `sensitive-logging`.
- Every matrix row includes `decision`, `severity`, `rationale`, `evidenceRefs`, `guidelineIds`, and `sourceIds`.
- Severity values use only `blocking`, `conditional`, or `advisory`.
- Security-impacting artifacts include at least one taxonomy category and guideline ID.
- No-impact artifacts include explicit no-impact proof: every category is `not-applicable`, every row has rationale and evidence refs, `noImpactProof.status: complete`, and there are no design-changing unknowns.
- Absence of mapped guidelines is never treated as no-impact proof.
- All guideline IDs exist in the catalog.
- Source refs resolve when catalog source metadata is available; strict source coverage failures block when configured or required by the catalog contract.
- `overridesApplied` records supported safe overrides and rejected/ignored unsafe overrides.
- Blocking unknowns produce a blocked phase result, not a successful persisted artifact.
- Validation metadata is present and success is blocked when validation fails.
- Artifact `nextRecommended` is `design`.

## Output

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`.

- Success: `next_recommended: design`.
- Blocked: `next_recommended: resolve-blockers`.
- Include classification, categories, guideline IDs, blocking unknowns, risks, and artifact location in `detailed_report`.

## Rules

- ALWAYS run after specs and before technical design for new DAG changes.
- NEVER skip `security-applicability.md`, including no-impact changes.
- Use only catalog taxonomy categories and guideline IDs.
- Apply any `rules.security-applicability` from `openspec/config.yaml` if present.
- Preserve artifact identity and no-impact routing compatibility. Additive fields do not make `security-design.md` mandatory when a no-impact artifact has complete proof and valid validation metadata.
