import type { AgentHarness, UniversalThread } from "@claude-assist/shared";

export interface HarnessTransferRequest {
  sourceHarness: AgentHarness;
  targetHarness: AgentHarness;
  thread: UniversalThread;
}

export interface HarnessTransferResult {
  sourceHarness: AgentHarness;
  targetHarness: AgentHarness;
  payload: unknown;
  warnings: string[];
}

export function exportUniversalThreadToHarness(request: HarnessTransferRequest): HarnessTransferResult {
  switch (request.targetHarness) {
    case "claude":
    case "codex":
      return pendingExport(request, "Exporter is not implemented yet; provider quirks need compatibility tests.");
    case "gemini":
    case "opencode":
    case "aider":
      return pendingExport(request, "TODO: transcript examples are pending; validate target format before exporting.");
    case "other":
      return pendingExport(request, "TODO: user-defined harness export requires an adapter contract.");
  }
}

function pendingExport(request: HarnessTransferRequest, message: string): HarnessTransferResult {
  return {
    sourceHarness: request.sourceHarness,
    targetHarness: request.targetHarness,
    payload: {
      universalThreadId: request.thread.id,
      messages: request.thread.messages,
    },
    warnings: [message],
  };
}
