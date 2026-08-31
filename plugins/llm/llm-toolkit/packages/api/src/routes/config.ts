import { Hono } from "hono";
import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";
import type { AppConfig } from "@llm-toolkit/shared";
import type { StorageService } from "../services/storage.ts";
import type { LlmService } from "../services/llm.ts";

const CONFIG_KEY = "app_config";

const DEFAULTS: AppConfig = {
  indexPaths: [join(homedir(), ".claude", "projects")],
  indexSources: [
    { harness: "claude", path: join(homedir(), ".claude", "projects"), format: "jsonl", label: "Claude Code" },
    { harness: "codex", path: join(homedir(), ".codex", "sessions"), format: "jsonl", label: "Codex" },
  ],
  embedding: { provider: "local", model: "all-MiniLM-L6-v2" },
  server: { port: 3100, host: "localhost" },
};

const LLM_ENV_KEYS: Record<string, string> = {
  anthropic: "ANTHROPIC_API_KEY",
  openai: "OPENAI_API_KEY",
  groq: "GROQ_API_KEY",
  cerebras: "CEREBRAS_API_KEY",
  deepseek: "DEEPSEEK_API_KEY",
  zai: "ZAI_API_KEY",
  litellm: "LITELLM_API_KEY",
};

function applyEnvOverlays(config: AppConfig): AppConfig {
  // Embedding key overlays
  const embeddingEnvKey = LLM_ENV_KEYS[config.embedding.provider];
  if (embeddingEnvKey && process.env[embeddingEnvKey]) {
    config.embedding.apiKey = process.env[embeddingEnvKey];
  }

  // LLM key + URL overlays
  if (config.llm?.provider) {
    const llmEnvKey = LLM_ENV_KEYS[config.llm.provider];
    if (llmEnvKey && process.env[llmEnvKey]) {
      config.llm.apiKey = process.env[llmEnvKey];
    }
    if (config.llm.provider === "litellm" && !config.llm.apiKey && process.env.OPENAI_API_KEY) {
      config.llm.apiKey = process.env.OPENAI_API_KEY;
    }
    if (config.llm.provider === "ollama" && process.env.OLLAMA_BASE_URL) {
      config.llm.baseUrl = process.env.OLLAMA_BASE_URL;
    }
    if (config.llm.provider === "litellm" && process.env.LITELLM_BASE_URL) {
      config.llm.baseUrl = process.env.LITELLM_BASE_URL;
    }
  }

  return config;
}

function maskKey(key: string | undefined): string | undefined {
  if (!key || key.length < 8) return key ? "***" : undefined;
  return key.slice(0, 3) + "..." + key.slice(-4);
}

function isMaskedKey(key: string | undefined): boolean {
  if (!key) return false;
  return key === "***" || /^.{3}\.\.\..{4}$/.test(key);
}

function sanitizeForResponse(config: AppConfig): AppConfig {
  const safe = structuredClone(config);
  safe.embedding.apiKey = maskKey(safe.embedding.apiKey);
  if (safe.llm) safe.llm.apiKey = maskKey(safe.llm.apiKey);
  return safe;
}

function migrateLegacyConfig(storage: StorageService): Partial<AppConfig> {
  const legacyPath = join(
    process.env.LLM_TOOLKIT_DATA_DIR ?? process.env.CLAUDE_ASSIST_DATA_DIR ?? join(homedir(), ".llm-toolkit"),
    "config.json",
  );
  if (!existsSync(legacyPath)) return {};
  try {
    const raw = JSON.parse(readFileSync(legacyPath, "utf-8")) as Partial<AppConfig>;
    storage.setSetting(CONFIG_KEY, JSON.stringify(raw));
    return raw;
  } catch {
    return {};
  }
}

function loadConfig(storage: StorageService): AppConfig {
  let dbConfig: Partial<AppConfig> = {};
  const raw = storage.getSetting(CONFIG_KEY);
  if (raw) {
    dbConfig = JSON.parse(raw);
  } else {
    dbConfig = migrateLegacyConfig(storage);
  }

  const merged: AppConfig = {
    ...DEFAULTS,
    ...dbConfig,
    embedding: { ...DEFAULTS.embedding, ...dbConfig.embedding },
    server: { ...DEFAULTS.server, ...dbConfig.server },
  };
  if (!merged.indexSources && merged.indexPaths) {
    merged.indexSources = merged.indexPaths.map((path) => ({ harness: "claude", path, format: "jsonl" }));
  }
  if (dbConfig.llm) merged.llm = dbConfig.llm;

  return applyEnvOverlays(merged);
}

// ⟦𓁫𓉳𓉎𓅅⟧ createConfigRoutes :: auto-generated pointer for public function createConfigRoutes
export function createConfigRoutes(storage: StorageService, llmService: LlmService): Hono {
  const routes = new Hono();

  routes.get("/", (c) => {
    const config = loadConfig(storage);
    return c.json({ data: sanitizeForResponse(config) });
  });

  routes.patch("/", async (c) => {
    const current = loadConfig(storage);
    const updates = await c.req.json() as Partial<AppConfig>;

    if (updates.indexPaths) current.indexPaths = updates.indexPaths;
    if (updates.indexSources) current.indexSources = updates.indexSources;
    if (updates.embedding) {
      if (isMaskedKey(updates.embedding.apiKey)) delete updates.embedding.apiKey;
      current.embedding = { ...current.embedding, ...updates.embedding };
    }
    if (updates.server) current.server = { ...current.server, ...updates.server };
    if (updates.llm) {
      if (isMaskedKey(updates.llm.apiKey)) delete updates.llm.apiKey;
      current.llm = { ...current.llm, ...updates.llm };
    }

    // Persist to SQLite (strip env-overlay keys so they don't leak into DB)
    const toStore = structuredClone(current);
    const embEnvKey = LLM_ENV_KEYS[toStore.embedding.provider];
    if (embEnvKey && process.env[embEnvKey]) delete toStore.embedding.apiKey;
    if (toStore.llm?.provider) {
      const llmEnvKey = LLM_ENV_KEYS[toStore.llm.provider];
      if (llmEnvKey && process.env[llmEnvKey]) delete toStore.llm.apiKey;
    }
    storage.setSetting(CONFIG_KEY, JSON.stringify(toStore));

    // Hot-reconfigure LLM service if LLM config changed
    if (updates.llm) {
      await llmService.reconfigure(current.llm);
    }

    return c.json({ data: sanitizeForResponse(current) });
  });

  return routes;
}

export { loadConfig };
