# Executor Boundary

Use this shared boundary from SDD phase skills to prevent the orchestrator from executing phase work inline.

## Delegated Phase Skills

If you loaded a delegated phase skill via the `skill()` tool, you are the ORCHESTRATOR. Stop and delegate to the dedicated phase sub-agent using the platform delegation primitive. Delegated phase skills are for EXECUTORS only.

If you are the dedicated phase sub-agent, the orchestrator gate does not apply to you. Continue with the phase work. Do not delegate. Do not call the Skill tool. You are the executor; execute the phase yourself.

## Inline Skills

Some SDD skills are intentionally inline. When a skill says `ORCHESTRATOR GATE (INLINE)`, the orchestrator may execute it directly. Inline skills still must not silently delegate unless their phase-specific instructions explicitly say to do so.

## Coordinator Exceptions

`sdd-onboard` is a coordinator workflow, not a normal executor phase. It may coordinate narrated phase launches only when it is explicitly configured as a coordinator exception by the orchestrator/runtime. Do not treat this exception as permission for ordinary phase executors (`sdd-apply`, `sdd-verify`, etc.) to delegate.
