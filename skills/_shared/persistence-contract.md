# Persistence Contract (shared across all SDD skills)

This file is the authoritative SDD persistence contract. SDD phase skills and shared execution contracts MUST delegate detailed artifact-store mode behavior, backend read/write semantics, artifact reference resolution, hybrid conflict handling, state persistence, and persistence verification to this file.

Phase skills MAY define phase-local artifact obligations such as required inputs, produced artifacts, mutations, conditional behavior, validation, and routing. They MUST NOT redefine the common persistence mechanics below.

## Mode Resolution

The orchestrator passes `artifact_store.mode` with one of: `engram | openspec | hybrid | none`.

The orchestrator ASKs the user which mode they want when `/sdd-new`, `/sdd-ff`, or `/sdd-continue` is invoked for the first time in a session. The choice is cached for the session.

Default (if user doesn't specify): if Engram is available → `engram`. Otherwise → `none`.

## Mode Roles

- **`engram`**: Working memory between sessions. Upserts overwrite — no iteration history. Local only, not shareable.
- **`openspec`**: Source of truth. Files in repo, git history, team-shareable, full audit trail.
- **`hybrid`**: Both — files for team + engram for recovery. Higher token cost.
- **`none`**: Ephemeral. Lost when conversation ends.

### Mode Comparison

| Capability | `engram` | `openspec` | `hybrid` | `none` |
|------------|----------|------------|----------|--------|
| Cross-session recovery | ✅ | ❌ (needs git) | ✅ | ❌ |
| Compaction survival | ✅ | ❌ | ✅ | ❌ |
| Shareable with team | ❌ (local DB) | ✅ (committed files) | ✅ (files) | ❌ |
| Full iteration history | ❌ (upsert overwrites) | ✅ (git history) | ✅ (files + git) | ❌ |
| Audit trail (archive) | Partial (report only) | ✅ (full folder) | ✅ (both) | ❌ |
| Project files created | Never | Yes | Yes | Never |

### `engram` mode limitation

Engram uses `topic_key`-based upserts. Re-running a phase for the same change **overwrites** the previous version — no revision history is kept. The archive phase saves a summary report, not the full artifact folder. For iteration history or team collaboration, use `openspec` or `hybrid`.

## Behavior Per Mode

| Mode | Read from | Write to | Project files |
|------|-----------|----------|---------------|
| `engram` | Engram | Engram | Never |
| `openspec` | Filesystem | Filesystem | Yes |
| `hybrid` | Engram + Filesystem; read both when both refs exist, fallback only when one backend is absent | Both | Yes |
| `none` | Orchestrator prompt context | Nowhere | Never |

Mode behavior is intentionally centralized here. If a phase-specific instruction appears to conflict with this table, keep the phase-local artifact obligation only and resolve backend behavior from this contract.

### Hybrid Mode

Persists every artifact to BOTH Engram and OpenSpec simultaneously:
- Engram: cross-session recovery, compaction survival, deterministic search
- OpenSpec: human-readable files, version-controllable artifacts

Write to Engram (per `engram-convention.md`) AND to filesystem (per `openspec-convention.md`) for every artifact.

Read behavior: when both Engram and OpenSpec refs are expected or provided, read both and apply the Hybrid Conflict Policy before using either result. Fall back to the existing backend only when one backend is absent.
Write behavior: both writes MUST succeed for the operation to be complete.
Token cost warning: hybrid consumes MORE tokens per operation. Use only when you need both cross-session persistence AND local file artifacts.

### Hybrid Conflict Policy

Hybrid mode MUST NOT silently choose one backend when both Engram and OpenSpec contain the same artifact but disagree.

Conflict detection:

- Compare artifact identity: `changeName`, artifact type, `schemaName`, `schemaVersion`, `currentPhase`, `completedPhases`, and `updatedAt` when present.
- If both sides exist and content differs materially, mark the artifact `partial` in status and add a `blockedReasons` entry.
- If only metadata differs but content is equivalent, prefer the newer `updatedAt` and repair the older backend during the next successful phase write.

Conflict resolution:

| Situation | Action |
| --- | --- |
| One backend missing | Read the existing backend, repair the missing backend, continue. |
| Same content, different metadata | Prefer newer `updatedAt`, update stale metadata, continue. |
| Material content differs before apply/archive | STOP and ask which backend is authoritative before launching dependent work. |
| Material content differs during automatic planning | STOP automatic mode, report both refs, and request reconciliation. |
| Material content differs after apply has modified code | Run verification only to collect evidence; do not archive until reconciled. |

When asking for reconciliation, show both artifact references, last known phase, and a concise diff summary if available. Never overwrite either side until the user or a deterministic phase result establishes the authoritative content.

## Artifact Reference Resolver

Use this resolver whenever checking dependencies, launching sub-agents, validating artifacts, continuing a change, or recovering state.

| Artifact | `engram` reference | `openspec` reference | `hybrid` reference | `none` reference |
| --- | --- | --- | --- | --- |
| Project context | `sdd-init/{project}` | `openspec/config.yaml` | Both; apply Hybrid Conflict Policy | Current-session `sdd-init` result only |
| Testing capabilities | `sdd/{project}/testing-capabilities` | `openspec/config.yaml` | Both; apply Hybrid Conflict Policy | Current-session `sdd-init` result only |
| State | `sdd/{change-name}/state` | `openspec/changes/{change-name}/state.yaml` | Both; apply Hybrid Conflict Policy | Not recoverable after context loss |
| Exploration | `sdd/{change-name}/explore` | `openspec/changes/{change-name}/explore.md` | Both | Inline phase result only |
| Proposal | `sdd/{change-name}/proposal` | `openspec/changes/{change-name}/proposal.md` | Both | Inline phase result only |
| Spec | `sdd/{change-name}/spec` | `openspec/changes/{change-name}/specs/{domain}/spec.md` | Both | Inline phase result only |
| Security applicability | `sdd/{change-name}/security-applicability` | `openspec/changes/{change-name}/security-applicability.md` | Both | Inline phase result only |
| Design | `sdd/{change-name}/design` | `openspec/changes/{change-name}/design.md` | Both | Inline phase result only |
| Security design | `sdd/{change-name}/security-design` | `openspec/changes/{change-name}/security-design.md` | Both | Inline phase result only |
| Test design | `sdd/{change-name}/test-design` | `openspec/changes/{change-name}/test-design.md` | Both | Inline phase result only |
| Tasks | `sdd/{change-name}/tasks` | `openspec/changes/{change-name}/tasks.md` | Both | Inline phase result only |
| Apply progress | `sdd/{change-name}/apply-progress` | `openspec/changes/{change-name}/tasks.md` checkbox state plus status evidence | Both; merge without dropping either side | Current conversation evidence only |
| Review report | `sdd/{change-name}/review` | `openspec/changes/{change-name}/review-report.md` | Both | Inline phase result only |
| Verify report | `sdd/{change-name}/verify-report` | `openspec/changes/{change-name}/verify-report.md` | Both | Inline phase result only |
| Archive report | `sdd/{change-name}/archive-report` | `openspec/changes/archive/YYYY-MM-DD-{change-name}/` | Both | Inline final summary only |

Resolver rules:

- `engram`: use `mem_search` to find the topic key, then `mem_get_observation` for full content.
- `openspec`: read/write only paths defined by `openspec-convention.md`.
- `hybrid`: require both writes for phase success; read both Engram and OpenSpec when both refs exist, fall back only when one backend is absent, and apply the Hybrid Conflict Policy before using either result.
- `none`: never write SDD artifacts, OpenSpec files, Engram observations, or local support files. If required dependency content is not present in current conversation context, return blocked and recommend a persistent mode. Implementation code edits are allowed only for `sdd-apply` when the orchestrator explicitly requested implementation and `actionContext`/`allowedEditRoots` prove the edit is safe.

Resolver verification:

- Treat `mem_search` results as previews only; call `mem_get_observation` before using Engram artifact content.
- In `openspec`, read artifacts from the paths in `openspec-convention.md` or the structured status artifact paths. Do not infer alternate paths.
- In `hybrid`, compare both backends when both refs exist before launching dependent work. Apply the Hybrid Conflict Policy when material content or routing metadata differs.
- In `none`, report blocked when a required dependency is missing from current context; do not reconstruct artifacts from memory or local guesses.
- For review evidence, downstream phases MUST resolve exactly one backend identity: Engram/hybrid key `sdd/{change-name}/review` or OpenSpec path `openspec/changes/{change-name}/review-report.md`. Missing, ambiguous, blocking, or unreadable review evidence MUST block verify/archive and route to `resolve-blockers`.
- The review phase MUST route to `resolve-blockers` when required artifacts, changed-file context, safe workspace context, or review-report persistence evidence are missing.

## State Persistence (Orchestrator)

The orchestrator persists DAG state after each phase transition to enable SDD recovery after compaction.

State is an index and recovery pointer, not a replacement for artifacts. It points to artifact refs/paths and summarizes routing state; do not duplicate full proposal/spec/design/tasks bodies into state.

Persisted SDD state uses camelCase fields. Phase result envelopes may return `next_recommended`, but the orchestrator MUST normalize that value into state `nextRecommended` before writing state. Do not write `next_recommended`, `current_phase`, or `completed_phases` into state artifacts. If legacy snake_case state is encountered, normalize it in memory and rewrite only camelCase state after validation succeeds.

Persist state after:

- Every phase `success` before launching the next phase
- Every `partial` result that produced useful artifacts, recovery steps, or changed task/apply/archive progress
- Every `blocked` result that creates or changes `blockedReasons`, required decisions, selected change, chain plan, or recovery instructions
- Every delivery decision that changes `deliveryStrategy`, `chainStrategy`, `chainPlanRef`, `sizeException`, or `reviewBudgetLines`

| Mode | Persist State | Recover State |
|------|--------------|---------------|
| `engram` | `mem_save(topic_key: "sdd/{change-name}/state", capture_prompt: false*)` | `mem_search("sdd/*/state")` → `mem_get_observation(id)` |
| `openspec` | Write `openspec/changes/{change-name}/state.yaml` | Read `openspec/changes/{change-name}/state.yaml` |
| `hybrid` | Both: `mem_save` AND write `state.yaml`; both writes must succeed | Read both backends when both exist; fallback only when one backend is absent; apply Hybrid Conflict Policy when they differ |
| `none` | Not possible — warn user | Not possible |

*For state automated artifacts, set `capture_prompt: false` when the Engram tool schema supports it; if an older schema rejects or does not expose the field, omit it rather than failing.

Minimum state fields:

```yaml
schemaName: gentle-ai.sdd-state
schemaVersion: 1
changeName: {change-name}
artifactStore: engram | openspec | hybrid | none
currentPhase: explore | propose | spec | security-applicability | design | security-design | test-design | tasks | apply | review | verify | archive | blocked | complete
completedPhases: []
artifactRefs:
  explore: []
  proposal: []
  specs: []
  securityApplicability: []
  design: []
  securityDesign: []
  testDesign: []
  tasks: []
  applyProgress: []
  reviewReport: []
  verifyReport: []
  archiveReport: []
  state: []
delivery:
  deliveryStrategy: ask-on-risk | auto-chain | single-pr | exception-ok | null
  reviewBudgetLines: {number|null}
  chainStrategy: stacked-to-main | feature-branch-chain | null
  chainPlanRef: {ref|null}
  sizeException:
    approved: true | false
    approver: {name-or-null}
    rationale: {text-or-null}
nextRecommended: propose | spec | security-applicability | design | security-design | test-design | tasks | apply | review | verify | archive | sdd-new | select-change | resolve-blockers | none
blockedReasons:
  - code: {machine-readable-code}
    message: {human-readable-summary}
    owner: orchestrator | user | phase-agent | reviewer
    requiredAction: {next-action}
stateRevision: {monotonic-integer-or-iso-timestamp}
updatedAt: {iso-8601-timestamp}
```

State update order: validate the phase result, persist/update state in the selected backend, read state back for verification, then launch the next phase or report completion. If state persistence fails in `engram`, `openspec`, or `hybrid`, stop before dependent work.

Read-back verification:

- After writing state in any persistent mode, read it back from the selected backend before continuing.
- Verify `changeName`, `artifactStore`, `currentPhase`, `completedPhases`, `nextRecommended`, `artifactRefs`, `blockedReasons`, `stateRevision`, and `updatedAt` match the intended transition.
- In `hybrid`, read both backends. If one write is missing, stale, or materially different, mark state persistence as failed and stop before dependent work.
- If read-back fails, do not trust the write result. Report the backend, expected state, observed state if any, and safest recovery action.

Failure handling:

- If state persistence fails after a phase `success`, treat orchestration as blocked before dependent work. Do not launch the next phase.
- If one side of `hybrid` succeeds and the other fails, report partial persistence and require repair/reconciliation before continuing.
- If existing state has a newer `stateRevision` or `updatedAt` than the state about to be written, stop and reconcile; do not overwrite newer state.
- If Engram state and OpenSpec state materially disagree in `hybrid`, apply the Hybrid Conflict Policy and ask for reconciliation before launching dependent work.

## Artifact Persistence Verification

Every phase that produces or mutates a persistent artifact MUST verify the selected backend before reporting success.

| Mode | Required verification |
|------|-----------------------|
| `engram` | Save with the expected `topic_key`, then retrieve the observation by ID or topic and confirm the artifact identity and content needed by downstream phases. |
| `openspec` | Re-read the written file path and confirm the expected artifact identity, required sections, and task/status mutations are present. |
| `hybrid` | Verify both Engram and OpenSpec writes, then confirm the two artifacts describe the same phase result or apply the Hybrid Conflict Policy. |
| `none` | No persistent verification is possible; the phase envelope is the only artifact evidence. |

Verification rules:

- Do not report `success` for persistent modes if the artifact cannot be read back from the selected backend.
- For `sdd-apply`, completed work MUST be visible in the selected task/progress artifact before returning success or partial completion.
- For `sdd-review`, `review-report.md` or `sdd/{change-name}/review` MUST be readable after persistence and MUST state verdict, blocking summary, evidence summary, and next recommendation before downstream phases treat review evidence as present.
- For `sdd-archive`, archive movement and spec synchronization MUST be verified from the filesystem and/or Engram topic keys selected by mode.
- If read-back verification fails after a useful artifact or mutation was attempted, return `partial` or `blocked` with the backend, expected reference, observed result, and safest recovery action.

## Common Rules

- `none` → do NOT create or modify SDD/OpenSpec artifacts, Engram observations, or local support files; return SDD artifacts inline only. Code edits are allowed only for implementation phases when explicit workspace guards allow them.
- `engram` → do NOT write any project files; persist to Engram and return observation IDs
- `openspec` → write files ONLY to paths defined in `openspec-convention.md`
- `hybrid` → persist to BOTH Engram AND filesystem; follow both conventions
- NEVER force `openspec/` creation unless orchestrator explicitly passed `openspec` or `hybrid`
- If unsure which mode to use, default to `none`

## Sub-Agent Context Rules

Sub-agents launch with a fresh context and NO access to the orchestrator's instructions or memory protocol.

Who reads, who writes:
- Non-SDD (general task): orchestrator searches engram, passes summary in prompt; sub-agent saves discoveries via `mem_save`
- SDD (phase with dependencies): sub-agent reads artifacts directly from backend; sub-agent saves its artifact
- SDD (phase without dependencies, e.g. explore): nobody reads; sub-agent saves its artifact
- SDD test-design phase: `sdd-test-design` reads proposal, spec, and design directly from the selected backend and saves `test-design`; later dependent SDD phases read `test-design` from the backend when their phase contracts require it

Why this split:
- Orchestrator reads for non-SDD: it knows what context is relevant; sub-agents doing their own searches waste tokens on irrelevant results
- Sub-agents read for SDD: SDD artifacts are large; inlining them in the orchestrator prompt would consume the entire context window
- Sub-agents always write: they have the complete detail on what happened; nuance is lost by the time results flow back to the orchestrator

## Orchestrator Prompt Instructions for Sub-Agents

Non-SDD:
```
PERSISTENCE (MANDATORY):
If you make important discoveries, decisions, or fix bugs, you MUST save them to engram before returning:
  mem_save(title: "{short description}", type: "{decision|bugfix|discovery|pattern}",
           project: "{project}", content: "{What, Why, Where, Learned}")
Do NOT return without saving what you learned. This is how the team builds persistent knowledge across sessions.
```

SDD (with dependencies):
```
Artifact store mode: {engram|openspec|hybrid|none}

Read dependency artifacts from the selected backend:
  engram: mem_search(query: "sdd/{change-name}/{type}", project: "{project}") -> mem_get_observation(id)
  openspec: read the artifact path from openspec-convention.md / the status contract
  test-design dependencies: sdd-test-design reads proposal, spec, and design; downstream phases read test-design when their phase contract requires test-planning evidence
  hybrid: read both Engram and OpenSpec when both refs are available, fallback only when one backend is absent, and report any mismatch
  none: use only the dependency content explicitly provided by the orchestrator; if missing, return blocked

PERSISTENCE (MANDATORY — do NOT skip):
Persist your completed artifact according to artifact_store.mode:
  engram: mem_save(title/topic_key: "sdd/{change-name}/{artifact-type}", type: "architecture", project: "{project}", capture_prompt: false, content: full artifact)
  openspec: write/update the file path defined in openspec-convention.md; read existing file first and do not overwrite blindly
  hybrid: write BOTH Engram and OpenSpec; both writes must succeed for status: success
  none: return the full SDD artifact inline only; do not write SDD/OpenSpec files, Engram observations, or local support files
If you return without persisting or returning the artifact according to the selected mode, the next phase CANNOT find it and the pipeline BREAKS.
```

Recovery fallback for `test-design`: if persisted state says design is complete but `artifactRefs.testDesign` is empty, the orchestrator must resolve the artifact directly from `sdd/{change-name}/test-design` or `openspec/changes/{change-name}/test-design.md`. If the artifact is still missing, continuation must recommend `test-design` / `sdd-test-design` before launching `sdd-tasks`.

SDD (no dependencies):
```
Artifact store mode: {engram|openspec|hybrid|none}

PERSISTENCE (MANDATORY — do NOT skip):
Persist your completed artifact according to artifact_store.mode:
  engram: mem_save(title/topic_key: "sdd/{change-name}/{artifact-type}", type: "architecture", project: "{project}", capture_prompt: false, content: full artifact)
  openspec: write/update the file path defined in openspec-convention.md; read existing file first and do not overwrite blindly
  hybrid: write BOTH Engram and OpenSpec; both writes must succeed for status: success
  none: return the full SDD artifact inline only; do not write SDD/OpenSpec files, Engram observations, or local support files
If you return without persisting or returning the artifact according to the selected mode, the next phase CANNOT find it and the pipeline BREAKS.
```

For SDD artifacts, `capture_prompt: false` is explicit and mandatory when the Engram tool schema supports it. Engram v1.15.3 defaults `capture_prompt` to true for normal human/proactive saves, but automated pipeline artifacts must not capture the user's prompt. Do not infer this from `type` because SDD artifacts and real human architecture decisions both use `architecture`. If an older schema rejects or does not expose `capture_prompt`, omit it rather than failing.

## Sub-Agent Response Ordering

When a sub-agent persists artifacts (via `mem_save` or file writes), the persistence call MUST happen BEFORE the final text response. The sub-agent's absolute last output must be text, never a tool call.

**Why**: The Task tool returns the sub-agent's final output to the parent. If the sub-agent ends with a tool call, the parent receives only the tool result (e.g., `"Observation saved"`) — the sub-agent's text analysis is lost. Always: do your work → save → respond with text envelope.

Sub-agents must NOT call `mem_session_summary` — that's reserved for top-level agents only.

## Skill Registry

The orchestrator pre-resolves skill paths from the skill registry and injects them as `## Skills to load before work` in your launch prompt. Sub-agents read those exact `SKILL.md` files before task-specific work.

To generate/update: run the `skill-registry` skill, or run `sdd-init`.

Sub-agent skill loading: check for a `## Skills to load before work` block in your prompt — if present, read those exact files. If not present, check for `SKILL: Load` instructions as a fallback. If neither exists, proceed without — this is not an error.

## Detail Level

The orchestrator may pass `detail_level`: `concise | standard | deep`. This controls output verbosity but does NOT affect what gets persisted — always persist the full artifact.
