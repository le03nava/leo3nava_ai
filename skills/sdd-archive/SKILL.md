---
name: sdd-archive
description: "Archive a completed SDD change by syncing delta specs. Trigger: orchestrator launches archive after implementation and verification."
disable-model-invocation: true
user-invocable: false
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
  delegate_only: true
---

> **ORCHESTRATOR GATE**: Follow `skills/_shared/executor-boundary.md`.
> This skill is for the dedicated `sdd-archive` executor only.

## Language Domain Contract

Follow `skills/_shared/language-domain-contract.md`.

## Purpose

You are a sub-agent responsible for ARCHIVING. You merge delta specs into the main specs (source of truth), then move the change folder to the archive. You complete the SDD cycle.

In `engram` mode, archive means lineage and closure report only; it does not promote specs into a shared filesystem source-of-truth tree.

## What You Receive

From the orchestrator:
- Change name
- Artifact store mode (`engram | openspec | hybrid | none`)
- Structured status from `skills/_shared/sdd-status-contract.md`, including artifact paths, task progress, dependency states, and actionContext
- Any explicit intentional archive override text from the user/orchestrator

## Phase Artifact Contract

Common backend mechanics: follow `skills/_shared/persistence-contract.md` through **Section B** (retrieval) and **Section C** (persistence) in `skills/_shared/sdd-phase-common.md`.

| Concern | Contract |
| --- | --- |
| Required inputs | Proposal, specs, design with mandatory `## Secure Development Design`, `test-design`, tasks, non-blocking `review-report.md` / `sdd/{change-name}/review`, non-blocking `review-security-report.md` / `sdd/{change-name}/review-security-report`, and passing `verify-report` from the selected backend. Standalone `security-design.md` is legacy/read-only compatibility data only. |
| Produced artifact | Archive report as `sdd/{change-name}/archive-report`; in OpenSpec, the archive audit-trail reference is `openspec/changes/archive/YYYY-MM-DD-{change-name}/`. |
| Mutates | OpenSpec/hybrid source specs under `openspec/specs/{domain}/spec.md`; OpenSpec/hybrid change folder location from active change to dated archive; Engram/hybrid archive report lineage. |
| Spec sync semantics | Merge delta specs before moving the change folder. Preserve unrelated requirements; create missing main specs from full new specs; require explicit reason/migration for removals and explicit old/new names for renames. |
| Archive move semantics | Move the entire change folder to the dated archive destination, never overwrite an existing archive folder, and verify the active change folder is gone and archived contents are complete. |
| Destructive-delta warnings | Stop before destructive merges, large removals, unresolved removals, or ambiguous renames; return `confirmation_required: destructive-merge` for orchestrator-owned confirmation. |
| Audit-trail semantics | Record artifact refs/observation IDs or concrete paths, synced domains and counts, task completion status, general review verdict/blocking state, security review verdict/blocking state, verify verdict, embedded secure-design validation metadata, secure design/control evidence and N/A rationale, archive destination, warnings, and any approved reconciliation. |
| Source-row preservation | When corporate source-row validation applies, preserve source-row coverage summary, catalog snapshot identity/path, exact Source ID count, compact `SEC-*` mappings, non-blocking warnings, complete exceptions, safe evidence references, `N/A` evidence/justification status, and review-security/verify verdict links. Archive MUST NOT require legacy standalone `security-design.md` or `scripts/validate_security_design.ps1` for active new changes, and MUST NOT copy the full review-security source-row matrix into archive summaries. |
| Conditional behavior | Engram mode records lineage and closure without filesystem promotion; `none` mode returns inline closure only and must not claim durable archive, source-of-truth sync, or recoverable completion. |
| Success routing | `next_recommended: none` after archive report persistence and selected-backend read-back verification succeed. |
| Block routing | `next_recommended: review`, `review-security`, `verify`, `apply`, or `resolve-blockers` according to missing/blocking review evidence, missing verify evidence, unchecked tasks, missing embedded secure design, unsafe context, destructive merge, destination conflict, or persistence failure. |

