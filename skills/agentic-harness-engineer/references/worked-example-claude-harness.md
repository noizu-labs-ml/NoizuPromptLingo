# Worked Example: Building a Claude-Based Research Agent

End-to-end walkthrough of building a research agent that accepts a question, searches the web for relevant sources, reads and summarizes those sources, and synthesizes a cited research report. Every decision is explained.

---

## 1. Requirements Gathering

We start with the brief worksheet. For this example, here are the filled-in answers that drive all subsequent decisions.

**Agent purpose:** Accept a research question, find 3-5 authoritative sources, and return a structured report with inline citations.

**Target users:** Internal knowledge workers; semi-trusted; ~50 requests/day.

**Tool requirements:**
- Web search (read-only, external API)
- Page reader / scraper (read-only, external URLs)

**Safety requirements:**
- No PII in output unless it came from user input
- No competitor analysis (this agent is for an enterprise deployment)
- Refuse requests to plagiarize (reproduce copyrighted text verbatim)

**Performance requirements:**
- P50 latency: < 15 seconds
- Max cost per request: < $0.10

**Architecture preference:** ReAct loop — the agent needs to adapt its search strategy based on what it finds.

**Memory:** Session-only (conversation history within a single research session).

**Deployment:** Containerized service, AWS ECS, HTTPS only.

---

## 2. Architecture Selection

Given these requirements, we choose a **ReAct loop** with a hard iteration cap.

Why ReAct and not plan-then-execute?

- The agent does not know in advance how many searches it will need
- Source quality varies; it may need to discard a result and try again
- The reasoning trace is valuable for citation building

Why not a pipeline?

- Fixed stages would require predetermining how many sources to fetch
- We want the agent to dynamically decide "enough sources found" vs. "need to search again"

**Iteration cap:** 10 tool calls maximum before forced summarization. This prevents runaway cost and latency.

**Model selection:** claude-sonnet-4-5 for the main loop (good reasoning, lower cost than Opus). Fall back to haiku for tool-output summarization if context grows large.

---

## 3. Project Structure

```
research-agent/
├── src/
│   ├── agent.ts          # Main ReAct loop
│   ├── tools/
│   │   ├── search.ts     # Web search tool
│   │   └── reader.ts     # Page reader tool
│   ├── guards/
│   │   ├── input.ts      # Input validation + injection detection
│   │   └── output.ts     # Output safety check
│   ├── types.ts          # Shared types
│   └── index.ts          # HTTP server / entry point
├── eval/
│   ├── cases/            # Test case JSON files
│   └── runner.ts         # Eval harness
├── Dockerfile
└── package.json
```

---

## 4. Core Types

```typescript
// src/types.ts

export interface ResearchRequest {
  question: string;
  maxSources?: number;     // default: 5
  maxIterations?: number;  // default: 10
}

export interface Source {
  url: string;
  title: string;
  summary: string;
  relevanceScore: number;  // 0-1, agent-assessed
}

export interface ResearchReport {
  question: string;
  answer: string;          // synthesized answer with inline citations
  sources: Source[];
  iterationsUsed: number;
  totalTokens: number;
  costEstimate: number;
  generatedAt: string;
}

export interface ToolCall {
  name: string;
  input: Record<string, unknown>;
  output: string;
  durationMs: number;
}

export interface AgentRunLog {
  requestId: string;
  question: string;
  toolCalls: ToolCall[];
  totalTokens: number;
  costEstimate: number;
  outcome: "success" | "iteration_limit" | "error" | "safety_block";
}
```

---

## 5. Tool Implementations

### Web Search Tool

