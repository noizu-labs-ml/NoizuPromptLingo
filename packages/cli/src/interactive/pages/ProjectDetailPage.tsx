import React, { useState, useMemo } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner, TextInput, Select } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useApiQuery, useConversations, apiFetch } from "../hooks/useApi.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { SelectableList } from "../components/SelectableList.js";
import { ConversationRow } from "../components/ConversationRow.js";
import { TagChips } from "../components/TagChips.js";

interface ProjectEntry {
  projectPath: string;
  title: string;
  description: string;
  tags: string[];
  conversationCount: number;
  lastActive: string;
}

type SortOption = "updated_at" | "started_at" | "message_count" | "title";
type UIMode = "list" | "filter" | "sort";

const SORT_OPTIONS = [
  { label: "Last Updated", value: "updated_at" },
  { label: "Date Started", value: "started_at" },
  { label: "Message Count", value: "message_count" },
  { label: "Title", value: "title" },
];

export function ProjectDetailPage() {
  const { current, navigate, goBack } = useRouter();
  const projectPath = current.params.path;
  const { rows } = useTerminalSize();

  const { data: projData, loading: projLoading } = useApiQuery<{ data: ProjectEntry }>(
    `/projects/${encodeURIComponent(projectPath)}`
  );
  const { data: convData, loading: convLoading } = useConversations({ project: projectPath, limit: 500 });

  const project = projData?.data;
  const conversations = convData?.data ?? [];

  const [uiMode, setUiMode] = useState<UIMode>("list");
  const [filter, setFilter] = useState("");
  const [sort, setSort] = useState<SortOption>("updated_at");

  const filtered = useMemo(() => {
    let items = conversations;
    if (filter) {
      const lower = filter.toLowerCase();
      items = items.filter((c) => c.title.toLowerCase().includes(lower));
    }
    return items.sort((a, b) => {
      switch (sort) {
        case "title": return a.title.localeCompare(b.title);
        case "message_count": return b.messageCount - a.messageCount;
        case "started_at": return new Date(b.startedAt).getTime() - new Date(a.startedAt).getTime();
        default: return new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime();
      }
    });
  }, [conversations, filter, sort]);

  const contentHeight = Math.max(5, rows - 12);
  const scroll = useScroll({
    totalItems: filtered.length,
    viewportHeight: contentHeight,
    isActive: uiMode === "list",
  });

  useInput((input, key) => {
    if (uiMode !== "list") {
      if (key.escape) setUiMode("list");
      return;
    }
    if (key.escape) goBack();
    else if (input === "/") setUiMode("filter");
    else if (input === "o") setUiMode("sort");
    else if (key.return) {
      const conv = filtered[scroll.cursor];
      if (conv) navigate("thread", { id: conv.id });
    }
  }, { isActive: true });

  if (projLoading || convLoading) return <Spinner label="Loading project..." />;
  if (!project) return <Text color="red">Project not found</Text>;

  return (
    <Box flexDirection="column">
      <Box flexDirection="column" borderStyle="single" borderColor="cyan" paddingX={1} marginBottom={1}>
        <Text bold color="cyan">{project.title || shortPath(project.projectPath)}</Text>
        <Text dimColor>{project.projectPath}</Text>
        {project.description && <Text dimColor>{project.description}</Text>}
        <Text dimColor>{project.conversationCount} conversations</Text>
        {project.tags.length > 0 && <TagChips tags={project.tags} />}
      </Box>

      <Text dimColor>/:filter o:sort Enter:open Esc:back</Text>

      {uiMode === "filter" && (
        <Box marginY={1}>
          <Text>Filter: </Text>
          <TextInput defaultValue={filter} onSubmit={(v) => { setFilter(v); setUiMode("list"); }} />
        </Box>
      )}

      {uiMode === "sort" && (
        <Box marginY={1}>
          <Text>Sort: </Text>
          <Select
            options={SORT_OPTIONS}
            defaultValue={sort}
            onChange={(v) => { setSort(v as SortOption); setUiMode("list"); }}
          />
        </Box>
      )}

      {filter && <Text dimColor>Filter: "{filter}" ({filtered.length} results)</Text>}

      <Box flexDirection="column" marginTop={1}>
        <SelectableList
          items={filtered}
          cursor={scroll.cursor}
          visibleRange={scroll.visibleRange}
          emptyMessage="No conversations in this project."
          renderItem={(conv: any, _i, isCursor) => (
            <ConversationRow
              id={conv.id}
              title={conv.title}
              projectPath={conv.projectPath}
              messageCount={conv.messageCount}
              updatedAt={conv.updatedAt}
              status={conv.status}
              isCursor={isCursor}
            />
          )}
        />
      </Box>
    </Box>
  );
}

function shortPath(path: string): string {
  return path.split("/").filter(Boolean).slice(-2).join("/");
}
