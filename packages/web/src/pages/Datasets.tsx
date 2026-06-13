import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { apiFetch } from "../hooks/useApi.js";

interface Dataset {
  name: string;
  description: string;
  version: number;
  entryCount: number;
  createdAt: string;
  updatedAt: string;
}

export function Datasets() {
  const navigate = useNavigate();
  const [datasets, setDatasets] = useState<Dataset[]>([]);
  const [loading, setLoading] = useState(true);
  const [showCreate, setShowCreate] = useState(false);
  const [newName, setNewName] = useState("");
  const [newDesc, setNewDesc] = useState("");

  useEffect(() => {
    apiFetch<{ data: Dataset[] }>("/datasets")
      .then((res) => { setDatasets(res.data); setLoading(false); })
      .catch(() => setLoading(false));
  }, []);

  const handleCreate = async () => {
    if (!newName.trim()) return;
    await apiFetch("/datasets", {
      method: "POST",
      body: JSON.stringify({ name: newName.trim(), description: newDesc }),
    });
    setShowCreate(false);
    setNewName("");
    setNewDesc("");
    const res = await apiFetch<{ data: Dataset[] }>("/datasets");
    setDatasets(res.data);
  };

  return (
    <div className="mx-auto max-w-4xl space-y-6">
      <div>
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-medium text-white">Datasets</h1>
          <button
          onClick={() => setShowCreate(!showCreate)}
          className="rounded bg-glow px-4 py-1.5 text-sm font-medium text-void hover:bg-glow/90"
        >
          New Dataset
        </button>
        </div>
        <p className="mt-1 text-sm text-text-muted">Tag message ranges from conversations as fine-tuning data. Curate quality labels and export in OpenAI, Anthropic, or JSONL formats.</p>
      </div>

      {showCreate && (
        <div className="rounded-md border border-glow/30 bg-surface p-4 space-y-3">
          <input
            type="text"
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            placeholder="Dataset name..."
            className="w-full rounded bg-canvas px-3 py-1.5 text-sm text-text-primary placeholder:text-text-dim outline-none border border-border-subtle"
          />
          <input
            type="text"
            value={newDesc}
            onChange={(e) => setNewDesc(e.target.value)}
            placeholder="Description (optional)..."
            className="w-full rounded bg-canvas px-3 py-1.5 text-sm text-text-primary placeholder:text-text-dim outline-none border border-border-subtle"
          />
          <button onClick={handleCreate} className="rounded bg-glow px-4 py-1.5 text-sm font-medium text-void">
            Create
          </button>
        </div>
      )}

      {loading ? (
        <p className="text-sm text-text-muted">Loading...</p>
      ) : datasets.length === 0 ? (
        <p className="text-sm text-text-muted">No datasets yet. Create one to start tagging training data.</p>
      ) : (
        <div className="space-y-3">
          {datasets.map((ds) => (
            <button
              key={ds.name}
              onClick={() => navigate(`/datasets/${ds.name}`)}
              className="block w-full rounded-md border border-border-subtle bg-surface p-4 text-left hover:border-glow/30 transition-colors"
            >
              <div className="flex items-center justify-between mb-1">
                <span className="text-sm font-medium text-text-bright">{ds.name}</span>
                <span className="text-xs text-text-dim">v{ds.version}</span>
              </div>
              {ds.description && <p className="text-xs text-text-muted mb-2">{ds.description}</p>}
              <div className="flex gap-4 text-xs text-text-dim">
                <span>{ds.entryCount} entries</span>
                <span>Updated {new Date(ds.updatedAt).toLocaleDateString()}</span>
              </div>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
