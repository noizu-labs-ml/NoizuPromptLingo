import Database from "better-sqlite3";
import { afterEach, describe, expect, test } from "vitest";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  formatRecentSessions,
  parsePeriod,
  parseRecentArgs,
  queryRecentSessions,
  type RecentSession,
} from "../../commands/recent.ts";

const tempDirs: string[] = [];

afterEach(() => {
  for (const path of tempDirs.splice(0)) rmSync(path, { recursive: true, force: true });
});

describe("recent command", () => {
  test("defaults to the last hour", () => {
    const options = parseRecentArgs([]);
    expect(options.periodMs).toBe(3_600_000);
    expect(options.periodLabel).toBe("1 hour");
    expect(options.limit).toBe(50);
  });

  test("accepts compact, positional, and flag periods", () => {
    expect(parsePeriod("30m").milliseconds).toBe(1_800_000);
    expect(parseRecentArgs(["2", "hours"]).periodMs).toBe(7_200_000);
    expect(parseRecentArgs(["--since", "1d", "--limit", "10", "--json"])).toMatchObject({
      periodMs: 86_400_000,
      limit: 10,
      json: true,
    });
  });

  test("rejects invalid periods and limits", () => {
    expect(() => parseRecentArgs(["soon"])).toThrow("invalid period");
    expect(() => parseRecentArgs(["1h", "--limit", "0"])).toThrow("between 1 and 1000");
  });

  test("queries only sessions updated inside the requested period", () => {
    const dir = mkdtempSync(join(tmpdir(), "llm-toolkit-recent-"));
    tempDirs.push(dir);
    const dbPath = join(dir, "llm-toolkit.db");
    const db = new Database(dbPath);
    db.exec(`
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY, title TEXT, project_path TEXT, harness TEXT, source_path TEXT,
        started_at TEXT, updated_at TEXT, message_count INTEGER
      );
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY, conversation_id TEXT, role TEXT, content TEXT, timestamp TEXT
      );
    `);
    db.prepare("INSERT INTO conversations VALUES (?, ?, ?, ?, ?, ?, ?, ?)").run(
      "recent", "Recent title", "/work/recent", "codex", "/logs/recent.jsonl",
      "2026-07-17T00:30:00.000Z", "2026-07-17T01:00:00.000Z", 2,
    );
    db.prepare("INSERT INTO conversations VALUES (?, ?, ?, ?, ?, ?, ?, ?)").run(
      "old", "Old title", "/work/old", "claude", "/logs/old.jsonl",
      "2026-07-15T00:00:00.000Z", "2026-07-15T01:00:00.000Z", 1,
    );
    db.prepare("INSERT INTO messages VALUES (?, ?, ?, ?, ?)").run(1, "recent", "user", "first message", "2026-07-17T00:30:00.000Z");
    db.prepare("INSERT INTO messages VALUES (?, ?, ?, ?, ?)").run(2, "recent", "assistant", "last message", "2026-07-17T01:00:00.000Z");
    db.close();

    const sessions = queryRecentSessions(dbPath, new Date("2026-07-17T00:00:00.000Z"), 50);
    expect(sessions).toEqual([expect.objectContaining({
      id: "recent",
      title: "Recent title",
      directory: "/work/recent",
      runner: "codex",
      source: "/logs/recent.jsonl",
      firstMessage: "first message",
      lastMessage: "last message",
    })]);
  });

  test("prints all requested session details", () => {
    const session: RecentSession = {
      id: "abc123",
      title: "Fix the runner",
      directory: "/work/project",
      runner: "claude",
      source: "/logs/abc123.jsonl",
      startedAt: "2026-07-17T00:00:00.000Z",
      updatedAt: "2026-07-17T01:00:00.000Z",
      messageCount: 4,
      firstMessage: "Please fix it",
      lastMessage: "Fixed and tested",
    };
    const output = formatRecentSessions([session], parseRecentArgs([]));
    expect(output).toContain("Fix the runner");
    expect(output).toContain("directory: /work/project");
    expect(output).toContain("runner:    claude");
    expect(output).toContain("source:    /logs/abc123.jsonl");
    expect(output).toContain("first:     Please fix it");
    expect(output).toContain("last:      Fixed and tested");
  });
});
