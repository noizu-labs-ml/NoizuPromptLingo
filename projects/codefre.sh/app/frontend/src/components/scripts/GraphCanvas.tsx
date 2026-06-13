"use client";
import * as React from "react";
import type { ScriptEdge, ScriptNode, ScriptNodeKind } from "@/lib/api";
import type { RunVerdict } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";

// ─── constants ──────────────────────────────────────────────────────────────
export const NODE_W = 180;
export const NODE_H = 72;
export const CANVAS_W = 1600;
export const CANVAS_H = 1200;

export const NODE_KIND_COLORS: Record<ScriptNodeKind, string> = {
  user_turn: "var(--copper)",
  system: "var(--text-secondary)",
  assistant_turn: "var(--eval-pass)",
  terminal: "var(--eval-fail)",
  freeball_anchor: "var(--eval-freeball)",
};

function kindColor(kind: string): string {
  return NODE_KIND_COLORS[kind as ScriptNodeKind] ?? "var(--text-secondary)";
}

export interface GraphCanvasProps {
  nodes: ScriptNode[];
  edges: ScriptEdge[];
  selectedNodeId?: string | null;
  edgeSourceId?: string | null;
  /** Optional per-node verdict for render-only views (run detail). */
  nodeVerdicts?: Record<string, RunVerdict | null | undefined>;
  /** Node ids currently in the "flashing" (dark well) Forge state. */
  flashingIds?: Set<string>;
  /** Node ids already settled into their final eval state (Forge sequence). */
  forgedIds?: Set<string>;
  /** Edge ids belonging to the active root→selected path; styled copper. */
  activePathEdgeIds?: Set<string>;
  /** When true, disables drag + interaction (read-only view). */
  readOnly?: boolean;
  /** Called when a node's final click is detected (non-drag). */
  onSelectNode?: (node: ScriptNode) => void;
  /** Called when node position changes mid-drag; receives committed coords. */
  onDragNode?: (nodeId: string, pos: { x: number; y: number }) => void;
  /** Called when shift-click starts an edge from this node. */
  onEdgeSourceStart?: (node: ScriptNode) => void;
  /** Called when the edge completion target is clicked. */
  onEdgeTarget?: (targetNode: ScriptNode) => void;
}

/**
 * Hand-rolled SVG graph canvas. Preserves legacy drag/mouse logic exactly;
 * only swaps inline-style node presentation for Forge CSS classes so a single
 * canvas can render either the editor or the run-detail verdict view.
 */
