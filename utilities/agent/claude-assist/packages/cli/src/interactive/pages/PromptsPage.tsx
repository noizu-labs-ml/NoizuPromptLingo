import React, { useState } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner, TextInput } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useApiQuery, apiFetch } from "../hooks/useApi.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { SelectableList } from "../components/SelectableList.js";
import { TagChips } from "../components/TagChips.js";
import { ConfirmDialog } from "../components/ConfirmDialog.js";

interface SavedPrompt {
  id: string;
  title: string;
  content: string;
  role: string;
  tags: string[];
  sourceConversationId?: string;
  createdAt: string;
}

type UIMode = "list" | "filter" | "create-title" | "create-content" | "edit-title" | "edit-content" | "add-tag" | "confirm-delete";

export function PromptsPage() {
  const { navigate } = useRouter();
  const { rows } = useTerminalSize();

  const { data, loading, refetch } = useApiQuery<{ data: SavedPrompt[] }>("/prompts");
  const allPrompts = data?.data ?? [];

  const [uiMode, setUiMode] = useState<UIMode>("list");
  const [filter, setFilter] = useState("");
  const [newTitle, setNewTitle] = useState("");
  const [actionMsg, setActionMsg] = useState("");

  const prompts = filter
    ? allPrompts.filter((p) =>
        p.title.toLowerCase().includes(filter.toLowerCase()) ||
        p.content.toLowerCase().includes(filter.toLowerCase()))
    : allPrompts;

  const contentHeight = Math.max(5, rows - 8);
  const scroll = useScroll({
    totalItems: prompts.length,
    viewportHeight: contentHeight,
    isActive: uiMode === "list",
  });

  const showAction = (msg: string) => {
    setActionMsg(msg);
    setTimeout(() => setActionMsg(""), 2000);
  };

  const currentPrompt = prompts[scroll.cursor];

  useInput((input, key) => {
    if (uiMode !== "list") {
      if (key.escape) setUiMode("list");
      return;
    }
    if (input === "/") setUiMode("filter");
    else if (input === "n") setUiMode("create-title");
    else if (input === "e") setUiMode("edit-title");
    else if (input === "t") setUiMode("add-tag");
    else if (input === "d") setUiMode("confirm-delete");
    else if (input === "c" && currentPrompt) {
      // Copy to clipboard attempt
      try {
        const { execSync } = require("child_process");
        execSync(`echo ${JSON.stringify(currentPrompt.content)} | pbcopy`);
        showAction("Copied");
      } catch {
        showAction("Copy not available");
      }
    }
    else if (key.return && currentPrompt?.sourceConversationId) {
      navigate("thread", { id: currentPrompt.sourceConversationId });
    }
  }, { isActive: true });

  if (loading) return <Spinner label="Loading prompts..." />;

  return (
    <Box flexDirection="column">
      <Text bold color="cyan">Prompts</Text>
      <Text dimColor>/:filter n:create e:edit t:tag c:copy d:delete Enter:source</Text>
      {actionMsg && <Text color="green">{actionMsg}</Text>}
      {filter && <Text dimColor>Filter: "{filter}"</Text>}

      {uiMode === "filter" && (
        <Box marginY={1}>
          <Text>Filter: </Text>
          <TextInput
            defaultValue={filter}
            onSubmit={(v) => { setFilter(v); setUiMode("list"); }}
          />
        </Box>
      )}

      {uiMode === "create-title" && (
        <Box marginY={1} flexDirection="column">
          <Text>Prompt title:</Text>
          <TextInput onSubmit={(v) => { setNewTitle(v); setUiMode("create-content"); }} />
        </Box>
      )}

      {uiMode === "create-content" && (
        <Box marginY={1} flexDirection="column">
          <Text>Content for <Text color="cyan">{newTitle}</Text>:</Text>
          <TextInput
            onSubmit={async (content) => {
              await apiFetch("/prompts", {
                method: "POST",
                body: JSON.stringify({ title: newTitle, content, role: "user" }),
              });
              showAction("Created");
              setUiMode("list");
              refetch();
            }}
          />
        </Box>
      )}

      {uiMode === "edit-title" && currentPrompt && (
        <Box marginY={1} flexDirection="column">
          <Text>Edit title:</Text>
          <TextInput
            defaultValue={currentPrompt.title}
            onSubmit={async (title) => {
              await apiFetch(`/prompts/${currentPrompt.id}`, {
                method: "PATCH",
                body: JSON.stringify({ title }),
              });
              showAction("Updated");
              setUiMode("list");
              refetch();
            }}
          />
        </Box>
      )}

      {uiMode === "edit-content" && currentPrompt && (
        <Box marginY={1} flexDirection="column">
          <Text>Edit content:</Text>
          <TextInput
            defaultValue={currentPrompt.content}
            onSubmit={async (content) => {
              await apiFetch(`/prompts/${currentPrompt.id}`, {
                method: "PATCH",
                body: JSON.stringify({ content }),
              });
              showAction("Updated");
              setUiMode("list");
              refetch();
            }}
          />
        </Box>
      )}

      {uiMode === "add-tag" && currentPrompt && (
        <Box marginY={1} flexDirection="column">
          <Text>Add tag:</Text>
          <TextInput
            onSubmit={async (tag) => {
              await apiFetch(`/prompts/${currentPrompt.id}`, {
                method: "PATCH",
                body: JSON.stringify({ tags: [...currentPrompt.tags, tag] }),
              });
              showAction(`Tagged: ${tag}`);
              setUiMode("list");
              refetch();
            }}
          />
        </Box>
      )}

      {uiMode === "confirm-delete" && currentPrompt && (
        <ConfirmDialog
          message={`Delete "${currentPrompt.title}"?`}
          onConfirm={async () => {
            await apiFetch(`/prompts/${currentPrompt.id}`, { method: "DELETE" });
            showAction("Deleted");
            setUiMode("list");
            refetch();
          }}
          onCancel={() => setUiMode("list")}
        />
      )}

      <Box flexDirection="column" marginTop={1}>
        <SelectableList
          items={prompts}
          cursor={scroll.cursor}
          visibleRange={scroll.visibleRange}
          emptyMessage="No prompts. Press n to create one."
          renderItem={(prompt, _i, isCursor) => (
            <Box flexDirection="column">
              <Text inverse={isCursor}>
                {isCursor ? "▸ " : "  "}
                <Text color={prompt.role === "user" ? "cyan" : "magenta"} bold>[{prompt.role}]</Text>
                {" "}
                <Text bold>{prompt.title}</Text>
                {prompt.sourceConversationId && <Text dimColor> ⤶</Text>}
              </Text>
              {prompt.tags.length > 0 && (
                <Box marginLeft={4}><TagChips tags={prompt.tags} compact /></Box>
              )}
              {isCursor && (
                <Text dimColor wrap="truncate-end">
                  {"    "}{prompt.content.slice(0, 120)}
                </Text>
              )}
            </Box>
          )}
        />
      </Box>
    </Box>
  );
}
