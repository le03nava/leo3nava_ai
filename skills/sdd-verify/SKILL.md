---
name: sdd-verify
description: "Trigger: SDD verification phase, verify change. Execute tests and prove implementation matches specs, design, and tasks."
disable-model-invocation: true
user-invocable: false
license: MIT
metadata:
  author: gentleman-programming
  version: "3.0"
  delegate_only: true
---

> **ORCHESTRATOR GATE**: Follow `skills/_shared/executor-boundary.md`.
> This skill is for the dedicated `sdd-verify` executor only.

## Language Domain Contract

Follow `skills/_shared/language-domain-contract.md`.

## Activation Contract

Run when the orchestrator launches verification for an SDD change. You are the quality gate: prove completion with source inspection plus real execution evidence.

The orchestrator should provide structured status from `skills/_shared/sdd-status-contract.md`. Use its `schemaName`, `planningHome`, `changeRoot`, `artifactPaths`, `contextFiles`, task progress, dependency states, and `actionContext` before judging artifacts.

## Hard Rules

- Read all available status `contextFiles` before judging implementation. Full spec-driven verification reads proposal, specs, security applicability, design, required security design, test design, and tasks; partial artifact sets degrade as described below.
- Execute relevant tests; static analysis alone is never verification.
- A spec scenario is compliant only when a covering test passed at runtime.
- Compare specs first, design second, task completion third.
- Compare security-design controls and mandatory evidence before archive readiness can be claimed.
- Compare `test-design.md` planned cases against apply/verification evidence. Uncovered mandatory cases fail verification; uncovered non-mandatory cases are warnings only.
- Do not fix issues; report them for the orchestrator/user.
- Persist `verify-report` according to mode: Engram `sdd/{change-name}/verify-report`, OpenSpec `openspec/changes/{change-name}/verify-report.md`, hybrid both, or inline-only for `none`.
- If Strict TDD is active, load `strict-tdd-verify.md` from this skill directory; if inactive, never load it.
- Apply any `rules.verify` from `openspec/config.yaml`.
- Return the Section D envelope from `skills/_shared/sdd-phase-common.md`.

## Decision Gates

| Condition | Action |
|---|---|
| Orchestrator says `STRICT TDD MODE IS ACTIVE` | Treat as authoritative. |
| Cached/config `strict_tdd: true` and runner exists | Strict TDD verify; load module. |
| Strict TDD false and runner exists | Standard verify; skip TDD protocol checks. |
| No runner and specs exist | Do not claim full spec compliance; missing runtime evidence is CRITICAL unless config explicitly allows manual verification. |
| No runner and only tasks exist | Verify task completion only; verdict may be `PASS WITH WARNINGS`. |
| Strict TDD active but `apply-progress` or TDD evidence is missing | FAIL; report CRITICAL missing TDD evidence. |
| `actionContext.mode: workspace-planning` | Return `blocked` with `next_recommended: resolve-blockers`; full workspace implementation verification is not supported in this slice. |
| Changed files cannot be identified | Mark static correctness/design coherence as PARTIAL, record the skipped evidence, and return `next_recommended: resolve-blockers` unless runtime evidence still proves the required behavior. |
| Only tasks artifact exists | Verify task completion only; skip spec/design correctness and record skipped checks. |
| Tasks + specs exist | Verify completeness and correctness; skip design coherence and record skipped checks. |
| Proposal/specs/design/test-design/tasks exist | Verify all dimensions, including planned case coverage. |
| Applicability is security-impacting and `security-design.md` is missing | CRITICAL blocker; return `next_recommended: security-design`. |
| Mandatory security-design control has no implementation, verification evidence, or complete approved exception | CRITICAL `SECURITY_EVIDENCE_MISSING` and verdict `FAIL`. |
| Mandatory security exception is incomplete | CRITICAL `SECURITY_EXCEPTION_INCOMPLETE` and verdict `FAIL`. |
| Task incomplete | CRITICAL for core task, WARNING for cleanup task. |
| Test command exits non-zero | CRITICAL. |
| Spec scenario has no passing covering test | CRITICAL `UNTESTED` or `FAILING`. |
| Mandatory test-design case has no matching implementation, execution, or justified skip evidence | CRITICAL `UNTESTED` and verdict `FAIL`. |
| Non-mandatory test-design case has no matching evidence | WARNING; do not fail solely because of this uncovered non-mandatory case. |
| Design deviation exists | WARNING unless it breaks a spec. |
| Verification failure discovered | Report only; do not patch implementation. |
| Verify-report persistence fails | Return `partial` with `next_recommended: resolve-blockers` and the report inline in `detailed_report`. |

