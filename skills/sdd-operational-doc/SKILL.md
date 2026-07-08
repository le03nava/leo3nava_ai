---
name: sdd-operational-doc
description: "Trigger: operational doc, documento operativo, post-archive SDD. Generate an operations document from archived SDD evidence."
disable-model-invocation: true
user-invocable: true
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
---

## Language Domain Contract

Follow `skills/_shared/language-domain-contract.md`. The generated operational document defaults to neutral professional Spanish because this artifact is a Spanish operational handoff document.

## Activation Contract

Run manually after an SDD change has been archived and the user asks for an operational document, operations manual, production handoff, or `sdd-operational-doc`.

This utility is post-archive only. It must not modify SDD DAG state, rerun phases, re-archive, or claim missing evidence as fact.

## Inputs

Accept from the user or launch context:
- Archived change name, or an archive folder path.
- Artifact store mode when known: `openspec | engram | hybrid | none`.
- Optional explicit product metadata: product, application owner, platform, IT project lead, developer, support roles, retention policy, and target output path.

## Evidence Sources

Use the selected backend through `skills/_shared/persistence-contract.md`.

| Mode | Read from |
| --- | --- |
| `openspec` | `openspec/changes/archive/YYYY-MM-DD-{change-name}/` |
| `engram` | `sdd/{change-name}/archive-report` and linked artifact observations |
| `hybrid` | Resolve both and follow the Hybrid Conflict Policy before choosing authority |
| `none` | Only current conversation/context; label the document as non-recoverable draft |

When reading an OpenSpec archive, inspect available `proposal.md`, `specs/**/spec.md`, `design.md`, `test-design.md`, `tasks.md`, `review-report.md`, `review-security-report.md`, `verify-report.md`, and any archive report/evidence files.

## Hard Rules

- Use `assets/operational-document-template.md` as the mandatory output structure.
- Keep every numbered section from 1 through 9, including sub-sections.
- If a section does not apply, write exactly `No aplica.` in that section unless the template requires a more specific sentence.
- Do not invent owners, systems, SQL, jobs, endpoints, schedules, backup commands, retention windows, thresholds, log paths, or escalation roles.
- If required operational evidence is absent but the section concept applies, write `Pendiente de confirmar:` followed by the missing evidence.
- Diagrams R1, R2, R3, and R4 are mandatory. Use Mermaid diagrams. If evidence is incomplete, include a conservative diagram with explicit `Pendiente de confirmar` nodes.
- Section 4 must describe execution of the product/entrypoint. Do not write a detailed installation procedure.
- Section 4.1 writes exactly `No aplica.` unless the change is BI, ETL, ODI, or WebService load related.
- Section 5 writes exactly `No aplica.` unless UI, reports, dashboards, or frontend assets are touched.
- Section 6.4 R4 may use only `Escalar a Soporte` as an escalation leaf.
- Backup, quarantine, restart, monitoring, and reprocess instructions must be operationally concrete or explicitly marked pending.
- Preserve safe-evidence boundaries: summarize review/security evidence and link/cite refs; do not copy full review matrices.

## Decision Gates

| Condition | Action |
| --- | --- |
| Archived change cannot be found | Stop and ask for the archive path or change name. |
| Hybrid backends differ materially | Stop and ask which backend is authoritative. |
| Product metadata is missing | Generate with `Pendiente de confirmar` fields; do not block. |
| Operational commands are missing | Do not fabricate; include pending placeholders with the exact missing command type. |
| User provided target path | Write the document there after reading existing file first if it exists. |
| No target path provided | Return the document inline and suggest a path under the archived change folder. |

## Execution Steps

1. Resolve the archived change and selected backend.
2. Read the template at `skills/sdd-operational-doc/assets/operational-document-template.md`.
3. Read archived SDD artifacts and collect only evidence needed for the template.
4. Derive entrypoints, touched objects, systems, schedules, UI impact, technologies, monitoring signals, logs, backup/reprocess operations, and support gaps from evidence.
5. Generate the complete document in neutral professional Spanish.
6. If writing to disk, use a safe Markdown path such as `openspec/changes/archive/YYYY-MM-DD-{change-name}/operational-document.md` unless the user provided another path.
7. Return a concise summary with output location, sections marked `No aplica.`, and fields marked `Pendiente de confirmar`.

## Output Contract

Return:
- Generated document path, or `inline only`.
- Evidence sources read.
- Count/list of `Pendiente de confirmar` items.
- Confirmation that all sections 1 through 9 and diagrams R1-R4 are present.

## References

- `skills/sdd-operational-doc/assets/operational-document-template.md` — mandatory document skeleton.
- `skills/_shared/persistence-contract.md` — backend resolution and hybrid conflict policy.
- `skills/_shared/openspec-convention.md` — OpenSpec archive path conventions.
- `skills/_shared/language-domain-contract.md` — artifact language rules.
