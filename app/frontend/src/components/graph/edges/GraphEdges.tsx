"use client";

import React, { memo } from "react";
import { BaseEdge, getStraightPath, getBezierPath, type EdgeProps } from "@xyflow/react";

/**
 * Custom edge components for all 6 edge types from Priya's spec (§4).
 *
 * - AssignmentEdge: Story → Role (solid 1.5px, gray→blue→green)
 * - BreakdownEdge: Role → Subtask (solid 1px, thin chevron)
 * - StoryDepEdge: Story → Story (thick 2.5px, blocking/resolved states)
 * - CrossRoleDepEdge: Subtask → Subtask (solid 1.5px, lateral)
 * - ForkBranchEdge: Fork → Branch entry (violet fan-out)
 * - BranchMergeEdge: Branch → Merge (solid winner / dashed loser)
 */

// ── Assignment Edge ─────────────────────────────────────────────

function AssignmentEdgeInner(props: EdgeProps) {
  const { sourceX, sourceY, targetX, targetY, style, markerEnd, data } = props;
  const [path] = getStraightPath({ sourceX, sourceY, targetX, targetY });

  return (
    <BaseEdge
      path={path}
      markerEnd={markerEnd}
      style={{
        stroke: "var(--graph-edge-color, var(--gray-300))",
        strokeWidth: 1.5,
        ...style,
      }}
    />
  );
}

// ── Breakdown Edge ──────────────────────────────────────────────

function BreakdownEdgeInner(props: EdgeProps) {
  const { sourceX, sourceY, targetX, targetY, style, markerEnd } = props;
  const [path] = getStraightPath({ sourceX, sourceY, targetX, targetY });

  return (
    <BaseEdge
      path={path}
      markerEnd={markerEnd}
      style={{
        stroke: "var(--graph-edge-color, var(--gray-300))",
        strokeWidth: 1,
        ...style,
      }}
    />
  );
}

// ── Story Dependency Edge ───────────────────────────────────────

function StoryDepEdgeInner(props: EdgeProps) {
  const { sourceX, sourceY, targetX, targetY, style, markerEnd, data } = props;
  const [path, labelX, labelY] = getBezierPath({ sourceX, sourceY, targetX, targetY });

  const health = (data as any)?.health ?? "active";
  const edgeColor = health === "blocked" ? "var(--error)" : health === "resolved" ? "var(--success)" : "var(--blue)";
  const dashArray = health === "blocked" ? "8 4" : undefined;

  return (
    <>
      <BaseEdge
        path={path}
        markerEnd={markerEnd}
        style={{
          stroke: edgeColor,
          strokeWidth: 2.5,
          strokeDasharray: dashArray,
          opacity: health === "resolved" ? 0.4 : 0.8,
          ...style,
        }}
      />
      {/* Label */}
      <text x={labelX} y={labelY} textAnchor="middle" dominantBaseline="central" style={{ fontFamily: "var(--font-mono)", fontSize: 9, fill: "var(--text-muted)" }}>
        blocks
      </text>
    </>
  );
}

// ── Cross-Role Dependency Edge ──────────────────────────────────

function CrossRoleDepEdgeInner(props: EdgeProps) {
  const { sourceX, sourceY, targetX, targetY, style, markerEnd, data } = props;
  const [path] = getBezierPath({ sourceX, sourceY, targetX, targetY });
  const health = (data as any)?.health ?? "active";
  const edgeColor = health === "blocked" ? "var(--error)" : "var(--blue)";

  return (
    <BaseEdge
      path={path}
      markerEnd={markerEnd}
      style={{
        stroke: edgeColor,
        strokeWidth: 1.5,
        opacity: 0.6,
        ...style,
      }}
    />
  );
}

// ── Fork-Branch Edge ────────────────────────────────────────────

function ForkBranchEdgeInner(props: EdgeProps) {
  const { sourceX, sourceY, targetX, targetY, style, markerEnd } = props;
  const [path] = getBezierPath({ sourceX, sourceY, targetX, targetY });

  return (
    <BaseEdge
      path={path}
      markerEnd={markerEnd}
      style={{
        stroke: "var(--violet)",
        strokeWidth: 1.5,
        opacity: 0.5,
        ...style,
      }}
    />
  );
}

// ── Branch-Merge Edge ───────────────────────────────────────────

function BranchMergeEdgeInner(props: EdgeProps) {
  const { sourceX, sourceY, targetX, targetY, style, markerEnd, data } = props;
  const [path] = getBezierPath({ sourceX, sourceY, targetX, targetY });
  const isWinner = (data as any)?.isWinner ?? false;

  return (
    <BaseEdge
      path={path}
      markerEnd={markerEnd}
      style={{
        stroke: isWinner ? "var(--success)" : "var(--gray-300)",
        strokeWidth: 1.5,
        strokeDasharray: isWinner ? undefined : "6 3",
        opacity: isWinner ? 0.8 : 0.3,
        ...style,
      }}
    />
  );
}

// ── Exports ─────────────────────────────────────────────────────

export const AssignmentEdge = memo(AssignmentEdgeInner);
export const BreakdownEdge = memo(BreakdownEdgeInner);
export const StoryDepEdge = memo(StoryDepEdgeInner);
export const CrossRoleDepEdge = memo(CrossRoleDepEdgeInner);
export const ForkBranchEdge = memo(ForkBranchEdgeInner);
export const BranchMergeEdge = memo(BranchMergeEdgeInner);

import type { EdgeTypes } from "@xyflow/react";

/** React Flow edgeTypes registration map */
export const graphEdgeTypes: EdgeTypes = {
  assignment: AssignmentEdge,
  breakdown: BreakdownEdge,
  "story-dep": StoryDepEdge,
  "cross-role-dep": CrossRoleDepEdge,
  "fork-branch": ForkBranchEdge,
  "branch-merge": BranchMergeEdge,
};
