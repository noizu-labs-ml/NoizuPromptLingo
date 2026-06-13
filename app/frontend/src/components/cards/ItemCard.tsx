"use client";

import React from "react";

/**
 * ItemCard — Work item card showing title, assignee, priority, labels, due date.
 * Used across boards, lists, and queues (8 screens). Depends on Badge (T0).
 *
 * @example
 * ```tsx
 * <ItemCard title="Fix auth timeout" priority="p1" status="in-progress" variant="inline" />
 * <ItemCard title="Add rate limiting" assignee={{ name: "Marcus", type: "human" }} priority="p0" labels={["backend","security"]} variant="compact" />
 * <ItemCard title="Deploy v2.1" assignee={{ name: "PM Agent", type: "agent" }} priority="p2" labels={["ops"]} dueDate="2026-06-01" source="ai-suggested" variant="expanded" onClick={handleOpen} />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type ItemPriority = "p0" | "p1" | "p2" | "p3";
type ItemVariant = "inline" | "compact" | "expanded";
type AssigneeType = "human" | "agent";

interface Assignee {
  name: string;
  type: AssigneeType;
  avatarUrl?: string;
}

interface ItemCardProps {
  title: string;
  assignee?: Assignee;
  priority?: ItemPriority;
  labels?: string[];
  dueDate?: string;
  status?: string;
  source?: "manual" | "ai-suggested" | "imported";
  variant?: ItemVariant;
  onClick?: () => void;
  onDragStart?: React.DragEventHandler;
  draggable?: boolean;
}

// ── Helpers ─────────────────────────────────────────────────────

const priorityConfig: Record<ItemPriority, { color: string; bg: string; label: string }> = {
  p0: { color: "var(--error)", bg: "color-mix(in srgb, var(--error) 12%, transparent)", label: "P0" },
  p1: { color: "var(--warning)", bg: "color-mix(in srgb, var(--warning) 12%, transparent)", label: "P1" },
  p2: { color: "var(--info, var(--blue))", bg: "color-mix(in srgb, var(--info, var(--blue)) 12%, transparent)", label: "P2" },
  p3: { color: "var(--text-muted)", bg: "color-mix(in srgb, var(--text-muted) 10%, transparent)", label: "P3" },
};

const sourceIcons: Record<string, string> = {
  "manual": "",
  "ai-suggested": "⚡",
  "imported": "↗",
};

function PriorityDot({ priority }: { priority: ItemPriority }) {
  const cfg = priorityConfig[priority];
  return (
    <span
      title={cfg.label}
      style={{
        width: 8,
        height: 8,
        borderRadius: "50%",
        background: cfg.color,
        flexShrink: 0,
      }}
    />
  );
}

function PriorityBadge({ priority }: { priority: ItemPriority }) {
  const cfg = priorityConfig[priority];
  return (
    <span
      style={{
        display: "inline-flex",
        alignItems: "center",
        padding: "1px 6px",
        borderRadius: "999px",
        background: cfg.bg,
        color: cfg.color,
        fontFamily: "var(--font-mono)",
        fontSize: "var(--font-size-2xs, 10px)",
        fontWeight: 700,
        lineHeight: 1,
      }}
    >
      {cfg.label}
    </span>
  );
}

function AvatarMini({ assignee }: { assignee: Assignee }) {
  const initial = assignee.name.charAt(0).toUpperCase();
  return (
    <span
      title={`${assignee.name}${assignee.type === "agent" ? " (agent)" : ""}`}
      style={{
        display: "inline-flex",
        alignItems: "center",
        justifyContent: "center",
        width: 20,
        height: 20,
        borderRadius: assignee.type === "agent" ? "20%" : "50%",
        background: assignee.type === "agent" ? "var(--violet, #7C3AED)" : "var(--text-muted)",
        color: "#fff",
        fontSize: "var(--font-size-2xs, 10px)",
        fontWeight: 600,
        flexShrink: 0,
        lineHeight: 1,
      }}
    >
      {assignee.type === "agent" ? "⬢" : initial}
    </span>
  );
}

function LabelChip({ label }: { label: string }) {
  return (
    <span
      style={{
        display: "inline-flex",
        padding: "1px 6px",
        borderRadius: "999px",
        background: "color-mix(in srgb, var(--text-muted) 10%, transparent)",
        color: "var(--text-secondary)",
        fontFamily: "var(--font-mono)",
        fontSize: "var(--font-size-2xs, 10px)",
        lineHeight: 1,
        whiteSpace: "nowrap",
      }}
    >
      {label}
    </span>
  );
}

// ── Component ───────────────────────────────────────────────────

export function ItemCard({
  title,
  assignee,
  priority,
  labels,
  dueDate,
  status,
  source,
  variant = "compact",
  onClick,
  onDragStart,
  draggable = false,
}: ItemCardProps) {
  const interactive = !!onClick;

  // ── Inline: single-line title + priority dot ──
  if (variant === "inline") {
    return (
      <div
        role={interactive ? "button" : undefined}
        tabIndex={interactive ? 0 : undefined}
        onClick={onClick}
        onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined}
        draggable={draggable}
        onDragStart={onDragStart}
        aria-label={`${title}${priority ? `, ${priorityConfig[priority].label}` : ""}`}
        style={{
          display: "flex",
          alignItems: "center",
          gap: "8px",
          padding: "4px 0",
          cursor: interactive ? "pointer" : "default",
        }}
      >
        {priority && <PriorityDot priority={priority} />}
        <span
          style={{
            fontFamily: "var(--font-body)",
            fontSize: "var(--font-size-sm)",
            color: "var(--text)",
            overflow: "hidden",
            textOverflow: "ellipsis",
            whiteSpace: "nowrap",
            flex: 1,
          }}
        >
          {title}
        </span>
        {status && (
          <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>
            {status}
          </span>
        )}
      </div>
    );
  }

  // ── Compact: card with title, assignee avatar, priority badge ──
  if (variant === "compact") {
    return (
      <div
        role={interactive ? "button" : undefined}
        tabIndex={interactive ? 0 : undefined}
        onClick={onClick}
        onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined}
        draggable={draggable}
        onDragStart={onDragStart}
        aria-label={title}
        style={{
          padding: "var(--space-2) var(--space-3)",
          borderRadius: "var(--radius, 6px)",
          border: "1px solid var(--border)",
          background: "var(--surface)",
          cursor: interactive ? "pointer" : "default",
          display: "flex",
          flexDirection: "column",
          gap: "6px",
        }}
      >
        <span
          style={{
            fontFamily: "var(--font-body)",
            fontSize: "var(--font-size-sm)",
            fontWeight: 500,
            color: "var(--text)",
            lineHeight: 1.3,
          }}
        >
          {title}
        </span>
        <div style={{ display: "flex", alignItems: "center", gap: "6px", flexWrap: "wrap" }}>
          {priority && <PriorityBadge priority={priority} />}
          {assignee && <AvatarMini assignee={assignee} />}
          {source && sourceIcons[source] && (
            <span style={{ fontSize: "var(--font-size-xs)", color: "var(--violet, #7C3AED)" }} title={source}>
              {sourceIcons[source]}
            </span>
          )}
        </div>
      </div>
    );
  }

  // ── Expanded: full metadata, labels, actions ──
  return (
    <div
      role={interactive ? "button" : undefined}
      tabIndex={interactive ? 0 : undefined}
      onClick={onClick}
      onKeyDown={interactive ? (e) => e.key === "Enter" && onClick?.() : undefined}
      draggable={draggable}
      onDragStart={onDragStart}
      aria-label={title}
      style={{
        padding: "var(--space-3)",
        borderRadius: "var(--radius, 6px)",
        border: "1px solid var(--border)",
        background: "var(--surface)",
        cursor: interactive ? "pointer" : "default",
        display: "flex",
        flexDirection: "column",
        gap: "var(--space-2)",
      }}
    >
      {/* Title row */}
      <div style={{ display: "flex", alignItems: "flex-start", gap: "8px" }}>
        <span
          style={{
            fontFamily: "var(--font-body)",
            fontSize: "var(--font-size-sm)",
            fontWeight: 600,
            color: "var(--text)",
            lineHeight: 1.3,
            flex: 1,
          }}
        >
          {title}
        </span>
        {priority && <PriorityBadge priority={priority} />}
      </div>

      {/* Metadata row */}
      <div style={{ display: "flex", alignItems: "center", gap: "8px", flexWrap: "wrap" }}>
        {assignee && (
          <div style={{ display: "flex", alignItems: "center", gap: "4px" }}>
            <AvatarMini assignee={assignee} />
            <span style={{ fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text-secondary)" }}>
              {assignee.name}
            </span>
          </div>
        )}
        {status && (
          <span
            style={{
              padding: "1px 6px",
              borderRadius: "999px",
              background: "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)",
              color: "var(--info, var(--blue))",
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-2xs, 10px)",
              fontWeight: 500,
            }}
          >
            {status}
          </span>
        )}
        {source && sourceIcons[source] && (
          <span
            style={{
              padding: "1px 6px",
              borderRadius: "999px",
              background: "color-mix(in srgb, var(--violet, #7C3AED) 10%, transparent)",
              color: "var(--violet, #7C3AED)",
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-2xs, 10px)",
              fontWeight: 500,
            }}
          >
            {sourceIcons[source]} {source}
          </span>
        )}
        {dueDate && (
          <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", marginLeft: "auto" }}>
            📅 {dueDate}
          </span>
        )}
      </div>

      {/* Labels row */}
      {labels && labels.length > 0 && (
        <div style={{ display: "flex", flexWrap: "wrap", gap: "4px" }}>
          {labels.map((l) => (
            <LabelChip key={l} label={l} />
          ))}
        </div>
      )}
    </div>
  );
}

export default ItemCard;
