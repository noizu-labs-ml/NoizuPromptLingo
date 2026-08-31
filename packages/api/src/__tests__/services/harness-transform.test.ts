import { describe, expect, test } from "vitest";
import type { UniversalMessage } from "@llm-toolkit/shared";
import {
  exportUniversalToClaude,
  exportUniversalToCodex,
  exportUniversalToHarness,
  importHarnessToUniversal,
  isHarnessExportSupported,
} from "../../services/harness-transform.ts";

describe("harness transforms", () => {
  const messages: UniversalMessage[] = [
    {
      id: "system-1",
      role: "system",
      timestamp: "2026-06-01T00:00:00.000Z",
      content: [{ type: "text", text: "Stay concise." }],
    },
    {
      id: "user-1",
      role: "user",
      timestamp: "2026-06-01T00:00:01.000Z",
      content: [{ type: "text", text: "Read the file." }],
    },
    {
      id: "assistant-1",
      role: "assistant",
      timestamp: "2026-06-01T00:00:02.000Z",
      content: [
        {
          type: "tool_use",
          toolCallId: "toolu-1",
          name: "Read",
          input: { file_path: "/tmp/example.md" },
          providerType: "tool_use",
        },
        {
          type: "unknown",
          raw: { type: "vendor_special", payload: { opaque: true } },
          providerType: "vendor_special",
          providerHints: { harness: "future-agent" },
        },
      ],
    },
    {
      id: "tool-1",
      role: "tool",
      timestamp: "2026-06-01T00:00:03.000Z",
      content: [
        {
          type: "tool_result",
          toolCallId: "toolu-1",
          content: "file contents",
          isError: false,
          providerType: "tool_result",
        },
      ],
    },
  ];

  test("exports text/tool_use/tool_result-ish blocks to Claude-compatible messages", () => {
    const payload = exportUniversalToClaude(messages);

    expect(payload.direction).toBe("universal->harness");
    expect(payload.targetHarness).toBe("claude");
    expect(payload.system).toBe("Stay concise.");
    expect(payload.messages).toEqual([
      {
        role: "user",
        content: [{ type: "text", text: "Read the file." }],
      },
      {
        role: "assistant",
        content: [
          {
            type: "tool_use",
            id: "toolu-1",
            name: "Read",
            input: { file_path: "/tmp/example.md" },
          },
          { type: "text", text: "[Unsupported universal block: unknown provider=vendor_special]" },
        ],
      },
      {
        role: "user",
        content: [
          {
            type: "tool_result",
            tool_use_id: "toolu-1",
            content: "file contents",
            is_error: false,
          },
        ],
      },
    ]);
    expect(payload.unsupportedBlocks).toEqual([
      {
        messageId: "assistant-1",
        blockIndex: 1,
        role: "assistant",
        blockType: "unknown",
        providerType: "vendor_special",
        providerHints: { harness: "future-agent" },
      },
    ]);
  });

  test("exports a Codex JSONL/message-compatible continuation payload", () => {
    const payload = exportUniversalToCodex(messages, { sessionId: "codex-transfer-1" });

    expect(payload.direction).toBe("universal->harness");
    expect(payload.targetHarness).toBe("codex");
    expect(payload.messages[1]).toEqual({
      type: "message",
      role: "user",
      content: [{ type: "input_text", text: "Read the file." }],
    });
    expect(payload.messages[2].content[0]).toEqual({
      type: "tool_call",
      id: "toolu-1",
      name: "Read",
      input: { file_path: "/tmp/example.md" },
    });
    expect(payload.events[0]).toEqual({
      timestamp: "2026-06-01T00:00:00.000Z",
      type: "session_meta",
      payload: { id: "codex-transfer-1" },
    });

    const lines = payload.jsonl.split("\n").map((line) => JSON.parse(line) as Record<string, unknown>);
    expect(lines).toHaveLength(5);
    expect(lines[1]).toMatchObject({
      timestamp: "2026-06-01T00:00:00.000Z",
      type: "response_item",
      payload: { type: "message", role: "system" },
    });
  });

  test("keeps unknown blocks as placeholders/provider hints instead of dropping them", () => {
    const payload = exportUniversalToCodex(messages);
    const unknownBlock = payload.messages[2].content[1];

    expect(unknownBlock).toEqual({
      type: "unknown",
      text: "[Unsupported universal block: unknown provider=vendor_special]",
      raw: { type: "vendor_special", payload: { opaque: true } },
      provider_type: "vendor_special",
      provider_hints: { harness: "future-agent" },
    });
    expect(payload.unsupportedBlocks).toHaveLength(1);
  });

  test("routes through the generic harness export API", () => {
    const payload = exportUniversalToHarness({ targetHarness: "claude", messages });

    expect(payload.targetHarness).toBe("claude");
    expect(isHarnessExportSupported("claude")).toBe(true);
    expect(isHarnessExportSupported("gemini")).toBe(false);
  });

  test("makes harness import direction explicit without duplicating indexer parsing", () => {
    expect(importHarnessToUniversal({ sourceHarness: "codex", raw: messages })).toBe(messages);
    expect(() => importHarnessToUniversal({ sourceHarness: "codex", raw: { type: "response_item" } }))
      .toThrow("should use the indexed normalizer path");
  });
});
