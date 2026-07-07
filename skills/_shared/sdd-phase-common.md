# SDD Phase — Common Protocol

Boilerplate identical across all SDD phase skills. Sub-agents MUST load this alongside their phase-specific SKILL.md.

Executor boundary: every SDD phase agent is an EXECUTOR, not an orchestrator. Do the phase work yourself. Do NOT launch sub-agents, do NOT call `delegate`/`task`, and do NOT bounce work back unless the phase skill explicitly says to stop and report a blocker.

## Launch Envelope Contract

Every SDD phase executor receives a structured `launch` envelope from the orchestrator before task-specific instructions. Treat it as the authoritative launch metadata for this run.

```yaml
launch:
  phase: sdd-<phase>
  changeName: {change-name}
  artifact_store:
    mode: engram | openspec | hybrid | none
  execution_mode: interactive | auto
  delivery_strategy: ask-on-risk | auto-chain | single-pr | exception-ok | null
  chain_strategy: stacked-to-main | feature-branch-chain | null
  model_assignment:
    requested_agent: sdd-<phase>
    resolved_model: {provider/model-or-runtime-default-or-unknown}
    resolved_model_source: explicit-phase | explicit-profile | orchestrator-synthesis | runtime-default | unknown
    escalation_reason: {reason-or-null}
  status:
    nextRecommended: {token}
    dependencies: {structured-status-dependencies}
    blockedReasons: []
  artifacts:
    refs: {artifact refs by type}
    paths: {file paths by type when available}
  actionContext:
    mode: repo-local | workspace-planning | memory-local | ephemeral
    workspaceRoot: {absolute-path-or-null}
    allowedEditRoots: []
  review:
    review_budget_lines: {number|null}
    current_slice_boundary: {text-or-null}
    size_exception: {approved/evidence-or-null}
  skill_paths:
    - {absolute SKILL.md path}
```

Consumption rules for executors:

- Read artifacts from `artifacts.refs` / `artifacts.paths` according to `artifact_store.mode`; do not reconstruct missing artifacts from prose or broad memory searches.
- Treat `status`, `dependencies`, `blockedReasons`, delivery/chain fields, review fields, and `actionContext` as launch constraints. If they are inconsistent with readable artifacts, return `blocked` instead of guessing.
- Respect `actionContext.allowedEditRoots` for any repository operation. If roots are missing or unsafe for the requested phase, return `blocked` before reading broadly, testing, editing, verifying, or archiving.
- Load supplemental skills from `skill_paths` using Section A. These are supplemental only; do not launch sub-agents or call skill tools to perform phase work.
- Unknown or unresolved fields must remain `null` or `unknown`. Do not invent model IDs, artifact refs, workspace roots, delivery decisions, review approvals, or missing state.

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

Every phase MUST return a structured envelope to the orchestrator. This section is the authoritative phase result contract.

Required envelope fields:

| Field | Required shape / meaning |
| --- | --- |
| `status` | One of `success`, `partial`, or `blocked` only. Do not invent values such as `hold`, `failed`, `done`, or `ok`. |
| `executive_summary` | 1-3 sentence human summary of what happened and why it matters. |
| `detailed_report` | Full phase output, or an explicit note that the full output is already inline and intentionally small. Required for every phase result. |
| `artifacts` | Array/list of artifacts produced, updated, read, or intentionally omitted. Use the artifact entry shape below. |
| `next_recommended` | Next bounded routing token or phase token, normalized by the orchestrator through `skills/_shared/sdd-status-contract.md`. |
| `risks` | Structured risk entries using the shape below, or `None`. |
| `skill_resolution` | How supplemental skills were loaded. Return the structured shape below so the orchestrator can gate missing required skills without guessing. |

Status semantics:

- `success`: the phase reached its objective, persisted or returned the expected artifact according to `artifact_store.mode`, and the next phase may be considered after gatekeeper validation.
- `partial`: the phase produced useful output but could not fully persist, verify, archive, or complete a required operation. Include recovery steps in `detailed_report` and route to `resolve-blockers` unless the phase-specific contract defines a safe retry.
- `blocked`: the phase could not safely proceed because it needs user input, dependency repair, artifact reconciliation, safe edit context, or another external decision. Set `next_recommended: resolve-blockers` unless a phase-specific contract routes to an earlier SDD phase for remediation.
- If a phase needs user input or orchestration, return `blocked`; do not ask the user directly from the sub-agent.

Artifact entry shape:

```yaml
artifacts:
  - type: explore | proposal | spec | design | test-design | tasks | apply-progress | review-report | review-security-report | verify-report | archive-report | state | other
    mode: engram | openspec | hybrid | none
    ref: "topic key, file path, or inline ref"
    persisted: true | false
    readable: true | false
    notes: "optional concise context"
```

