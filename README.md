# leo3nava_ai

Repository for reusable AI agent prompts, opencode skills, and Spec-Driven Development (SDD) workflow contracts. It is not an application runtime; it is a distribution and maintenance workspace for AI-assisted development instructions.

## Quick path

From the repository root, sync the current repository content into your Windows opencode configuration:

```powershell
# Install or refresh opencode skills
.\scripts\sdd_init_opencode_skills.ps1

# Install or refresh opencode prompts/agents
.\scripts\sdd_init_opencode_prompts.ps1
```

Expected destinations:

| Source | Destination |
|--------|-------------|
| `skills/` | `%USERPROFILE%\.config\opencode\skills` |
| `agents/` | `%USERPROFILE%\.config\opencode\prompts` |

The scripts create the destination directories when needed and overwrite matching files on rerun. They do not hardcode a user-specific home path.

## Repository layout

| Path | Purpose |
|------|---------|
| `agents/` | Agent prompt definitions, including SDD phase agents. |
| `skills/` | Reusable opencode skills and shared SDD contracts. |
| `scripts/` | Windows PowerShell sync scripts for opencode setup. |
| `openspec/` | Spec-driven documentation for repository capabilities and archived changes. |
| `LICENSE` | MIT license for this repository. |

## SDD workflow assets

The repository contains a full SDD workflow split into dedicated phase agents and skills:

- `sdd-init`
- `sdd-explore`
- `sdd-propose`
- `sdd-spec`
- `sdd-design`
- `sdd-tasks`
- `sdd-apply`
- `sdd-verify`
- `sdd-archive`

Shared contracts live under `skills/_shared/` and define persistence, status, language-domain, and executor-boundary rules used by the SDD agents.

## Requirements

- Windows PowerShell.
- `USERPROFILE` must be set for sync scripts.
- No package manager, build system, or test runner is required by this repository.

## Verification

There is no application test runner configured. For script-related changes, verify behavior with isolated PowerShell smoke checks that avoid modifying the real user opencode directory unless that is the intended operation.

## License

MIT License. See `LICENSE` for details.
