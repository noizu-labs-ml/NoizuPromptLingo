import React, { useState, useEffect } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner, TextInput, Select } from "@inkjs/ui";
import { useApiQuery, apiFetch, useIndexStatus } from "../hooks/useApi.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { ConfirmDialog } from "../components/ConfirmDialog.js";
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
  | "test-prompt"
  | "confirm-rebuild";

type Section = "index" | "embedding" | "llm";

const EMBEDDING_OPTIONS = [
  { label: "Local (MiniLM)", value: "local" },
  { label: "OpenAI", value: "openai" },
  { label: "Voyage", value: "voyage" },
  { label: "Anthropic", value: "anthropic" },
];

const LLM_OPTIONS = [
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

const API_TYPE_OPTIONS = [
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

export function SettingsPage() {
  const { rows } = useTerminalSize();

  const { data: configData, loading, refetch } = useApiQuery<{ data: AppConfig }>("/config");
  const { data: idxData, refetch: refetchIdx } = useIndexStatus();

  const [config, setConfig] = useState<AppConfig | null>(null);
  const [llmStatus, setLlmStatus] = useState<LlmStatus | null>(null);
  const [scanPreview, setScanPreview] = useState<ScanPreview | null>(null);
  const [uiMode, setUiMode] = useState<UIMode>("browse");
  const [section, setSection] = useState<Section>("index");
  const [dirty, setDirty] = useState(false);
  const [saving, setSaving] = useState(false);
  const [scanning, setScanning] = useState(false);
  const [reindexing, setReindexing] = useState(false);
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
  }, [saving]);

  const pathScroll = useScroll({
    totalItems: config?.indexPaths.length ?? 0,
    viewportHeight: Math.min(8, Math.max(3, rows - 20)),
    isActive: uiMode === "browse" && section === "index",
  });

  const showAction = (msg: string) => {
    setActionMsg(msg);
    setTimeout(() => setActionMsg(""), 2000);
  };

  useInput((input, key) => {
    if (uiMode !== "browse") {
      if (key.escape) setUiMode("browse");
      return;
    }

    if (input === "1") setSection("index");
    else if (input === "2") setSection("embedding");
    else if (input === "3") setSection("llm");
    else if (input === "s") handleSave();
    else if (section === "index") {
      if (input === "a") setUiMode("add-path");
      else if (input === "d" && config) {
        const updated = { ...config, indexPaths: config.indexPaths.filter((_, i) => i !== pathScroll.cursor) };
        setConfig(updated);
        setDirty(true);
      }
      else if (input === "p") handleScan();
      else if (input === "r") handleRebuild();
    }
    else if (section === "embedding") {
      if (input === "e") setUiMode("select-embedding");
    }
    else if (section === "llm") {
      if (input === "e") setUiMode("select-llm");
      else if (input === "m") setUiMode("llm-model");
      else if (input === "k") setUiMode("llm-key");
      else if (input === "b") setUiMode("llm-baseurl");
      else if (input === "y") setUiMode("llm-apitype");
      else if (input === "t") setUiMode("test-prompt");
    }
  }, { isActive: true });

  const handleSave = async () => {
    if (!config || !dirty) return;
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
    } catch {
      showAction("Scan failed");
    }
    setScanning(false);
  };

  const handleRebuild = async () => {
    setReindexing(true);
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
    try {
      const res = await apiFetch<{ data: { content: string } }>("/llm/complete", {
        method: "POST",
        body: JSON.stringify({ messages: [{ role: "user", content: msg }], maxTokens: 256 }),
      });
      setTestResponse(res.data.content);
    } catch (err: any) {
      setTestError(err.message ?? "Request failed");
    }
    setTesting(false);
    setUiMode("browse");
  };

  if (loading || !config) return <Spinner label="Loading settings..." />;

  const indexStatus = idxData?.data;
  const lastIndexed = indexStatus?.lastIndexed
    ? new Date(indexStatus.lastIndexed).toLocaleString()
    : "Never";
  const llmProvider = config.llm?.provider ?? "";
  const llmNeedsBaseUrl = llmProvider === "ollama" || llmProvider === "litellm" || llmProvider === "custom";

  return (
    <Box flexDirection="column">
      <Text bold color="cyan">Settings</Text>
      <Text dimColor>
        1:Index 2:Embedding 3:LLM s:save
        {dirty && <Text color="yellow"> [unsaved]</Text>}
      </Text>
      {actionMsg && <Text color="green">{actionMsg}</Text>}

      {/* Section tabs */}
      <Box gap={2} marginY={1}>
        {(["index", "embedding", "llm"] as Section[]).map((s) => (
          <Text key={s} bold={section === s} color={section === s ? "cyan" : undefined} dimColor={section !== s}>
            [{s === "index" ? "1" : s === "embedding" ? "2" : "3"}] {s.toUpperCase()}
          </Text>
        ))}
      </Box>

      {/* ── Index Section ── */}
      {section === "index" && (
        <Box flexDirection="column" borderStyle="single" borderColor="gray" paddingX={1}>
          <Text bold>Index & Watch Paths</Text>
          <Text dimColor>a:add d:remove p:preview-scan r:rebuild</Text>

          {/* Status */}
          <Box marginTop={1}>
            <Text>
              <Text color={reindexing ? "yellow" : "green"}>●</Text>
              {" "}{reindexing ? "Indexing..." : "Idle"}
              {" | "}{indexStatus?.conversationCount ?? 0} indexed
              {" | "}Last: {lastIndexed}
            </Text>
          </Box>

          {/* Paths */}
          {config.indexPaths.length === 0 && <Text dimColor italic>No paths configured. Press a to add ~/.claude/projects</Text>}
          {config.indexPaths.map((p, i) => (
            <Text key={i}>
              <Text color={pathScroll.cursor === i ? "cyan" : undefined} inverse={pathScroll.cursor === i}>
                {pathScroll.cursor === i ? "▸ " : "  "}{p}
              </Text>
            </Text>
          ))}

          {reindexing && <Spinner label="Rebuilding index..." />}
          {scanning && <Spinner label="Scanning..." />}

          {/* Scan preview */}
          {scanPreview && (
            <Box flexDirection="column" marginTop={1} borderStyle="single" borderColor="gray" paddingX={1}>
              <Text bold>Scan Preview</Text>
              <Text>
                <Text bold>{scanPreview.totalFiles}</Text> files total
                {" | "}<Text bold color="cyan">{scanPreview.totalNewFiles}</Text> new/changed
                {" | "}Cost: {scanPreview.embeddingProvider === "local" ? "Free" : `~$${scanPreview.estimatedCost.toFixed(4)}`}
              </Text>
              <Text dimColor>~{scanPreview.estimatedTokens.toLocaleString()} tokens to embed</Text>
              {scanPreview.projects.slice(0, 8).map((proj, i) => (
                <Text key={i} dimColor>
                  {"  "}{proj.projectPath.split("/").slice(-3).join("/")} — {proj.fileCount} files
                  {proj.newOrChanged > 0 && <Text color="cyan"> ({proj.newOrChanged} new)</Text>}
                </Text>
              ))}
              {scanPreview.projects.length > 8 && (
                <Text dimColor>  ...and {scanPreview.projects.length - 8} more projects</Text>
              )}
            </Box>
          )}
        </Box>
      )}

      {/* ── Embedding Section ── */}
      {section === "embedding" && (
        <Box flexDirection="column" borderStyle="single" borderColor="gray" paddingX={1}>
          <Text bold>Embedding Provider</Text>
          <Text dimColor>e:change provider</Text>
          <Text>Current: <Text color="cyan">{config.embedding.provider}</Text></Text>
          <Text dimColor>Local embeddings use all-MiniLM-L6-v2 (~25MB, CPU). No API key needed.</Text>
        </Box>
      )}

      {/* ── LLM Section ── */}
      {section === "llm" && (
        <Box flexDirection="column" borderStyle="single" borderColor="gray" paddingX={1}>
          <Box>
            <Text bold>LLM Inference</Text>
            {llmStatus && (
              <Text>
                {"  "}
                <Text color={llmStatus.available ? "green" : "yellow"}>●</Text>
                {" "}{llmStatus.available ? `${llmStatus.provider} connected` : "Not configured"}
              </Text>
            )}
          </Box>
          <Text dimColor>e:provider m:model k:api-key {llmNeedsBaseUrl ? "b:base-url " : ""}{llmProvider === "custom" ? "y:api-type " : ""}t:test</Text>

          <Text>Provider: <Text color="cyan">{llmProvider || "None"}</Text></Text>
          {config.llm?.model && <Text>Model: <Text color="cyan">{config.llm.model}</Text></Text>}
          {config.llm?.apiKey && <Text>API Key: <Text dimColor>***configured***</Text></Text>}
          {config.llm?.baseUrl && <Text>Base URL: <Text dimColor>{config.llm.baseUrl}</Text></Text>}
          {config.llm?.apiType && <Text>API Type: <Text dimColor>{config.llm.apiType}</Text></Text>}

          {/* Test results */}
          {testing && <Spinner label="Testing..." />}
          {testError && <Text color="red">Error: {testError}</Text>}
          {testResponse && (
            <Box flexDirection="column" marginTop={1} borderStyle="single" borderColor="green" paddingX={1}>
              <Text bold color="green">Response:</Text>
              <Text wrap="wrap">{testResponse}</Text>
            </Box>
          )}
        </Box>
      )}

      {/* ── Overlays ── */}
      {uiMode === "add-path" && (
        <InputModal
          label="New index path:"
          placeholder="~/.claude/projects"
          onSubmit={(path) => {
            if (path && config) {
              setConfig({ ...config, indexPaths: [...config.indexPaths, path] });
              setDirty(true);
            }
            setUiMode("browse");
          }}
          onCancel={() => setUiMode("browse")}
        />
      )}

      {uiMode === "select-embedding" && (
        <Box marginY={1}>
          <Select
            options={EMBEDDING_OPTIONS}
            defaultValue={config.embedding.provider}
            onChange={(v) => {
              setConfig({ ...config, embedding: { ...config.embedding, provider: v } });
              setDirty(true);
              setUiMode("browse");
            }}
          />
        </Box>
      )}

      {uiMode === "select-llm" && (
        <Box marginY={1}>
          <Select
            options={LLM_OPTIONS}
            defaultValue={llmProvider}
            onChange={(v) => {
              if (!v) {
                setConfig({ ...config, llm: undefined });
              } else {
                setConfig({ ...config, llm: { ...config.llm, provider: v } });
              }
              setDirty(true);
              setUiMode("browse");
            }}
          />
        </Box>
      )}

      {uiMode === "llm-model" && (
        <InputModal
          label="Model name:"
          defaultValue={config.llm?.model ?? ""}
          placeholder={MODEL_PLACEHOLDERS[llmProvider] ?? "model-name"}
          onSubmit={(v) => {
            setConfig({ ...config, llm: { ...config.llm!, model: v || undefined } });
            setDirty(true);
            setUiMode("browse");
          }}
          onCancel={() => setUiMode("browse")}
        />
      )}

      {uiMode === "llm-key" && (
        <InputModal
          label="API Key:"
          placeholder="Enter API key (or set via env var)"
          onSubmit={(v) => {
            setConfig({ ...config, llm: { ...config.llm!, apiKey: v || undefined } });
            setDirty(true);
            setUiMode("browse");
          }}
          onCancel={() => setUiMode("browse")}
        />
      )}

      {uiMode === "llm-baseurl" && (
        <InputModal
          label="Base URL:"
          defaultValue={config.llm?.baseUrl ?? ""}
          placeholder="http://localhost:11434"
          onSubmit={(v) => {
            setConfig({ ...config, llm: { ...config.llm!, baseUrl: v || undefined } });
            setDirty(true);
            setUiMode("browse");
          }}
          onCancel={() => setUiMode("browse")}
        />
      )}

      {uiMode === "llm-apitype" && (
        <Box marginY={1}>
          <Select
            options={API_TYPE_OPTIONS}
            defaultValue={config.llm?.apiType ?? "openai"}
            onChange={(v) => {
              setConfig({ ...config, llm: { ...config.llm!, apiType: v as "openai" | "anthropic" } });
              setDirty(true);
              setUiMode("browse");
            }}
          />
        </Box>
      )}

      {uiMode === "test-prompt" && (
        <InputModal
          label="Test prompt (leave blank for default):"
          placeholder="Say hello in one sentence"
          onSubmit={handleTestLlm}
          onCancel={() => setUiMode("browse")}
        />
      )}

      {/* Save reminder */}
      <Box marginTop={1}>
        <Text dimColor>s:save settings</Text>
        {saving && <Spinner label=" Saving..." />}
      </Box>
    </Box>
  );
}
