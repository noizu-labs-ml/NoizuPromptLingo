"use client";

import React, { useState, useRef, useCallback } from "react";

/**
 * RichTextEditor — Markdown-capable editor with toolbar, live preview, image paste, and [[cross-link]] autocomplete.
 * Used across 10 screens — the highest-complexity T3 component.
 *
 * NOTE: This is a structural scaffold. Production integration should wire in a proper
 * markdown engine (e.g., unified/remark or Monaco) for AST-based rendering. The preview
 * here does basic markdown-to-HTML conversion for demonstration.
 *
 * @example
 * ```tsx
 * <RichTextEditor value={markdown} onChange={setMarkdown} toolbar preview />
 * <RichTextEditor value={md} onChange={setMd} variant="full_page" crossLinkEnabled />
 * ```
 */

type EditorVariant = "inline" | "compact" | "expanded" | "full_page";

interface RichTextEditorProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  toolbar?: boolean;
  preview?: boolean;
  crossLinkEnabled?: boolean;
  variant?: EditorVariant;
  minHeight?: number;
}

// ── HTML escaping (XSS prevention) ──────────────────────────────────────────
// Escape user input BEFORE markdown regex so injected tags are neutralized
// while the regex-produced HTML (e.g., <strong>) remains valid.
// TODO: Replace this entire scaffold with remark + rehype-sanitize pipeline.

