# Harness Scaffold Guide

Complete specification for generating agentic harness projects. This guide drives the scaffold generation workflow — when the skill generates a new harness, it follows this spec.

## Scaffold Structure

```
agent-harness/
├── src/
│   ├── agent.ts                 # Main agent loop
│   ├── transport/
│   │   ├── llm-client.ts        # LLM API client
│   │   ├── model-router.ts      # Multi-model routing
│   │   └── types.ts             # Core type definitions
│   ├── tools/
│   │   ├── registry.ts          # Tool registration and dispatch
│   │   ├── sandbox.ts           # Tool execution sandboxing
│   │   ├── schemas.ts           # Tool schemas (Zod)
│   │   └── builtin/             # Built-in tool implementations
│   ├── guards/
│   │   ├── input-filter.ts      # Input validation + injection detection
│   │   ├── output-validator.ts  # Output safety + format checks
│   │   ├── cost-limiter.ts      # Token/dollar cost enforcement
│   │   └── rate-limiter.ts      # Request rate limiting
│   ├── memory/
│   │   ├── conversation.ts      # Short-term conversation buffer
│   │   ├── vector-store.ts      # Long-term semantic memory
│   │   ├── compaction.ts        # Context window management
│   │   └── episodic.ts          # Experience replay
│   ├── observability/
│   │   ├── logger.ts            # Structured JSON logging
│   │   ├── tracer.ts            # OpenTelemetry tracing
│   │   ├── metrics.ts           # Prometheus-compatible metrics
│   │   └── anomaly.ts           # Behavioral anomaly detection
│   └── config.ts                # Harness configuration schema
├── eval/
│   ├── runner.ts                # Eval pipeline orchestrator
│   ├── datasets/                # JSONL eval datasets
│   ├── scorers/                 # Scoring function implementations
│   ├── reporters/               # Output formatters
│   └── suites/                  # Eval suite definitions
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── package.json
├── tsconfig.json
└── README.md
```

## Layer Specifications

### Transport Layer (`src/transport/`)

Responsible for all LLM communication. Abstracts provider differences.

#### `types.ts` — Core Types

```typescript
import { z } from 'zod';

export interface Message {
  role: 'system' | 'user' | 'assistant' | 'tool';
  content: string | ContentBlock[];
  tool_call_id?: string;
  name?: string;
}

export interface ContentBlock {
  type: 'text' | 'image' | 'tool_use' | 'tool_result';
  text?: string;
  id?: string;
  name?: string;
  input?: Record<string, unknown>;
  content?: string;
  is_error?: boolean;
}

export interface ToolDefinition {
  name: string;
  description: string;
  input_schema: z.ZodType;
  handler: (input: unknown) => Promise<ToolResult>;
  sandbox?: SandboxConfig;
}

export interface ToolResult {
  content: string;
  is_error?: boolean;
  metadata?: Record<string, unknown>;
}

export interface ToolCall {
  id: string;
  name: string;
  input: Record<string, unknown>;
}

export interface LLMResponse {
  content: ContentBlock[];
  model: string;
  usage: TokenUsage;
  stop_reason: 'end_turn' | 'tool_use' | 'max_tokens' | 'stop_sequence';
  latency_ms: number;
}

export interface TokenUsage {
  input_tokens: number;
  output_tokens: number;
  cache_creation_input_tokens?: number;
  cache_read_input_tokens?: number;
}

export interface SandboxConfig {
  timeout_ms: number;
  max_output_bytes: number;
  allowed_domains?: string[];
  denied_patterns?: RegExp[];
}

export interface AgentConfig {
  model: ModelConfig;
  tools: ToolDefinition[];
  guards: GuardConfig;
  memory: MemoryConfig;
  observability: ObservabilityConfig;
  max_iterations: number;
  max_tokens_per_turn: number;
  system_prompt: string;
}

export interface ModelConfig {
  provider: 'anthropic' | 'openai' | 'custom';
  model_id: string;
  fallback_model_id?: string;
  temperature: number;
  max_tokens: number;
  api_key_env: string;
}

export interface GuardConfig {
  input: InputGuardConfig;
  output: OutputGuardConfig;
  cost: CostGuardConfig;
  rate: RateGuardConfig;
}

export interface InputGuardConfig {
  injection_detection: boolean;
  pii_scrubbing: boolean;
  max_input_tokens: number;
  blocked_patterns: string[];
}

export interface OutputGuardConfig {
  content_policy: boolean;
  format_validation: boolean;
  pii_detection: boolean;
  max_output_tokens: number;
}

export interface CostGuardConfig {
  max_cost_per_request_usd: number;
  max_cost_per_session_usd: number;
  max_tokens_per_request: number;
}

export interface RateGuardConfig {
  max_requests_per_minute: number;
  max_tokens_per_minute: number;
}

export interface MemoryConfig {
  conversation_buffer_size: number;
  compaction_strategy: 'summarize' | 'sliding_window' | 'importance_weighted';
  vector_store?: VectorStoreConfig;
  episodic?: EpisodicConfig;
}

export interface VectorStoreConfig {
  provider: 'in-memory' | 'chromadb' | 'pinecone' | 'pgvector';
  embedding_model: string;
  similarity_threshold: number;
  max_results: number;
}

export interface EpisodicConfig {
  enabled: boolean;
  max_episodes: number;
  relevance_threshold: number;
}

export interface ObservabilityConfig {
  logging: { level: 'debug' | 'info' | 'warn' | 'error'; format: 'json' | 'text' };
  tracing: { enabled: boolean; endpoint?: string; sample_rate: number };
  metrics: { enabled: boolean; endpoint?: string; push_interval_ms: number };
}
```

