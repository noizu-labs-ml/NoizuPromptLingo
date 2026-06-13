import React, { useState } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner, TextInput } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useApiQuery, apiFetch } from "../hooks/useApi.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { SelectableList } from "../components/SelectableList.js";

interface Dataset {
  name: string;
  description: string;
  version: number;
  entryCount: number;
  createdAt: string;
  updatedAt: string;
}

type UIMode = "list" | "create-name" | "create-desc";

export function DatasetsPage() {
  const { navigate } = useRouter();
  const { rows } = useTerminalSize();

  const { data, loading, refetch } = useApiQuery<{ data: Dataset[] }>("/datasets");
  const datasets = data?.data ?? [];

  const [uiMode, setUiMode] = useState<UIMode>("list");
  const [newName, setNewName] = useState("");
  const [actionMsg, setActionMsg] = useState("");

  const contentHeight = Math.max(5, rows - 8);
  const scroll = useScroll({
    totalItems: datasets.length,
    viewportHeight: contentHeight,
    isActive: uiMode === "list",
  });

  useInput((input, key) => {
    if (uiMode !== "list") {
      if (key.escape) setUiMode("list");
      return;
    }
    if (input === "n") setUiMode("create-name");
    else if (key.return) {
      const ds = datasets[scroll.cursor];
      if (ds) navigate("dataset-detail", { name: ds.name });
    }
  }, { isActive: true });

  if (loading) return <Spinner label="Loading datasets..." />;

  return (
    <Box flexDirection="column">
      <Text bold color="cyan">Datasets</Text>
      <Text dimColor>n:create Enter:view</Text>
      {actionMsg && <Text color="green">{actionMsg}</Text>}

      {uiMode === "create-name" && (
        <Box marginY={1} flexDirection="column">
          <Text>Dataset name:</Text>
          <TextInput
            placeholder="my-dataset"
            onSubmit={(v) => { setNewName(v); setUiMode("create-desc"); }}
          />
        </Box>
      )}

      {uiMode === "create-desc" && (
        <Box marginY={1} flexDirection="column">
          <Text>Description for <Text color="cyan">{newName}</Text>:</Text>
          <TextInput
            placeholder="Training data for..."
            onSubmit={async (desc) => {
              await apiFetch("/datasets", {
                method: "POST",
                body: JSON.stringify({ name: newName, description: desc }),
              });
              setActionMsg(`Created: ${newName}`);
              setTimeout(() => setActionMsg(""), 2000);
              setUiMode("list");
              refetch();
            }}
          />
        </Box>
      )}

      <Box flexDirection="column" marginTop={1}>
        <SelectableList
          items={datasets}
          cursor={scroll.cursor}
          visibleRange={scroll.visibleRange}
          emptyMessage="No datasets. Press n to create one."
          renderItem={(ds, _i, isCursor) => (
            <Text inverse={isCursor}>
              {isCursor ? "▸ " : "  "}
              <Text bold>{ds.name}</Text>
              <Text dimColor> v{ds.version} | {ds.entryCount} entries | {ds.description}</Text>
            </Text>
          )}
        />
      </Box>
    </Box>
  );
}
