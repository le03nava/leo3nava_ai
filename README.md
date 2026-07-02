# leo3nava_ai

Repository for reusable AI agent prompts, opencode skills, and Spec-Driven Development (SDD) workflow contracts. It is not an application runtime; it is a distribution and maintenance workspace for AI-assisted development instructions.

## Quick path

From the repository root, sync the current repository content into your Windows agent configurations:

```powershell
# Install or refresh skills
.\scripts\sdd_init_skills.ps1

# Install or refresh agents
.\scripts\sdd_init_agents.ps1
```

Expected destinations:

| Source | Destination |
|--------|-------------|
| `skills/` | `%USERPROFILE%\.config\opencode\skills` |
| `skills/` | `C:\Users\leo3n\.copilot\skills` |
| `agents/` | `%USERPROFILE%\.config\opencode\prompts` |
| `agents/` | `C:\Users\leo3n\.copilot\agents` |

The scripts only sync to tools whose base directories already exist. Missing destinations are skipped with an informational message, and existing destinations still receive the files. Destination subdirectories are created when needed and matching files are overwritten on rerun.

## Repository layout

| Path | Purpose |
|------|---------|
| `agents/` | Agent prompt definitions, including SDD phase agents. |
| `skills/` | Reusable opencode skills and shared SDD contracts. |
| `scripts/` | Windows PowerShell sync scripts for opencode and Copilot setup. |
| `openspec/` | Spec-driven documentation for repository capabilities and archived changes. |
| `LICENSE` | MIT license for this repository. |

## SDD workflow assets

The repository contains a full SDD workflow split into dedicated phase agents and skills:

- `sdd-init`
- `sdd-explore`
- `sdd-propose`
- `sdd-spec`
- `sdd-security-applicability`
- `sdd-design`
- `sdd-security-design` (only when security applicability is impacting)
- `sdd-test-design`
- `sdd-tasks`
- `sdd-apply`
- `sdd-review`
- `sdd-verify`
- `sdd-archive`

Phase order: `explore? -> propose -> spec -> security-applicability -> design -> security-design? -> test-design -> tasks -> apply -> review -> verify -> archive`.

The review phase writes `openspec/changes/{change-name}/review-report.md` in OpenSpec mode, or `sdd/{change-name}/review` in Engram/hybrid mode. Verification consumes that non-blocking review evidence without owning the full review matrix, and archive requires both non-blocking review and passing verification.

Shared contracts live under `skills/_shared/` and define persistence, status, security, language-domain, and executor-boundary rules used by the SDD agents.

## Requirements

- Windows PowerShell.
- `USERPROFILE` must be set for sync scripts.
- At least one supported base directory must exist to receive synced files: `%USERPROFILE%\.config\opencode` or `C:\Users\leo3n\.copilot`.
- No package manager, build system, or test runner is required by this repository.

## Verification

There is no application test runner configured. For script-related changes, verify behavior with isolated PowerShell smoke checks that avoid modifying the real user opencode directory unless that is the intended operation.

## License

MIT License. See `LICENSE` for details.
