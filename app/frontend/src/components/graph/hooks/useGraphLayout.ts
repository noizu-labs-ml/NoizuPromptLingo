"use client";

import { useMemo } from "react";
import type { Node, Edge } from "@xyflow/react";
import type { GraphNode, GraphEdge, LayoutMode } from "../ProjectGraph.types";

/**
 * useGraphLayout — Computes positioned nodes + edges from raw graph data
 * using the selected layout algorithm. (Architecture §6)
 *
 * Layout engines (dagre / elkjs) are loaded lazily via dynamic import so the
 * bundle only pays for what's used. During SSR or before the layout resolves,
 * nodes are returned with fallback grid positions.
 *
 * React Flow expects `Node<T>` objects with { id, type, position, data }.
 * This hook bridges our domain `GraphNode[]` → React Flow `Node[]`.
 */

// ── Defaults ────────────────────────────────────────────────────

const NODE_WIDTH: Record<string, number> = {
  story: 260,
  role: 180,
  subtask: 160,
  milestone: 60,
  fork: 200,
  merge: 200,
};
const NODE_HEIGHT: Record<string, number> = {
  story: 80,
  role: 110,
  subtask: 36,
  milestone: 80,
  fork: 100,
  merge: 90,
};

const DEFAULT_RANK_SEP = 100;
const DEFAULT_NODE_SEP = 20;

// ── Fallback grid layout (used before async layout resolves) ────

function gridLayout(nodes: GraphNode[]): Node[] {
  const cols = Math.max(1, Math.ceil(Math.sqrt(nodes.length)));
  return nodes.map((n, i) => ({
    id: n.id,
    type: n.type,
    position: n.position ?? {
      x: (i % cols) * 300,
      y: Math.floor(i / cols) * 160,
    },
    data: n.data as Record<string, unknown>,
  }));
}

// ── Dagre layout ────────────────────────────────────────────────

async function computeDagre(
  nodes: GraphNode[],
  edges: GraphEdge[],
  direction: "TB" | "LR",
): Promise<Node[]> {
  // Dynamic import — dagre is only needed when this layout is active
  const dagre = await import("dagre");
  const g = new dagre.graphlib.Graph();
  g.setDefaultEdgeLabel(() => ({}));
  g.setGraph({
    rankdir: direction,
    ranksep: DEFAULT_RANK_SEP,
    nodesep: DEFAULT_NODE_SEP,
    marginx: 24,
    marginy: 24,
  });

  for (const n of nodes) {
    g.setNode(n.id, {
      width: NODE_WIDTH[n.type] ?? 180,
      height: NODE_HEIGHT[n.type] ?? 60,
    });
  }
  for (const e of edges) {
    g.setEdge(e.source, e.target);
  }

  dagre.layout(g);

  return nodes.map((n) => {
    const pos = g.node(n.id);
    const w = NODE_WIDTH[n.type] ?? 180;
    const h = NODE_HEIGHT[n.type] ?? 60;
    return {
      id: n.id,
      type: n.type,
      position: {
        x: (pos?.x ?? 0) - w / 2,
        y: (pos?.y ?? 0) - h / 2,
      },
      data: n.data as Record<string, unknown>,
    };
  });
}

// ── Force layout (simple spring simulation) ─────────────────────

function computeForce(nodes: GraphNode[]): Node[] {
  // Minimal force — places connected clusters in a radial pattern.
  // A full d3-force simulation would be wired here in production.
  const angleStep = (2 * Math.PI) / Math.max(1, nodes.length);
  const radius = Math.max(200, nodes.length * 20);

  return nodes.map((n, i) => ({
    id: n.id,
    type: n.type,
    position: n.position ?? {
      x: Math.cos(i * angleStep) * radius + radius,
      y: Math.sin(i * angleStep) * radius + radius,
    },
    data: n.data as Record<string, unknown>,
  }));
}

// ── Radial layout ───────────────────────────────────────────────

function computeRadial(nodes: GraphNode[]): Node[] {
  // Layer by type: milestones center, stories ring 1, roles ring 2, subtasks ring 3
  const layers: Record<string, number> = {
    milestone: 0,
    story: 1,
    fork: 1,
    role: 2,
    merge: 2,
    subtask: 3,
  };

  const rings: Record<number, GraphNode[]> = {};
  for (const n of nodes) {
    const layer = layers[n.type] ?? 2;
    (rings[layer] ??= []).push(n);
  }

  const ringRadii = [0, 160, 300, 440];
  const result: Node[] = [];

  for (const [layerStr, ringNodes] of Object.entries(rings)) {
    const layer = Number(layerStr);
    const r = ringRadii[layer] ?? 300;
    const angleStep = (2 * Math.PI) / Math.max(1, ringNodes.length);
    const centerX = 500;
    const centerY = 500;

    for (let i = 0; i < ringNodes.length; i++) {
      const n = ringNodes[i];
      result.push({
        id: n.id,
        type: n.type,
        position: n.position ?? {
          x: centerX + Math.cos(i * angleStep) * r - (NODE_WIDTH[n.type] ?? 180) / 2,
          y: centerY + Math.sin(i * angleStep) * r - (NODE_HEIGHT[n.type] ?? 60) / 2,
        },
        data: n.data as Record<string, unknown>,
      });
    }
  }

  return result;
}

// ── Edge mapping ────────────────────────────────────────────────

function mapEdges(edges: GraphEdge[]): Edge[] {
  return edges.map((e) => ({
    id: e.id,
    source: e.source,
    target: e.target,
    type: e.type,
    animated: e.animated,
    data: e.data as Record<string, unknown>,
  }));
}

// ── Hook ────────────────────────────────────────────────────────

export interface LayoutResult {
  layoutNodes: Node[];
  layoutEdges: Edge[];
  isLayoutReady: boolean;
}

export function useGraphLayout(
  nodes: GraphNode[],
  edges: GraphEdge[],
  layout: LayoutMode,
): LayoutResult {
  // Synchronous layouts (force, radial, grid-fallback)
  const syncNodes = useMemo(() => {
    switch (layout) {
      case "force":
        return computeForce(nodes);
      case "radial":
        return computeRadial(nodes);
      default:
        return gridLayout(nodes);
    }
  }, [nodes, layout]);

  const layoutEdges = useMemo(() => mapEdges(edges), [edges]);

  // For dagre layouts, we'd use useEffect + state to resolve the async import.
  // In this scaffold, we return the sync fallback and flag that dagre layouts
  // will need the async path wired via useEffect in production.
  const isDagreLayout = layout === "ltr" || layout === "top-down";

  // For MVP, dagre falls back to grid. Production wires useEffect + state.
  // The important thing is the hook signature is stable.
  return {
    layoutNodes: isDagreLayout ? gridLayout(nodes) : syncNodes,
    layoutEdges,
    isLayoutReady: !isDagreLayout,
  };
}

export default useGraphLayout;
