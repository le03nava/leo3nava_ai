# Persistence Contract (shared across all SDD skills)

This file is the authoritative SDD persistence contract. SDD phase skills and shared execution contracts MUST delegate detailed artifact-store mode behavior, backend read/write semantics, artifact reference resolution, hybrid conflict handling, state persistence, and persistence verification to this file.

Phase skills MAY define phase-local artifact obligations such as required inputs, produced artifacts, mutations, conditional behavior, validation, and routing. They MUST NOT redefine the common persistence mechanics below.

## Mode Resolution

The orchestrator passes `artifact_store.mode` with one of: `engram | openspec | hybrid | none`.

The orchestrator asks/caches artifact mode during minimal preflight before the first mutating SDD route in a session. Status/read-only routes may bypass preflight and must not mutate artifacts just to resolve mode.

User-facing artifact options are OpenSpec, Engram, Both, and None/Ephemeral. Map them internally to `openspec`, `engram`, `hybrid`, and `none` respectively.

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
| Security applicability (historical/read-only) | `sdd/{change-name}/security-applicability` | `openspec/changes/{change-name}/security-applicability.md` | Both | Historical data only when already present; no active phase output |
| Design | `sdd/{change-name}/design` | `openspec/changes/{change-name}/design.md` | Both | Inline phase result only |
| Security design (historical/read-only) | `sdd/{change-name}/security-design` | `openspec/changes/{change-name}/security-design.md` | Both | Historical data only when already present; no active phase output |
| Test design | `sdd/{change-name}/test-design` | `openspec/changes/{change-name}/test-design.md` | Both | Inline phase result only |
| Test cases | `sdd/{change-name}/test-cases` | `openspec/changes/{change-name}/test-cases.json` | Both; apply Hybrid Conflict Policy | Inline phase result only |
| Tasks | `sdd/{change-name}/tasks` | `openspec/changes/{change-name}/tasks.md` | Both | Inline phase result only |
| Apply progress | `sdd/{change-name}/apply-progress` | `openspec/changes/{change-name}/tasks.md` checkbox state plus status evidence | Both; merge without dropping either side | Current conversation evidence only |
| Review report | Canonical JSON: `sdd/{change-name}/review-report.json`; derived Markdown compatibility view: `sdd/{change-name}/review` | Canonical JSON: `openspec/changes/{change-name}/review-report.json`; derived Markdown compatibility file: `openspec/changes/{change-name}/review-report.md` | Both canonical JSON refs plus both derived Markdown refs; apply Hybrid Conflict Policy | Inline phase result only; include canonical JSON facts and derived Markdown view when needed for human/downstream compatibility |
| Security review report | Canonical JSON: `sdd/{change-name}/review-security-report.json`; derived Markdown compatibility view: `sdd/{change-name}/review-security` | Canonical JSON: `openspec/changes/{change-name}/review-security-report.json`; derived Markdown compatibility file: `openspec/changes/{change-name}/review-security-report.md` | Both canonical JSON refs plus both derived Markdown refs; apply Hybrid Conflict Policy | Inline phase result only; include canonical JSON facts and derived Markdown view when needed for human/downstream compatibility |
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
- For review evidence, downstream phases MUST resolve exactly one selected-backend identity for each required review report. General review and security review each have two coordinated artifacts: canonical JSON and derived Markdown. General review uses canonical JSON `openspec/changes/{change-name}/review-report.json` or `sdd/{change-name}/review-report.json`, plus derived Markdown `openspec/changes/{change-name}/review-report.md` or `sdd/{change-name}/review`. Security review uses canonical JSON `openspec/changes/{change-name}/review-security-report.json` or `sdd/{change-name}/review-security-report.json`, plus derived Markdown `openspec/changes/{change-name}/review-security-report.md` or `sdd/{change-name}/review-security`. In hybrid, both OpenSpec paths and both Engram keys are expected and must describe the same report; apply the Hybrid Conflict Policy when they materially disagree. In `none`, the phase result must include inline canonical JSON facts and may include an inline Markdown view. Missing, ambiguous, blocking, stale, parity-failed, or unreadable review evidence MUST block verify/archive and route to `resolve-blockers`.
- Canonical general-review JSON wins over derived Markdown whenever both are present. Downstream phases MAY read `review-report.md` / `sdd/{change-name}/review` for compatibility, human review, section anchors, summaries, and handoff text, but they MUST NOT treat derived Markdown as authoritative for verdict, counts, routing, matrix facts, catalog identity, or validation state when canonical JSON is available.
- Canonical security-review JSON wins over derived Markdown whenever both are present. Downstream phases MUST consume `review-security-report.json` as authoritative for verdict/status, `nextRecommended`, `sourceRowValidation` exact-once coverage, expected/validated counts, coverage status, blockers, warnings, unsafe evidence rejections, warning carry-forward, exceptions, evidence refs, artifact parity/read-back metadata, and source refs. Markdown is compatibility only; stale/parity-failed Markdown routes to `resolve-blockers`.
- Derived Markdown references MUST use backend-appropriate naming. Do not describe all derived Markdown as an OpenSpec-only `review-report.md`: Engram and hybrid consumers use `sdd/{change-name}/review` for the Markdown compatibility view, while canonical Engram JSON remains `sdd/{change-name}/review-report.json`.
- Security-review derived Markdown references also use backend-appropriate naming: OpenSpec uses `review-security-report.md`, Engram/hybrid uses the stable legacy key `sdd/{change-name}/review-security`, while canonical Engram JSON remains `sdd/{change-name}/review-security-report.json`.
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
schemaName: sdd.state
schemaVersion: 1
changeName: {change-name}
artifactStore: engram | openspec | hybrid | none
currentPhase: explore | propose | spec | design | test-design | tasks | apply | review | review-security | review-parallel | verify | archive | blocked | complete
completedPhases: []
  artifactRefs:
  explore: []
  proposal: []
  specs: []
  securityApplicability: [] # historical/read-only; not an active new-change dependency or authority
  design: []
  securityDesign: [] # historical/read-only; active security authority is design.md#secure-development-design
  testDesign: []
  tasks: []
  applyProgress: []
  reviewReport: []
  securityReviewReport: [] # list canonical JSON first with authority: canonical when structured refs are supported, then derived Markdown with authority: derived
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
nextRecommended: propose | spec | design | test-design | tasks | apply | review | review-security | verify | archive | sdd-new | select-change | resolve-blockers | none

