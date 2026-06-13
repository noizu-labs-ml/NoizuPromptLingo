"use client";

import { useEffect, useRef } from "react";

// Neural Combat Palette
const SYNAPSE: [number, number, number] = [0, 255, 170];
const COMBAT: [number, number, number] = [255, 45, 85];

interface FighterNode {
  baseX: number;
  baseY: number;
  x: number;
  y: number;
  r: number;
  type: "decision" | "action" | "perception" | "default";
}

interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  life: number;
  decay: number;
  size: number;
  color: [number, number, number];
}

interface Fighter {
  centerX: number;
  centerY: number;
  facing: 1 | -1;
  color: [number, number, number];
  nodes: FighterNode[];
  particles: Particle[];
  breathPhase: number;
}

interface BgPath {
  x1: number;
  y1: number;
  cx: number;
  cy: number;
  x2: number;
  y2: number;
  phaseOffset: number;
}

const CONNECTION_PAIRS: [number, number][] = [
  // Spine
  [0, 1],
  [1, 2],
  // Arms
  [1, 3],
  [3, 4],
  [1, 5],
  [5, 6],
  // Legs
  [2, 7],
  [7, 8],
  [2, 9],
  [9, 10],
  // Cross
  [0, 3],
  [0, 5],
  [3, 5],
];

function buildFighterNodes(
  cx: number,
  cy: number,
  facing: 1 | -1
): FighterNode[] {
  const defs: {
    ox: number;
    oy: number;
    r: number;
    type: FighterNode["type"];
  }[] = [
    { ox: 0, oy: -40, r: 7, type: "decision" }, // 0  Head
    { ox: 0, oy: -15, r: 9, type: "default" }, //   1  Chest
    { ox: 0, oy: 10, r: 6, type: "default" }, //    2  Core
    { ox: -25 * facing, oy: -20, r: 5, type: "action" }, // 3  L shoulder
    { ox: -40 * facing, oy: -5, r: 4, type: "default" }, // 4  L hand
    { ox: 25 * facing, oy: -20, r: 5, type: "default" }, // 5  R shoulder
    { ox: 40 * facing, oy: -5, r: 4, type: "default" }, // 6  R hand (front)
    { ox: -12, oy: 35, r: 5, type: "perception" }, // 7  L knee
    { ox: -15, oy: 55, r: 4, type: "default" }, //   8  L foot
    { ox: 12, oy: 35, r: 5, type: "default" }, //    9  R knee
    { ox: 15, oy: 55, r: 4, type: "default" }, //    10 R foot
  ];

  return defs.map((d) => ({
    baseX: cx + d.ox,
    baseY: cy + d.oy,
    x: cx + d.ox,
    y: cy + d.oy,
    r: d.r,
    type: d.type,
  }));
}

function buildBgPaths(w: number, h: number): BgPath[] {
  const count = 4 + Math.floor(Math.random() * 3); // 4-6
  const paths: BgPath[] = [];
  for (let i = 0; i < count; i++) {
    paths.push({
      x1: Math.random() * w,
      y1: Math.random() * h,
      cx: Math.random() * w,
      cy: Math.random() * h,
      x2: Math.random() * w,
      y2: Math.random() * h,
      phaseOffset: Math.random() * Math.PI * 2,
    });
  }
  return paths;
}

function rgba(c: [number, number, number], a: number): string {
  return `rgba(${c[0]},${c[1]},${c[2]},${Math.max(0, Math.min(1, a))})`;
}

