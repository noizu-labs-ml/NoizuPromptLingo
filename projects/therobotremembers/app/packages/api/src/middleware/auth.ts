import { createMiddleware } from "hono/factory";
import type { AppEnv } from "../server.js";

export const apiKeyAuth = createMiddleware<AppEnv>(async (c, next) => {
  const requiredKey = process.env.TRR_API_KEY;
  if (!requiredKey) {
    await next();
    return;
  }

  if (c.req.path === "/api/v1/health") {
    await next();
    return;
  }

  const header = c.req.header("Authorization");
  if (!header) {
    return c.json({ error: "Missing Authorization header" }, 401);
  }

  const token = header.startsWith("Bearer ") ? header.slice(7) : header;
  if (token !== requiredKey) {
    return c.json({ error: "Invalid API key" }, 403);
  }

  await next();
});
