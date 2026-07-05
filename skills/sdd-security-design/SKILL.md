---
name: sdd-security-design
description: "Legacy/read-only security-design workflow. New changes use design.md#secure-development-design instead."
disable-model-invocation: true
user-invocable: false
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  delegate_only: true
---

> **ORCHESTRATOR GATE**: Follow `skills/_shared/executor-boundary.md`.
> This skill is for the dedicated `sdd-security-design` executor only.

## Language Domain Contract

Follow `skills/_shared/language-domain-contract.md`.

## Purpose

This standalone phase is retired for new changes. Secure development design is owned by `sdd-design` inside `design.md#secure-development-design`; standalone `security-design.md` is legacy/read-only archive compatibility data only.

## Inputs

Read before writing:
- Proposal, specs, and technical `design.md` from the selected artifact store.
- `skills/_shared/security-guideline-catalog.md`.
- `skills/_shared/sdd-security-contract.md`.
- `openspec/config.yaml` when in OpenSpec or hybrid mode.
- Legacy `security-applicability.md` only when the orchestrator explicitly identifies an old or archived compatibility context; it is not a new-change dependency.

## Phase Artifact Contract

Common backend mechanics: follow `skills/_shared/persistence-contract.md` through **Section B** (retrieval) and **Section C** (persistence) in `skills/_shared/sdd-phase-common.md`.

| Concern | Contract |
| --- | --- |
| Required inputs | Proposal, specs, technical `design.md`, `skills/_shared/security-guideline-catalog.md`, `skills/_shared/sdd-security-contract.md`, and OpenSpec config when applicable. |
| Produced artifact | None for new changes. Legacy `sdd/{change-name}/security-design` or `openspec/changes/{change-name}/security-design.md` may be read only as archive compatibility data. |
| Mutates | None. New changes do not create or update standalone security-design artifacts. |
| Conditional behavior | New-change launches MUST block and route back to `design`/`test-design`; no-impact is represented as justified rows inside `design.md#secure-development-design`. |
| Control/evidence mapping | Preserve guideline IDs, taxonomy categories, mandatory flags, operational severity/source refs where available, validation metadata, required controls, expected evidence owners/statuses, residual risks, carried risks, N/A rationale, and complete approved exceptions. |
| Downstream obligations | Required controls and mandatory evidence expectations must remain consumable by `sdd-test-design`, `sdd-apply`, `sdd-verify`, and archive readiness checks. |
| Success routing | None for new changes; this phase should not be launched. |
| Block routing | `next_recommended: resolve-blockers` for missing required inputs, unknown guideline IDs, incomplete mandatory evidence/exception data, or validation failures. |

## Decision Gates

| Situation | Action |
| --- | --- |
| Proposal, specs, technical design, catalog, or security contract is missing | Return `blocked` with `next_recommended: resolve-blockers`. |
| New active change launches this phase | Return `blocked` with `next_recommended: resolve-blockers`; route active work through `sdd-design` and `sdd-test-design`. |
| Legacy/archive context explicitly provided | Read only for compatibility; do not create or mutate standalone `security-design.md`. |
| Applicable guideline ID is unknown | Return `blocked`; do not invent controls. |
| Mandatory evidence is missing without complete approved exception | Return `blocked` or fix the draft before persistence. |
| Proposal/spec/design context leaves classification ambiguous | Return `blocked` or carry non-blocking risks forward with owner phase and evidence expectation when safe. |

## Control Mapping Rules

For every guideline row:
- Preserve `guidelineId`, `taxonomyCategory`, and `mandatoryWhenApplicable` from the catalog.
- Preserve catalog `snapshotId`, `catalogVersion`/`taxonomyVersion`, source refs, operational severity, classification rationale/evidence refs, and validation metadata.
- Create a required control grounded in technical `design.md` for applicable rows; create explicit N/A rationale and evidence for not-applicable rows.
- Translate `blocking` and true `conditional` obligations into controls, downstream evidence expectations, residual risks, or complete approved exceptions.
- Preserve `advisory` obligations as downstream-visible risk or guidance rather than dropping them because they are non-blocking.
- Add downstream evidence expectations for mandatory controls, normally owned by `test-design`, `apply`, `verify`, and/or `archive`.
- Use contract evidence statuses only: `not-started`, `planned`, `implemented`, `verified`, `not-applicable`, `exception-approved`, `blocked`.
- Record residual risk explicitly; use `None` only when no residual risk remains.

