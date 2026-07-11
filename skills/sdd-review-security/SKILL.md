---
name: sdd-review-security
description: "Validate embedded secure-design evidence and persist canonical review-security-report.json plus derived Markdown. Trigger: orchestrator launches review-security after non-blocking sdd-review."
disable-model-invocation: true
user-invocable: false
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
  delegate_only: true
---

> **ORCHESTRATOR GATE**: Follow `skills/_shared/executor-boundary.md`.
> This skill is for the dedicated `sdd-review-security` executor only.

## Language Domain Contract

Follow `skills/_shared/language-domain-contract.md`.

## Activation Contract

Run after a non-blocking `sdd-review` and before `sdd-verify`. Validate narrative `design.md#secure-development-design`, `test-design.md`, tasks/apply evidence, changed-file context, and general review evidence against the security catalog. General review evidence is canonical `review-report.json` when present plus derived `review-report.md` / `sdd/{change-name}/review` for compatibility; JSON is authoritative on conflict. Persist two coordinated owned artifacts: canonical `review-security-report.json` plus derived Markdown compatibility view `review-security-report.md` / `sdd/{change-name}/review-security`.

This phase owns security-review verdicts, compact `SEC-*` validation, corporate Source ID validation when applicable, missed-omission checks, safe-evidence checks, `N/A` decisions, blockers, warning carry-forward, and next routing. It does not replace general review, verification, archive readiness, or implementation fixes.

## Phase Artifact Contract

Follow the shared contracts instead of duplicating their rules:

| Concern | Contract |
| --- | --- |
| Backend mechanics | `skills/_shared/sdd-phase-common.md` Sections B/C and `skills/_shared/persistence-contract.md`. |
| Post-apply gates | `skills/_shared/sdd-post-apply-gates.md`. |
| Security vocabulary/routing/safe evidence | `skills/_shared/sdd-security-contract.md`. |
| Catalog authority | `references/security-guideline-catalog.operational.json` is the canonical source for automation, audit inventory, compact controls, Source ID text, mappings, and validation counts; `references/security-guideline-catalog.md` is a derived human/audit view. |
| JSON schema | `references/review-security-report.schema.json` is the canonical per-change security-review report contract. |
| Markdown presentation | `references/report-template.md` is the derived Markdown compatibility presentation generated from canonical JSON. |
| Detailed validation rules | `references/validation-rules.md`; load only after readiness gates pass and row validation is needed. |
| Required inputs | Structured status; narrative `design.md#secure-development-design`; non-blocking general review evidence from the selected backend: canonical `review-report.json` when present plus derived `review-report.md` / `sdd/{change-name}/review` compatibility view; tasks/apply evidence; changed-file context; `test-design.md`; security catalog; shared security contract. |
| Produced artifact | Canonical `sdd/{change-name}/review-security-report.json` plus derived `sdd/{change-name}/review-security` in Engram/hybrid mode, or canonical `openspec/changes/{change-name}/review-security-report.json` plus derived `openspec/changes/{change-name}/review-security-report.md` in OpenSpec mode. |
| Mutates | None outside the produced security review report artifact. |
| JSON authority | Build, validate, persist, and read back canonical `review-security-report.json` first. Render Markdown only from that JSON; Markdown never wins on conflict. |
| Matrix ownership | Only this phase owns compact/source-row validation. Validate all 155 Source IDs exactly once when source-row validation applies, but write the full Source ID matrix only when audit mode is explicitly requested; otherwise write coverage summaries and focused findings. Do not copy or re-score the general 96-control matrix. |
| Success routing | Non-blocking verdict: `next_recommended: verify`. |
| Failure routing | Missing mandatory evidence, incomplete exceptions, blocked rows, or security blockers: `next_recommended: apply` or `resolve-blockers` according to whether remediation is implementation work or artifact/config repair. |

## Decision Gates

