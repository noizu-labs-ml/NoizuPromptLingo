"use client";

import React, { useState } from "react";

/**
 * AgentActivityFeed — Real-time feed of AI agent actions with status, task description, and pause controls.
 *
 * @example
 * ```tsx
 * <AgentActivityFeed entries={agentActions} showPauseControls onPauseAgent={pauseAgent} />
 * ```
 */

interface FeedEntry {
  id: string;
  agentName: string;
  agentId: string;
  action: string;
  status: "running" | "completed" | "failed" | "paused";
  timestamp: string;
  detail?: string;
}

type FeedVariant = "compact" | "expanded";

interface AgentActivityFeedProps {
  entries: FeedEntry[];
  agentFilter?: string;
  showPauseControls?: boolean;
  onPauseAgent?: (agentId: string) => void;
  onResumeAgent?: (agentId: string) => void;
  onEntryClick?: (entryId: string) => void;
  variant?: FeedVariant;
}

const statusConfig: Record<string, { color: string; icon: string }> = {
  running: { color: "var(--info, var(--blue))", icon: "⏱" },
  completed: { color: "var(--success)", icon: "✓" },
  failed: { color: "var(--error)", icon: "✗" },
  paused: { color: "var(--warning)", icon: "⏸" },
};

export function AgentActivityFeed({ entries, agentFilter, showPauseControls = false, onPauseAgent, onResumeAgent, onEntryClick, variant = "expanded" }: AgentActivityFeedProps) {
  const [collapsed, setCollapsed] = useState(variant === "compact");
  const [filter, setFilter] = useState(agentFilter ?? "");

  const filtered = filter ? entries.filter((e) => e.agentId === filter) : entries;
  const displayed = collapsed ? filtered.slice(0, 1) : filtered;
  const agents = Array.from(new Set(entries.map((e) => JSON.stringify({ id: e.agentId, name: e.agentName })))).map((s) => JSON.parse(s));

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", overflow: "hidden" }}>
      {/* Header */}
      <div style={{ display: "flex", alignItems: "center", gap: "6px", padding: "var(--space-2) var(--space-3)", borderBottom: "1px solid var(--border)", background: "color-mix(in srgb, var(--text-muted) 4%, transparent)" }}>
        <span style={{ fontSize: "var(--font-size-sm)" }}>⬢</span>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.06em", color: "var(--text-muted)", flex: 1 }}>Agent Activity</span>
        {/* Agent filter */}
        {agents.length > 1 && (
          <select value={filter} onChange={(e) => setFilter(e.target.value)} style={{ padding: "2px 6px", borderRadius: 4, border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)" }}>
            <option value="">All agents</option>
            {agents.map((a: { id: string; name: string }) => <option key={a.id} value={a.id}>{a.name}</option>)}
          </select>
        )}
        <button type="button" onClick={() => setCollapsed(!collapsed)} style={{ background: "none", border: "none", color: "var(--text-muted)", cursor: "pointer", fontSize: "var(--font-size-xs)" }}>
          {collapsed ? "▾ Expand" : "▴ Collapse"}
        </button>
      </div>

      {/* Entries */}
      <div style={{ maxHeight: collapsed ? 60 : 400, overflow: "auto" }}>
        {displayed.length === 0 && <div style={{ padding: "var(--space-3)", textAlign: "center", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontStyle: "italic" }}>No activity</div>}
        {displayed.map((entry) => {
          const sc = statusConfig[entry.status] ?? statusConfig.running;
          return (
            <div key={entry.id} onClick={() => onEntryClick?.(entry.id)} style={{ display: "flex", alignItems: "flex-start", gap: "8px", padding: "6px var(--space-3)", borderBottom: "1px solid color-mix(in srgb, var(--border) 50%, transparent)", cursor: onEntryClick ? "pointer" : "default" }}>
              {/* Agent avatar */}
              <span style={{ width: 20, height: 20, borderRadius: "20%", background: "var(--violet, #7C3AED)", color: "#fff", fontSize: "8px", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, marginTop: 1 }}>⬢</span>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: "flex", alignItems: "center", gap: "4px" }}>
                  <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 600, color: "var(--text)" }}>{entry.agentName}</span>
                  <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)" }}>{entry.action}</span>
                </div>
                {entry.detail && !collapsed && (
                  <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", display: "block", marginTop: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{entry.detail}</span>
                )}
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: "4px", flexShrink: 0 }}>
                <span style={{ color: sc.color, fontSize: "var(--font-size-xs)" }} title={entry.status}>{sc.icon}</span>
                <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>{entry.timestamp}</span>
              </div>
              {showPauseControls && entry.status === "running" && onPauseAgent && (
                <button type="button" onClick={(e) => { e.stopPropagation(); onPauseAgent(entry.agentId); }} title="Pause agent" style={{ background: "none", border: "none", color: "var(--warning)", cursor: "pointer", fontSize: "var(--font-size-xs)", padding: "0 2px", flexShrink: 0 }}>⏸</button>
              )}
              {showPauseControls && entry.status === "paused" && onResumeAgent && (
                <button type="button" onClick={(e) => { e.stopPropagation(); onResumeAgent(entry.agentId); }} title="Resume agent" style={{ background: "none", border: "none", color: "var(--success)", cursor: "pointer", fontSize: "var(--font-size-xs)", padding: "0 2px", flexShrink: 0 }}>▶</button>
              )}
            </div>
          );
        })}
      </div>

      {collapsed && filtered.length > 1 && (
        <div style={{ padding: "2px var(--space-3)", textAlign: "center" }}>
          <button type="button" onClick={() => setCollapsed(false)} style={{ background: "none", border: "none", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", cursor: "pointer", textDecoration: "underline" }}>
            +{filtered.length - 1} more entries
          </button>
        </div>
      )}
    </div>
  );
}

export default AgentActivityFeed;
