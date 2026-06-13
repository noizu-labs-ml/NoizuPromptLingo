import React from "react";
import { Box, Text } from "ink";

type PreviewMode = "both" | "first" | "last" | "none";

interface ConversationRowProps {
  id: string;
  title: string;
  projectPath: string;
  messageCount?: number;
  updatedAt?: string;
  status?: string;
  snippet?: string;
  firstMessage?: string;
  lastMessage?: string;
  previewMode?: PreviewMode;
  isCursor: boolean;
}

function stripToolUse(text: string): string {
  const cleaned = text.replace(/^\{"type":"tool_use".*?"name":"[^"]*","input":\{.*?\}\}/, "").trim();
  return cleaned || text.slice(0, 80);
}

export function ConversationRow({
  id,
  title,
  projectPath,
  messageCount,
  updatedAt,
  status,
  snippet,
  firstMessage,
  lastMessage,
  previewMode = "none",
  isCursor,
}: ConversationRowProps) {
  const shortProject = projectPath.split("/").filter(Boolean).slice(-2).join("/");
  const dateStr = updatedAt ? new Date(updatedAt).toLocaleDateString() : "";

  return (
    <Box flexDirection="column">
      <Text inverse={isCursor}>
        <Text color={isCursor ? "cyan" : undefined}>
          {isCursor ? "▸ " : "  "}
        </Text>
        <Text dimColor>{id.slice(0, 8)}</Text>
        {" "}
        <Text color="cyan" dimColor>[{shortProject}]</Text>
        {" "}
        <Text bold={isCursor}>
          {title.startsWith("/") ? (
            <><Text color="cyan">{title.split(" ")[0]}</Text> {title.split(" ").slice(1).join(" ")}</>
          ) : title}
        </Text>
        {messageCount != null && <Text dimColor> ({messageCount} msgs)</Text>}
        {dateStr && <Text dimColor> {dateStr}</Text>}
        {status && status !== "active" && <Text dimColor> [{status}]</Text>}
      </Text>
      {snippet && (
        <Text dimColor wrap="truncate-end">
          {"    "}{snippet.replace(/<<</g, "").replace(/>>>/g, "")}
        </Text>
      )}
      {!snippet && previewMode !== "none" && (
        <>
          {(previewMode === "both" || previewMode === "first") && firstMessage && (
            <Text dimColor wrap="truncate-end">
              {"    ▸ "}{stripToolUse(firstMessage)}
            </Text>
          )}
          {(previewMode === "both" || previewMode === "last") && lastMessage && (
            <Text dimColor wrap="truncate-end">
              {"    ◂ "}{stripToolUse(lastMessage)}
            </Text>
          )}
        </>
      )}
    </Box>
  );
}
