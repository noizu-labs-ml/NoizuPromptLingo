import type { Context } from "hono";

export function errorHandler(err: Error, c: Context): Response {
  console.error(`[ERROR] ${err.message}`, err.stack);

  if (err.message.includes("duplicate key")) {
    return c.json({ error: "Duplicate entry" }, 409);
  }

  return c.json(
    {
      error: "Internal server error",
      message: process.env.NODE_ENV === "development" ? err.message : undefined,
    },
    500
  );
}
