import { describe, test, expect, afterAll } from "vitest";
import { Hono } from "hono";
import { mkdtempSync, rmSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { StorageService } from "../../services/storage.ts";
import { createConfigRoutes } from "../../routes/config.ts";

const tempDir = mkdtempSync(join(tmpdir(), "claude-assist-test-"));
process.env.CLAUDE_ASSIST_DATA_DIR = tempDir;
const storage = new StorageService(join(tempDir, "test.db"));

const noopLlm = { reconfigure: async () => {} } as any;

const app = new Hono();

afterAll(() => {
  rmSync(tempDir, { recursive: true, force: true });
});

describe("config routes", () => {
  test("setup", async () => {
    await storage.initialize();
    const routes = createConfigRoutes(storage, noopLlm);
    app.route("/api/config", routes);
  });

  describe("GET /api/config", () => {
    test("returns 200 with data containing indexPaths, embedding, server", async () => {
      const res = await app.request("/api/config");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.data).toBeDefined();
      expect(body.data.indexPaths).toBeInstanceOf(Array);
      expect(body.data.embedding).toBeDefined();
      expect(body.data.embedding.provider).toBe("local");
      expect(body.data.server).toBeDefined();
      expect(body.data.server.port).toBe(3100);
    });
  });

  describe("PATCH /api/config", () => {
    test("returns 200 with updated config", async () => {
      const res = await app.request("/api/config", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ embedding: { provider: "openai" } }),
      });
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.data.embedding.provider).toBe("openai");
    });
  });
});