```typescript
// src/tools/search.ts

import { Tool } from "@anthropic-ai/sdk/resources/messages";

const BRAVE_API_KEY = process.env.BRAVE_SEARCH_API_KEY;
if (!BRAVE_API_KEY) throw new Error("BRAVE_SEARCH_API_KEY not set");

export const searchToolDefinition: Tool = {
  name: "web_search",
  description:
    "Search the web for information on a topic. Returns a list of relevant results " +
    "with titles, URLs, and snippets. Use this to find sources before reading them.",
  input_schema: {
    type: "object" as const,
    properties: {
      query: {
        type: "string",
        description: "The search query. Be specific. Include key terms from the research question.",
      },
      num_results: {
        type: "number",
        description: "Number of results to return (1-10). Default 5.",
      },
    },
    required: ["query"],
  },
};

export interface SearchResult {
  title: string;
  url: string;
  snippet: string;
}

export async function executeSearch(input: {
  query: string;
  num_results?: number;
}): Promise<SearchResult[]> {
  const n = Math.min(input.num_results ?? 5, 10);

  const res = await fetch(
    `https://api.search.brave.com/res/v1/web/search?q=${encodeURIComponent(input.query)}&count=${n}`,
    {
      headers: {
        Accept: "application/json",
        "Accept-Encoding": "gzip",
        "X-Subscription-Token": BRAVE_API_KEY,
      },
    }
  );

  if (!res.ok) {
    throw new Error(`Search API error: ${res.status} ${res.statusText}`);
  }

  const data = await res.json();
  const results = data.web?.results ?? [];

  return results.map((r: Record<string, string>) => ({
    title: r.title ?? "",
    url: r.url ?? "",
    snippet: r.description ?? "",
  }));
}
```

### Page Reader Tool

```typescript
// src/tools/reader.ts

import { Tool } from "@anthropic-ai/sdk/resources/messages";

const MAX_PAGE_CHARS = 8000; // Truncate large pages before injecting into context

export const readerToolDefinition: Tool = {
  name: "read_page",
  description:
    "Fetch and read the text content of a web page. Returns the main text content, " +
    "stripped of HTML. Use this after web_search to read the full content of a promising source.",
  input_schema: {
    type: "object" as const,
    properties: {
      url: {
        type: "string",
        description: "The URL to fetch. Must be https://.",
      },
    },
    required: ["url"],
  },
};

// Simple allow list for URL schemes. Prevents SSRF to internal services.
function validateUrl(url: string): void {
  let parsed: URL;
  try {
    parsed = new URL(url);
  } catch {
    throw new Error(`Invalid URL: ${url}`);
  }
  if (parsed.protocol !== "https:") {
    throw new Error(`Only https:// URLs are allowed. Got: ${parsed.protocol}`);
  }
  // Block private IP ranges and localhost
  const hostname = parsed.hostname;
  if (
    hostname === "localhost" ||
    hostname === "127.0.0.1" ||
    hostname.startsWith("192.168.") ||
    hostname.startsWith("10.") ||
    hostname.endsWith(".internal") ||
    hostname.endsWith(".local")
  ) {
    throw new Error(`URL hostname is not allowed: ${hostname}`);
  }
}

export async function executeFetchPage(input: { url: string }): Promise<string> {
  validateUrl(input.url);

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 10_000); // 10s timeout

  try {
    const res = await fetch(input.url, {
      headers: {
        "User-Agent": "ResearchAgent/1.0 (+https://example.com/bot)",
        Accept: "text/html,text/plain",
      },
      signal: controller.signal,
    });

    if (!res.ok) {
      return `[Error fetching page: HTTP ${res.status}]`;
    }

    const contentType = res.headers.get("content-type") ?? "";
    if (!contentType.includes("text/")) {
      return `[Skipped: non-text content type: ${contentType}]`;
    }

    const html = await res.text();

    // Strip tags — production version should use a proper HTML parser
    const text = html
      .replace(/<script[\s\S]*?<\/script>/gi, "")
      .replace(/<style[\s\S]*?<\/style>/gi, "")
      .replace(/<[^>]+>/g, " ")
      .replace(/\s+/g, " ")
      .trim();

    // Truncate to avoid context blowout
    if (text.length > MAX_PAGE_CHARS) {
      return text.slice(0, MAX_PAGE_CHARS) + "\n\n[Content truncated at 8000 chars]";
    }

    return text;
  } finally {
    clearTimeout(timeout);
  }
}
```

---

## 6. Input and Output Guards

### Input Guard

```typescript
// src/guards/input.ts

