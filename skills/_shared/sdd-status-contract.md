# SDD Status and Instructions Contract

Shared status contract for SDD commands and phase skills. Use this before acting on a change so orchestration does not guess state, artifact references, or edit scope.

## Purpose

Commands that select, continue, apply, verify, or archive an SDD change MUST first produce or consume structured status. The status is the handoff between orchestrator and phase executor.

## Change Selection

- If a change name is provided, use that exact change after confirming it exists in the selected artifact store.
- If no change name is provided, infer only when the active change is unambiguous from session state or there is exactly one active change.
- If multiple active changes match or the active change is unclear, ask the user to choose. Do not guess.
- If no active changes exist, report that no SDD change is active and suggest `/sdd-new <change>`.

## Native Engine

- When the `gentle-ai` binary is available, prefer `gentle-ai sdd-status [change] --cwd <repo> --json --instructions` for read-only status and `gentle-ai sdd-continue [change] --cwd <repo>` for dispatcher output.
- Treat native status JSON as authoritative over prompt inference or manually reconstructed state.
- When `blockedReasons` is non-empty, do not proceed to terminal, archive, or apply work. Return or report `blockedReasons` and stop unless `nextRecommended` is `verify`, in which case verification may run only to remediate or refresh evidence for the blockers. When `nextRecommended` is `resolve-blockers`, always report `blockedReasons` and stop.
- `nextRecommended` is a bounded machine token for routing, not human prose. Route only by `nextRecommended` and dependency states.
- Human-readable explanation belongs in `blockedReasons`, not `nextRecommended`.
- If the binary is unavailable, fall back to this prompt contract and the manual status schema below. Manual fallback status MUST stay shape-compatible with native `gentle-ai.sdd-status` JSON even when values are reconstructed manually.

## Routing Token Mapping

Native status uses bounded tokens: `propose`, `spec`, `design`, `tasks`, `apply`, `verify`, `archive`, `sdd-new`, `select-change`, `resolve-blockers`, and `none`.

When launching phase agents, normalize through this mapping:

| `nextRecommended` | Launch |
| --- | --- |
| `propose` | `sdd-propose` |
| `spec` | `sdd-spec` |
| `design` | `sdd-design` |
| `tasks` | `sdd-tasks` |
| `apply` | `sdd-apply` |
| `verify` | `sdd-verify` |
| `archive` | `sdd-archive` |
| `sdd-new` | orchestrator workflow |
| `select-change` | ask user to choose |
| `resolve-blockers` | report blockers and stop |
| `none` | no next phase |

Phase envelopes may return prefixed phase tokens such as `sdd-verify`; consumers MUST normalize them to the native token before comparing dependency states.

## Field Naming Across Contracts

| Contract | Field style | Routing field | Phase field | Completed phases field |
| --- | --- | --- | --- | --- |
| Phase result envelope | snake_case | `next_recommended` | N/A | N/A |
| Native/status JSON | camelCase | `nextRecommended` | dependency states | N/A |
| Persisted SDD state | camelCase | `nextRecommended` | `currentPhase` | `completedPhases` |

Rules:

- Phase agents may return `next_recommended` because `sdd-phase-common.md` defines the phase envelope.
- Status and state artifacts MUST use camelCase fields.
- Before routing or persisting state, normalize phase envelope `next_recommended` into status/state `nextRecommended`.
- Do not write `next_recommended`, `current_phase`, or `completed_phases` into persisted state.
- If legacy snake_case state is encountered, normalize it in memory and rewrite only camelCase state after validation succeeds.

## Status Schema

Return status as markdown with these fields, or as equivalent JSON when the host supports it:

