/**
 * sdd-cost-tracker plugin
 *
 * Automatically captures token/cost data for SDD phase sub-agents and posts
 * a PhaseRecord to the sdd-cost-tracker HTTP server when the child session ends.
 *
 * Capture flow:
 *   tool.execute.before (Task tool)
 *     → detect subagent_type matching sdd-*
 *     → extract changeName from the launch envelope
 *     → queue { phase, changeName } keyed by parent sessionID
 *
 *   event: session.created (child session with parentID)
 *     → associate childSessionID → { phase, changeName, project }
 *
 *   event: message.updated (AssistantMessage in a tracked child session)
 *     → accumulate tokens + cost by childSessionID
 *
 *   event: session.deleted
 *     → POST /phases with the accumulated totals for that session
 */

import type { Plugin } from "@opencode-ai/plugin"

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const TRACKER_URL = process.env.SDD_COST_TRACKER_URL ?? "http://127.0.0.1:7438"

// ---------------------------------------------------------------------------
// Internal types
// ---------------------------------------------------------------------------

/** Pending context queued from tool.execute.before, keyed by parent sessionID. */
interface PendingContext {
  phase: string
  changeName: string
}

/** Full tracking context attached to a live child session. */
interface SessionContext {
  phase: string
  changeName: string
  project: string
  modelId: string | null
  providerId: string | null
  tokensInput: number
  tokensOutput: number
  tokensReasoning: number
  tokensCacheRead: number
  tokensCacheWrite: number
  costUsd: number
  startedAt: number
}

// ---------------------------------------------------------------------------
// Regex helpers
// ---------------------------------------------------------------------------

const RE_SUBAGENT_TYPE = /subagent_type[:\s]+sdd-([a-z-]+)/i
const RE_CHANGE_NAME = /changeName[:\s"']+([^\s"',\n]+)/i

function extractSddPhase(text: string): string | null {
  const m = RE_SUBAGENT_TYPE.exec(text)
  return m ? `sdd-${m[1]}` : null
}

function extractChangeName(text: string): string | null {
  const m = RE_CHANGE_NAME.exec(text)
  return m ? m[1] : null
}

// ---------------------------------------------------------------------------
// HTTP helper
// ---------------------------------------------------------------------------

async function postPhase(sessionId: string, ctx: SessionContext): Promise<void> {
  const now = Math.floor(Date.now() / 1000)

  const body = JSON.stringify({
    project: ctx.project,
    change_name: ctx.changeName,
    phase: ctx.phase,
    session_id: sessionId,
    model_id: ctx.modelId,
    provider_id: ctx.providerId,
    tokens_input: ctx.tokensInput,
    tokens_output: ctx.tokensOutput,
    tokens_reasoning: ctx.tokensReasoning,
    tokens_cache_read: ctx.tokensCacheRead,
    tokens_cache_write: ctx.tokensCacheWrite,
    cost_usd: ctx.costUsd,
    started_at: ctx.startedAt,
    completed_at: now,
  })

  try {
    const res = await fetch(`${TRACKER_URL}/phases`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body,
    })

    if (!res.ok) {
      const text = await res.text().catch(() => "(no body)")
      console.error(
        `[sdd-cost-tracker] POST /phases failed: HTTP ${res.status} — ${text}`,
      )
    }
  } catch (err) {
    // Fire-and-forget: never crash the session on a tracking failure
    console.error(`[sdd-cost-tracker] POST /phases error: ${err}`)
  }
}

// ---------------------------------------------------------------------------
// Plugin factory
// ---------------------------------------------------------------------------

