import React from "react";
import { Box, Text } from "ink";
import { ContentBlockView } from "./ContentBlockView.js";

interface ContentBlock {
  type: "text" | "tool_use" | "tool_result" | "thinking";
  text?: string;
  thinking?: string;
  name?: string;
  input?: Record<string, unknown>;
  content?: string;
  is_error?: boolean;
}

interface ThreadRecord {
  type: string;
  uuid: string;
  timestamp: string;
  isSidechain?: boolean;
  message: {
    role: string;
    content: string | ContentBlock[];
    model?: string;
    usage?: {
      input_tokens: number;
      output_tokens: number;
    };
  };
}

interface MessageBlockProps {
  record: ThreadRecord;
  index: number;
  isCursor: boolean;
  expandThinking?: boolean;
  showRaw?: boolean;
}

export function MessageBlock({ record, index, isCursor, expandThinking = false, showRaw = false }: MessageBlockProps) {
  const isUser = record.message.role === "user";
  const time = record.timestamp?.slice(11, 19) ?? "";
  const content = record.message.content;

  if (showRaw) {
    return (
      <Box flexDirection="column" marginBottom={1}>
        <Text bold color={isUser ? "cyan" : "white"}>
          {isCursor ? "▸" : " "} {isUser ? "You" : "Assistant"} <Text dimColor>{time}</Text>
        </Text>
        <Text dimColor wrap="wrap">{"  "}{JSON.stringify(record, null, 2)}</Text>
      </Box>
    );
  }

  return (
    <Box flexDirection="column" marginBottom={1}>
      <Text bold color={isUser ? "cyan" : "white"}>
        {isCursor ? "▸" : " "} {isUser ? "You" : "Assistant"}
        <Text dimColor> {time}</Text>
        {record.message.usage && (
          <Text dimColor> [{record.message.usage.input_tokens}+{record.message.usage.output_tokens} tok]</Text>
        )}
        {record.isSidechain && <Text color="yellow"> [sidechain]</Text>}
      </Text>

      {typeof content === "string" ? (
        <Text wrap="wrap">{"  "}{content}</Text>
      ) : (
        Array.isArray(content) && content.map((block, bi) => (
          <ContentBlockView
            key={bi}
            block={block}
            expanded={expandThinking}
          />
        ))
      )}
    </Box>
  );
}

export type { ThreadRecord, ContentBlock };