| Situation | Action |
| --- | --- |
| Shared post-apply, safe-evidence, dependency, or persistence gate fails | Follow `skills/_shared/sdd-post-apply-gates.md`; keep verify/archive unavailable. |
| Embedded `design.md#secure-development-design` is missing | Return `blocked` with `next_recommended: resolve-blockers`. |
| General review evidence is missing, unreadable, ambiguous, blocking, missing canonical JSON when expected, or has stale/parity-failed Markdown | Return `blocked`/route per `sdd-post-apply-gates.md`; do not recreate general review or treat Markdown as authoritative over JSON. |
| Security-review JSON and Markdown disagree after rendering/read-back | JSON wins; mark Markdown stale/parity-failed, return `blocked` or `partial` with `next_recommended: resolve-blockers`, and do not let downstream phases consume the stale Markdown. |
| New-change evidence requires YAML/schema/matrices in design or all-row design `N/A` bookkeeping | Treat as invalid for the active flow; validate from narrative design, catalog, and artifact evidence. |
| Compact or Source ID rows are missing, duplicated, unknown, malformed, unmapped, unsafe, unsupported, or unsupported `N/A` | Persist no passing report; return `blocked` with `next_recommended: resolve-blockers` unless remediation clearly belongs to `apply`. |
| Proposal/specs/changed files/apply/test-design/review evidence prove an omitted security control applies | Persist a blocking report; route to `apply` for file/prompt/contract/task evidence remediation, otherwise `resolve-blockers`. |
| Applicable mandatory security evidence is absent and no complete approved exception exists | Mark `No` / blocked and route to `apply` when implementation/evidence work is needed. |
| Operational evidence leaks restricted identifiers, secrets, raw logs/payloads, full ID lists, generated bytes, final-document-only values, or invented details | Persist a blocking report and route by remediation owner. |
| Exact `Pendiente de confirmar:` or `No aplica.` appears | Treat as safe placeholder text, but still require safe non-leakage proof when a security obligation applies. |
| Only non-blocking warnings remain with complete mandatory safe evidence | Persist `PASS WITH WARNINGS` and return `next_recommended: verify`. |

## Execution Steps

1. Load supplemental skills via `skills/_shared/skill-resolver.md` and `sdd-phase-common.md` Section A.
2. Apply common post-apply gates; resolve/read required inputs from the selected backend or explicit `contextFiles`.
3. Confirm embedded secure design exists and selected-backend general review evidence is non-blocking. Consume canonical `review-report.json` as authoritative when present; use derived Markdown only for compatibility summaries, section anchors, and handoff text.
4. Load `references/validation-rules.md` after readiness passes, then parse narrative secure-design classification, applicable category rules, evidence expectations, exceptions, residual risks, safe-evidence policy, and omitted categories. Do not require design YAML/schema/matrices.
5. Validate compact `SEC-*` coverage and omissions against proposal/specs, changed files, tasks/apply evidence, `test-design.md`, and selected general review evidence using the detailed validation reference; when canonical JSON and derived Markdown disagree, JSON wins and stale/parity-failed Markdown routes to `resolve-blockers`.
6. When corporate Source ID validation applies, expand the catalog inventory and validate/report the expected universe according to the catalog, report template, and detailed validation reference.
7. Validate operational evidence leakage boundaries when operational evidence exists; preserve exact safe placeholders while rejecting unsafe evidence.
8. Build canonical `review-security-report.json` with schema identity, `changeName`, verdict/status, `nextRecommended`, source refs, general review handoff, compact control validation, expected/validated Source ID counts, coverage status, blockers, warnings, unsafe evidence rejections, warning carry-forward, artifact parity/read-back metadata, and no duplicated general 96-control matrix.
9. Validate JSON before Markdown rendering: required fields present, compact controls exact once, Source IDs exact once when applicable, expected/validated counts match the catalog, coverage status matches blockers, safe-evidence rules checked, `N/A`/exceptions complete, general review handoff cites canonical `review-report.json`, and routing/counts match verdict.
10. Render derived `review-security-report.md` / `sdd/{change-name}/review-security` from the canonical JSON using `references/report-template.md`. In summary mode, prove all 155 Source IDs were validated exactly once without printing the full matrix; include the full 155-row matrix only in explicit audit/full-matrix mode.
11. Persist and read back canonical JSON first, then derived Markdown, compare parity metadata, and register both artifacts in state/status handoff with JSON first using `authority: canonical` and Markdown second using `authority: derived`.

