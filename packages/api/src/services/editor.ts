import type { EditedMessage } from "@claude-assist/shared";

export type EditOperation =
  | { type: "collapse"; startIndex: number; endIndex: number; summary: string }
  | { type: "remove"; indices: number[] }
  | { type: "reorder"; newOrder: number[] }
  | { type: "inject"; atIndex: number; role: "user" | "assistant" | "system"; content: string };

interface SourceMessage {
  role: string;
  content: string;
}

export function applyOperations(
  messages: SourceMessage[],
  operations: EditOperation[],
): EditedMessage[] {
  let result: EditedMessage[] = messages.map((m, i) => ({
    originalIndex: i,
    role: m.role as EditedMessage["role"],
    content: m.content,
  }));

  for (const op of operations) {
    result = applyOperation(result, op);
  }

  return result;
}

function applyOperation(messages: EditedMessage[], op: EditOperation): EditedMessage[] {
  switch (op.type) {
    case "collapse":
      return collapseMessages(messages, op.startIndex, op.endIndex, op.summary);
    case "remove":
      return removeMessages(messages, op.indices);
    case "reorder":
      return reorderMessages(messages, op.newOrder);
    case "inject":
      return injectMessage(messages, op.atIndex, op.role, op.content);
  }
}

function collapseMessages(
  messages: EditedMessage[],
  startIndex: number,
  endIndex: number,
  summary: string,
): EditedMessage[] {
  if (startIndex < 0 || endIndex >= messages.length || startIndex > endIndex) {
    return messages;
  }

  const before = messages.slice(0, startIndex);
  const collapsed: EditedMessage = {
    originalIndex: messages[startIndex].originalIndex,
    role: "system",
    content: summary,
    collapsed: true,
  };
  const after = messages.slice(endIndex + 1);

  return [...before, collapsed, ...after];
}

function removeMessages(messages: EditedMessage[], indices: number[]): EditedMessage[] {
  const removeSet = new Set(indices);
  return messages.filter((_, i) => !removeSet.has(i));
}

function reorderMessages(messages: EditedMessage[], newOrder: number[]): EditedMessage[] {
  if (newOrder.length !== messages.length) return messages;
  const valid = newOrder.every((i) => i >= 0 && i < messages.length);
  if (!valid) return messages;
  return newOrder.map((i) => messages[i]);
}

function injectMessage(
  messages: EditedMessage[],
  atIndex: number,
  role: EditedMessage["role"],
  content: string,
): EditedMessage[] {
  const injected: EditedMessage = { role, content, injected: true };
  const clamped = Math.max(0, Math.min(atIndex, messages.length));
  const result = [...messages];
  result.splice(clamped, 0, injected);
  return result;
}