Do not consume legacy applicability decision-matrix fields as mandatory new-change inputs. Legacy no-impact routing remains archive-readable only for old artifacts; new changes always use `design.md#secure-development-design`.

Approved exceptions are valid only when all fields exist: `status: exception-approved`, `guidelineId`, `approver`, `approvedAt`, `acceptedRiskRationale`, `mitigationOrFollowUp`, and `evidenceGap`.

## Legacy Artifact Format

Legacy archived standalone security-design artifacts may use this historical structure. Do not create it for new changes:

````markdown
# Security Design: {Change Title}

```yaml
schemaName: gentle-ai.sdd-security-design
schemaVersion: 1
changeName: {change-name}
classification: security-impacting | no-impact
securityImpact: true | false
catalog:
  snapshotId: {catalog-snapshot-id}
  taxonomyVersion: 1
  source: skills/_shared/security-guideline-catalog.md
controls:
  - guidelineId: SEC-...
    taxonomyCategory: <taxonomyCategory>
    mandatoryWhenApplicable: true
    operationalSeverity: blocking | conditional | advisory
    sourceRefs: []
    requiredControl: <control description>
    expectedEvidence:
      - type: design-control | implementation-reference | test-design-check | verification-evidence | approved-exception
        ownerPhase: design | test-design | apply | verify | archive
        status: planned
        detail: <expected or observed evidence>
    residualRisk: <none-or-risk>
    exception: null
carriedRisks: []
validation:
  status: manual-pending | pass | fail
    validator: legacy/archive manual validation only; no active validator script is required
  notes: <manual/static validation metadata or unavailable-validator note>
nextRecommended: test-design
```

## Security Matrix
| Guideline ID | Category | Applies | Lifecycle Status | Required Control | Evidence Owner | Evidence Location | Observations |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SEC-...` | `category` | Yes/No/N/A | `planned`/`not-applicable`/... | {control or N/A rationale} | {owner phases} | {path/section refs} | {safe observations} |

## Evidence Expectations
| Guideline ID | Evidence Type | Owner Phase | Status | Detail |
| --- | --- | --- | --- | --- |
| `SEC-...` | `test-design-check` | `test-design` | `planned` | {expected evidence} |

## Carried Applicability Risks
{Resolved or carried risks with owner and evidence expectation. Say "None" if none.}

## Archive Gate Notes
- Mandatory applicable controls block archive until evidence is verified or a complete approved exception is recorded.
- Incomplete exceptions do not satisfy archive readiness.
- `review-security-report.md` must be present and non-blocking before verify/archive.
````

## Validation

Before persisting or returning, verify:
- New changes do not create or require standalone `security-design.md`.
- No-impact changes still contain every guideline/category row with `N/A` / `not-applicable` rationale and evidence.
- Artifacts preserve `catalog` identity, matrix/source refs, operational severity where known, and validation metadata in controls, rows, or carried risks.
- Every guideline is represented in controls, matrix rows, or explicitly justified as not applicable.
- Mandatory controls include downstream evidence expectations.
- Evidence statuses and owner phases use shared-contract vocabulary.
- Complete approved exceptions are the only exception evidence that can satisfy missing mandatory evidence.
- Artifact `nextRecommended` is `test-design`.

## Output

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`.

- New-change launch: `blocked`, `next_recommended: resolve-blockers`, and report that `design.md#secure-development-design` is the active authority.
- Legacy/archive read: report compatibility context only; do not mutate artifacts.

## Rules

- NEVER run before technical design completes.
- NEVER create or require standalone `security-design.md` for new changes; no-impact must be documented inside `design.md#secure-development-design`.
- Use only shared catalog and security-contract vocabulary.
- Treat any `rules.security-design` from `openspec/config.yaml` as legacy/read-only compatibility context only.
