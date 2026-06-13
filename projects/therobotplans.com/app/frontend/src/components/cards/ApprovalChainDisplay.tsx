"use client";

import React from "react";

/**
 * ApprovalChainDisplay — Ordered list of required approvers with status per person.
 *
 * @example
 * ```tsx
 * <ApprovalChainDisplay approvers={[
 *   { name: "Marcus", type: "human", status: "approved", timestamp: "14:30" },
 *   { name: "Kai", type: "human", status: "pending" },
 *   { name: "QA Agent", type: "agent", status: "pending" },
 * ]} requiredCount={2} variant="compact" />
 * ```
 */

type ApprovalStatus = "approved" | "pending" | "rejected";
type ChainVariant = "inline" | "compact" | "expanded";

interface Approver {
  name: string;
  type: "human" | "agent";
  status: ApprovalStatus;
  timestamp?: string;
  comment?: string;
}

interface ApprovalChainDisplayProps {
  approvers: Approver[];
  requiredCount?: number;
  variant?: ChainVariant;
  onApproverClick?: (index: number) => void;
}

const statusStyle: Record<ApprovalStatus, { color: string; icon: string; bg: string }> = {
  approved: { color: "var(--success)", icon: "✓", bg: "color-mix(in srgb, var(--success) 12%, transparent)" },
  pending: { color: "var(--text-muted)", icon: "○", bg: "color-mix(in srgb, var(--text-muted) 10%, transparent)" },
  rejected: { color: "var(--error)", icon: "✗", bg: "color-mix(in srgb, var(--error) 12%, transparent)" },
};

export function ApprovalChainDisplay({ approvers, requiredCount, variant = "compact", onApproverClick }: ApprovalChainDisplayProps) {
  const approvedCount = approvers.filter((a) => a.status === "approved").length;
  const gatePassed = requiredCount ? approvedCount >= requiredCount : approvers.every((a) => a.status === "approved");

  if (variant === "inline") {
    return (
      <div style={{ display: "flex", alignItems: "center", gap: 0 }} aria-label={`Approvals: ${approvedCount}/${approvers.length}`}>
        {approvers.map((a, i) => {
          const ss = statusStyle[a.status];
          return (
            <span key={i} title={`${a.name}: ${a.status}`} onClick={onApproverClick ? () => onApproverClick(i) : undefined} style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", width: 24, height: 24, borderRadius: a.type === "agent" ? "20%" : "50%", background: ss.bg, border: `2px solid var(--bg)`, marginLeft: i > 0 ? -6 : 0, cursor: onApproverClick ? "pointer" : "default", zIndex: approvers.length - i, position: "relative", fontSize: "10px", color: ss.color, fontWeight: 700 }}>
              {ss.icon}
            </span>
          );
        })}
        {requiredCount && (
          <span style={{ marginLeft: 8, fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: gatePassed ? "var(--success)" : "var(--text-muted)" }}>
            {approvedCount}/{requiredCount}
          </span>
        )}
      </div>
    );
  }

  if (variant === "compact") {
    return (
      <div style={{ display: "flex", flexDirection: "column", gap: "4px" }} aria-label="Approval chain">
        {approvers.map((a, i) => {
          const ss = statusStyle[a.status];
          return (
            <div key={i} onClick={onApproverClick ? () => onApproverClick(i) : undefined} style={{ display: "flex", alignItems: "center", gap: "8px", padding: "2px 0", cursor: onApproverClick ? "pointer" : "default" }}>
              <span style={{ width: 16, height: 16, borderRadius: a.type === "agent" ? "20%" : "50%", background: ss.bg, display: "flex", alignItems: "center", justifyContent: "center", fontSize: "9px", color: ss.color, fontWeight: 700, flexShrink: 0 }}>{ss.icon}</span>
              <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text)", flex: 1 }}>{a.name}</span>
              <span style={{ padding: "1px 6px", borderRadius: "999px", background: ss.bg, color: ss.color, fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 500 }}>{a.status}</span>
            </div>
          );
        })}
        {requiredCount && (
          <div style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: gatePassed ? "var(--success)" : "var(--text-muted)", fontWeight: 600, paddingTop: "2px" }}>
            {gatePassed ? "✓ Gate passed" : `${approvedCount}/${requiredCount} required`}
          </div>
        )}
      </div>
    );
  }

  // expanded — with timestamps/comments
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "6px" }} aria-label="Approval chain">
      {approvers.map((a, i) => {
        const ss = statusStyle[a.status];
        return (
          <div key={i} onClick={onApproverClick ? () => onApproverClick(i) : undefined} style={{ padding: "var(--space-2) var(--space-3)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", cursor: onApproverClick ? "pointer" : "default", display: "flex", flexDirection: "column", gap: "4px" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
              <span style={{ width: 20, height: 20, borderRadius: a.type === "agent" ? "20%" : "50%", background: ss.bg, display: "flex", alignItems: "center", justifyContent: "center", fontSize: "10px", color: ss.color, fontWeight: 700, flexShrink: 0 }}>{ss.icon}</span>
              <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontWeight: 500, color: "var(--text)", flex: 1 }}>{a.name}</span>
              {a.type === "agent" && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--violet, #7C3AED)" }}>⬢ agent</span>}
              <span style={{ padding: "1px 6px", borderRadius: "999px", background: ss.bg, color: ss.color, fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600 }}>{a.status}</span>
            </div>
            {(a.timestamp || a.comment) && (
              <div style={{ paddingLeft: 28, display: "flex", flexDirection: "column", gap: "2px" }}>
                {a.timestamp && <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{a.timestamp}</span>}
                {a.comment && <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)", fontStyle: "italic" }}>"{a.comment}"</span>}
              </div>
            )}
          </div>
        );
      })}
      {requiredCount && (
        <div style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 600, color: gatePassed ? "var(--success)" : "var(--text-muted)", padding: "var(--space-1) 0" }}>
          {gatePassed ? "✓ Gate passed — all required approvals received" : `${approvedCount}/${requiredCount} approvals received`}
        </div>
      )}
    </div>
  );
}

export default ApprovalChainDisplay;