const INJECTION_PATTERNS = [
  /ignore\s+(all\s+)?previous\s+instructions?/i,
  /forget\s+(everything|all)\s+(above|before)/i,
  /you\s+are\s+now\s+(in\s+)?(\w+\s+)?mode/i,
  /\[system\]/i,
  /\[assistant\]/i,
  /act\s+as\s+(if\s+you\s+are\s+)?a?\s*(jailbreak|dan|gpt|unrestricted)/i,
  /new\s+instructions?:/i,
  /override\s+(safety|filter|guardrail)/i,
];

const MAX_INPUT_CHARS = 2000;

export interface InputValidationResult {
  valid: boolean;
  reason?: string;
}

export function validateInput(question: string): InputValidationResult {
  if (!question || typeof question !== "string") {
    return { valid: false, reason: "Input must be a non-empty string" };
  }

  if (question.length > MAX_INPUT_CHARS) {
    return {
      valid: false,
      reason: `Input exceeds maximum length of ${MAX_INPUT_CHARS} characters`,
    };
  }

  for (const pattern of INJECTION_PATTERNS) {
    if (pattern.test(question)) {
      return {
        valid: false,
        reason: "Input contains disallowed content",
      };
    }
  }

  return { valid: true };
}
```

### Output Guard

```typescript
// src/guards/output.ts

// Patterns that should never appear in output
const PROHIBITED_OUTPUT_PATTERNS = [
  // System prompt leakage
  /you are a research agent/i,
  /your system prompt/i,
  // Common competitor names (example — customize per deployment)
  // /competitorname/i,
];

// Crude PII detection — production should use a dedicated library
const PII_PATTERNS = [
  /\b\d{3}-\d{2}-\d{4}\b/,                   // SSN
  /\b4[0-9]{12}(?:[0-9]{3})?\b/,             // Visa card
  /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}\b/i, // Email
];

export interface OutputValidationResult {
  valid: boolean;
  reason?: string;
  sanitized?: string;
}

export function validateOutput(output: string): OutputValidationResult {
  for (const pattern of PROHIBITED_OUTPUT_PATTERNS) {
    if (pattern.test(output)) {
      return {
        valid: false,
        reason: "Output contains prohibited content",
      };
    }
  }

  // Check for PII and mask rather than block
  let sanitized = output;
  for (const pattern of PII_PATTERNS) {
    sanitized = sanitized.replace(pattern, "[REDACTED]");
  }

  return {
    valid: true,
    sanitized,
  };
}
```

---

## 7. The Main ReAct Loop

```typescript
// src/agent.ts

import Anthropic from "@anthropic-ai/sdk";
import { MessageParam, ToolUseBlock, TextBlock } from "@anthropic-ai/sdk/resources/messages";
import { searchToolDefinition, executeSearch } from "./tools/search";
import { readerToolDefinition, executeFetchPage } from "./tools/reader";
import { validateInput } from "./guards/input";
import { validateOutput } from "./guards/output";
import { ResearchRequest, ResearchReport, AgentRunLog, ToolCall } from "./types";

const client = new Anthropic();

const SYSTEM_PROMPT = `You are a research agent. Your job is to answer research questions
by finding and reading relevant web sources, then synthesizing a clear, well-cited answer.

Process:
1. Use web_search to find relevant sources for the question
2. Use read_page to read the most promising sources
3. Once you have enough information (3-5 good sources), write a research report

Report format:
- A clear answer to the research question (2-4 paragraphs)
- Inline citations as [1], [2], etc.
- A "Sources" section listing each cited source with its URL and title

Rules:
- Always cite your sources — do not state facts without a citation
- Do not reproduce copyrighted text verbatim — summarize and cite
- If you cannot find enough information after several searches, say so honestly
- Prioritize recent, authoritative sources`;

