"use client";

import React, { useState } from "react";

/**
 * AiSuggestionList — Ranked list of AI-generated suggestions with rationale, accept/reject, and confidence.
 * Depends on: AcceptRejectControls (T1), ConfidenceScore (T0), RationalePopover (T1).
 * Used across 9 screens — the core AI interaction pattern.
 *
 * @example
 * ```tsx
 * <AiSuggestionList
 *   suggestions={[{ id: "1", text: "Move to sprint 15", rationale: "Based on priority and capacity", confidence: 0.87 }]}
 *   onAccept={(id) => accept(id)}
 *   onReject={(id, reason) => reject(id, reason)}
 *   showRationale bulkActions
 * />
 * ```
 */

interface Suggestion {
  id: string;
  text: string;
  rationale?: string;
  confidence: number;
  category?: string;
  metadata?: Record<string, string>;
}

type SuggestionVariant = "compact" | "expanded" | "full_page";

interface AiSuggestionListProps {
  suggestions: Suggestion[];
  onAccept: (id: string) => void;
  onReject: (id: string, reason?: string) => void;
  onModify?: (id: string) => void;
  bulkActions?: boolean;
  showRationale?: boolean;
  variant?: SuggestionVariant;
}

// ── Helpers ──

function confidenceColor(c: number): string {
  if (c >= 0.8) return "var(--success)";
  if (c >= 0.5) return "var(--warning)";
  return "var(--error)";
}

function confidenceLabel(c: number): string {
  if (c >= 0.8) return "High";
  if (c >= 0.5) return "Medium";
  return "Low";
}

// ── Component ──

