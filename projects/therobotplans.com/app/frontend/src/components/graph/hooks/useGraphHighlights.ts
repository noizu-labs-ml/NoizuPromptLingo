"use client";

import { useMemo } from "react";
import type { GraphNode, GraphEdge } from "../ProjectGraph.types";

/**
 * useGraphHighlights — Detects critical paths and blocked chains
 * for visual emphasis in the graph. (Architecture §5, Spec §4.3-4.4)
 *
 * - Critical path: the longest chain of story-dep edges (blocking=true)
 * - Blocked chains: nodes reachable from any blocked node via outgoing deps
 */

export interface HighlightResult {
  /** Edge IDs on the critical path */
  criticalPathEdgeIds: Set<string>;
  /** Node IDs in blocked chains */
  blockedChainNodeIds: Set<string>;
  /** Edge IDs in blocked chains */
  blockedChainEdgeIds: Set<string>;
}

export function useGraphHighlights(
  nodes: GraphNode[],
  edges: GraphEdge[],
  options?: { highlightCriticalPath?: boolean; highlightBlockedPaths?: boolean },
): HighlightResult {
  return useMemo(() => {
    const result: HighlightResult = {
      criticalPathEdgeIds: new Set(),
      blockedChainNodeIds: new Set(),
      blockedChainEdgeIds: new Set(),
    };

    if (!options?.highlightCriticalPath && !options?.highlightBlockedPaths) {
      return result;
    }

    // Build adjacency list (source → [{ edge, target }])
    const adj = new Map<string, { edge: GraphEdge; target: string }[]>();
    for (const e of edges) {
      if (!adj.has(e.source)) adj.set(e.source, []);
      adj.get(e.source)!.push({ edge: e, target: e.target });
    }

    // ── Blocked chain detection ──────────────────────────────────
    if (options?.highlightBlockedPaths) {
      const blockedNodeIds = new Set(
        nodes
          .filter((n) => {
            const data = n.data as Record<string, unknown>;
            return data.status === "blocked";
          })
          .map((n) => n.id),
      );

      // BFS from blocked nodes along outgoing edges
      const visited = new Set<string>();
      const queue = [...blockedNodeIds];
      while (queue.length > 0) {
        const current = queue.shift()!;
        if (visited.has(current)) continue;
        visited.add(current);
        result.blockedChainNodeIds.add(current);

        const neighbors = adj.get(current) ?? [];
        for (const { edge, target } of neighbors) {
          result.blockedChainEdgeIds.add(edge.id);
          if (!visited.has(target)) {
            queue.push(target);
          }
        }
      }
    }

    // ── Critical path detection (longest dependency chain) ───────
    if (options?.highlightCriticalPath) {
      const depEdges = edges.filter((e) => e.type === "story-dep");
      const depAdj = new Map<string, { edge: GraphEdge; target: string }[]>();
      for (const e of depEdges) {
        if (!depAdj.has(e.source)) depAdj.set(e.source, []);
        depAdj.get(e.source)!.push({ edge: e, target: e.target });
      }

      // Topological longest-path via DFS with memoization
      const memo = new Map<string, { length: number; path: string[] }>();

      function longestFrom(nodeId: string): { length: number; path: string[] } {
        if (memo.has(nodeId)) return memo.get(nodeId)!;

        const neighbors = depAdj.get(nodeId) ?? [];
        if (neighbors.length === 0) {
          const res = { length: 0, path: [] as string[] };
          memo.set(nodeId, res);
          return res;
        }

        let best = { length: 0, path: [] as string[] };
        for (const { edge, target } of neighbors) {
          const sub = longestFrom(target);
          if (sub.length + 1 > best.length) {
            best = { length: sub.length + 1, path: [edge.id, ...sub.path] };
          }
        }
        memo.set(nodeId, best);
        return best;
      }

      // Find the globally longest critical path
      let globalBest = { length: 0, path: [] as string[] };
      const nodeIds = new Set(nodes.map((n) => n.id));
      const hasIncoming = new Set(depEdges.map((e) => e.target));
      const roots = [...nodeIds].filter((id) => !hasIncoming.has(id));

      for (const rootId of roots) {
        const candidate = longestFrom(rootId);
        if (candidate.length > globalBest.length) {
          globalBest = candidate;
        }
      }

      for (const edgeId of globalBest.path) {
        result.criticalPathEdgeIds.add(edgeId);
      }
    }

    return result;
  }, [nodes, edges, options?.highlightCriticalPath, options?.highlightBlockedPaths]);
}

export default useGraphHighlights;
