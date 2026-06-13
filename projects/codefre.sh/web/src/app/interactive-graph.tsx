"use client";

import { useEffect, useRef, useState, useCallback } from "react";

/* =============================================
   DATA TYPES
   ============================================= */

type EvalState = "pass" | "warn" | "fail" | "freeball";

interface Expectation {
  text: string;
  score: number;
  status: "pass" | "warn" | "fail";
}

interface Branch {
  condition: string;
  target: string;
}

interface GraphNode {
  id: string;
  label: string;
  evalState: EvalState;
  score: string;
  x: number;
  y: number;
  prompt: string;
  expectations: Expectation[];
  branches: Branch[];
}

interface GraphEdge {
  from: string;
  to: string;
  label: string;
  dashed?: boolean;
}

/* =============================================
   GRAPH DATA
   ============================================= */

const NODES: GraphNode[] = [
  {
    id: "greeting",
    label: "greeting",
    evalState: "pass",
    score: "0.94",
    x: 100,
    y: 180,
    prompt: "Build me a website",
    expectations: [
      { text: "asks_clarifying_questions", score: 0.94, status: "pass" },
      { text: "does_not_hallucinate_stack", score: 0.91, status: "pass" },
    ],
    branches: [
      { condition: "clarifies_scope", target: "scope" },
      { condition: "jumps_to_code", target: "architecture" },
    ],
  },
  {
    id: "scope",
    label: "scope",
    evalState: "warn",
    score: "0.52",
    x: 300,
    y: 180,
    prompt: "A language learning platform",
    expectations: [
      { text: "proposes_concrete_structure", score: 0.52, status: "warn" },
      { text: "asks_about_audience", score: 0.67, status: "warn" },
    ],
    branches: [
      { condition: "proposes_structure", target: "architecture" },
      { condition: "agent_deviates", target: "freeball" },
    ],
  },
  {
    id: "architecture",
    label: "architecture",
    evalState: "fail",
    score: "0.12",
    x: 500,
    y: 120,
    prompt: "What stack would you use?",
    expectations: [
      { text: "justifies_choices", score: 0.12, status: "fail" },
      { text: "avoids_overengineering", score: 0.08, status: "fail" },
    ],
    branches: [{ condition: "retry_path", target: "recovery" }],
  },
  {
    id: "freeball",
    label: "freeball:clarify",
    evalState: "freeball",
    score: "drift",
    x: 500,
    y: 260,
    prompt:
      "[Agent deviated] Started discussing mobile-first design patterns without being asked",
    expectations: [
      { text: "quality_of_deviation", score: 0.85, status: "pass" },
      { text: "relevance_to_topic", score: 0.72, status: "warn" },
    ],
    branches: [{ condition: "auto-evaluated", target: "recovery" }],
  },
  {
    id: "recovery",
    label: "recovery",
    evalState: "pass",
    score: "0.88",
    x: 700,
    y: 180,
    prompt: "Let's go with your suggestion. What's the timeline?",
    expectations: [
      { text: "provides_realistic_estimate", score: 0.88, status: "pass" },
      { text: "breaks_into_phases", score: 0.91, status: "pass" },
    ],
    branches: [],
  },
];

const EDGES: GraphEdge[] = [
  { from: "greeting", to: "scope", label: "agent asks questions" },
  { from: "scope", to: "architecture", label: "proposes structure" },
  { from: "scope", to: "freeball", label: "agent deviates", dashed: true },
  { from: "architecture", to: "recovery", label: "retry path" },
  { from: "freeball", to: "recovery", label: "auto-evaluated" },
];

/* =============================================
   COLORS
   ============================================= */

const COLORS = {
  bgSurface: "#151820",
  bgPrimary: "#0E1017",
  borderDefault: "#2A2D33",
  borderStrong: "#3D4048",
  textPrimary: "#E8E5E0",
  textSecondary: "#908D87",
  textTertiary: "#5C5A55",
  copper: "#D4915E",
  copperMuted: "rgba(212, 145, 94, 0.25)",
  evalPass: "#3EC97E",
  evalWarn: "#E5C53E",
  evalFail: "#E54E4E",
  evalFreeball: "#E8863D",
};

const EVAL_COLORS: Record<EvalState, string> = {
  pass: COLORS.evalPass,
  warn: COLORS.evalWarn,
  fail: COLORS.evalFail,
  freeball: COLORS.evalFreeball,
};

