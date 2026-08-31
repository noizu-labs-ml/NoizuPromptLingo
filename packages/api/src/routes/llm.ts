import { Hono } from "hono";
import type { LlmService } from "../services/llm.ts";
import type { StorageService } from "../services/storage.ts";
import type { LlmCompletionRequest, LlmConfig } from "@llm-toolkit/shared";

const LLM_ENV_KEYS: Record<string, string> = {
  anthropic: "ANTHROPIC_API_KEY",
  openai: "OPENAI_API_KEY",
  groq: "GROQ_API_KEY",
  cerebras: "CEREBRAS_API_KEY",
  deepseek: "DEEPSEEK_API_KEY",
  zai: "ZAI_API_KEY",
  litellm: "LITELLM_API_KEY",
};

function isMaskedKey(key: string | undefined): boolean {
  if (!key) return false;
  return key === "***" || /^.{3}\.\.\..{4}$/.test(key);
}

function resolveApiKey(config: LlmConfig, storage: StorageService): LlmConfig {
  if (config.apiKey && !isMaskedKey(config.apiKey)) return config;

  const resolved = { ...config };

  const envKey = LLM_ENV_KEYS[config.provider];
  if (envKey && process.env[envKey]) {
    resolved.apiKey = process.env[envKey];
    return resolved;
  }

  const raw = storage.getSetting("app_config");
  if (raw) {
    try {
      const stored = JSON.parse(raw) as { llm?: LlmConfig };
      if (stored.llm?.apiKey && !isMaskedKey(stored.llm.apiKey)) {
        resolved.apiKey = stored.llm.apiKey;
      }
    } catch {}
  }
  return resolved;
}

// ⟦𓏴𓐡𓁑𓏝⟧ createLlmRoutes :: auto-generated pointer for public function createLlmRoutes
export function createLlmRoutes(llmService: LlmService, storage: StorageService): Hono {
  const routes = new Hono();

  routes.get("/status", (c) => {
    return c.json({
      data: {
        available: llmService.available,
        provider: llmService.providerName,
      },
    });
  });

  routes.get("/models", async (c) => {
    if (!llmService.available) {
      return c.json({ data: [] });
    }
    try {
      const models = await llmService.listModels();
      return c.json({ data: models });
    } catch {
      return c.json({ data: [] });
    }
  });

  routes.post("/models", async (c) => {
    const config = await c.req.json() as LlmConfig;
    if (!config?.provider) {
      return c.json({ data: [] });
    }
    const resolved = resolveApiKey(config, storage);
    const ephemeral = new (await import("../services/llm.ts")).LlmService();
    await ephemeral.initialize(resolved);
    if (!ephemeral.available) {
      return c.json({ data: [] });
    }
    try {
      const models = await ephemeral.listModels();
      return c.json({ data: models });
    } catch {
      return c.json({ data: [] });
    }
  });

  routes.post("/complete", async (c) => {
    if (!llmService.available) {
      return c.json({ error: "LLM service not available — configure a provider in settings", code: "LLM_UNAVAILABLE" }, 503);
    }

    const body = await c.req.json() as LlmCompletionRequest;

    if (!body.messages?.length) {
      return c.json({ error: "messages array is required", code: "INVALID_REQUEST" }, 400);
    }

    try {
      const result = await llmService.complete(body);
      return c.json({ data: result });
    } catch (err) {
      const message = err instanceof Error ? err.message : "Unknown error";
      return c.json({ error: message, code: "LLM_ERROR" }, 500);
    }
  });

  return routes;
}
