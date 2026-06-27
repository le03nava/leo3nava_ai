---
name: sdd-init
description: "Trigger: sdd init, iniciar sdd, openspec init. Initialize SDD context, testing capabilities, registry, and persistence."
disable-model-invocation: true
user-invocable: false
license: MIT
metadata:
  author: gentleman-programming
  version: "3.0"
  delegate_only: true
---

<!--
Copyright (c) 2026 gentleman-programming
Licensed under the MIT License.

Modificaciones bajo Copyright (c) 2026 FC-OXXO
Licensed under the MIT License.
-->

> **ORCHESTRATOR GATE**: Follow `skills/_shared/executor-boundary.md`.
> This skill is for the dedicated `sdd-init` executor only.

## Language Domain Contract

Follow `skills/_shared/language-domain-contract.md`.

## Activation Contract

Run this phase when the orchestrator/user asks to initialize SDD in a project. 
You are the phase executor: do the work yourself, do not delegate, and do not behave like the orchestrator.

## Hard Rules

- Detect the real stack, conventions, architecture, testing tools, and persistence mode; never guess.
- In `engram` mode, do **not** create `openspec/`.
- In `openspec` mode, follow `../_shared/openspec-convention.md` and write file artifacts.
- In `hybrid` mode, write both openspec files and Engram observations.
- In Engram-capable modes, persist project context as `sdd-init/{project}` and testing capabilities separately as `sdd/{project}/testing-capabilities`.
- In OpenSpec-capable modes, persist project context and testing capabilities in `openspec/config.yaml`.
- Build the skill registry following `skill-registry` rules. Persist `.atl/skill-registry.md` only in modes that allow local support files; in `mode=none`, return the registry inline only.
- Save the registry to Engram as `skill-registry` when Engram is available.
- Use `capture_prompt: false` for automated SDD/config saves when supported; omit it if the tool schema lacks it.
- If `openspec/` already exists, report what exists and ask before updating it.

## Decision Gates

| Input | Action |
|---|---|
| `mode=engram` | Save context and capabilities to Engram only. |
| `mode=openspec` | Create/update openspec bootstrap files only. |
| `mode=hybrid` | Do both Engram and openspec persistence. |
| `mode=none` | Return detected context and registry inline only; write no SDD/OpenSpec/Engram artifacts and no local support files. |
| `openspec/` already exists | Report existing files and ask before updating OpenSpec artifacts. |
| strict TDD marker/config found | Use that value. |
| no marker/config but test runner exists | Default `strict_tdd: true`. |
| no test runner | Set `strict_tdd: false` and explain unavailable. |

## Execution Steps

1. Follow **Section A** from `skills/_shared/sdd-phase-common.md`.
2. Inspect project files (`package.json`, `app.json`, `app.config.js`, `app.config.ts`, `metro.config.js`, `react-native.config.js`, `android/`, `ios/`, `go.mod`, `pyproject.toml`, `pom.xml`, `build.gradle`, `build.gradle.kts`, `settings.gradle`, `settings.gradle.kts`, `*.kt`, `*.kts`, CI, lint/test config) and summarize stack/conventions.
3. Detect test runner, test layers, coverage, linter, type checker, and formatter.
4. Resolve Strict TDD from agent marker, `openspec/config.yaml`, detected runner fallback, or no-runner fallback.
5. Initialize persistence for the resolved mode.
6. Build `.atl/skill-registry.md` using the skill-registry scan rules, except in `mode=none` where the registry is returned inline only.
7. Persist project context, testing capabilities, and registry using the exact artifact names for the resolved mode.
8. Return the structured initialization envelope.

## Output Contract

Return the full Section D envelope from `skills/_shared/sdd-phase-common.md`: `status`, `executive_summary`, `detailed_report`, `artifacts`, `next_recommended`, `risks`, and `skill_resolution`.
Include project, stack, persistence mode, Strict TDD status, testing capability table, registry path, and next `/sdd-explore` or `/sdd-new` step.
The `artifacts` list MUST explicitly report each artifact as saved, skipped, or blocked:

- `sdd-init/{project}` Engram project context observation ID, when applicable.
- `sdd/{project}/testing-capabilities` Engram testing capabilities observation ID, when applicable.
- `skill-registry` Engram observation ID, when applicable.
- `.atl/skill-registry.md` path, or `inline only` in `mode=none`.
- `openspec/config.yaml` path, when applicable.

## References

- [references/init-details.md](references/init-details.md) — detection checklist, Engram payloads, config skeleton, and output templates.
- `../_shared/sdd-phase-common.md` — skill loading protocol.
- `../_shared/engram-convention.md` — Engram artifact naming.
- `../_shared/openspec-convention.md` — openspec layout and rules.
