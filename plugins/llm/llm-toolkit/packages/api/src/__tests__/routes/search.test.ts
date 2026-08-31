import { describe, test, expect } from "vitest";
import { Hono } from "hono";
import { searchRoutes } from "../../routes/search.ts";

const app = new Hono();
app.route("/api/search", searchRoutes);

describe("search routes", () => {
  describe("GET /api/search", () => {
    test("returns 200 with data array and meta containing query and mode", async () => {
      const res = await app.request("/api/search?q=auth");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.data).toEqual([]);
      expect(body.meta.query).toBe("auth");
      expect(body.meta.mode).toBe("fts");
    });

    test("returns semantic mode when requested", async () => {
      const res = await app.request("/api/search?q=test&mode=semantic");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.meta.mode).toBe("semantic");
    });

    test("returns empty query when no q param provided", async () => {
      const res = await app.request("/api/search");
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.meta.query).toBe("");
    });
  });
});