> **Parallel review**: After `sdd-apply`, both `sdd-review` and `sdd-review-security` return `next_recommended: verify` independently. The orchestrator MUST advance to `verify` only when both phases appear in `completedPhases`. Use `currentPhase: review-parallel` when both are running simultaneously. Do not advance on the first one to complete.
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

Security-review state refs:

- After `sdd-review-security`, `artifactRefs.securityReviewReport` MUST register both security-review artifacts in this order: canonical JSON first, derived Markdown second.
- When structured refs are supported, use entries shaped like `{ ref: ".../review-security-report.json", authority: canonical, readable: true }` followed by `{ ref: ".../review-security-report.md" | "sdd/{change-name}/review-security", authority: derived, readable: true }`.
- When a legacy string-only state writer is still in use, preserve the same order and rely on the resolver contract to infer JSON as canonical and Markdown/topic view as derived.
- Downstream phases MUST treat missing canonical JSON, stale derived Markdown, or parity-failed derived Markdown as blocking evidence and route to `resolve-blockers` unless the selected mode is `none` and the canonical JSON facts are inline.

Failure handling:

- If state persistence fails after a phase `success`, treat orchestration as blocked before dependent work. Do not launch the next phase.
- If one side of `hybrid` succeeds and the other fails, report partial persistence and require repair/reconciliation before continuing.
- If existing state has a newer `stateRevision` or `updatedAt` than the state about to be written, stop and reconcile; do not overwrite newer state.
- If Engram state and OpenSpec state materially disagree in `hybrid`, apply the Hybrid Conflict Policy and ask for reconciliation before launching dependent work.

Historical `security-design` and `security-applicability` current-phase or next-recommended values may be read from old state only as compatibility data. They MUST NOT be emitted for new state, normalized into runnable successors, mapped to phase agents, or treated as active security authority.

## State Recovery (Orchestrator)

Use this when recovering after compaction, mid-session context drift, or `/sdd-continue` when state is not already trusted.

Recovery sources by mode:

| Mode | Recovery source |
|------|-----------------|
| `engram` | `mem_search(query: "sdd/*/state" or "sdd/{change-name}/state", project: "{project}")` -> `mem_get_observation(id)` |
| `openspec` | Read `openspec/changes/{change-name}/state.yaml` after selecting or confirming the active change |
| `hybrid` | Read BOTH Engram state and OpenSpec `state.yaml` when both exist; fallback only when one backend is absent; apply the Hybrid Conflict Policy when they differ materially |
| `none` | State is not recoverable after compaction; use only current conversation context, and ask whether to restart with persistent mode when insufficient |

Minimum recovered-state validation:

- `schemaName: sdd.state`
- supported `schemaVersion`
- `changeName` matches the selected change
- `artifactStore` matches cached/recovered preflight mode or has been explicitly reconciled
- `currentPhase`, `completedPhases`, `nextRecommended`, `artifactRefs`, `blockedReasons`, `stateRevision`, and `updatedAt` are present
- `delivery.deliveryStrategy`, `delivery.reviewBudgetLines`, `delivery.chainStrategy`, `delivery.chainPlanRef`, and `delivery.sizeException` are restored when present

Recovery reconciliation rules:

- If `blockedReasons` is non-empty or `nextRecommended` is `resolve-blockers`, report blockers and stop before launching phases.
- If cached preflight and recovered state disagree on `artifactStore`, stop and reconcile unless one side is clearly missing/stale by `stateRevision` or `updatedAt`. Delivery strategy, review budget, and chain strategy may be `null` until the tasks/delivery guard resolves them; reconcile only conflicting non-null values.
- If state is missing or invalid but persistence is enabled, reconstruct only a shape-compatible fallback status from artifact presence and `skills/_shared/sdd-status-contract.md`; do not route directly from ad hoc artifact checks.
- When fallback reconstruction is required, choose the earliest missing phase in DAG order and apply the status contract dependency-state rules. Preserve the post-apply order: `apply -> [review ∥ review-security] -> verify -> archive`; both `review` and `review-security` must be in `completedPhases` before `verify` may proceed; archive readiness is defined by `skills/_shared/sdd-post-apply-gates.md#archive-readiness`.
- Valid state is authoritative for `currentPhase` and `nextRecommended`; use artifact-presence fallback only when state is missing or invalid.
- Re-run the backend-aware SDD Init Guard before repairing or rewriting recovered state.

