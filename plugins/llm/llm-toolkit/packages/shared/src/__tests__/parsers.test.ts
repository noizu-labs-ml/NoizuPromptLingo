import { describe, test, expect } from "vitest";
import {
  parseJsonlLine,
  parseJsonlFile,
  isUserMessage,
  isAssistantMessage,
  extractTextContent,
} from "../parsers/index.ts";
import type { UserMessage, AssistantMessage, BaseRecord } from "../types/index.ts";

// -- Fixtures --

const baseFields = {
  uuid: "abc-123",
  parentUuid: null,
  timestamp: "2026-05-11T10:00:00Z",
  sessionId: "sess-001",
};

const userMessageFixture: UserMessage = {
  ...baseFields,
  type: "user",
  message: {
    role: "user",
    content: "Hello, can you help me with a task?",
  },
  cwd: "/home/user/project",
};

const userMessageWithBlocks: UserMessage = {
  ...baseFields,
  uuid: "abc-456",
  type: "user",
  message: {
    role: "user",
    content: [
      { type: "text", text: "First paragraph." },
      { type: "tool_result", tool_use_id: "tool-1", content: "result data" },
      { type: "text", text: "Second paragraph." },
    ],
  },
};

const userMessageNoTextBlocks: UserMessage = {
  ...baseFields,
  uuid: "abc-789",
  type: "user",
  message: {
    role: "user",
    content: [
      { type: "tool_result", tool_use_id: "tool-2", content: "only tool results here" },
    ],
  },
};

const assistantMessageFixture: AssistantMessage = {
  ...baseFields,
  uuid: "def-123",
  type: "assistant",
  message: {
    model: "claude-opus-4-6",
    role: "assistant",
    content: [
      { type: "thinking", thinking: "Let me consider this..." },
      { type: "text", text: "Here is my response." },
      {
        type: "tool_use",
        id: "tool-call-1",
        name: "Read",
        input: { file_path: "/tmp/test.ts" },
      },
    ],
    stop_reason: "end_turn",
    usage: {
      input_tokens: 100,
      output_tokens: 50,
      cache_read_input_tokens: 80,
    },
  },
};

// -- Tests --

describe("parseJsonlLine", () => {
  test("parses a valid JSON line into a BaseRecord", () => {
    const line = JSON.stringify(userMessageFixture);
    const result = parseJsonlLine(line);
    expect(isUserMessage(result)).toBe(true);
    if (!isUserMessage(result)) throw new Error("expected user message");
    expect(result.uuid).toBe("abc-123");
    expect(result.type).toBe("user");
    expect(result.sessionId).toBe("sess-001");
  });

  test("throws on invalid JSON", () => {
    expect(() => parseJsonlLine("{not valid json")).toThrow();
  });
});

describe("parseJsonlFile", () => {
  test("yields multiple records from multiline JSONL string", () => {
    const content = [
      JSON.stringify(userMessageFixture),
      JSON.stringify(assistantMessageFixture),
    ].join("\n");

    const records = [...parseJsonlFile(content)];
    expect(records).toHaveLength(2);
    expect(records[0].type).toBe("user");
    expect(records[1].type).toBe("assistant");
  });

  test("skips blank lines", () => {
    const content = [
      JSON.stringify(userMessageFixture),
      "",
      "   ",
      JSON.stringify(assistantMessageFixture),
      "",
    ].join("\n");

    const records = [...parseJsonlFile(content)];
    expect(records).toHaveLength(2);
  });
});

describe("isUserMessage", () => {
  test('returns true for type "user"', () => {
    const record = parseJsonlLine(JSON.stringify(userMessageFixture));
    expect(isUserMessage(record)).toBe(true);
  });

  test('returns false for type "assistant"', () => {
    const record = parseJsonlLine(JSON.stringify(assistantMessageFixture));
    expect(isUserMessage(record)).toBe(false);
  });
});

describe("isAssistantMessage", () => {
  test('returns true for type "assistant"', () => {
    const record = parseJsonlLine(JSON.stringify(assistantMessageFixture));
    expect(isAssistantMessage(record)).toBe(true);
  });

  test('returns false for type "user"', () => {
    const record = parseJsonlLine(JSON.stringify(userMessageFixture));
    expect(isAssistantMessage(record)).toBe(false);
  });
});

describe("extractTextContent", () => {
  test("extracts text from a string content UserMessage", () => {
    const text = extractTextContent(userMessageFixture);
    expect(text).toBe("Hello, can you help me with a task?");
  });

  test("extracts text from ContentBlock array, ignoring non-text blocks", () => {
    const text = extractTextContent(userMessageWithBlocks);
    expect(text).toBe("First paragraph.\nSecond paragraph.");
  });

  test("returns empty string when no text blocks exist", () => {
    const text = extractTextContent(userMessageNoTextBlocks);
    expect(text).toBe("");
  });

  test("extracts text from AssistantMessage content blocks", () => {
    const text = extractTextContent(assistantMessageFixture);
    expect(text).toBe("Here is my response.");
  });
});
