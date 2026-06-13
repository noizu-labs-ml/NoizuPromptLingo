import { Hono } from "hono";
import type { StorageService } from "../services/storage.ts";

export function createPromptRoutes(storage: StorageService): Hono {
  const routes = new Hono();

  routes.get("/", async (c) => {
    const prompts = await storage.getPrompts();
    return c.json({ data: prompts });
  });

  routes.post("/", async (c) => {
    const body = await c.req.json() as {
      title: string;
      content: string;
      role: string;
      tags?: string[];
      sourceConversationId?: string;
      sourceMessageIndex?: number;
    };
    if (!body.title || !body.content || !body.role) {
      return c.json({ data: null, error: "title, content, and role are required" }, 400);
    }
    const prompt = await storage.createPrompt(body);
    return c.json({ data: prompt }, 201);
  });

  routes.get("/:id", async (c) => {
    const id = c.req.param("id");
    const prompt = await storage.getPrompt(id);
    if (!prompt) return c.json({ error: "not found" }, 404);
    return c.json({ data: prompt });
  });

  routes.patch("/:id", async (c) => {
    const id = c.req.param("id");
    const body = await c.req.json() as { title?: string; content?: string; tags?: string[]; evals?: Record<string, unknown> | null };
    await storage.updatePrompt(id, body);
    const updated = await storage.getPrompt(id);
    return c.json({ data: updated });
  });

  routes.delete("/:id", async (c) => {
    const id = c.req.param("id");
    await storage.deletePrompt(id);
    return c.json({ success: true });
  });

  return routes;
}