Recovery safety checklist:

- State is readable in the selected backend.
- Hybrid state has no material Engram/OpenSpec conflict.
- State schema/version are valid.
- `artifactStore` matches preflight or has been explicitly reconciled.
- `blockedReasons` are empty and `nextRecommended` is not `resolve-blockers`.
- Delivery/chain/size-exception context is restored before apply or PR-shaped work.
- Required artifact refs for the next phase are readable.
- Init Guard is satisfied for the selected mode.
- Dependency Graph readiness passes for the recovered `nextRecommended`.

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
- For `sdd-review`, canonical `review-report.json` (`openspec/changes/{change-name}/review-report.json` or `sdd/{change-name}/review-report.json`) and derived Markdown (`openspec/changes/{change-name}/review-report.md` or `sdd/{change-name}/review`) MUST be readable after persistence in persistent modes. Canonical JSON MUST state schema identity, catalog refs, verdict, blocking summary/counts, evidence summary, next recommendation, validation metadata, and the 96-row matrix. Derived Markdown MUST be generated from that JSON and state verdict, blocking summary, evidence summary, matrix presentation, and next recommendation before downstream phases treat review evidence as present.
- For `sdd-review-security`, canonical `review-security-report.json` (`openspec/changes/{change-name}/review-security-report.json` or `sdd/{change-name}/review-security-report.json`) and derived Markdown (`openspec/changes/{change-name}/review-security-report.md` or `sdd/{change-name}/review-security`) MUST be readable after persistence in persistent modes. Canonical JSON MUST state schema identity, `changeName`, status/verdict, `nextRecommended`, source refs, general review handoff, `sourceRowValidation` expected/validated counts, exact-once coverage status, blockers, warnings, unsafe evidence rejections, warning carry-forward, exceptions, evidence refs, and artifact parity/read-back metadata. Derived Markdown MUST be generated from that JSON and state verdict, source refs, general review handoff, source-row summaries, blocker/warning summaries, exception summaries, parity metadata, and next recommendation before downstream phases treat security-review evidence as present.
- For `sdd-archive`, archive movement and spec synchronization MUST be verified from the filesystem and/or Engram topic keys selected by mode.
- If read-back verification fails after a useful artifact or mutation was attempted, return `partial` or `blocked` with the backend, expected reference, observed result, and safest recovery action.

## Common Rules

- `none` → do NOT create or modify SDD/OpenSpec artifacts, Engram observations, or local support files; return SDD artifacts inline only. Code edits are allowed only for implementation phases when explicit workspace guards allow them.
- `engram` → do NOT write any project files; persist to Engram and return observation IDs
- `openspec` → write files ONLY to paths defined in `openspec-convention.md`
- `hybrid` → persist to BOTH Engram AND filesystem; follow both conventions
- NEVER force `openspec/` creation unless orchestrator explicitly passed `openspec` or `hybrid`
- If unsure which mode to use, default to `none`

## Cross-Contract Boundaries

This file owns persistence mechanics only. Keep adjacent orchestration and executor behavior in their dedicated contracts:

| Concern | Source of truth |
| --- | --- |
| SDD phase context, dependency retrieval, artifact persistence handoff, and final response ordering | `skills/_shared/sdd-phase-common.md` |
| Supplemental skill registry lookup, `## Skills to load before work`, and `skill_resolution` reporting | `skills/_shared/skill-resolver.md` |
| OpenSpec paths, folder layout, and delta-spec file conventions | `skills/_shared/openspec-convention.md` |
| Engram topic naming and Engram-specific call examples | `skills/_shared/engram-convention.md` |

Persistence-specific reminders retained here:

- SDD phase agents read required artifacts from the selected backend using exact refs/paths supplied by status or launch context; they must not reconstruct missing artifacts from prose.
- Every persistent SDD artifact write must follow the selected mode and pass read-back verification before a phase reports `status: success`.
- For automated SDD artifacts saved to Engram, use `capture_prompt: false` when the tool schema supports it; omit the field rather than failing on older schemas.
- Recovery fallback for `test-design`: if persisted state says design is complete but `artifactRefs.testDesign` is empty, resolve the artifact directly from `sdd/{change-name}/test-design` or `openspec/changes/{change-name}/test-design.md`. If it is still missing, continuation must recommend `test-design` / `sdd-test-design` before launching `sdd-tasks`.
- Recovery fallback for `test-cases`: if persisted state says test-design is complete but `artifactRefs.testCases` is empty, resolve the artifact directly from `sdd/{change-name}/test-cases` or `openspec/changes/{change-name}/test-cases.json`.
