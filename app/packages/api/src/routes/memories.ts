import { Hono } from "hono";
import { MemoryWriteRequestSchema } from "@trr/core";
import type { AppEnv } from "../server.js";

export const memoriesRoutes = new Hono<AppEnv>();

// POST /api/v1/memories — Create a memory
memoriesRoutes.post("/", async (c) => {
  const body = await c.req.json();
  const parsed = MemoryWriteRequestSchema.safeParse(body);

  if (!parsed.success) {
    return c.json({ error: "Validation failed", details: parsed.error.issues }, 400);
  }

  const postgres = c.get("postgres");
  const weaviate = c.get("weaviate");
  const embedder = c.get("embedder");

  const summary = parsed.data.summary ?? parsed.data.content.slice(0, 200);
  const embedding = await embedder.embed(parsed.data.content);

  const memory = await postgres.createMemory(parsed.data, embedding, summary);

  // Store in Weaviate
  await weaviate.upsertMemory(
    memory.id,
    memory.content,
    memory.summary,
    memory.contentType,
    memory.compartment,
    embedding
  );

  return c.json({ memory }, 201);
});

// GET /api/v1/memories/:id — Get a memory by ID
memoriesRoutes.get("/:id", async (c) => {
  const id = c.req.param("id");
  const postgres = c.get("postgres");

  const memory = await postgres.getMemory(id);
  if (!memory) {
    return c.json({ error: "Memory not found" }, 404);
  }

  return c.json({ memory });
});

// POST /api/v1/memories/:id/reinforce — Reinforce a memory
memoriesRoutes.post("/:id/reinforce", async (c) => {
  const id = c.req.param("id");
  const postgres = c.get("postgres");

  const memory = await postgres.getMemory(id);
  if (!memory) {
    return c.json({ error: "Memory not found" }, 404);
  }

  await postgres.reinforceMemory(id);
  const updated = await postgres.getMemory(id);

  return c.json({ memory: updated });
});
