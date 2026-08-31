import React from "react";
import { Box, Text } from "ink";
import { useTerminalSize } from "../hooks/useTerminalSize.js";

type PreviewMode = "both" | "first" | "last" | "none";

interface ConversationRowProps {
  id: string;
  harness?: string;
  title: string;
  projectPath: string;
  messageCount?: number;
  startedAt?: string;
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

function cleanPreview(text: string): string {
  return stripToolUse(text).replace(/<<</g, "").replace(/>>>/g, "").replace(/\s+/g, " ").trim();
}

function formatDateTime(value?: string): string {
  if (!value) return "unknown";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleString();
}

// ⟦𓌓𓆗𓎯𓊴⟧ ConversationRow :: auto-generated pointer for public function ConversationRow
export function ConversationRow({
  id,
  harness,
  title,
  projectPath,
  messageCount,
  startedAt,
  updatedAt,
  status,
  snippet,
  firstMessage,
  lastMessage,
  previewMode = "none",
  isCursor,
}: ConversationRowProps) {
  const { columns } = useTerminalSize();
  const shortProject = projectPath.split("/").filter(Boolean).slice(-2).join("/");
  const divider = "─".repeat(Math.max(16, Math.min(120, columns - 28)));
  const header = `${shortProject} | ${title || "Untitled"} | ${id.slice(0, 8)} | ${messageCount ?? 0} messages | first ${formatDateTime(startedAt)} | last ${formatDateTime(updatedAt)}`;
  const statusLine = [
    harness ? `harness ${harness}` : undefined,
    status && status !== "active" ? `status ${status}` : undefined,
    projectPath,
  ].filter(Boolean).join(" | ");
  const bodyLines = snippet
    ? [{ label: "Match", color: "cyan" as const, text: cleanPreview(snippet) }]
    : [
      (previewMode === "both" || previewMode === "first") && firstMessage
        ? { label: "User", color: "green" as const, text: cleanPreview(firstMessage) }
        : undefined,
      (previewMode === "both" || previewMode === "last") && lastMessage
        ? { label: "Agent", color: "yellow" as const, text: cleanPreview(lastMessage) }
        : undefined,
    ].filter((line): line is { label: string; color: "green" | "yellow"; text: string } => Boolean(line));

  const content = (
    <Box flexDirection="column">
      <Text wrap="truncate-end">
        {isCursor && <Text color="white" bold>✓ </Text>}
        <Text color={isCursor ? "white" : "cyan"} bold>{header}</Text>
      </Text>
      {statusLine && <Text dimColor={!isCursor} color={isCursor ? "white" : undefined} wrap="truncate-end">  {statusLine}</Text>}
      {bodyLines.map((line, index) => (
        <Text key={index} wrap="truncate-end">
          {"  "}
          <Text color={line.color} bold>{line.label}:</Text>
          {" "}
          <Text color={isCursor ? "white" : undefined} dimColor={!isCursor}>{line.text}</Text>
        </Text>
      ))}
    </Box>
  );

  return (
    <Box flexDirection="column">
      {isCursor ? (
        <Box flexDirection="column" borderStyle="single" borderColor="cyan" paddingX={1}>
          {content}
        </Box>
      ) : (
        content
      )}
      <Text dimColor>{divider}</Text>
    </Box>
  );
}
