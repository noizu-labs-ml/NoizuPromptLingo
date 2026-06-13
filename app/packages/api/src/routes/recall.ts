import { Hono } from "hono";
import { RecallRequestSchema } from "@trr/core";
import type { AppEnv } from "../server.js";

export const recallRoutes = new Hono<AppEnv>();

recallRoutes.post("/", async (c) => {
  const body = await c.req.json();
  const parsed = RecallRequestSchema.safeParse(body);

  if (!parsed.success) {
    return c.json({ error: "Validation failed", details: parsed.error.issues }, 400);
  }

  const postgres = c.get("postgres");
  const weaviate = c.get("weaviate");
  const embedder = c.get("embedder");
  const startTime = Date.now();

  const queryEmbedding = await embedder.embed(parsed.data.query);

  const vectorResults = await weaviate.searchSimilar(
    queryEmbedding,
    parsed.data.maxResults,
    parsed.data.compartment
  );

  const results = [];
  for (const vr of vectorResults) {
    const memory = await postgres.getMemory(vr.memoryId);
    if (memory && memory.lifecycle.state === "active") {
      results.push({
        memory,
        relevanceScore: vr.score,
        emotionalResonance: 0,
        retrievalPath: [memory.id],
        distanceFromQuery: 0,
      });
      await postgres.reinforceMemory(memory.id);
    }
  }

  const durationMs = Date.now() - startTime;

  return c.json({
    mode: parsed.data.mode,
    query: parsed.data.query,
    totalCandidates: vectorResults.length,
    results,
    durationMs,
    hotIndexHit: false,
  });
});
