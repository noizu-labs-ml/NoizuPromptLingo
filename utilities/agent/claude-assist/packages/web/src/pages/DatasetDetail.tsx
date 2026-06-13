import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { apiFetch } from "../hooks/useApi.js";

interface DatasetEntry {
  id: string;
  conversationId: string;
  quality: string;
  messages: Array<{ role: string; content: string }>;
  createdAt: string;
}

interface Dataset {
  name: string;
  description: string;
  entryCount: number;
}

export function DatasetDetail() {
  const { name } = useParams<{ name: string }>();
  const navigate = useNavigate();
  const [dataset, setDataset] = useState<Dataset | null>(null);
  const [entries, setEntries] = useState<DatasetEntry[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!name) return;
    Promise.all([
      apiFetch<{ data: Dataset }>(`/datasets/${name}`),
      apiFetch<{ data: DatasetEntry[] }>(`/datasets/${name}/entries`),
    ]).then(([dsRes, entryRes]) => {
      setDataset(dsRes.data);
      setEntries(entryRes.data);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, [name]);

  const handleExport = (format: string) => {
    window.open(`/api/datasets/${name}/export?format=${format}`);
  };

  const handleDelete = async (entryId: string) => {
    await apiFetch(`/datasets/${name}/entries/${entryId}`, { method: "DELETE" });
    setEntries(entries.filter((e) => e.id !== entryId));
  };

  const qualityColor: Record<string, string> = {
    gold: "text-yellow-400",
    silver: "text-gray-400",
    bronze: "text-orange-400",
  };

  if (loading) return <div className="mx-auto max-w-4xl"><p className="text-sm text-text-muted">Loading...</p></div>;

  return (
    <div className="mx-auto max-w-4xl space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-medium text-text-bright">{dataset?.name}</h1>
          {dataset?.description && <p className="text-sm text-text-muted mt-1">{dataset.description}</p>}
        </div>
        <div className="flex gap-2">
          <button onClick={() => handleExport("openai")} className="rounded bg-surface-active px-3 py-1 text-xs text-text-muted hover:text-text-primary">
            Export OpenAI
          </button>
          <button onClick={() => handleExport("anthropic")} className="rounded bg-surface-active px-3 py-1 text-xs text-text-muted hover:text-text-primary">
            Export Anthropic
          </button>
          <button onClick={() => handleExport("jsonl")} className="rounded bg-surface-active px-3 py-1 text-xs text-text-muted hover:text-text-primary">
            Export JSONL
          </button>
        </div>
      </div>

      {entries.length === 0 ? (
        <p className="text-sm text-text-muted">No entries yet. Open a conversation and tag message ranges as training data.</p>
      ) : (
        <div className="space-y-3">
          {entries.map((entry) => (
            <div key={entry.id} className="rounded-md border border-border-subtle bg-surface p-4">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <span className={`text-xs font-medium ${qualityColor[entry.quality] ?? "text-text-dim"}`}>
                    {entry.quality}
                  </span>
                  <span className="font-mono text-xs text-text-dim">{entry.conversationId.slice(0, 8)}</span>
                </div>
                <button onClick={() => handleDelete(entry.id)} className="text-xs text-red-400 hover:text-red-300">
                  Delete
                </button>
              </div>
              <div className="space-y-1">
                {entry.messages.slice(0, 3).map((m, i) => (
                  <div key={i} className="text-xs">
                    <span className={m.role === "user" ? "text-glow" : "text-text-primary"}>{m.role}:</span>{" "}
                    <span className="text-text-muted">{m.content.slice(0, 100)}</span>
                  </div>
                ))}
                {entry.messages.length > 3 && (
                  <p className="text-xs text-text-dim">...and {entry.messages.length - 3} more messages</p>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      <button onClick={() => navigate("/datasets")} className="text-xs text-text-muted hover:text-text-primary">
        Back to datasets
      </button>
    </div>
  );
}