export default function NeuralCanvas() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let w = 0;
    let h = 0;
    let animationId: number;
    let time = 0;
    let fighters: Fighter[] = [];
    let bgPaths: BgPath[] = [];
    let vsParticles: Particle[] = [];

    const prefersReducedMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches;

    function createFighters() {
      fighters = [
        {
          centerX: w * 0.3,
          centerY: h * 0.5,
          facing: 1,
          color: SYNAPSE,
          nodes: buildFighterNodes(w * 0.3, h * 0.5, 1),
          particles: [],
          breathPhase: 0,
        },
        {
          centerX: w * 0.7,
          centerY: h * 0.5,
          facing: -1,
          color: COMBAT,
          nodes: buildFighterNodes(w * 0.7, h * 0.5, -1),
          particles: [],
          breathPhase: Math.PI, // offset so they don't breathe in sync
        },
      ];
    }

    function resize() {
      const parent = canvas!.parentElement;
      if (!parent) return;
      const rect = parent.getBoundingClientRect();
      w = canvas!.width = rect.width;
      h = canvas!.height = rect.height;
      createFighters();
      bgPaths = buildBgPaths(w, h);
      vsParticles = [];
    }

    // ---- Drawing helpers ----

    function drawBgPaths() {
      for (const p of bgPaths) {
        const alpha =
          (5 + 20 * (0.5 + 0.5 * Math.sin(time * 1.5 + p.phaseOffset))) / 255;
        ctx!.beginPath();
        ctx!.moveTo(p.x1, p.y1);
        ctx!.quadraticCurveTo(p.cx, p.cy, p.x2, p.y2);
        ctx!.strokeStyle = rgba(SYNAPSE, alpha);
        ctx!.lineWidth = 1;
        ctx!.stroke();
      }
    }

    function drawConnection(
      a: FighterNode,
      b: FighterNode,
      color: [number, number, number],
      index: number
    ) {
      const mx = (a.x + b.x) / 2;
      const my = (a.y + b.y) / 2;
      // Offset midpoint perpendicular to the line for a curve
      const dx = b.x - a.x;
      const dy = b.y - a.y;
      const len = Math.sqrt(dx * dx + dy * dy) || 1;
      const offsetMag = len * 0.15;
      const cx = mx + (-dy / len) * offsetMag;
      const cy = my + (dx / len) * offsetMag;

      const alpha = 0.3 + 0.25 * Math.sin(time * 2 + index * 0.7);

      ctx!.beginPath();
      ctx!.moveTo(a.x, a.y);
      ctx!.quadraticCurveTo(cx, cy, b.x, b.y);
      ctx!.strokeStyle = rgba(color, alpha);
      ctx!.lineWidth = 1.5;
      ctx!.stroke();
    }

    function drawNode(
      node: FighterNode,
      color: [number, number, number],
      index: number
    ) {
      const pulse = 0.6 + 0.4 * Math.sin(time * 3 + index * 1.1);

      // Outer glow
      const outerR = node.r * 4;
      const outerGrad = ctx!.createRadialGradient(
        node.x,
        node.y,
        0,
        node.x,
        node.y,
        outerR
      );
      outerGrad.addColorStop(0, rgba(color, (25 * pulse) / 255));
      outerGrad.addColorStop(1, rgba(color, 0));
      ctx!.beginPath();
      ctx!.arc(node.x, node.y, outerR, 0, Math.PI * 2);
      ctx!.fillStyle = outerGrad;
      ctx!.fill();

      // Mid glow
      const midR = node.r * 2.5;
      const midGrad = ctx!.createRadialGradient(
        node.x,
        node.y,
        0,
        node.x,
        node.y,
        midR
      );
      midGrad.addColorStop(0, rgba(color, (50 * pulse) / 255));
      midGrad.addColorStop(1, rgba(color, 0));
      ctx!.beginPath();
      ctx!.arc(node.x, node.y, midR, 0, Math.PI * 2);
      ctx!.fillStyle = midGrad;
      ctx!.fill();

      // Core
      ctx!.beginPath();
      ctx!.arc(node.x, node.y, node.r, 0, Math.PI * 2);
      ctx!.fillStyle = rgba(color, (180 + 75 * pulse) / 255);
      ctx!.fill();

      // Bright center
      ctx!.beginPath();
      ctx!.arc(node.x, node.y, node.r * 0.4, 0, Math.PI * 2);
      ctx!.fillStyle = rgba([255, 255, 255], (80 * pulse) / 255);
      ctx!.fill();
    }

    function updateFighterParticles(fighter: Fighter) {
      // Spawn from random nodes
      for (let i = 0; i < fighter.nodes.length; i++) {
        if (Math.random() < 0.15) {
          const node = fighter.nodes[i];
          fighter.particles.push({
            x: node.x + (Math.random() - 0.5) * 10,
            y: node.y + (Math.random() - 0.5) * 10,
            vx: (Math.random() - 0.5) * 1,
            vy: -(Math.random() * 1.5 + 0.5),
            life: 1.0,
            decay: 0.01 + Math.random() * 0.02,
            size: 1 + Math.random() * 2,
            color: fighter.color,
          });
        }
      }

      // Update & cull
      for (let i = fighter.particles.length - 1; i >= 0; i--) {
        const p = fighter.particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.life -= p.decay;
        if (p.life <= 0) {
          fighter.particles.splice(i, 1);
        }
      }
    }

    function drawParticles(particles: Particle[]) {
      for (const p of particles) {
        ctx!.beginPath();
        ctx!.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx!.fillStyle = rgba(p.color, (p.life * 120) / 255);
        ctx!.fill();
      }
    }

    function updateVsArea() {
      const midX = w * 0.5;
      const midY = h * 0.5;

      // Spawn spark particles
      if (Math.random() < 0.3) {
        const color = Math.random() < 0.5 ? SYNAPSE : COMBAT;
        vsParticles.push({
          x: midX + (Math.random() - 0.5) * 20,
          y: midY + (Math.random() - 0.5) * 20,
          vx: (Math.random() - 0.5) * 2,
          vy: (Math.random() - 0.5) * 2,
          life: 1.0,
          decay: 0.02 + Math.random() * 0.02,
          size: 1 + Math.random() * 1.5,
          color,
        });
      }

      for (let i = vsParticles.length - 1; i >= 0; i--) {
        const p = vsParticles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.life -= p.decay;
        if (p.life <= 0) {
          vsParticles.splice(i, 1);
        }
      }
    }

    function drawVsGlow() {
      const midX = w * 0.5;
      const midY = h * 0.5;
      const pulseR = 40 + 20 * (0.5 + 0.5 * Math.sin(time * 1.8));
      const alpha = (8 + 5 * Math.sin(time * 2.2)) / 255;

      const grad = ctx!.createRadialGradient(
        midX,
        midY,
        0,
        midX,
        midY,
        pulseR
      );
      grad.addColorStop(0, rgba([255, 255, 255], alpha));
      grad.addColorStop(1, rgba([255, 255, 255], 0));
      ctx!.beginPath();
      ctx!.arc(midX, midY, pulseR, 0, Math.PI * 2);
      ctx!.fillStyle = grad;
      ctx!.fill();
    }

    function applyBreathing(fighter: Fighter) {
      const breathOffset = Math.sin(fighter.breathPhase) * 3;
      for (const node of fighter.nodes) {
        node.x = node.baseX;
        node.y = node.baseY + breathOffset;
      }
    }

    // ---- Main draw loop ----

    function draw() {
      ctx!.clearRect(0, 0, w, h);

      // Background paths
      drawBgPaths();

      // Update & draw fighters
      for (const fighter of fighters) {
        if (!prefersReducedMotion) {
          fighter.breathPhase += 0.02;
        }
        applyBreathing(fighter);

        // Connections
        for (let i = 0; i < CONNECTION_PAIRS.length; i++) {
          const [a, b] = CONNECTION_PAIRS[i];
          drawConnection(fighter.nodes[a], fighter.nodes[b], fighter.color, i);
        }

        // Nodes
        for (let i = 0; i < fighter.nodes.length; i++) {
          drawNode(fighter.nodes[i], fighter.color, i);
        }

        // Particles
        if (!prefersReducedMotion) {
          updateFighterParticles(fighter);
        }
        drawParticles(fighter.particles);
      }

      // VS area
      drawVsGlow();
      if (!prefersReducedMotion) {
        updateVsArea();
      }
      drawParticles(vsParticles);

      if (!prefersReducedMotion) {
        time += 0.016; // ~60fps time step
        animationId = requestAnimationFrame(draw);
      }
    }

    window.addEventListener("resize", resize);
    resize();
    draw();

    return () => {
      window.removeEventListener("resize", resize);
      if (animationId) cancelAnimationFrame(animationId);
    };
  }, []);

  return <canvas ref={canvasRef} className="neural-canvas" />;
}