## Output Contract

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`. Put the full archive summary in `detailed_report`.

## Routing Contract

- Successful archive -> return `next_recommended: none`.
- Missing `review-report` or unreadable/ambiguous review evidence -> return `next_recommended: review`.
- Missing `review-security-report` or unreadable/ambiguous security review evidence -> return `next_recommended: review-security`.
- Blocking `review-report` findings -> return `next_recommended: apply`.
- Missing or non-passing `verify-report` -> return `next_recommended: verify`.
- Persisted tasks contain unchecked implementation tasks without approved stale-checkbox reconciliation -> return `next_recommended: apply`.
- Missing proposal/spec/design/test-design without explicit partial-archive approval -> return `next_recommended: resolve-blockers`.
- Missing mandatory embedded secure design or mandatory security evidence without complete approved exceptions -> return `next_recommended: resolve-blockers`.
- Destructive merge confirmation, unsafe action context, archive destination conflict, or archive operation outside `allowedEditRoots` -> return `next_recommended: resolve-blockers`.
- Status `partial` after filesystem operations -> return `next_recommended: resolve-blockers` and include exact recovery steps in `detailed_report`.
- Do not return camelCase `nextRecommended` from the phase envelope. CamelCase is for status/state artifacts only.

### Task Completion Gate

`sdd-apply` is responsible for marking completed tasks in the persisted tasks artifact. `sdd-archive` is responsible for validating that the persisted artifact reflects the final state before closing the cycle.

Before syncing specs or moving any archive folder, inspect the tasks artifact:

- **engram**: read the full `sdd/{change-name}/tasks` observation.
- **openspec/hybrid**: read `openspec/changes/{change-name}/tasks.md`.

If any implementation task remains unchecked (`- [ ]`):

1. STOP and return `blocked` with `next_recommended: apply`; do not sync specs, move the change folder, or claim the SDD cycle is complete.
2. Report that `sdd-apply` must be rerun or corrected so it marks completed tasks in the persisted tasks artifact.
3. Only proceed if the orchestrator explicitly instructs you to reconcile stale checkboxes and `apply-progress`/`verify-report` prove every unchecked task is complete. If you do this exceptional repair, record the exact reconciliation reason in the archive report.

The archived audit trail MUST NOT contain stale unchecked tasks for completed work. Internal todo state is not enough; the persisted SDD task artifact is the source of truth for completion visibility.

### Strict-vs-OpenSpec Archive Policy

OpenSpec permits archiving with incomplete artifacts or tasks after a user confirmation. gentle-ai is stricter by default:

- Incomplete implementation tasks block archive unless they are stale checkboxes and apply-progress/verify-report prove completion.
- Blocking findings in `review-report` / `review-security-report` and CRITICAL issues in `verify-report` always block archive. Do not accept an override for blocking review findings or CRITICAL verification issues.
- Missing mandatory security evidence blocks archive unless every gap has a complete approved exception with approver, guideline ID, accepted-risk rationale, and mitigation or follow-up.
- `sdd-archive` does not own normal task completion. `sdd-apply` owns checkbox completion; archive may only perform exceptional mechanical reconciliation with proof from apply-progress and verify-report.
- Missing proposal/spec/design/test-design artifacts should be reported. Archive may continue only when the user explicitly chooses an intentional partial archive and the archive report records what was missing.

### Action Context Guard

- If structured status reports `actionContext.mode: workspace-planning`, STOP. Do not move workspace changes into repo-local archives or edit linked repos.
- If `allowedEditRoots` is present, archive operations must stay inside those roots.

## Decision Gates

| Condition | Action |
|---|---|
| `review-report` is missing, unreadable, or ambiguous | Return `blocked` with `next_recommended: review`; archive readiness cannot be proven. |
| `review-report` contains blocking findings, CRITICAL review failures, or a blocking verdict | Return `blocked` with `next_recommended: apply`; do not archive. |
| `review-security-report` is missing, unreadable, or ambiguous | Return `blocked` with `next_recommended: review-security`; archive readiness cannot be proven. |
| `review-security-report` contains blocking findings, CRITICAL security review failures, or a blocking verdict | Return `blocked` with `next_recommended: apply`; do not archive. |
| `review-security-report` has unresolved corporate source-row blockers, missing/duplicate/unknown Source IDs, malformed schema, missing compact mappings, unsafe evidence, unsupported `N/A`, or missing mandatory source-row evidence | Return `blocked`; route to `apply` for implementation/contract evidence remediation and to `resolve-blockers` for catalog/schema/artifact/unsafe-evidence/unsupported-`N/A` causes. |
| `verify-report` is missing | Return `blocked` with `next_recommended: verify`; archive readiness cannot be proven. |
| `verify-report` contains CRITICAL issues or verdict `FAIL` | Return `blocked` with `next_recommended: apply`; do not accept an override. |
| Persisted tasks contain unchecked implementation tasks | Return `blocked` with `next_recommended: apply` unless explicitly approved stale-checkbox reconciliation is backed by apply-progress and verify-report proof. |
| Proposal/spec/design/test-design artifacts are missing | Return `blocked` with `next_recommended: resolve-blockers` unless the orchestrator provides explicit intentional partial archive approval. |
| `design.md#secure-development-design` is missing for a new active change | Return `blocked` with `next_recommended: resolve-blockers`; do not archive. |
| Standalone `security-design.md` is missing for a new active change | Continue; do not require it. It is legacy/read-only compatibility data only. |
| Mandatory applicable security evidence is missing | Return `blocked` with `next_recommended: resolve-blockers` unless each gap has a complete approved exception. |
| Security exception lacks approver, guideline ID, accepted-risk rationale, or mitigation/follow-up | Return `blocked` with `next_recommended: resolve-blockers`; incomplete exceptions do not satisfy archive readiness. |
| `actionContext.mode: workspace-planning` | Return `blocked` with `next_recommended: resolve-blockers`; do not move folders or edit linked repos. |
| Archive operation would leave `allowedEditRoots` | Return `blocked` with `next_recommended: resolve-blockers` and report the offending path. |
| Delta spec removal lacks `(Reason: ...)` or `(Migration: ...)` | Return `blocked` with `next_recommended: resolve-blockers`; do not delete from main specs. |
| Delta spec rename lacks explicit old and new requirement names | Return `blocked` with `next_recommended: resolve-blockers`; do not rename in main specs. |
| Merge would be destructive or remove large sections | Return `blocked` with `next_recommended: resolve-blockers` and `confirmation_required: destructive-merge`; the orchestrator owns confirmation. |
| Archive destination already exists | Return `blocked` with `next_recommended: resolve-blockers` unless the orchestrator provides an explicit alternate destination. |
| Archive verification fails after filesystem operations | Return `partial` with `next_recommended: resolve-blockers` and exact failed checks and recovery paths. |
| Archive report persistence fails | Return `partial` with `next_recommended: resolve-blockers` and the full archive report inline in `detailed_report`. |

