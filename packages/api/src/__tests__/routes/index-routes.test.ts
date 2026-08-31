import { describe, test, expect } from "vitest";
import { Hono } from "hono";
import { indexRoutes } from "../../routes/index-routes.ts";

const app = new Hono();
app.route("/api/index", indexRoutes);

describe("index routes", () => {
  describe("POST /api/index/rebuild", () => {
    test("returns 200 with status started", async () => {
      const res = await app.request("/api/index/rebuild", { method: "POST" });
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.data.status).toBe("started");
    });
  });

  describe("GET /api/index/status", () => {
    test("returns 200 with status idle", async () => {
      const res = await app.request("/api/index/status");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.data.status).toBe("idle");
      expect(body.data.lastIndexed).toBeNull();
      expect(body.data.conversationCount).toBe(0);
    });
  });
});
