import { describe, test, expect, beforeEach, afterEach } from "vitest";
import { mkdtempSync, rmSync, writeFileSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { StorageService } from "../../services/storage.ts";
import { OperationsService } from "../../services/operations.ts";

describe("OperationsService", () => {
  let tempDir: string;
  let storage: StorageService;
  let ops: OperationsService;

  beforeEach(async () => {
    tempDir = mkdtempSync(join(tmpdir(), "llm-toolkit-ops-"));
    storage = new StorageService(":memory:");
    await storage.initialize();
    ops = new OperationsService(storage);
  });

  afterEach(() => {
    storage.close();
    rmSync(tempDir, { recursive: true, force: true });
  });

  test("saveEdit patches existing records without dropping provider metadata", async () => {
    const sourcePath = join(tempDir, "session.jsonl");
    const records = [
      { type: "permission-mode", permissionMode: "acceptEdits", sessionId: "session" },
      {
        parentUuid: null,
        isSidechain: false,
        promptId: "prompt-1",
        type: "user",
        message: { role: "user", content: "original user" },
        uuid: "user-uuid",
        timestamp: "2026-06-26T10:00:00.000Z",
        permissionMode: "auto",
        cwd: "/repo",
        version: "2.1.193",
        gitBranch: "feature",
        sessionId: "session",
      },
      {
        parentUuid: "user-uuid",
        isSidechain: false,
        type: "assistant",
        message: {
          role: "assistant",
          model: "claude-sonnet",
          content: [{ type: "text", text: "original assistant" }],
          stop_reason: "end_turn",
          usage: { input_tokens: 12, output_tokens: 34 },
        },
        uuid: "assistant-uuid",
        timestamp: "2026-06-26T10:00:01.000Z",
        requestId: "req-1",
        sessionId: "session",
      },
    ];
    writeFileSync(sourcePath, records.map((record) => JSON.stringify(record)).join("\n") + "\n");

    await storage.upsertConversation({
      id: "conv",
      harness: "claude",
      projectPath: "/repo",
      startedAt: "2026-06-26T10:00:00.000Z",
      updatedAt: "2026-06-26T10:00:01.000Z",
      messageCount: 2,
      title: "Test",
      sourcePath,
    });

    await ops.saveEdit("conv", [
      { originalIndex: 0, role: "user", content: "edited user" },
      { originalIndex: 1, role: "assistant", content: "edited assistant" },
    ], "overwrite", "Edited title");

    const saved = readJsonl(sourcePath);
    const user = saved.find((record) => record.uuid === "user-uuid")!;
    const assistant = saved.find((record) => record.uuid === "assistant-uuid")!;

    expect(user.promptId).toBe("prompt-1");
    expect(user.cwd).toBe("/repo");
    expect(user.version).toBe("2.1.193");
    expect((user.message as Record<string, unknown>).content).toBe("edited user");
    expect((assistant.message as Record<string, unknown>).model).toBe("claude-sonnet");
    expect((assistant.message as Record<string, unknown>).usage).toEqual({ input_tokens: 12, output_tokens: 34 });
    expect(assistant.requestId).toBe("req-1");
    expect(((assistant.message as Record<string, unknown>).content as Array<Record<string, unknown>>)[0].text).toBe("edited assistant");
  });

  test("saveEdit uses rawEdited records exactly for raw JSON edits", async () => {
    const sourcePath = join(tempDir, "session.jsonl");
    writeFileSync(sourcePath, [
      JSON.stringify({ type: "permission-mode", permissionMode: "default", sessionId: "session" }),
      JSON.stringify({ type: "user", message: { role: "user", content: "original" }, uuid: "u1", timestamp: "2026-06-26T10:00:00.000Z", sessionId: "session" }),
    ].join("\n") + "\n");

    await storage.upsertConversation({
      id: "conv",
      harness: "claude",
      projectPath: "/repo",
      startedAt: "2026-06-26T10:00:00.000Z",
      updatedAt: "2026-06-26T10:00:00.000Z",
      messageCount: 1,
      title: "Test",
      sourcePath,
    });

    const rawRecord = {
      type: "user",
      message: { role: "user", content: "raw edited" },
      uuid: "u1",
      timestamp: "2026-06-26T10:00:00.000Z",
      sessionId: "session",
      providerSpecific: { preserved: true },
    };

    await ops.saveEdit("conv", [
      { originalIndex: 0, role: "user", content: "raw edited", rawEdited: true, rawRecord },
    ], "overwrite");

    const saved = readJsonl(sourcePath);
    expect(saved[1]).toEqual(rawRecord);
  });
});

function readJsonl(path: string): Array<Record<string, unknown>> {
  return readFileSync(path, "utf-8")
    .split("\n")
    .filter((line) => line.trim())
    .map((line) => JSON.parse(line) as Record<string, unknown>);
}