## What to Do

### Step 1: Load Skills
Follow **Section A** from `skills/_shared/sdd-phase-common.md`.

### Step 2: Sync Delta Specs to Main Specs

Do not start this step until the **Task Completion Gate** above passes.

**IF mode is `engram`:** Skip filesystem sync — artifacts live in Engram only. The archive report (Step 5) records all observation IDs for traceability.

**IF mode is `none`:** Skip — no artifacts to sync.

**IF mode is `openspec` or `hybrid`:** For each delta spec in `openspec/changes/{change-name}/specs/`:

#### If Main Spec Exists (`openspec/specs/{domain}/spec.md`)

Read the existing main spec and apply the delta:

```
FOR EACH SECTION in delta spec:
├── ADDED Requirements → Append to main spec's Requirements section
├── MODIFIED Requirements → Replace the matching requirement in main spec
├── REMOVED Requirements → Delete the matching requirement from main spec after recording Reason/Migration
└── RENAMED Requirements → Rename the matching requirement while preserving scenarios unless the delta also modifies them
```

**Merge carefully:**
- Match requirements by name (e.g., "### Requirement: Session Expiration")
- Preserve all OTHER requirements that aren't in the delta
- Maintain proper Markdown formatting and heading hierarchy
- For REMOVED requirements, require `(Reason: ...)` and `(Migration: ...)` notes in the delta before deleting from main specs
- For RENAMED requirements, require the old and new requirement names to be explicit
- If the merge would be destructive, STOP before editing and return `blocked` with `next_recommended: resolve-blockers` and `confirmation_required: destructive-merge`

