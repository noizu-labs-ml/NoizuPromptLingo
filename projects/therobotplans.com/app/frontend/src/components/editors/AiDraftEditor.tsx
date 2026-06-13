"use client";

import React, { useState, useCallback, useRef } from "react";

/**
 * AiDraftEditor — Editable content block pre-filled by AI with visible edit tracking,
 * accept-as-is, regenerate, and diff-against-original controls.
 *
 * Composes: RichTextEditor (T3).
 * Used across 9 screens — highest-usage T4 component and critical-path terminus.
 *
 * NOTE: Scaffold. The diff engine uses a naive line-based comparison. Production should
 * integrate a proper diff library (e.g., diff-match-patch or jsdiff) for word-level diffs.
 *
 * @example
 * ```tsx
 * <AiDraftEditor
 *   draft="AI-generated quarterly summary..."
 *   onEdit={(text) => setSummary(text)}
 *   onAccept={() => finalize()}
 *   sectionTitle="Executive Summary"
 * />
 * <AiDraftEditor
 *   draft={longDoc}
 *   onEdit={setDoc}
 *   onAccept={save}
 *   variant="full_page"
 *   onRegenerate={() => refetch()}
 * />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type DraftVariant = "expanded" | "full_page";

interface AiDraftEditorProps {
  /** AI-generated draft text (markdown) */
  draft: string;
  /** Fires on every edit */
  onEdit: (value: string) => void;
  /** Fires when user accepts the current content */
  onAccept: () => void;
  /** Optional: request a fresh AI generation */
  onRegenerate?: () => void;
  /** Show the "AI Generated" badge */
  showAIBadge?: boolean;
  /** Section heading displayed above the editor */
  sectionTitle?: string;
  /** Display variant */
  variant?: DraftVariant;
  /** Whether a regeneration is in progress */
  regenerating?: boolean;
}

// ── Naive diff helper (scaffold — replace with jsdiff in production) ──

interface DiffLine {
  type: "added" | "removed" | "unchanged";
  text: string;
}

function naiveDiff(original: string, current: string): DiffLine[] {
  const origLines = original.split("\n");
  const currLines = current.split("\n");
  const maxLen = Math.max(origLines.length, currLines.length);
  const result: DiffLine[] = [];

  for (let i = 0; i < maxLen; i++) {
    const o = origLines[i];
    const c = currLines[i];
    if (o === undefined) {
      result.push({ type: "added", text: c });
    } else if (c === undefined) {
      result.push({ type: "removed", text: o });
    } else if (o !== c) {
      result.push({ type: "removed", text: o });
      result.push({ type: "added", text: c });
    } else {
      result.push({ type: "unchanged", text: o });
    }
  }
  return result;
}

// ── Component ───────────────────────────────────────────────────

