import React from "react";
import { Box, Text } from "ink";

interface ContentBlock {
  type: "text" | "tool_use" | "tool_result" | "thinking";
  text?: string;
  thinking?: string;
  name?: string;
  input?: Record<string, unknown>;
  content?: string;
  is_error?: boolean;
}

interface ContentBlockViewProps {
  block: ContentBlock;
  expanded?: boolean;
}

export function ContentBlockView({ block, expanded = false }: ContentBlockViewProps) {
  switch (block.type) {
    case "text":
      return <Text wrap="wrap">{block.text ?? ""}</Text>;

    case "thinking":
      if (!expanded) {
        return (
          <Text dimColor italic>
            {"  "}[thinking: {(block.thinking ?? "").slice(0, 60)}...]
          </Text>
        );
      }
      return (
        <Box flexDirection="column" marginLeft={2} borderStyle="single" borderColor="gray" paddingX={1}>
          <Text dimColor bold>Thinking:</Text>
          <Text dimColor wrap="wrap">{block.thinking ?? ""}</Text>
        </Box>
      );

    case "tool_use":
      return (
        <Box flexDirection="column" marginLeft={2}>
          <Text color="yellow">
            {"  "}⚙ {block.name ?? "tool"}
          </Text>
          {block.input && (
            <Text dimColor wrap="wrap">
              {"    "}{formatToolInput(block.input)}
            </Text>
          )}
        </Box>
      );

    case "tool_result": {
      const content = block.content ?? "";
      const preview = expanded ? content : content.slice(0, 200);
      return (
        <Box flexDirection="column" marginLeft={2}>
          <Text color={block.is_error ? "red" : "green"}>
            {"  "}{block.is_error ? "✗" : "✓"} result
            {!expanded && content.length > 200 && <Text dimColor> (+{content.length - 200} chars)</Text>}
          </Text>
          {preview && <Text dimColor wrap="wrap">{"    "}{preview}</Text>}
        </Box>
      );
    }

    default:
      return <Text dimColor>[{block.type}]</Text>;
  }
}

function formatToolInput(input: Record<string, unknown>): string {
  if ("command" in input && typeof input.command === "string") {
    return `$ ${input.command}`;
  }
  if ("file_path" in input && typeof input.file_path === "string") {
    return input.file_path;
  }
  const json = JSON.stringify(input);
  return json.length > 120 ? json.slice(0, 120) + "..." : json;
}
