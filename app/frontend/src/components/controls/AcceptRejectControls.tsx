"use client";

import React, { useState } from "react";

/**
 * AcceptRejectControls — Binary/ternary action buttons for AI suggestions.
 *
 * @example
 * ```tsx
 * <AcceptRejectControls onAccept={accept} onReject={reject} variant="inline" />
 * <AcceptRejectControls onAccept={accept} onReject={reject} onModify={modify} variant="compact" />
 * <AcceptRejectControls onAccept={accept} onReject={reject} requireReason variant="expanded" />
 * ```
 */

type ControlVariant = "inline" | "compact" | "expanded";

interface AcceptRejectControlsProps {
  onAccept: () => void;
  onReject: (reason?: string) => void;
  onModify?: () => void;
  requireReason?: boolean;
  variant?: ControlVariant;
}

export function AcceptRejectControls({ onAccept, onReject, onModify, requireReason = false, variant = "compact" }: AcceptRejectControlsProps) {
  const [showReason, setShowReason] = useState(false);
  const [reason, setReason] = useState("");

  const handleReject = () => {
    if (requireReason && !showReason) { setShowReason(true); return; }
    onReject(reason || undefined);
    setShowReason(false);
    setReason("");
  };

  if (variant === "inline") {
    return (
      <span style={{ display: "inline-flex", gap: "4px" }}>
        <button type="button" onClick={onAccept} aria-label="Accept" title="Accept (A)" style={{ background: "none", border: "none", cursor: "pointer", fontSize: "var(--font-size-base)", padding: "2px", color: "var(--success)", lineHeight: 1 }}>👍</button>
        <button type="button" onClick={handleReject} aria-label="Reject" title="Reject (R)" style={{ background: "none", border: "none", cursor: "pointer", fontSize: "var(--font-size-base)", padding: "2px", color: "var(--error)", lineHeight: 1 }}>👎</button>
      </span>
    );
  }

  if (variant === "compact") {
    return (
      <div style={{ display: "flex", gap: "6px", alignItems: "center", flexWrap: "wrap" }}>
        <button type="button" onClick={onAccept} style={{ padding: "4px 12px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--success)", background: "color-mix(in srgb, var(--success) 10%, transparent)", color: "var(--success)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, cursor: "pointer" }}>
          ✓ Accept
        </button>
        {onModify && (
          <button type="button" onClick={onModify} style={{ padding: "4px 12px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--warning)", background: "color-mix(in srgb, var(--warning) 10%, transparent)", color: "var(--warning)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, cursor: "pointer" }}>
            ✎ Modify
          </button>
        )}
        <button type="button" onClick={handleReject} style={{ padding: "4px 12px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--error)", background: "color-mix(in srgb, var(--error) 10%, transparent)", color: "var(--error)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, cursor: "pointer" }}>
          ✗ Reject
        </button>
        {showReason && (
          <div style={{ width: "100%", display: "flex", gap: "6px", marginTop: 4 }}>
            <input type="text" value={reason} onChange={(e) => setReason(e.target.value)} placeholder="Reason for rejection..." onKeyDown={(e) => e.key === "Enter" && handleReject()} style={{ flex: 1, padding: "4px 8px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)" }} autoFocus />
            <button type="button" onClick={handleReject} style={{ padding: "4px 8px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--error)", background: "var(--error)", color: "#fff", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, cursor: "pointer" }}>Send</button>
          </div>
        )}
      </div>
    );
  }

  // expanded — full Accept/Modify/Reject with reason textarea
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)", padding: "var(--space-2)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)" }}>
      <div style={{ display: "flex", gap: "8px" }}>
        <button type="button" onClick={onAccept} style={{ flex: 1, padding: "6px 12px", borderRadius: "var(--radius, 6px)", border: "none", background: "var(--success)", color: "#fff", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 600, cursor: "pointer" }}>
          ✓ Accept
        </button>
        {onModify && (
          <button type="button" onClick={onModify} style={{ flex: 1, padding: "6px 12px", borderRadius: "var(--radius, 6px)", border: "none", background: "var(--warning)", color: "#fff", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 600, cursor: "pointer" }}>
            ✎ Modify
          </button>
        )}
        <button type="button" onClick={() => (requireReason ? setShowReason(true) : onReject())} style={{ flex: 1, padding: "6px 12px", borderRadius: "var(--radius, 6px)", border: "none", background: "var(--error)", color: "#fff", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 600, cursor: "pointer" }}>
          ✗ Reject
        </button>
      </div>
      {showReason && (
        <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
          <textarea value={reason} onChange={(e) => setReason(e.target.value)} placeholder="Why are you rejecting this suggestion?" rows={2} style={{ padding: "var(--space-2)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--bg)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", resize: "vertical" }} autoFocus />
          <div style={{ display: "flex", gap: "6px", justifyContent: "flex-end" }}>
            <button type="button" onClick={() => { setShowReason(false); setReason(""); }} style={{ padding: "3px 10px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text-secondary)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>Cancel</button>
            <button type="button" onClick={handleReject} style={{ padding: "3px 10px", borderRadius: "var(--radius, 6px)", border: "none", background: "var(--error)", color: "#fff", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, cursor: "pointer" }}>Reject</button>
          </div>
        </div>
      )}
      <div style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>Keyboard: A=accept · R=reject{onModify ? " · M=modify" : ""}</div>
    </div>
  );
}

export default AcceptRejectControls;