#### If Main Spec Does NOT Exist

The delta spec IS a full spec (not a delta). Copy it directly:

```bash
# Copy new spec to main specs
openspec/changes/{change-name}/specs/{domain}/spec.md
  → openspec/specs/{domain}/spec.md
```

### Step 3: Move to Archive

**IF mode is `engram`:** Skip — there are no `openspec/` directories to move. The archive report in Engram serves as the audit trail.

**IF mode is `none`:** Skip — no filesystem operations.

**IF mode is `openspec` or `hybrid`:** Move the entire change folder to archive with date prefix:

```
openspec/changes/{change-name}/
  → openspec/changes/archive/YYYY-MM-DD-{change-name}/
```

Use today's date in ISO format (e.g., `2026-02-16`).
If the destination already exists, STOP and return `blocked` with the existing destination path. Do not overwrite or mutate an existing archive folder.

### Step 4: Verify Archive

**IF mode is `openspec` or `hybrid`:** Confirm:
- [ ] Main specs updated correctly
- [ ] Change folder moved to archive
- [ ] Archive contains all artifacts (proposal, specs, design, test-design, tasks)
- [ ] Archive contains design artifact with mandatory `## Secure Development Design`
- [ ] Embedded secure-design validation metadata or static/manual notes are preserved and non-failing, or archive stops with a blocker
- [ ] Archive contains `review-report.md` / review artifact with a non-blocking verdict
- [ ] Archive contains `review-security-report.md` / security review artifact with a non-blocking verdict
- [ ] Missing `test-design.md` is blocked unless an explicit partial archive exception is provided and recorded in the archive report
- [ ] Mandatory applicable security evidence is verified or covered by complete approved exceptions recorded in the audit trail
- [ ] Archived `tasks.md` has no unchecked implementation tasks, unless the orchestrator explicitly approved archive-time stale-checkbox reconciliation backed by apply-progress/verify-report proof
- [ ] Active changes directory no longer has this change
- [ ] Archive report lists all synced domains, archive destination, verification verdict, and any intentional-with-warnings reason

**IF mode is `engram`:** Confirm all artifact observation IDs are recorded in the archive report and the tasks observation has no unchecked implementation tasks unless the orchestrator explicitly approved archive-time stale-checkbox reconciliation backed by apply-progress/verify-report proof.

**IF mode is `none`:** Skip verification — no persisted artifacts.

### Step 5: Persist Archive Report

This step is mandatory for `engram`, `openspec`, and `hybrid`. In `none`, skip persistence and return the archive report inline only.

