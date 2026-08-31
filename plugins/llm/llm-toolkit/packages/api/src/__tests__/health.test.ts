import { describe, test, expect } from "vitest";
import { Hono } from "hono";

const app = new Hono();
app.get("/api/health", (c) => c.json({ status: "ok" }));

describe("GET /api/health", () => {
  test("returns 200", async () => {
    const res = await app.request("/api/health");
    expect(res.status).toBe(200);
  });

  test("returns { status: 'ok' }", async () => {
    const res = await app.request("/api/health");
    const body = await res.json();
    expect(body).toEqual({ status: "ok" });
  });
});
