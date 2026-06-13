"use client";

import React, { useCallback } from "react";

/**
 * DuplicateSuggestionPanel — Dropdown panel appearing during item creation, showing
 * potentially duplicate existing items with confidence scores. Supports compact (inline
 * dropdown) and expanded (side panel with full comparison) variants.
 *
 * Composes: ConfidenceScore (T0) for similarity display.
 * Used in: Bug Report Form, Customer Bug Intake.
 *
 * The parent is responsible for running the similarity query and passing results via
 * the `suggestions` prop. This component handles display and selection only.
 *
 * @example
 * ```tsx
 * <DuplicateSuggestionPanel
 *   query={inputText}
 *   suggestions={dupes}
 *   onSelectDuplicate={(id) => linkToExisting(id)}
 *   onDismiss={() => setShowDupes(false)}
 * />
 * <DuplicateSuggestionPanel
 *   query={inputText}
 *   suggestions={dupes}
 *   onSelectDuplicate={linkDupe}
 *   onDismiss={dismiss}
 *   variant="expanded"
 *   threshold={0.6}
 * />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type PanelVariant = "compact" | "expanded";

interface SuggestionItem {
  /** Unique identifier */
  id: string;
  /** Item title */
  title: string;
  /** Similarity score 0-1 */
  similarity: number;
  /** Optional: item type label (e.g., "Bug", "Task") */
  type?: string;
  /** Optional: item status */
  status?: string;
  /** Optional: creation date ISO string */
  createdAt?: string;
  /** Optional: description excerpt */
  excerpt?: string;
}

interface DuplicateSuggestionPanelProps {
  /** Current input text being checked */
  query: string;
  /** Array of potential duplicates */
  suggestions: SuggestionItem[];
  /** Fires when user selects an existing item as the duplicate */
  onSelectDuplicate: (id: string) => void;
  /** Fires when user dismisses the panel to continue creating new */
  onDismiss: () => void;
  /** Minimum similarity threshold for display (items below this are filtered) */
  threshold?: number;
  /** Display variant */
  variant?: PanelVariant;
  /** Whether a search is in progress */
  loading?: boolean;
}

// ── Helpers ─────────────────────────────────────────────────────

function confidenceColor(score: number): string {
  if (score >= 0.8) return "var(--success)";
  if (score >= 0.5) return "var(--warning)";
  return "var(--error)";
}

function formatPercent(score: number): string {
  return `${Math.round(score * 100)}%`;
}

function relativeDate(iso: string): string {
  try {
    const d = new Date(iso);
    const now = new Date();
    const diffMs = now.getTime() - d.getTime();
    const days = Math.floor(diffMs / 86400000);
    if (days === 0) return "today";
    if (days === 1) return "yesterday";
    if (days < 30) return `${days}d ago`;
    const months = Math.floor(days / 30);
    return `${months}mo ago`;
  } catch {
    return iso;
  }
}

// ── Component ───────────────────────────────────────────────────

