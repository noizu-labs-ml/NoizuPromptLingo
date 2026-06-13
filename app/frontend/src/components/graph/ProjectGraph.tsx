"use client";

import React, { useState, useCallback, useEffect } from "react";
import {
  ReactFlow,
  ReactFlowProvider,
  MiniMap,
  Controls,
  useReactFlow,
  type OnConnect,
} from "@xyflow/react";
import "@xyflow/react/dist/style.css";

import type {
  ProjectGraphProps,
  ProjectGraphConfig,
  GraphFilters,
  LayoutMode,
  FilterPreset,
  GraphEdgeType,
} from "./ProjectGraph.types";
import { graphNodeTypes } from "./nodes";
import { graphEdgeTypes } from "./edges";
import { useGraphLayout } from "./hooks/useGraphLayout";
import { useGraphFilters } from "./hooks/useGraphFilters";
import { useGraphSelection } from "./hooks/useGraphSelection";
import { useGraphHighlights } from "./hooks/useGraphHighlights";
import { GraphToolbar } from "./controls/GraphToolbar";
import { FilterPanel } from "./controls/FilterPanel";
import { GraphLegend } from "./controls/GraphLegend";
import { DetailPanel } from "./panels/DetailPanel";

/**
 * ProjectGraph — Main wrapper component. Composes ReactFlow provider,
 * layout engine, filter/highlight hooks, toolbar, filter panel, detail panel,
 * and minimap. (Architecture §4.2, §4.3)
 *
 * Usage:
 * ```tsx
 * <ProjectGraph
 *   data={{ nodes, edges }}
 *   config={CrossProjectPreset}
 *   onNodeSelect={setSelectedItem}
 *   onNodeNavigate={(id) => router.push(`/items/${id}`)}
 *   detailPanelSide="right"
 * />
 * ```
 */

const DEFAULT_CONFIG: ProjectGraphConfig = {
  layout: "ltr",
  showMinimap: true,
  editable: false,
};

// ── Inner component (needs ReactFlow context) ───────────────────

