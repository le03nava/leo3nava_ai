---
name: sdd-test-design
description: "Create the SDD test design artifact between technical design and task planning. Trigger: orchestrator launches test-design for a change."
disable-model-invocation: true
user-invocable: false
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  delegate_only: true
---

> **ORCHESTRATOR GATE**: Follow `skills/_shared/executor-boundary.md`.
> This skill is for the dedicated `sdd-test-design` executor only.

## Language Domain Contract

Follow `skills/_shared/language-domain-contract.md`.

## Purpose

You are a sub-agent responsible for TEST DESIGN. You take the proposal, specs, and technical design, then produce `test-design.md` that maps scenarios, design risks, and behavior contracts to planned automated, manual, or static checks before task planning begins.

## What You Receive

From the orchestrator:
- Change name
- Artifact store mode (`engram | openspec | hybrid | none`)
- Structured status from `skills/_shared/sdd-status-contract.md` when available
- Artifact refs/paths for proposal, specs, and design

## Execution and Persistence Contract

> Follow **Section B** (retrieval) and **Section C** (persistence) from `skills/_shared/sdd-phase-common.md`.

- **engram**: Read `sdd/{change-name}/proposal` (required), `sdd/{change-name}/spec` (required), and `sdd/{change-name}/design` (required). Save as `sdd/{change-name}/test-design`.
- **openspec**: Read and follow `skills/_shared/openspec-convention.md`. Write only `openspec/changes/{change-name}/test-design.md`.
- **hybrid**: Follow BOTH conventions — persist to Engram as `sdd/{change-name}/test-design` AND write `openspec/changes/{change-name}/test-design.md`. Retrieve both Engram and OpenSpec dependencies when both refs exist; fallback only when one backend is absent; block on material mismatch.
- **none**: Return SDD artifact content inline only. Never create or modify SDD/OpenSpec files, Engram observations, or local support files.
- Never force `openspec/` creation unless user requested file-based persistence or mode is `hybrid`.

## Output Contract

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`. Put the test-design summary in `detailed_report`.

Routing rules for `next_recommended`:
- **Successful test design**: return `next_recommended: tasks`. The orchestrator normalizes this into state `nextRecommended: tasks` before routing or persisting state.
- **Blocked test design**: return `next_recommended: resolve-blockers` and include the exact missing proposal, spec, design, testability decision, or artifact validation issue in `risks` / `detailed_report`.
- **Partial persistence failure**: return `next_recommended: resolve-blockers` unless the same artifact can be safely retried without new user input.
- Do not return camelCase `nextRecommended` from the phase envelope. CamelCase is for status/state artifacts only.

## Decision Gates

| Situation | Action |
| --- | --- |
| Required proposal, spec, or design is missing | Return `blocked` with `next_recommended: resolve-blockers`; do not write test design. |
| Specs/design have no behavior or testability impact | Write a no-impact assessment in `test-design.md`; do not treat the artifact as absent. |
| A mandatory spec scenario or design risk has no planned check and no justified skip | Return `blocked` or fix the draft before persistence. |
| `engram` mode | Do not create `openspec/`; persist only `sdd/{change-name}/test-design`. |
| `openspec` mode | Write only `openspec/changes/{change-name}/test-design.md`; do not call `mem_save`. |
| `hybrid` mode | Write OpenSpec test design and persist the Engram artifact. |
| `none` mode | Return inline only; do not write files and do not call `mem_save`. |
| Test-design draft fails validation | Fix it before persistence; if it cannot be fixed, return `blocked` with `next_recommended: resolve-blockers`. |

## What to Do

### Step 1: Load Skills

Follow **Section A** from `skills/_shared/sdd-phase-common.md`.

### Step 2: Read Required Inputs

Before writing the artifact, read:
- Proposal: user intent, scope, non-goals, risks, and success criteria.
- Specs: requirements and scenarios that need coverage.
- Design: architecture decisions, data flow, file changes, contracts, and testing strategy.
- Testing capabilities when available:
  - Engram: `sdd/{project}/testing-capabilities`
  - OpenSpec: `openspec/config.yaml` `testing` section
  - Hybrid: read both and apply the Hybrid Conflict Policy if they disagree
  - None: use only current-session testing context provided by the orchestrator

### Step 3: Identify Test Design Inputs

Collect planned checks from:
- Spec scenarios and RFC 2119 requirements.
- Design risks, compatibility decisions, routing/state/persistence contracts, migrations, and rollout notes.
- Testing capability constraints such as unavailable runners, missing coverage tooling, or static-only repositories.

If there is no behavior or testability impact, write a concise no-impact assessment instead of inventing checks.

### Step 4: Write test-design.md

**IF mode is `openspec` or `hybrid`:** Create the test-design document:

```text
openspec/changes/{change-name}/
├── proposal.md
├── specs/
├── design.md
└── test-design.md          ← You create this
```

**IF mode is `engram` or `none`:** Do NOT create any `openspec/` directories or files. Compose the test-design content in memory; persist it only if the mode allows persistence.

#### Test Design Document Format

```markdown
# Test Design: {Change Title}