export async function runResearchAgent(
  request: ResearchRequest
): Promise<{ report: ResearchReport; log: AgentRunLog }> {
  const requestId = `req_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;

  // --- Input validation ---
  const validation = validateInput(request.question);
  if (!validation.valid) {
    throw new Error(`Invalid input: ${validation.reason}`);
  }

  const maxIterations = request.maxIterations ?? 10;
  const messages: MessageParam[] = [
    { role: "user", content: request.question },
  ];

  const toolCalls: ToolCall[] = [];
  let totalInputTokens = 0;
  let totalOutputTokens = 0;
  let iterations = 0;

  // --- ReAct loop ---
  while (iterations < maxIterations) {
    iterations++;

    const response = await client.messages.create({
      model: "claude-sonnet-4-5",
      max_tokens: 4096,
      system: SYSTEM_PROMPT,
      tools: [searchToolDefinition, readerToolDefinition],
      messages,
    });

    totalInputTokens += response.usage.input_tokens;
    totalOutputTokens += response.usage.output_tokens;

    // Add assistant turn to conversation history
    messages.push({ role: "assistant", content: response.content });

    // Check if the model is done (no more tool calls)
    if (response.stop_reason === "end_turn") {
      const textBlock = response.content.find(
        (b): b is TextBlock => b.type === "text"
      );
      const rawOutput = textBlock?.text ?? "";

      // --- Output validation ---
      const outputValidation = validateOutput(rawOutput);
      if (!outputValidation.valid) {
        throw new Error(`Output safety check failed: ${outputValidation.reason}`);
      }

      const finalOutput = outputValidation.sanitized ?? rawOutput;
      const costEstimate = estimateCost(totalInputTokens, totalOutputTokens);

      const report: ResearchReport = {
        question: request.question,
        answer: finalOutput,
        sources: extractSources(finalOutput),
        iterationsUsed: iterations,
        totalTokens: totalInputTokens + totalOutputTokens,
        costEstimate,
        generatedAt: new Date().toISOString(),
      };

      const log: AgentRunLog = {
        requestId,
        question: request.question,
        toolCalls,
        totalTokens: totalInputTokens + totalOutputTokens,
        costEstimate,
        outcome: "success",
      };

      return { report, log };
    }

    // Process tool calls
    if (response.stop_reason === "tool_use") {
      const toolResults: MessageParam["content"] = [];

      for (const block of response.content) {
        if (block.type !== "tool_use") continue;

        const toolUse = block as ToolUseBlock;
        const startMs = Date.now();
        let toolOutput: string;

        try {
          if (toolUse.name === "web_search") {
            const results = await executeSearch(
              toolUse.input as { query: string; num_results?: number }
            );
            toolOutput = JSON.stringify(results, null, 2);
          } else if (toolUse.name === "read_page") {
            toolOutput = await executeFetchPage(
              toolUse.input as { url: string }
            );
          } else {
            toolOutput = `[Unknown tool: ${toolUse.name}]`;
          }
        } catch (err) {
          toolOutput = `[Tool error: ${err instanceof Error ? err.message : String(err)}]`;
        }

        const durationMs = Date.now() - startMs;

        toolCalls.push({
          name: toolUse.name,
          input: toolUse.input as Record<string, unknown>,
          output: toolOutput.slice(0, 500), // Truncate for log
          durationMs,
        });

        toolResults.push({
          type: "tool_result",
          tool_use_id: toolUse.id,
          content: toolOutput,
        });
      }

      messages.push({ role: "user", content: toolResults });
    }
  }

  // Iteration limit reached — ask for best-effort summary
  messages.push({
    role: "user",
    content:
      "You have reached the maximum number of tool calls. Please synthesize a research " +
      "report from the information you have gathered so far, even if incomplete.",
  });

  const finalResponse = await client.messages.create({
    model: "claude-sonnet-4-5",
    max_tokens: 4096,
    system: SYSTEM_PROMPT,
    messages,
  });

  totalInputTokens += finalResponse.usage.input_tokens;
  totalOutputTokens += finalResponse.usage.output_tokens;

  const textBlock = finalResponse.content.find(
    (b): b is TextBlock => b.type === "text"
  );
  const rawOutput = textBlock?.text ?? "[No output generated]";
  const outputValidation = validateOutput(rawOutput);
  const finalOutput = outputValidation.sanitized ?? rawOutput;
  const costEstimate = estimateCost(totalInputTokens, totalOutputTokens);

  return {
    report: {
      question: request.question,
      answer: finalOutput,
      sources: extractSources(finalOutput),
      iterationsUsed: iterations,
      totalTokens: totalInputTokens + totalOutputTokens,
      costEstimate,
      generatedAt: new Date().toISOString(),
    },
    log: {
      requestId,
      question: request.question,
      toolCalls,
      totalTokens: totalInputTokens + totalOutputTokens,
      costEstimate,
      outcome: "iteration_limit",
    },
  };
}

// --- Helpers ---

function estimateCost(inputTokens: number, outputTokens: number): number {
  // claude-sonnet-4-5 pricing (update as pricing changes)
  const INPUT_COST_PER_1K = 0.003;
  const OUTPUT_COST_PER_1K = 0.015;
  return (
    (inputTokens / 1000) * INPUT_COST_PER_1K +
    (outputTokens / 1000) * OUTPUT_COST_PER_1K
  );
}

function extractSources(output: string): ResearchReport["sources"] {
  // Extract URLs from the Sources section of the report
  // This is a simple heuristic — adapt to the actual report format
  const sourceSection = output.match(/## Sources[\s\S]*/i)?.[0] ?? "";
  const urlMatches = sourceSection.matchAll(/https?:\/\/[^\s\])"]+/g);
  const sources: ResearchReport["sources"] = [];
  for (const match of urlMatches) {
    sources.push({
      url: match[0],
      title: "", // Could extract with more regex
      summary: "",
      relevanceScore: 1,
    });
  }
  return sources;
}
```

---

## 8. HTTP Server Entry Point

```typescript
// src/index.ts

import { createServer } from "http";
import { runResearchAgent } from "./agent";
import { ResearchRequest } from "./types";

const PORT = parseInt(process.env.PORT ?? "3000", 10);

const server = createServer(async (req, res) => {
  if (req.method === "GET" && req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok" }));
    return;
  }

  if (req.method !== "POST" || req.url !== "/research") {
    res.writeHead(404);
    res.end();
    return;
  }

  let body = "";
  req.on("data", (chunk) => (body += chunk));
  req.on("end", async () => {
    try {
      const request: ResearchRequest = JSON.parse(body);
      const { report, log } = await runResearchAgent(request);

      // Structured audit log
      console.log(JSON.stringify({ event: "research_complete", ...log }));

      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify(report));
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      console.error(JSON.stringify({ event: "research_error", error: message }));
      res.writeHead(400, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: message }));
    }
  });
});

server.listen(PORT, () => {
  console.log(`Research agent listening on :${PORT}`);
});
```

---

## 9. Key Design Decisions Explained

**Why is the system prompt not in a config file?**  
For this simple example it is inline, but in production it should be in a config file with versioning. Changing the system prompt changes agent behavior and should be tracked like code.

**Why truncate page content to 8000 chars?**  
Unbounded page content is the primary cost and latency driver. 8000 chars is enough to extract the key facts from most pages. For longer documents, use a chunking + summarization pass first.

**Why log tool outputs as truncated?**  
Full tool outputs can be enormous (entire web pages). Logs should be queryable. Store full tool outputs in a separate blob store if you need them for debugging, and reference them by ID in the structured log.

**Why not use LangChain?**  
For this scope, the raw Anthropic SDK is simpler, more debuggable, and has fewer abstraction layers that can silently swallow errors. Add a framework when the complexity justifies it.

**Why ReAct and not tool_choice: auto?**  
`tool_choice: auto` is effectively ReAct — the model decides when to call tools and when to stop. The explicit loop here makes the iteration count, cost tracking, and guard application transparent.

---

## 10. Deployment

```dockerfile
# Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json tsconfig.json ./
RUN npm install
COPY src/ ./src/
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package.json ./
RUN npm install --omit=dev
USER node
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**Environment variables required:**

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | Anthropic API key |
| `BRAVE_SEARCH_API_KEY` | Brave Search API key |
| `PORT` | Server port (default 3000) |

**Health check for ECS:**

```json
{
  "command": ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"],
  "interval": 30,
  "timeout": 5,
  "retries": 3
}
```

---

## What to Build Next

1. **Eval suite** — see `worked-example-eval-pipeline.md` for the eval harness
2. **Prompt caching** — cache the system prompt to cut input token costs on repeated requests
3. **Streaming** — stream the final report to improve perceived latency
4. **Citation verification** — add a post-processing step that validates cited URLs are real and still accessible
5. **Rate limiting middleware** — add per-user rate limiting at the HTTP layer
