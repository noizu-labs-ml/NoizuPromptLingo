import { describe, test, expect } from "vitest";
import { applyOperations, type EditOperation } from "../../services/editor.ts";

const messages = [
  { role: "user", content: "Hello" },
  { role: "assistant", content: "Hi there" },
  { role: "user", content: "How are you?" },
  { role: "assistant", content: "I'm good" },
  { role: "user", content: "Goodbye" },
];

describe("applyOperations", () => {
  test("remove deletes specified indices", () => {
    const ops: EditOperation[] = [{ type: "remove", indices: [1, 3] }];
    const result = applyOperations(messages, ops);
    expect(result).toHaveLength(3);
    expect(result[0].content).toBe("Hello");
    expect(result[1].content).toBe("How are you?");
    expect(result[2].content).toBe("Goodbye");
  });

  test("collapse merges a range into a single summary", () => {
    const ops: EditOperation[] = [{ type: "collapse", startIndex: 1, endIndex: 3, summary: "Exchanged greetings" }];
    const result = applyOperations(messages, ops);
    expect(result).toHaveLength(3);
    expect(result[0].content).toBe("Hello");
    expect(result[1].content).toBe("Exchanged greetings");
    expect(result[1].collapsed).toBe(true);
    expect(result[2].content).toBe("Goodbye");
  });

  test("inject adds a message at the specified position", () => {
    const ops: EditOperation[] = [{ type: "inject", atIndex: 2, role: "system", content: "Context note" }];
    const result = applyOperations(messages, ops);
    expect(result).toHaveLength(6);
    expect(result[2].content).toBe("Context note");
    expect(result[2].injected).toBe(true);
    expect(result[2].role).toBe("system");
  });

  test("reorder rearranges messages by index", () => {
    const ops: EditOperation[] = [{ type: "reorder", newOrder: [4, 3, 2, 1, 0] }];
    const result = applyOperations(messages, ops);
    expect(result[0].content).toBe("Goodbye");
    expect(result[4].content).toBe("Hello");
  });

  test("reorder with invalid length is a no-op", () => {
    const ops: EditOperation[] = [{ type: "reorder", newOrder: [0, 1] }];
    const result = applyOperations(messages, ops);
    expect(result).toHaveLength(5);
    expect(result[0].content).toBe("Hello");
  });

  test("multiple operations compose correctly", () => {
    const ops: EditOperation[] = [
      { type: "remove", indices: [4] },
      { type: "inject", atIndex: 0, role: "system", content: "Preamble" },
    ];
    const result = applyOperations(messages, ops);
    expect(result).toHaveLength(5);
    expect(result[0].content).toBe("Preamble");
    expect(result[0].injected).toBe(true);
  });

  test("collapse with invalid range is a no-op", () => {
    const ops: EditOperation[] = [{ type: "collapse", startIndex: 3, endIndex: 1, summary: "Bad range" }];
    const result = applyOperations(messages, ops);
    expect(result).toHaveLength(5);
  });

  test("preserves originalIndex from source", () => {
    const ops: EditOperation[] = [{ type: "remove", indices: [0] }];
    const result = applyOperations(messages, ops);
    expect(result[0].originalIndex).toBe(1);
  });
});
