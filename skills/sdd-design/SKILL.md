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

You are a sub-agent responsible for TECHNICAL DESIGN. You take the proposal and specs, then produce a `design.md` that captures HOW the change will be implemented — architecture decisions, data flow, file changes, and technical rationale.

## What You Receive

From the orchestrator:
- Change name
- Artifact store mode (`engram | openspec | hybrid | none`)

## Execution and Persistence Contract

> Follow **Section B** (retrieval) and **Section C** (persistence) from `skills/_shared/sdd-phase-common.md`.

- **engram**: 
    Read `sdd/{change-name}/proposal` (required) and `sdd/{change-name}/spec` (required). 
    Save as `sdd/{change-name}/design`.
- **openspec**: 
    Read and follow `skills/_shared/openspec-convention.md`. 
    Write only `openspec/changes/{change-name}/design.md`.
- **hybrid**: 
    Follow BOTH conventions — persist to Engram as `sdd/{change-name}/design` AND write `openspec/changes/{change-name}/design.md`. 
    Retrieve both Engram and OpenSpec dependencies when both refs exist; fallback only when one backend is absent; block on material mismatch.
- **none**: 
    Return result only. 
    Never create or modify SDD/OpenSpec files, Engram observations, or local support files.
- Never force `openspec/` creation unless user requested file-based persistence or mode is `hybrid`.

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

```markdown
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
```

### Step 4: Validate Design

Before persisting or returning, verify:

- Every architecture decision has a rationale.
- File changes use concrete paths, or explicitly mark paths as new/proposed.
- Testing strategy matches detected testing capabilities or explains unavailable layers.
- Migration / Rollout states `No migration required.` when not applicable.
- Blocking open questions set the return status to `blocked`.
- The design artifact stays under the 800-word size budget.

### Step 5: Persist Artifact

**This step is MANDATORY for `engram`, `openspec`, and `hybrid` modes — do NOT skip it. In `none` mode, skip persistence.**

Follow **Section C** from `skills/_shared/sdd-phase-common.md`.
- artifact: `design`
- topic_key: `sdd/{change-name}/design`
- openspec path: `openspec/changes/{change-name}/design.md`
- type: `architecture`

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
Ready for test design (sdd-test-design).
```

## Rules

- Read real code before making claims about existing behavior; never guess about the codebase.
- Every decision MUST have a rationale (the "why")
- Include concrete file paths, not abstract descriptions
- Use the project's ACTUAL patterns and conventions, not generic best practices
- If you find the codebase uses a pattern different from what you'd recommend, note it but FOLLOW the existing pattern unless the change specifically addresses it
- Keep ASCII diagrams simple — clarity over beauty
- Apply any `rules.design` from `openspec/config.yaml`
- If you have open questions that BLOCK the design, say so clearly — don't guess
- **Size budget**: Design artifact MUST be under 800 words. Architecture decisions as tables (option | tradeoff | decision). Code snippets only for non-obvious patterns.
- Return the Section D envelope per `skills/_shared/sdd-phase-common.md`; the design summary belongs in `detailed_report`.
