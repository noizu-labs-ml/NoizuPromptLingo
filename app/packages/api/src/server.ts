import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { config } from "dotenv";

import { PostgresStore, WeaviateStore, RedisStore } from "@trr/storage";
import { OpenAIEmbedding } from "@trr/core";
import type { EmbeddingService } from "@trr/core";

import { memoriesRoutes } from "./routes/memories.js";
import { recallRoutes } from "./routes/recall.js";
import { adminRoutes } from "./routes/admin.js";
import { errorHandler } from "./middleware/error-handler.js";
import { apiKeyAuth } from "./middleware/auth.js";

config({ path: ".env.development", override: true });
config({ path: "../../.env.development", override: true });

export interface AppEnv {
  Variables: {
    postgres: PostgresStore;
    weaviate: WeaviateStore;
    redis: RedisStore;
    embedder: EmbeddingService;
  };
}

const app = new Hono<AppEnv>();

app.use("*", logger());
app.use("*", cors());
app.use("/api/*", apiKeyAuth);
app.onError(errorHandler);

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

app.use("*", async (c, next) => {
  c.set("postgres", postgres);
  c.set("weaviate", weaviateStore);
  c.set("redis", redis);
  c.set("embedder", embedder);
  await next();
});

app.route("/api/v1/memories", memoriesRoutes);
app.route("/api/v1/recall", recallRoutes);
app.route("/api/v1/admin", adminRoutes);

app.get("/api/v1/health", async (c) => {
  const [pgOk, wvOk, rdOk] = await Promise.all([
    postgres.healthCheck(),
    weaviateStore.healthCheck(),
    redis.healthCheck(),
  ]);
  const healthy = pgOk && wvOk && rdOk;
  return c.json({
    status: healthy ? "healthy" : "degraded",
    stores: { postgres: pgOk ? "ok" : "down", weaviate: wvOk ? "ok" : "down", redis: rdOk ? "ok" : "down" },
    timestamp: new Date().toISOString(),
  }, healthy ? 200 : 503);
});

async function start() {
  await weaviateStore.connect();
  await weaviateStore.ensureCollection();
  const port = parseInt(process.env.PORT ?? "3100");
  serve({ fetch: app.fetch, port });
  console.log(`The Robot Remembers API ready at http://localhost:${port}`);
}

start().catch((err) => {
  console.error("Failed to start:", err);
  process.exit(1);
});

process.on("SIGTERM", async () => {
  await postgres.close();
  await weaviateStore.close();
  await redis.close();
  process.exit(0);
});
