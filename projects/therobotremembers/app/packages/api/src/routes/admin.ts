import { Hono } from "hono";
import type { AppEnv } from "../server.js";

export const adminRoutes = new Hono<AppEnv>();

// GET /api/v1/admin/metrics — Basic system metrics
adminRoutes.get("/metrics", async (c) => {
  const postgres = c.get("postgres");

  const activeMemories = await postgres.getActiveMemories(undefined, 1);

  return c.json({
    timestamp: new Date().toISOString(),
    phase: 0,
    note: "Phase 0 — foundation metrics only",
  });
});
