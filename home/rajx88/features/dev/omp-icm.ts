// ICM extension for Oh My Pi (omp).
//
// Ports ICM's Claude Code hook coverage to omp's pi-style extension API:
//   - before_agent_start   -> icm hook start   (SessionStart wake-up pack, once per session)
//   - before_agent_start   -> icm hook prompt  (UserPromptSubmit recall, each turn)
//   - tool_execution_end   -> icm extract --enqueue + detached icm extract-pending (PostToolUse)
//   - session_compact      -> enqueue compaction summary + drain            (PreCompact)
//   - session_shutdown     -> enqueue recent assistant text + drain         (SessionEnd)
//
// Storage/recall instructions live in ~/.omp/agent/APPEND_SYSTEM.md and the
// /icm-recall + /icm-remember skills; this extension only wires the automatic
// injection + extraction that Claude Code gets from its icm hooks.
//
// Injection delegates to `icm hook start/prompt` so omp and Claude Code share
// one code path (single source of truth in the icm binary). Extraction uses the
// OpenCode-plugin enqueue/drain pattern (`icm extract --enqueue` is ~50ms with
// no model load; `icm extract-pending` loads the extractor once per batch in a
// detached worker) because [extraction] has no LLM summarizer configured and
// the inline `icm hook post` path would block the extension for seconds.

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent"
import { execFileSync, spawn } from "node:child_process"

const ICM_TIMEOUT_MS = 10_000
const EXTRACT_INPUT_CAP = 8_000
const DRAIN_EVERY = 10
const DRAIN_LIMIT = 30

// Tools whose output is rarely worth extracting.
const NOISE_TOOLS = new Set(["edit", "write", "question", "skill", "todowrite", "notify"])

let enqueueCount = 0

function projectName(cwd: string): string {
  const parts = cwd.split("/").filter(Boolean)
  return parts[parts.length - 1] ?? "project"
}

/// Capture stdout of `icm <args>`, optionally feeding `input` on stdin and
/// running in `cwd`. Returns the empty string on any failure so a missing/old
/// binary or empty memory store can never break a turn.
function icmCapture(args: string[], input?: string, cwd?: string): string {
  try {
    return String(
      execFileSync("icm", args, {
        encoding: "utf-8",
        timeout: ICM_TIMEOUT_MS,
        input,
        cwd,
        stdio: ["pipe", "pipe", "pipe"],
      }),
    ).trim()
  } catch {
    return ""
  }
}

/// Enqueue raw text for deferred extraction. Cheap (~50ms, no model load);
/// the heavy work happens once per drain in `icm extract-pending`.
function icmEnqueue(project: string, text: string, cwd?: string): void {
  try {
    execFileSync("icm", ["extract", "--enqueue", "-p", project], {
      encoding: "utf-8",
      timeout: ICM_TIMEOUT_MS,
      input: text,
      cwd,
      stdio: ["pipe", "pipe", "pipe"],
    })
  } catch {
    // silent — extraction is best-effort
  }
}

/// Drain the pending-extraction queue in a detached background process.
/// Fire-and-forget: the turn never waits on it, and the fastembed extractor
/// loads at most once per drain. ICM_WORKER=1 guards against re-entrant forks.
function icmDrainDetached(cwd?: string): void {
  try {
    const child = spawn("icm", ["extract-pending", "--limit", String(DRAIN_LIMIT)], {
      detached: true,
      stdio: "ignore",
      cwd,
      env: { ...process.env, ICM_WORKER: "1" },
    })
    child.unref()
  } catch {
    // silent — extraction is best-effort
  }
}

