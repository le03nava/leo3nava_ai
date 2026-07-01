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

## Persistence

Follow **Section B** and **Section C** from `skills/_shared/sdd-phase-common.md`.

| Mode | Read | Write |
| --- | --- | --- |
| `engram` | `sdd/{change-name}/proposal`, `sdd/{change-name}/spec` | `sdd/{change-name}/security-applicability` |
| `openspec` | `openspec/changes/{change-name}/proposal.md`, `specs/**/spec.md` | `openspec/changes/{change-name}/security-applicability.md` |
| `hybrid` | Both backends; block on material mismatch | Both backends |
| `none` | Current launch context only | Inline result only |

## Decision Gates

| Situation | Action |
| --- | --- |
| Proposal, specs, catalog, or contract is missing | Return `blocked` with `next_recommended: resolve-blockers`; do not write the artifact. |
| Missing information could change required security controls | Return `blocked`; name the missing decision area. |
| Security impact is known but a non-decisive detail is incomplete | Continue and record the gap in `nonBlockingRisks`. |
| No plausible security impact exists | Write a no-impact artifact with explicit evidence. |
| Any taxonomy category applies | Classify as `security-impacting` and map guideline IDs from the catalog. |

Design-changing decision areas are: `authentication`, `sessions`, `sensitive-data-pan`, `secrets`, `permissions-access-control`, `files`, `database-access`, and `sensitive-logging`.

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
taxonomyCategories: []
applicableGuidelines: []
evidenceSummary:
  - <proposal/spec evidence used for classification>
designChangingUnknowns: []
nonBlockingRisks: []
nextRecommended: design
```

## Classification Rationale
{Why this classification follows from proposal/spec evidence.}

## Guideline Mapping
| Guideline ID | Category | Mandatory When Applicable | Evidence |
| --- | --- | --- | --- |
| `SEC-...` | `category` | Yes/No | {proposal/spec evidence} |

## No-Impact Evidence
{Required for no-impact changes; otherwise say "Not applicable."}

## Blocking Unknowns
{Design-changing unknowns, or "None."}

## Security-Design Risks
{Non-blocking risks to carry forward, or "None."}
````

## Validation

Before persisting or returning, verify:
- `classification` and `securityImpact` agree.
- Security-impacting artifacts include at least one taxonomy category and guideline ID.
- No-impact artifacts include explicit no-impact evidence.
- All guideline IDs exist in the catalog.
- Blocking unknowns produce a blocked phase result, not a successful persisted artifact.
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