function ProjectGraphInner({
  data,
  config: configProp,
  onNodeSelect,
  onNodeNavigate,
  onEdgeCreate,
  onEdgeDelete,
  detailPanelSide = "right",
  loading = false,
  className,
}: ProjectGraphProps) {
  const config = { ...DEFAULT_CONFIG, ...configProp };
  const { fitView, zoomIn, zoomOut } = useReactFlow();

  // ── State ──────────────────────────────────────────────────────
  const [layout, setLayout] = useState<LayoutMode>(config.layout);
  const [filters, setFilters] = useState<GraphFilters>(config.filters ?? {});
  const [showFilters, setShowFilters] = useState(false);
  const [activePresetId, setActivePresetId] = useState<string | undefined>();

  // ── Hooks ──────────────────────────────────────────────────────
  const { filteredNodes, filteredEdges } = useGraphFilters(
    data.nodes,
    data.edges,
    filters,
  );

  const { layoutNodes, layoutEdges } = useGraphLayout(
    filteredNodes,
    filteredEdges,
    layout,
  );

  const { selectedNode, handleNodeClick, handlePaneClick, clearSelection } =
    useGraphSelection(filteredNodes, onNodeSelect, onNodeNavigate);

  const highlights = useGraphHighlights(filteredNodes, filteredEdges, {
    highlightCriticalPath: config.highlightCriticalPath,
    highlightBlockedPaths: config.highlightBlockedPaths,
  });

  // ── Keyboard shortcuts ─────────────────────────────────────────
  useEffect(() => {
    function handleKeyDown(e: KeyboardEvent) {
      // Layout shortcuts (1-4)
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;
      switch (e.key) {
        case "1": setLayout("ltr"); break;
        case "2": setLayout("radial"); break;
        case "3": setLayout("top-down"); break;
        case "4": setLayout("force"); break;
        case "f": case "F": fitView({ padding: 0.1 }); break;
        case "Escape": clearSelection(); break;
      }
    }
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [fitView, clearSelection]);

  // ── Edge creation (editable mode) ──────────────────────────────
  const onConnect: OnConnect = useCallback(
    (connection) => {
      if (!config.editable || !onEdgeCreate) return;
      if (connection.source && connection.target) {
        onEdgeCreate(connection.source, connection.target, "story-dep" as GraphEdgeType);
      }
    },
    [config.editable, onEdgeCreate],
  );

  // ── Preset handler ─────────────────────────────────────────────
  const handlePresetSelect = useCallback((preset: FilterPreset) => {
    setActivePresetId(preset.id);
    setFilters(preset.filters);
    if (preset.layout) setLayout(preset.layout);
  }, []);

  // ── Render ─────────────────────────────────────────────────────
  const showDetailPanel = detailPanelSide !== "none" && selectedNode;

  return (
    <div
      className={className}
      style={{
        display: "flex",
        flexDirection: "column",
        height: "100%",
        width: "100%",
        border: "1px solid var(--border)",
        borderRadius: "var(--radius-md, 6px)",
        overflow: "hidden",
        background: "var(--graph-canvas-bg, var(--bg, var(--surface)))",
      }}
    >
      {/* Toolbar */}
      <GraphToolbar
        layout={layout}
        onLayoutChange={setLayout}
        onFitView={() => fitView({ padding: 0.1 })}
        onZoomIn={() => zoomIn()}
        onZoomOut={() => zoomOut()}
        filtersActive={showFilters}
        onToggleFilters={() => setShowFilters((v) => !v)}
        activePresetId={activePresetId}
        onPresetSelect={handlePresetSelect}
      />

      {/* Filter panel (collapsible) */}
      {showFilters && <FilterPanel filters={filters} onChange={setFilters} />}

      {/* Main content: graph + detail panel */}
      <div style={{ display: "flex", flex: 1, minHeight: 0 }}>
        {/* Graph canvas */}
        <div style={{ flex: 1, position: "relative" }}>
          {loading ? (
            <div style={{ display: "flex", alignItems: "center", justifyContent: "center", height: "100%", color: "var(--text-muted)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-sm)" }}>
              Loading graph...
            </div>
          ) : (
            <ReactFlow
              nodes={layoutNodes}
              edges={layoutEdges}
              nodeTypes={graphNodeTypes}
              edgeTypes={graphEdgeTypes}
              onNodeClick={(event, node) => handleNodeClick(event as unknown as React.MouseEvent, node.id)}
              onPaneClick={handlePaneClick}
              onConnect={config.editable ? onConnect : undefined}
              fitView
              fitViewOptions={{ padding: 0.1 }}
              minZoom={0.2}
              maxZoom={3}
              attributionPosition="bottom-left"
              proOptions={{ hideAttribution: true }}
            >
              {config.showMinimap && (
                <MiniMap
                  style={{
                    background: "var(--graph-minimap-bg, var(--surface-alt, var(--surface)))",
                    border: "1px solid var(--graph-minimap-border, var(--border))",
                    borderRadius: 4,
                  }}
                  maskColor="rgba(0,0,0,0.1)"
                  nodeStrokeWidth={1}
                  pannable
                  zoomable
                />
              )}
              <Controls
                showInteractive={!!config.editable}
                style={{ borderRadius: 4, border: "1px solid var(--border)", overflow: "hidden" }}
              />
            </ReactFlow>
          )}
        </div>

        {/* Detail panel */}
        {showDetailPanel && (
          <DetailPanel
            node={selectedNode}
            onClose={clearSelection}
            onNavigate={(id) => onNodeNavigate?.(id, "story")}
            side={detailPanelSide === "bottom" ? "bottom" : "right"}
          />
        )}
      </div>

      {/* Legend */}
      <GraphLegend />
    </div>
  );
}

// ── Public wrapper with ReactFlowProvider ────────────────────────

export function ProjectGraph(props: ProjectGraphProps) {
  return (
    <ReactFlowProvider>
      <ProjectGraphInner {...props} />
    </ReactFlowProvider>
  );
}

export default ProjectGraph;
