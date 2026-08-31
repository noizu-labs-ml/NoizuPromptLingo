import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { apiFetch } from "../hooks/useApi.js";
import { MarkdownView } from "../components/MarkdownView.js";

interface ContentBlock {
  type: "text" | "tool_use" | "tool_result" | "thinking";
  text?: string;
  thinking?: string;
  name?: string;
  id?: string;
  input?: Record<string, unknown>;
  content?: string | Array<{ type: string; text?: string }> | Record<string, unknown>;
  is_error?: boolean;
}

interface ThreadRecord {
  type: "user" | "assistant";
  uuid: string;
  timestamp: string;
  isSidechain?: boolean;
  message: {
    role: string;
    model?: string;
    content: string | ContentBlock[];
    stop_reason?: string | null;
    usage?: {
      input_tokens: number;
      output_tokens: number;
      cache_creation_input_tokens?: number;
      cache_read_input_tokens?: number;
    };
  };
}

interface ConversationMeta {
  id: string;
  harness: string;
  title: string;
  slug: string | null;
  description: string | null;
  projectPath: string;
  messageCount: number;
  startedAt: string;
  updatedAt: string;
  status: string;
  tags: string[];
  sourcePath: string;
}

// ⟦𓈚𓈳𓏟𓌌⟧ Thread :: auto-generated pointer for public function Thread
export function Thread() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [meta, setMeta] = useState<ConversationMeta | null>(null);
  const [records, setRecords] = useState<ThreadRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [actionMsg, setActionMsg] = useState<string | null>(null);
  const [tagInput, setTagInput] = useState("");
  const [showTagInput, setShowTagInput] = useState(false);
  const [editingTitle, setEditingTitle] = useState(false);
  const [editingSlug, setEditingSlug] = useState(false);
  const [editingDesc, setEditingDesc] = useState(false);
  const [titleDraft, setTitleDraft] = useState("");
  const [slugDraft, setSlugDraft] = useState("");
  const [descDraft, setDescDraft] = useState("");
  const [findQuery, setFindQuery] = useState("");
  const [findResults, setFindResults] = useState<Array<{ messageId: number; snippet: string }>>([]);
  const [findActive, setFindActive] = useState(false);

  useEffect(() => {
    if (!id) return;
    Promise.all([
      apiFetch<{ data: ConversationMeta }>(`/conversations/${id}`),
      apiFetch<{ data: ThreadRecord[] }>(`/conversations/${id}/thread`),
    ])
      .then(([convRes, threadRes]) => {
        setMeta(convRes.data);
        setRecords(threadRes.data ?? []);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, [id]);

  const handleClone = async () => {
    if (!id) return;
    try {
      const res = await apiFetch<{ data: { id: string } }>(`/conversations/${id}/clone`, { method: "POST" });
      setActionMsg(`Cloned as ${res.data.id}`);
      setTimeout(() => navigate(`/thread/${res.data.id}`), 1000);
    } catch (err) {
      setActionMsg(`Clone failed: ${err instanceof Error ? err.message : "unknown error"}`);
    }
  };

  const handleRehome = async () => {
    if (!id) return;
    const project = prompt("Move to project path:", meta?.projectPath ?? "");
    if (!project) return;
    try {
      await apiFetch(`/conversations/${id}/rehome`, {
        method: "POST",
        body: JSON.stringify({ project }),
      });
      setActionMsg(`Moved to ${project}`);
      if (meta) setMeta({ ...meta, projectPath: project });
    } catch (err) {
      setActionMsg(`Rehome failed: ${err instanceof Error ? err.message : "unknown error"}`);
    }
  };

  const handleArchive = async () => {
    if (!id) return;
    try {
      await apiFetch(`/conversations/${id}/archive`, { method: "POST" });
      setActionMsg("Archived");
      if (meta) setMeta({ ...meta, status: "archived" });
    } catch (err) {
      setActionMsg(`Archive failed: ${err instanceof Error ? err.message : "unknown error"}`);
    }
  };

  const handleAddTag = async (tag: string) => {
    if (!id || !meta || !tag.trim()) return;
    const newTags = [...new Set([...meta.tags, tag.trim()])];
    try {
      await apiFetch(`/conversations/${id}/tag`, {
        method: "POST",
        body: JSON.stringify({ tags: newTags }),
      });
      setMeta({ ...meta, tags: newTags });
      setTagInput("");
      setShowTagInput(false);
    } catch (err) {
      setActionMsg(`Tag failed: ${err instanceof Error ? err.message : "unknown error"}`);
    }
  };

  const handleRemoveTag = async (tag: string) => {
    if (!id || !meta) return;
    const newTags = meta.tags.filter((t) => t !== tag);
    try {
      await apiFetch(`/conversations/${id}/tag`, {
        method: "POST",
        body: JSON.stringify({ tags: newTags }),
      });
      setMeta({ ...meta, tags: newTags });
    } catch (err) {
      setActionMsg(`Tag removal failed: ${err instanceof Error ? err.message : "unknown error"}`);
    }
  };

  const handleSavePrompt = async (record: ThreadRecord) => {
    const content = typeof record.message.content === "string"
      ? record.message.content
      : record.message.content.filter((b) => b.type === "text").map((b) => b.text ?? "").join("\n");
    const title = prompt("Save as prompt — enter a title:", content.slice(0, 60));
    if (!title) return;
    try {
      await apiFetch("/prompts", {
        method: "POST",
        body: JSON.stringify({ title, content, role: record.type, sourceConversationId: id }),
      });
      setActionMsg("Prompt saved");
      setTimeout(() => setActionMsg(null), 2000);
    } catch (err) {
      setActionMsg(`Save failed: ${err instanceof Error ? err.message : "unknown error"}`);
    }
  };

  const handleSaveMeta = async (field: "title" | "slug" | "description", value: string) => {
    if (!id) return;
    const body: Record<string, string | null> = {};
    if (field === "slug") {
      body.slug = value.trim() || null;
    } else if (field === "description") {
      body.description = value.trim() || null;
    } else {
      body.title = value.trim();
    }
    try {
      const res = await apiFetch<{ data: ConversationMeta; error?: string }>(`/conversations/${id}/meta`, {
        method: "PATCH",
        body: JSON.stringify(body),
      });
      if (res.data && meta) {
        setMeta({ ...meta, ...res.data });
      }
      setEditingTitle(false);
      setEditingSlug(false);
      setEditingDesc(false);
    } catch (err) {
      setActionMsg(`Save failed: ${err instanceof Error ? err.message : "unknown error"}`);
    }
  };

  const handleFindInThread = async () => {
    if (!id || !findQuery.trim()) { setFindResults([]); return; }
    try {
      const res = await apiFetch<{ data: Array<{ messageId: number; snippet: string }>; meta: { total: number } }>(
        `/conversations/${id}/search?q=${encodeURIComponent(findQuery)}`
      );
      setFindResults(res.data);
    } catch {
      setFindResults([]);
    }
  };

  if (loading) {
    return (
      <div className="mx-auto max-w-4xl py-12">
        <p className="text-sm text-text-muted">Loading thread...</p>
      </div>
    );
  }

  if (error || !meta) {
    return (
      <div className="mx-auto max-w-4xl py-12">
        <p className="text-sm text-red-400">{error ?? "Thread not found"}</p>
        <button onClick={() => navigate(-1)} className="mt-3 btn-action">Go back</button>
      </div>
    );
  }

  const sessionId = extractSessionId(meta.sourcePath);
  const dir = meta.projectPath;
  const resumeCmd = meta.harness === "claude" && sessionId ? `pushd ${dir} && claude --resume ${sessionId}` : null;

  return (
    <div className="mx-auto max-w-4xl space-y-6 pb-16">

      {/* ── Header Card ── */}
      <div className="rounded-lg border border-border-strong bg-surface-raised p-5">

        {/* Title (click to edit) */}
        {editingTitle ? (
          <form onSubmit={(e) => { e.preventDefault(); handleSaveMeta("title", titleDraft); }} className="flex items-center gap-2">
            <input
              type="text"
              value={titleDraft}
              onChange={(e) => setTitleDraft(e.target.value)}
              className="flex-1 rounded-md border border-glow/30 bg-canvas px-3 py-1.5 text-xl font-medium text-white outline-none"
              autoFocus
              onKeyDown={(e) => { if (e.key === "Escape") setEditingTitle(false); }}
            />
            <button type="submit" className="btn-action text-xs">Save</button>
            <button type="button" onClick={() => setEditingTitle(false)} className="btn-action text-xs">Cancel</button>
          </form>
        ) : (
          <h1
            className="text-xl font-medium text-white leading-snug cursor-pointer hover:text-glow transition-colors"
            onClick={() => { setTitleDraft(meta.title); setEditingTitle(true); }}
            title="Click to rename"
          >
            {meta.title}
          </h1>
        )}

        {/* Slug + Description */}
        <div className="mt-2 flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-text-dim">
          {/* Slug */}
          {editingSlug ? (
            <form onSubmit={(e) => { e.preventDefault(); handleSaveMeta("slug", slugDraft); }} className="flex items-center gap-1">
              <input
                type="text"
                value={slugDraft}
                onChange={(e) => setSlugDraft(e.target.value.toLowerCase().replace(/[^a-z0-9-]/g, ""))}
                placeholder="my-slug"
                className="w-32 rounded border border-glow/30 bg-canvas px-2 py-0.5 text-xs font-mono text-glow outline-none"
                autoFocus
                onKeyDown={(e) => { if (e.key === "Escape") setEditingSlug(false); }}
              />
              <button type="submit" className="text-xs text-glow hover:text-glow-bright">Save</button>
              <button type="button" onClick={() => setEditingSlug(false)} className="text-xs text-text-dim">&times;</button>
            </form>
          ) : (
            <span
              className="cursor-pointer font-mono text-glow hover:text-glow-bright transition-colors"
              onClick={() => { setSlugDraft(meta.slug ?? ""); setEditingSlug(true); }}
              title="Click to set/change slug"
            >
              {meta.slug ? `@${meta.slug}` : meta.id.slice(0, 8)}
            </span>
          )}

          <span className="text-border-strong">|</span>
          <span className="rounded border border-border-subtle px-1.5 py-0.5 uppercase">{meta.harness}</span>
          <span className="text-border-strong">|</span>
          <span title="Project working directory">
            <span className="text-glow font-medium">{shortProject(meta.projectPath)}</span>
          </span>
          <span className="text-border-strong">|</span>
          <span>{meta.messageCount} messages</span>
          <span className="text-border-strong">|</span>
          <span>{new Date(meta.startedAt).toLocaleDateString()}</span>
          {meta.status !== "active" && (
            <>
              <span className="text-border-strong">|</span>
              <span className="rounded bg-surface-active px-1.5 py-0.5">{meta.status}</span>
            </>
          )}
        </div>

        {/* Description (click to edit) */}
        <div className="mt-1.5">
          {editingDesc ? (
            <form onSubmit={(e) => { e.preventDefault(); handleSaveMeta("description", descDraft); }} className="flex items-center gap-2">
              <input
                type="text"
                value={descDraft}
                onChange={(e) => setDescDraft(e.target.value)}
                placeholder="Add a description..."
                className="flex-1 rounded border border-border-subtle bg-canvas px-2 py-1 text-xs text-text-primary outline-none"
                autoFocus
                onKeyDown={(e) => { if (e.key === "Escape") setEditingDesc(false); }}
              />
              <button type="submit" className="text-xs text-glow">Save</button>
              <button type="button" onClick={() => setEditingDesc(false)} className="text-xs text-text-dim">&times;</button>
            </form>
          ) : (
            <p
              className="cursor-pointer text-xs text-text-muted italic hover:text-text-primary transition-colors"
              onClick={() => { setDescDraft(meta.description ?? ""); setEditingDesc(true); }}
              title="Click to edit description"
            >
              {meta.description ?? "No description — click to add"}
            </p>
          )}
        </div>

        {/* Tags */}
        <div className="mt-3 flex flex-wrap items-center gap-1.5">
          {meta.tags.map((tag) => (
            <span key={tag} className="tag-chip group">
              {tag}
              <button
                onClick={() => handleRemoveTag(tag)}
                className="ml-0.5 opacity-0 group-hover:opacity-100 hover:text-red-400 transition-opacity"
                title={`Remove tag "${tag}"`}
              >
                &times;
              </button>
            </span>
          ))}
          {showTagInput ? (
            <form
              onSubmit={(e) => { e.preventDefault(); handleAddTag(tagInput); }}
              className="flex items-center gap-1"
            >
              <input
                type="text"
                value={tagInput}
                onChange={(e) => setTagInput(e.target.value)}
                placeholder="tag..."
                className="w-20 rounded-full bg-canvas px-2.5 py-0.5 text-xs text-text-primary placeholder:text-text-dim outline-none border border-border-subtle focus:border-glow transition-colors"
                autoFocus
                onKeyDown={(e) => { if (e.key === "Escape") { setShowTagInput(false); setTagInput(""); } }}
              />
              <button type="submit" className="text-xs text-glow hover:text-glow-bright" title="Add tag">+</button>
              <button type="button" onClick={() => { setShowTagInput(false); setTagInput(""); }} className="text-xs text-text-dim hover:text-text-muted" title="Cancel">&times;</button>
            </form>
          ) : (
            <button
              onClick={() => setShowTagInput(true)}
              className="rounded-full border border-dashed border-border-subtle px-2 py-0.5 text-xs text-text-dim hover:text-glow hover:border-glow/30 transition-colors"
              title="Add a tag to this conversation"
            >
              + tag
            </button>
          )}
        </div>

        {/* Divider */}
        <div className="my-4 border-t border-border-subtle" />

        {/* Source metadata */}
        <div className="space-y-2">
          <div className="meta-row">
            <span className="meta-label" title="The working directory this conversation was started from">Dir</span>
            <code className="meta-value text-glow" title={dir}>{dir}</code>
            <button onClick={() => navigator.clipboard.writeText(dir)} className="meta-copy" title="Copy directory path">Copy</button>
          </div>
          <div className="meta-row">
            <span className="meta-label" title="Path to the raw JSONL file on disk">Source</span>
            <code className="meta-value truncate max-w-md" title={meta.sourcePath}>{meta.sourcePath}</code>
            <button onClick={() => navigator.clipboard.writeText(meta.sourcePath)} className="meta-copy" title="Copy source path">Copy</button>
          </div>
          {resumeCmd && (
            <div className="meta-row">
              <span className="meta-label" title="Shell command to resume this session in Claude Code">Resume</span>
              <code className="meta-value truncate max-w-md text-xs" title={resumeCmd}>{resumeCmd}</code>
              <button onClick={() => navigator.clipboard.writeText(resumeCmd)} className="meta-copy" title="Copy resume command">Copy</button>
            </div>
          )}
        </div>

        {/* Divider */}
        <div className="my-4 border-t border-border-subtle" />

        {/* Actions */}
        <div className="flex flex-wrap items-center gap-2">
          <button onClick={() => navigate(-1)} className="btn-action" title="Go back to the previous page">Back</button>
          <button onClick={() => navigate(`/thread/${id}/edit`)} className="btn-action-primary" title="Edit this thread — collapse, remove, reorder, or inject messages (non-destructive)">Edit</button>
          <button onClick={() => navigate(`/thread/${id}/convert`)} className="btn-action-primary" title="Extract a reusable artifact — agent, skill, command, snippet, or runbook">Convert</button>
          <button onClick={() => navigate(`/thread/${id}/continue`)} className="btn-action-primary" title="Prepare a continuation or transfer payload from the universal transcript">Continue / Transfer</button>
          <div className="mx-1 h-5 w-px bg-border-subtle" />
          <button onClick={handleClone} className="btn-action" title="Create a duplicate of this conversation with a new ID">Clone</button>
          <button onClick={handleRehome} className="btn-action" title="Move this conversation's JSONL file to a different project directory">Rehome</button>
          <button onClick={handleArchive} className="btn-action-danger" title="Mark this conversation as archived — hides it from default listings">Archive</button>
        </div>

        {actionMsg && (
          <p className="mt-3 rounded bg-glow/10 border border-glow/20 px-3 py-1.5 text-xs text-glow">{actionMsg}</p>
        )}
      </div>

      {/* ── Messages ── */}
      {/* Find in thread bar */}
      <div className="flex items-center gap-2">
        <button
          onClick={() => { setFindActive(!findActive); if (findActive) { setFindQuery(""); setFindResults([]); } }}
          className={`rounded px-2 py-1 text-xs transition-colors ${findActive ? "bg-glow text-void" : "bg-surface-active text-text-muted hover:text-text-primary"}`}
          title="Search within this conversation (Ctrl+F)"
        >
          {findActive ? "Close" : "Find"}
        </button>
        {findActive && (
          <>
            <input
              type="text"
              value={findQuery}
              onChange={(e) => setFindQuery(e.target.value)}
              onKeyDown={(e) => { if (e.key === "Enter") handleFindInThread(); }}
              placeholder="Search in thread..."
              className="flex-1 rounded-md border border-border-subtle bg-void px-3 py-1.5 text-sm text-text-primary placeholder:text-text-dim outline-none focus:border-glow"
              autoFocus
            />
            <button onClick={handleFindInThread} className="btn-action text-xs">Search</button>
            {findResults.length > 0 && (
              <span className="text-xs text-text-dim">{findResults.length} match{findResults.length !== 1 ? "es" : ""}</span>
            )}
          </>
        )}
      </div>

      <div className="space-y-3">
        {records.map((record, i) => (
          <MessageBlock key={record.uuid ?? i} record={record} onSavePrompt={handleSavePrompt} />
        ))}
      </div>

      <p className="py-6 text-center text-xs text-text-dim">
        End of thread &middot; {records.length} messages
      </p>
    </div>
  );
}

function MessageBlock({ record, onSavePrompt }: { record: ThreadRecord; onSavePrompt: (record: ThreadRecord) => void }) {
  const isUser = record.type === "user";
  const content = record.message.content;
  const usage = record.message.usage;
  const [showRaw, setShowRaw] = useState(false);

  const textContent = typeof content === "string"
    ? content
    : content.filter((b) => b.type === "text").map((b) => b.text ?? "").join("\n");
  const special = detectSpecialMessage(textContent);

  const borderClass = special
    ? special.borderClass
    : isUser ? "border-glow/20" : "border-border-subtle";

  const bgStyle = special
    ? undefined
    : isUser
      ? { background: "#162028", borderLeft: "3px solid #06B6D4" }
      : { background: "#28222E", borderLeft: "3px solid #9333EA" };

  return (
    <div className={`rounded-lg border p-5 ${borderClass} ${record.isSidechain ? "opacity-50 border-dashed" : ""}`} style={bgStyle}>

      {/* Role header */}
      <div className="mb-3 flex items-center gap-2">
        {special ? (
          <span className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium ${special.badgeClass}`}>
            {special.label}
          </span>
        ) : (
          <span className={isUser ? "role-user" : "role-assistant"}>
            {isUser ? "You" : "Assistant"}
          </span>
        )}
        {record.message.model && record.message.model !== "<synthetic>" && (
          <span className="text-xs text-text-dim font-mono">{record.message.model}</span>
        )}
        {record.timestamp && (
          <span className="text-xs text-text-dim">{formatTime(record.timestamp)}</span>
        )}
        {record.isSidechain && (
          <span className="rounded bg-surface-active px-1.5 py-0.5 text-xs text-text-dim">sidechain</span>
        )}
        <div className="ml-auto flex items-center gap-2">
          {usage && (
            <span className="text-xs text-text-dim font-mono" title={`In: ${usage.input_tokens} Out: ${usage.output_tokens}`}>
              {(usage.input_tokens + usage.output_tokens).toLocaleString()} tok
            </span>
          )}
          <button
            onClick={() => onSavePrompt(record)}
            className="rounded px-1.5 py-0.5 text-sm transition-colors text-text-muted hover:text-glow"
            title="Save this message as a reusable prompt"
          >
            ✦
          </button>
          <button
            onClick={() => setShowRaw(!showRaw)}
            className={`rounded px-1.5 py-0.5 text-xs transition-colors ${showRaw ? "bg-surface-active text-text-primary" : "text-text-dim hover:text-text-muted"}`}
            title="Toggle raw JSONL record"
          >
            {showRaw ? "Rendered" : "Raw"}
          </button>
        </div>
      </div>

      {/* Raw JSONL view */}
      {showRaw ? (
        <pre className="overflow-x-auto whitespace-pre-wrap rounded bg-void p-3 text-xs text-text-muted font-mono leading-relaxed max-h-[600px] overflow-y-auto">
          {JSON.stringify(record, null, 2)}
        </pre>
      ) : special ? (
        <SpecialMessageView special={special} content={textContent} />
      ) : typeof content === "string" ? (
        isUser ? (
          <div className="text-[15px] text-text-bright leading-relaxed whitespace-pre-wrap">{content}</div>
        ) : (
          <MarkdownView content={content} />
        )
      ) : (
        <div className="space-y-3">
          {content.map((block, j) => (
            <ContentBlockView key={j} block={block} isAssistant={!isUser} />
          ))}
        </div>
      )}
    </div>
  );
}

interface SpecialMessage {
  type: "skill-invoke" | "skill-definition" | "system-reminder" | "command";
  label: string;
  badgeClass: string;
  borderClass: string;
  summary: string;
  body: string;
}

function detectSpecialMessage(text: string): SpecialMessage | null {
  if (!text) return null;

  // Skill invocation: <command-message>...<command-name>/...<command-args>...
  const cmdMatch = text.match(/<command-name>(.*?)<\/command-name>/);
  const argsMatch = text.match(/<command-args>([\s\S]*?)<\/command-args>/);
  if (cmdMatch) {
    return {
      type: "skill-invoke",
      label: `/${cmdMatch[1]}`,
      badgeClass: "bg-purple-500/15 text-purple-400",
      borderClass: "border-purple-500/20 bg-surface-raised",
      summary: argsMatch?.[1]?.trim() ?? "",
      body: text,
    };
  }

  // Skill/system definition: starts with "Base directory for this skill:"
  if (text.startsWith("Base directory for this skill:") || text.startsWith("Base directory for")) {
    const lines = text.split("\n");
    const dirLine = lines[0];
    const restStart = text.indexOf("\n\n");
    const body = restStart > 0 ? text.slice(restStart + 2) : "";
    const titleMatch = body.match(/^#\s+(.+)/m);
    return {
      type: "skill-definition",
      label: "Skill Definition",
      badgeClass: "bg-amber-500/15 text-amber-400",
      borderClass: "border-amber-500/15 bg-surface-raised",
      summary: titleMatch?.[1] ?? dirLine,
      body,
    };
  }

  // System reminder
  if (text.includes("<system-reminder>")) {
    const inner = text.replace(/<\/?system-reminder>/g, "").trim();
    return {
      type: "system-reminder",
      label: "System",
      badgeClass: "bg-text-dim/20 text-text-muted",
      borderClass: "border-border-subtle bg-surface",
      summary: inner.split("\n")[0].slice(0, 80),
      body: inner,
    };
  }

  return null;
}

function SpecialMessageView({ special, content }: { special: SpecialMessage; content: string }) {
  const [expanded, setExpanded] = useState(false);

  if (special.type === "skill-invoke") {
    return (
      <div className="space-y-2">
        <div className="flex items-center gap-2">
          <span className="font-mono text-sm text-purple-400 font-medium">{special.label}</span>
          {special.summary && (
            <span className="text-sm text-text-primary">{special.summary}</span>
          )}
        </div>
      </div>
    );
  }

  if (special.type === "skill-definition") {
    const dirMatch = content.match(/Base directory.*?:\s*(.*)/);
    const dir = dirMatch?.[1]?.trim() ?? "";
    return (
      <div className="space-y-2">
        {dir && (
          <div className="flex items-center gap-2 text-xs">
            <span className="text-text-muted">Base dir:</span>
            <code className="rounded bg-void px-2 py-0.5 font-mono text-amber-400/80 select-all">{dir}</code>
          </div>
        )}
        <div className="rounded-md border border-border-subtle">
          <button onClick={() => setExpanded(!expanded)} className="collapse-toggle text-text-muted">
            <span className="opacity-60">{expanded ? "▾" : "▸"}</span>
            <span className="font-medium">{special.summary || "Skill definition"}</span>
            <span className="ml-1 text-text-dim text-xs">({special.body.length.toLocaleString()} chars)</span>
          </button>
          {expanded && (
            <div className="border-t border-border-subtle px-4 py-3 max-h-96 overflow-y-auto">
              <MarkdownView content={special.body} />
            </div>
          )}
        </div>
      </div>
    );
  }

  if (special.type === "system-reminder") {
    return (
      <div className="rounded-md border border-border-subtle">
        <button onClick={() => setExpanded(!expanded)} className="collapse-toggle text-text-dim">
          <span className="opacity-60">{expanded ? "▾" : "▸"}</span>
          <span className="font-medium">System reminder</span>
          {!expanded && <span className="ml-1 flex-1 truncate opacity-50">{special.summary}</span>}
        </button>
        {expanded && (
          <div className="border-t border-border-subtle px-4 py-3 max-h-96 overflow-y-auto">
            <MarkdownView content={special.body} />
          </div>
        )}
      </div>
    );
  }

  return <div className="text-sm text-text-primary whitespace-pre-wrap">{content}</div>;
}

function ContentBlockView({ block, isAssistant }: { block: ContentBlock; isAssistant: boolean }) {
  const [expanded, setExpanded] = useState(false);

  if (block.type === "text") {
    return isAssistant ? (
      <MarkdownView content={block.text ?? ""} />
    ) : (
      <div className="text-[15px] text-text-bright leading-relaxed whitespace-pre-wrap">{block.text}</div>
    );
  }

  if (block.type === "thinking") {
    return (
      <div className="rounded-md border border-border-subtle bg-void/30">
        <button onClick={() => setExpanded(!expanded)} className="collapse-toggle text-text-dim">
          <span className="text-text-dim/60">{expanded ? "▾" : "▸"}</span>
          <span className="font-medium">Thinking</span>
          {!expanded && block.thinking && (
            <span className="ml-1 flex-1 truncate text-text-dim/60">{block.thinking.slice(0, 100)}</span>
          )}
        </button>
        {expanded && (
          <div className="border-t border-border-subtle px-4 py-3">
            <MarkdownView content={block.thinking ?? ""} />
          </div>
        )}
      </div>
    );
  }

  if (block.type === "tool_use") {
    const isBash = block.name === "Bash";
    const command = isBash ? String(block.input?.command ?? "") : null;
    const description = block.input?.description ? String(block.input.description) : null;
    return (
      <div className="rounded-md border border-border-subtle bg-void/30">
        <div className="flex items-center gap-2 px-3 py-2 text-xs">
          <span className="font-mono text-glow font-medium">{block.name}</span>
          {description && <span className="text-text-muted">{description}</span>}
        </div>
        {command ? (
          <div className="border-t border-border-subtle px-3 py-2">
            <pre className="overflow-x-auto rounded bg-void p-3 text-xs text-text-bright font-mono leading-relaxed">{command}</pre>
          </div>
        ) : block.input ? (
          <div className="border-t border-border-subtle px-3 py-2">
            <pre className="overflow-x-auto rounded bg-void p-3 text-xs text-text-muted font-mono leading-relaxed">
              {JSON.stringify(block.input, null, 2)}
            </pre>
          </div>
        ) : null}
      </div>
    );
  }

  if (block.type === "tool_result") {
    const resultText = safeText(block.content);
    return (
      <div className="rounded-md border border-border-subtle bg-void/30">
        <button
          onClick={() => setExpanded(!expanded)}
          className={`collapse-toggle ${block.is_error ? "text-red-400" : "text-text-dim"}`}
        >
          <span className="opacity-60">{expanded ? "▾" : "▸"}</span>
          <span className="font-medium">{block.is_error ? "Error" : "Output"}</span>
          {!expanded && resultText && (
            <span className="ml-1 flex-1 truncate opacity-50">{resultText.slice(0, 120)}</span>
          )}
        </button>
        {expanded && resultText && (
          <div className="border-t border-border-subtle px-4 py-3">
            <pre className="overflow-x-auto whitespace-pre-wrap rounded bg-void/50 p-3 text-xs text-text-muted font-mono leading-relaxed max-h-96 overflow-y-auto">
              {resultText}
            </pre>
          </div>
        )}
      </div>
    );
  }

  return null;
}

function shortProject(path: string): string {
  const parts = path.split("/").filter(Boolean);
  return parts.length > 2 ? parts.slice(-2).join("/") : path;
}

function extractSessionId(sourcePath: string): string {
  const fileName = sourcePath.split("/").pop() ?? "";
  return fileName.replace(/\.jsonl$/, "");
}

function formatTime(timestamp: string): string {
  try {
    return new Date(timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" });
  } catch {
    return timestamp.slice(11, 19);
  }
}

function safeText(content: ContentBlock["content"]): string {
  if (content == null) return "";
  if (typeof content === "string") return content;
  if (Array.isArray(content)) {
    return content.map((c) => c.text ?? "").join("\n");
  }
  return JSON.stringify(content, null, 2);
}

function contentHasMarkdown(content: string | ContentBlock[]): boolean {
  const text = typeof content === "string"
    ? content
    : content.filter((b) => b.type === "text").map((b) => b.text ?? "").join("");
  return /[#*`\[|>]/.test(text);
}
