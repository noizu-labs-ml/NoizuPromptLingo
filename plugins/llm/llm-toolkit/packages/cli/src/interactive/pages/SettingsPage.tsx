import React, { useEffect, useState } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner } from "@inkjs/ui";
import { useApiQuery, apiFetch, useIndexStatus } from "../hooks/useApi.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { InputModal } from "../components/InputModal.js";

interface LlmConfig {
  provider: string;
  model?: string;
  apiKey?: string;
  baseUrl?: string;
  apiType?: "openai" | "anthropic";
}

interface AppConfig {
  indexPaths: string[];
  embedding: {
    provider: string;
    model?: string;
    apiKey?: string;
  };
  llm?: LlmConfig;
  server: {
    port: number;
    host: string;
  };
}

interface LlmStatus {
  available: boolean;
  provider: string;
}

interface ScanProject {
  projectPath: string;
  fileCount: number;
  newOrChanged: number;
}

interface ScanPreview {
  projects: ScanProject[];
  totalFiles: number;
  totalNewFiles: number;
  embeddingProvider: string;
  estimatedTokens: number;
  estimatedCost: number;
}

type UIMode =
  | "browse"
  | "add-path"
  | "select-embedding"
  | "select-llm"
  | "llm-model"
  | "llm-key"
  | "llm-baseurl"
  | "llm-apitype"
  | "test-prompt";

type Section = "index" | "embedding" | "llm";

interface MenuOption {
  label: string;
  value: string;
}

interface ActionButton {
  id: string;
  label: string;
  run: () => void | Promise<void>;
  disabled?: boolean;
}

const SECTIONS: Section[] = ["index", "embedding", "llm"];

const SECTION_LABELS: Record<Section, string> = {
  index: "Index Paths",
  embedding: "Embedding",
  llm: "LLM Inference",
};

const EMBEDDING_OPTIONS: MenuOption[] = [
  { label: "Local (MiniLM)", value: "local" },
  { label: "OpenAI", value: "openai" },
  { label: "Voyage", value: "voyage" },
  { label: "Anthropic", value: "anthropic" },
];

const LLM_OPTIONS: MenuOption[] = [
  { label: "None", value: "" },
  { label: "Anthropic (Claude)", value: "anthropic" },
  { label: "OpenAI", value: "openai" },
  { label: "DeepSeek", value: "deepseek" },
  { label: "Groq", value: "groq" },
  { label: "Cerebras", value: "cerebras" },
  { label: "Z.ai (Zhipu/GLM)", value: "zai" },
  { label: "LiteLLM Proxy", value: "litellm" },
  { label: "Ollama (Local)", value: "ollama" },
  { label: "Custom Endpoint", value: "custom" },
];

const API_TYPE_OPTIONS: MenuOption[] = [
  { label: "OpenAI-compatible", value: "openai" },
  { label: "Anthropic-compatible", value: "anthropic" },
];

const MODEL_PLACEHOLDERS: Record<string, string> = {
  anthropic: "claude-sonnet-4-20250514",
  openai: "gpt-4o",
  ollama: "llama3",
  litellm: "claude-sonnet-4-6",
  groq: "llama-3.3-70b",
  deepseek: "deepseek-chat",
};

function selectedOptionIndex(options: MenuOption[], value: string | undefined): number {
  return Math.max(0, options.findIndex((option) => option.value === (value ?? "")));
}

function shortPath(path: string): string {
  const parts = path.split("/").filter(Boolean);
  return parts.length > 3 ? parts.slice(-3).join("/") : path;
}

