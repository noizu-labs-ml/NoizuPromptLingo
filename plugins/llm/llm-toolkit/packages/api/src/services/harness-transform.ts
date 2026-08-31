import type {
  AgentHarness,
  UniversalContentBlock,
  UniversalMessage,
  UniversalRole,
  UniversalThread,
} from "@llm-toolkit/shared";

export type HarnessTransformDirection = "harness->universal" | "universal->harness";
export type UniversalExportHarness = Extract<AgentHarness, "claude" | "codex">;

export interface UniversalExportInput {
  targetHarness: UniversalExportHarness;
  messages?: UniversalMessage[];
  thread?: Pick<UniversalThread, "id" | "title" | "messages" | "providerMetadata">;
  sessionId?: string;
}

export interface UnsupportedBlockNotice {
  messageId: string;
  blockIndex: number;
  role: UniversalRole;
  blockType: UniversalContentBlock["type"];
  providerType?: string;
  providerHints?: Record<string, unknown>;
}

export interface ClaudeExportPayload {
  targetHarness: "claude";
  direction: "universal->harness";
  system?: string;
  messages: ClaudeExportMessage[];
  unsupportedBlocks: UnsupportedBlockNotice[];
}

export interface ClaudeExportMessage {
  role: "user" | "assistant";
  content: ClaudeExportBlock[];
}

export type ClaudeExportBlock =
  | { type: "text"; text: string }
  | { type: "thinking"; thinking: string; signature?: string }
  | { type: "redacted_thinking"; data?: string }
  | { type: "tool_use"; id: string; name: string; input: Record<string, unknown> }
  | { type: "tool_result"; tool_use_id: string; content: string; is_error?: boolean }
  | { type: "image"; source: { type: "base64"; media_type: string; data: string } };

export interface CodexExportPayload {
  targetHarness: "codex";
  direction: "universal->harness";
  sessionId?: string;
  messages: CodexExportMessage[];
  events: CodexJsonlEvent[];
  jsonl: string;
  unsupportedBlocks: UnsupportedBlockNotice[];
}

export interface CodexExportMessage {
  type: "message";
  role: UniversalRole;
  content: CodexExportBlock[];
}

export type CodexExportBlock =
  | { type: "input_text" | "output_text" | "text"; text: string; [key: string]: unknown }
  | { type: "tool_call"; id: string; name: string; input: Record<string, unknown> }
  | { type: "tool_result"; tool_call_id: string; content: string; is_error?: boolean }
  | { type: "unknown"; text: string; raw: unknown; provider_type?: string; provider_hints?: Record<string, unknown> };

export interface CodexJsonlEvent {
  timestamp: string;
  type: "session_meta" | "response_item";
  payload: Record<string, unknown>;
}

export type HarnessExportPayload = ClaudeExportPayload | CodexExportPayload;

export interface HarnessImportInput {
  sourceHarness: AgentHarness;
  raw: unknown;
}

// ⟦𓀁𓂑𓋗𓌪⟧ exportUniversalToHarness :: auto-generated pointer for public function exportUniversalToHarness
export function exportUniversalToHarness(input: UniversalExportInput): HarnessExportPayload {
  switch (input.targetHarness) {
    case "claude":
      return exportUniversalToClaude(input.thread?.messages ?? input.messages ?? []);
    case "codex":
      return exportUniversalToCodex(input.thread?.messages ?? input.messages ?? [], {
        sessionId: input.sessionId ?? stringFromRecord(input.thread?.providerMetadata, "sessionId"),
      });
  }
}

