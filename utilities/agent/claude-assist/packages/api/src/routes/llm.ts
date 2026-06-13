import { Hono } from "hono";
import type { LlmService } from "../services/llm.ts";
import type { LlmCompletionRequest, LlmConfig } from "@claude-assist/shared";

export function createLlmRoutes(llmService: LlmService): Hono {
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
    const ephemeral = new (await import("../services/llm.ts")).LlmService();
    await ephemeral.initialize(config);
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