// ⟦𓍝𓃑𓊩𓇸⟧ SettingsPage :: auto-generated pointer for public function SettingsPage
export function SettingsPage() {
  const { rows } = useTerminalSize();

  const { data: configData, loading } = useApiQuery<{ data: AppConfig }>("/config");
  const { data: idxData, refetch: refetchIdx } = useIndexStatus();

  const [config, setConfig] = useState<AppConfig | null>(null);
  const [llmStatus, setLlmStatus] = useState<LlmStatus | null>(null);
  const [scanPreview, setScanPreview] = useState<ScanPreview | null>(null);
  const [uiMode, setUiMode] = useState<UIMode>("browse");
  const [section, setSection] = useState<Section>("index");
  const [actionIndex, setActionIndex] = useState(0);
  const [optionIndex, setOptionIndex] = useState(0);
  const [dirty, setDirty] = useState(false);
  const [saving, setSaving] = useState(false);
  const [scanning, setScanning] = useState(false);
  const [reindexing, setReindexing] = useState(false);
  const [testPrompt, setTestPrompt] = useState<string | null>(null);
  const [testResponse, setTestResponse] = useState<string | null>(null);
  const [testError, setTestError] = useState<string | null>(null);
  const [testing, setTesting] = useState(false);
  const [actionMsg, setActionMsg] = useState("");

  useEffect(() => {
    if (configData?.data) setConfig(configData.data);
  }, [configData]);

  useEffect(() => {
    apiFetch<{ data: LlmStatus }>("/llm/status")
      .then((res) => setLlmStatus(res.data))
      .catch(() => {});
  }, [saving, dirty]);

  useEffect(() => {
    setActionIndex(0);
  }, [section]);

  const pathScroll = useScroll({
    totalItems: config?.indexPaths.length ?? 0,
    viewportHeight: Math.min(8, Math.max(3, rows - 20)),
    isActive: false,
  });

  const showAction = (msg: string) => {
    setActionMsg(msg);
    setTimeout(() => setActionMsg(""), 2500);
  };

  const handleSave = async () => {
    if (!config || !dirty) {
      showAction("No settings changes to save");
      return;
    }
    setSaving(true);
    try {
      const res = await apiFetch<{ data: AppConfig }>("/config", {
        method: "PATCH",
        body: JSON.stringify(config),
      });
      setConfig(res.data);
      setDirty(false);
      showAction("Settings saved");
    } catch {
      showAction("Save failed");
    }
    setSaving(false);
  };

  const handleScan = async () => {
    setScanning(true);
    try {
      const res = await apiFetch<{ data: ScanPreview }>("/index/preview");
      setScanPreview(res.data);
      showAction("Scan preview ready");
    } catch {
      showAction("Scan failed");
    }
    setScanning(false);
  };

  const handleRebuild = async () => {
    setReindexing(true);
    showAction("Rebuild started");
    await apiFetch("/index/rebuild", { method: "POST" });
    const poll = setInterval(async () => {
      try {
        const res = await fetch("http://localhost:3100/api/index/status");
        const body = await res.json();
        if (body.data.status === "idle") {
          clearInterval(poll);
          setReindexing(false);
          showAction("Reindex complete");
          refetchIdx();
          setScanPreview(null);
        }
      } catch {}
    }, 1000);
    setTimeout(() => clearInterval(poll), 60000);
  };

  const handleTestLlm = async (prompt: string) => {
    setTesting(true);
    setTestError(null);
    setTestResponse(null);
    const msg = prompt.trim() || "Say hello in one sentence";
    setTestPrompt(msg);
    try {
      const res = await apiFetch<{ data: { content: string } }>("/llm/complete", {
        method: "POST",
        body: JSON.stringify({ messages: [{ role: "user", content: msg }], maxTokens: 256 }),
      });
      setTestResponse(res.data.content);
      showAction("Inference test complete");
    } catch (err: any) {
      setTestError(err.message ?? "Request failed");
      showAction("Inference test failed");
    }
    setTesting(false);
    setUiMode("browse");
  };

  const openOptionMenu = (mode: Extract<UIMode, "select-embedding" | "select-llm" | "llm-apitype">, options: MenuOption[], value?: string) => {
    setOptionIndex(selectedOptionIndex(options, value));
    setUiMode(mode);
  };

  const moveSection = (delta: number) => {
    setSection((current) => {
      const currentIndex = SECTIONS.indexOf(current);
      return SECTIONS[(currentIndex + delta + SECTIONS.length) % SECTIONS.length];
    });
  };

  const selectOption = (value: string) => {
    if (!config) return;
    if (uiMode === "select-embedding") {
      setConfig({ ...config, embedding: { ...config.embedding, provider: value } });
      setDirty(true);
      setUiMode("browse");
      showAction(`Embedding provider set to ${value}`);
    } else if (uiMode === "select-llm") {
      setConfig(value ? { ...config, llm: { ...config.llm, provider: value } } : { ...config, llm: undefined });
      setDirty(true);
      setUiMode("browse");
      showAction(value ? `LLM provider set to ${value}` : "LLM provider cleared");
    } else if (uiMode === "llm-apitype") {
      setConfig({
        ...config,
        llm: { provider: config.llm?.provider ?? "custom", ...config.llm, apiType: value as "openai" | "anthropic" },
      });
      setDirty(true);
      setUiMode("browse");
      showAction(`API type set to ${value}`);
    }
  };

  const activeConfig: AppConfig = config ?? {
    indexPaths: [],
    embedding: { provider: "local" },
    server: { port: 0, host: "localhost" },
  };
  const indexStatus = idxData?.data;
  const lastIndexed = indexStatus?.lastIndexed ? new Date(indexStatus.lastIndexed).toLocaleString() : "Never";
  const llmProvider = activeConfig.llm?.provider ?? "";
  const llmNeedsBaseUrl = llmProvider === "ollama" || llmProvider === "litellm" || llmProvider === "custom";

  const sectionActions: Record<Section, ActionButton[]> = {
    index: [
      { id: "add", label: "Add Path", run: () => setUiMode("add-path") },
      {
        id: "delete",
        label: "Delete Selected",
        disabled: activeConfig.indexPaths.length === 0,
        run: () => {
          if (!config) return;
          const updated = { ...config, indexPaths: config.indexPaths.filter((_, i) => i !== pathScroll.cursor) };
          setConfig(updated);
          setDirty(true);
          showAction("Path removed");
        },
      },
      { id: "scan", label: "Preview Scan", run: handleScan },
      { id: "rebuild", label: "Rebuild Index", run: handleRebuild },
      { id: "save", label: dirty ? "Save Changes" : "Save", disabled: !dirty, run: handleSave },
    ],
    embedding: [
      {
        id: "provider",
        label: "Change Provider",
        run: () => openOptionMenu("select-embedding", EMBEDDING_OPTIONS, activeConfig.embedding.provider),
      },
      { id: "save", label: dirty ? "Save Changes" : "Save", disabled: !dirty, run: handleSave },
    ],
    llm: [
      { id: "provider", label: "Provider", run: () => openOptionMenu("select-llm", LLM_OPTIONS, llmProvider) },
      { id: "model", label: "Model", disabled: !llmProvider, run: () => setUiMode("llm-model") },
      { id: "key", label: "API Key", disabled: !llmProvider, run: () => setUiMode("llm-key") },
      { id: "base", label: "Base URL", disabled: !llmNeedsBaseUrl, run: () => setUiMode("llm-baseurl") },
      {
        id: "type",
        label: "API Type",
        disabled: llmProvider !== "custom",
        run: () => openOptionMenu("llm-apitype", API_TYPE_OPTIONS, activeConfig.llm?.apiType ?? "openai"),
      },
      { id: "test", label: "Test Inference", disabled: !llmProvider, run: () => setUiMode("test-prompt") },
      { id: "save", label: dirty ? "Save Changes" : "Save", disabled: !dirty, run: handleSave },
    ],
  };

  const currentActions = sectionActions[section];
  const currentAction = currentActions[Math.min(actionIndex, currentActions.length - 1)];

  useInput((input, key) => {
    if (!config) return;

    if (uiMode === "select-embedding" || uiMode === "select-llm" || uiMode === "llm-apitype") {
      const options = uiMode === "select-embedding"
        ? EMBEDDING_OPTIONS
        : uiMode === "select-llm"
          ? LLM_OPTIONS
          : API_TYPE_OPTIONS;
      if (key.escape) setUiMode("browse");
      else if (key.upArrow) setOptionIndex((idx) => (idx - 1 + options.length) % options.length);
      else if (key.downArrow) setOptionIndex((idx) => (idx + 1) % options.length);
      else if (key.return) selectOption(options[optionIndex]?.value ?? "");
      return;
    }

    if (uiMode !== "browse") {
      if (key.escape) setUiMode("browse");
      return;
    }

    if (key.upArrow) moveSection(-1);
    else if (key.downArrow) moveSection(1);
    else if (key.leftArrow) setActionIndex((idx) => (idx - 1 + currentActions.length) % currentActions.length);
    else if (key.rightArrow) setActionIndex((idx) => (idx + 1) % currentActions.length);
    else if (key.return && currentAction && !currentAction.disabled) currentAction.run();
    else if (section === "index" && input === "j") pathScroll.moveCursorDown();
    else if (section === "index" && input === "k") pathScroll.moveCursorUp();
  }, { isActive: true });

  const visiblePaths = activeConfig.indexPaths.slice(pathScroll.visibleRange[0], pathScroll.visibleRange[1]);

  if (loading || !config) return <Spinner label="Loading settings..." />;

  return (
    <Box flexDirection="column">
      <Box justifyContent="space-between">
        <Text bold color="cyan">Settings</Text>
        <Text dimColor>
          <Text color="yellow">Keys:</Text> arrows move, Enter activates, Esc cancels
          {section === "index" && <Text color="magenta">  j/k select path</Text>}
        </Text>
      </Box>
      {actionMsg && <Text color="cyan">{actionMsg}</Text>}
      {dirty && <Text color="yellow">Unsaved changes</Text>}

      <SettingsSection title={SECTION_LABELS.index} active={section === "index"} actions={sectionActions.index} actionIndex={actionIndex}>
        <Text>
          <Text color={reindexing ? "yellow" : "green"}>●</Text>
          {" "}{reindexing ? "Indexing..." : "Idle"}
          {" | "}{indexStatus?.conversationCount ?? 0} indexed
          {" | "}Last: {lastIndexed}
        </Text>
        {config.indexPaths.length === 0 && <Text dimColor italic>No paths configured.</Text>}
        {visiblePaths.map((path, i) => {
          const pathIndex = pathScroll.visibleRange[0] + i;
          const selected = pathIndex === pathScroll.cursor;
          return (
            <Text key={pathIndex} wrap="truncate-end">
              <Text color={selected ? "white" : "gray"} bold={selected}>{selected ? "✓ " : "  "}</Text>
              <Text color={selected ? "white" : undefined}>{shortPath(path)}</Text>
              <Text dimColor>  {path}</Text>
            </Text>
          );
        })}
        {reindexing && <Spinner label="Rebuilding index..." />}
        {scanning && <Spinner label="Scanning..." />}
        {scanPreview && (
          <Box flexDirection="column" marginTop={1} borderStyle="single" borderColor="gray" paddingX={1}>
            <Text bold>Scan Preview</Text>
            <Text>
              <Text bold>{scanPreview.totalFiles}</Text> files total
              {" | "}<Text bold color="cyan">{scanPreview.totalNewFiles}</Text> new/changed
              {" | "}Cost: {scanPreview.embeddingProvider === "local" ? "Free" : `~$${scanPreview.estimatedCost.toFixed(4)}`}
            </Text>
            <Text dimColor>~{scanPreview.estimatedTokens.toLocaleString()} tokens to embed</Text>
            {scanPreview.projects.slice(0, 5).map((proj, i) => (
              <Text key={i} dimColor>
                {"  "}{shortPath(proj.projectPath)} - {proj.fileCount} files
                {proj.newOrChanged > 0 && <Text color="cyan"> ({proj.newOrChanged} new)</Text>}
              </Text>
            ))}
          </Box>
        )}
      </SettingsSection>

      <SettingsSection title={SECTION_LABELS.embedding} active={section === "embedding"} actions={sectionActions.embedding} actionIndex={actionIndex}>
        <Text>Current: <Text color="cyan">{config.embedding.provider}</Text></Text>
        <Text dimColor>Local embeddings use all-MiniLM-L6-v2. Cloud providers require API configuration outside local embedding mode.</Text>
      </SettingsSection>

      <SettingsSection title={SECTION_LABELS.llm} active={section === "llm"} actions={sectionActions.llm} actionIndex={actionIndex}>
        <Text>
          Provider: <Text color="cyan">{llmProvider || "None"}</Text>
          {llmStatus && (
            <Text>
              {" | "}
              <Text color={llmStatus.available ? "green" : "yellow"}>{llmStatus.available ? "connected" : "not configured"}</Text>
            </Text>
          )}
        </Text>
        {config.llm?.model && <Text>Model: <Text color="cyan">{config.llm.model}</Text></Text>}
        {config.llm?.apiKey && <Text>API Key: <Text dimColor>***configured***</Text></Text>}
        {config.llm?.baseUrl && <Text>Base URL: <Text dimColor>{config.llm.baseUrl}</Text></Text>}
        {config.llm?.apiType && <Text>API Type: <Text dimColor>{config.llm.apiType}</Text></Text>}
        {testing && <Spinner label="Testing inference..." />}
        {(testResponse || testError || testPrompt) && (
          <Box flexDirection="column" marginTop={1} borderStyle="single" borderColor={testError ? "red" : testResponse ? "green" : "gray"} paddingX={1}>
            <Text bold color={testError ? "red" : testResponse ? "green" : "cyan"}>
              Inference Test {testError ? "Failed" : testResponse ? "Succeeded" : "Pending"}
            </Text>
            {testPrompt && <Text dimColor>Prompt: {testPrompt}</Text>}
            {testError && <Text color="red">Error: {testError}</Text>}
            {testResponse && <Text wrap="wrap">{testResponse}</Text>}
          </Box>
        )}
      </SettingsSection>

      {uiMode === "add-path" && (
        <InputModal
          label="New index path:"
          placeholder="~/.claude/projects"
          onSubmit={(path) => {
            if (path) {
              setConfig({ ...config, indexPaths: [...config.indexPaths, path] });
              setDirty(true);
              showAction("Path added");
            }
            setUiMode("browse");
          }}
          onCancel={() => setUiMode("browse")}
        />
      )}

      {uiMode === "llm-model" && (
        <InputModal
          label="Model name:"
          defaultValue={config.llm?.model ?? ""}
          placeholder={MODEL_PLACEHOLDERS[llmProvider] ?? "model-name"}
          onSubmit={(value) => {
            setConfig({ ...config, llm: { provider: llmProvider || "custom", ...config.llm, model: value || undefined } });
            setDirty(true);
            setUiMode("browse");
            showAction("Model updated");
          }}
          onCancel={() => setUiMode("browse")}
        />
      )}

      {uiMode === "llm-key" && (
        <InputModal
          label="API Key:"
          placeholder="Enter API key"
          onSubmit={(value) => {
            setConfig({ ...config, llm: { provider: llmProvider || "custom", ...config.llm, apiKey: value || undefined } });
            setDirty(true);
            setUiMode("browse");
            showAction(value ? "API key updated" : "API key cleared");
          }}
          onCancel={() => setUiMode("browse")}
        />
      )}

      {uiMode === "llm-baseurl" && (
        <InputModal
          label="Base URL:"
          defaultValue={config.llm?.baseUrl ?? ""}
          placeholder="http://localhost:11434"
          onSubmit={(value) => {
            setConfig({ ...config, llm: { provider: llmProvider || "custom", ...config.llm, baseUrl: value || undefined } });
            setDirty(true);
            setUiMode("browse");
            showAction(value ? "Base URL updated" : "Base URL cleared");
          }}
          onCancel={() => setUiMode("browse")}
        />
      )}

      {uiMode === "test-prompt" && (
        <InputModal
          label="Test prompt:"
          placeholder="Say hello in one sentence"
          onSubmit={handleTestLlm}
          onCancel={() => setUiMode("browse")}
        />
      )}

      {(uiMode === "select-embedding" || uiMode === "select-llm" || uiMode === "llm-apitype") && (
        <OptionMenu
          title={uiMode === "select-embedding" ? "Embedding Provider" : uiMode === "select-llm" ? "LLM Provider" : "API Type"}
          options={uiMode === "select-embedding" ? EMBEDDING_OPTIONS : uiMode === "select-llm" ? LLM_OPTIONS : API_TYPE_OPTIONS}
          selectedIndex={optionIndex}
          currentValue={uiMode === "select-embedding" ? config.embedding.provider : uiMode === "select-llm" ? llmProvider : config.llm?.apiType}
        />
      )}

      {saving && <Spinner label="Saving..." />}
    </Box>
  );
}

