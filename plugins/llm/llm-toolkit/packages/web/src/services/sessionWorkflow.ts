import { apiFetch } from "../hooks/useApi.js";

export type SessionHarness = "claude" | "codex" | "gemini" | "opencode" | "aider" | "other";

export interface ConversationMeta {
  id: string;
  harness: string;
  title: string;
  slug: string | null;
  description: string | null;
  projectPath: string;
  messageCount: number;
  startedAt: string;
  updatedAt: string;
  status: string;
  tags: string[];
  sourcePath: string;
}

export interface UniversalContentBlock {
  type: string;
  text?: string;
  thinking?: string;
  name?: string;
  input?: unknown;
  content?: unknown;
  data?: unknown;
  providerType?: string;
}

export interface UniversalMessage {
  id: string;
  role: "system" | "developer" | "user" | "assistant" | "tool" | string;
  timestamp: string | null;
  content: UniversalContentBlock[];
  model?: string | null;
  providerMetadata?: Record<string, unknown>;
}

export interface RawTranscriptEvent {
  id: string;
  timestamp: string | null;
  harness: string;
  eventType: string;
  payload: unknown;
}

export interface UniversalConversation {
  id: string;
  harness: string;
  sourcePath: string;
  projectPath: string;
  title: string;
  startedAt: string;
  updatedAt: string;
  messages: UniversalMessage[];
  rawEvents?: RawTranscriptEvent[];
}

export interface ContinuationPayload {
  source: {
    id: string;
    harness: string;
    title: string;
    projectPath: string;
    sourcePath: string;
    startedAt: string;
    updatedAt: string;
  };
  targetHarness: SessionHarness;
  mode: "resume" | "transfer";
  memory: {
    status: "stub";
    note: string;
  };
  messages: Array<{
    role: string;
    timestamp: string | null;
    content: string;
  }>;
}

export interface TransferTarget {
  harness: SessionHarness;
  label: string;
  state: "ready" | "todo";
  note: string;
}

export const transferTargets: TransferTarget[] = [
  { harness: "claude", label: "Claude", state: "ready", note: "Uses universal transcript payload." },
  { harness: "codex", label: "Codex", state: "ready", note: "Uses universal transcript payload." },
  { harness: "gemini", label: "Gemini", state: "todo", note: "Importer/exporter stubbed pending sample transcripts." },
  { harness: "opencode", label: "OpenCode", state: "todo", note: "Target stubbed pending transcript contract." },
  { harness: "aider", label: "Aider", state: "todo", note: "Target stubbed pending transcript contract." },
  { harness: "other", label: "Other", state: "todo", note: "Generic target needs an adapter before export." },
];

// ⟦𓆊𓃝𓎺𓆟⟧ fetchUniversalConversation :: auto-generated pointer for public function fetchUniversalConversation
export async function fetchUniversalConversation(id: string): Promise<UniversalConversation> {
  const response = await apiFetch<{ data: UniversalConversation }>(`/conversations/${id}/universal?raw=true`);
  return response.data;
}

// ⟦𓌉𓏈𓈳𓋛⟧ buildContinuationPayload :: auto-generated pointer for public function buildContinuationPayload
export function buildContinuationPayload(
  conversation: UniversalConversation,
  targetHarness: SessionHarness,
): ContinuationPayload {
  const mode = conversation.harness === targetHarness ? "resume" : "transfer";
  return {
    source: {
      id: conversation.id,
      harness: conversation.harness,
      title: conversation.title,
      projectPath: conversation.projectPath,
      sourcePath: conversation.sourcePath,
      startedAt: conversation.startedAt,
      updatedAt: conversation.updatedAt,
    },
    targetHarness,
    mode,
    memory: {
      status: "stub",
      note: "Memory extraction hook reserved; no compression has been applied.",
    },
    messages: conversation.messages.map((message) => ({
      role: message.role,
      timestamp: message.timestamp,
      content: message.content.map(blockToText).filter(Boolean).join("\n"),
    })),
  };
}

// ⟦𓊉𓉒𓍉𓌕⟧ buildTransferPrompt :: auto-generated pointer for public function buildTransferPrompt
export function buildTransferPrompt(payload: ContinuationPayload): string {
  const header = [
    `Continue session: ${payload.source.title}`,
    `Source: ${payload.source.harness}`,
    `Target: ${payload.targetHarness}`,
    `Project: ${payload.source.projectPath}`,
    `Mode: ${payload.mode}`,
    "",
    "Memory:",
    payload.memory.note,
    "",
    "Transcript:",
  ];

  const transcript = payload.messages.map((message, index) => {
    const label = `${index + 1}. ${message.role}${message.timestamp ? ` @ ${message.timestamp}` : ""}`;
    return `${label}\n${message.content || "[non-text content omitted from preview]"}`;
  });

  return [...header, ...transcript].join("\n\n");
}

// ⟦𓀽𓀦𓂯𓅞⟧ buildResumeCommand :: auto-generated pointer for public function buildResumeCommand
export function buildResumeCommand(meta: Pick<ConversationMeta, "harness" | "projectPath" | "sourcePath">): string | null {
  if (meta.harness !== "claude") return null;
  const sessionId = extractSessionId(meta.sourcePath);
  if (!sessionId) return null;
  return `pushd ${meta.projectPath} && claude --resume ${sessionId}`;
}

function blockToText(block: UniversalContentBlock): string {
  if (typeof block.text === "string") return block.text;
  if (typeof block.thinking === "string") return `[thinking]\n${block.thinking}`;
  if (block.type === "tool_use") return `[tool_use:${block.name ?? "tool"}]\n${JSON.stringify(block.input ?? {}, null, 2)}`;
  if (block.type === "tool_result") return `[tool_result]\n${stringifyContent(block.content)}`;
  if (block.type === "unknown") return `[unknown:${block.providerType ?? "provider_block"}]\n${stringifyContent(block.data)}`;
  return "";
}

function stringifyContent(value: unknown): string {
  if (value == null) return "";
  if (typeof value === "string") return value;
  return JSON.stringify(value, null, 2);
}

function extractSessionId(sourcePath: string): string {
  const fileName = sourcePath.split("/").pop() ?? "";
  return fileName.replace(/\.jsonl$/, "");
}