export function DuplicateSuggestionPanel({
  query,
  suggestions,
  onSelectDuplicate,
  onDismiss,
  threshold = 0.3,
  variant = "compact",
  loading = false,
}: DuplicateSuggestionPanelProps) {
  const filtered = suggestions.filter((s) => s.similarity >= threshold);

  const handleSelect = useCallback(
    (id: string) => {
      onSelectDuplicate(id);
    },
    [onSelectDuplicate],
  );

  // Nothing to show
  if (!loading && filtered.length === 0) return null;

  const isExpanded = variant === "expanded";

  return (
    <div
      role="region"
      aria-label="Potential duplicates"
      aria-live="polite"
      style={{
        border: "1px solid var(--border)",
        borderRadius: "var(--radius, 6px)",
        background: "var(--surface)",
        overflow: "hidden",
        ...(isExpanded
          ? { maxHeight: 400, display: "flex", flexDirection: "column" as const }
          : { maxHeight: 260 }),
      }}
    >
      {/* Header */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          padding: "6px 12px",
          borderBottom: "1px solid var(--border)",
          background: "color-mix(in srgb, var(--warning) 6%, transparent)",
          flexShrink: 0,
        }}
      >
        <span
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: "6px",
            fontFamily: "var(--font-body)",
            fontSize: "var(--font-size-xs)",
            fontWeight: 600,
            color: "var(--warning)",
          }}
        >
          <span
            style={{
              width: 6,
              height: 6,
              borderRadius: "50%",
              background: "var(--warning)",
              flexShrink: 0,
            }}
          />
          {loading
            ? "Checking for duplicates..."
            : `${filtered.length} potential duplicate${filtered.length !== 1 ? "s" : ""}`}
        </span>
        <button
          type="button"
          onClick={onDismiss}
          aria-label="Dismiss duplicate suggestions"
          style={{
            background: "none",
            border: "none",
            color: "var(--text-muted)",
            fontFamily: "var(--font-body)",
            fontSize: "var(--font-size-2xs, 10px)",
            cursor: "pointer",
            textDecoration: "underline",
          }}
        >
          Create new anyway
        </button>
      </div>

      {/* Loading state */}
      {loading && (
        <div
          style={{
            padding: "var(--space-3)",
            textAlign: "center",
            fontFamily: "var(--font-body)",
            fontSize: "var(--font-size-xs)",
            color: "var(--text-muted)",
          }}
        >
          Searching existing items...
        </div>
      )}

      {/* Suggestion list */}
      {!loading && (
        <div
          style={{
            overflow: "auto",
            flex: isExpanded ? 1 : undefined,
          }}
        >
          {filtered.map((item, i) => (
            <button
              key={item.id}
              type="button"
              onClick={() => handleSelect(item.id)}
              aria-label={`Select duplicate: ${item.title} — ${formatPercent(item.similarity)} match`}
              style={{
                display: "flex",
                flexDirection: isExpanded ? "column" : "row",
                alignItems: isExpanded ? "stretch" : "center",
                gap: isExpanded ? "6px" : "8px",
                width: "100%",
                padding: isExpanded ? "var(--space-2) 12px" : "8px 12px",
                border: "none",
                borderBottom:
                  i < filtered.length - 1 ? "1px solid var(--border)" : "none",
                background: "transparent",
                color: "var(--text)",
                cursor: "pointer",
                textAlign: "left",
                transition: "background 0.1s",
              }}
              onMouseEnter={(e) => {
                (e.currentTarget.style.background =
                  "color-mix(in srgb, var(--text-muted) 6%, transparent)");
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.background = "transparent";
              }}
            >
              {/* Compact: single row */}
              {!isExpanded && (
                <>
                  {/* Confidence dot + percent */}
                  <span
                    style={{
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "4px",
                      fontFamily: "var(--font-mono)",
                      fontSize: "var(--font-size-xs)",
                      fontWeight: 600,
                      color: confidenceColor(item.similarity),
                      flexShrink: 0,
                      width: 44,
                    }}
                  >
                    <span
                      style={{
                        width: 6,
                        height: 6,
                        borderRadius: "50%",
                        background: confidenceColor(item.similarity),
                      }}
                    />
                    {formatPercent(item.similarity)}
                  </span>

                  {/* Title */}
                  <span
                    style={{
                      flex: 1,
                      fontFamily: "var(--font-body)",
                      fontSize: "var(--font-size-sm)",
                      color: "var(--text)",
                      overflow: "hidden",
                      textOverflow: "ellipsis",
                      whiteSpace: "nowrap",
                    }}
                  >
                    {item.title}
                  </span>

                  {/* Type badge */}
                  {item.type && (
                    <span
                      style={{
                        padding: "1px 6px",
                        borderRadius: "999px",
                        background: "color-mix(in srgb, var(--text-muted) 10%, transparent)",
                        fontFamily: "var(--font-mono)",
                        fontSize: "var(--font-size-2xs, 10px)",
                        color: "var(--text-muted)",
                        flexShrink: 0,
                      }}
                    >
                      {item.type}
                    </span>
                  )}
                </>
              )}

              {/* Expanded: multi-line with excerpt */}
              {isExpanded && (
                <>
                  <div
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: "8px",
                    }}
                  >
                    <span
                      style={{
                        display: "inline-flex",
                        alignItems: "center",
                        gap: "4px",
                        fontFamily: "var(--font-mono)",
                        fontSize: "var(--font-size-xs)",
                        fontWeight: 600,
                        color: confidenceColor(item.similarity),
                      }}
                    >
                      <span
                        style={{
                          width: 6,
                          height: 6,
                          borderRadius: "50%",
                          background: confidenceColor(item.similarity),
                        }}
                      />
                      {formatPercent(item.similarity)} match
                    </span>
                    {item.type && (
                      <span
                        style={{
                          padding: "1px 6px",
                          borderRadius: "999px",
                          background: "color-mix(in srgb, var(--text-muted) 10%, transparent)",
                          fontFamily: "var(--font-mono)",
                          fontSize: "var(--font-size-2xs, 10px)",
                          color: "var(--text-muted)",
                        }}
                      >
                        {item.type}
                      </span>
                    )}
                    {item.status && (
                      <span
                        style={{
                          padding: "1px 6px",
                          borderRadius: "999px",
                          background: "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)",
                          fontFamily: "var(--font-mono)",
                          fontSize: "var(--font-size-2xs, 10px)",
                          color: "var(--info, var(--blue))",
                        }}
                      >
                        {item.status}
                      </span>
                    )}
                    {item.createdAt && (
                      <span
                        style={{
                          marginLeft: "auto",
                          fontFamily: "var(--font-mono)",
                          fontSize: "var(--font-size-2xs, 10px)",
                          color: "var(--text-muted)",
                        }}
                      >
                        {relativeDate(item.createdAt)}
                      </span>
                    )}
                  </div>

                  <span
                    style={{
                      fontFamily: "var(--font-body)",
                      fontSize: "var(--font-size-sm)",
                      fontWeight: 500,
                      color: "var(--text)",
                    }}
                  >
                    {item.title}
                  </span>

                  {item.excerpt && (
                    <span
                      style={{
                        fontFamily: "var(--font-body)",
                        fontSize: "var(--font-size-xs)",
                        color: "var(--text-muted)",
                        lineHeight: 1.4,
                        display: "-webkit-box",
                        WebkitLineClamp: 2,
                        WebkitBoxOrient: "vertical",
                        overflow: "hidden",
                      }}
                    >
                      {item.excerpt}
                    </span>
                  )}
                </>
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

export default DuplicateSuggestionPanel;
