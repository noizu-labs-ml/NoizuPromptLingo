#!/usr/bin/env node
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { config } from "dotenv";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

import { PostgresStore, WeaviateStore, RedisStore } from "@trr/storage";
import { OpenAIEmbedding, NEUTRAL_EMOTIONAL_STATE } from "@trr/core";
import type { EmbeddingService } from "@trr/core";

const __dirname = dirname(fileURLToPath(import.meta.url));
config({ path: join(__dirname, "../../../.env.development"), override: true });

const postgres = new PostgresStore(
  process.env.DATABASE_URL ?? "postgresql://trr:trr_dev_password@localhost:5434/therobotremembers"
);
const weaviateStore = new WeaviateStore(
  process.env.WEAVIATE_URL ?? "http://localhost:8081"
);
const redis = new RedisStore(
  process.env.REDIS_URL ?? "redis://localhost:6380"
);
const embedder: EmbeddingService = new OpenAIEmbedding(
  process.env.OPENAI_API_KEY ?? "",
  process.env.EMBEDDING_MODEL ?? "text-embedding-3-small",
  parseInt(process.env.EMBEDDING_DIMENSIONS ?? "1536")
);

const server = new McpServer({
  name: "therobotremembers",
  version: "0.1.0",
});

function getSeason(date: Date): "spring" | "summer" | "autumn" | "winter" {
  const month = date.getMonth();
  if (month >= 2 && month <= 4) return "spring";
  if (month >= 5 && month <= 7) return "summer";
  if (month >= 8 && month <= 10) return "autumn";
  return "winter";
}

server.tool(
  "remember",
  "Store a memory with emotional and contextual metadata. Include mood, frustration level, and what you're working on for richer future recall.",
  {
    content: z.string().describe("The memory — what happened, was learned, or was decided"),
    summary: z.string().optional().describe("Brief summary (auto-generated if omitted)"),
    contentType: z.enum(["episodic", "semantic", "procedural"]).default("episodic")
      .describe("episodic=events, semantic=facts, procedural=how-to"),
    domain: z.string().default("general").describe("Task domain: debugging, design, ops, planning, coding"),
    mood: z.object({
      valence: z.number().min(-1).max(1).describe("-1=negative, 0=neutral, 1=positive"),
      arousal: z.number().min(0).max(1).describe("0=calm, 1=excited/agitated"),
      dominance: z.number().min(0).max(1).describe("0=overwhelmed, 1=in control"),
    }).optional().describe("Current emotional state"),
    frustration: z.number().min(0).max(1).optional().describe("Frustration level 0-1"),
    collaborators: z.array(z.string()).optional().describe("Who is involved"),
    compartment: z.string().default("default").describe("Memory compartment"),
  },
  async ({ content, summary, contentType, domain, mood, frustration, collaborators, compartment }) => {
    try {
      const emotionalMetadata = {
        mood: mood ?? NEUTRAL_EMOTIONAL_STATE.mood,
        hormones: {
          cortisol: frustration ?? 0.2,
          dopamine: (mood?.valence ?? 0) > 0.3 ? 0.6 : 0.3,
          oxytocin: (collaborators?.length ?? 0) > 0 ? 0.5 : 0.2,
          serotonin: 0.5,
        },
        frustrationIndex: frustration ?? 0.0,
        confidence: "medium" as const,
        schemaVersion: 1,
      };

      const now = new Date();
      const hour = now.getHours();
      const timeOfDay = hour < 6 ? "night" : hour < 12 ? "morning" : hour < 18 ? "afternoon" : "evening";

      const contextualMetadata = {
        collaborators: collaborators ?? [],
        taskDomain: domain,
        sessionId: null,
        environment: "development",
        temporal: {
          timeOfDay: timeOfDay as "morning" | "afternoon" | "evening" | "night",
          dayOfWeek: now.toLocaleDateString("en-US", { weekday: "long" }),
          season: getSeason(now),
          isWeekend: [0, 6].includes(now.getDay()),
        },
      };

      const summaryText = summary ?? content.slice(0, 200);
      const embedding = await embedder.embed(content);

      const memory = await postgres.createMemory(
        {
          content,
          contentType,
          summary: summaryText,
          emotionalMetadata,
          contextualMetadata,
          compartment,
          sourceAgent: "mcp-client",
          classification: "open",
        },
        embedding,
        summaryText
      );

      await weaviateStore.upsertMemory(
        memory.id,
        content,
        summaryText,
        contentType,
        compartment,
        embedding
      );

      return {
        content: [{
          type: "text" as const,
          text: `Remembered (${memory.id}): ${summaryText}\nType: ${contentType} | Domain: ${domain} | Mood: v=${emotionalMetadata.mood.valence.toFixed(1)} a=${emotionalMetadata.mood.arousal.toFixed(1)}`,
        }],
      };
    } catch (error: unknown) {
      const msg = error instanceof Error ? error.message : String(error);
      return { content: [{ type: "text" as const, text: `Failed to store memory: ${msg}` }], isError: true };
    }
  }
);

