import type { LLMCall, ToolCall, ToolError } from "../types";
import { hoursAgo, makeRandom, minutesAgo, pick, shortUuid } from "./helpers";

const TOOL_NAMES = [
  "Ping", "ToMarkdown", "Screenshot", "Rest", "Download",
  "NPLSpec", "NPLLoad", "ToolSummary", "ToolSearch",
  "Proj.UserStories.List", "Instructions", "Instructions.Create",
];

const LLM_MODELS = ["groq/openai/gpt-oss-120b", "openai/gpt-4o-mini", "anthropic/claude-3-5-haiku"];
const LLM_PURPOSES = ["intent_search", "image_description", "tool_help", "embedding"];

function generateToolCalls(count: number): ToolCall[] {
  const rng = makeRandom(54321);
  const out: ToolCall[] = [];
  for (let i = 0; i < count; i++) {
    const ok = rng() > 0.08;
    const tool = pick(rng, TOOL_NAMES);
    out.push({
      id: shortUuid(rng, 12),
      tool_name: tool,
      session_id: rng() > 0.3 ? shortUuid(rng) : null,
      args_summary:
        tool === "Ping"
          ? `url=https://example.com/${Math.floor(rng() * 1000)}`
          : tool === "NPLLoad"
            ? `expression=syntax#${pick(rng, ["placeholder", "qualifier", "attention"])}`
            : `args<${Math.floor(rng() * 4)}>`,
      status: ok ? "ok" : "error",
      error_message: ok ? null : pick(rng, ["httpx.ConnectError", "KeyError", "TypeError: missing arg"]),
      response_time_ms: Math.floor(rng() * 2400) + 12,
      created_at: minutesAgo(Math.floor(rng() * 60 * 24 * 3)),
    });
  }
  return out.sort(
    (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
  );
}

function generateLLMCalls(count: number): LLMCall[] {
  const rng = makeRandom(13579);
  const out: LLMCall[] = [];
  for (let i = 0; i < count; i++) {
    out.push({
      id: shortUuid(rng, 12),
      model: pick(rng, LLM_MODELS),
      purpose: pick(rng, LLM_PURPOSES),
      tokens_in: 400 + Math.floor(rng() * 3600),
      tokens_out: 100 + Math.floor(rng() * 900),
      duration_ms: Math.floor(rng() * 5000) + 200,
      created_at: hoursAgo(Math.floor(rng() * 72)),
    });
  }
  return out.sort(
    (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
  );
}

const ERROR_TYPES = ["KeyError", "TypeError", "ConnectionError", "ValueError", "TimeoutError", "AttributeError"];
const ERROR_MESSAGES: Record<string, string[]> = {
  KeyError: ["'session_id'", "'project'", "'uuid'", "'tool_name'"],
  TypeError: ["missing required argument: 'url'", "argument of type 'NoneType' is not iterable", "unsupported operand type"],
  ConnectionError: ["Failed to connect to database", "Connection refused: 127.0.0.1:5432", "SSL handshake failed"],
  ValueError: ["invalid literal for int() with base 10: 'abc'", "argument out of range", "empty sequence"],
  TimeoutError: ["Request timed out after 30s", "DB query exceeded 10s limit"],
  AttributeError: ["'NoneType' object has no attribute 'fetch'", "'dict' object has no attribute 'execute'"],
};

function generateToolErrors(count: number): ToolError[] {
  const rng = makeRandom(98765);
  const out: ToolError[] = [];
  for (let i = 0; i < count; i++) {
    const errorType = pick(rng, ERROR_TYPES);
    const messages = ERROR_MESSAGES[errorType];
    const toolName = pick(rng, TOOL_NAMES);
    out.push({
      id: i + 1,
      tool_name: toolName,
      error_type: errorType,
      error_message: pick(rng, messages),
      session_id: rng() > 0.4 ? shortUuid(rng) : null,
      stack_excerpt:
        rng() > 0.2
          ? `Traceback (most recent call last):\n  File "npl_mcp/${toolName.toLowerCase()}.py", line ${Math.floor(rng() * 200) + 10}, in handle\n    result = await _process(args)\n${errorType}: ${pick(rng, messages)}`
          : null,
      created_at: minutesAgo(Math.floor(rng() * 60 * 24 * 7)),
    });
  }
  return out.sort(
    (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
  );
}

export const TOOL_CALLS: ToolCall[] = generateToolCalls(60);
export const LLM_CALLS: LLMCall[] = generateLLMCalls(25);
export const TOOL_ERRORS: ToolError[] = generateToolErrors(10);
