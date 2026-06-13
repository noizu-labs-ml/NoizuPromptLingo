import React, { useState, useEffect } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner, TextInput, Select } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useApiQuery, useConversations, apiFetch } from "../hooks/useApi.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { SelectableList } from "../components/SelectableList.js";
import { ConfirmDialog } from "../components/ConfirmDialog.js";

interface TagMeta {
  name: string;
  color: string;
  description: string;
}

interface TagEntry {
  name: string;
  color: string;
  description: string;
  count: number;
}

const COLOR_PRESETS = [
  { label: "Cyan", value: "#06B6D4" },
  { label: "Green", value: "#22C55E" },
  { label: "Orange", value: "#F97316" },
  { label: "Purple", value: "#A855F7" },
  { label: "Pink", value: "#EC4899" },
  { label: "Gold", value: "#EAB308" },
  { label: "Red", value: "#EF4444" },
  { label: "Blue", value: "#3B82F6" },
];

type UIMode = "list" | "create-name" | "create-desc" | "create-color" | "edit-desc" | "pick-color" | "confirm-delete";

export function TagsPage() {
  const { navigate } = useRouter();
  const { rows } = useTerminalSize();

  const { data: tagData, loading: tagLoading, refetch: refetchTags } = useApiQuery<{ data: TagMeta[] }>("/tags");
  const { data: convData } = useConversations({ limit: 1000 });

  const [tags, setTags] = useState<TagEntry[]>([]);
  const [uiMode, setUiMode] = useState<UIMode>("list");
  const [newName, setNewName] = useState("");
  const [newDesc, setNewDesc] = useState("");
  const [actionMsg, setActionMsg] = useState("");

  useEffect(() => {
    const metas = tagData?.data ?? [];
    const convos = convData?.data ?? [];
    const countMap = new Map<string, number>();
    for (const c of convos) {
      for (const t of c.tags) {
        countMap.set(t, (countMap.get(t) || 0) + 1);
      }
    }

    const allNames = new Set([...metas.map((m) => m.name), ...countMap.keys()]);
    const entries: TagEntry[] = [];
    for (const name of allNames) {
      const meta = metas.find((m) => m.name === name);
      entries.push({
        name,
        color: meta?.color ?? "#06B6D4",
        description: meta?.description ?? "",
        count: countMap.get(name) ?? 0,
      });
    }
    entries.sort((a, b) => b.count - a.count);
    setTags(entries);
  }, [tagData, convData]);

  const contentHeight = Math.max(5, rows - 8);
  const scroll = useScroll({
    totalItems: tags.length,
    viewportHeight: contentHeight,
    isActive: uiMode === "list",
  });

  const showAction = (msg: string) => {
    setActionMsg(msg);
    setTimeout(() => setActionMsg(""), 2000);
  };

  const currentTag = tags[scroll.cursor];

  useInput((input, key) => {
    if (uiMode !== "list") {
      if (key.escape) setUiMode("list");
      return;
    }
    if (input === "n") setUiMode("create-name");
    else if (input === "e") setUiMode("edit-desc");
    else if (input === "c") setUiMode("pick-color");
    else if (input === "d") setUiMode("confirm-delete");
    else if (key.return && currentTag) {
      navigate("explore", { tag: currentTag.name });
    }
  }, { isActive: true });

  if (tagLoading) return <Spinner label="Loading tags..." />;

  return (
    <Box flexDirection="column">
      <Text bold color="cyan">Tags</Text>
      <Text dimColor>n:create e:edit-desc c:color d:delete Enter:browse</Text>
      {actionMsg && <Text color="green">{actionMsg}</Text>}

      {uiMode === "create-name" && (
        <Box marginY={1} flexDirection="column">
          <Text>Tag name:</Text>
          <TextInput onSubmit={(v) => { setNewName(v); setUiMode("create-desc"); }} />
        </Box>
      )}

      {uiMode === "create-desc" && (
        <Box marginY={1} flexDirection="column">
          <Text>Description for <Text color="cyan">{newName}</Text>:</Text>
          <TextInput onSubmit={(v) => { setNewDesc(v); setUiMode("create-color"); }} />
        </Box>
      )}

      {uiMode === "create-color" && (
        <Box marginY={1} flexDirection="column">
          <Text>Color for <Text color="cyan">{newName}</Text>:</Text>
          <Select
            options={COLOR_PRESETS}
            onChange={async (color) => {
              await apiFetch("/tags", {
                method: "POST",
                body: JSON.stringify({ name: newName, description: newDesc, color }),
              });
              showAction(`Created: ${newName}`);
              setUiMode("list");
              refetchTags();
            }}
          />
        </Box>
      )}

      {uiMode === "edit-desc" && currentTag && (
        <Box marginY={1} flexDirection="column">
          <Text>Description for <Text color="cyan">{currentTag.name}</Text>:</Text>
          <TextInput
            defaultValue={currentTag.description}
            onSubmit={async (desc) => {
              await apiFetch("/tags", {
                method: "POST",
                body: JSON.stringify({ name: currentTag.name, description: desc }),
              });
              showAction("Updated");
              setUiMode("list");
              refetchTags();
            }}
          />
        </Box>
      )}

      {uiMode === "pick-color" && currentTag && (
        <Box marginY={1} flexDirection="column">
          <Text>Color for <Text color="cyan">{currentTag.name}</Text>:</Text>
          <Select
            options={COLOR_PRESETS}
            defaultValue={currentTag.color}
            onChange={async (color) => {
              await apiFetch("/tags", {
                method: "POST",
                body: JSON.stringify({ name: currentTag.name, color }),
              });
              showAction("Color updated");
              setUiMode("list");
              refetchTags();
            }}
          />
        </Box>
      )}

      {uiMode === "confirm-delete" && currentTag && (
        <ConfirmDialog
          message={`Delete tag metadata for "${currentTag.name}"?`}
          onConfirm={async () => {
            await apiFetch(`/tags/${currentTag.name}`, { method: "DELETE" });
            showAction("Deleted");
            setUiMode("list");
            refetchTags();
          }}
          onCancel={() => setUiMode("list")}
        />
      )}

      <Box flexDirection="column" marginTop={1}>
        <SelectableList
          items={tags}
          cursor={scroll.cursor}
          visibleRange={scroll.visibleRange}
          emptyMessage="No tags. Press n to create one."
          renderItem={(tag, _i, isCursor) => (
            <Text inverse={isCursor}>
              {isCursor ? "▸ " : "  "}
              <Text color="cyan">●</Text>
              {" "}
              <Text bold>{tag.name}</Text>
              <Text dimColor> ({tag.count})</Text>
              {tag.description && <Text dimColor> — {tag.description}</Text>}
            </Text>
          )}
        />
      </Box>
    </Box>
  );
}
