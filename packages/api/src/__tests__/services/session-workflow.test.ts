import { describe, expect, test } from "vitest";
import type { UniversalMessage } from "@llm-toolkit/shared";
import { prepareContinuationPayload } from "../../services/session-workflow.ts";

const messages: UniversalMessage[] = [
  {
    id: "m1",
    role: "user",
    timestamp: "2026-06-02T00:00:00Z",
    content: [{ type: "text", text: "Continue this deployment investigation." }],
  },
  {
    id: "m2",
    role: "assistant",
    timestamp: "2026-06-02T00:01:00Z",
    content: [
      { type: "text", text: "I found the failing chart." },
      { type: "tool_use", toolCallId: "tool-1", name: "rg", input: { pattern: "image.tag" } },
    ],
  },
];

describe("session workflow", () => {
  test("prepares same-harness Claude continuation payloads", () => {
    const payload = prepareContinuationPayload({
      sourceHarness: "claude",
      targetHarness: "claude",
      title: "Deploy debug",
      messages,
    });

    expect(payload.intent).toBe("continue");
    expect(payload.readiness).toBe("ready");
    expect(payload.messageCount).toBe(2);
    expect(payload.memoryHooks.sessionSummary.status).toBe("planned");
    expect(payload.harnessPayload).toMatchObject({
      targetHarness: "claude",
      direction: "universal->harness",
    });
  });

  test("prepares cross-harness Codex transfer payloads", () => {
    const payload = prepareContinuationPayload({
      sourceHarness: "claude",
      targetHarness: "codex",
      messages,
    });

    expect(payload.intent).toBe("transfer");
    expect(payload.targetHarness).toBe("codex");
    expect(payload.readiness).toBe("ready");
    expect(payload.harnessPayload).toMatchObject({
      targetHarness: "codex",
      direction: "universal->harness",
      messages: [
        { type: "message", role: "user" },
        { type: "message", role: "assistant" },
      ],
    });
  });

  test("marks transcript-pending harnesses as stubs", () => {
    const payload = prepareContinuationPayload({
      sourceHarness: "codex",
      targetHarness: "opencode",
      messages,
    });

    expect(payload.intent).toBe("transfer");
    expect(payload.readiness).toBe("stub");
    expect(payload.warnings[0]).toContain("opencode export is stubbed");
    expect(payload.harnessPayload).toMatchObject({
      format: "opencode-continuation-stub",
      todo: "Validate real transcript shape before enabling this exporter.",
    });
  });
});