```yaml
schemaName: gentle-ai.sdd-status
schemaVersion: 2
changeName: <change-name-or-null>
artifactStore: engram | openspec | hybrid | none
planningHome:
  mode: repo-local | memory-local | hybrid | ephemeral
  path: <absolute path to openspec, memory namespace, or null>
changeRoot: <absolute path to openspec/changes/<change>, memory namespace, or null>
artifactRefs:
  explore: [<topic keys, file paths, or inline refs>]
  proposal: [<topic keys, file paths, or inline refs>]
  specs: [<topic keys, file paths, or inline refs>]
  design: [<topic keys, file paths, or inline refs>]
  tasks: [<topic keys, file paths, or inline refs>]
  applyProgress: [<topic keys, file paths, or inline refs>]
  verifyReport: [<topic keys, file paths, or inline refs>]
  state: [<topic keys, file paths, or inline refs>]
artifactPaths:
  explore: [<absolute path>]
  proposal: [<absolute path>]
  specs: [<absolute paths>]
  design: [<absolute path>]
  tasks: [<absolute path>]
  applyProgress: [<absolute path>]
  verifyReport: [<absolute path>]
  state: [<absolute path>]
contextFiles:
  explore: [<absolute readable files>]
  proposal: [<absolute readable files>]
  specs: [<absolute readable files>]
  design: [<absolute readable files>]
  tasks: [<absolute readable files>]
  applyProgress: [<absolute readable files>]
  verifyReport: [<absolute readable files>]
  state: [<absolute readable files>]
artifacts:
  explore: missing | done | partial
  proposal: missing | done | partial
  specs: missing | done | partial
  design: missing | done | partial
  tasks: missing | done | partial
  applyProgress: missing | done | partial
  verifyReport: missing | done | partial
  state: missing | done | partial
taskProgress:
  total: 0
  completed: 0
  pending: 0
  allComplete: false
dependencies:
  proposal: blocked | ready | all_done
  specs: blocked | ready | all_done
  design: blocked | ready | all_done
  tasks: blocked | ready | all_done
  apply: blocked | ready | all_done
  verify: blocked | ready | all_done
  archive: blocked | ready | all_done
applyState: blocked | all_done | ready
actionContext:
  mode: repo-local | workspace-planning | memory-local | ephemeral
  workspaceRoot: <absolute path>
  allowedEditRoots: [<absolute paths>]
relationships:
  dependsOn: []
  supersedes: []
  amends: []
  conflictsWith: []
  sameDomainActiveChanges: []
phaseInstructions:
  apply: [<instruction strings>]
  verify: [<instruction strings>]
  archive: [<instruction strings>]
nextRecommended: propose | spec | design | tasks | apply | verify | archive | sdd-new | select-change | resolve-blockers | none
blockedReasons: []
```

`phaseInstructions` is optional and appears only when instructions are requested. `nextRecommended` is a required top-level routing token, never nested under `phaseInstructions`. Empty array fields MUST be arrays, not null. `changeName`, `planningHome.path`, and `changeRoot` are nullable; all other sections should be present in fallback output so consumers can parse native and manual status the same way.

Mode-specific status rules:

- **`engram`**: `artifactRefs` contain Engram topic keys. `artifactPaths` and `contextFiles` are empty arrays unless a real filesystem path is also known.
- **`openspec`**: `artifactRefs`, `artifactPaths`, and `contextFiles` contain OpenSpec file paths where applicable.
- **`hybrid`**: `artifactRefs` contain both Engram topic keys and OpenSpec file paths. `artifactPaths` and `contextFiles` contain only filesystem paths. If matching Engram/OpenSpec artifacts materially differ, mark the artifact `partial` and add `blockedReasons` per the Hybrid Conflict Policy in `persistence-contract.md`.
- **`none`**: `artifactRefs` may contain inline/session refs such as `inline:proposal`. `artifactPaths` and `contextFiles` are empty arrays.

Native status JSON is authoritative when available. If native currently emits only `artifactStore: openspec`, treat that output as authoritative for OpenSpec-mode runs; manual fallback MUST use `artifactStore` and `artifactRefs` from the active session preflight for non-OpenSpec modes.

## Apply State

- `blocked`: Required apply artifacts are missing, task selection is ambiguous, or action context makes edits unsafe.
- `all_done`: Tasks artifact exists and every implementation task is checked `[x]`.
- `ready`: Tasks artifact exists, at least one implementation task remains unchecked, and edit scope is safe.

## Dependency States

- `proposal`, `specs`, `design`, and `tasks` report whether prerequisite artifacts are blocked, ready, or all done.
- `apply` is `ready` only when specs, design, and tasks are available and task progress is not all done.
- `verify` is `ready` when tasks exist and either apply-progress exists or the tasks artifact shows all intended implementation work complete. Incomplete tasks remain blockers for full verification.
- `archive` is `ready` only when verify-report exists, is clearly passing, and tasks are complete. A clearly passing report needs an explicit PASS/SUCCESS signal and no blocker or negation signals such as FAIL, FAILURE, BLOCKED, CRITICAL, PENDING, TODO, verification blockers, `not passed`, or `pass: no`. CRITICAL verification issues have no override. Explicit recorded exceptions are limited to non-critical partial archives or stale-checkbox reconciliation when apply-progress/verify-report prove completion.

## Action Context Guard

The orchestrator MUST carry `actionContext` into any phase launch.

- If manually reconstructed context cannot prove edit ownership or allowed edit roots, stop before editing.
- If `allowedEditRoots` is present, only edit files within those roots.
- If a command cannot prove a file is inside the authoritative workspace or allowed edit roots, stop and ask for clarification.

## Status Output

Every command that acts on a change MUST show status before launching an executor or performing archive work:

- Active change selection and how it was resolved.
- Artifact statuses and paths/topics used as context.
- Task progress and unchecked task list when tasks exist.
- Next recommended action.
- `blockedReasons` when `nextRecommended` is not `verify`, plus any edit-root blockers.
