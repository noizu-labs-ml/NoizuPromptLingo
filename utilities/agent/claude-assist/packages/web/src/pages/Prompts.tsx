import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { apiFetch } from "../hooks/useApi.js";

interface SavedPrompt {
  id: string;
  title: string;
  content: string;
  role: string;
  tags: string[];
  evals: Record<string, unknown> | null;
  sourceConversationId?: string;
  createdAt: string;
}

export function Prompts() {
  const navigate = useNavigate();
  const [prompts, setPrompts] = useState<SavedPrompt[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("");

  const reload = () => {
    apiFetch<{ data: SavedPrompt[] }>("/prompts")
      .then((res) => { setPrompts(res.data); setLoading(false); })
      .catch(() => setLoading(false));
  };

  useEffect(reload, []);

  const filtered = filter
    ? prompts.filter((p) =>
        p.title.toLowerCase().includes(filter.toLowerCase()) ||
        p.content.toLowerCase().includes(filter.toLowerCase()) ||
        p.tags.some((t) => t.toLowerCase().includes(filter.toLowerCase()))
      )
    : prompts;

  return (
    <div className="mx-auto max-w-4xl space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-medium text-white">Saved Prompts</h1>
          <p className="mt-1 text-sm text-text-muted">Reusable messages saved from conversations. Add eval criteria to define expected outcomes, tag for organization, and copy to reuse.</p>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-xs text-text-muted">{prompts.length} prompts</span>
          <button
            onClick={async () => {
              const title = prompt("New prompt title:");
              if (!title) return;
              const content = prompt("Prompt content:");
              if (!content) return;
              await apiFetch("/prompts", { method: "POST", body: JSON.stringify({ title, content, role: "user" }) });
              reload();
            }}
            className="btn-action-primary text-xs"
            title="Create a new prompt from scratch"
          >
            + New Prompt
          </button>
        </div>
      </div>

      <input
        type="text"
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        placeholder="Filter prompts..."
        className="w-full rounded-md border border-border-subtle bg-void px-3 py-2 text-sm text-text-primary placeholder:text-text-dim outline-none focus:border-glow"
      />

      {loading ? (
        <p className="text-sm text-text-muted">Loading...</p>
      ) : filtered.length === 0 ? (
        <p className="text-sm text-text-muted">
          {prompts.length === 0
            ? "No saved prompts yet. Use the ✦ button on any message in a thread to save it."
            : "No prompts match your filter."}
        </p>
      ) : (
        <div className="space-y-3">
          {filtered.map((p) => (
            <PromptCard key={p.id} prompt={p} onUpdate={reload} navigate={navigate} />
          ))}
        </div>
      )}
    </div>
  );
}

function PromptCard({ prompt: p, onUpdate, navigate }: {
  prompt: SavedPrompt;
  onUpdate: () => void;
  navigate: ReturnType<typeof useNavigate>;
}) {
  const [editing, setEditing] = useState(false);
  const [editTitle, setEditTitle] = useState(p.title);
  const [editContent, setEditContent] = useState(p.content);
  const [showEvals, setShowEvals] = useState(false);
  const [evalsJson, setEvalsJson] = useState(p.evals ? JSON.stringify(p.evals, null, 2) : "");
  const [evalsError, setEvalsError] = useState<string | null>(null);
  const [tagging, setTagging] = useState(false);
  const [tagInput, setTagInput] = useState("");

  const handleCopy = () => navigator.clipboard.writeText(p.content);

  const handleDelete = async () => {
    await apiFetch(`/prompts/${p.id}`, { method: "DELETE" });
    onUpdate();
  };

  const handleSaveEdit = async () => {
    await apiFetch(`/prompts/${p.id}`, {
      method: "PATCH",
      body: JSON.stringify({ title: editTitle, content: editContent }),
    });
    setEditing(false);
    onUpdate();
  };

  const handleSaveEvals = async () => {
    try {
      const parsed = evalsJson.trim() ? JSON.parse(evalsJson) : null;
      setEvalsError(null);
      await apiFetch(`/prompts/${p.id}`, {
        method: "PATCH",
        body: JSON.stringify({ evals: parsed }),
      });
      setShowEvals(false);
      onUpdate();
    } catch {
      setEvalsError("Invalid JSON");
    }
  };

  const handleAddTag = async () => {
    if (!tagInput.trim()) return;
    const newTags = [...new Set([...p.tags, tagInput.trim()])];
    await apiFetch(`/prompts/${p.id}`, {
      method: "PATCH",
      body: JSON.stringify({ tags: newTags }),
    });
    setTagInput("");
    setTagging(false);
    onUpdate();
  };

  const handleRemoveTag = async (tag: string) => {
    const newTags = p.tags.filter((t) => t !== tag);
    await apiFetch(`/prompts/${p.id}`, {
      method: "PATCH",
      body: JSON.stringify({ tags: newTags }),
    });
    onUpdate();
  };

  const roleBadge: Record<string, string> = {
    user: "role-user",
    assistant: "role-assistant",
  };

  return (
    <div className="rounded-lg border border-border-subtle bg-surface-raised p-4 space-y-3">
      {/* Header */}
      <div className="flex items-center gap-2">
        <span className={roleBadge[p.role] ?? "text-xs text-text-muted"}>{p.role}</span>
        <span className="text-sm font-medium text-white flex-1">{p.title}</span>
        <div className="flex items-center gap-1">
          <button onClick={handleCopy} className="btn-action text-xs" title="Copy prompt content to clipboard">Copy</button>
          <button onClick={() => { setEditing(!editing); setEditTitle(p.title); setEditContent(p.content); }} className="btn-action text-xs" title="Edit prompt title and content">Edit</button>
          <button onClick={() => { setShowEvals(!showEvals); setEvalsJson(p.evals ? JSON.stringify(p.evals, null, 2) : ""); }} className="btn-action-primary text-xs" title="Define expected outcomes as a JSON map for evaluation">Evals</button>
          {p.sourceConversationId && (
            <button onClick={() => navigate(`/thread/${p.sourceConversationId}`)} className="btn-action text-xs" title="View source conversation">Source</button>
          )}
          <button onClick={handleDelete} className="btn-action-danger text-xs" title="Delete this prompt">Delete</button>
        </div>
      </div>

      {/* Tags */}
      <div className="flex flex-wrap items-center gap-1.5">
        {p.tags.map((t) => (
          <span key={t} className="tag-chip group">
            {t}
            <button onClick={() => handleRemoveTag(t)} className="ml-0.5 opacity-0 group-hover:opacity-100 hover:text-red-400 transition-opacity" title={`Remove tag "${t}"`}>&times;</button>
          </span>
        ))}
        {tagging ? (
          <form onSubmit={(e) => { e.preventDefault(); handleAddTag(); }} className="flex items-center gap-1">
            <input type="text" value={tagInput} onChange={(e) => setTagInput(e.target.value)} placeholder="tag..." className="w-20 rounded-full bg-void px-2.5 py-0.5 text-xs text-text-primary placeholder:text-text-dim outline-none border border-border-subtle focus:border-glow" autoFocus onKeyDown={(e) => { if (e.key === "Escape") setTagging(false); }} />
            <button type="submit" className="text-xs text-glow">+</button>
          </form>
        ) : (
          <button onClick={() => setTagging(true)} className="rounded-full border border-dashed border-border-subtle px-2 py-0.5 text-xs text-text-dim hover:text-glow hover:border-glow/30 transition-colors" title="Add a tag">+ tag</button>
        )}
        {p.evals && (
          <span className="rounded-full bg-green-900/20 border border-green-800/30 px-2 py-0.5 text-xs text-green-400" title="Has eval criteria defined">✓ evals</span>
        )}
      </div>

      {/* Content */}
      {editing ? (
        <div className="space-y-2">
          <input type="text" value={editTitle} onChange={(e) => setEditTitle(e.target.value)} className="w-full rounded bg-void px-3 py-1.5 text-sm text-white border border-border-subtle outline-none focus:border-glow" placeholder="Title" />
          <textarea value={editContent} onChange={(e) => setEditContent(e.target.value)} rows={8} className="w-full rounded bg-void px-3 py-2 text-xs text-text-primary font-mono border border-border-subtle outline-none focus:border-glow resize-y" />
          <div className="flex gap-2">
            <button onClick={handleSaveEdit} className="btn-action-primary text-xs">Save</button>
            <button onClick={() => setEditing(false)} className="btn-action text-xs">Cancel</button>
          </div>
        </div>
      ) : (
        <pre className="whitespace-pre-wrap text-xs text-text-muted font-mono leading-relaxed max-h-32 overflow-hidden">{p.content}</pre>
      )}

      {/* Evals editor */}
      {showEvals && (
        <div className="space-y-2 border-t border-border-subtle pt-3">
          <div className="flex items-center gap-2">
            <span className="text-xs text-text-muted font-medium">Expected Outcomes (JSON)</span>
            {evalsError && <span className="text-xs text-red-400">{evalsError}</span>}
          </div>
          <textarea
            value={evalsJson}
            onChange={(e) => { setEvalsJson(e.target.value); setEvalsError(null); }}
            rows={6}
            className="w-full rounded bg-void px-3 py-2 text-xs text-text-primary font-mono border border-border-subtle outline-none focus:border-glow resize-y"
            placeholder='{\n  "contains": ["expected phrase"],\n  "format": "markdown",\n  "max_tokens": 500\n}'
          />
          <div className="flex gap-2">
            <button onClick={handleSaveEvals} className="btn-action-primary text-xs">Save Evals</button>
            <button onClick={() => setShowEvals(false)} className="btn-action text-xs">Cancel</button>
          </div>
        </div>
      )}
    </div>
  );
}
