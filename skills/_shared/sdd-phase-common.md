# SDD Phase — Common Protocol

Boilerplate identical across all SDD phase skills. Sub-agents MUST load this alongside their phase-specific SKILL.md.

Executor boundary: every SDD phase agent is an EXECUTOR, not an orchestrator. Do the phase work yourself. Do NOT launch sub-agents, do NOT call `delegate`/`task`, and do NOT bounce work back unless the phase skill explicitly says to stop and report a blocker.

## A. Skill Loading

1. Check if the orchestrator injected a `## Skills to load before work` block in your launch prompt. If yes, read those exact `SKILL.md` files before task-specific work.
2. If no skills block was provided, check for `SKILL: Load` instructions. If present, load those exact skill files.
3. If neither was provided, search for the skill registry as a fallback:
   a. `mem_search(query: "skill-registry", project: "{project}")` — if found, `mem_get_observation(id)` for full content
   b. Fallback: read `.atl/skill-registry.md` from the project root if it exists
   c. From the registry's skills index, match triggers to your task and read the exact listed `SKILL.md` paths.
4. If no registry exists, proceed with your phase skill only.

NOTE: the preferred path is (1) — exact skill paths selected by the orchestrator. Paths (2) and (3) are fallbacks. Searching the registry is SKILL LOADING, not delegation. If `## Skills to load before work` is present, IGNORE redundant `SKILL: Load` instructions.

## B. Artifact Retrieval

Follow `skills/_shared/persistence-contract.md` for artifact-store mode resolution, artifact references, backend read behavior, Engram preview handling, OpenSpec paths, hybrid conflict policy, and missing-artifact behavior.

Phase skills remain responsible for naming their required inputs and reading every required dependency before producing phase output.

## C. Artifact Persistence

Every phase that produces or mutates an artifact MUST persist and verify it according to `skills/_shared/persistence-contract.md`. Skipping persistence or read-back verification BREAKS the pipeline because downstream phases cannot trust the artifact references.

Phase skills remain responsible for defining the artifact key/path, artifact content, phase-local mutations, and any conditional persistence requirements.

## D. Return Envelope

> **CRITICAL — Response ordering**: Your FINAL output MUST be text (the return envelope), NOT a tool call. If you need to save to Engram (`mem_save`), do it BEFORE your final text response. Do NOT call `mem_session_summary` — that's for top-level agents only. **Why**: When a sub-agent's last action is a tool call, the parent agent receives only the tool result — your text response (the actual analysis) is lost.

 Every phase MUST return a structured envelope to the orchestrator:

- `status`: `success`, `partial`, or `blocked`
- `executive_summary`: 1-3 sentence summary of what was done
- `detailed_report`: (optional) full phase output, or omit if already inline
- `artifacts`: list of artifact keys/paths written
- `next_recommended`: the next SDD phase to run, or "none"
- `risks`: risks discovered, or "None"
- `skill_resolution`: how supplemental skills were loaded. Return the structured shape below so the orchestrator can gate missing required skills without guessing.

```yaml
skill_resolution:
  mode: paths-injected | fallback-registry | fallback-path | none
  loaded:
    - name: {skill-name}
      path: {absolute SKILL.md path-or-null}
  missing_required:
    - {skill-name}
  registry_source: session-cache | engram | atl-file | fallback-path | none
  notes: {text-or-null}
```

Use `mode: none` only when no supplemental skills were required or no registry/paths were available. If the orchestrator injected `## Skills to load before work`, prefer `mode: paths-injected` and list every path actually loaded.

Do not invent additional status values such as `hold`. If a phase needs user input or orchestration before it can continue, return `status: blocked` with `next_recommended: resolve-blockers` and put the required question or decision in `risks` / `detailed_report`.

Routing token convention:

`skills/_shared/sdd-status-contract.md` is the routing-token source of truth. The table below is a convenience mirror for phase envelopes; if it ever differs from `sdd-status-contract.md`, use the status contract.

