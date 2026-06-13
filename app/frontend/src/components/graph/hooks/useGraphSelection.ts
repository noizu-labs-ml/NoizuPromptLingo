"use client";

import { useState, useCallback } from "react";
import type { GraphNode, GraphNodeType } from "../ProjectGraph.types";

/**
 * useGraphSelection — Manages selected node state and drives the detail panel.
 * Single-select by default; fires onNodeSelect callback. (Architecture §4.1)
 */

export interface GraphSelectionState {
  selectedNode: GraphNode | null;
  selectNode: (node: GraphNode | null) => void;
  clearSelection: () => void;
  handleNodeClick: (event: React.MouseEvent, nodeId: string) => void;
  handlePaneClick: () => void;
}

export function useGraphSelection(
  nodes: GraphNode[],
  onNodeSelect?: (node: GraphNode | null) => void,
  onNodeNavigate?: (nodeId: string, nodeType: GraphNodeType) => void,
): GraphSelectionState {
  const [selectedNode, setSelectedNode] = useState<GraphNode | null>(null);

  const selectNode = useCallback(
    (node: GraphNode | null) => {
      setSelectedNode(node);
      onNodeSelect?.(node);
    },
    [onNodeSelect],
  );

  const clearSelection = useCallback(() => {
    setSelectedNode(null);
    onNodeSelect?.(null);
  }, [onNodeSelect]);

  const handleNodeClick = useCallback(
    (_event: React.MouseEvent, nodeId: string) => {
      const found = nodes.find((n) => n.id === nodeId) ?? null;
      selectNode(found);
    },
    [nodes, selectNode],
  );

  const handlePaneClick = useCallback(() => {
    clearSelection();
  }, [clearSelection]);

  return {
    selectedNode,
    selectNode,
    clearSelection,
    handleNodeClick,
    handlePaneClick,
  };
}

export default useGraphSelection;
