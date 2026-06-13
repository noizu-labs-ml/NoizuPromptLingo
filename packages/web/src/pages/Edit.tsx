import React, { useState, useEffect, useCallback, useRef } from "react";
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
    };
  };
}

interface DraftMessage {
  originalIndex?: number;
  role: "user" | "assistant" | "system";
  content: string;
  injected?: boolean;
  collapsed?: boolean;
  template?: string;
}

interface DraftEdit {
  id: string;
  sourceId: string;
  createdAt: string;
  description: string;
  messages: DraftMessage[];
}

interface ConversationMeta {
  id: string;
  title: string;
  projectPath: string;
  messageCount: number;
  startedAt: string;
  updatedAt: string;
  status: string;
  tags: string[];
  sourcePath: string;
}

// ── Message Templates ──────────────────────────────────────────────────────────

interface MessageTemplate {
  id: string;
  label: string;
  icon: string;
  role: "user" | "assistant" | "system";
  description: string;
  fields: TemplateField[];
  build: (values: Record<string, string>) => string;
}

interface TemplateField {
  name: string;
  label: string;
  type: "text" | "textarea" | "select";
  placeholder?: string;
  options?: { value: string; label: string }[];
  defaultValue?: string;
  rows?: number;
}

const TEMPLATES: MessageTemplate[] = [
  {
    id: "user-text",
    label: "User Message",
    icon: "💬",
    role: "user",
    description: "Plain text from the user",
    fields: [
      { name: "content", label: "Message", type: "textarea", placeholder: "What the user said...", rows: 4 },
    ],
    build: (v) => v.content,
  },
  {
    id: "assistant-text",
    label: "Assistant Response",
    icon: "🤖",
    role: "assistant",
    description: "Markdown response from the assistant",
    fields: [
      { name: "content", label: "Response", type: "textarea", placeholder: "Assistant's markdown response...", rows: 6 },
    ],
    build: (v) => v.content,
  },
  {
    id: "system-context",
    label: "System Context",
    icon: "⚙️",
    role: "system",
    description: "Injected system prompt or context",
    fields: [
      { name: "content", label: "System message", type: "textarea", placeholder: "You are a helpful assistant that...", rows: 4 },
    ],
    build: (v) => v.content,
  },
  {
    id: "skill-invoke",
    label: "Skill Invocation",
    icon: "⚡",
    role: "user",
    description: "Invoke a slash command / skill",
    fields: [
      { name: "skill", label: "Skill name", type: "text", placeholder: "user-experience-engineer" },
      { name: "args", label: "Arguments", type: "textarea", placeholder: "prepare a styleguide for...", rows: 3 },
    ],
    build: (v) => `<command-message>\n<command-name>${v.skill}</command-name>\n<command-args>${v.args}</command-args>\n</command-message>`,
  },
  {
    id: "system-reminder",
    label: "System Reminder",
    icon: "📌",
    role: "user",
    description: "Injected context (CLAUDE.md, tool schemas, etc.)",
    fields: [
      { name: "content", label: "Reminder content", type: "textarea", placeholder: "Context injected by the system...", rows: 6 },
    ],
    build: (v) => `<system-reminder>\n${v.content}\n</system-reminder>`,
  },
  {
    id: "tool-use",
    label: "Tool Call",
    icon: "🔧",
    role: "assistant",
    description: "Assistant invoking a tool (Bash, Read, Edit, etc.)",
    fields: [
      { name: "tool", label: "Tool name", type: "select", options: [
        { value: "Bash", label: "Bash" },
        { value: "Read", label: "Read" },
        { value: "Edit", label: "Edit" },
        { value: "Write", label: "Write" },
        { value: "Agent", label: "Agent" },
        { value: "WebSearch", label: "WebSearch" },
        { value: "WebFetch", label: "WebFetch" },
      ]},
      { name: "input", label: "Input (JSON or command)", type: "textarea", placeholder: "ls -la src/", rows: 3 },
    ],
    build: (v) => {
      if (v.tool === "Bash") return `[Tool: Bash]\n$ ${v.input}`;
      return `[Tool: ${v.tool}]\n${v.input}`;
    },
  },
  {
    id: "tool-result",
    label: "Tool Output",
    icon: "📋",
    role: "user",
    description: "Result returned from a tool call",
    fields: [
      { name: "output", label: "Output", type: "textarea", placeholder: "Command output or file contents...", rows: 6 },
      { name: "is_error", label: "Status", type: "select", options: [
        { value: "false", label: "Success" },
        { value: "true", label: "Error" },
      ]},
    ],
    build: (v) => v.is_error === "true" ? `[Error]\n${v.output}` : v.output,
  },
  {
    id: "thinking",
    label: "Thinking Block",
    icon: "💭",
    role: "assistant",
    description: "Internal reasoning (chain-of-thought)",
    fields: [
      { name: "thinking", label: "Thinking", type: "textarea", placeholder: "Let me think about this...", rows: 6 },
    ],
    build: (v) => `<thinking>\n${v.thinking}\n</thinking>`,
  },
];

// ── Helpers ─────────────────────────────────────────────────────────────────────

function extractText(content: string | ContentBlock[]): string {
  if (typeof content === "string") return content;
  const parts: string[] = [];
  for (const block of content) {
    if (block.type === "text" && block.text) {
      parts.push(block.text);
    } else if (block.type === "thinking" && block.thinking) {
      parts.push(`<thinking>\n${block.thinking}\n</thinking>`);
    } else if (block.type === "tool_use") {
      const input = block.name === "Bash"
        ? `$ ${block.input?.command ?? ""}`
        : JSON.stringify(block.input ?? {}, null, 2);
      parts.push(`[Tool: ${block.name}]\n${input}`);
    } else if (block.type === "tool_result") {
      const text = safeToolResultText(block.content);
      if (block.is_error) {
        parts.push(`[Tool Output: Error]\n${text}`);
      } else if (text) {
        parts.push(`[Tool Output]\n${text}`);
      }
    }
  }
  return parts.join("\n\n");
}

function safeToolResultText(content: ContentBlock["content"]): string {
  if (content == null) return "";
  if (typeof content === "string") return content;
  if (Array.isArray(content)) {
    return (content as Array<{ type?: string; text?: string }>).map((c) => c.text ?? "").join("\n");
  }
  return JSON.stringify(content, null, 2);
}