// ⟦𓁌𓋪𓃣𓉬⟧ exportUniversalToClaude :: auto-generated pointer for public function exportUniversalToClaude
export function exportUniversalToClaude(messages: UniversalMessage[]): ClaudeExportPayload {
  const unsupportedBlocks: UnsupportedBlockNotice[] = [];
  const systemParts: string[] = [];
  const claudeMessages: ClaudeExportMessage[] = [];

  for (const message of messages) {
    const content = message.content.flatMap((block, blockIndex) => {
      const converted = universalBlockToClaude(block, message, blockIndex, unsupportedBlocks);
      return converted ? [converted] : [];
    });

    if (message.role === "system" || message.role === "developer") {
      const systemText = blocksToPlainText(message.content);
      if (systemText) systemParts.push(systemText);
      continue;
    }

    if (content.length === 0) continue;
    claudeMessages.push({
      role: message.role === "assistant" ? "assistant" : "user",
      content,
    });
  }

  return {
    targetHarness: "claude",
    direction: "universal->harness",
    system: systemParts.length > 0 ? systemParts.join("\n\n") : undefined,
    messages: claudeMessages,
    unsupportedBlocks,
  };
}

// ⟦𓏮𓉽𓃁𓆍⟧ exportUniversalToCodex :: auto-generated pointer for public function exportUniversalToCodex
export function exportUniversalToCodex(
  messages: UniversalMessage[],
  options: { sessionId?: string } = {},
): CodexExportPayload {
  const unsupportedBlocks: UnsupportedBlockNotice[] = [];
  const codexMessages = messages.map((message) => ({
    type: "message" as const,
    role: message.role,
    content: message.content.flatMap((block, blockIndex) => {
      const converted = universalBlockToCodex(block, message, blockIndex, unsupportedBlocks);
      return converted ? [converted] : [];
    }),
  }));

  const events: CodexJsonlEvent[] = [];
  if (options.sessionId) {
    events.push({
      timestamp: messages[0]?.timestamp ?? new Date(0).toISOString(),
      type: "session_meta",
      payload: { id: options.sessionId },
    });
  }

  for (let i = 0; i < messages.length; i++) {
    events.push({
      timestamp: messages[i].timestamp,
      type: "response_item",
      payload: codexMessages[i],
    });
  }

  return {
    targetHarness: "codex",
    direction: "universal->harness",
    sessionId: options.sessionId,
    messages: codexMessages,
    events,
    jsonl: events.map((event) => JSON.stringify(event)).join("\n"),
    unsupportedBlocks,
  };
}

// ⟦𓀭𓏫𓎃𓄌⟧ importHarnessToUniversal :: auto-generated pointer for public function importHarnessToUniversal
export function importHarnessToUniversal(input: HarnessImportInput): UniversalMessage[] {
  if (Array.isArray(input.raw) && looksLikeUniversalMessages(input.raw)) {
    return input.raw;
  }

  throw new Error(
    `Harness import for ${input.sourceHarness} should use the indexed normalizer path before calling export transforms.`,
  );
}

// ⟦𓂾𓉕𓉡𓋥⟧ isHarnessExportSupported :: auto-generated pointer for public function isHarnessExportSupported
export function isHarnessExportSupported(harness: AgentHarness): harness is UniversalExportHarness {
  return harness === "claude" || harness === "codex";
}

function universalBlockToClaude(
  block: UniversalContentBlock,
  message: UniversalMessage,
  blockIndex: number,
  unsupportedBlocks: UnsupportedBlockNotice[],
): ClaudeExportBlock | null {
  switch (block.type) {
    case "text":
      return { type: "text", text: block.text };
    case "thinking":
      return {
        type: "thinking",
        thinking: block.thinking,
        signature: block.signature,
      };
    case "redacted_thinking":
      return { type: "redacted_thinking", data: block.data };
    case "tool_use":
      return {
        type: "tool_use",
        id: block.toolCallId,
        name: block.name,
        input: block.input,
      };
    case "tool_result":
      return {
        type: "tool_result",
        tool_use_id: block.toolCallId,
        content: typeof block.content === "string" ? block.content : blocksToPlainText(block.content),
        is_error: block.isError,
      };
    case "image":
      if (block.data) {
        return {
          type: "image",
          source: {
            type: "base64",
            media_type: block.mediaType ?? "image/png",
            data: block.data,
          },
        };
      }
      return unsupportedClaudePlaceholder(block, message, blockIndex, unsupportedBlocks);
    case "audio":
    case "document":
    case "unknown":
      return unsupportedClaudePlaceholder(block, message, blockIndex, unsupportedBlocks);
  }
}

