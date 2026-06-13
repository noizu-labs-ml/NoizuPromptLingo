"use client";

import * as React from "react";
import * as d3Force from "d3-force";
import * as d3Drag from "d3-drag";
import * as d3Selection from "d3-selection";
import * as d3Zoom from "d3-zoom";
import type { EntryType, EntryStatus } from "@/lib/constants";

export interface GraphNode {
  id: string;
  label: string;
  type: EntryType;
  status: EntryStatus;
  x?: number;
  y?: number;
}

export interface GraphEdge {
  source: string;
  target: string;
  relationship: string;
}

interface KnowledgeGraphProps {
  nodes: GraphNode[];
  edges: GraphEdge[];
  onNodeClick?: (node: GraphNode) => void;
}

// Node dimensions
const NODE_W = 124;
const NODE_H = 46;

export function KnowledgeGraph({ nodes, edges, onNodeClick }: KnowledgeGraphProps) {
  const svgRef = React.useRef<SVGSVGElement>(null);
  const containerRef = React.useRef<HTMLDivElement>(null);
  const [hoveredId, setHoveredId] = React.useState<string | null>(null);

  React.useEffect(() => {
    if (!svgRef.current || !containerRef.current) return;

    const svg = d3Selection.select(svgRef.current);
    svg.selectAll("*").remove();

    const { width, height } = containerRef.current.getBoundingClientRect();

    // Defs for clipping / arrows
    const defs = svg.append("defs");
    defs
      .append("marker")
      .attr("id", "arrowhead")
      .attr("viewBox", "0 -4 8 8")
      .attr("refX", 8)
      .attr("refY", 0)
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
      .append("path")
      .attr("d", "M0,-4L8,0L0,4")
      .attr("fill", "#C4BDB3");

    // Root group — zoom target
    const root = svg.append("g").attr("class", "zoom-root");

    // Zoom behaviour
    const zoom = d3Zoom
      .zoom<SVGSVGElement, unknown>()
      .scaleExtent([0.2, 3])
      .on("zoom", (event: d3Zoom.D3ZoomEvent<SVGSVGElement, unknown>) => {
        root.attr("transform", event.transform.toString());
      });

    svg.call(zoom);

    // Simulation nodes (mutable copies d3-force requires)
    type SimNode = d3Force.SimulationNodeDatum & GraphNode;
    type SimLink = d3Force.SimulationLinkDatum<SimNode> & { relationship: string };

    const simNodes: SimNode[] = nodes.map((n) => ({ ...n }));
    const nodeById = new Map(simNodes.map((n) => [n.id, n]));

    const simLinks: SimLink[] = edges
      .map((e) => {
        const src = nodeById.get(e.source);
        const tgt = nodeById.get(e.target);
        if (!src || !tgt) return null;
        return { source: src, target: tgt, relationship: e.relationship } as SimLink;
      })
      .filter((l): l is SimLink => l !== null);

    const simulation = d3Force
      .forceSimulation<SimNode>(simNodes)
      .force(
        "link",
        d3Force
          .forceLink<SimNode, SimLink>(simLinks)
          .id((d) => d.id)
          .distance(160)
          .strength(0.6)
      )
      .force("charge", d3Force.forceManyBody().strength(-320))
      .force("center", d3Force.forceCenter(width / 2, height / 2))
      .force("collide", d3Force.forceCollide(80));

    // Edge lines
    const edgeGroup = root.append("g").attr("class", "edges");
    const edgePaths = edgeGroup
      .selectAll<SVGLineElement, SimLink>("line")
      .data(simLinks)
      .enter()
      .append("line")
      .attr("stroke", "#C4BDB3")
      .attr("stroke-width", 1)
      .attr("stroke-linecap", "round")
      .attr("class", "graph-edge");

    // Node foreignObject groups
    const nodeGroup = root.append("g").attr("class", "nodes");

    const nodeFO = nodeGroup
      .selectAll<SVGForeignObjectElement, SimNode>("foreignObject")
      .data(simNodes)
      .enter()
      .append("foreignObject")
      .attr("width", NODE_W)
      .attr("height", NODE_H)
      .style("overflow", "visible")
      .style("cursor", "pointer")
      .on("click", (_event: MouseEvent, d: SimNode) => {
        onNodeClick?.(d);
      })
      .on("mouseenter", (_event: MouseEvent, d: SimNode) => {
        setHoveredId(d.id);
      })
      .on("mouseleave", () => {
        setHoveredId(null);
      });

    // Inner HTML node
    nodeFO
      .append("xhtml:div")
      .attr("xmlns", "http://www.w3.org/1999/xhtml")
      .style("width", `${NODE_W}px`)
      .style("height", `${NODE_H}px`)
      .style("background", "#FFFFFF")
      .style("border-radius", "6px")
      .style("border", "1px solid #E8E2D9")
      .style("padding", "6px 10px")
      .style("box-sizing", "border-box")
      .style("display", "flex")
      .style("flex-direction", "column")
      .style("justify-content", "center")
      .style("user-select", "none")
      .style("transition", "border-color 150ms ease, box-shadow 150ms ease")
      .each(function (d: SimNode) {
        const div = d3Selection.select(this);

        // Canon/generated left border strip
        div
          .append("xhtml:div")
          .style("position", "absolute")
          .style("left", "0")
          .style("top", "0")
          .style("bottom", "0")
          .style("width", "3px")
          .style("border-radius", "6px 0 0 6px")
          .style(
            "background",
            d.status === "canon" ? "#1A1714" : "none"
          )
          .style(
            "border-left",
            d.status === "generated" ? "3px dashed #8B7355" : "none"
          );

        // Type label
        div
          .append("xhtml:div")
          .style("font-family", "'JetBrains Mono', monospace")
          .style("font-size", "10px")
          .style("text-transform", "uppercase")
          .style("letter-spacing", "0.06em")
          .style("color", "#9E9790")
          .style("margin-bottom", "2px")
          .style("padding-left", "6px")
          .text(d.type);

        // Main label
        div
          .append("xhtml:div")
          .style("font-family", "'Lora', 'Source Serif 4', serif")
          .style("font-size", "13px")
          .style("font-weight", "600")
          .style("color", "#1A1714")
          .style("padding-left", "6px")
          .style("white-space", "nowrap")
          .style("overflow", "hidden")
          .style("text-overflow", "ellipsis")
          .text(d.label);
      });

    // Simulation tick
    simulation.on("tick", () => {
      edgePaths
        .attr("x1", (d) => {
          const src = d.source as SimNode;
          return (src.x ?? 0) + NODE_W / 2;
        })
        .attr("y1", (d) => {
          const src = d.source as SimNode;
          return (src.y ?? 0) + NODE_H / 2;
        })
        .attr("x2", (d) => {
          const tgt = d.target as SimNode;
          return (tgt.x ?? 0) + NODE_W / 2;
        })
        .attr("y2", (d) => {
          const tgt = d.target as SimNode;
          return (tgt.y ?? 0) + NODE_H / 2;
        });

      nodeFO
        .attr("x", (d) => (d.x ?? 0) - NODE_W / 2)
        .attr("y", (d) => (d.y ?? 0) - NODE_H / 2);
    });

    // Drag behaviour
    const drag = d3Drag
      .drag<SVGForeignObjectElement, SimNode>()
      .on("start", (event, d) => {
        if (!event.active) simulation.alphaTarget(0.3).restart();
        d.fx = d.x;
        d.fy = d.y;
      })
      .on("drag", (event, d) => {
        d.fx = event.x;
        d.fy = event.y;
      })
      .on("end", (event, d) => {
        if (!event.active) simulation.alphaTarget(0);
        d.fx = null;
        d.fy = null;
      });

    nodeFO.call(drag);

    return () => {
      simulation.stop();
    };
  }, [nodes, edges, onNodeClick]);

  // Highlight connected edges on hover (DOM-based)
  React.useEffect(() => {
    if (!svgRef.current) return;
    const svg = d3Selection.select(svgRef.current);

    if (hoveredId === null) {
      svg.selectAll<SVGLineElement, d3Force.SimulationLinkDatum<d3Force.SimulationNodeDatum>>("line.graph-edge")
        .attr("stroke", "#C4BDB3")
        .attr("stroke-width", 1);
    } else {
      svg.selectAll<SVGLineElement, { source: { id?: string }; target: { id?: string } }>("line.graph-edge")
        .attr("stroke", (d) => {
          const srcId = typeof d.source === "object" ? (d.source as { id?: string }).id : d.source;
          const tgtId = typeof d.target === "object" ? (d.target as { id?: string }).id : d.target;
          return srcId === hoveredId || tgtId === hoveredId ? "#2D5A8E" : "#C4BDB3";
        })
        .attr("stroke-width", (d) => {
          const srcId = typeof d.source === "object" ? (d.source as { id?: string }).id : d.source;
          const tgtId = typeof d.target === "object" ? (d.target as { id?: string }).id : d.target;
          return srcId === hoveredId || tgtId === hoveredId ? 1.5 : 1;
        });
    }
  }, [hoveredId]);

  return (
    <div ref={containerRef} className="relative w-full h-full bg-page rounded-md overflow-hidden">
      <svg
        ref={svgRef}
        className="w-full h-full"
        style={{ background: "#FAF9F6" }}
      />
    </div>
  );
}
