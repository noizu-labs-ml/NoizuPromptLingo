import React, { useEffect, useMemo, useState } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import {
  buildContinuationPayload,
  buildResumeCommand,
  buildTransferPrompt,
  fetchUniversalConversation,
  normalizeHarness,
  transferTargets,
  type SessionHarness,
  type UniversalConversation,
} from "../services/sessionWorkflow.js";

type ViewMode = "continuation" | "universal" | "raw";

const VIEW_MODES: ViewMode[] = ["continuation", "universal", "raw"];

// ⟦𓍛𓄓𓁢𓀚⟧ ContinueSessionPage :: auto-generated pointer for public function ContinueSessionPage
export function ContinueSessionPage() {
  const { current, navigate, goBack } = useRouter();
  const id = current.params.id;
  const { rows } = useTerminalSize();

  const [conversation, setConversation] = useState<UniversalConversation | null>(null);
  const [targetHarness, setTargetHarness] = useState<SessionHarness>("claude");
  const [viewMode, setViewMode] = useState<ViewMode>("continuation");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!id) return;
    setLoading(true);
    fetchUniversalConversation(id)
      .then((result) => {
        setConversation(result);
        setTargetHarness(normalizeHarness(result.harness));
        setLoading(false);
      })
      .catch((err) => {
        setError(err instanceof Error ? err.message : "Failed to load universal transcript");
        setLoading(false);
      });
  }, [id]);

  const payload = useMemo(
    () => conversation ? buildContinuationPayload(conversation, targetHarness) : null,
    [conversation, targetHarness],
  );
  const transferPrompt = useMemo(() => payload ? buildTransferPrompt(payload) : "", [payload]);
  const resumeCommand = conversation ? buildResumeCommand(conversation) : null;
  const selectedTarget = transferTargets.find((target) => target.harness === targetHarness) ?? transferTargets[0];
  const previewContent = payload
    ? viewMode === "continuation"
      ? transferPrompt
      : viewMode === "universal"
        ? JSON.stringify(payload, null, 2)
        : JSON.stringify(conversation?.rawEvents ?? [], null, 2)
    : "";
  const lines = previewContent.split("\n");
  const contentHeight = Math.max(5, rows - 18);
  const scroll = useScroll({
    totalItems: lines.length,
    viewportHeight: contentHeight,
    isActive: Boolean(payload),
  });

  useInput((input, key) => {
    if (key.escape || input === "b") {
      goBack();
    } else if (input === "t") {
      const currentIndex = transferTargets.findIndex((target) => target.harness === targetHarness);
      const next = transferTargets[(currentIndex + 1) % transferTargets.length];
      setTargetHarness(next.harness);
      scroll.setCursor(0);
    } else if (input === "m") {
      const currentIndex = VIEW_MODES.indexOf(viewMode);
      setViewMode(VIEW_MODES[(currentIndex + 1) % VIEW_MODES.length]);
      scroll.setCursor(0);
    } else if (input === "r" && conversation) {
      navigate("thread", { id: conversation.id });
    }
  }, { isActive: true });

  if (loading) return <Spinner label="Loading continuation workspace..." />;
  if (error || !conversation || !payload) {
    return (
      <Box flexDirection="column">
        <Text color="red">{error ?? "Conversation not found"}</Text>
        <Text dimColor>b/Esc:back</Text>
      </Box>
    );
  }

  const canNativeResume = Boolean(resumeCommand && conversation.harness === targetHarness);

  return (
    <Box flexDirection="column">
      <Box flexDirection="column" borderStyle="single" borderColor="cyan" paddingX={1} marginBottom={1}>
        <Text bold color="cyan">{conversation.title}</Text>
        <Text dimColor>
          <Text color="cyan">{conversation.harness}</Text>
          {" | "}{conversation.messages.length} universal messages
          {" | "}{conversation.rawEvents?.length ?? 0} raw events
          {" | "}{shortProject(conversation.projectPath)}
        </Text>
      </Box>

      <Text dimColor>b:back r:thread t:target m:view j/k:scroll</Text>
      <Box marginTop={1} gap={2}>
        <Text>
          Target: <Text color="cyan" bold>{selectedTarget.label}</Text>
          <Text dimColor> [{selectedTarget.state === "todo" ? "TODO" : "Ready"}]</Text>
        </Text>
        <Text>
          View: <Text color="cyan">{viewMode}</Text>
        </Text>
        <Text>
          Mode: <Text color={payload.mode === "resume" ? "green" : "yellow"}>{payload.mode}</Text>
        </Text>
      </Box>
      <Text dimColor>{selectedTarget.note}</Text>

      <Box flexDirection="column" borderStyle="single" borderColor="gray" paddingX={1} marginY={1}>
        <Text bold>Continuation</Text>
        <Text dimColor>Source: {payload.source.harness} | Target: {payload.targetHarness} | Memory: {payload.memory.status}</Text>
        {canNativeResume && resumeCommand ? (
          <Text color="cyan" wrap="truncate-end">Native resume: {resumeCommand}</Text>
        ) : (
          <Text dimColor>Native resume is not available for this target; use the universal payload or prompt.</Text>
        )}
      </Box>

      <Text bold>{viewTitle(viewMode)}</Text>
      <Box flexDirection="column" borderStyle="single" borderColor="gray" paddingX={1}>
        {scroll.visibleRange[0] > 0 && <Text dimColor>▲ {scroll.visibleRange[0]} lines above</Text>}
        {lines.slice(scroll.visibleRange[0], scroll.visibleRange[1]).map((line, index) => (
          <Text key={scroll.visibleRange[0] + index} dimColor={viewMode !== "continuation"} wrap="truncate-end">
            {line || " "}
          </Text>
        ))}
        {scroll.visibleRange[1] < lines.length && <Text dimColor>▼ {lines.length - scroll.visibleRange[1]} lines below</Text>}
      </Box>
    </Box>
  );
}

function viewTitle(viewMode: ViewMode): string {
  if (viewMode === "continuation") return "Continuation Prompt";
  if (viewMode === "universal") return "Universal Payload";
  return "Raw Transcript Events";
}

function shortProject(path: string): string {
  const parts = path.split("/").filter(Boolean);
  return parts.length > 2 ? parts.slice(-2).join("/") : path;
}
