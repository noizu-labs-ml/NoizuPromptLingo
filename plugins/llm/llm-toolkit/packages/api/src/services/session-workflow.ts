import type { AgentHarness, UniversalMessage } from "@llm-toolkit/shared";
import { exportUniversalToHarness, isHarnessExportSupported } from "./harness-transform.ts";

export type ContinuationIntent = "continue" | "transfer";
export type ExportReadiness = "ready" | "stub";

export interface MemoryHookStub {
  status: "planned";
  todo: string;
}

export interface ContinuationRequest {
  sourceHarness: AgentHarness;
  targetHarness?: AgentHarness;
  messages: UniversalMessage[];
  title?: string;
  intent?: ContinuationIntent;
}

export interface ContinuationPayload {
  intent: ContinuationIntent;
  sourceHarness: AgentHarness;
  targetHarness: AgentHarness;
  readiness: ExportReadiness;
  title?: string;
  messageCount: number;
  universalMessages: UniversalMessage[];
  harnessPayload: unknown;
  memoryHooks: {
    sessionSummary: MemoryHookStub;
    durableFacts: MemoryHookStub;
    openTasks: MemoryHookStub;
  };
  warnings: string[];
}

// ⟦𓉠𓐀𓈾𓁾⟧ prepareContinuationPayload :: auto-generated pointer for public function prepareContinuationPayload
export function prepareContinuationPayload(request: ContinuationRequest): ContinuationPayload {
  const targetHarness = request.targetHarness ?? request.sourceHarness;
  const intent = request.intent ?? (targetHarness === request.sourceHarness ? "continue" : "transfer");
  const readiness: ExportReadiness = isHarnessExportSupported(targetHarness) ? "ready" : "stub";
  const warnings = readiness === "stub"
    ? [`${targetHarness} export is stubbed until real transcript samples are available.`]
    : [];

  return {
    intent,
    sourceHarness: request.sourceHarness,
    targetHarness,
    readiness,
    title: request.title,
    messageCount: request.messages.length,
    universalMessages: request.messages,
    harnessPayload: exportForHarness(targetHarness, request.messages, request.title),
    memoryHooks: createMemoryHookStubs(),
    warnings,
  };
}

function exportForHarness(targetHarness: AgentHarness, messages: UniversalMessage[], title?: string): unknown {
  if (isHarnessExportSupported(targetHarness)) {
    return exportUniversalToHarness({
      targetHarness,
      thread: {
        id: title ?? "continuation",
        title: title ?? "Continuation",
        messages,
        providerMetadata: {},
      },
    });
  }

  return {
    format: `${targetHarness}-continuation-stub`,
    title,
    todo: "Validate real transcript shape before enabling this exporter.",
    universalMessages: messages,
  };
}

function createMemoryHookStubs(): ContinuationPayload["memoryHooks"] {
  return {
    sessionSummary: {
      status: "planned",
      todo: "Requires memory extraction architecture before generating durable session summaries.",
    },
    durableFacts: {
      status: "planned",
      todo: "Requires policy for what facts may be retained across harnesses.",
    },
    openTasks: {
      status: "planned",
      todo: "Requires task extraction and review workflow before continuation injection.",
    },
  };
}
