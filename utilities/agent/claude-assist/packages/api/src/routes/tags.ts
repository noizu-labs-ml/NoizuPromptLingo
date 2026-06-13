import { Hono } from "hono";
import type { StorageService } from "../services/storage.ts";

export function createTagRoutes(storage: StorageService): Hono {
  const routes = new Hono();

  // GET / — returns all tag metadata
  routes.get("/", async (c) => {
    const tags = await storage.getAllTagMeta();
    return c.json({ data: tags });
  });

  // POST / — create/update tag metadata (body: { name, color?, description? })
  routes.post("/", async (c) => {
    const body = await c.req.json<{ name?: string; color?: string; description?: string }>();
    if (!body.name || typeof body.name !== "string") {
      return c.json({ error: "name is required" }, 400);
    }
    await storage.upsertTagMeta({
      name: body.name,
      color: body.color,
      description: body.description,
    });
    const updated = await storage.getTagMeta(body.name);
    return c.json({ data: updated });
  });

  // DELETE /:name — delete tag metadata
  routes.delete("/:name", async (c) => {
    const name = decodeURIComponent(c.req.param("name"));
    await storage.deleteTagMeta(name);
    return c.json({ success: true });
  });

  return routes;
}
