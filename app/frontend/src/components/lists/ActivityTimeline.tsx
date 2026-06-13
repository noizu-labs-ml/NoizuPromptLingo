"use client";

import React, { useState } from "react";

/**
 * ActivityTimeline — Chronological feed of events/actions with expandable entries and actor attribution.
 *
 * @example
 * ```tsx
 * <ActivityTimeline entries={[{ id: "1", actor: "Marcus", actorType: "human", action: "deployed v2.1", timestamp: "14:30", detail: "Helm chart updated" }]} />
 * ```
 */

interface TimelineEntry { id: string; actor: string; actorType?: "human" | "agent" | "system"; action: string; timestamp: string; detail?: string; type?: string; }
type TimelineVariant = "inline" | "compact" | "expanded";

interface ActivityTimelineProps {
  entries: TimelineEntry[];
  variant?: TimelineVariant;
  expandable?: boolean;
  showActorAvatar?: boolean;
  groupByDate?: boolean;
}

const typeIcons: Record<string, string> = { deploy: "🚀", update: "✏", create: "⊕", delete: "✗", comment: "💬", review: "👁", agent: "⬢" };

export function ActivityTimeline({ entries, variant = "compact", expandable = true, showActorAvatar = true }: ActivityTimelineProps) {
  const [expandedIds, setExpandedIds] = useState<Set<string>>(new Set());
  const toggle = (id: string) => setExpandedIds((s) => { const n = new Set(s); n.has(id) ? n.delete(id) : n.add(id); return n; });

  if (entries.length === 0) return <span style={{ padding: "var(--space-4)", display: "block", textAlign: "center", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", fontStyle: "italic" }}>No activity</span>;

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 0, position: "relative", paddingLeft: variant === "inline" ? 0 : 20 }}>
      {/* Timeline line */}
      {variant !== "inline" && <div style={{ position: "absolute", left: 8, top: 8, bottom: 8, width: 2, background: "var(--border)" }} />}

      {entries.map((entry) => {
        const isExpanded = expandedIds.has(entry.id);
        const icon = typeIcons[entry.type ?? ""] ?? "●";

        if (variant === "inline") {
          return (
            <div key={entry.id} style={{ display: "flex", gap: "6px", padding: "2px 0", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)" }}>
              <span style={{ color: "var(--text-muted)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", width: 36, flexShrink: 0 }}>{entry.timestamp}</span>
              <span style={{ color: "var(--text-secondary)" }}><strong>{entry.actor}</strong> {entry.action}</span>
            </div>
          );
        }

        return (
          <div key={entry.id} style={{ display: "flex", gap: "10px", padding: "6px 0", position: "relative" }}>
            {/* Dot */}
            <div style={{ position: "absolute", left: -16, top: 10, width: 10, height: 10, borderRadius: "50%", background: "var(--surface)", border: "2px solid var(--border)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "6px", zIndex: 1 }}>
              <span style={{ fontSize: "6px" }}>{icon}</span>
            </div>

            <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: "2px" }}>
              <div onClick={expandable && entry.detail ? () => toggle(entry.id) : undefined} style={{ display: "flex", alignItems: "center", gap: "6px", cursor: expandable && entry.detail ? "pointer" : "default" }}>
                {showActorAvatar && (
                  <span style={{ width: 18, height: 18, borderRadius: entry.actorType === "agent" ? "20%" : "50%", background: entry.actorType === "agent" ? "var(--violet, #7C3AED)" : "var(--text-muted)", color: "#fff", fontSize: "8px", display: "inline-flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                    {entry.actorType === "agent" ? "⬢" : entry.actor.charAt(0).toUpperCase()}
                  </span>
                )}
                <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text)" }}><strong>{entry.actor}</strong> {entry.action}</span>
                <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", marginLeft: "auto", flexShrink: 0 }}>{entry.timestamp}</span>
              </div>
              {isExpanded && entry.detail && (
                <div style={{ padding: "4px 8px", marginLeft: showActorAvatar ? 24 : 0, borderRadius: 4, background: "color-mix(in srgb, var(--text-muted) 6%, transparent)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)", lineHeight: 1.4 }}>{entry.detail}</div>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}

export default ActivityTimeline;
