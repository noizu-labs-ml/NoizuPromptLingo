import { describe, test, expect } from "vitest";
import { Hono } from "hono";
import { conversationRoutes } from "../../routes/conversations.ts";

const app = new Hono();
app.route("/api/conversations", conversationRoutes);

describe("conversation routes", () => {
  describe("GET /api/conversations", () => {
    test("returns 200 with empty data and meta", async () => {
      const res = await app.request("/api/conversations");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body).toEqual({ data: [], meta: { total: 0, limit: 20 } });
    });

    test("accepts sort and limit query params", async () => {
      const res = await app.request(
        "/api/conversations?sort=updated_at&limit=10",
      );
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.meta.limit).toBe(10);
    });
  });

  describe("GET /api/conversations/:id", () => {
    test("returns 501 not implemented", async () => {
      const res = await app.request("/api/conversations/abc123");
      expect(res.status).toBe(501);
    });
  });

  describe("GET /api/conversations/:id/messages", () => {
    test("returns 200 with empty data", async () => {
      const res = await app.request("/api/conversations/abc123/messages");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body).toEqual({ data: [], meta: { total: 0 } });
    });
  });

  describe("GET /api/conversations/:id/edits", () => {
    test("returns 200 with empty data", async () => {
      const res = await app.request("/api/conversations/abc123/edits");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body).toEqual({ data: [] });
    });
  });

  describe("POST /api/conversations/:id/edits", () => {
    test("returns 501 not implemented", async () => {
      const res = await app.request("/api/conversations/abc123/edits", {
        method: "POST",
      });
      expect(res.status).toBe(501);
    });
  });

  describe("POST /api/conversations/bulk", () => {
    test("returns 501 not implemented", async () => {
      const res = await app.request("/api/conversations/bulk", {
        method: "POST",
      });
      expect(res.status).toBe(501);
    });
  });
});