Artifact rules:

- `success` requires every expected artifact for that phase to be `persisted: true` and `readable: true`, except in `none` mode where the artifact must be returned inline.
- `partial` must name which artifact or write failed and include the inline artifact content when safe.
- `hybrid` success requires both Engram and OpenSpec refs or an explicit statement that one side was repaired according to the Hybrid Conflict Policy.
- Artifacts must use the naming conventions in this file and `skills/_shared/persistence-contract.md`.

Risk entry shape:

```yaml
risks:
  - severity: CRITICAL | WARNING | SUGGESTION
    blocker: true | false
    message: "specific risk"
    evidence: "artifact ref, file path, command output, or rationale"
    owner: orchestrator | user | phase-agent | reviewer
```

Risk rules:

- Use `risks: None` only when there are no material risks.
- Any `CRITICAL` risk or `blocker: true` prevents dependent phases from launching.
- Warnings may continue only when explicitly non-blocking and consistent with the phase-specific rules.

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

Phase-specific minimum details:

| Phase | Minimum required detail |
| --- | --- |
| `sdd-explore` | Findings, relevant files/artifacts consulted, recommendation, uncertainty/risk. |
| `sdd-propose` | Proposal scope, non-goals, assumptions, unresolved product questions if any. |
| `sdd-spec` | Requirements/scenarios produced, domain/spec refs, proposal traceability. |
| `sdd-design` | Architecture approach, tradeoffs, affected components, spec traceability. |
| `sdd-test-design` | Test-design ref, planned cases, mandatory/non-mandatory coverage expectations, and no-impact assessment when applicable. |
| `sdd-tasks` | Task list refs plus Review Workload Forecast, estimated changed lines, chain/exception recommendation, and test-design traceability. |
| `sdd-apply` | Apply-progress ref, completed/pending task summary, files changed, verification run or reason not run, next slice boundary if chained. |
| `sdd-review` | Final review verdict, blocking/non-blocking summary, matrix validation summary, review-report ref, and next remediation or verification route. |
| `sdd-review-security` | Final security review verdict, blocking/non-blocking summary, compact/source-row validation summary, review-security-report ref, and next remediation or verification route. |
| `sdd-verify` | Final verdict `PASS`, `PASS WITH WARNINGS`, or `FAIL`; evidence table; CRITICAL/WARNING/SUGGESTION issues; verify-report ref. |
| `sdd-archive` | Archive destination/ref, included artifacts, final status, recovery path if partial. |

Response ordering:

- Persist artifacts according to `artifact_store.mode` before returning the final envelope.
- The final output must be text containing the envelope, not a tool result. If the final action is a persistence tool call, the orchestrator loses the analysis.
- Do not call `mem_session_summary`; session summaries are reserved for the top-level agent.

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

- The default PR review budget is **400 changed lines** (`additions + deletions`), unless the orchestrator has resolved a different `review_budget_lines` during deferred delivery planning.
- The orchestrator may keep `delivery_strategy` as `null` until `sdd-tasks` produces a Review Workload Forecast or the user explicitly requests delivery planning.
- The orchestrator MUST pass the current `delivery_strategy` value to `sdd-tasks` (`null` when deferred) and pass the resolved decision to `sdd-apply`.
- `sdd-tasks` MUST forecast whether the planned work may exceed that budget.
- The forecast MUST include exact plain-text guard lines: `Decision needed before apply: Yes|No`, `Chained PRs recommended: Yes|No`, `Chain strategy: stacked-to-main|feature-branch-chain|pending`, `Size exception: approved|pending|none`, `Review budget lines: <number>`, `Review budget risk: Low|Medium|High`, and legacy `400-line budget risk: Low|Medium|High`.
- `size:exception` is a delivery/approval decision, not a chain strategy. Represent it with `Size exception`, and keep `Chain strategy` limited to `stacked-to-main`, `feature-branch-chain`, or `pending`.
- If the forecast is high, `sdd-tasks` MUST recommend chained or stacked PRs using deliverable work units.
- `sdd-apply` MUST NOT start oversized work unless the delivery strategy resolves to chained/stacked PR slices or explicitly accepted `size:exception`.
- Each chained PR slice must have a clear start, clear finish, autonomous scope, verification, and reasonable rollback.
- In a Feature Branch Chain, PR #1 targets the feature/tracker branch and later child PRs target the immediate previous PR branch; if GitHub shows previous slices in a child diff, retarget/rebase until the diff is clean.

This guard exists to reduce reviewer burnout and keep implementation delivery safe. Do not treat it as optional process noise.