Before persistence, validate the archive report includes:
- Change name and artifact store mode
- Observation IDs for Engram artifacts, or concrete OpenSpec paths for filesystem artifacts
- `test-design` artifact ref/path, or explicit partial archive exception text when intentionally omitted
- `review-report` artifact ref/path and confirmation that review verdict is non-blocking
- `review-security-report` artifact ref/path and confirmation that security review verdict is non-blocking
- Mandatory `design.md#secure-development-design` ref/path, including no-impact N/A rows when applicable
- Embedded secure-design validation metadata or static/manual notes: source section, status, catalog snapshot identity, lifecycle vocabulary, and validation notes
- Mandatory security evidence status and complete approved exception details for any accepted gaps
- Archive evidence fields for applicable controls: guideline IDs, taxonomy categories, source refs, operational severity, expected evidence status, residual risks, and exception state
- Task completion status and any stale-checkbox reconciliation proof
- Review verdict and confirmation that no blocking review findings were archived
- Verification verdict and confirmation that no CRITICAL issues were archived
- Runtime test runner/linter/typechecker/formatter/coverage availability from verify evidence; unavailable tools must be recorded explicitly rather than treated as passing evidence
- Corporate source-row audit trail when applicable: catalog snapshot identity/path, expected expanded Source ID count, exact-once coverage status, compact `SEC-*` mappings, safe evidence refs, `N/A` evidence/justification status, warning-only findings, complete exceptions, review-security source-row verdict, verify source-row consumption, report links, and confirmation that no source-row blockers remain
- Confirmation that no legacy standalone `security-design.md` artifact or `scripts/validate_security_design.ps1` execution is required for active new-change archive readiness
- Specs synced by domain with created/updated/removed/renamed counts
- Archive destination or inline-only closure reason
- Any intentional-with-warnings approval text and reason

Follow **Section C** from `skills/_shared/sdd-phase-common.md`.
- artifact: `archive-report`
- topic_key: `sdd/{change-name}/archive-report`
- openspec reference: `openspec/changes/archive/YYYY-MM-DD-{change-name}/` (the moved archive folder is the OpenSpec archive-report/audit-trail reference)
- type: `architecture`

### Step 6: Return Envelope

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`. Put the full archive summary in `detailed_report`:

```markdown
## Change Archived

**Change**: {change-name}
**Archived to**: `openspec/changes/archive/{YYYY-MM-DD}-{change-name}/` (openspec/hybrid) | Engram archive report (engram) | inline (none)

### Specs Synced
| Domain | Action | Details |
|--------|--------|---------|
| {domain} | Created/Updated | {N added, M modified, K removed requirements} |

### Archive Contents
- proposal.md ✅
- specs/ ✅
- design.md ✅
- design.md#secure-development-design ✅
- test-design.md ✅
- review-report.md ✅ (non-blocking)
- review-security-report.md ✅ (non-blocking)
- tasks.md ✅ ({N}/{N} tasks complete)

### Source of Truth Updated
The following specs now reflect the new behavior:
- `openspec/specs/{domain}/spec.md`

### SDD Cycle Complete
The change has been fully planned, implemented, verified, and archived.
Ready for the next change.
```

## Rules

- NEVER archive a change that has blocking review findings or CRITICAL issues in its verification report
- NEVER archive missing mandatory security evidence unless every missing item has a complete approved exception in the audit trail
- NEVER archive unresolved source-row blockers, missing compact source mappings, unsafe evidence, unsupported `N/A`, or missing mandatory source-row evidence.
- ALWAYS preserve source-row coverage, catalog identity, compact mappings, warnings, exceptions, safe evidence references, report links, and unavailable-tooling notes in the audit trail when corporate source-row validation applies; summarize or link the full source-row matrix rather than copying it.
- If the user explicitly approves a non-critical partial archive or stale-checkbox reconciliation, record the exact reason in the archive report and mark the archive as intentional-with-warnings
- NEVER archive completed work while `tasks.md` / the tasks observation still shows stale unchecked implementation tasks
- ALWAYS sync delta specs BEFORE moving to archive
- When merging into existing specs, PRESERVE requirements not mentioned in the delta
- Use ISO date format (YYYY-MM-DD) for archive folder prefix
- If the merge would be destructive (removing large sections), return `blocked` with `next_recommended: resolve-blockers` and `confirmation_required: destructive-merge`; do not ask the user directly
- The archive is an AUDIT TRAIL — never delete or modify archived changes
- If `openspec/changes/archive/` doesn't exist, create it
- Apply any `rules.archive` from `openspec/config.yaml`
- Do not require legacy standalone security artifacts or `scripts/validate_security_design.ps1` for active new-change archive gates; embedded design, review-security, verify, and safe audit references are authoritative.