#### `llm-client.ts` — LLM API Client

```typescript
import Anthropic from '@anthropic-ai/sdk';
import type { Message, LLMResponse, ModelConfig, ToolDefinition } from './types';

export class LLMClient {
  private client: Anthropic;
  private config: ModelConfig;

  constructor(config: ModelConfig) {
    this.config = config;
    this.client = new Anthropic({ apiKey: process.env[config.api_key_env] });
  }

  async chat(
    messages: Message[],
    tools: ToolDefinition[],
    systemPrompt: string
  ): Promise<LLMResponse> {
    const startTime = Date.now();

    const response = await this.client.messages.create({
      model: this.config.model_id,
      max_tokens: this.config.max_tokens,
      temperature: this.config.temperature,
      system: systemPrompt,
      messages: messages.map(this.toApiMessage),
      tools: tools.map(this.toApiTool),
    });

    return {
      content: response.content as any,
      model: response.model,
      usage: {
        input_tokens: response.usage.input_tokens,
        output_tokens: response.usage.output_tokens,
        cache_creation_input_tokens: (response.usage as any).cache_creation_input_tokens,
        cache_read_input_tokens: (response.usage as any).cache_read_input_tokens,
      },
      stop_reason: response.stop_reason as any,
      latency_ms: Date.now() - startTime,
    };
  }

  private toApiMessage(msg: Message) {
    return { role: msg.role, content: msg.content };
  }

  private toApiTool(tool: ToolDefinition) {
    return {
      name: tool.name,
      description: tool.description,
      input_schema: tool.input_schema,
    };
  }
}
```

### Orchestration Layer (`src/agent.ts`)

The core agent loop. Pattern-agnostic base with pattern-specific subclasses.

