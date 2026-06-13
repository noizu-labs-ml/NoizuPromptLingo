import React, { useState } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner, TextInput } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useApiQuery, apiFetch } from "../hooks/useApi.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { SelectableList } from "../components/SelectableList.js";
import { TagChips } from "../components/TagChips.js";

interface ProjectEntry {
  projectPath: string;
  title: string;
  description: string;
  tags: string[];
  conversationCount: number;
  lastActive: string;
}

type UIMode = "list" | "edit-title" | "edit-desc";

export function ProjectsPage() {
  const { navigate } = useRouter();
  const { rows } = useTerminalSize();

  const { data, loading, refetch } = useApiQuery<{ data: ProjectEntry[] }>("/projects");
  const projects = data?.data ?? [];

  const [uiMode, setUiMode] = useState<UIMode>("list");
  const [actionMsg, setActionMsg] = useState("");

  const contentHeight = Math.max(5, rows - 8);
  const scroll = useScroll({
    totalItems: projects.length,
    viewportHeight: contentHeight,
    isActive: uiMode === "list",
  });

  const showAction = (msg: string) => {
    setActionMsg(msg);
    setTimeout(() => setActionMsg(""), 2000);
  };

  const currentProject = projects[scroll.cursor];

  useInput((input, key) => {
    if (uiMode !== "list") {
      if (key.escape) setUiMode("list");
      return;
    }
    if (input === "e") setUiMode("edit-title");
    else if (input === "E") setUiMode("edit-desc");
    else if (key.return && currentProject) {
      navigate("project-detail", { path: currentProject.projectPath });
    }
  }, { isActive: true });

  if (loading) return <Spinner label="Loading projects..." />;

  return (
    <Box flexDirection="column">
      <Text bold color="cyan">Projects</Text>
      <Text dimColor>e:edit-title E:edit-desc Enter:view</Text>
      {actionMsg && <Text color="green">{actionMsg}</Text>}

      {uiMode === "edit-title" && currentProject && (
        <Box marginY={1} flexDirection="column">
          <Text>Title for <Text dimColor>{currentProject.projectPath}</Text>:</Text>
          <TextInput
            defaultValue={currentProject.title}
            onSubmit={async (title) => {
              await apiFetch(`/projects/${encodeURIComponent(currentProject.projectPath)}`, {
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

      {uiMode === "edit-desc" && currentProject && (
        <Box marginY={1} flexDirection="column">
          <Text>Description for <Text dimColor>{currentProject.projectPath}</Text>:</Text>
          <TextInput
            defaultValue={currentProject.description}
            onSubmit={async (description) => {
              await apiFetch(`/projects/${encodeURIComponent(currentProject.projectPath)}`, {
                method: "PATCH",
                body: JSON.stringify({ description }),
              });
              showAction("Updated");
              setUiMode("list");
              refetch();
            }}
          />
        </Box>
      )}

      <Box flexDirection="column" marginTop={1}>
        <SelectableList
          items={projects}
          cursor={scroll.cursor}
          visibleRange={scroll.visibleRange}
          emptyMessage="No projects found."
          renderItem={(proj, _i, isCursor) => (
            <Box flexDirection="column">
              <Text inverse={isCursor}>
                {isCursor ? "▸ " : "  "}
                <Text bold>{proj.title || shortPath(proj.projectPath)}</Text>
                <Text dimColor> ({proj.conversationCount} convos)</Text>
                {proj.lastActive && (
                  <Text dimColor> {new Date(proj.lastActive).toLocaleDateString()}</Text>
                )}
              </Text>
              <Text dimColor wrap="truncate-end">
                {"    "}{proj.projectPath}
              </Text>
              {proj.tags.length > 0 && (
                <Box marginLeft={4}><TagChips tags={proj.tags} compact /></Box>
              )}
              {isCursor && proj.description && (
                <Text dimColor>{"    "}{proj.description}</Text>
              )}
            </Box>
          )}
        />
      </Box>
    </Box>
  );
}

function shortPath(path: string): string {
  return path.split("/").filter(Boolean).slice(-2).join("/");
}