export function AiSuggestionList({
  suggestions,
  onAccept,
  onReject,
  onModify,
  bulkActions = false,
  showRationale = true,
  variant = "expanded",
}: AiSuggestionListProps) {
  const [dismissed, setDismissed] = useState<Set<string>>(new Set());
  const [expandedRationale, setExpandedRationale] = useState<Set<string>>(new Set());

  const visible = suggestions.filter((s) => !dismissed.has(s.id));
  const highConfidence = visible.filter((s) => s.confidence >= 0.8);

  const handleReject = (id: string, reason?: string) => {
    setDismissed((d) => new Set(d).add(id));
    onReject(id, reason);
  };

  const handleAccept = (id: string) => {
    setDismissed((d) => new Set(d).add(id));
    onAccept(id);
  };

  const bulkAcceptHigh = () => {
    highConfidence.forEach((s) => handleAccept(s.id));
  };

  const toggleRationale = (id: string) => {
    setExpandedRationale((s) => { const n = new Set(s); n.has(id) ? n.delete(id) : n.add(id); return n; });
  };

  if (visible.length === 0) {
    return (
      <div style={{ padding: "var(--space-4)", textAlign: "center", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontStyle: "italic" }}>
        {suggestions.length > 0 ? "All suggestions reviewed ✓" : "No suggestions available"}
      </div>
    );
  }

  // ── Compact: chips ──
  if (variant === "compact") {
    return (
      <div style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
        {bulkActions && highConfidence.length > 1 && (
          <button type="button" onClick={bulkAcceptHigh} style={{ alignSelf: "flex-start", padding: "3px 10px", borderRadius: "999px", border: "1px solid var(--success)", background: "color-mix(in srgb, var(--success) 8%, transparent)", color: "var(--success)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, cursor: "pointer", marginBottom: 4 }}>
            ✓ Accept all high-confidence ({highConfidence.length})
          </button>
        )}
        {visible.map((s) => (
          <div key={s.id} style={{ display: "flex", alignItems: "center", gap: "6px", padding: "4px 8px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)" }}>
            <span style={{ width: 6, height: 6, borderRadius: "50%", background: confidenceColor(s.confidence), flexShrink: 0 }} title={`${Math.round(s.confidence * 100)}%`} />
            <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text)", flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{s.text}</span>
            <button type="button" onClick={() => handleAccept(s.id)} title="Accept" style={{ background: "none", border: "none", color: "var(--success)", cursor: "pointer", fontSize: "var(--font-size-sm)", padding: "0 2px" }}>✓</button>
            <button type="button" onClick={() => handleReject(s.id)} title="Dismiss" style={{ background: "none", border: "none", color: "var(--error)", cursor: "pointer", fontSize: "var(--font-size-sm)", padding: "0 2px" }}>✗</button>
          </div>
        ))}
      </div>
    );
  }

  // ── Expanded / Full Page ──
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
      {/* Header with bulk actions */}
      <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.06em", color: "var(--text-muted)" }}>
          ⚡ {visible.length} Suggestion{visible.length !== 1 ? "s" : ""}
        </span>
        {bulkActions && highConfidence.length > 1 && (
          <button type="button" onClick={bulkAcceptHigh} style={{ padding: "2px 10px", borderRadius: "999px", border: "1px solid var(--success)", background: "color-mix(in srgb, var(--success) 8%, transparent)", color: "var(--success)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, cursor: "pointer", marginLeft: "auto" }}>
            ✓ Accept all high ({highConfidence.length})
          </button>
        )}
      </div>

      {/* Suggestion cards */}
      {visible.map((s) => (
        <div key={s.id} style={{ padding: "var(--space-2) var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", display: "flex", flexDirection: "column", gap: "6px" }}>
          {/* Main row */}
          <div style={{ display: "flex", alignItems: "flex-start", gap: "8px" }}>
            {/* Confidence badge */}
            <span style={{ display: "inline-flex", alignItems: "center", gap: "3px", padding: "2px 6px", borderRadius: "999px", background: `color-mix(in srgb, ${confidenceColor(s.confidence)} 12%, transparent)`, color: confidenceColor(s.confidence), fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 700, flexShrink: 0, marginTop: 2 }}>
              {Math.round(s.confidence * 100)}%
            </span>

            {/* Text */}
            <div style={{ flex: 1 }}>
              <p style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", color: "var(--text)", margin: 0, lineHeight: 1.4 }}>{s.text}</p>
              {s.category && (
                <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", marginTop: 2, display: "inline-block" }}>{s.category}</span>
              )}
            </div>
          </div>

          {/* Rationale (expandable) */}
          {showRationale && s.rationale && (
            <div>
              <button type="button" onClick={() => toggleRationale(s.id)} style={{ background: "none", border: "none", padding: 0, cursor: "pointer", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", textDecoration: "underline", textDecorationStyle: "dotted" }}>
                {expandedRationale.has(s.id) ? "Hide rationale ▴" : "Why? ▾"}
              </button>
              {expandedRationale.has(s.id) && (
                <div style={{ marginTop: 4, padding: "6px 10px", borderRadius: 4, background: "color-mix(in srgb, var(--text-muted) 6%, transparent)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)", lineHeight: 1.4 }}>
                  {s.rationale}
                </div>
              )}
            </div>
          )}

          {/* Action buttons */}
          <div style={{ display: "flex", gap: "6px", alignItems: "center" }}>
            <button type="button" onClick={() => handleAccept(s.id)} style={{ padding: "3px 12px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--success)", background: "color-mix(in srgb, var(--success) 8%, transparent)", color: "var(--success)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, cursor: "pointer" }}>✓ Accept</button>
            {onModify && (
              <button type="button" onClick={() => onModify(s.id)} style={{ padding: "3px 12px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--warning)", background: "color-mix(in srgb, var(--warning) 8%, transparent)", color: "var(--warning)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, cursor: "pointer" }}>✎ Modify</button>
            )}
            <button type="button" onClick={() => handleReject(s.id)} style={{ padding: "3px 12px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--error)", background: "color-mix(in srgb, var(--error) 8%, transparent)", color: "var(--error)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, cursor: "pointer" }}>✗ Reject</button>
          </div>
        </div>
      ))}
    </div>
  );
}

export default AiSuggestionList;