## Output Contract

Return the Section D envelope from `skills/_shared/sdd-phase-common.md`. Put `## Security Review Report Summary` in `detailed_report` with change, inputs inspected, verdict, canonical JSON ref, derived Markdown ref, row counts, blockers, non-blockers, operational evidence leakage verdict when evidence exists, placeholder safety notes, compact/source-row ownership validation, safe-evidence notes, unavailable tooling, artifact parity/read-back metadata, and next route. The `artifacts` array MUST list canonical JSON before derived Markdown; use notes such as `authority: canonical` and `authority: derived` until the shared envelope supports a dedicated authority field.

## Routing Contract

- `PASS` or `PASS WITH WARNINGS` with no blockers -> `status: success`, `next_recommended: verify`.
- Implementation/security evidence gaps -> persist `FAIL`, route `next_recommended: apply` when remediation is file, prompt, contract, task, or apply-evidence work.
- Missing/malformed/unsafe/conflicting context, catalog/schema repair, backend repair, unsupported `N/A`, missing mappings, or unsafe evidence cleanup -> `status: blocked`, `next_recommended: resolve-blockers` unless remediation clearly belongs to `apply`.
- Persistence failure after a useful report -> `status: partial`, `next_recommended: resolve-blockers`, include safe recovery details.
- Do not return camelCase `nextRecommended` from the phase envelope. CamelCase is for artifact/status/state metadata only.

## Rules

- ALWAYS run after non-blocking `sdd-review` and before `sdd-verify` for new changes.
- ALWAYS require narrative `design.md#secure-development-design` for active new changes.
- NEVER require design/test-design to materialize compact controls, Source IDs, schema fields, YAML/JSON, or exhaustive `N/A` rows.
- NEVER duplicate, recreate, or re-score the 96-control general review matrix; consume canonical `review-report.json` as handoff evidence and use Markdown only as compatibility.
- ALWAYS treat canonical `review-security-report.json` as the security-review source of truth. Derived Markdown exists for human/downstream compatibility only.
- Source-row presence alone is not compliance evidence; each row needs safe corroborating evidence, justified `N/A`, or complete approved exception.
- Return `next_recommended: verify` only for non-blocking security-review verdicts.

## References

- `../_shared/skill-resolver.md` — supplemental skill loading and `skill_resolution` protocol.
- `../_shared/sdd-phase-common.md` — phase retrieval, persistence, and return envelope.
- `../_shared/persistence-contract.md` — artifact keys, backend behavior, hybrid conflict policy, and read-back verification.
- `references/security-guideline-catalog.operational.json` — canonical structured catalog for scripts, Excel exports, row expansion, compact mappings, PCI alignment, source guideline text, and validation counts.
- `references/security-guideline-catalog.md` — derived human/audit view generated from the canonical JSON catalog.
- `references/review-security-report.schema.json` — canonical per-change `review-security-report.json` contract.
- `references/report-template.md` — derived `review-security-report.md` presentation contract generated from `review-security-report.json`.
- `references/validation-rules.md` — detailed compact/source-row validation, safe-evidence, routing, and report validation rules loaded after readiness passes.
- `../_shared/sdd-security-contract.md` — narrative secure-design and review-security report schema contracts.
- `../_shared/sdd-post-apply-gates.md` — common post-apply gates, review evidence consumption, routing defaults, safe evidence, and matrix ownership boundaries.
