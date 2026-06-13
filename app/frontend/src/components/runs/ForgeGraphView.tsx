"use client";
import * as React from "react";
import {
  GraphCanvas,
  computeActivePathEdges,
  computePathOrder,
} from "@/components/scripts/GraphCanvas";
import type { RunVerdict, ScriptEdge, ScriptNode } from "@/lib/api";

export interface ForgeGraphViewProps {
  nodes: ScriptNode[];
  edges: ScriptEdge[];
  /** node_id → verdict for that step's eval result. */
  verdictByNode: Record<string, RunVerdict | null>;
  /** Currently selected node (drives active path + opens drill-down). */
  selectedNodeId?: string | null;
  onSelectNode?: (node: ScriptNode) => void;
  /** When true, skip the dark-flash and stagger. */
  reducedMotion: boolean;
  /** When false, render final state immediately (no sequence). */
  animate: boolean;
}

/**
 * Renders the script graph with node verdicts and plays the Forge sequence
 * once on mount when `animate` is true.
 *
 * Sequence:
 *   1. All nodes flash `--bg-well` for 100 ms (`sg-graph-node--flashing`)
 *   2. In path order, apply eval state with 60 ms stagger
 *
 * `prefers-reduced-motion` skips step 1 and the stagger — nodes appear in
 * their final state immediately.
 */
export function ForgeGraphView({
  nodes,
  edges,
  verdictByNode,
  selectedNodeId,
  onSelectNode,
  reducedMotion,
  animate,
}: ForgeGraphViewProps) {
  const [flashingIds, setFlashingIds] = React.useState<Set<string>>(
    () => new Set(),
  );
  const [litIds, setLitIds] = React.useState<Set<string>>(() => new Set());
  const [forgedIds, setForgedIds] = React.useState<Set<string>>(() => new Set());

  const pathOrder = React.useMemo(
    () => computePathOrder(nodes, edges),
    [nodes, edges],
  );
  const activePathEdgeIds = React.useMemo(
    () => computeActivePathEdges(nodes, edges, selectedNodeId),
    [nodes, edges, selectedNodeId],
  );

  // Visible verdicts — controlled by the sequence. Before a node is "lit",
  // we hide its verdict so the forge effect is visible.
  const visibleVerdicts: Record<string, RunVerdict | null> = React.useMemo(() => {
    const out: Record<string, RunVerdict | null> = {};
    for (const n of nodes) {
      out[n.id] = litIds.has(n.id) ? verdictByNode[n.id] ?? null : null;
    }
    return out;
  }, [nodes, litIds, verdictByNode]);

  React.useEffect(() => {
    if (!animate || nodes.length === 0) {
      // No sequence — reveal all at once.
      setFlashingIds(new Set());
      setLitIds(new Set(nodes.map((n) => n.id)));
      setForgedIds(new Set(nodes.map((n) => n.id)));
      return;
    }

    if (reducedMotion) {
      setFlashingIds(new Set());
      setLitIds(new Set(nodes.map((n) => n.id)));
      setForgedIds(new Set(nodes.map((n) => n.id)));
      return;
    }

    // Full sequence.
    const timers: number[] = [];
    // Step 1 — flash all.
    setFlashingIds(new Set(nodes.map((n) => n.id)));
    setLitIds(new Set());
    setForgedIds(new Set());
    timers.push(
      window.setTimeout(() => {
        setFlashingIds(new Set());
      }, 100),
    );

    // Step 2 — illuminate in path order with 60 ms stagger starting at 100 ms.
    pathOrder.forEach((id, idx) => {
      timers.push(
        window.setTimeout(
          () => {
            setLitIds((prev) => {
              const next = new Set(prev);
              next.add(id);
              return next;
            });
            setForgedIds((prev) => {
              const next = new Set(prev);
              next.add(id);
              return next;
            });
          },
          100 + idx * 60,
        ),
      );
    });

    return () => {
      for (const t of timers) window.clearTimeout(t);
    };
    // Only (re)run when the identity of the graph changes.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [animate, reducedMotion, nodes.length, edges.length]);

  return (
    <GraphCanvas
      nodes={nodes}
      edges={edges}
      selectedNodeId={selectedNodeId}
      nodeVerdicts={visibleVerdicts}
      flashingIds={flashingIds}
      forgedIds={forgedIds}
      activePathEdgeIds={activePathEdgeIds}
      readOnly
      onSelectNode={onSelectNode}
    />
  );
}