function SettingsSection({
  title,
  active,
  actions,
  actionIndex,
  children,
}: {
  title: string;
  active: boolean;
  actions: ActionButton[];
  actionIndex: number;
  children: React.ReactNode;
}) {
  return (
    <Box flexDirection="column" borderStyle="single" borderColor={active ? "white" : "gray"} paddingX={1} marginTop={1}>
      <Box justifyContent="space-between">
        <Text bold color={active ? "white" : "cyan"}>{active ? "✓ " : "  "}{title}</Text>
        {active && <Text dimColor><Text color="yellow">Keys:</Text> ←/→ buttons</Text>}
      </Box>
      <ActionButtons actions={actions} activeIndex={active ? actionIndex : -1} />
      <Box flexDirection="column" marginTop={1}>
        {children}
      </Box>
    </Box>
  );
}

function ActionButtons({ actions, activeIndex }: { actions: ActionButton[]; activeIndex: number }) {
  return (
    <Box gap={1} marginTop={1}>
      {actions.map((action, index) => {
        const selected = index === activeIndex;
        const disabled = Boolean(action.disabled);
        return (
          <Text
            key={action.id}
            color={selected ? "black" : disabled ? "gray" : "cyan"}
            backgroundColor={selected ? disabled ? "gray" : "cyan" : undefined}
            bold={selected || !disabled}
          >
            {" "}{action.label}{" "}
          </Text>
        );
      })}
    </Box>
  );
}

function OptionMenu({
  title,
  options,
  selectedIndex,
  currentValue,
}: {
  title: string;
  options: MenuOption[];
  selectedIndex: number;
  currentValue?: string;
}) {
  return (
    <Box flexDirection="column" borderStyle="round" borderColor="cyan" paddingX={2} paddingY={1} marginTop={1}>
      <Text bold>{title}</Text>
      <Text dimColor><Text color="yellow">Keys:</Text> ↑/↓ choose, Enter apply, Esc cancel</Text>
      {options.map((option, index) => {
        const selected = index === selectedIndex;
        const current = option.value === (currentValue ?? "");
        return (
          <Text
            key={option.value || "none"}
            color={selected ? "black" : current ? "cyan" : undefined}
            backgroundColor={selected ? "cyan" : undefined}
            bold={selected || current}
          >
            {selected ? "› " : "  "}{option.label}{current ? "  current" : ""}
          </Text>
        );
      })}
    </Box>
  );
}
