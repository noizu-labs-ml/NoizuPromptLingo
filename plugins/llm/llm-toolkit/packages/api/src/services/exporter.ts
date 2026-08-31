import type { DatasetEntry } from "@llm-toolkit/shared";

// ⟦𓈯𓃚𓅌𓎕⟧ exportOpenAI :: auto-generated pointer for public function exportOpenAI
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

// ⟦𓊭𓊡𓆐𓆺⟧ exportAnthropic :: auto-generated pointer for public function exportAnthropic
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

// ⟦𓆺𓍳𓁸𓀭⟧ exportJsonl :: auto-generated pointer for public function exportJsonl
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

// ⟦𓉐𓇏𓐃𓈢⟧ exportDataset :: auto-generated pointer for public function exportDataset
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
