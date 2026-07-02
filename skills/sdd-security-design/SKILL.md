---
name: sdd-security-design
description: "Create the SDD security design artifact for security-impacting changes. Trigger: orchestrator launches security-design after technical design when applicability requires it."
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

Create `security-design.md` only for changes where `security-applicability.md` records `securityImpact: true`. Map applicable guidelines to design controls, downstream evidence, residual risks, and complete approved exceptions.

## Inputs

Read before writing:
- `security-applicability.md` from the selected artifact store.
- Proposal, specs, and technical `design.md`.
- `skills/_shared/security-guideline-catalog.md`.
- `skills/_shared/sdd-security-contract.md`.
- `openspec/config.yaml` when in OpenSpec or hybrid mode.

## Phase Artifact Contract

Common backend mechanics: follow `skills/_shared/persistence-contract.md` through **Section B** (retrieval) and **Section C** (persistence) in `skills/_shared/sdd-phase-common.md`.

| Concern | Contract |
| --- | --- |
| Required inputs | `security-applicability.md`, proposal, specs, technical `design.md`, `skills/_shared/security-guideline-catalog.md`, `skills/_shared/sdd-security-contract.md`, and OpenSpec config when applicable. |
| Produced artifact | `sdd/{change-name}/security-design` or `openspec/changes/{change-name}/security-design.md` only when `securityImpact: true`. |
| Mutates | None outside the conditional security design artifact. No artifact is created for no-impact changes. |
| Conditional behavior | If applicability is `no-impact` or `securityImpact: false`, return success with `next_recommended: test-design` and preserve `security-design.md` as not required. |
| Control/evidence mapping | For security-impacting changes, preserve guideline IDs, taxonomy categories, mandatory flags, required controls, expected evidence owners/statuses, residual risks, carried applicability risks, and complete approved exceptions. |
| Downstream obligations | Required controls and mandatory evidence expectations must remain consumable by `sdd-test-design`, `sdd-apply`, `sdd-verify`, and archive readiness checks. |
| Success routing | `next_recommended: test-design` whether the artifact is created or explicitly not required. |
| Block routing | `next_recommended: resolve-blockers` for missing required inputs, unknown guideline IDs, incomplete mandatory evidence/exception data, or validation failures. |

## Decision Gates

| Situation | Action |
| --- | --- |
| Security applicability or technical design is missing | Return `blocked` with `next_recommended: resolve-blockers`. |
| Applicability is `no-impact` or `securityImpact: false` | Do not create `security-design.md`; return success with `next_recommended: test-design`. |
| Applicability is `security-impacting` | Create `security-design.md`. |
| Applicable guideline ID is unknown | Return `blocked`; do not invent controls. |
| Mandatory evidence is missing without complete approved exception | Return `blocked` or fix the draft before persistence. |
| Applicability has `nonBlockingRisks` | Resolve each risk or carry it forward with owner phase and evidence expectation. |

## Control Mapping Rules

For every applicable guideline:
- Preserve `guidelineId`, `taxonomyCategory`, and `mandatoryWhenApplicable` from the catalog.
- Create a required control grounded in technical `design.md`.
- Add downstream evidence expectations for mandatory controls, normally owned by `test-design`, `apply`, `verify`, and/or `archive`.
- Use contract evidence statuses only: `not-started`, `planned`, `implemented`, `verified`, `not-applicable`, `exception-approved`, `blocked`.
- Record residual risk explicitly; use `None` only when no residual risk remains.

Approved exceptions are valid only when all fields exist: `status: exception-approved`, `guidelineId`, `approver`, `approvedAt`, `acceptedRiskRationale`, `mitigationOrFollowUp`, and `evidenceGap`.

## Artifact Format

Use this structure when security design is required:

````markdown
# Security Design: {Change Title}

```yaml
schemaName: gentle-ai.sdd-security-design
schemaVersion: 1
changeName: {change-name}
sourceApplicability: {path-or-topic-key}
controls:
  - guidelineId: SEC-...
    taxonomyCategory: <taxonomyCategory>
    mandatoryWhenApplicable: true
    requiredControl: <control description>
    expectedEvidence:
      - type: design-control | implementation-reference | test-design-check | verification-evidence | approved-exception
        ownerPhase: design | security-design | test-design | apply | verify | archive
        status: planned
        detail: <expected or observed evidence>
    residualRisk: <none-or-risk>
    exception: null
carriedRisks: []
nextRecommended: test-design
```

## Control Matrix
| Guideline ID | Category | Mandatory | Required Control | Evidence Owners | Residual Risk | Exception |
| --- | --- | --- | --- | --- | --- | --- |
| `SEC-...` | `category` | Yes/No | {control} | {owner phases} | {risk or None} | {None or complete exception} |

## Evidence Expectations
| Guideline ID | Evidence Type | Owner Phase | Status | Detail |
| --- | --- | --- | --- | --- |
| `SEC-...` | `test-design-check` | `test-design` | `planned` | {expected evidence} |

## Carried Applicability Risks
{Resolved or carried risks with owner and evidence expectation. Say "None" if none.}

## Archive Gate Notes
- Mandatory applicable controls block archive until evidence is verified or a complete approved exception is recorded.
- Incomplete exceptions do not satisfy archive readiness.
````

## Validation

Before persisting or returning, verify:
- `security-design.md` exists only for security-impacting changes.
- Every applicable guideline is represented in `controls` or explicitly justified as not applicable.
- Mandatory controls include downstream evidence expectations.
- Evidence statuses and owner phases use shared-contract vocabulary.
- Complete approved exceptions are the only exception evidence that can satisfy missing mandatory evidence.
- Artifact `nextRecommended` is `test-design`.

## Output

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`.

- Success when required: `next_recommended: test-design` and report controls/evidence/risks/exceptions.
- Success when no-impact: `next_recommended: test-design`, artifact location `not required`, and no file write.
- Blocked: `next_recommended: resolve-blockers`.

## Rules

- NEVER run before technical design completes.
- NEVER create placeholder `security-design.md` for no-impact changes.
- Use only shared catalog and security-contract vocabulary.
- Apply any `rules.security-design` from `openspec/config.yaml` if present.