function universalBlockToCodex(
  block: UniversalContentBlock,
  message: UniversalMessage,
  blockIndex: number,
  unsupportedBlocks: UnsupportedBlockNotice[],
): CodexExportBlock | null {
  switch (block.type) {
    case "text":
      return { type: message.role === "assistant" ? "output_text" : "input_text", text: block.text };
    case "thinking":
      return {
        type: "text",
        text: block.thinking,
        provider_type: block.providerType ?? "thinking",
        provider_hints: withoutUndefined({ signature: block.signature, ...block.providerHints }),
      };
    case "redacted_thinking":
      return {
        type: "unknown",
        text: placeholderText(block),
        raw: { type: "redacted_thinking", data: block.data },
        provider_type: block.providerType ?? "redacted_thinking",
        provider_hints: block.providerHints,
      };
    case "tool_use":
      return {
        type: "tool_call",
        id: block.toolCallId,
        name: block.name,
        input: block.input,
      };
    case "tool_result":
      return {
        type: "tool_result",
        tool_call_id: block.toolCallId,
        content: typeof block.content === "string" ? block.content : blocksToPlainText(block.content),
        is_error: block.isError,
      };
    case "image":
    case "audio":
    case "document":
    case "unknown":
      unsupportedBlocks.push(noticeFor(block, message, blockIndex));
      return {
        type: "unknown",
        text: placeholderText(block),
        raw: block.type === "unknown" ? block.raw : block,
        provider_type: block.providerType,
        provider_hints: block.providerHints,
      };
  }
}

function unsupportedClaudePlaceholder(
  block: UniversalContentBlock,
  message: UniversalMessage,
  blockIndex: number,
  unsupportedBlocks: UnsupportedBlockNotice[],
): ClaudeExportBlock {
  unsupportedBlocks.push(noticeFor(block, message, blockIndex));
  return { type: "text", text: placeholderText(block) };
}

function noticeFor(block: UniversalContentBlock, message: UniversalMessage, blockIndex: number): UnsupportedBlockNotice {
  return {
    messageId: message.id,
    blockIndex,
    role: message.role,
    blockType: block.type,
    providerType: block.providerType,
    providerHints: block.providerHints,
  };
}

function blocksToPlainText(blocks: UniversalContentBlock[]): string {
  return blocks
    .map((block) => {
      switch (block.type) {
        case "text":
          return block.text;
        case "thinking":
          return block.thinking;
        case "redacted_thinking":
          return "[redacted thinking]";
        case "tool_use":
          return `[tool use: ${block.name} ${safeJson(block.input)}]`;
        case "tool_result":
          return typeof block.content === "string" ? block.content : blocksToPlainText(block.content);
        case "image":
          return block.source ? `[image: ${block.source}]` : "[image]";
        case "audio":
          return block.transcript ?? (block.source ? `[audio: ${block.source}]` : "[audio]");
        case "document":
          return block.text ?? (block.source ? `[document: ${block.source}]` : "[document]");
        case "unknown":
          return placeholderText(block);
      }
    })
    .filter(Boolean)
    .join("\n");
}

function placeholderText(block: UniversalContentBlock): string {
  const provider = block.providerType ? ` provider=${block.providerType}` : "";
  return `[Unsupported universal block: ${block.type}${provider}]`;
}

function looksLikeUniversalMessages(value: unknown[]): value is UniversalMessage[] {
  return value.every((item) => {
    if (!item || typeof item !== "object") return false;
    const record = item as Record<string, unknown>;
    return typeof record.id === "string" && typeof record.role === "string" && Array.isArray(record.content);
  });
}

function safeJson(value: unknown): string {
  try {
    return JSON.stringify(value);
  } catch {
    return "[unserializable]";
  }
}

function withoutUndefined<T extends Record<string, unknown>>(value: T): T {
  return Object.fromEntries(Object.entries(value).filter(([, entry]) => entry !== undefined)) as T;
}

function stringFromRecord(record: Record<string, unknown> | undefined, key: string): string | undefined {
  const value = record?.[key];
  return typeof value === "string" ? value : undefined;
}
