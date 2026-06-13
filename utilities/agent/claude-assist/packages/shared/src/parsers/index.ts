import type { BaseRecord, UserMessage, AssistantMessage } from "../types/index.ts";

export interface CustomTitleRecord {
  type: "custom-title";
  customTitle: string;
  sessionId: string;
}

export function parseJsonlLine(line: string): BaseRecord | CustomTitleRecord {
  return JSON.parse(line);
}

export function* parseJsonlFile(content: string): Generator<BaseRecord | CustomTitleRecord> {
  for (const line of content.split("\n")) {
    if (line.trim()) {
      yield parseJsonlLine(line);
    }
  }
}

export function isUserMessage(record: BaseRecord | CustomTitleRecord): record is UserMessage {
  return record.type === "user";
}

export function isAssistantMessage(record: BaseRecord | CustomTitleRecord): record is AssistantMessage {
  return record.type === "assistant";
}

export function isCustomTitle(record: BaseRecord | CustomTitleRecord): record is CustomTitleRecord {
  return record.type === "custom-title";
}

export function extractTextContent(message: UserMessage | AssistantMessage): string {
  const content = message.message.content;
  if (typeof content === "string") return content;
  return content
    .filter((block) => block.type === "text")
    .map((block) => block.text ?? "")
    .join("\n");
}
