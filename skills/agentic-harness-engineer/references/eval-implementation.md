# Eval Implementation

End-to-end TypeScript pipeline for building, running, scoring, and reporting evals for agentic systems.

## Core Interfaces

```typescript
interface EvalCase {
  id: string;
  input: string;                          // user message or prompt
  expectedOutput?: string;                // for exact/fuzzy match scorers
  expectedToolCalls?: ToolCallExpectation[];
  tags: string[];                         // for filtering (e.g., ["injection", "coding"])
  metadata: Record<string, unknown>;
}

interface ToolCallExpectation {
  name: string;
  parametersMatch?: Record<string, unknown>; // subset match
  mustBeCalled: boolean;
}

interface EvalResult {
  caseId: string;
  runId: string;
  score: number;           // 0-1
  passed: boolean;
  scorerResults: ScorerResult[];
  actualOutput: string;
  actualToolCalls?: ToolCall[];
  latencyMs: number;
  tokenUsage: { input: number; output: number };
  error?: string;
}

interface ScorerResult {
  scorerName: string;
  score: number;
  reasoning?: string;
  details?: Record<string, unknown>;
}
```

---

## Dataset Loading (JSONL)

```typescript
import { createReadStream } from "fs";
import { createInterface } from "readline";

async function loadDataset(filePath: string): Promise<EvalCase[]> {
  const cases: EvalCase[] = [];
  const rl = createInterface({ input: createReadStream(filePath) });

  for await (const line of rl) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("//")) continue; // skip comments

    try {
      const parsed = JSON.parse(trimmed);
      cases.push(validateEvalCase(parsed));
    } catch (err) {
      console.warn(`Skipping malformed line: ${trimmed.slice(0, 80)}`, err);
    }
  }

  return cases;
}

function validateEvalCase(raw: unknown): EvalCase {
  if (typeof raw !== "object" || raw === null) throw new Error("Not an object");
  const r = raw as Record<string, unknown>;
  if (typeof r.id !== "string") throw new Error("Missing id");
  if (typeof r.input !== "string") throw new Error("Missing input");
  return {
    id: r.id,
    input: r.input,
    expectedOutput: typeof r.expectedOutput === "string" ? r.expectedOutput : undefined,
    expectedToolCalls: Array.isArray(r.expectedToolCalls) ? r.expectedToolCalls : [],
    tags: Array.isArray(r.tags) ? r.tags : [],
    metadata: typeof r.metadata === "object" && r.metadata ? r.metadata : {},
  } as EvalCase;
}

// Sample JSONL format:
// {"id": "t001", "input": "What is 2+2?", "expectedOutput": "4", "tags": ["math"]}
// {"id": "t002", "input": "Search for climate news", "expectedToolCalls": [{"name": "web_search", "mustBeCalled": true}], "tags": ["tool_use"]}
```

---

## Scorer Interfaces and Implementations

### Exact Match Scorer

```typescript
interface Scorer {
  name: string;
  score(evalCase: EvalCase, actualOutput: string, toolCalls?: ToolCall[]): Promise<ScorerResult>;
}

class ExactMatchScorer implements Scorer {
  name = "exact_match";

  async score(evalCase: EvalCase, actualOutput: string): Promise<ScorerResult> {
    if (!evalCase.expectedOutput) {
      return { scorerName: this.name, score: 0, reasoning: "No expected output defined" };
    }
    const normalizedExpected = evalCase.expectedOutput.trim().toLowerCase();
    const normalizedActual = actualOutput.trim().toLowerCase();
    const match = normalizedExpected === normalizedActual;
    return {
      scorerName: this.name,
      score: match ? 1 : 0,
      reasoning: match ? "Exact match" : `Expected: "${normalizedExpected}", got: "${normalizedActual}"`,
    };
  }
}
```

### LLM-as-Judge Scorer

```typescript
interface LLMJudgeConfig {
  model: string;
  rubric: string;
  callLLM: (prompt: string) => Promise<string>;
  parseScore: (response: string) => number; // extract 0-1 from judge response
}

class LLMJudgeScorer implements Scorer {
  name = "llm_judge";

  constructor(private config: LLMJudgeConfig) {}

  async score(evalCase: EvalCase, actualOutput: string): Promise<ScorerResult> {
    const prompt = `
You are an evaluator. Score the following response on a scale of 0-10.

RUBRIC:
${this.config.rubric}

QUESTION: ${evalCase.input}
${evalCase.expectedOutput ? `REFERENCE ANSWER: ${evalCase.expectedOutput}` : ""}
ACTUAL RESPONSE: ${actualOutput}

