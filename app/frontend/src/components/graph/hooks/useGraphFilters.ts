"use client";

import { useMemo } from "react";
import type { GraphNode, GraphEdge, GraphFilters } from "../ProjectGraph.types";

/**
 * useGraphFilters — Applies filter config to raw graph data, returning
 * the visible subgraph. Non-matching nodes are excluded; edges whose
 * source or target is excluded are also removed. (Architecture §4.4)
 *
 * Filters are combined with AND logic: a node must pass ALL active filters.
 */

export interface FilteredGraph {
  filteredNodes: GraphNode[];
  filteredEdges: GraphEdge[];
  /** IDs of nodes that matched filters (for dimming logic in the graph) */
  matchedNodeIds: Set<string>;
}

export function useGraphFilters(
  nodes: GraphNode[],
  edges: GraphEdge[],
  filters?: GraphFilters,
): FilteredGraph {
  return useMemo(() => {
    if (!filters) {
      return {
        filteredNodes: nodes,
        filteredEdges: edges,
        matchedNodeIds: new Set(nodes.map((n) => n.id)),
      };
    }

    const filteredNodes = nodes.filter((node) => {
      // Node type filter
      if (filters.nodeTypes && filters.nodeTypes.length > 0) {
        if (!filters.nodeTypes.includes(node.type)) return false;
      }

      // Status filter (applies to story, subtask)
      if (filters.status && filters.status.length > 0) {
        const data = node.data as Record<string, unknown>;
        if ("status" in data && typeof data.status === "string") {
          if (!filters.status.includes(data.status as any)) return false;
        }
      }

      // Priority filter (applies to story)
      if (filters.priority && filters.priority.length > 0) {
        const data = node.data as Record<string, unknown>;
        if ("priority" in data && typeof data.priority === "string") {
          if (!filters.priority.includes(data.priority as any)) return false;
        }
      }

      // Assignee filter (applies to role)
      if (filters.assigneeId) {
        const data = node.data as Record<string, unknown>;
        if ("assignee" in data) {
          const assignee = data.assignee as { id: string } | undefined;
          if (!assignee || assignee.id !== filters.assigneeId) return false;
        }
      }

      // Epic filter (applies to story)
      if (filters.epicId) {
        const data = node.data as Record<string, unknown>;
        if ("epicId" in data && data.epicId !== filters.epicId) return false;
      }

      return true;
    });

    const matchedNodeIds = new Set(filteredNodes.map((n) => n.id));

    // Only keep edges where both endpoints survived filtering
    const filteredEdges = edges.filter(
      (e) => matchedNodeIds.has(e.source) && matchedNodeIds.has(e.target),
    );

    return { filteredNodes, filteredEdges, matchedNodeIds };
  }, [nodes, edges, filters]);
}

export default useGraphFilters;
