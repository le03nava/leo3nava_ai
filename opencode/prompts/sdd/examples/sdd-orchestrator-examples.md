# SDD Orchestrator Examples

Long-form examples live here so `prompts/sdd/sdd-orchestrator.md` stays focused on contracts and hard gates.

## Example 1 - Preflight Dialog -> Cached Session State

**Trigger:** User says "use SDD to add dark mode".

```text
Orchestrator: [ask-questions tool - 4 base groups in one call]
  Pace:      Interactive <- user picks this
  Artifacts: OpenSpec    <- user picks this
  PRs:       Ask me      <- user picks this
  Review:    400 lines   <- user picks this

Orchestrator caches session state:
  {
    "execution_mode":    "interactive",
    "artifact_store":    "openspec",
    "delivery_strategy": "ask-on-risk",
    "review_budget_lines": 400
  }

-> Entry Routing classifies this as a new mutating SDD change, then runs backend-aware Init Guard:
  artifact_store.mode = openspec
  checks openspec/config.yaml
  -> Not found -> delegates sdd-init sub-agent with artifact_store.mode = openspec
  -> sdd-init writes openspec/config.yaml. Delegates sdd-explore, then sdd-propose.
-> Shows proposal summary to user, asks: "Continuar con spec y design?"
```

If the user had picked `PRs: Chained`, preflight would also collect the conditional chain strategy in the same grouped question when possible:

```text
  PRs:            Chained              <- maps to delivery_strategy: auto-chain
  Chain Strategy: Feature branch chain <- maps to chain_strategy: feature-branch-chain
```

If the user picks `PRs: Ask me`, chain strategy is intentionally deferred until `sdd-tasks` forecasts chaining and the user chooses to split.

When `PRs: Chained` is selected, the cached session state includes both delivery and chain strategy:

```json
{
  "delivery_strategy": "auto-chain",
  "chain_strategy": "feature-branch-chain"
}
```

Equivalent init checks by mode:

| Mode | Init check |
| --- | --- |
| `engram` | `sdd-init/{project}` plus `sdd/{project}/testing-capabilities` |
| `openspec` | `openspec/config.yaml` |
| `hybrid` | Both Engram observations and `openspec/config.yaml` |
| `none` | Current-session `sdd-init` result only; not recoverable later |

## Example 2 - Phase Returns `partial` -> Gatekeeper Catches -> Re-run -> Success

**Trigger:** Automatic mode, `sdd-spec` returns.

```text
sdd-spec returns:
  status:           "partial"    <- Gatekeeper: status is not "success"
  artifacts:        [{ type: "spec", reference: resolved by artifact_store.mode }]
  next_recommended: "sdd-design"

Gatekeeper checklist:
  [ ] Status: success?           FAIL - status is "partial"
  [x] Artifact readable?         PASS - resolver can read the spec reference from the selected backend
  [x] No hallucination?          PASS - resolved reference exists in Engram/OpenSpec, or inline context for none
  [ ] No drift?                  SKIP - blocked by status failure
  [ ] Routing coherence?         SKIP - blocked by status failure

Action: Re-run sdd-spec with feedback:
  "Previous run returned status: partial.
   Specific failure: spec sections 3 and 4 are incomplete (missing acceptance criteria).
   Complete those sections and return status: success."

sdd-spec (retry) returns:
  status:           "success"
  artifacts:        [{ type: "spec", reference: resolved by artifact_store.mode }]
  next_recommended: "sdd-design"

Gatekeeper checklist (retry):
  [x] Status: success?           PASS
  [x] Artifact readable?         PASS
  [x] No hallucination?          PASS
  [x] No drift?                  PASS
  [x] Routing coherence?         PASS
  [x] State persisted?           PASS - normalized `next_recommended` -> state `nextRecommended`

State update written before launching design:
  schemaName: gentle-ai.sdd-state
  currentPhase: spec
  completedPhases: [spec]
  nextRecommended: design

-> Gate PASS. Orchestrator continues to sdd-design automatically.
```