const SddCostTrackerPlugin: Plugin = async ({ project }) => {
  /**
   * Queued contexts from tool.execute.before, waiting to be associated with a
   * child session once session.created fires with a parentID.
   * Key: parentSessionID
   */
  const pendingByParent = new Map<string, PendingContext>()

  /**
   * Active tracking state for child sessions.
   * Key: childSessionID
   */
  const sessions = new Map<string, SessionContext>()

  return {
    // -----------------------------------------------------------------------
    // Intercept Task tool launches to detect SDD sub-agent invocations
    // -----------------------------------------------------------------------
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "Task") return

      // The prompt is carried in output.args — cast to any since the schema
      // varies by tool.
      const args = (output as any).args ?? {}
      const prompt: string =
        typeof args.prompt === "string" ? args.prompt : JSON.stringify(args)

      const phase = extractSddPhase(prompt)
      if (!phase) return

      const changeName = extractChangeName(prompt)
      if (!changeName) return

      // input.sessionID is the parent (orchestrator) session
      const parentSessionID: string | undefined = (input as any).sessionID
      if (!parentSessionID) return

      pendingByParent.set(parentSessionID, { phase, changeName })
    },

    // -----------------------------------------------------------------------
    // React to all bus events
    // -----------------------------------------------------------------------
    event: async ({ event }: { event: { type: string; properties?: any } }) => {
      const { type, properties } = event

      // -------------------------------------------------------------------
      // session.created — associate child session with pending context
      // -------------------------------------------------------------------
      if (type === "session.created") {
        const childID: string | undefined = properties?.info?.id
        const parentID: string | undefined = properties?.info?.parentID

        if (!childID || !parentID) return

        const pending = pendingByParent.get(parentID)
        if (!pending) return

        pendingByParent.delete(parentID)

        sessions.set(childID, {
          phase: pending.phase,
          changeName: pending.changeName,
          project: project ?? "",
          modelId: null,
          providerId: null,
          tokensInput: 0,
          tokensOutput: 0,
          tokensReasoning: 0,
          tokensCacheRead: 0,
          tokensCacheWrite: 0,
          costUsd: 0,
          startedAt: Math.floor(Date.now() / 1000),
        })
        return
      }

      // -------------------------------------------------------------------
      // message.updated — accumulate tokens & cost for tracked sessions
      // -------------------------------------------------------------------
      if (type === "message.updated") {
        const msg = properties?.message
        if (!msg || msg.role !== "assistant") return

        const sessionID: string | undefined = properties?.sessionID
        if (!sessionID) return

        const ctx = sessions.get(sessionID)
        if (!ctx) return

        // Extract model/provider from the message metadata (first time seen)
        if (!ctx.modelId && msg.modelID) ctx.modelId = msg.modelID
        if (!ctx.providerId && msg.providerID) ctx.providerId = msg.providerID

        // Accumulate token counts from each message part (content blocks)
        const usage = msg.tokens ?? msg.usage
        if (usage) {
          ctx.tokensInput += usage.input ?? usage.inputTokens ?? 0
          ctx.tokensOutput += usage.output ?? usage.outputTokens ?? 0
          ctx.tokensReasoning += usage.reasoning ?? usage.reasoningTokens ?? 0
          ctx.tokensCacheRead += usage.cacheRead ?? usage.cacheReadTokens ?? 0
          ctx.tokensCacheWrite += usage.cacheWrite ?? usage.cacheWriteTokens ?? 0
        }

        // Accumulate cost
        const cost = msg.cost ?? msg.costUSD ?? 0
        ctx.costUsd += typeof cost === "number" ? cost : 0
        return
      }

      // -------------------------------------------------------------------
      // session.deleted — flush accumulated data to the tracker
      // -------------------------------------------------------------------
      if (type === "session.deleted") {
        const sessionID: string | undefined =
          properties?.info?.id ?? properties?.sessionID

        if (!sessionID) return

        const ctx = sessions.get(sessionID)
        if (!ctx) return

        sessions.delete(sessionID)

        // Only post if we actually captured something meaningful
        if (ctx.tokensInput === 0 && ctx.tokensOutput === 0 && ctx.costUsd === 0) return

        await postPhase(sessionID, ctx)
      }
    },
  }
}

export default SddCostTrackerPlugin