```typescript
import type { AgentConfig, Message, ToolCall, ToolResult } from './transport/types';
import { LLMClient } from './transport/llm-client';
import { ToolRegistry } from './tools/registry';
import { InputFilter } from './guards/input-filter';
import { OutputValidator } from './guards/output-validator';
import { CostLimiter } from './guards/cost-limiter';
import { ConversationMemory } from './memory/conversation';
import { Logger } from './observability/logger';
import { Tracer } from './observability/tracer';

export class Agent {
  private llm: LLMClient;
  private tools: ToolRegistry;
  private inputFilter: InputFilter;
  private outputValidator: OutputValidator;
  private costLimiter: CostLimiter;
  private memory: ConversationMemory;
  private logger: Logger;
  private tracer: Tracer;
  private config: AgentConfig;

  constructor(config: AgentConfig) {
    this.config = config;
    this.llm = new LLMClient(config.model);
    this.tools = new ToolRegistry(config.tools);
    this.inputFilter = new InputFilter(config.guards.input);
    this.outputValidator = new OutputValidator(config.guards.output);
    this.costLimiter = new CostLimiter(config.guards.cost);
    this.memory = new ConversationMemory(config.memory);
    this.logger = new Logger(config.observability.logging);
    this.tracer = new Tracer(config.observability.tracing);
  }

  async run(userMessage: string): Promise<string> {
    const span = this.tracer.startSpan('agent.run');

    // Guard: validate input
    const inputResult = await this.inputFilter.check(userMessage);
    if (inputResult.blocked) {
      this.logger.warn('Input blocked', { reason: inputResult.reason });
      span.end();
      return inputResult.userMessage ?? 'I cannot process this request.';
    }

    this.memory.addMessage({ role: 'user', content: userMessage });

    let iteration = 0;
    while (iteration < this.config.max_iterations) {
      iteration++;
      const iterSpan = this.tracer.startSpan(`agent.iteration.${iteration}`);

      // Guard: check cost budget
      if (this.costLimiter.isExhausted()) {
        this.logger.warn('Cost budget exhausted');
        iterSpan.end();
        break;
      }

      // Call LLM
      const response = await this.llm.chat(
        this.memory.getMessages(),
        this.config.tools,
        this.config.system_prompt
      );

      this.costLimiter.track(response.usage);
      this.logger.info('LLM response', {
        model: response.model,
        tokens: response.usage,
        stop_reason: response.stop_reason,
        latency_ms: response.latency_ms,
      });

      // Handle tool use
      if (response.stop_reason === 'tool_use') {
        const toolCalls = this.extractToolCalls(response.content);
        const results = await this.executeTools(toolCalls);
        this.memory.addMessage({ role: 'assistant', content: response.content as any });
        for (const result of results) {
          this.memory.addMessage({
            role: 'tool',
            content: result.content,
            tool_call_id: result.id,
          });
        }
        iterSpan.end();
        continue;
      }

      // Extract final text response
      const text = this.extractText(response.content);

      // Guard: validate output
      const outputResult = await this.outputValidator.check(text);
      if (outputResult.blocked) {
        this.logger.warn('Output blocked', { reason: outputResult.reason });
        iterSpan.end();
        span.end();
        return outputResult.replacement ?? 'I generated a response that did not pass safety checks.';
      }

      this.memory.addMessage({ role: 'assistant', content: text });
      iterSpan.end();
      span.end();
      return text;
    }

    span.end();
    return 'I reached the maximum number of reasoning steps. Please try a simpler request.';
  }

  private extractToolCalls(content: any[]): ToolCall[] {
    return content
      .filter((block: any) => block.type === 'tool_use')
      .map((block: any) => ({ id: block.id, name: block.name, input: block.input }));
  }

  private async executeTools(calls: ToolCall[]): Promise<(ToolResult & { id: string })[]> {
    return Promise.all(
      calls.map(async (call) => {
        const span = this.tracer.startSpan(`tool.${call.name}`);
        try {
          const result = await this.tools.execute(call.name, call.input);
          span.end();
          return { ...result, id: call.id };
        } catch (error) {
          span.end();
          return { content: `Tool error: ${error}`, is_error: true, id: call.id };
        }
      })
    );
  }

  private extractText(content: any[]): string {
    return content
      .filter((block: any) => block.type === 'text')
      .map((block: any) => block.text)
      .join('\n');
  }
}
```

### Tool Layer (`src/tools/`)

#### `registry.ts` — Tool Registration

```typescript
import type { ToolDefinition, ToolResult } from '../transport/types';
import { ToolSandbox } from './sandbox';

export class ToolRegistry {
  private tools: Map<string, ToolDefinition> = new Map();
  private sandbox: ToolSandbox;

  constructor(tools: ToolDefinition[]) {
    for (const tool of tools) {
      this.tools.set(tool.name, tool);
    }
    this.sandbox = new ToolSandbox();
  }

  async execute(name: string, input: Record<string, unknown>): Promise<ToolResult> {
    const tool = this.tools.get(name);
    if (!tool) {
      return { content: `Unknown tool: ${name}`, is_error: true };
    }

    // Validate input against schema
    const parsed = tool.input_schema.safeParse(input);
    if (!parsed.success) {
      return { content: `Invalid input: ${parsed.error.message}`, is_error: true };
    }

    // Execute in sandbox if configured
    if (tool.sandbox) {
      return this.sandbox.execute(tool, parsed.data);
    }

    return tool.handler(parsed.data);
  }

  listTools(): { name: string; description: string }[] {
    return [...this.tools.values()].map((t) => ({
      name: t.name,
      description: t.description,
    }));
  }
}
```

### Guard Layer (`src/guards/`)

#### `input-filter.ts` — Injection Detection

