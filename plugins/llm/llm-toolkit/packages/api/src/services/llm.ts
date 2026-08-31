import type { LlmConfig, LlmCompletionRequest, LlmCompletionResponse, ContentBlock } from "@llm-toolkit/shared";
import { standardizeContentBlocks } from "@llm-toolkit/shared";
import type { MessageParam } from "@anthropic-ai/sdk/resources/messages";

interface LlmProvider {
  complete(req: LlmCompletionRequest): Promise<LlmCompletionResponse>;
  listModels(): Promise<string[]>;
}

const ANTHROPIC_MODELS = [
  "claude-opus-4-20250514",
  "claude-sonnet-4-20250514",
  "claude-haiku-4-5-20251001",
];

const PROVIDER_DEFAULTS: Record<string, { envKey?: string; baseUrl?: string; model: string; label: string }> = {
  anthropic: { envKey: "ANTHROPIC_API_KEY", model: "claude-sonnet-4-20250514", label: "anthropic" },
  openai: { envKey: "OPENAI_API_KEY", model: "gpt-4o", label: "openai" },
  litellm: { envKey: "LITELLM_API_KEY", baseUrl: "https://inference.noizu.com/v1", model: "claude-sonnet-4-6", label: "litellm" },
  groq: { envKey: "GROQ_API_KEY", baseUrl: "https://api.groq.com/openai/v1", model: "llama-3.3-70b", label: "groq" },
  cerebras: { envKey: "CEREBRAS_API_KEY", baseUrl: "https://api.cerebras.ai/v1", model: "llama-3.3-70b", label: "cerebras" },
  deepseek: { envKey: "DEEPSEEK_API_KEY", baseUrl: "https://api.deepseek.com", model: "deepseek-chat", label: "deepseek" },
  zai: { envKey: "ZAI_API_KEY", baseUrl: "https://open.bigmodel.cn/api/paas/v4", model: "glm-4", label: "zai" },
};

class AnthropicProvider implements LlmProvider {
  private client: import("@anthropic-ai/sdk").default | null = null;
  private apiKey: string;
  private defaultModel: string;

  constructor(apiKey: string, model?: string) {
    this.apiKey = apiKey;
    this.defaultModel = model ?? "claude-sonnet-4-20250514";
  }

  private async getClient() {
    if (!this.client) {
      const { default: Anthropic } = await import("@anthropic-ai/sdk");
      this.client = new Anthropic({ apiKey: this.apiKey });
    }
    return this.client;
  }

  async complete(req: LlmCompletionRequest): Promise<LlmCompletionResponse> {
    const client = await this.getClient();
    const systemMsg = req.messages.find((m) => m.role === "system");
    const system = typeof systemMsg?.content === "string"
      ? systemMsg.content
      : undefined;
    const msgs: MessageParam[] = req.messages
      .filter((m) => m.role !== "system")
      .map((m) => ({
        role: m.role as "user" | "assistant",
        content: typeof m.content === "string"
          ? m.content
          : standardizeContentBlocks(m.content as ContentBlock[]) as MessageParam["content"],
      }));

    const response = await client.messages.create({
      model: req.model ?? this.defaultModel,
      max_tokens: req.maxTokens ?? 1024,
      temperature: req.temperature,
      system,
      messages: msgs,
    });

    const textBlock = response.content.find((b) => b.type === "text");
    return {
      content: textBlock && "text" in textBlock ? textBlock.text : "",
      model: response.model,
      provider: "anthropic",
      usage: {
        inputTokens: response.usage.input_tokens,
        outputTokens: response.usage.output_tokens,
      },
      finishReason: response.stop_reason ?? "end_turn",
    };
  }

  async listModels(): Promise<string[]> {
    try {
      const client = await this.getClient();
      const page = await client.models.list({ limit: 100 });
      return page.data.map((m) => m.id).sort();
    } catch {
      return [...ANTHROPIC_MODELS];
    }
  }
}

class OpenAICompatibleProvider implements LlmProvider {
  private client: import("openai").default | null = null;
  private apiKey: string;
  private baseUrl: string | undefined;
  private defaultModel: string;
  private providerLabel: string;

  constructor(apiKey: string, opts?: { model?: string; baseUrl?: string; providerLabel?: string }) {
    this.apiKey = apiKey;
    this.baseUrl = opts?.baseUrl;
    this.defaultModel = opts?.model ?? "gpt-4o";
    this.providerLabel = opts?.providerLabel ?? "openai";
  }

  private async getClient() {
    if (!this.client) {
      const { default: OpenAI } = await import("openai");
      this.client = new OpenAI({ apiKey: this.apiKey, baseURL: this.baseUrl });
    }
    return this.client;
  }

  async complete(req: LlmCompletionRequest): Promise<LlmCompletionResponse> {
    const client = await this.getClient();
    // OpenAI-compatible APIs only understand text messages; strip thinking/tool blocks
    const messages = req.messages
      .filter((m) => typeof m.content === "string" || !Array.isArray(m.content))
      .map((m) => {
        if (typeof m.content === "string") return { role: m.role, content: m.content };
        const blocks = standardizeContentBlocks(m.content as ContentBlock[]);
        const text = blocks
          .filter((b) => b.type === "text")
          .map((b) => b.text ?? "")
          .join("\n");
        return { role: m.role, content: text };
      });

    const response = await client.chat.completions.create({
      model: req.model ?? this.defaultModel,
      max_tokens: req.maxTokens ?? 1024,
      temperature: req.temperature,
      messages,
    });

    const choice = response.choices[0];
    return {
      content: choice?.message?.content ?? "",
      model: response.model,
      provider: this.providerLabel,
      usage: response.usage
        ? { inputTokens: response.usage.prompt_tokens ?? 0, outputTokens: response.usage.completion_tokens ?? 0 }
        : undefined,
      finishReason: choice?.finish_reason ?? "stop",
    };
  }