export function AiDraftEditor({
  draft,
  onEdit,
  onAccept,
  onRegenerate,
  showAIBadge = true,
  sectionTitle,
  variant = "expanded",
  regenerating = false,
}: AiDraftEditorProps) {
  const [currentValue, setCurrentValue] = useState(draft);
  const [showDiff, setShowDiff] = useState(false);
  const originalRef = useRef(draft);

  // Track whether the user has made any edits
  const isEdited = currentValue !== originalRef.current;

  const handleChange = useCallback(
    (value: string) => {
      setCurrentValue(value);
      onEdit(value);
    },
    [onEdit],
  );

  const handleAccept = useCallback(() => {
    onAccept();
  }, [onAccept]);

  const handleRegenerate = useCallback(() => {
    onRegenerate?.();
  }, [onRegenerate]);

  const handleRevert = useCallback(() => {
    setCurrentValue(originalRef.current);
    onEdit(originalRef.current);
  }, [onEdit]);

  // When the parent supplies a new draft (e.g., after regeneration), reset baseline
  if (draft !== originalRef.current && draft !== currentValue) {
    originalRef.current = draft;
    setCurrentValue(draft);
  }

  const diff = showDiff ? naiveDiff(originalRef.current, currentValue) : [];
  const isFullPage = variant === "full_page";
  const minHeight = isFullPage ? 400 : 200;

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        border: "1px solid var(--border)",
        borderRadius: "var(--radius, 6px)",
        background: "var(--surface)",
        overflow: "hidden",
      }}
    >
      {/* ── Header bar ── */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: "8px",
          padding: "6px 12px",
          borderBottom: "1px solid var(--border)",
          background: "color-mix(in srgb, var(--text-muted) 4%, transparent)",
          flexWrap: "wrap",
        }}
      >
        {sectionTitle && (
          <span
            style={{
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-sm)",
              fontWeight: 600,
              color: "var(--text)",
            }}
          >
            {sectionTitle}
          </span>
        )}

        {showAIBadge && (
          <span
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
              padding: "1px 8px",
              borderRadius: "999px",
              background: "color-mix(in srgb, var(--info, var(--blue)) 12%, transparent)",
              color: "var(--info, var(--blue))",
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-2xs, 10px)",
              fontWeight: 600,
              textTransform: "uppercase",
              letterSpacing: "0.03em",
            }}
          >
            AI Generated
          </span>
        )}

        {isEdited && (
          <span
            style={{
              padding: "1px 6px",
              borderRadius: "999px",
              background: "color-mix(in srgb, var(--warning) 12%, transparent)",
              color: "var(--warning)",
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-2xs, 10px)",
              fontWeight: 600,
            }}
          >
            Edited
          </span>
        )}

        <div style={{ flex: 1 }} />

        {/* Diff toggle */}
        {isEdited && (
          <button
            type="button"
            onClick={() => setShowDiff(!showDiff)}
            aria-pressed={showDiff}
            style={{
              padding: "2px 8px",
              borderRadius: 4,
              border: "1px solid var(--border)",
              background: showDiff
                ? "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)"
                : "none",
              color: showDiff ? "var(--info, var(--blue))" : "var(--text-muted)",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-2xs, 10px)",
              cursor: "pointer",
            }}
          >
            {showDiff ? "Hide Diff" : "View Changes"}
          </button>
        )}

        {/* Revert */}
        {isEdited && (
          <button
            type="button"
            onClick={handleRevert}
            aria-label="Revert to AI original"
            style={{
              padding: "2px 8px",
              borderRadius: 4,
              border: "1px solid var(--border)",
              background: "none",
              color: "var(--text-muted)",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-2xs, 10px)",
              cursor: "pointer",
            }}
          >
            Revert
          </button>
        )}
      </div>

      {/* ── Diff viewer (replaces editor when active) ── */}
      {showDiff ? (
        <div
          role="region"
          aria-label="Diff view — changes from AI original"
          style={{
            padding: "var(--space-2) var(--space-3)",
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-xs)",
            lineHeight: 1.8,
            minHeight,
            overflow: "auto",
          }}
        >
          {diff.map((line, i) => (
            <div
              key={i}
              style={{
                padding: "0 4px",
                borderRadius: 2,
                background:
                  line.type === "added"
                    ? "color-mix(in srgb, var(--success) 10%, transparent)"
                    : line.type === "removed"
                      ? "color-mix(in srgb, var(--error) 10%, transparent)"
                      : "none",
                color:
                  line.type === "added"
                    ? "var(--success)"
                    : line.type === "removed"
                      ? "var(--error)"
                      : "var(--text)",
                textDecoration: line.type === "removed" ? "line-through" : "none",
              }}
            >
              <span style={{ display: "inline-block", width: 16, color: "var(--text-muted)", userSelect: "none" }}>
                {line.type === "added" ? "+" : line.type === "removed" ? "-" : " "}
              </span>
              {line.text || " "}
            </div>
          ))}
        </div>
      ) : (
        /* ── Editor pane — wrapping RichTextEditor inline (same structure) ── */
        <textarea
          value={currentValue}
          onChange={(e) => handleChange(e.target.value)}
          aria-label={sectionTitle ? `Edit ${sectionTitle}` : "Edit AI draft"}
          placeholder="Edit the AI-generated draft..."
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
      )}

      {/* ── Footer actions ── */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: "8px",
          padding: "6px 12px",
          borderTop: "1px solid var(--border)",
          background: "color-mix(in srgb, var(--text-muted) 4%, transparent)",
        }}
      >
        <button
          type="button"
          onClick={handleAccept}
          style={{
            padding: "4px 14px",
            borderRadius: "var(--radius, 6px)",
            border: "none",
            background: "var(--success)",
            color: "#fff",
            fontFamily: "var(--font-body)",
            fontSize: "var(--font-size-xs)",
            fontWeight: 600,
            cursor: "pointer",
          }}
        >
          {isEdited ? "Accept Edits" : "Accept As-Is"}
        </button>

        {onRegenerate && (
          <button
            type="button"
            onClick={handleRegenerate}
            disabled={regenerating}
            aria-label="Regenerate AI draft"
            style={{
              padding: "4px 14px",
              borderRadius: "var(--radius, 6px)",
              border: "1px solid var(--border)",
              background: "none",
              color: regenerating ? "var(--text-muted)" : "var(--text-secondary)",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-xs)",
              fontWeight: 500,
              cursor: regenerating ? "not-allowed" : "pointer",
              opacity: regenerating ? 0.6 : 1,
            }}
          >
            {regenerating ? "Regenerating..." : "Regenerate"}
          </button>
        )}

        <div style={{ flex: 1 }} />

        <span
          style={{
            fontFamily: "var(--font-mono)",
            fontSize: "var(--font-size-2xs, 10px)",
            color: "var(--text-muted)",
          }}
        >
          {currentValue.split(/\s+/).filter(Boolean).length} words
        </span>
      </div>
    </div>
  );
}

export default AiDraftEditor;