## Execution Steps

1. Load relevant skills via shared SDD Section A.
2. Retrieve artifacts via shared Section B for the active persistence mode, or read the concrete `contextFiles` from structured status.
3. Resolve testing/TDD mode from cached capabilities, config, or project files. Prefer `sdd/{project}/testing-capabilities`, then `openspec/config.yaml`, then project files.
4. Count completed and incomplete tasks. Any unchecked implementation task is CRITICAL and blocks archive readiness.
5. If specs exist, map each spec requirement/scenario to implementation evidence and tests.
6. If security design exists, map each mandatory control to implementation references, test-design cases, verification evidence, or complete approved exceptions; classify gaps as CRITICAL.
7. If test design exists, map each planned case to implementation, execution, apply-progress, security evidence, or justified skip evidence and classify mandatory gaps as CRITICAL and non-mandatory gaps as WARNING.
8. If design exists, check design decisions against changed code. If design is missing, skip design coherence and record why.
9. Run test, build/type-check, and coverage commands when available. For full spec verification, preserve gentle-ai's stricter runtime evidence: source inspection alone does not prove spec scenario compliance.
10. Build the behavioral and security compliance matrices from actual test results and evidence when specs/scenarios/security controls exist.
11. Validate the report before persistence: completeness table present, every spec scenario has a status, every security control has evidence/exception status when required, every test-design case has a coverage status, runtime evidence includes command and result, skipped dimensions are listed, Strict TDD sections are present when active, and any CRITICAL issue forces verdict `FAIL`.
12. Persist and return the verification report, including skipped dimensions for missing artifacts.

## Output Contract

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`. Put `## Verification Report` in `detailed_report` with change, mode, completeness table, build/tests/coverage evidence, spec compliance matrix, security evidence matrix, test-design coverage matrix, correctness table, design coherence table, skipped/degraded dimensions, issues grouped as CRITICAL/WARNING/SUGGESTION, and final verdict `PASS`, `PASS WITH WARNINGS`, or `FAIL`.

## Routing Contract

- Verdict `PASS` -> return `next_recommended: archive`.
- Verdict `PASS WITH WARNINGS` -> return `next_recommended: archive` only when there are no CRITICAL issues, all implementation tasks are complete, and warnings are explicitly non-blocking.
- Verdict `FAIL`, any CRITICAL issue, failing tests, missing required runtime evidence, missing Strict TDD evidence, or unchecked implementation tasks -> return `next_recommended: apply`.
- Status `blocked` due unsafe workspace, missing selected change, missing required artifacts, or unresolved configuration -> return `next_recommended: resolve-blockers` and do not claim archive readiness.
- Status `partial` because verify-report persistence failed -> return `next_recommended: resolve-blockers` unless the inline report clearly proves a retry can safely persist the same evidence.
- Do not return camelCase `nextRecommended` from the phase envelope. CamelCase is for status/state artifacts only.

## Graceful Artifact Handling

- **Tasks only**: verify objective task completion only. Do not claim spec correctness or design coherence. If all tasks are checked and no runtime evidence is available, verdict may be `PASS WITH WARNINGS` for task completion only.
- **Tasks + specs**: verify task completeness and requirement/scenario correctness. Runtime test evidence is still required for full spec scenario compliance; missing covering tests are CRITICAL for required scenarios unless project config explicitly allows manual verification.
- **Full artifacts**: verify completeness, correctness, security evidence, test-design planned case coverage, and coherence.
- **Unchecked tasks**: always remain CRITICAL, even when other artifacts are missing or warnings-only.

## References

- [references/report-format.md](references/report-format.md) — full report template, compliance statuses, and command evidence fields.
- [strict-tdd-verify.md](strict-tdd-verify.md) — load only when Strict TDD is active.
- `../_shared/sdd-phase-common.md` — skill loading, retrieval, persistence, and return envelope.