/// Pull a plain-text body out of an omp tool result, which may be a string,
/// a {content:[...]} array, or an object with text/output/stdout.
function textFromResult(result: unknown): string {
  if (typeof result === "string") return result
  if (Array.isArray(result)) {
    return result
      .map((b) => {
        if (typeof b === "string") return b
        if (b && typeof b === "object" && (b as any).type === "text") return (b as any).text
        return ""
      })
      .filter(Boolean)
      .join("\n")
  }
  if (result && typeof result === "object") {
    const r = result as any
    if (Array.isArray(r.content)) return textFromResult(r.content)
    for (const key of ["text", "output", "stdout"]) {
      if (typeof r[key] === "string") return r[key]
    }
  }
  return ""
}

/// Join the trailing assistant message text from the session, mirroring the
/// OpenCode plugin's compaction slice.
function assistantText(entries: unknown[]): string {
  return entries
    .filter((e) => (e as any)?.type === "message" && (e as any)?.message?.role === "assistant")
    .slice(-20)
    .map((e) => textFromResult((e as any).message.content))
    .filter(Boolean)
    .join("\n")
    .slice(-4000)
}

export default async function (pi: ExtensionAPI) {
  const version = icmCapture(["--version"])
  if (!version) {
    console.warn("[icm] icm binary not found in PATH — extension disabled")
    return
  }
  console.error(`[icm] extension loaded (${version})`)

  const injectedSessions = new Set<string>()

  pi.on("before_agent_start", async (event, ctx) => {
    try {
      const cwd = ctx.cwd
      const sessionId = ctx.sessionManager.getSessionId() ?? "no-session"

      // SessionStart wake-up pack only once per session; per-prompt recall
      // every turn (omp rebuilds the system prompt each agent loop).
      const wakeUp = injectedSessions.has(sessionId)
        ? ""
        : icmCapture(["hook", "start"], JSON.stringify({ cwd, session_id: sessionId }), cwd)

      const recall = icmCapture(
        ["hook", "prompt"],
        JSON.stringify({ user_message: event.prompt ?? "", cwd, session_id: sessionId }),
        cwd,
      )

      const injected = [wakeUp, recall].filter(Boolean).join("\n\n")
      if (!injected) return

      injectedSessions.add(sessionId)
      console.error(`[icm] injecting ${injected.split("\n").length} lines into system prompt`)
      return { systemPrompt: `${event.systemPrompt}\n\n${injected}` }
    } catch (err) {
      console.warn("[icm] unexpected error in before_agent_start handler", err)
      return
    }
  })

  pi.on("tool_execution_end", async (event, ctx) => {
    try {
      const toolName = String(event.toolName ?? "")
      if (toolName.startsWith("icm") || toolName.startsWith("mcp__icm__")) return
      if (NOISE_TOOLS.has(toolName.toLowerCase())) return
      if (event.isError) return

      const text = textFromResult(event.result)
      if (text.length < 20) return

      const cwd = ctx.cwd
      icmEnqueue(projectName(cwd), text.slice(0, EXTRACT_INPUT_CAP), cwd)
      enqueueCount++
      if (enqueueCount >= DRAIN_EVERY) {
        enqueueCount = 0
        icmDrainDetached(cwd)
      }
    } catch (err) {
      console.warn("[icm] unexpected error in tool_execution_end handler", err)
    }
  })

  pi.on("session_compact", async (event, ctx) => {
    try {
      const cwd = ctx.cwd
      const summary = (event as any)?.compactionEntry?.summary ?? ""
      if (summary.length >= 50) icmEnqueue(projectName(cwd), summary, cwd)
      enqueueCount = 0
      icmDrainDetached(cwd)
    } catch (err) {
      console.warn("[icm] unexpected error in session_compact handler", err)
    }
  })

  pi.on("session_shutdown", async (_event, ctx) => {
    try {
      const cwd = ctx.cwd
      const text = assistantText(ctx.sessionManager.getEntries())
      if (text.length >= 50) icmEnqueue(projectName(cwd), text, cwd)
      enqueueCount = 0
      icmDrainDetached(cwd)
    } catch (err) {
      console.warn("[icm] unexpected error in session_shutdown handler", err)
    }
  })
}
