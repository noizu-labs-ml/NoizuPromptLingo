import type { DatasetEntry } from "@claude-assist/shared";

export function exportOpenAI(entries: DatasetEntry[]): string {
  return entries
    .map((entry) => {
      const messages = [];
      if (entry.systemPrompt) {
        messages.push({ role: "system", content: entry.systemPrompt });
      }
      messages.push(...entry.messages);
      return JSON.stringify({ messages });
    })
    .join("\n");
}

export function exportAnthropic(entries: DatasetEntry[]): string {
  return entries
    .map((entry) => {
      const system = entry.systemPrompt ?? undefined;
      const messages = entry.messages.map((m) => ({
        role: m.role === "system" ? "user" : m.role,
        content: m.content,
      }));
      return JSON.stringify({ system, messages });
    })
    .join("\n");
}

export function exportJsonl(entries: DatasetEntry[]): string {
  return entries
    .map((entry) => {
      return JSON.stringify({
        id: entry.id,
        dataset: entry.datasetName,
        conversation_id: entry.conversationId,
        quality: entry.quality,
        system_prompt: entry.systemPrompt ?? null,
        messages: entry.messages,
      });
    })
    .join("\n");
}

export function exportDataset(entries: DatasetEntry[], format: string): string {
  switch (format) {
    case "openai":
      return exportOpenAI(entries);
    case "anthropic":
      return exportAnthropic(entries);
    default:
      return exportJsonl(entries);
  }
}
