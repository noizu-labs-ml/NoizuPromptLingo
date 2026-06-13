"use client";

import React from "react";

/**
 * AiFailureAnalysis — Agent-generated hypothesis panel explaining failures with evidence links.
 *
 * @example
 * ```tsx
 * <AiFailureAnalysis hypothesis="OOM kill on deploy pod — memory request too low" confidence={0.82} evidence={[{ label: "Pod logs", href: "/logs/deploy-xyz" }]} suggestedAction="Increase memory to 512Mi" onAccept={accept} onDismiss={dismiss} />
 * ```
 */

interface EvidenceLink { label: string; href: string; }

interface AiFailureAnalysisProps {
  hypothesis: string;
  confidence: number;
  evidence?: EvidenceLink[];
  suggestedAction?: string;
  onAccept?: () => void;
  onDismiss?: () => void;
  onCreateAction?: (action: string) => void;
  variant?: "compact" | "expanded";
}

function confColor(c: number): string {
  if (c >= 0.8) return "var(--success)";
  if (c >= 0.5) return "var(--warning)";
  return "var(--error)";
}

export function AiFailureAnalysis({ hypothesis, confidence, evidence, suggestedAction, onAccept, onDismiss, onCreateAction, variant = "expanded" }: AiFailureAnalysisProps) {
  const cc = confColor(confidence);

  if (variant === "compact") {
    return (
      <div style={{ display: "flex", alignItems: "flex-start", gap: "8px", padding: "var(--space-2) var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "color-mix(in srgb, var(--warning) 4%, transparent)" }}>
        <span style={{ fontSize: "var(--font-size-sm)" }}>🔍</span>
        <div style={{ flex: 1 }}>
          <p style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text)", margin: 0, lineHeight: 1.4 }}>{hypothesis}</p>
          <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: cc, fontWeight: 600 }}>{Math.round(confidence * 100)}% confidence</span>
        </div>
        {onAccept && <button type="button" onClick={onAccept} style={{ background: "none", border: "none", color: "var(--success)", cursor: "pointer", fontSize: "var(--font-size-sm)" }}>✓</button>}
        {onDismiss && <button type="button" onClick={onDismiss} style={{ background: "none", border: "none", color: "var(--text-muted)", cursor: "pointer", fontSize: "var(--font-size-sm)" }}>✗</button>}
      </div>
    );
  }

  return (
    <div style={{ padding: "var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
      {/* Header */}
      <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
        <span style={{ fontSize: "var(--font-size-base)" }}>🔍</span>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.06em", color: "var(--text-muted)" }}>AI Failure Analysis</span>
        <span style={{ padding: "2px 6px", borderRadius: "999px", background: `color-mix(in srgb, ${cc} 12%, transparent)`, color: cc, fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 700, marginLeft: "auto" }}>{Math.round(confidence * 100)}%</span>
      </div>

      {/* Hypothesis */}
      <div style={{ padding: "var(--space-2)", borderRadius: 4, background: "color-mix(in srgb, var(--warning) 6%, transparent)", borderLeft: "3px solid var(--warning)" }}>
        <p style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", color: "var(--text)", margin: 0, lineHeight: 1.5 }}>{hypothesis}</p>
      </div>

      {/* Evidence links */}
      {evidence && evidence.length > 0 && (
        <div>
          <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.06em", color: "var(--text-muted)" }}>Evidence</span>
          <div style={{ display: "flex", flexWrap: "wrap", gap: "4px", marginTop: 4 }}>
            {evidence.map((e, i) => (
              <a key={i} href={e.href} style={{ display: "inline-flex", alignItems: "center", gap: "3px", padding: "2px 8px", borderRadius: "999px", background: "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)", color: "var(--info, var(--blue))", fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", textDecoration: "none" }}>
                ↗ {e.label}
              </a>
            ))}
          </div>
        </div>
      )}

      {/* Suggested action */}
      {suggestedAction && (
        <div style={{ display: "flex", alignItems: "center", gap: "8px", padding: "var(--space-1) var(--space-2)", borderRadius: 4, background: "color-mix(in srgb, var(--success) 6%, transparent)" }}>
          <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--success)", fontWeight: 600 }}>Suggested:</span>
          <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text)", flex: 1 }}>{suggestedAction}</span>
          {onCreateAction && <button type="button" onClick={() => onCreateAction(suggestedAction)} style={{ padding: "2px 8px", borderRadius: 4, border: "1px solid var(--success)", background: "none", color: "var(--success)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, cursor: "pointer" }}>Create action</button>}
        </div>
      )}

      {/* Actions */}
      <div style={{ display: "flex", gap: "6px" }}>
        {onAccept && <button type="button" onClick={onAccept} style={{ padding: "3px 12px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--success)", background: "color-mix(in srgb, var(--success) 8%, transparent)", color: "var(--success)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, cursor: "pointer" }}>✓ Accept hypothesis</button>}
        {onDismiss && <button type="button" onClick={onDismiss} style={{ padding: "3px 12px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "none", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>✗ Dismiss</button>}
      </div>
    </div>
  );
}

export default AiFailureAnalysis;
