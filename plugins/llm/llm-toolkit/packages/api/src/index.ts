import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { serve } from "@hono/node-server";
import { existsSync, readFileSync, statSync } from "node:fs";
import { dirname, extname, join, normalize } from "node:path";
import { fileURLToPath } from "node:url";
import { homedir } from "node:os";
import type { IndexSource } from "@llm-toolkit/shared";
import { createConversationRoutes } from "./routes/conversations.ts";
import { createSearchRoutes } from "./routes/search.ts";
import { createDatasetRoutes } from "./routes/datasets.ts";
import { createConfigRoutes, loadConfig } from "./routes/config.ts";
import { createIndexRoutes } from "./routes/index-routes.ts";
import { createPromptRoutes } from "./routes/prompts.ts";
import { createProjectRoutes } from "./routes/projects.ts";
import { createTagRoutes } from "./routes/tags.ts";
import { createLlmRoutes } from "./routes/llm.ts";
import { StorageService } from "./services/storage.ts";
import { IndexerService } from "./services/indexer.ts";
import { SearchService } from "./services/search.ts";
import { EmbeddingService } from "./services/embeddings.ts";
import { LlmService } from "./services/llm.ts";

const dataDir = process.env.LLM_TOOLKIT_DATA_DIR ?? process.env.CLAUDE_ASSIST_DATA_DIR ?? join(homedir(), ".llm-toolkit");
const dbPath = join(dataDir, "llm-toolkit.db");

const defaultIndexSources: IndexSource[] = [
  { harness: "claude", path: join(homedir(), ".claude", "projects"), format: "jsonl", label: "Claude Code" },
  { harness: "codex", path: join(homedir(), ".codex", "sessions"), format: "jsonl", label: "Codex" },
];
const watchPaths = process.env.LLM_TOOLKIT_WATCH_PATHS ?? process.env.CLAUDE_ASSIST_WATCH_PATHS;
const indexSources = watchPaths
  ? watchPaths.split(":").map((path) => ({ harness: "claude" as const, path, format: "jsonl" as const }))
  : defaultIndexSources;

const embeddings = new EmbeddingService();
const storage = new StorageService(dbPath);
const llmService = new LlmService();
const indexer = new IndexerService(storage, indexSources, embeddings, llmService);
const searchService = new SearchService(storage, embeddings);

const app = new Hono();

app.use("*", logger());
app.use(
  "*",
  cors({
    origin: (origin) => {
      if (!origin) return "";
      try {
        const host = new URL(origin).hostname;
        if (host === "localhost" || host === "127.0.0.1") return origin;
      } catch {
        /* ignore */
      }
      return "http://localhost:3100";
    },
  }),
);

app.get("/api/health", (c) => c.json({ status: "ok" }));

app.route("/api/conversations", createConversationRoutes(storage, searchService));
app.route("/api/search", createSearchRoutes(searchService));
app.route("/api/datasets", createDatasetRoutes(storage));
app.route("/api/config", createConfigRoutes(storage, llmService));
app.route("/api/index", createIndexRoutes(indexer));
app.route("/api/prompts", createPromptRoutes(storage));
app.route("/api/projects", createProjectRoutes(storage));
app.route("/api/tags", createTagRoutes(storage));
app.route("/api/llm", createLlmRoutes(llmService, storage));

const webDist = join(dirname(fileURLToPath(import.meta.url)), "..", "..", "web", "dist");
if (existsSync(join(webDist, "index.html"))) {
  app.get("*", (c) => {
    if (c.req.path.startsWith("/api")) return c.notFound();
    const file = consoleAsset(webDist, c.req.path);
    const body = readFileSync(file.path);
    return c.body(body, 200, { "Content-Type": file.type });
  });
}

const port = Number(process.env.PORT) || 3100;

async function start() {
  const { mkdirSync } = await import("node:fs");
  mkdirSync(dataDir, { recursive: true });

  await storage.initialize();
  console.log(`Database initialized at ${dbPath}`);

  // Load config from DB and initialize LLM service
  const config = loadConfig(storage);
  const llmReady = config.llm
    ? llmService.initialize(config.llm).then(() => {
      if (llmService.available) {
        console.log(`LLM inference ready — provider: ${llmService.providerName}`);
      }
    })
    : Promise.resolve();

  const embeddingsReady = embeddings.initialize().then(() => {
    if (embeddings.ready) {
      console.log("Embedding model ready — semantic search enabled");
    }
  });

  serve({ fetch: app.fetch, port }, async () => {
    console.log(`llm-toolkit api listening on http://localhost:${port}`);
    console.log(`Watching: ${indexSources.map((source) => `${source.harness}:${source.path}`).join(", ")}`);

    const stats = await storage.getStats();
    if (stats.conversationCount === 0) {
      console.log("No conversations indexed — running initial index...");
      await Promise.allSettled([llmReady, embeddingsReady]);
      indexer.indexAll().then((result) => {
        console.log(`Initial index: ${result.indexed} indexed, ${result.errors} errors, ${result.skipped} skipped`);
      });
    }

    if ((process.env.LLM_TOOLKIT_WATCH ?? process.env.CLAUDE_ASSIST_WATCH) !== "false") {
      indexer.watch();
    }
  });
}

start().catch((err) => {
  console.error("Failed to start:", err);
  process.exit(1);
});

export { app, storage, indexer, searchService, llmService };

function consoleAsset(root: string, requestPath: string): { path: string; type: string } {
  const index = join(root, "index.html");
  const decoded = decodeURIComponent(requestPath.split("?")[0] ?? "/");
  const relative = decoded.replace(/^\/+/, "");
  const candidate = normalize(join(root, relative));
  if (relative && candidate.startsWith(root) && existsSync(candidate) && statSync(candidate).isFile()) {
    return { path: candidate, type: contentType(candidate) };
  }
  return { path: index, type: "text/html; charset=utf-8" };
}

function contentType(filePath: string): string {
  switch (extname(filePath).toLowerCase()) {
    case ".html": return "text/html; charset=utf-8";
    case ".js": return "text/javascript; charset=utf-8";
    case ".css": return "text/css; charset=utf-8";
    case ".json": return "application/json";
    case ".svg": return "image/svg+xml";
    case ".png": return "image/png";
    case ".ico": return "image/x-icon";
    case ".woff2": return "font/woff2";
    case ".map": return "application/json";
    default: return "application/octet-stream";
  }
}