Respond with JSON: {"score": <0-10>, "reasoning": "<brief explanation>"}
`.trim();

    const response = await this.config.callLLM(prompt);

    try {
      const parsed = JSON.parse(response.match(/\{[\s\S]*\}/)?.[0] ?? "{}");
      const rawScore = typeof parsed.score === "number" ? parsed.score : 0;
      return {
        scorerName: this.name,
        score: Math.min(1, Math.max(0, rawScore / 10)),
        reasoning: parsed.reasoning ?? "No reasoning provided",
      };
    } catch {
      return { scorerName: this.name, score: 0, reasoning: "Failed to parse judge response" };
    }
  }
}
```

### Embedding Similarity Scorer

```typescript
class EmbeddingSimilarityScorer implements Scorer {
  name = "embedding_similarity";

  constructor(
    private embedFn: (text: string) => Promise<number[]>,
    private threshold = 0.85
  ) {}

  async score(evalCase: EvalCase, actualOutput: string): Promise<ScorerResult> {
    if (!evalCase.expectedOutput) {
      return { scorerName: this.name, score: 0, reasoning: "No expected output" };
    }

    const [expectedEmb, actualEmb] = await Promise.all([
      this.embedFn(evalCase.expectedOutput),
      this.embedFn(actualOutput),
    ]);

    const similarity = cosineSimilarity(expectedEmb, actualEmb);
    return {
      scorerName: this.name,
      score: similarity,
      reasoning: `Cosine similarity: ${similarity.toFixed(3)} (threshold: ${this.threshold})`,
      details: { similarity, threshold: this.threshold },
    };
  }
}

function cosineSimilarity(a: number[], b: number[]): number {
  const dot = a.reduce((s, ai, i) => s + ai * b[i], 0);
  return dot / (Math.sqrt(a.reduce((s, ai) => s + ai * ai, 0)) * Math.sqrt(b.reduce((s, bi) => s + bi * bi, 0)));
}
```

### Tool Call Match Scorer

```typescript
class ToolCallMatchScorer implements Scorer {
  name = "tool_call_match";

  async score(evalCase: EvalCase, _output: string, toolCalls?: ToolCall[]): Promise<ScorerResult> {
    const expected = evalCase.expectedToolCalls ?? [];
    if (expected.length === 0) return { scorerName: this.name, score: 1, reasoning: "No tool expectations" };

    const actual = toolCalls ?? [];
    let matched = 0;

    for (const exp of expected) {
      const found = actual.find((a) => a.name === exp.name);
      if (!found && exp.mustBeCalled) continue; // miss
      if (found) {
        if (exp.parametersMatch) {
          const allMatch = Object.entries(exp.parametersMatch).every(
            ([k, v]) => (found.parameters as Record<string, unknown>)[k] === v
          );
          if (allMatch) matched++;
        } else {
          matched++;
        }
      }
    }

    const score = expected.length > 0 ? matched / expected.length : 1;
    return {
      scorerName: this.name,
      score,
      reasoning: `${matched}/${expected.length} expected tool calls matched`,
      details: { matched, total: expected.length },
    };
  }
}
```

---

## Eval Runner

```typescript
interface EvalRunConfig {
  runId: string;
  datasetPath: string;
  tagFilter?: string[];          // run only cases with these tags
  concurrency: number;
  scorers: Scorer[];
  callAgent: (input: string) => Promise<{ output: string; toolCalls?: ToolCall[]; usage: { input: number; output: number } }>;
  onProgress?: (completed: number, total: number) => void;
}

async function runEval(config: EvalRunConfig): Promise<EvalResult[]> {
  const cases = await loadDataset(config.datasetPath);
  const filtered = config.tagFilter
    ? cases.filter((c) => config.tagFilter!.some((t) => c.tags.includes(t)))
    : cases;

  const results: EvalResult[] = [];
  const queue = [...filtered];
  let completed = 0;

  async function processCase(evalCase: EvalCase): Promise<EvalResult> {
    const start = Date.now();
    let actualOutput = "";
    let actualToolCalls: ToolCall[] | undefined;
    let tokenUsage = { input: 0, output: 0 };
    let error: string | undefined;

    try {
      const response = await config.callAgent(evalCase.input);
      actualOutput = response.output;
      actualToolCalls = response.toolCalls;
      tokenUsage = response.usage;
    } catch (err) {
      error = err instanceof Error ? err.message : String(err);
    }

    const scorerResults = await Promise.all(
      config.scorers.map((s) => s.score(evalCase, actualOutput, actualToolCalls).catch((e) => ({
        scorerName: s.name,
        score: 0,
        reasoning: `Scorer error: ${e.message}`,
      })))
    );

    const score = scorerResults.length > 0
      ? scorerResults.reduce((s, r) => s + r.score, 0) / scorerResults.length
      : 0;

    return {
      caseId: evalCase.id,
      runId: config.runId,
      score,
      passed: score >= 0.7,
      scorerResults,
      actualOutput,
      actualToolCalls,
      latencyMs: Date.now() - start,
      tokenUsage,
      error,
    };
  }

  // Process with concurrency limit
  const workers = Array.from({ length: config.concurrency }, async () => {
    while (queue.length > 0) {
      const evalCase = queue.shift()!;
      const result = await processCase(evalCase);
      results.push(result);
      completed++;
      config.onProgress?.(completed, filtered.length);
    }
  });

  await Promise.all(workers);
  return results;
}
```