export function GraphCanvas({
  nodes,
  edges,
  selectedNodeId,
  edgeSourceId,
  nodeVerdicts,
  flashingIds,
  forgedIds,
  activePathEdgeIds,
  readOnly = false,
  onSelectNode,
  onDragNode,
  onEdgeSourceStart,
  onEdgeTarget,
}: GraphCanvasProps) {
  const svgRef = React.useRef<SVGSVGElement | null>(null);

  // Drag state is ref-only so it doesn't cause re-renders mid-drag.
  const dragState = React.useRef<{
    nodeId: string;
    offsetX: number;
    offsetY: number;
    moved: boolean;
  } | null>(null);

  function svgPoint(clientX: number, clientY: number) {
    const svg = svgRef.current;
    if (!svg) return { x: clientX, y: clientY };
    const pt = svg.createSVGPoint();
    pt.x = clientX;
    pt.y = clientY;
    const m = svg.getScreenCTM();
    if (!m) return { x: clientX, y: clientY };
    const p = pt.matrixTransform(m.inverse());
    return { x: p.x, y: p.y };
  }

  function onNodeMouseDown(e: React.MouseEvent, node: ScriptNode) {
    if (readOnly) return;
    if (e.shiftKey) {
      onEdgeSourceStart?.(node);
      return;
    }
    const { x = 0, y = 0 } = node.position ?? {};
    const pt = svgPoint(e.clientX, e.clientY);
    dragState.current = {
      nodeId: node.id,
      offsetX: pt.x - x,
      offsetY: pt.y - y,
      moved: false,
    };
  }

  function onSvgMouseMove(e: React.MouseEvent) {
    const drag = dragState.current;
    if (!drag) return;
    const pt = svgPoint(e.clientX, e.clientY);
    drag.moved = true;
    onDragNode?.(drag.nodeId, {
      x: Math.max(0, pt.x - drag.offsetX),
      y: Math.max(0, pt.y - drag.offsetY),
    });
  }

  function onSvgMouseUp() {
    const drag = dragState.current;
    dragState.current = null;
    if (!drag) return;
    if (drag.moved) return; // committed via onDragNode callbacks already
    const node = nodes.find((n) => n.id === drag.nodeId);
    if (!node) return;
    if (edgeSourceId && edgeSourceId !== drag.nodeId) {
      onEdgeTarget?.(node);
      return;
    }
    onSelectNode?.(node);
  }

  return (
    <svg
      ref={svgRef}
      data-cy="script-svg"
      width={CANVAS_W}
      height={CANVAS_H}
      viewBox={`0 0 ${CANVAS_W} ${CANVAS_H}`}
      onMouseMove={onSvgMouseMove}
      onMouseUp={onSvgMouseUp}
      onMouseLeave={onSvgMouseUp}
    >
      <defs>
        <marker
          id="forge-arrow"
          viewBox="0 0 10 10"
          refX="9"
          refY="5"
          markerWidth="8"
          markerHeight="8"
          orient="auto-start-reverse"
        >
          <path d="M 0 0 L 10 5 L 0 10 z" fill="currentColor" />
        </marker>
      </defs>

      {/* Edges */}
      {edges.map((e) => {
        const from = nodes.find((n) => n.id === e.from_node_id);
        const to = nodes.find((n) => n.id === e.to_node_id);
        if (!from || !to) return null;
        const fx = (from.position?.x ?? 0) + NODE_W / 2;
        const fy = (from.position?.y ?? 0) + NODE_H;
        const tx = (to.position?.x ?? 0) + NODE_W / 2;
        const ty = to.position?.y ?? 0;
        const dy = Math.max(30, (ty - fy) / 2);
        const d = `M ${fx} ${fy} C ${fx} ${fy + dy}, ${tx} ${ty - dy}, ${tx} ${ty}`;
        const mx = (fx + tx) / 2;
        const my = (fy + ty) / 2;
        const onActivePath = activePathEdgeIds?.has(e.id);
        const isFreeball =
          e.match_method === "intent" &&
          typeof e.match_config === "object" &&
          e.match_config !== null &&
          "freeball" in (e.match_config as Record<string, unknown>);
        const edgeClass = onActivePath
          ? "sg-graph-edge--path"
          : isFreeball
            ? "sg-graph-edge sg-graph-edge--freeball"
            : "sg-graph-edge";
        return (
          <g
            key={e.id}
            data-cy="graph-edge"
            style={{ color: onActivePath ? "var(--copper)" : "var(--border-default)" }}
            {...cyAttrs({ cyId: e.id })}
          >
            <path d={d} className={edgeClass} markerEnd="url(#forge-arrow)" />
            <text
              x={mx}
              y={my}
              fill="var(--text-secondary)"
              fontSize={11}
              fontFamily="var(--font-sans)"
              textAnchor="middle"
            >
              {e.label || e.match_method}
            </text>
          </g>
        );
      })}

      {/* Nodes */}
      {nodes.map((n) => {
        const { x = 0, y = 0 } = n.position ?? {};
        const isSelected = n.id === selectedNodeId;
        const isEdgeSource = n.id === edgeSourceId;
        const accent = kindColor(n.kind);
        const verdict = nodeVerdicts?.[n.id] ?? null;
        const flashing = flashingIds?.has(n.id) === true;
        const forged = forgedIds?.has(n.id) === true;
        const evalClass = verdict
          ? `eval-${verdict}`
          : "";
        const classes = [
          "sg-graph-node--svg",
          evalClass,
          flashing ? "sg-graph-node--flashing" : "",
          forged ? "sg-graph-node--forged" : "",
        ]
          .filter(Boolean)
          .join(" ");
        return (
          <g
            key={n.id}
            data-cy="graph-node"
            {...cyAttrs({ cyId: n.node_key, cyValue: verdict ?? undefined })}
            transform={`translate(${x}, ${y})`}
            style={{ cursor: readOnly ? "pointer" : "grab" }}
            className={classes}
            data-selected={isSelected ? "true" : undefined}
            data-edge-source={isEdgeSource ? "true" : undefined}
            onMouseDown={(e) => onNodeMouseDown(e, n)}
          >
            <rect
              width={NODE_W}
              height={NODE_H}
              rx={6}
              ry={6}
              className="sg-graph-node--svg__rect"
            />
            <rect width={4} height={NODE_H} rx={2} ry={2} fill={accent} />
            <text
              x={14}
              y={26}
              fontSize={13}
              fontWeight={600}
              fill="var(--text-primary)"
              fontFamily="var(--font-sans)"
            >
              {n.node_key}
            </text>
            <text
              x={14}
              y={44}
              fontSize={11}
              fill="var(--text-secondary)"
              fontFamily="var(--font-mono)"
            >
              {n.kind}
            </text>
            {n.prompt_version_id ? (
              <text
                x={14}
                y={60}
                fontSize={10}
                fill="var(--copper)"
                fontFamily="var(--font-sans)"
              >
                prompt attached
              </text>
            ) : null}
          </g>
        );
      })}

      {nodes.length === 0 ? (
        <text
          x={CANVAS_W / 2}
          y={CANVAS_H / 2}
          textAnchor="middle"
          fill="var(--text-tertiary)"
          fontSize={16}
          fontFamily="var(--font-sans)"
          data-cy="graph-empty"
        >
          Empty script — add a node from the left palette.
        </text>
      ) : null}
    </svg>
  );
}