function detectEffectiveRole(record: ThreadRecord): "user" | "assistant" | "system" {
  const content = record.message.content;
  if (typeof content === "string") return record.type as "user" | "assistant";
  const hasToolUse = content.some((b) => b.type === "tool_use");
  const hasToolResult = content.some((b) => b.type === "tool_result");
  const hasThinking = content.some((b) => b.type === "thinking");
  if (hasToolUse || hasThinking) return "assistant";
  if (hasToolResult) return "assistant";
  return record.type as "user" | "assistant";
}

function formatTime(timestamp: string): string {
  try {
    return new Date(timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" });
  } catch {
    return timestamp.slice(11, 19);
  }
}

function detectMessageType(content: string): string | null {
  if (content.includes("<command-name>")) return "skill-invoke";
  if (content.includes("<system-reminder>")) return "system-reminder";
  if (content.startsWith("Base directory for this skill:")) return "skill-definition";
  if (content.startsWith("[Tool:")) return "tool-use";
  if (content.startsWith("[Tool Output")) return "tool-output";
  if (content.startsWith("<thinking>")) return "thinking";
  return null;
}

// ── Insert Divider ──────────────────────────────────────────────────────────────

function InsertDivider({
  onInsert,
  active,
  onCancel,
}: {
  onInsert: (template: MessageTemplate) => void;
  active: boolean;
  onCancel: () => void;
}) {
  const [hovered, setHovered] = useState(false);
  const [showTemplates, setShowTemplates] = useState(active);

  useEffect(() => {
    setShowTemplates(active);
  }, [active]);

  if (showTemplates) {
    return (
      <div className="my-1 rounded-lg border border-dashed border-glow/30 bg-surface p-3">
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs text-glow font-medium">Insert message</span>
          <button onClick={() => { setShowTemplates(false); onCancel(); }} className="text-xs text-text-dim hover:text-text-muted">✕</button>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-1.5">
          {TEMPLATES.map((t) => (
            <button
              key={t.id}
              onClick={() => onInsert(t)}
              className="flex items-center gap-1.5 rounded-md border border-border-subtle bg-surface-raised px-2.5 py-2 text-left hover:border-glow/30 hover:bg-surface-active transition-colors"
              title={t.description}
            >
              <span className="text-sm">{t.icon}</span>
              <span className="text-xs text-text-primary truncate">{t.label}</span>
            </button>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div
      className="group/divider relative my-0 flex items-center justify-center"
      style={{ height: "16px" }}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
    >
      <div className={`absolute inset-x-0 top-1/2 border-t transition-all duration-150 ${hovered ? "border-glow/40" : "border-transparent"}`} />
      <button
        onClick={() => setShowTemplates(true)}
        className={`relative z-10 flex items-center gap-1 rounded-full border px-3 py-0.5 text-xs font-medium transition-all duration-150 ${
          hovered
            ? "border-glow/40 bg-surface-raised text-glow opacity-100 scale-100"
            : "border-transparent bg-transparent text-transparent opacity-0 scale-95"
        }`}
      >
        + Insert
      </button>
    </div>
  );
}

// ── Template Form ───────────────────────────────────────────────────────────────

function TemplateForm({
  template,
  onSubmit,
  onCancel,
}: {
  template: MessageTemplate;
  onSubmit: (msg: DraftMessage) => void;
  onCancel: () => void;
}) {
  const [values, setValues] = useState<Record<string, string>>(() => {
    const init: Record<string, string> = {};
    for (const f of template.fields) {
      init[f.name] = f.defaultValue ?? "";
    }
    return init;
  });

  const update = (name: string, value: string) => setValues((v) => ({ ...v, [name]: value }));

  const canSubmit = template.fields.every((f) => {
    if (f.type === "select") return true;
    return (values[f.name] ?? "").trim().length > 0;
  });

  const handleSubmit = () => {
    const content = template.build(values);
    onSubmit({
      role: template.role,
      content,
      injected: true,
      template: template.id,
    });
  };

  return (
    <div className="my-1 rounded-lg border border-glow/30 bg-surface p-4 space-y-3">
      <div className="flex items-center gap-2">
        <span className="text-sm">{template.icon}</span>
        <span className="text-xs text-glow font-medium">{template.label}</span>
        <span className="text-xs text-text-dim">— {template.description}</span>
      </div>

      {template.fields.map((field) => (
        <div key={field.name} className="space-y-1">
          <label className="text-xs text-text-muted">{field.label}</label>
          {field.type === "select" ? (
            <select
              value={values[field.name] ?? field.options?.[0]?.value ?? ""}
              onChange={(e) => update(field.name, e.target.value)}
              className="w-full rounded bg-void border border-border-subtle px-3 py-1.5 text-sm text-text-primary outline-none focus:border-glow"
            >
              {field.options?.map((opt) => (
                <option key={opt.value} value={opt.value}>{opt.label}</option>
              ))}
            </select>
          ) : field.type === "textarea" ? (
            <textarea
              value={values[field.name] ?? ""}
              onChange={(e) => update(field.name, e.target.value)}
              placeholder={field.placeholder}
              rows={field.rows ?? 3}
              className="w-full rounded bg-void border border-border-subtle px-3 py-2 text-sm text-text-primary placeholder:text-text-dim outline-none focus:border-glow resize-y font-mono leading-relaxed"
              autoFocus={template.fields[0] === field}
            />
          ) : (
            <input
              type="text"
              value={values[field.name] ?? ""}
              onChange={(e) => update(field.name, e.target.value)}
              placeholder={field.placeholder}
              className="w-full rounded bg-void border border-border-subtle px-3 py-1.5 text-sm text-text-primary placeholder:text-text-dim outline-none focus:border-glow font-mono"
              autoFocus={template.fields[0] === field}
            />
          )}
        </div>
      ))}

      <div className="flex gap-2 pt-1">
        <button
          onClick={handleSubmit}
          disabled={!canSubmit}
          className="rounded bg-glow px-4 py-1.5 text-xs font-medium text-void hover:bg-glow/90 disabled:opacity-40"
        >
          Insert
        </button>
        <button onClick={onCancel} className="btn-action text-xs">Cancel</button>
      </div>
    </div>
  );
}

// ── Preview Panel ───────────────────────────────────────────────────────────────

function PreviewModal({
  action,
  messages,
  selected,
  onApply,
  onCancel,
}: {
  action: { type: "compact" | "simplify"; result: DraftMessage[]; simplifyMap: Map<number, string>; loading: boolean; error?: string };
  messages: DraftMessage[];
  selected: Set<number>;
  onApply: () => void;
  onCancel: () => void;
}) {
  const isCompact = action.type === "compact";
  const indices = [...selected].sort((a, b) => a - b);
  const hasResults = isCompact ? action.result.length > 0 : action.simplifyMap.size > 0;

  const roleStyle = (role: string) => {
    if (role === "user") return { background: "#162028", borderLeft: "3px solid #06B6D4" };
    return { background: "#28222E", borderLeft: "3px solid #9333EA" };
  };
  const roleColor = (role: string) => role === "user" ? "text-glow" : "text-purple-400";

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm" onClick={onCancel}>
      <div
        className="relative mx-4 flex max-h-[85vh] w-full max-w-3xl flex-col rounded-xl border border-border-strong bg-canvas shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between border-b border-border-subtle px-6 py-4">
          <div>
            <h2 className="text-base font-medium text-white">
              {isCompact ? "Compact Preview" : "Simplify Preview"}
            </h2>
            <p className="mt-0.5 text-xs text-text-dim">
              {isCompact
                ? `${indices.length} messages → ${action.result.length || "?"} compacted (valid user ↔ assistant turns)`
                : `${indices.length} messages rewritten individually`}
            </p>
          </div>
          <button onClick={onCancel} className="rounded p-1 text-text-dim hover:text-text-muted hover:bg-surface-active transition-colors" title="Close">
            <span className="text-lg leading-none">✕</span>
          </button>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto px-6 py-4 space-y-4">
          {action.error && (
            <div className="rounded-md border border-red-800/40 bg-red-950/20 px-4 py-3 text-sm text-red-400">
              {action.error}
            </div>
          )}

          {action.loading && (
            <div className="flex items-center justify-center py-12">
              <div className="text-sm text-text-dim animate-pulse">Generating preview...</div>
            </div>
          )}

          {isCompact && !action.loading && hasResults && (
            <div className="space-y-4">
              {/* Original */}
              <div className="space-y-1">
                <label className="text-xs text-text-dim font-medium">Original ({indices.length} messages)</label>
                <div className="max-h-32 overflow-y-auto rounded border border-border-subtle bg-void p-3 space-y-1.5">
                  {indices.map((idx) => (
                    <div key={idx} className="text-xs text-text-muted flex gap-2">
                      <span className="text-text-dim font-mono shrink-0">#{idx + 1}</span>
                      <span className={`shrink-0 ${roleColor(messages[idx].role)}`}>{messages[idx].role}</span>
                      <span className="truncate opacity-70">{messages[idx].content.slice(0, 80)}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Compacted turns */}
              <div className="space-y-1">
                <label className="text-xs text-text-dim font-medium">Compacted ({action.result.length} messages)</label>
                <div className="space-y-2">
                  {action.result.map((msg, i) => (
                    <div key={i} className="rounded border border-border-subtle p-3" style={roleStyle(msg.role)}>
                      <div className="mb-1.5 flex items-center gap-2">
                        <span className={`text-xs font-medium ${roleColor(msg.role)}`}>
                          {msg.role === "user" ? "User" : "Assistant"}
                        </span>
                        <span className="text-xs text-text-dim">Turn {i + 1}</span>
                      </div>
                      <pre className="whitespace-pre-wrap text-xs text-text-primary font-mono leading-relaxed max-h-48 overflow-y-auto">{msg.content}</pre>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {!isCompact && !action.loading && (
            <div className="space-y-3">
              {indices.map((idx) => {
                const original = messages[idx];
                const simplified = action.simplifyMap.get(idx);
                const done = simplified !== undefined;
                return (
                  <div key={idx} className="rounded border border-border-subtle bg-surface-raised p-3 space-y-2">
                    <div className="flex items-center gap-2 text-xs">
                      <span className="font-mono text-text-dim">#{idx + 1}</span>
                      <span className={roleColor(original.role)}>{original.role}</span>
                      {!done && action.loading && <span className="text-text-dim animate-pulse">pending...</span>}
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                      <div className="space-y-1">
                        <label className="text-xs text-red-400/70 font-medium">Before</label>
                        <div className="rounded bg-red-950/10 border border-red-900/20 p-2 max-h-36 overflow-y-auto">
                          <pre className="whitespace-pre-wrap text-xs text-text-muted font-mono leading-relaxed">{original.content.slice(0, 600)}{original.content.length > 600 ? "\n..." : ""}</pre>
                        </div>
                      </div>
                      <div className="space-y-1">
                        <label className="text-xs text-green-400/70 font-medium">After</label>
                        <div className="rounded bg-green-950/10 border border-green-900/20 p-2 max-h-36 overflow-y-auto">
                          {done ? (
                            <pre className="whitespace-pre-wrap text-xs text-text-primary font-mono leading-relaxed">{simplified}</pre>
                          ) : (
                            <div className="text-xs text-text-dim italic animate-pulse">Generating...</div>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="flex items-center gap-3 border-t border-border-subtle px-6 py-4">
          {hasResults && (
            <button
              onClick={onApply}
              disabled={action.loading}
              className="rounded bg-glow px-5 py-2 text-sm font-medium text-void hover:bg-glow/90 disabled:opacity-50 transition-opacity"
            >
              {isCompact ? "Apply Compact" : "Apply Simplify"}
            </button>
          )}
          <button onClick={onCancel} className="rounded border border-border-subtle px-4 py-2 text-sm text-text-muted hover:text-text-primary hover:border-glow/30 transition-colors">
            {hasResults ? "Cancel" : "Dismiss"}
          </button>
          {!action.loading && hasResults && (
            <span className="text-xs text-text-dim ml-auto">
              {isCompact
                ? `${indices.length} → ${action.result.length} message${action.result.length !== 1 ? "s" : ""}`
                : `${action.simplifyMap.size} message${action.simplifyMap.size !== 1 ? "s" : ""} rewritten`}
            </span>
          )}
        </div>
      </div>
    </div>
  );
}

// ── Main Edit Page ──────────────────────────────────────────────────────────────

export function Edit() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [meta, setMeta] = useState<ConversationMeta | null>(null);
  const [originalRecords, setOriginalRecords] = useState<ThreadRecord[]>([]);
  const [messages, setMessages] = useState<DraftMessage[]>([]);
  const [draftId, setDraftId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [editingIdx, setEditingIdx] = useState<number | null>(null);
  const [editDraft, setEditDraft] = useState({ role: "user" as string, content: "" });
  const [insertingAt, setInsertingAt] = useState<number | null>(null);
  const [insertTemplate, setInsertTemplate] = useState<MessageTemplate | null>(null);
  const [selected, setSelected] = useState<Set<number>>(new Set());
  const [rawVisible, setRawVisible] = useState<Set<number>>(new Set());
  const [dirty, setDirty] = useState(false);
  const [previewAction, setPreviewAction] = useState<null | {
    type: "compact" | "simplify";
    result: DraftMessage[];
    simplifyMap: Map<number, string>;
    loading: boolean;
    error?: string;
  }>(null);
  const lastClickedIdx = useRef<number | null>(null);
  const saveTimeout = useRef<ReturnType<typeof setTimeout> | null>(null);
  const draftIdRef = useRef<string | null>(null);

  useEffect(() => { draftIdRef.current = draftId; }, [draftId]);

  useEffect(() => {
    if (!id) return;
    Promise.all([
      apiFetch<{ data: ConversationMeta }>(`/conversations/${id}`),
      apiFetch<{ data: ThreadRecord[] }>(`/conversations/${id}/thread`),
      apiFetch<{ data: DraftEdit | null }>(`/conversations/${id}/draft`),
    ])
      .then(([convRes, threadRes, draftRes]) => {
        setMeta(convRes.data);
        const records = threadRes.data ?? [];
        setOriginalRecords(records);

        if (draftRes.data) {
          setMessages(draftRes.data.messages);
          setDraftId(draftRes.data.id);
          draftIdRef.current = draftRes.data.id;
          setDirty(true);
        } else {
          const initial: DraftMessage[] = records.map((r, i) => ({
            originalIndex: i,
            role: detectEffectiveRole(r),
            content: extractText(r.message.content),
          }));
          setMessages(initial);
        }
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, [id]);

  const persistDraft = useCallback(
    async (msgs: DraftMessage[]) => {
      if (!id) return;
      try {
        if (!draftIdRef.current) {
          const res = await apiFetch<{ data: DraftEdit }>(`/conversations/${id}/draft`, {
            method: "POST",
            body: JSON.stringify({ messages: msgs }),
          });
          setDraftId(res.data.id);
          draftIdRef.current = res.data.id;
        } else {
          await apiFetch(`/conversations/${id}/draft`, {
            method: "PATCH",
            body: JSON.stringify({ messages: msgs }),
          });
        }
      } catch {
        // silent
      }
    },
    [id],
  );

  const debouncedSave = useCallback(
    (msgs: DraftMessage[]) => {
      if (saveTimeout.current) clearTimeout(saveTimeout.current);
      saveTimeout.current = setTimeout(() => persistDraft(msgs), 800);
    },
    [persistDraft],
  );

  const updateMessages = useCallback(
    (next: DraftMessage[]) => {
      setMessages(next);
      setDirty(true);
      debouncedSave(next);
    },
    [debouncedSave],
  );

  const toggleSelect = (idx: number, shiftKey: boolean) => {
    setSelected((prev) => {
      const next = new Set(prev);
      if (shiftKey && lastClickedIdx.current !== null) {
        const from = Math.min(lastClickedIdx.current, idx);
        const to = Math.max(lastClickedIdx.current, idx);
        for (let i = from; i <= to; i++) next.add(i);
      } else {
        if (next.has(idx)) next.delete(idx); else next.add(idx);
      }
      return next;
    });
    lastClickedIdx.current = idx;
  };

  const selectAll = () => setSelected(new Set(messages.map((_, i) => i)));
  const deselectAll = () => setSelected(new Set());

  const handleBulkDelete = () => {
    if (selected.size === 0) return;
    updateMessages(messages.filter((_, i) => !selected.has(i)));
    setSelected(new Set());
    setEditingIdx(null);
  };

  const handlePreviewCompact = async () => {
    if (selected.size === 0) return;
    const indices = [...selected].sort((a, b) => a - b);
    const transcript = indices.map((i) => {
      const m = messages[i];
      return `[${m.role}]\n${m.content}`;
    }).join("\n\n---\n\n");

    const inputRoles = new Set(indices.map((i) => messages[i].role));
    const hasUser = inputRoles.has("user");
    const hasAssistant = inputRoles.has("assistant");

    setPreviewAction({ type: "compact", result: [], simplifyMap: new Map(), loading: true, error: undefined });

    const systemPrompt = `You are a conversation editor that compacts message sequences.

TASK: Condense the following messages into the fewest possible messages while preserving ALL key information, decisions, code changes, and outcomes.

INPUT ROLES PRESENT: ${[...inputRoles].join(", ")}

CRITICAL RULES:
1. ONLY use roles that exist in the input. ${!hasUser ? "There are NO user messages — do NOT create any user messages." : ""} ${!hasAssistant ? "There are NO assistant messages — do NOT create any assistant messages." : ""}
2. ${hasUser && hasAssistant ? "When both roles are present, messages MUST alternate: user → assistant → user → assistant. Never two consecutive messages with the same role." : `All output messages must have role "${[...inputRoles][0]}".`}
3. Tool calls (e.g. "[Tool: Bash]") and tool outputs (e.g. "[Tool Output]") belong to the assistant turn — fold them into the assistant message as a summary of what was done and what resulted.
4. System messages should be folded into the nearest user message as context.
5. Produce the MINIMUM number of messages needed.
6. The first output message role must match the first input message role ("${messages[indices[0]]?.role}").

OUTPUT FORMAT: Return ONLY a JSON array of message objects. No markdown fences, no commentary.
Example: [{"role":"assistant","content":"..."}] or [{"role":"user","content":"..."},{"role":"assistant","content":"..."}]`;

    try {
      const res = await apiFetch<{ data: { content: string } }>("/llm/complete", {
        method: "POST",
        body: JSON.stringify({
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: transcript },
          ],
          maxTokens: 4096,
        }),
      });

      let parsed: Array<{ role: string; content: string }>;
      const raw = res.data.content.trim();
      const jsonMatch = raw.match(/\[[\s\S]*\]/);
      parsed = JSON.parse(jsonMatch ? jsonMatch[0] : raw);

      if (!Array.isArray(parsed) || parsed.length === 0) {
        throw new Error("LLM returned invalid format — expected a JSON array of messages.");
      }

      // Strip messages with roles not in the input
      parsed = parsed.filter((m) => inputRoles.has(m.role === "user" ? "user" : "assistant"));

      if (parsed.length === 0) {
        throw new Error("LLM returned no valid messages matching the input roles.");
      }

      // Merge consecutive same-role messages
      for (let i = 1; i < parsed.length; i++) {
        if (parsed[i].role === parsed[i - 1].role) {
          parsed[i - 1].content += "\n\n" + parsed[i].content;
          parsed.splice(i, 1);
          i--;
        }
      }

      const result: DraftMessage[] = parsed.map((m) => ({
        role: (m.role === "user" ? "user" : "assistant") as DraftMessage["role"],
        content: m.content,
        collapsed: true,
      }));

      setPreviewAction({ type: "compact", result, simplifyMap: new Map(), loading: false });
    } catch (err) {
      setPreviewAction({ type: "compact", result: [], simplifyMap: new Map(), loading: false, error: err instanceof Error ? err.message : "LLM request failed." });
    }
  };

  const handleApplyCompact = () => {
    if (!previewAction || previewAction.type !== "compact" || previewAction.result.length === 0) return;
    const newMessages: DraftMessage[] = [];
    let inserted = false;
    messages.forEach((msg, i) => {
      if (!selected.has(i)) {
        newMessages.push(msg);
      } else if (!inserted) {
        newMessages.push(...previewAction.result);
        inserted = true;
      }
    });
    updateMessages(newMessages);
    setSelected(new Set());
    setEditingIdx(null);
    setPreviewAction(null);
  };

  const handlePreviewSimplify = async () => {
    if (selected.size === 0) return;
    const indices = [...selected];
    setPreviewAction({ type: "simplify", result: [], simplifyMap: new Map(), loading: true, error: undefined });
    const smap = new Map<number, string>();
    let anyFailed = false;

    for (const idx of indices) {
      const msg = messages[idx];
      if (!msg.content.trim()) continue;
      try {
        const res = await apiFetch<{ data: { content: string } }>("/llm/complete", {
          method: "POST",
          body: JSON.stringify({
            messages: [
              { role: "system", content: "You are an editor. Simplify and distill the following message to its essential content. Remove verbose tool output, redundant explanations, and boilerplate. Preserve key information, decisions, code snippets, and outcomes. Return only the simplified text, no commentary." },
              { role: "user", content: msg.content },
            ],
            maxTokens: 2048,
          }),
        });
        smap.set(idx, res.data.content);
        setPreviewAction({ type: "simplify", result: [], simplifyMap: new Map(smap), loading: idx !== indices[indices.length - 1] });
      } catch (err) {
        anyFailed = true;
        if (smap.size === 0) {
          setPreviewAction({ type: "simplify", result: [], simplifyMap: new Map(), loading: false, error: err instanceof Error ? err.message : "LLM request failed — check Settings > LLM Inference configuration." });
          return;
        }
        break;
      }
    }
    setPreviewAction({ type: "simplify", result: [], simplifyMap: smap, loading: false, error: anyFailed ? "Some messages failed to simplify and were skipped." : undefined });
  };

  const handleApplySimplify = () => {
    if (!previewAction || previewAction.type !== "simplify") return;
    const updated = [...messages];
    for (const [idx, content] of previewAction.simplifyMap) {
      updated[idx] = { ...updated[idx], content };
    }
    updateMessages(updated);
    setSelected(new Set());
    setPreviewAction(null);
  };

  const handleDelete = (idx: number) => {
    updateMessages(messages.filter((_, i) => i !== idx));
    if (editingIdx === idx) setEditingIdx(null);
    if (insertingAt !== null && insertingAt > idx) setInsertingAt(insertingAt - 1);
    setSelected((prev) => { const next = new Set(prev); next.delete(idx); return next; });
  };

  const startEdit = (idx: number) => {
    setEditingIdx(idx);
    setEditDraft({ role: messages[idx].role, content: messages[idx].content });
    setInsertingAt(null);
    setInsertTemplate(null);
  };

  const saveEdit = () => {
    if (editingIdx === null) return;
    const next = messages.map((m, i) =>
      i === editingIdx ? { ...m, role: editDraft.role as DraftMessage["role"], content: editDraft.content } : m,
    );
    updateMessages(next);
    setEditingIdx(null);
  };

  const handleSelectTemplate = (position: number, template: MessageTemplate) => {
    setInsertingAt(position);
    setInsertTemplate(template);
    setEditingIdx(null);
  };

  const handleInsertMessage = (position: number, msg: DraftMessage) => {
    const next = [...messages.slice(0, position), msg, ...messages.slice(position)];
    updateMessages(next);
    setInsertingAt(null);
    setInsertTemplate(null);
  };

  const handleSaveEdit = async (mode: "new" | "overwrite") => {
    if (!id) return;
    setSaving(true);
    try {
      if (saveTimeout.current) {
        clearTimeout(saveTimeout.current);
      }

      const defaultTitle = mode === "new" ? `${meta?.title ?? "Thread"} (edited)` : meta?.title ?? "Thread edit";
      const desc = prompt(
        mode === "new"
          ? "Title for the new conversation:"
          : "Update title (or leave as-is):",
        defaultTitle,
      );
      if (desc === null) { setSaving(false); return; }

      if (mode === "overwrite" && !confirm("This will overwrite the original JSONL file on disk. Continue?")) {
        setSaving(false);
        return;
      }

      const res = await apiFetch<{ data: { id: string; sourcePath: string } }>(`/conversations/${id}/save-edit`, {
        method: "POST",
        body: JSON.stringify({
          messages: messages.map((m) => ({ role: m.role, content: m.content })),
          mode,
          description: desc || defaultTitle,
        }),
      });

      // Clean up draft
      if (draftIdRef.current) {
        await apiFetch(`/conversations/${id}/draft`, { method: "DELETE" }).catch(() => {});
      }

      navigate(`/thread/${res.data.id}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Save failed");
      setSaving(false);
    }
  };

  const handleRevert = async () => {
    if (!id) return;
    if (!confirm("Discard all edits and revert to original?")) return;
    try {
      await apiFetch(`/conversations/${id}/draft`, { method: "DELETE" });
      const initial: DraftMessage[] = originalRecords.map((r, i) => ({
        originalIndex: i,
        role: detectEffectiveRole(r),
        content: extractText(r.message.content),
      }));
      setMessages(initial);
      setDraftId(null);
      draftIdRef.current = null;
      setDirty(false);
      setEditingIdx(null);
      setInsertingAt(null);
      setInsertTemplate(null);
      setSelected(new Set());
    } catch (err) {
      setError(err instanceof Error ? err.message : "Revert failed");
    }
  };

  if (loading) {
    return <div className="mx-auto max-w-4xl py-12"><p className="text-sm text-text-muted">Loading thread...</p></div>;
  }

  if (error || !meta) {
    return (
      <div className="mx-auto max-w-4xl py-12">
        <p className="text-sm text-red-400">{error ?? "Thread not found"}</p>
        <button onClick={() => navigate(-1)} className="mt-3 btn-action">Go back</button>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-4xl space-y-0 pb-24">

      {/* Header */}
      <div className="rounded-lg border border-glow/30 bg-surface-raised p-5 mb-4">
        <div className="flex items-center gap-3">
          <h1 className="flex-1 text-xl font-medium text-white leading-snug">Editing: {meta.title}</h1>
          <button onClick={() => navigate(`/thread/${id}`)} className="btn-action text-xs">Cancel</button>
        </div>
        <p className="mt-1 text-xs text-text-dim">
          {messages.length} messages{dirty ? " · draft auto-saved" : ""}
        </p>
      </div>

      {/* Bulk toolbar */}
      <div className="sticky top-0 z-20 flex flex-wrap items-center gap-2 rounded-md border border-border-subtle bg-canvas/95 backdrop-blur px-4 py-2.5 mb-2">
        <button
          onClick={selected.size === messages.length ? deselectAll : selectAll}
          className="rounded bg-surface-active px-3 py-1 text-xs text-text-muted hover:text-text-primary transition-colors"
        >
          {selected.size === messages.length && messages.length > 0 ? "Deselect All" : "Select All"}
        </button>

        <div className="mx-1 h-4 w-px bg-border-subtle" />

        <button
          onClick={handleBulkDelete}
          disabled={selected.size === 0}
          className="rounded bg-red-900/30 px-3 py-1 text-xs text-red-400 hover:bg-red-900/50 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
          title="Permanently remove selected messages from the thread. Immediate — no preview."
        >
          Delete ({selected.size})
        </button>

        <button
          onClick={handlePreviewCompact}
          disabled={selected.size === 0 || (previewAction?.loading ?? false)}
          className="rounded bg-surface-active px-3 py-1 text-xs text-text-muted hover:text-text-primary disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
          title="Use LLM to summarize selected messages into a single compact message. Preview before applying."
        >
          Compact ({selected.size})
        </button>

        <button
          onClick={handlePreviewSimplify}
          disabled={selected.size === 0 || (previewAction?.loading ?? false)}
          className="rounded bg-purple-900/30 px-3 py-1 text-xs text-purple-400 hover:bg-purple-900/50 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
          title="Use LLM to distill each selected message individually — removes boilerplate and verbose output. Preview before applying."
        >
          Simplify ({selected.size})
        </button>

        <div className="flex-1" />

        {selected.size > 0 && (
          <span className="text-xs text-text-dim">{selected.size} selected</span>
        )}
      </div>

      {/* Preview/Approve modal */}
      {previewAction && (
        <PreviewModal
          action={previewAction}
          messages={messages}
          selected={selected}
          onApply={previewAction.type === "compact" ? handleApplyCompact : handleApplySimplify}
          onCancel={() => setPreviewAction(null)}
        />
      )}

      {/* Insert at top */}
      {insertingAt === 0 && insertTemplate ? (
        <TemplateForm
          template={insertTemplate}
          onSubmit={(msg) => handleInsertMessage(0, msg)}
          onCancel={() => { setInsertingAt(null); setInsertTemplate(null); }}
        />
      ) : (
        <InsertDivider
          onInsert={(t) => handleSelectTemplate(0, t)}
          active={insertingAt === 0 && !insertTemplate}
          onCancel={() => setInsertingAt(null)}
        />
      )}

      {/* Messages */}
      {messages.map((msg, i) => {
        const isUser = msg.role === "user";
        const isEditing = editingIdx === i;
        const originalRecord = msg.originalIndex != null ? originalRecords[msg.originalIndex] : null;
        const msgType = detectMessageType(msg.content);
        const insertPos = i + 1;
        const isInsertingHere = insertingAt === insertPos;
        const isShowingRaw = rawVisible.has(i);

        const isToolOutput = msgType === "tool-output";
        const bgStyle = msg.injected
          ? { background: "#1C2828", borderLeft: "3px solid #4ADE80" }
          : isToolOutput
            ? { background: "#1A2420", borderLeft: "3px solid #34D399" }
            : isUser
              ? { background: "#162028", borderLeft: "3px solid #06B6D4" }
              : { background: "#28222E", borderLeft: "3px solid #9333EA" };

        const borderClass = msg.injected
          ? "border-green-500/20"
          : isToolOutput
            ? "border-emerald-500/20"
            : isUser ? "border-glow/20" : "border-border-subtle";

        return (
          <React.Fragment key={i}>
            <div
              className={`group rounded-lg border p-5 transition-colors cursor-pointer ${borderClass} ${selected.has(i) ? "ring-1 ring-glow/40" : ""}`}
              style={bgStyle}
              onClick={(e) => {
                const tag = (e.target as HTMLElement).tagName;
                if (tag === "INPUT" || tag === "BUTTON" || tag === "TEXTAREA" || tag === "SELECT" || tag === "A") return;
                if ((e.target as HTMLElement).closest("button, a, textarea, select")) return;
                toggleSelect(i, e.shiftKey);
              }}
            >
              {/* Role header + action icons */}
              <div className="mb-3 flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={selected.has(i)}
                  onChange={() => {}}
                  onClick={(e) => { e.stopPropagation(); toggleSelect(i, e.shiftKey); }}
                  className="shrink-0 cursor-pointer accent-cyan-400 mr-1"
                  title="Select for bulk actions (Shift+click to select range)"
                />
                {msgType === "skill-invoke" ? (
                  <span className="inline-flex items-center gap-1 rounded-full bg-purple-500/15 px-2.5 py-0.5 text-xs font-medium text-purple-400">
                    ⚡ Skill
                  </span>
                ) : msgType === "system-reminder" ? (
                  <span className="inline-flex items-center gap-1 rounded-full bg-text-dim/20 px-2.5 py-0.5 text-xs font-medium text-text-muted">
                    📌 System
                  </span>
                ) : msgType === "thinking" ? (
                  <span className="inline-flex items-center gap-1 rounded-full bg-amber-500/15 px-2.5 py-0.5 text-xs font-medium text-amber-400">
                    💭 Thinking
                  </span>
                ) : msgType === "tool-use" ? (
                  <span className="inline-flex items-center gap-1 rounded-full bg-glow/10 px-2.5 py-0.5 text-xs font-medium text-glow">
                    🔧 Tool
                  </span>
                ) : msgType === "tool-output" ? (
                  <span className="inline-flex items-center gap-1 rounded-full bg-emerald-500/10 px-2.5 py-0.5 text-xs font-medium text-emerald-400">
                    📋 Tool Response
                  </span>
                ) : (
                  <span className={isUser ? "role-user" : msg.role === "assistant" ? "role-assistant" : "rounded-full bg-surface-active px-2.5 py-0.5 text-xs text-text-dim"}>
                    {isUser ? "You" : msg.role === "assistant" ? "Assistant" : msg.role}
                  </span>
                )}
                {msg.injected && (
                  <span className="rounded-full bg-green-900/30 border border-green-800/30 px-2 py-0.5 text-xs text-green-400">inserted</span>
                )}
                {msg.template && (
                  <span className="text-xs text-text-dim italic">{TEMPLATES.find((t) => t.id === msg.template)?.label}</span>
                )}
                {originalRecord?.message.model && originalRecord.message.model !== "<synthetic>" && (
                  <span className="text-xs text-text-dim font-mono">{originalRecord.message.model}</span>
                )}
                {originalRecord?.timestamp && (
                  <span className="text-xs text-text-dim">{formatTime(originalRecord.timestamp)}</span>
                )}

                <div className="ml-auto flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  {originalRecord && (
                    <button
                      onClick={() => setRawVisible((prev) => { const next = new Set(prev); if (next.has(i)) next.delete(i); else next.add(i); return next; })}
                      className={`rounded px-2 py-1 text-xs transition-colors ${isShowingRaw ? "bg-surface-active text-text-primary" : "text-text-dim hover:text-text-bright hover:bg-surface-active"}`}
                      title="Toggle raw JSONL record"
                    >
                      {isShowingRaw ? "Rendered" : "Raw"}
                    </button>
                  )}
                  <button
                    onClick={() => isEditing ? setEditingIdx(null) : startEdit(i)}
                    className={`rounded px-2 py-1 text-xs transition-colors ${isEditing ? "bg-glow/20 text-glow" : "text-text-dim hover:text-text-bright hover:bg-surface-active"}`}
                    title={isEditing ? "Cancel edit" : "Edit message content"}
                  >
                    ✎
                  </button>
                  <button
                    onClick={() => handleDelete(i)}
                    className="rounded px-2 py-1 text-xs text-text-dim hover:text-red-400 hover:bg-red-900/20 transition-colors"
                    title="Delete this message"
                  >
                    ✕
                  </button>
                </div>
              </div>

              {/* Content */}
              {isShowingRaw && originalRecord ? (
                <pre className="overflow-x-auto whitespace-pre-wrap rounded bg-void p-3 text-xs text-text-muted font-mono leading-relaxed max-h-[600px] overflow-y-auto">
                  {JSON.stringify(originalRecord, null, 2)}
                </pre>
              ) : isEditing ? (
                <div className="space-y-3">
                  <div className="flex items-center gap-2">
                    <label className="text-xs text-text-dim">Role:</label>
                    <select
                      value={editDraft.role}
                      onChange={(e) => setEditDraft((d) => ({ ...d, role: e.target.value }))}
                      className="rounded bg-void border border-border-subtle px-2 py-1 text-xs text-text-primary outline-none focus:border-glow"
                    >
                      <option value="user">user</option>
                      <option value="assistant">assistant</option>
                      <option value="system">system</option>
                    </select>
                  </div>
                  <textarea
                    value={editDraft.content}
                    onChange={(e) => setEditDraft((d) => ({ ...d, content: e.target.value }))}
                    rows={Math.min(20, editDraft.content.split("\n").length + 2)}
                    className="w-full rounded bg-void border border-border-subtle px-4 py-3 text-sm text-text-primary placeholder:text-text-dim outline-none focus:border-glow resize-y font-mono leading-relaxed"
                    autoFocus
                  />
                  <div className="flex gap-2">
                    <button onClick={saveEdit} className="rounded bg-glow px-4 py-1.5 text-xs font-medium text-void hover:bg-glow/90">Apply</button>
                    <button onClick={() => setEditingIdx(null)} className="btn-action text-xs">Cancel</button>
                  </div>
                </div>
              ) : !msg.content.trim() ? (
                <EmptyMessageView record={originalRecord} onEdit={() => startEdit(i)} />
              ) : isUser && !msgType ? (
                <div className="text-[15px] text-text-bright leading-relaxed whitespace-pre-wrap">{msg.content}</div>
              ) : msgType === "skill-invoke" ? (
                <SkillInvokeView content={msg.content} />
              ) : msgType === "system-reminder" ? (
                <SystemReminderView content={msg.content} />
              ) : msgType === "thinking" ? (
                <ThinkingView content={msg.content} />
              ) : msgType === "tool-use" ? (
                <ToolUseView content={msg.content} />
              ) : msgType === "tool-output" ? (
                <ToolOutputView content={msg.content} />
              ) : (
                <MarkdownView content={msg.content} />
              )}
            </div>

            {/* Insert divider between messages */}
            {isInsertingHere && insertTemplate ? (
              <TemplateForm
                template={insertTemplate}
                onSubmit={(msg) => handleInsertMessage(insertPos, msg)}
                onCancel={() => { setInsertingAt(null); setInsertTemplate(null); }}
              />
            ) : (
              <InsertDivider
                onInsert={(t) => handleSelectTemplate(insertPos, t)}
                active={isInsertingHere && !insertTemplate}
                onCancel={() => setInsertingAt(null)}
              />
            )}
          </React.Fragment>
        );
      })}

      {messages.length === 0 && (
        <p className="py-8 text-center text-sm text-text-dim">No messages</p>
      )}

      {/* Fixed bottom bar */}
      <div className="fixed bottom-0 left-0 right-0 z-10 border-t border-border-strong bg-canvas/95 backdrop-blur px-4 py-3">
        <div className="mx-auto flex max-w-4xl items-center gap-3">
          <span className="text-xs text-text-dim">{messages.length} messages</span>
          {dirty && <span className="text-xs text-glow">● draft saved</span>}
          <div className="flex-1" />
          <button
            onClick={handleRevert}
            disabled={!dirty}
            className="btn-action-danger text-xs disabled:opacity-30"
          >
            Revert
          </button>
          <button
            onClick={() => handleSaveEdit("new")}
            disabled={saving || !dirty}
            className="rounded border border-glow/40 px-4 py-1.5 text-sm font-medium text-glow hover:bg-glow/10 disabled:opacity-50 transition-colors"
            title="Save as a new conversation JSONL file with a new session ID. Original is unchanged."
          >
            {saving ? "Saving..." : "Save as New"}
          </button>
          <button
            onClick={() => handleSaveEdit("overwrite")}
            disabled={saving || !dirty}
            className="rounded bg-glow px-4 py-1.5 text-sm font-medium text-void hover:bg-glow/90 disabled:opacity-50"
            title="Overwrite the original JSONL file on disk with the edited messages."
          >
            {saving ? "Saving..." : "Save to Original"}
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Specialized content renderers for detected types ────────────────────────────

function ToolOutputView({ content }: { content: string }) {
  const [expanded, setExpanded] = useState(false);
  const isError = content.startsWith("[Tool Output: Error]");
  const body = content.replace(/^\[Tool Output(?:: Error)?\]\n?/, "");
  const preview = body.slice(0, 120);
  const isLong = body.length > 300;

  if (!isLong) {
    return (
      <pre className={`overflow-x-auto whitespace-pre-wrap rounded bg-void p-3 text-xs font-mono leading-relaxed max-h-96 overflow-y-auto ${isError ? "text-red-400" : "text-text-muted"}`}>
        {body}
      </pre>
    );
  }

  return (
    <div className="rounded-md border border-border-subtle bg-void/30">
      <button onClick={() => setExpanded(!expanded)} className={`collapse-toggle w-full text-left ${isError ? "text-red-400" : "text-text-dim"}`}>
        <span className="opacity-60">{expanded ? "▾" : "▸"}</span>
        <span className="font-medium">{isError ? "Error output" : "Output"}</span>
        <span className="ml-1 text-text-dim text-xs">({body.length.toLocaleString()} chars)</span>
        {!expanded && <span className="ml-1 flex-1 truncate opacity-50">{preview}</span>}
      </button>
      {expanded && (
        <div className="border-t border-border-subtle px-4 py-3 max-h-96 overflow-y-auto">
          <pre className={`whitespace-pre-wrap text-xs font-mono leading-relaxed ${isError ? "text-red-400" : "text-text-muted"}`}>{body}</pre>
        </div>
      )}
    </div>
  );
}

function SkillInvokeView({ content }: { content: string }) {
  const cmdMatch = content.match(/<command-name>(.*?)<\/command-name>/);
  const argsMatch = content.match(/<command-args>([\s\S]*?)<\/command-args>/);
  return (
    <div className="space-y-1">
      <span className="font-mono text-sm text-purple-400 font-medium">/{cmdMatch?.[1] ?? "unknown"}</span>
      {argsMatch?.[1]?.trim() && (
        <div className="text-sm text-text-primary">{argsMatch[1].trim()}</div>
      )}
    </div>
  );
}

function SystemReminderView({ content }: { content: string }) {
  const [expanded, setExpanded] = useState(false);
  const inner = content.replace(/<\/?system-reminder>/g, "").trim();
  const firstLine = inner.split("\n")[0].slice(0, 80);
  return (
    <div className="rounded-md border border-border-subtle">
      <button onClick={() => setExpanded(!expanded)} className="collapse-toggle text-text-dim w-full text-left">
        <span className="opacity-60">{expanded ? "▾" : "▸"}</span>
        <span className="font-medium">System reminder</span>
        {!expanded && <span className="ml-1 flex-1 truncate opacity-50">{firstLine}</span>}
      </button>
      {expanded && (
        <div className="border-t border-border-subtle px-4 py-3 max-h-96 overflow-y-auto">
          <MarkdownView content={inner} />
        </div>
      )}
    </div>
  );
}

function ThinkingView({ content }: { content: string }) {
  const [expanded, setExpanded] = useState(false);
  const inner = content.replace(/<\/?thinking>/g, "").trim();
  return (
    <div className="rounded-md border border-border-subtle bg-void/30">
      <button onClick={() => setExpanded(!expanded)} className="collapse-toggle text-text-dim w-full text-left">
        <span className="opacity-60">{expanded ? "▾" : "▸"}</span>
        <span className="font-medium">Thinking</span>
        {!expanded && <span className="ml-1 flex-1 truncate text-text-dim/60">{inner.slice(0, 100)}</span>}
      </button>
      {expanded && (
        <div className="border-t border-border-subtle px-4 py-3 max-h-96 overflow-y-auto">
          <MarkdownView content={inner} />
        </div>
      )}
    </div>
  );
}

function EmptyMessageView({ record, onEdit }: { record: ThreadRecord | null; onEdit: () => void }) {
  const [showRaw, setShowRaw] = useState(false);

  return (
    <div className="space-y-2">
      <div className="flex items-center gap-3">
        <span className="text-xs text-text-dim italic">No text content extracted</span>
        <button
          onClick={onEdit}
          className="text-xs text-glow hover:text-glow-bright transition-colors"
        >
          Add content
        </button>
        {record && (
          <button
            onClick={() => setShowRaw(!showRaw)}
            className="text-xs text-text-dim hover:text-text-muted transition-colors"
          >
            {showRaw ? "Hide raw" : "View raw JSONL"}
          </button>
        )}
      </div>
      {showRaw && record && (
        <pre className="overflow-x-auto whitespace-pre-wrap rounded bg-void p-3 text-xs text-text-muted font-mono leading-relaxed max-h-96 overflow-y-auto">
          {JSON.stringify(record, null, 2)}
        </pre>
      )}
    </div>
  );
}

function ToolUseView({ content }: { content: string }) {
  const headerMatch = content.match(/^\[Tool:\s*(\w+)\]/);
  const toolName = headerMatch?.[1] ?? "Unknown";
  const body = content.replace(/^\[Tool:\s*\w+\]\n?/, "");
  return (
    <div className="rounded-md border border-border-subtle bg-void/30">
      <div className="flex items-center gap-2 px-3 py-2 text-xs">
        <span className="font-mono text-glow font-medium">{toolName}</span>
      </div>
      {body && (
        <div className="border-t border-border-subtle px-3 py-2">
          <pre className="overflow-x-auto rounded bg-void p-3 text-xs text-text-bright font-mono leading-relaxed">{body}</pre>
        </div>
      )}
    </div>
  );
}