---

## Result Aggregation

```typescript
interface EvalSummary {
  runId: string;
  totalCases: number;
  passed: number;
  failed: number;
  passRate: number;
  avgScore: number;
  avgLatencyMs: number;
  totalTokens: number;
  scorerBreakdown: Record<string, { avgScore: number; count: number }>;
  tagBreakdown: Record<string, { passed: number; total: number; passRate: number }>;
}

function aggregateResults(results: EvalResult[], cases: EvalCase[]): EvalSummary {
  const caseMap = new Map(cases.map((c) => [c.id, c]));
  const tagBreakdown: Record<string, { passed: number; total: number; passRate: number }> = {};
  const scorerTotals: Record<string, { sum: number; count: number }> = {};

  for (const r of results) {
    const evalCase = caseMap.get(r.caseId);
    for (const tag of evalCase?.tags ?? []) {
      if (!tagBreakdown[tag]) tagBreakdown[tag] = { passed: 0, total: 0, passRate: 0 };
      tagBreakdown[tag].total++;
      if (r.passed) tagBreakdown[tag].passed++;
    }
    for (const sr of r.scorerResults) {
      if (!scorerTotals[sr.scorerName]) scorerTotals[sr.scorerName] = { sum: 0, count: 0 };
      scorerTotals[sr.scorerName].sum += sr.score;
      scorerTotals[sr.scorerName].count++;
    }
  }

  for (const tag of Object.keys(tagBreakdown)) {
    tagBreakdown[tag].passRate = tagBreakdown[tag].passed / tagBreakdown[tag].total;
  }

  const passed = results.filter((r) => r.passed).length;
  return {
    runId: results[0]?.runId ?? "unknown",
    totalCases: results.length,
    passed,
    failed: results.length - passed,
    passRate: passed / results.length,
    avgScore: results.reduce((s, r) => s + r.score, 0) / results.length,
    avgLatencyMs: results.reduce((s, r) => s + r.latencyMs, 0) / results.length,
    totalTokens: results.reduce((s, r) => s + r.tokenUsage.input + r.tokenUsage.output, 0),
    scorerBreakdown: Object.fromEntries(
      Object.entries(scorerTotals).map(([k, v]) => [k, { avgScore: v.sum / v.count, count: v.count }])
    ),
    tagBreakdown,
  };
}
```

---

## CI Integration

```typescript
// ci-eval.ts — exit code drives CI pass/fail
async function runCiEval(): Promise<void> {
  const results = await runEval({
    runId: `ci-${Date.now()}`,
    datasetPath: process.env.EVAL_DATASET ?? "./evals/dataset.jsonl",
    concurrency: 4,
    scorers: [new ExactMatchScorer(), new ToolCallMatchScorer()],
    callAgent: async (input) => {
      // wire your agent here
      throw new Error("Not implemented");
    },
    onProgress: (c, t) => process.stderr.write(`\rProgress: ${c}/${t}`),
  });

  const cases = await loadDataset(process.env.EVAL_DATASET ?? "./evals/dataset.jsonl");
  const summary = aggregateResults(results, cases);

  console.log(JSON.stringify(summary, null, 2));

  const MIN_PASS_RATE = parseFloat(process.env.MIN_PASS_RATE ?? "0.9");
  if (summary.passRate < MIN_PASS_RATE) {
    console.error(`\nFAIL: Pass rate ${(summary.passRate * 100).toFixed(1)}% < required ${MIN_PASS_RATE * 100}%`);
    process.exit(1);
  }

  console.log(`\nPASS: ${(summary.passRate * 100).toFixed(1)}% pass rate`);
}

runCiEval().catch((err) => { console.error(err); process.exit(1); });
```