server.tool(
  "recall",
  "Search memories by semantic similarity. Returns ranked results with metadata.",
  {
    query: z.string().describe("What to search for"),
    maxResults: z.number().int().min(1).max(20).default(5).describe("Max memories to return"),
    compartment: z.string().optional().describe("Limit to a compartment"),
  },
  async ({ query, maxResults, compartment }) => {
    try {
      const startTime = Date.now();
      const queryEmbedding = await embedder.embed(query);

      const vectorResults = await weaviateStore.searchSimilar(queryEmbedding, maxResults, compartment);

      const memories = [];
      for (const vr of vectorResults) {
        const memory = await postgres.getMemory(vr.memoryId);
        if (memory && memory.lifecycle.state === "active") {
          await postgres.reinforceMemory(memory.id);
          memories.push({ memory, score: vr.score });
        }
      }

      const durationMs = Date.now() - startTime;

      if (memories.length === 0) {
        return { content: [{ type: "text" as const, text: `No memories found for: "${query}" (${durationMs}ms)` }] };
      }

      const lines = memories.map((m, i) => {
        const em = m.memory.emotionalMetadata;
        const ctx = m.memory.contextualMetadata;
        return [
          `### ${i + 1}. [${m.score.toFixed(2)}] ${m.memory.summary}`,
          `**Content:** ${m.memory.content}`,
          `**Type:** ${m.memory.contentType} | **Domain:** ${ctx.taskDomain} | **Created:** ${m.memory.createdAt}`,
          `**Mood:** valence=${em.mood.valence.toFixed(1)} arousal=${em.mood.arousal.toFixed(1)} | **Frustration:** ${em.frustrationIndex.toFixed(1)}`,
          `**Recalled:** ${m.memory.lifecycle.recallCount}x | **Weight:** ${m.memory.lifecycle.decayWeight}`,
          "",
        ].join("\n");
      });

      return {
        content: [{
          type: "text" as const,
          text: `Found ${memories.length} memories for "${query}" (${durationMs}ms):\n\n${lines.join("\n")}`,
        }],
      };
    } catch (error: unknown) {
      const msg = error instanceof Error ? error.message : String(error);
      return { content: [{ type: "text" as const, text: `Recall failed: ${msg}` }], isError: true };
    }
  }
);

server.tool(
  "memory_health",
  "Check memory system health.",
  {},
  async () => {
    const [pgOk, wvOk, rdOk] = await Promise.all([
      postgres.healthCheck(),
      weaviateStore.healthCheck(),
      redis.healthCheck(),
    ]);
    return {
      content: [{
        type: "text" as const,
        text: `Memory System: PostgreSQL=${pgOk ? "OK" : "DOWN"} Weaviate=${wvOk ? "OK" : "DOWN"} Redis=${rdOk ? "OK" : "DOWN"} Status=${pgOk && wvOk && rdOk ? "HEALTHY" : "DEGRADED"}`,
      }],
    };
  }
);

async function main() {
  await weaviateStore.connect();
  await weaviateStore.ensureCollection();
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("The Robot Remembers MCP server running on stdio");
}

main().catch((err) => {
  console.error("MCP server failed:", err);
  process.exit(1);
});

process.on("SIGTERM", async () => {
  await postgres.close();
  await weaviateStore.close();
  await redis.close();
  process.exit(0);
});