/**
 * Compute edges lying on the root→target path (by node ancestry following
 * the first incoming edge). Used to highlight active path in copper.
 */
export function computeActivePathEdges(
  nodes: ScriptNode[],
  edges: ScriptEdge[],
  targetNodeId: string | null | undefined,
): Set<string> {
  const out = new Set<string>();
  if (!targetNodeId) return out;

  const incoming = new Map<string, ScriptEdge[]>();
  for (const e of edges) {
    const list = incoming.get(e.to_node_id) ?? [];
    list.push(e);
    incoming.set(e.to_node_id, list);
  }

  let cursor: string | null = targetNodeId;
  const seen = new Set<string>();
  while (cursor && !seen.has(cursor)) {
    seen.add(cursor);
    const ins = incoming.get(cursor);
    if (!ins || ins.length === 0) break;
    const edge = ins[0];
    out.add(edge.id);
    cursor = edge.from_node_id;
  }
  return out;
}

/**
 * Compute path order (root → ... → last) given a set of edges. Used to
 * stagger the Forge sequence illumination.
 */
export function computePathOrder(
  nodes: ScriptNode[],
  edges: ScriptEdge[],
): string[] {
  if (nodes.length === 0) return [];
  const outgoing = new Map<string, ScriptEdge[]>();
  for (const e of edges) {
    const list = outgoing.get(e.from_node_id) ?? [];
    list.push(e);
    outgoing.set(e.from_node_id, list);
  }
  const hasIncoming = new Set(edges.map((e) => e.to_node_id));
  const root =
    nodes.find((n) => !hasIncoming.has(n.id)) ?? nodes[0];

  const order: string[] = [];
  const seen = new Set<string>();
  const queue: string[] = [root.id];
  while (queue.length > 0) {
    const id = queue.shift()!;
    if (seen.has(id)) continue;
    seen.add(id);
    order.push(id);
    const outs = outgoing.get(id) ?? [];
    for (const e of outs) queue.push(e.to_node_id);
  }
  // Include any orphan nodes (not reachable from root) at the end so the
  // Forge sequence still touches them.
  for (const n of nodes) if (!seen.has(n.id)) order.push(n.id);
  return order;
}