function escapeHtml(raw: string): string {
  return raw
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

// ── Basic markdown → HTML (scaffold; replace with remark in production) ──

function basicMarkdownToHtml(md: string): string {
  const escaped = escapeHtml(md);
  return escaped
    .replace(/^### (.+)$/gm, "<h3>$1</h3>")
    .replace(/^## (.+)$/gm, "<h2>$1</h2>")
    .replace(/^# (.+)$/gm, "<h1>$1</h1>")
    .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
    .replace(/\*(.+?)\*/g, "<em>$1</em>")
    .replace(/`(.+?)`/g, '<code style="background:color-mix(in srgb, var(--text-muted) 10%, transparent);padding:1px 4px;border-radius:3px;font-family:var(--font-mono);font-size:var(--font-size-xs)">$1</code>')
    .replace(/\[\[(.+?)\]\]/g, '<a href="#" style="color:var(--info, var(--blue));text-decoration:underline">$1</a>')
    .replace(/^- (.+)$/gm, "<li>$1</li>")
    .replace(/(<li>.*<\/li>)/gs, "<ul>$1</ul>")
    .replace(/\n\n/g, "<br/><br/>")
    .replace(/\n/g, "<br/>");
}

// ── Toolbar buttons ──

interface ToolbarAction { label: string; icon: string; prefix: string; suffix: string; title: string; }

const toolbarActions: ToolbarAction[] = [
  { label: "Bold", icon: "B", prefix: "**", suffix: "**", title: "Bold (Ctrl+B)" },
  { label: "Italic", icon: "I", prefix: "*", suffix: "*", title: "Italic (Ctrl+I)" },
  { label: "Code", icon: "<>", prefix: "`", suffix: "`", title: "Inline code" },
  { label: "H2", icon: "H2", prefix: "## ", suffix: "", title: "Heading 2" },
  { label: "H3", icon: "H3", prefix: "### ", suffix: "", title: "Heading 3" },
  { label: "List", icon: "•", prefix: "- ", suffix: "", title: "Bullet list" },
  { label: "Link", icon: "🔗", prefix: "[[", suffix: "]]", title: "Cross-link" },
];

// ── Component ──

export function RichTextEditor({
  value,
  onChange,
  placeholder = "Write something...",
  toolbar = true,
  preview = false,
  crossLinkEnabled = false,
  variant = "expanded",
  minHeight = 200,
}: RichTextEditorProps) {
  const [showPreview, setShowPreview] = useState(preview && (variant === "full_page" || variant === "expanded"));
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const insertMarkdown = useCallback((prefix: string, suffix: string) => {
    const el = textareaRef.current;
    if (!el) return;
    const start = el.selectionStart;
    const end = el.selectionEnd;
    const selected = value.substring(start, end);
    const newValue = value.substring(0, start) + prefix + (selected || "text") + suffix + value.substring(end);
    onChange(newValue);
    // Restore cursor position after React re-render
    requestAnimationFrame(() => {
      el.focus();
      const newCursorPos = start + prefix.length + (selected ? selected.length : 4) + suffix.length;
      el.setSelectionRange(newCursorPos, newCursorPos);
    });
  }, [value, onChange]);

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.ctrlKey || e.metaKey) {
      if (e.key === "b") { e.preventDefault(); insertMarkdown("**", "**"); }
      if (e.key === "i") { e.preventDefault(); insertMarkdown("*", "*"); }
    }
    // [[cross-link trigger
    if (crossLinkEnabled && e.key === "[") {
      const el = textareaRef.current;
      if (el && value[el.selectionStart - 1] === "[") {
        // User typed [[ — autocomplete would trigger here in production
      }
    }
  };

  const handlePaste = (e: React.ClipboardEvent) => {
    const items = e.clipboardData?.items;
    if (!items) return;
    for (const item of Array.from(items)) {
      if (item.type.startsWith("image/")) {
        e.preventDefault();
        // In production: upload image and insert markdown image reference
        const el = textareaRef.current;
        if (el) {
          const pos = el.selectionStart;
          const newValue = value.substring(0, pos) + "![pasted image](uploading...)" + value.substring(pos);
          onChange(newValue);
        }
        break;
      }
    }
  };

  // ── Inline: single-line expanding ──
  if (variant === "inline") {
    return (
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        style={{
          width: "100%",
          padding: "6px 10px",
          borderRadius: "var(--radius, 6px)",
          border: "1px solid var(--border)",
          background: "var(--surface)",
          color: "var(--text)",
          fontFamily: "var(--font-body)",
          fontSize: "var(--font-size-sm)",
          outline: "none",
        }}
      />
    );
  }

  // ── Compact: multi-line without toolbar ──
  if (variant === "compact") {
    return (
      <textarea
        ref={textareaRef}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        onKeyDown={handleKeyDown}
        onPaste={handlePaste}
        placeholder={placeholder}
        rows={6}
        style={{
          width: "100%",
          padding: "var(--space-2)",
          borderRadius: "var(--radius, 6px)",
          border: "1px solid var(--border)",
          background: "var(--surface)",
          color: "var(--text)",
          fontFamily: "var(--font-mono)",
          fontSize: "var(--font-size-sm)",
          resize: "vertical",
          minHeight: 100,
          outline: "none",
          lineHeight: 1.6,
        }}
      />
    );
  }

  // ── Expanded / Full Page ──
  const isSplit = variant === "full_page" || showPreview;

  return (
    <div style={{ display: "flex", flexDirection: "column", border: "1px solid var(--border)", borderRadius: "var(--radius, 6px)", background: "var(--surface)", overflow: "hidden" }}>
      {/* Toolbar */}
      {toolbar && (
        <div style={{ display: "flex", alignItems: "center", gap: "2px", padding: "4px 8px", borderBottom: "1px solid var(--border)", background: "color-mix(in srgb, var(--text-muted) 4%, transparent)", flexWrap: "wrap" }}>
          {toolbarActions.map((action) => {
            if (action.label === "Link" && !crossLinkEnabled) return null;
            return (
              <button
                key={action.label}
                type="button"
                onClick={() => insertMarkdown(action.prefix, action.suffix)}
                title={action.title}
                style={{
                  padding: "2px 8px",
                  borderRadius: 4,
                  border: "none",
                  background: "none",
                  color: "var(--text-secondary)",
                  fontFamily: action.icon.match(/^[A-Z]/) ? "var(--font-mono)" : "var(--font-body)",
                  fontSize: "var(--font-size-xs)",
                  fontWeight: action.label === "Bold" ? 700 : action.label === "Italic" ? 400 : 500,
                  fontStyle: action.label === "Italic" ? "italic" : "normal",
                  cursor: "pointer",
                }}
              >
                {action.icon}
              </button>
            );
          })}
          <div style={{ flex: 1 }} />
          <button
            type="button"
            onClick={() => setShowPreview(!showPreview)}
            style={{
              padding: "2px 8px",
              borderRadius: 4,
              border: "1px solid var(--border)",
              background: showPreview ? "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)" : "none",
              color: showPreview ? "var(--info, var(--blue))" : "var(--text-muted)",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-2xs, 10px)",
              cursor: "pointer",
            }}
          >
            {showPreview ? "Hide Preview" : "Preview"}
          </button>
        </div>
      )}

      {/* Editor + Preview */}
      <div style={{ display: "flex", flex: 1, minHeight }}>
        {/* Editor pane */}
        <div style={{ flex: 1, display: "flex" }}>
          <textarea
            ref={textareaRef}
            value={value}
            onChange={(e) => onChange(e.target.value)}
            onKeyDown={handleKeyDown}
            onPaste={handlePaste}
            placeholder={placeholder}
            aria-label="Rich text editor"
            style={{
              flex: 1,
              padding: "var(--space-2) var(--space-3)",
              border: "none",
              background: "transparent",
              color: "var(--text)",
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-sm)",
              resize: "none",
              outline: "none",
              lineHeight: 1.6,
              minHeight,
            }}
          />
        </div>

        {/* Preview pane */}
        {isSplit && (
          <div
            style={{
              flex: 1,
              padding: "var(--space-2) var(--space-3)",
              borderLeft: "1px solid var(--border)",
              overflow: "auto",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-sm)",
              color: "var(--text)",
              lineHeight: 1.6,
              background: "color-mix(in srgb, var(--text-muted) 3%, transparent)",
            }}
            dangerouslySetInnerHTML={{ __html: basicMarkdownToHtml(value) || `<span style="color:var(--text-muted);font-style:italic">Preview will appear here</span>` }}
          />
        )}
      </div>

      {/* Status bar */}
      <div style={{ display: "flex", justifyContent: "space-between", padding: "2px 8px", borderTop: "1px solid var(--border)", background: "color-mix(in srgb, var(--text-muted) 4%, transparent)" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>
          Markdown · {value.split(/\s+/).filter(Boolean).length} words · {value.length} chars
        </span>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>
          Ctrl+B bold · Ctrl+I italic
        </span>
      </div>
    </div>
  );
}

export default RichTextEditor;