  async listModels(): Promise<string[]> {
    try {
      const client = await this.getClient();
      const page = await client.models.list();
      const models: string[] = [];
      for await (const model of page) {
        models.push(model.id);
      }
      return models.sort();
    } catch {
      // Many OpenAI-compatible providers don't support the models endpoint
      return [];
    }
  }
}

class OllamaProvider implements LlmProvider {
  private baseUrl: string;
  private defaultModel: string;

  constructor(baseUrl?: string, model?: string) {
    this.baseUrl = baseUrl ?? "http://localhost:11434";
    this.defaultModel = model ?? "llama3";
  }

  async complete(req: LlmCompletionRequest): Promise<LlmCompletionResponse> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 60_000);

    try {
      const res = await fetch(`${this.baseUrl}/api/chat`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        signal: controller.signal,
        body: JSON.stringify({
          model: req.model ?? this.defaultModel,
          messages: req.messages,
          stream: false,
          options: {
            temperature: req.temperature,
            num_predict: req.maxTokens,
          },
        }),
      });

      if (!res.ok) throw new Error(`Ollama error: ${res.status} ${await res.text()}`);

      const data = (await res.json()) as {
        message?: { content: string };
        model: string;
        done: boolean;
        prompt_eval_count?: number;
        eval_count?: number;
      };

      return {
        content: data.message?.content ?? "",
        model: data.model,
        provider: "ollama",
        usage: data.eval_count
          ? { inputTokens: data.prompt_eval_count ?? 0, outputTokens: data.eval_count }
          : undefined,
        finishReason: data.done ? "stop" : "length",
      };
    } finally {
      clearTimeout(timeout);
    }
  }

  async listModels(): Promise<string[]> {
    const res = await fetch(`${this.baseUrl}/api/tags`, {
      signal: AbortSignal.timeout(10_000),
    });
    if (!res.ok) return [];
    const data = (await res.json()) as { models?: Array<{ name: string }> };
    return (data.models ?? []).map((m) => m.name).sort();
  }
}

export class LlmService {
  private provider: LlmProvider | null = null;
  private _available = false;
  private _providerName = "none";

  get available(): boolean {
    return this._available;
  }

  get providerName(): string {
    return this._providerName;
  }

  async initialize(config?: LlmConfig): Promise<void> {
    if (!config?.provider) {
      console.warn("No LLM provider configured — inference unavailable.");
      return;
    }

    try {
      if (config.provider === "ollama") {
        const baseUrl = config.baseUrl ?? process.env.OLLAMA_BASE_URL;
        this.provider = new OllamaProvider(baseUrl, config.model);
      } else if (config.provider === "anthropic" && config.apiType !== "openai") {
        const key = config.apiKey ?? process.env.ANTHROPIC_API_KEY;
        if (!key) {
          console.warn("Anthropic API key not configured — inference unavailable.");
          return;
        }
        this.provider = new AnthropicProvider(key, config.model);
      } else if (config.provider === "custom") {
        if (!config.baseUrl) {
          console.warn("Custom provider requires a base URL — inference unavailable.");
          return;
        }
        const key = config.apiKey ?? "";
        if (config.apiType === "anthropic") {
          this.provider = new AnthropicProvider(key, config.model);
        } else {
          this.provider = new OpenAICompatibleProvider(key, {
            model: config.model ?? "gpt-4o",
            baseUrl: config.baseUrl,
            providerLabel: "custom",
          });
        }
      } else {
        const defaults = PROVIDER_DEFAULTS[config.provider];
        if (!defaults) {
          console.warn(`Unknown LLM provider: ${config.provider}`);
          return;
        }
        const key = config.apiKey
          ?? (defaults.envKey ? process.env[defaults.envKey] : undefined)
          ?? "";
        if (!key && config.provider !== "litellm") {
          console.warn(`${defaults.label} API key not configured — inference unavailable.`);
          return;
        }
        this.provider = new OpenAICompatibleProvider(key, {
          model: config.model ?? defaults.model,
          baseUrl: config.baseUrl ?? defaults.baseUrl,
          providerLabel: defaults.label,
        });
      }

      this._available = true;
      this._providerName = config.provider;
      console.log(`LLM provider initialized: ${config.provider}${config.model ? ` (${config.model})` : ""}`);
    } catch (err) {
      console.warn(`Failed to initialize LLM provider: ${err instanceof Error ? err.message : err}`);
      this._available = false;
    }
  }

  async complete(req: LlmCompletionRequest): Promise<LlmCompletionResponse> {
    if (!this.provider) throw new Error("LLM service not available — configure a provider in settings");
    return this.provider.complete(req);
  }

  async listModels(): Promise<string[]> {
    if (!this.provider) return [];
    try {
      return await this.provider.listModels();
    } catch {
      return [];
    }
  }

  async reconfigure(config?: LlmConfig): Promise<void> {
    this.provider = null;
    this._available = false;
    this._providerName = "none";
    await this.initialize(config);
  }
}