const EVAL_BRIGHT: Record<EvalState, string> = {
  pass: "#5CDFAA",
  warn: "#F0D86A",
  fail: "#F07070",
  freeball: "#F0A060",
};

// RGBA wash colors for node fills
const EVAL_WASH: Record<EvalState, [number, number, number, number]> = {
  pass: [62, 201, 126, 13],
  warn: [229, 197, 62, 13],
  fail: [229, 78, 78, 13],
  freeball: [232, 134, 61, 13],
};

/* =============================================
   CONSTANTS
   ============================================= */

const BASE_W = 800;
const BASE_H = 400;
const NODE_W = 140;
const NODE_H = 60;
const NODE_R = 6;

/* =============================================
   STATUS ICONS
   ============================================= */

function StatusIcon({ status }: { status: "pass" | "warn" | "fail" }) {
  if (status === "pass")
    return <span className="text-eval-pass">&#x2713;</span>;
  if (status === "warn")
    return <span className="text-eval-warn">&#x26A0;</span>;
  return <span className="text-eval-fail">&#x2717;</span>;
}

/* =============================================
   COMPONENT
   ============================================= */

export function InteractiveGraph({ className }: { className?: string }) {
  const containerRef = useRef<HTMLDivElement>(null);
  const canvasContainerRef = useRef<HTMLDivElement>(null);
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(null);
  const [notes, setNotes] = useState<Record<string, string>>({});
  const [canvasWidth, setCanvasWidth] = useState(BASE_W);

  // Refs for p5 communication
  const hoveredNodeRef = useRef<string | null>(null);
  const selectedNodeRef = useRef<string | null>(null);
  const scaleRef = useRef(1);

  // Keep ref in sync with state
  useEffect(() => {
    selectedNodeRef.current = selectedNodeId;
  }, [selectedNodeId]);

  const handleNodeClick = useCallback((nodeId: string | null) => {
    setSelectedNodeId(nodeId);
  }, []);

  // Resize observer
  useEffect(() => {
    const el = canvasContainerRef.current;
    if (!el) return;

    const observer = new ResizeObserver((entries) => {
      for (const entry of entries) {
        const w = entry.contentRect.width;
        if (w > 0) setCanvasWidth(w);
      }
    });
    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  // p5 sketch
  useEffect(() => {
    const container = canvasContainerRef.current;
    if (!container) return;

    let p5Instance: any;

    import("p5").then((p5Module) => {
      const P5 = p5Module.default;

      p5Instance = new P5((s: any) => {
        let cw = container.clientWidth || BASE_W;
        let ch = BASE_H;
        let scale = cw / BASE_W;

        function scaledNodes(): (GraphNode & {
          sx: number;
          sy: number;
          sw: number;
          sh: number;
        })[] {
          return NODES.map((n) => ({
            ...n,
            sx: n.x * scale,
            sy: n.y * scale,
            sw: NODE_W * scale,
            sh: NODE_H * scale,
          }));
        }

        function nodeAt(mx: number, my: number): string | null {
          const nodes = scaledNodes();
          for (const n of nodes) {
            if (
              mx >= n.sx - n.sw / 2 &&
              mx <= n.sx + n.sw / 2 &&
              my >= n.sy - n.sh / 2 &&
              my <= n.sy + n.sh / 2
            ) {
              return n.id;
            }
          }
          return null;
        }

        s.setup = () => {
          cw = container.clientWidth || BASE_W;
          scale = cw / BASE_W;
          scaleRef.current = scale;
          ch = BASE_H * scale;
          const canvas = s.createCanvas(cw, ch);
          canvas.style("display", "block");
          s.textFont("Plus Jakarta Sans");
        };

        s.windowResized = () => {
          cw = container.clientWidth || BASE_W;
          scale = cw / BASE_W;
          scaleRef.current = scale;
          ch = BASE_H * scale;
          s.resizeCanvas(cw, ch);
        };

        s.draw = () => {
          s.clear();

          const nodes = scaledNodes();
          const nodeMap = new Map(nodes.map((n) => [n.id, n]));
          const selected = selectedNodeRef.current;
          const hovered = hoveredNodeRef.current;

          // Draw edges
          for (const edge of EDGES) {
            const fromNode = nodeMap.get(edge.from);
            const toNode = nodeMap.get(edge.to);
            if (!fromNode || !toNode) continue;

            const isConnected =
              selected === edge.from || selected === edge.to;
            const edgeColor = isConnected
              ? COLORS.copper
              : COLORS.borderDefault;

            s.stroke(edgeColor);
            s.strokeWeight(1.5 * scale);
            s.noFill();

            if (edge.dashed) {
              s.drawingContext.setLineDash([6 * scale, 4 * scale]);
            }

            // Bezier curve
            const x1 = fromNode.sx;
            const y1 = fromNode.sy;
            const x2 = toNode.sx;
            const y2 = toNode.sy;
            const cpx1 = x1 + (x2 - x1) * 0.4;
            const cpy1 = y1;
            const cpx2 = x1 + (x2 - x1) * 0.6;
            const cpy2 = y2;

            s.bezier(x1, y1, cpx1, cpy1, cpx2, cpy2, x2, y2);
            s.drawingContext.setLineDash([]);

            // Arrowhead
            const t = 0.95;
            const ax =
              (1 - t) ** 3 * x1 +
              3 * (1 - t) ** 2 * t * cpx1 +
              3 * (1 - t) * t ** 2 * cpx2 +
              t ** 3 * x2;
            const ay =
              (1 - t) ** 3 * y1 +
              3 * (1 - t) ** 2 * t * cpy1 +
              3 * (1 - t) * t ** 2 * cpy2 +
              t ** 3 * y2;
            const dt = 0.01;
            const t2 = t - dt;
            const bx =
              (1 - t2) ** 3 * x1 +
              3 * (1 - t2) ** 2 * t2 * cpx1 +
              3 * (1 - t2) * t2 ** 2 * cpx2 +
              t2 ** 3 * x2;
            const by =
              (1 - t2) ** 3 * y1 +
              3 * (1 - t2) ** 2 * t2 * cpy1 +
              3 * (1 - t2) * t2 ** 2 * cpy2 +
              t2 ** 3 * y2;

            const angle = Math.atan2(ay - by, ax - bx);
            const arrowSize = 6 * scale;
            s.fill(edgeColor);
            s.noStroke();
            s.triangle(
              ax,
              ay,
              ax - arrowSize * Math.cos(angle - 0.4),
              ay - arrowSize * Math.sin(angle - 0.4),
              ax - arrowSize * Math.cos(angle + 0.4),
              ay - arrowSize * Math.sin(angle + 0.4)
            );

            // Edge label
            const midT = 0.5;
            const mx =
              (1 - midT) ** 3 * x1 +
              3 * (1 - midT) ** 2 * midT * cpx1 +
              3 * (1 - midT) * midT ** 2 * cpx2 +
              midT ** 3 * x2;
            const my =
              (1 - midT) ** 3 * y1 +
              3 * (1 - midT) ** 2 * midT * cpy1 +
              3 * (1 - midT) * midT ** 2 * cpy2 +
              midT ** 3 * y2;

            s.textFont("Plus Jakarta Sans");
            s.textSize(10 * scale);
            s.textAlign(s.CENTER, s.CENTER);
            const tw = s.textWidth(edge.label) + 8 * scale;
            const th = 14 * scale;
            s.fill(COLORS.bgPrimary);
            s.noStroke();
            s.rect(mx - tw / 2, my - th / 2, tw, th, 3 * scale);
            s.fill(COLORS.textTertiary);
            s.text(edge.label, mx, my);
          }

          // Draw nodes
          for (const n of nodes) {
            const isSelected = selected === n.id;
            const isHovered = hovered === n.id;
            const evalColor = EVAL_COLORS[n.evalState];
            const brightColor = EVAL_BRIGHT[n.evalState];
            const wash = EVAL_WASH[n.evalState];

            // Selected glow
            if (isSelected) {
              s.noStroke();
              s.fill(COLORS.copperMuted);
              s.rect(
                n.sx - n.sw / 2 - 3 * scale,
                n.sy - n.sh / 2 - 3 * scale,
                n.sw + 6 * scale,
                n.sh + 6 * scale,
                (NODE_R + 3) * scale
              );
            }

            // Node fill
            s.fill(wash[0], wash[1], wash[2], wash[3]);

            // Border
            const borderColor = isSelected
              ? COLORS.copper
              : isHovered
                ? brightColor
                : evalColor;
            s.stroke(borderColor);
            s.strokeWeight(1.5 * scale);

            if (n.evalState === "freeball") {
              s.drawingContext.setLineDash([5 * scale, 3 * scale]);
            }

            s.rect(
              n.sx - n.sw / 2,
              n.sy - n.sh / 2,
              n.sw,
              n.sh,
              NODE_R * scale
            );
            s.drawingContext.setLineDash([]);

            // Label
            s.noStroke();
            s.fill(COLORS.textPrimary);
            s.textFont("Plus Jakarta Sans");
            s.textSize(13 * scale);
            s.textAlign(s.CENTER, s.CENTER);
            s.text(n.label, n.sx, n.sy - 6 * scale);

            // Score badge
            s.fill(evalColor);
            s.textFont("JetBrains Mono");
            s.textSize(11 * scale);
            s.text(n.score, n.sx, n.sy + 12 * scale);
          }
        };

        s.mouseMoved = () => {
          const id = nodeAt(s.mouseX, s.mouseY);
          hoveredNodeRef.current = id;
          container.style.cursor = id ? "pointer" : "default";
        };

        s.mousePressed = () => {
          const id = nodeAt(s.mouseX, s.mouseY);
          handleNodeClick(id);
        };
      }, container);
    });

    return () => {
      p5Instance?.remove();
    };
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const selectedNode = NODES.find((n) => n.id === selectedNodeId) || null;

  return (
    <div className={className} ref={containerRef}>
      {/* p5 canvas container */}
      <div ref={canvasContainerRef} className="w-full" />

      {/* Detail panel */}
      <div
        className={`overflow-hidden transition-all duration-300 ease-out ${
          selectedNode
            ? "mt-4 max-h-[600px] opacity-100"
            : "max-h-0 opacity-0"
        }`}
      >
        {selectedNode && (
          <DetailPanel
            node={selectedNode}
            notes={notes[selectedNode.id] || ""}
            onNotesChange={(val) =>
              setNotes((prev) => ({ ...prev, [selectedNode.id]: val }))
            }
          />
        )}
      </div>
    </div>
  );
}

/* =============================================
   DETAIL PANEL
   ============================================= */

function DetailPanel({
  node,
  notes,
  onNotesChange,
}: {
  node: GraphNode;
  notes: string;
  onNotesChange: (val: string) => void;
}) {
  const evalColor = EVAL_COLORS[node.evalState];

  return (
    <div className="rounded-[6px] border-[1.5px] border-border bg-surface p-5 space-y-5">
      {/* Header */}
      <div className="flex items-center gap-3">
        <span className="font-mono text-sm font-semibold text-text-primary">
          {node.label}
        </span>
        <span
          className="rounded px-2 py-0.5 font-mono text-[12px] font-semibold"
          style={{ color: evalColor, backgroundColor: `${evalColor}15` }}
        >
          {node.score} {node.evalState}
        </span>
      </div>

      {/* Script */}
      <div>
        <p className="mb-2 text-[11px] font-medium uppercase tracking-widest text-text-tertiary">
          Script
        </p>
        <div className="rounded-[4px] border-l-[3px] border-border bg-well px-4 py-2.5 font-mono text-[13px] leading-snug text-text-secondary">
          {node.prompt}
        </div>
      </div>

      {/* Expectations */}
      <div>
        <p className="mb-2 text-[11px] font-medium uppercase tracking-widest text-text-tertiary">
          Expectations
        </p>
        <div className="space-y-1.5">
          {node.expectations.map((exp) => (
            <div
              key={exp.text}
              className="flex items-center gap-2 text-[13px]"
            >
              <StatusIcon status={exp.status} />
              <span className="text-text-secondary">{exp.text}</span>
              <span className="font-mono text-text-tertiary">
                ({exp.score.toFixed(2)})
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Branches */}
      {node.branches.length > 0 && (
        <div>
          <p className="mb-2 text-[11px] font-medium uppercase tracking-widest text-text-tertiary">
            Branches
          </p>
          <div className="space-y-1">
            {node.branches.map((b) => (
              <p
                key={b.condition}
                className="font-mono text-[13px] text-text-secondary"
              >
                <span className="text-text-tertiary">IF</span> {b.condition}{" "}
                <span className="text-text-tertiary">&rarr;</span> {b.target}
              </p>
            ))}
          </div>
        </div>
      )}

      {/* Notes */}
      <div>
        <p className="mb-2 text-[11px] font-medium uppercase tracking-widest text-accent">
          Notes
        </p>
        <textarea
          value={notes}
          onChange={(e) => onNotesChange(e.target.value)}
          placeholder="Add notes about this node..."
          className="w-full rounded-[6px] border-[1.5px] border-border bg-well p-3 font-mono text-[13px] text-text-secondary placeholder:text-text-ghost focus:border-accent focus:outline-none resize-y min-h-[60px]"
          rows={2}
        />
      </div>
    </div>
  );
}
