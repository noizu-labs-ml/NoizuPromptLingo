import React, { useState, useEffect } from "react";
import { apiFetch, useIndexStatus } from "../hooks/useApi.js";

interface LlmConfig {
  provider: string;
  model?: string;
  apiKey?: string;
  baseUrl?: string;
  apiType?: "openai" | "anthropic";
}

interface AppConfig {
  indexPaths: string[];
  embedding: { provider: string; model?: string; apiKey?: string };
  llm?: LlmConfig;
  server: { port: number; host: string };
}

interface LlmStatus {
  available: boolean;
  provider: string;
}

interface ScanProject {
  projectPath: string;
  encodedDir: string;
  fileCount: number;
  newOrChanged: number;
}

interface ScanPreview {
  watchPaths: string[];
  projects: ScanProject[];
  totalFiles: number;
  totalNewFiles: number;
  embeddingProvider: string;
  estimatedTokens: number;
  estimatedCost: number;
}

export function Settings() {
  const [config, setConfig] = useState<AppConfig | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [reindexing, setReindexing] = useState(false);
  const [newPath, setNewPath] = useState("");
  const [llmStatus, setLlmStatus] = useState<LlmStatus | null>(null);
  const [scanPreview, setScanPreview] = useState<ScanPreview | null>(null);
  const [scanning, setScanning] = useState(false);
  const [excludedProjects, setExcludedProjects] = useState<Set<string>>(new Set());
  const [browsingPath, setBrowsingPath] = useState(false);
  const [dirEntries, setDirEntries] = useState<string[]>([]);
  const [browseBase, setBrowseBase] = useState("");
  const [testPrompt, setTestPrompt] = useState("");
  const [testResponse, setTestResponse] = useState<string | null>(null);
  const [testError, setTestError] = useState<string | null>(null);
  const [testing, setTesting] = useState(false);
  const [availableModels, setAvailableModels] = useState<string[]>([]);
  const [loadingModels, setLoadingModels] = useState(false);
  const { data: idxData, refetch: refetchIndex } = useIndexStatus();
  const indexStatus = idxData?.data;

  useEffect(() => {
    const defaults: AppConfig = {
      indexPaths: [],
      embedding: { provider: "local", model: "all-MiniLM-L6-v2" },
      server: { port: 3100, host: "localhost" },
    };
    apiFetch<{ data: AppConfig }>("/config")
      .then((res) => {
        setConfig(res.data);
        setLoading(false);
      })
      .catch(() => {
        setConfig(defaults);
        setLoading(false);
      });
  }, []);

  useEffect(() => {
    apiFetch<{ data: LlmStatus }>("/llm/status")
      .then((res) => {
        setLlmStatus(res.data);
        if (res.data.available) {
          apiFetch<{ data: string[] }>("/llm/models")
            .then((r) => setAvailableModels(r.data))
            .catch(() => {});
        }
      })
      .catch(() => {});
  }, [saving]);

  const fetchModels = () => {
    if (!config?.llm?.provider) return;
    setLoadingModels(true);
    apiFetch<{ data: string[] }>("/llm/models", {
      method: "POST",
      body: JSON.stringify(config.llm),
    })
      .then((res) => setAvailableModels(res.data))
      .catch(() => setAvailableModels([]))
      .finally(() => setLoadingModels(false));
  };

  const handleSave = async () => {
    if (!config) return;
    setSaving(true);
    try {
      const res = await apiFetch<{ data: AppConfig }>("/config", {
        method: "PATCH",
        body: JSON.stringify(config),
      });
      setConfig(res.data);
    } catch {
      // Error handling would go here
    }
    setSaving(false);
  };

  const handleScan = async () => {
    setScanning(true);
    try {
      const res = await apiFetch<{ data: ScanPreview }>("/index/preview");
      setScanPreview(res.data);
    } catch {
      // Error handling
    }
    setScanning(false);
  };

  const handleReindex = async () => {
    setReindexing(true);
    try {
      await apiFetch("/index/rebuild", { method: "POST" });
      const pollInterval = setInterval(async () => {
        try {
          const res = await apiFetch<{ data: { status: string; progress?: { phase: string; current: number; total: number; currentFile?: string } } }>("/index/status");
          refetchIndex();
          if (res.data.status === "idle" && (!res.data.progress || res.data.progress.phase === "idle")) {
            clearInterval(pollInterval);
            setReindexing(false);
            setScanPreview(null);
          }
        } catch {
          clearInterval(pollInterval);
          setReindexing(false);
        }
      }, 1500);
    } catch {
      setReindexing(false);
    }
  };

  const toggleProjectExclude = (projectPath: string) => {
    setExcludedProjects((prev) => {
      const next = new Set(prev);
      if (next.has(projectPath)) next.delete(projectPath); else next.add(projectPath);
      return next;
    });
  };

  const addPath = () => {
    if (!config || !newPath.trim()) return;
    setConfig({ ...config, indexPaths: [...config.indexPaths, newPath.trim()] });
    setNewPath("");
  };

  const removePath = (idx: number) => {
    if (!config) return;
    setConfig({ ...config, indexPaths: config.indexPaths.filter((_, i) => i !== idx) });
  };

  const updateEmbedding = (updates: Partial<AppConfig["embedding"]>) => {
    if (!config) return;
    setConfig({ ...config, embedding: { ...config.embedding, ...updates } });
  };

  const updateLlm = (updates: Partial<LlmConfig>) => {
    if (!config) return;
    setConfig({ ...config, llm: { ...config.llm, provider: config.llm?.provider ?? "", ...updates } });
  };

  const handleTestLlm = async () => {
    setTesting(true);
    setTestError(null);
    setTestResponse(null);
    const prompt = testPrompt.trim() || "Say hello in one sentence";
    try {
      const res = await apiFetch<{ data: { content: string; model: string; provider: string } }>("/llm/complete", {
        method: "POST",
        body: JSON.stringify({ messages: [{ role: "user", content: prompt }], maxTokens: 256 }),
      });
      setTestResponse(res.data.content);
    } catch (err) {
      setTestError(err instanceof Error ? err.message : "Request failed — is the API running and LLM configured?");
    }
    setTesting(false);
  };

  if (loading) {
    return <div className="mx-auto max-w-3xl"><p className="text-sm text-text-muted">Loading...</p></div>;
  }

  const embeddingNeedsKey = config?.embedding.provider && config.embedding.provider !== "local";
  const llmProvider = config?.llm?.provider ?? "";
  const llmNeedsKey = llmProvider && llmProvider !== "ollama";
  const llmNeedsBaseUrl = llmProvider === "ollama" || llmProvider === "litellm" || llmProvider === "custom";
  const llmIsCustom = llmProvider === "custom";

  const ENV_KEY_NAMES: Record<string, string> = {
    anthropic: "ANTHROPIC_API_KEY",
    openai: "OPENAI_API_KEY",
    groq: "GROQ_API_KEY",
    cerebras: "CEREBRAS_API_KEY",
    deepseek: "DEEPSEEK_API_KEY",
    zai: "ZAI_API_KEY",
    litellm: "LITELLM_API_KEY",
  };

  const MODEL_PLACEHOLDERS: Record<string, string> = {
    anthropic: "claude-sonnet-4-20250514",
    openai: "gpt-4o",
    ollama: "llama3",
    litellm: "claude-sonnet-4-6",
    groq: "llama-3.3-70b",
    cerebras: "llama-3.3-70b",
    deepseek: "deepseek-chat",
    zai: "glm-4",
    custom: "model-name",
  };

  const BASE_URL_PLACEHOLDERS: Record<string, string> = {
    ollama: "http://localhost:11434",
    litellm: "https://inference.noizu.com/v1",
    custom: "https://api.example.com/v1",
  };

  return (
    <div className="mx-auto max-w-3xl">
      <h1 className="mb-6 text-xl font-medium text-text-bright">Settings</h1>
      <div className="space-y-6">
        {/* Index Configuration */}
        <section className="rounded-md border border-border-subtle bg-surface p-6 space-y-5">
          <div>
            <h2 className="text-base font-medium text-text-primary">Index &amp; Embeddings</h2>
            <p className="mt-1 text-xs text-text-dim">
              Scans watch paths for Claude Code JSONL conversation files, imports metadata into SQLite, and generates text embeddings for semantic search. Already-indexed conversations are skipped unless the file has changed. Tags, project metadata, and prompts are preserved across rebuilds.
            </p>
          </div>

          {/* Current status */}
          <div className="rounded-md bg-canvas px-4 py-3 space-y-2">
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <span className={`h-2 w-2 rounded-full ${indexStatus?.status === "indexing" ? "bg-yellow-400 animate-pulse" : "bg-green-400"}`} />
                <span className="text-xs text-text-primary font-medium">
                  {indexStatus?.status === "indexing" ? "Indexing..." : "Idle"}
                </span>
              </div>
              <span className="text-xs text-text-dim">
                {indexStatus?.conversationCount ?? 0} conversations indexed
              </span>
              {indexStatus?.lastIndexed && (
                <span className="text-xs text-text-dim">
                  Last: {new Date(indexStatus.lastIndexed).toLocaleString()}
                </span>
              )}
            </div>

            {/* Progress bar during indexing */}
            {reindexing && indexStatus?.progress && indexStatus.progress.phase !== "idle" && (
              <div className="space-y-1">
                <div className="flex items-center justify-between text-xs text-text-dim">
                  <span>
                    {indexStatus.progress.phase === "scanning" ? "Scanning files..." : `Indexing ${indexStatus.progress.current} / ${indexStatus.progress.total}`}
                  </span>
                  {indexStatus.progress.currentFile && (
                    <span className="truncate max-w-xs font-mono text-text-dim">{indexStatus.progress.currentFile}</span>
                  )}
                </div>
                <div className="h-1.5 w-full rounded-full bg-surface-active overflow-hidden">
                  <div
                    className="h-full rounded-full bg-glow transition-all duration-300"
                    style={{ width: indexStatus.progress.total > 0 ? `${(indexStatus.progress.current / indexStatus.progress.total) * 100}%` : "0%" }}
                  />
                </div>
              </div>
            )}
          </div>

          {/* Watch paths */}
          <div>
            <label className="block text-xs text-text-muted mb-2 font-medium">Watch Paths</label>
            <div className="space-y-1.5 mb-3">
              {config?.indexPaths.map((path, i) => (
                <div key={i} className="flex items-center gap-2">
                  <code className="flex-1 rounded bg-canvas px-3 py-1.5 text-xs text-text-muted font-mono">{path}</code>
                  <button onClick={() => removePath(i)} className="text-xs text-red-400 hover:text-red-300 transition-colors">Remove</button>
                </div>
              ))}
              {(!config?.indexPaths || config.indexPaths.length === 0) && (
                <p className="text-xs text-text-dim italic">No watch paths configured. Add ~/.claude/projects to get started.</p>
              )}
            </div>

            <div className="flex gap-2">
              <input
                type="text"
                value={newPath}
                onChange={(e) => setNewPath(e.target.value)}
                placeholder="~/.claude/projects or /path/to/conversations"
                className="flex-1 rounded bg-canvas px-3 py-1.5 text-sm text-text-primary placeholder:text-text-dim outline-none border border-border-subtle focus:border-glow"
                onKeyDown={(e) => { if (e.key === "Enter") addPath(); }}
              />
              <button onClick={addPath} className="rounded bg-surface-active px-3 py-1 text-xs text-text-muted hover:text-text-primary transition-colors">
                Add
              </button>
            </div>
          </div>

          {/* Scan + Rebuild */}
          <div className="space-y-3">
            <div className="flex items-center gap-3">
              <button
                onClick={handleScan}
                disabled={scanning || reindexing}
                className="rounded border border-border-subtle px-4 py-1.5 text-sm text-text-muted hover:text-text-primary hover:border-glow transition-colors disabled:opacity-50"
              >
                {scanning ? "Scanning..." : "Preview Scan"}
              </button>
              <button
                onClick={handleReindex}
                disabled={reindexing || scanning}
                className="rounded bg-glow px-4 py-1.5 text-sm font-medium text-void hover:bg-glow/90 disabled:opacity-50"
              >
                {reindexing ? "Rebuilding..." : "Rebuild Index"}
              </button>
            </div>

            {/* Scan preview results */}
            {scanPreview && (
              <div className="rounded-md border border-border-subtle bg-canvas p-4 space-y-4">
                <div className="flex items-baseline justify-between">
                  <h3 className="text-sm font-medium text-text-primary">Scan Preview</h3>
                  <button onClick={() => setScanPreview(null)} className="text-xs text-text-dim hover:text-text-muted">Dismiss</button>
                </div>

                {/* Summary stats */}
                <div className="grid grid-cols-3 gap-3">
                  <div className="rounded bg-surface-raised p-2.5 text-center">
                    <p className="font-mono text-lg text-white">{scanPreview.totalFiles}</p>
                    <p className="text-xs text-text-dim">Total Files</p>
                  </div>
                  <div className="rounded bg-surface-raised p-2.5 text-center">
                    <p className="font-mono text-lg text-glow">{scanPreview.totalNewFiles}</p>
                    <p className="text-xs text-text-dim">New / Changed</p>
                  </div>
                  <div className="rounded bg-surface-raised p-2.5 text-center">
                    <p className="font-mono text-lg text-white">
                      {scanPreview.embeddingProvider === "local" ? "Free" : `~$${scanPreview.estimatedCost.toFixed(4)}`}
                    </p>
                    <p className="text-xs text-text-dim">
                      Est. Cost ({scanPreview.embeddingProvider})
                    </p>
                  </div>
                </div>

                {scanPreview.totalNewFiles > 0 && (
                  <p className="text-xs text-text-dim">
                    ~{scanPreview.estimatedTokens.toLocaleString()} tokens across {scanPreview.totalNewFiles} conversations will be embedded.
                    {scanPreview.totalFiles - scanPreview.totalNewFiles > 0 && (
                      <> {scanPreview.totalFiles - scanPreview.totalNewFiles} already indexed (skipped).</>
                    )}
                  </p>
                )}

                {/* Project list with checkboxes */}
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <label className="text-xs text-text-muted font-medium">Projects ({scanPreview.projects.length})</label>
                    <div className="flex gap-2">
                      <button onClick={() => setExcludedProjects(new Set())} className="text-xs text-glow hover:underline">Include All</button>
                      <button onClick={() => setExcludedProjects(new Set(scanPreview.projects.map((p) => p.projectPath)))} className="text-xs text-text-dim hover:text-text-muted">Exclude All</button>
                    </div>
                  </div>
                  <div className="max-h-60 overflow-y-auto space-y-1 rounded border border-border-subtle bg-void p-2">
                    {scanPreview.projects.map((proj) => {
                      const excluded = excludedProjects.has(proj.projectPath);
                      const shortPath = proj.projectPath.split("/").slice(-3).join("/");
                      return (
                        <label
                          key={proj.projectPath}
                          className={`flex items-center gap-2 rounded px-2 py-1.5 cursor-pointer transition-colors ${excluded ? "opacity-40" : "hover:bg-surface-active"}`}
                        >
                          <input
                            type="checkbox"
                            checked={!excluded}
                            onChange={() => toggleProjectExclude(proj.projectPath)}
                            className="accent-cyan-400 shrink-0"
                          />
                          <span className="flex-1 text-xs text-text-primary font-mono truncate" title={proj.projectPath}>{shortPath}</span>
                          <span className="text-xs text-text-dim shrink-0">{proj.fileCount} files</span>
                          {proj.newOrChanged > 0 && (
                            <span className="text-xs text-glow shrink-0">{proj.newOrChanged} new</span>
                          )}
                        </label>
                      );
                    })}
                  </div>
                  {excludedProjects.size > 0 && (
                    <p className="mt-1 text-xs text-yellow-400">
                      {excludedProjects.size} project{excludedProjects.size !== 1 ? "s" : ""} excluded — these will be skipped during rebuild.
                    </p>
                  )}
                </div>
              </div>
            )}
          </div>
        </section>

        {/* Embedding Provider */}
        <section className="rounded-md border border-border-subtle bg-surface p-6">
          <h2 className="mb-4 text-base font-medium text-text-primary">Embedding Provider</h2>
          <select
            value={config?.embedding.provider ?? "local"}
            onChange={(e) => updateEmbedding({ provider: e.target.value })}
            className="rounded bg-canvas px-3 py-1.5 text-sm text-text-primary border border-border-subtle outline-none"
          >
            <option value="local">Local (Transformers.js)</option>
            <option value="openai">OpenAI</option>
            <option value="voyage">Voyage</option>
            <option value="anthropic">Anthropic</option>
          </select>
          <p className="mt-2 text-xs text-text-dim">
            Local embeddings use all-MiniLM-L6-v2 (~25MB, runs on CPU). No API key required.
          </p>

          {embeddingNeedsKey && (
            <div className="mt-4">
              <label className="block text-xs text-text-muted mb-1">API Key</label>
              <input
                type="password"
                value={config?.embedding.apiKey ?? ""}
                onChange={(e) => updateEmbedding({ apiKey: e.target.value })}
                placeholder="Enter API key (or set via environment variable)"
                className="w-full rounded bg-canvas px-3 py-1.5 text-sm text-text-primary placeholder:text-text-dim outline-none border border-border-subtle"
              />
              <p className="mt-1 text-xs text-text-dim">
                Can also be set via ANTHROPIC_API_KEY or OPENAI_API_KEY environment variable.
              </p>
            </div>
          )}
        </section>

        {/* LLM Provider */}
        <section className="rounded-md border border-border-subtle bg-surface p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-base font-medium text-text-primary">LLM Inference</h2>
            {llmStatus && (
              <span className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium ${
                llmStatus.available
                  ? "bg-green-900/30 text-green-400"
                  : "bg-yellow-900/30 text-yellow-400"
              }`}>
                <span className={`h-1.5 w-1.5 rounded-full ${llmStatus.available ? "bg-green-400" : "bg-yellow-400"}`} />
                {llmStatus.available ? `${llmStatus.provider} connected` : "Not configured"}
              </span>
            )}
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-xs text-text-muted mb-1">Provider</label>
              <select
                value={llmProvider}
                onChange={(e) => {
                  if (!config) return;
                  const val = e.target.value;
                  setAvailableModels([]);
                  if (!val) {
                    setConfig({ ...config, llm: undefined });
                  } else {
                    setConfig({ ...config, llm: { ...config.llm, provider: val, model: undefined } });
                  }
                }}
                className="rounded bg-canvas px-3 py-1.5 text-sm text-text-primary border border-border-subtle outline-none"
              >
                <option value="">None</option>
                <option disabled className="text-text-dim">{"── Cloud Providers ──"}</option>
                <option value="anthropic">Anthropic (Claude)</option>
                <option value="openai">OpenAI</option>
                <option value="deepseek">DeepSeek</option>
                <option value="groq">Groq</option>
                <option value="cerebras">Cerebras</option>
                <option value="zai">Z.ai (Zhipu/GLM)</option>
                <option disabled className="text-text-dim">{"── Proxies & Local ──"}</option>
                <option value="litellm">LiteLLM Proxy</option>
                <option value="ollama">Ollama (Local)</option>
                <option disabled className="text-text-dim">{"── Advanced ──"}</option>
                <option value="custom">Custom Endpoint</option>
              </select>
            </div>

            {llmProvider && (
              <>
                {llmIsCustom && (
                  <div>
                    <label className="block text-xs text-text-muted mb-1">API Type</label>
                    <select
                      value={config?.llm?.apiType ?? "openai"}
                      onChange={(e) => updateLlm({ apiType: e.target.value as "openai" | "anthropic" })}
                      className="rounded bg-canvas px-3 py-1.5 text-sm text-text-primary border border-border-subtle outline-none"
                    >
                      <option value="openai">OpenAI-compatible</option>
                      <option value="anthropic">Anthropic-compatible</option>
                    </select>
                  </div>
                )}

                {llmNeedsKey && (
                  <div>
                    <label className="block text-xs text-text-muted mb-1">API Key</label>
                    <input
                      type="password"
                      value={config?.llm?.apiKey ?? ""}
                      onChange={(e) => updateLlm({ apiKey: e.target.value || undefined })}
                      placeholder="Enter API key (or set via environment variable)"
                      className="w-full rounded bg-canvas px-3 py-1.5 text-sm text-text-primary placeholder:text-text-dim outline-none border border-border-subtle"
                    />
                    {ENV_KEY_NAMES[llmProvider] && (
                      <p className="mt-1 text-xs text-text-dim">
                        Can also be set via {ENV_KEY_NAMES[llmProvider]} environment variable.
                      </p>
                    )}
                  </div>
                )}

                {llmNeedsBaseUrl && (
                  <div>
                    <label className="block text-xs text-text-muted mb-1">Base URL</label>
                    <input
                      type="text"
                      value={config?.llm?.baseUrl ?? ""}
                      onChange={(e) => updateLlm({ baseUrl: e.target.value || undefined })}
                      placeholder={BASE_URL_PLACEHOLDERS[llmProvider] ?? "https://api.example.com/v1"}
                      className="w-full rounded bg-canvas px-3 py-1.5 text-sm text-text-primary placeholder:text-text-dim outline-none border border-border-subtle"
                    />
                  </div>
                )}

                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="block text-xs text-text-muted">Model</label>
                    <button
                      onClick={fetchModels}
                      disabled={loadingModels}
                      className="text-xs text-glow hover:underline disabled:opacity-50"
                    >
                      {loadingModels ? "Loading..." : availableModels.length > 0 ? "Refresh models" : "Fetch models"}
                    </button>
                  </div>
                  {availableModels.length > 0 ? (
                    <>
                      <select
                        value={config?.llm?.model ?? ""}
                        onChange={(e) => updateLlm({ model: e.target.value || undefined })}
                        className="w-full rounded bg-canvas px-3 py-1.5 text-sm text-text-primary border border-border-subtle outline-none"
                      >
                        <option value="">Default ({MODEL_PLACEHOLDERS[llmProvider] ?? "auto"})</option>
                        {availableModels.map((m) => (
                          <option key={m} value={m}>{m}</option>
                        ))}
                      </select>
                      <div className="flex items-center gap-2 mt-2">
                        <input
                          type="text"
                          value={config?.llm?.model ?? ""}
                          onChange={(e) => updateLlm({ model: e.target.value || undefined })}
                          placeholder="Or type a model name manually"
                          className="flex-1 rounded bg-canvas px-3 py-1.5 text-xs text-text-primary placeholder:text-text-dim outline-none border border-border-subtle"
                        />
                      </div>
                      <p className="mt-1 text-xs text-text-dim">
                        {availableModels.length} model{availableModels.length !== 1 ? "s" : ""} available. Select from list or type a custom name.
                      </p>
                    </>
                  ) : (
                    <>
                      <input
                        type="text"
                        value={config?.llm?.model ?? ""}
                        onChange={(e) => updateLlm({ model: e.target.value || undefined })}
                        placeholder={MODEL_PLACEHOLDERS[llmProvider] ?? "model-name"}
                        className="w-full rounded bg-canvas px-3 py-1.5 text-sm text-text-primary placeholder:text-text-dim outline-none border border-border-subtle"
                      />
                      <p className="mt-1 text-xs text-text-dim">
                        {loadingModels ? "Fetching available models..." : "Save settings and click \"Fetch models\" to populate the dropdown, or type a model name."}
                      </p>
                    </>
                  )}
                </div>

                {/* Test Connection */}
                <div className="rounded-md border border-border-subtle bg-canvas p-4 space-y-3">
                  <label className="block text-xs text-text-muted font-medium">Test Connection</label>
                  <div className="flex gap-2">
                    <input
                      type="text"
                      value={testPrompt}
                      onChange={(e) => setTestPrompt(e.target.value)}
                      placeholder="Say hello in one sentence"
                      onKeyDown={(e) => {
                        if (e.key === "Enter" && !testing) handleTestLlm();
                      }}
                      className="flex-1 rounded bg-void px-3 py-1.5 text-sm text-text-primary placeholder:text-text-dim outline-none border border-border-subtle focus:border-glow"
                    />
                    <button
                      onClick={handleTestLlm}
                      disabled={testing}
                      className="rounded bg-glow px-4 py-1.5 text-sm font-medium text-void hover:bg-glow/90 disabled:opacity-50 whitespace-nowrap"
                    >
                      {testing ? "Sending..." : "Test"}
                    </button>
                  </div>
                  {testError && (
                    <div className="rounded bg-red-950/30 border border-red-900/50 px-3 py-2">
                      <p className="text-xs text-red-400">{testError}</p>
                    </div>
                  )}
                  {testResponse && (
                    <div className="rounded bg-void border border-border-subtle px-3 py-2">
                      <p className="text-xs text-text-muted mb-1 font-medium">Response:</p>
                      <p className="text-sm text-text-primary whitespace-pre-wrap">{testResponse}</p>
                    </div>
                  )}
                  <p className="text-xs text-text-dim">
                    Save settings first, then send a test message to verify the provider is reachable.
                  </p>
                </div>
              </>
            )}
          </div>
        </section>

        {/* Save */}
        <div className="flex justify-end">
          <button
            onClick={handleSave}
            disabled={saving}
            className="rounded bg-glow px-6 py-2 text-sm font-medium text-void hover:bg-glow/90 disabled:opacity-50"
          >
            {saving ? "Saving..." : "Save Settings"}
          </button>
        </div>
      </div>
    </div>
  );
}