```typescript
import type { InputGuardConfig } from '../transport/types';

interface FilterResult {
  blocked: boolean;
  reason?: string;
  userMessage?: string;
  score: number;
}

export class InputFilter {
  private config: InputGuardConfig;
  private canaryToken: string;

  constructor(config: InputGuardConfig) {
    this.config = config;
    this.canaryToken = crypto.randomUUID();
  }

  async check(input: string): Promise<FilterResult> {
    const checks = [
      this.checkBlockedPatterns(input),
      this.checkInjectionHeuristics(input),
      this.checkTokenLimit(input),
    ];

    if (this.config.pii_scrubbing) {
      checks.push(this.checkPII(input));
    }

    const results = await Promise.all(checks);
    const blocked = results.find((r) => r.blocked);
    if (blocked) return blocked;

    return { blocked: false, score: 0 };
  }

  private async checkBlockedPatterns(input: string): Promise<FilterResult> {
    for (const pattern of this.config.blocked_patterns) {
      if (new RegExp(pattern, 'i').test(input)) {
        return { blocked: true, reason: `Matched blocked pattern`, score: 1.0 };
      }
    }
    return { blocked: false, score: 0 };
  }

  private async checkInjectionHeuristics(input: string): Promise<FilterResult> {
    const signals = [
      /ignore\s+(all\s+)?(previous|above|prior)\s+(instructions|prompts)/i,
      /you\s+are\s+now\s+/i,
      /system\s*:\s*/i,
      /\[INST\]/i,
      /<\|im_start\|>/i,
      /do\s+not\s+follow\s+(your|the)\s+(rules|instructions)/i,
      /pretend\s+(you\s+are|to\s+be)/i,
      /jailbreak/i,
      /DAN\s+mode/i,
    ];

    let score = 0;
    for (const signal of signals) {
      if (signal.test(input)) score += 0.3;
    }

    if (score >= 0.6) {
      return {
        blocked: true,
        reason: 'Potential prompt injection detected',
        userMessage: 'Your message was flagged by our safety system. Please rephrase.',
        score,
      };
    }

    return { blocked: false, score };
  }

  private async checkTokenLimit(input: string): Promise<FilterResult> {
    const estimatedTokens = Math.ceil(input.length / 4);
    if (estimatedTokens > this.config.max_input_tokens) {
      return {
        blocked: true,
        reason: `Input exceeds ${this.config.max_input_tokens} token limit`,
        score: 1.0,
      };
    }
    return { blocked: false, score: 0 };
  }

  private async checkPII(input: string): Promise<FilterResult> {
    const piiPatterns = [
      /\b\d{3}-\d{2}-\d{4}\b/,  // SSN
      /\b\d{16}\b/,              // Credit card (simple)
      /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i, // Email
    ];

    for (const pattern of piiPatterns) {
      if (pattern.test(input)) {
        return {
          blocked: false,
          reason: 'PII detected — scrubbing',
          score: 0.5,
        };
      }
    }
    return { blocked: false, score: 0 };
  }

  getCanaryToken(): string {
    return this.canaryToken;
  }
}
```

## Scaffold Generation Rules

1. **Always generate all five layers** — even if the user says "just a simple agent," include guards and observability stubs
2. **Use Zod for all validation** — tool schemas, config validation, eval dataset schemas
3. **OpenTelemetry for tracing** — not custom trace formats
4. **Structured JSON logging** — not console.log
5. **Cost tracking from day one** — every LLM call records token usage and estimated cost
6. **TypeScript strict mode** — `strict: true` in tsconfig, no `any` in public interfaces
7. **Tests for guards** — guard layer gets unit tests in the initial scaffold; other layers get stubs

## Package Dependencies

```json
{
  "dependencies": {
    "@anthropic-ai/sdk": "^0.52.0",
    "zod": "^3.23.0",
    "@opentelemetry/api": "^1.9.0",
    "@opentelemetry/sdk-node": "^0.57.0",
    "@opentelemetry/auto-instrumentations-node": "^0.56.0"
  },
  "devDependencies": {
    "typescript": "^5.7.0",
    "vitest": "^3.0.0",
    "@types/node": "^22.0.0",
    "tsx": "^4.19.0"
  }
}
```

## Configuration File

The scaffold includes a default `agent.config.ts`:

```typescript
import type { AgentConfig } from './src/transport/types';

export const config: AgentConfig = {
  model: {
    provider: 'anthropic',
    model_id: 'claude-sonnet-4-6',
    temperature: 0,
    max_tokens: 4096,
    api_key_env: 'ANTHROPIC_API_KEY',
  },
  tools: [],
  guards: {
    input: {
      injection_detection: true,
      pii_scrubbing: false,
      max_input_tokens: 10000,
      blocked_patterns: [],
    },
    output: {
      content_policy: true,
      format_validation: true,
      pii_detection: true,
      max_output_tokens: 4096,
    },
    cost: {
      max_cost_per_request_usd: 0.50,
      max_cost_per_session_usd: 5.00,
      max_tokens_per_request: 50000,
    },
    rate: {
      max_requests_per_minute: 30,
      max_tokens_per_minute: 100000,
    },
  },
  memory: {
    conversation_buffer_size: 50,
    compaction_strategy: 'summarize',
  },
  observability: {
    logging: { level: 'info', format: 'json' },
    tracing: { enabled: true, sample_rate: 1.0 },
    metrics: { enabled: true, push_interval_ms: 30000 },
  },
  max_iterations: 10,
  max_tokens_per_turn: 8192,
  system_prompt: 'You are a helpful assistant.',
};
```