| Native/status token | Phase agent token |
| --- | --- |
| `propose` | `sdd-propose` |
| `spec` | `sdd-spec` |
| `design` | `sdd-design` |
| `test-design` | `sdd-test-design` |
| `tasks` | `sdd-tasks` |
| `apply` | `sdd-apply` |
| `review` | `sdd-review` |
| `review-security` | `sdd-review-security` |
| `verify` | `sdd-verify` |
| `archive` | `sdd-archive` |
| `sdd-new` | orchestrator workflow |
| `select-change` | ask user to choose |
| `resolve-blockers` | `resolve-blockers` |
| `none` | `none` |

Phase envelopes may use either the native/status token or the phase agent token for `next_recommended`. The orchestrator MUST normalize through this table before routing or validating successors.

Example:

```markdown
**Status**: success
**Summary**: Proposal created for `{change-name}`. Defined scope, approach, and rollback plan.
**Artifacts**: Engram `sdd/{change-name}/proposal` | `openspec/changes/{change-name}/proposal.md`
**Next**: sdd-spec
**Risks**: None
**Skill Resolution**: paths-injected — 3 skills (react-19, typescript, tailwind-4)
(other values: `fallback-registry`, `fallback-path`, or `none — no registry found`)
```

## E. Artifact Naming Convention

- `sdd-propose` and `sdd-spec` are phase/agent names.
- `proposal` and `spec` are singular Engram artifact keys: `sdd/{change-name}/proposal`, `sdd/{change-name}/spec`.
- `specs` is the OpenSpec/status collection name because file-based mode may write multiple domain files under `openspec/changes/{change-name}/specs/{domain}/spec.md`.
- `sdd-test-design` is the phase/agent token; `test-design` is the native/status token and artifact key: `sdd/{change-name}/test-design` or `openspec/changes/{change-name}/test-design.md`.
- Persisted camelCase state/status fields use `testDesign` when a field name cannot contain hyphens.
- Do not use `sdd-proposal`, `sdd-proposals`, `sdd-specs`, `sdd-test-design`, or `testDesign` as Engram artifact keys.

## F. Review Workload Guard

SDD must protect reviewer cognitive load, not only generate tasks.

- The default PR review budget is **400 changed lines** (`additions + deletions`), but SDD Session Preflight may set `review_budget_lines` to another value.
- The orchestrator MUST cache a delivery strategy at session start: `ask-on-risk` (default), `auto-chain`, `single-pr`, or `exception-ok`.
- The orchestrator MUST pass `delivery_strategy` to `sdd-tasks` and the resolved decision to `sdd-apply`.
- `sdd-tasks` MUST forecast whether the planned work may exceed that budget.
- The forecast MUST include exact plain-text guard lines: `Decision needed before apply: Yes|No`, `Chained PRs recommended: Yes|No`, `Chain strategy: stacked-to-main|feature-branch-chain|pending`, `Size exception: approved|pending|none`, `Review budget lines: <number>`, `Review budget risk: Low|Medium|High`, and legacy `400-line budget risk: Low|Medium|High`.
- `size:exception` is a delivery/approval decision, not a chain strategy. Represent it with `Size exception`, and keep `Chain strategy` limited to `stacked-to-main`, `feature-branch-chain`, or `pending`.
- If the forecast is high, `sdd-tasks` MUST recommend chained or stacked PRs using deliverable work units.
- `sdd-apply` MUST NOT start oversized work unless the delivery strategy resolves to chained/stacked PR slices or explicitly accepted `size:exception`.
- Each chained PR slice must have a clear start, clear finish, autonomous scope, verification, and reasonable rollback.
- In a Feature Branch Chain, PR #1 targets the feature/tracker branch and later child PRs target the immediate previous PR branch; if GitHub shows previous slices in a child diff, retarget/rebase until the diff is clean.

This guard exists to reduce reviewer burnout and keep implementation delivery safe. Do not treat it as optional process noise.