## Overview

{One paragraph summarizing the behavior/testability surface and testing constraints.}

## Inputs

| Artifact | Reference | Used For |
| --- | --- | --- |
| Proposal | {path-or-topic} | {scope/intent summary} |
| Spec | {path-or-topic} | {requirements/scenarios summary} |
| Design | {path-or-topic} | {architecture/risk summary} |

## Test Cases

| ID | Source | Check | Type | Severity | Expected Evidence | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| TD-001 | Spec: {requirement/scenario} | {planned check} | automated/manual/static | mandatory/non-mandatory | {command, artifact, file-contract check, or manual evidence} | {constraints/dependencies} |

## No-Impact Assessment

{Required only when no behavior or testability impact exists. State why no checks are needed.}

## Evidence Expectations

- Mandatory cases require implementation, execution, static/manual evidence, or a justified skip.
- Non-mandatory cases should be reported as warnings when uncovered, but they do not block verification by themselves.

## Open Questions

- [ ] {Only questions that block reliable test planning. Say "None" if there are no blockers.}
```

Valid `Type` values: `automated`, `manual`, `static`.
Valid `Severity` values: `mandatory`, `non-mandatory`.

### Step 5: Validate Test Design

Before persisting or returning, verify:
- Every behavior-impacting spec scenario or design risk has a linked test case, or a justified omission.
- Each test case has `ID`, `Source`, `Check`, `Type`, `Severity`, `Expected Evidence`, and `Notes`.
- `Type` is one of `automated`, `manual`, or `static`.
- `Severity` is one of `mandatory` or `non-mandatory`.
- Mandatory cases are verification-blocking when uncovered.
- Non-mandatory cases are advisory and become verification warnings when uncovered.
- Static/manual checks are allowed when no runtime test runner exists.
- No-impact changes include the no-impact assessment and still produce the artifact.
- Blocking open questions set the return status to `blocked`.

### Step 6: Persist Artifact

**This step is MANDATORY for `engram`, `openspec`, and `hybrid` modes — do NOT skip it. In `none` mode, skip persistence.**

Follow **Section C** from `skills/_shared/sdd-phase-common.md`.
- artifact: `test-design`
- topic_key: `sdd/{change-name}/test-design`
- openspec path: `openspec/changes/{change-name}/test-design.md`
- type: `architecture`

### Step 7: Return Summary

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`. Put this test-design summary in `detailed_report`:

```markdown
## Test Design Created

**Change**: {change-name}
**Location**: `openspec/changes/{change-name}/test-design.md` (openspec/hybrid) | Engram `sdd/{change-name}/test-design` (engram) | inline (none)

### Summary
- **Inputs**: Proposal, specs, and design read.
- **Cases Planned**: {N mandatory, M non-mandatory; automated/manual/static counts}
- **No-Impact Assessment**: {present/not applicable}
- **Testing Constraints**: {detected runner/static/manual constraints}

### Open Questions
{List any unresolved questions, or "None"}

### Next Step
Ready for tasks (sdd-tasks).
```

## Rules

- ALWAYS read proposal, specs, and design before writing test design.
- DO NOT implement tests or code; this phase plans evidence only.
- DO NOT skip the artifact for no-impact changes; document the no-impact assessment.
- Prefer scenario-linked, evidence-focused checks over broad testing wishes.
- Match testing capabilities; do not invent unavailable runners or commands.
- Apply any `rules.test-design` from `openspec/config.yaml` if present.
- Return the Section D envelope per `skills/_shared/sdd-phase-common.md`; the test-design summary belongs in `detailed_report`.
