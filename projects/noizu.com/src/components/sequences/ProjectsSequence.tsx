"use client";

/* eslint-disable @next/next/no-img-element */
import { motion, useTransform } from "framer-motion";
import { ScrollSequence } from "@/components/ScrollSequence";
import { useScrollSequence } from "@/components/ScrollSequenceContext";
import { DrawOnPath } from "@/components/DrawOnPath";
import { PcbPad, PcbVia } from "@/components/CircuitComponents";
import { TiltCard } from "@/components/TiltCard";
import { MouseLightCard } from "@/components/MouseLightCard";
import { FadeIn, FadeInStagger, FadeInItem } from "@/components/FadeIn";

interface Project {
  name: string;
  description: string;
  tags: string[];
  href: string;
}

function ProjectCard({ project }: { project: Project }) {
  return (
    <TiltCard className="h-full">
      <MouseLightCard className="glass glass-hover rounded-2xl h-full">
        <a
          href={project.href}
          target="_blank"
          rel="noopener noreferrer"
          className="block p-6 h-full group"
        >
          <div className="flex items-start justify-between mb-3">
            <h3 className="text-lg font-semibold text-white group-hover:text-gold-400 transition-colors">
              {project.name}
            </h3>
            <svg
              className="w-5 h-5 text-zinc-600 group-hover:text-gold-400 transition-colors flex-shrink-0 mt-0.5"
              fill="none"
              viewBox="0 0 24 24"
              strokeWidth={1.5}
              stroke="currentColor"
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 19.5l15-15m0 0H8.25m11.25 0v11.25" />
            </svg>
          </div>
          <p className="text-sm text-zinc-300 mb-4 leading-relaxed">{project.description}</p>
          <div className="flex flex-wrap gap-2">
            {project.tags.map((tag) => (
              <span
                key={tag}
                className="text-xs px-2.5 py-1 rounded-full bg-gold-500/10 text-gold-400 border border-gold-500/20"
              >
                {tag}
              </span>
            ))}
          </div>
        </a>
      </MouseLightCard>
    </TiltCard>
  );
}


/** IC chip — outline draws on scroll, then pins draw */
function IcChip({ x, y, w, h, at, progress }: {
  x: number; y: number; w: number; h: number; at: number;
  progress: ReturnType<typeof useScrollSequence>;
}) {
  const pins = Math.floor(h / 12);
  const chipOutline = `M ${x} ${y + 2} L ${x} ${y + h - 2} Q ${x} ${y + h} ${x + 2} ${y + h} L ${x + w - 2} ${y + h} Q ${x + w} ${y + h} ${x + w} ${y + h - 2} L ${x + w} ${y + 2} Q ${x + w} ${y} ${x + w - 2} ${y} L ${x + 2} ${y} Q ${x} ${y} ${x} ${y + 2}`;
  // All pins as one continuous path
  const pinPaths = Array.from({ length: pins }).map((_, i) => {
    const py = y + 8 + i * 12;
    return `M ${x - 8} ${py} L ${x} ${py} M ${x + w} ${py} L ${x + w + 8} ${py}`;
  }).join(' ');

  return (
    <g>
      <DrawOnPath d={chipOutline} progress={progress} startAt={at} endAt={at + 0.1}
        stroke="rgba(255,202,2,0.35)" strokeWidth={1} glow glowColor="rgba(255,202,2,0.1)" glowWidth={3} />
      <DrawOnPath d={pinPaths} progress={progress} startAt={at + 0.05} endAt={at + 0.12}
        stroke="rgba(255,202,2,0.25)" strokeWidth={0.8} />
      <PcbVia cx={x + 6} cy={y + 6} at={at + 0.08} progress={progress} />
    </g>
  );
}

/** AND gate — 2 inputs left, 1 output right, draws on scroll */
function AndGate({ x, y, at, progress }: {
  x: number; y: number; at: number;
  progress: ReturnType<typeof useScrollSequence>;
}) {
  // Two input leads + body + output lead — all as one path
  // Inputs at (x-10, y-4) and (x-10, y+4), output at (x+18, y)
  const d = [
    `M ${x - 10} ${y - 4} L ${x} ${y - 4}`,  // input 1
    `M ${x - 10} ${y + 4} L ${x} ${y + 4}`,  // input 2
    `M ${x} ${y - 7} L ${x} ${y + 7} L ${x + 7} ${y + 7} A 7 7 0 0 0 ${x + 7} ${y - 7} Z`, // body
    `M ${x + 14} ${y} L ${x + 22} ${y}`,      // output
  ].join(' ');

  return (
    <DrawOnPath d={d} progress={progress} startAt={at} endAt={at + 0.08}
      stroke="rgba(255,202,2,0.4)" strokeWidth={1} glow glowColor="rgba(255,202,2,0.1)" glowWidth={3} />
  );
}

/** OR gate — 2 inputs left, 1 output right, draws on scroll */
function OrGate({ x, y, at, progress }: {
  x: number; y: number; at: number;
  progress: ReturnType<typeof useScrollSequence>;
}) {
  const d = [
    `M ${x - 10} ${y - 4} L ${x + 1} ${y - 4}`,   // input 1
    `M ${x - 10} ${y + 4} L ${x + 1} ${y + 4}`,   // input 2
    `M ${x - 2} ${y - 7} Q ${x + 3} ${y} ${x - 2} ${y + 7}`, // back curve
    `M ${x - 2} ${y + 7} Q ${x + 10} ${y + 7} ${x + 15} ${y}`, // bottom
    `Q ${x + 10} ${y - 7} ${x - 2} ${y - 7}`,       // top
    `M ${x + 15} ${y} L ${x + 22} ${y}`,             // output
  ].join(' ');

  return (
    <DrawOnPath d={d} progress={progress} startAt={at} endAt={at + 0.08}
      stroke="rgba(255,202,2,0.4)" strokeWidth={1} glow glowColor="rgba(255,202,2,0.1)" glowWidth={3} />
  );
}

/** NOT gate (triangle + bubble) — 1 input, 1 output */
function NotGate({ x, y, at, progress }: {
  x: number; y: number; at: number;
  progress: ReturnType<typeof useScrollSequence>;
}) {
  const d = [
    `M ${x - 8} ${y} L ${x} ${y}`,                   // input
    `M ${x} ${y - 6} L ${x + 10} ${y} L ${x} ${y + 6} Z`, // triangle
    `M ${x + 12} ${y} L ${x + 20} ${y}`,             // output (past bubble)
  ].join(' ');

  return (
    <g>
      <DrawOnPath d={d} progress={progress} startAt={at} endAt={at + 0.06}
        stroke="rgba(255,202,2,0.4)" strokeWidth={1} glow glowColor="rgba(255,202,2,0.1)" glowWidth={3} />
    </g>
  );
}

/** Resistor — zig-zag draws on scroll */
function Resistor({ x, y, at, progress, vertical = false }: {
  x: number; y: number; at: number; vertical?: boolean;
  progress: ReturnType<typeof useScrollSequence>;
}) {
  const d = vertical
    ? `M ${x} ${y - 14} L ${x} ${y - 8} L ${x + 5} ${y - 6} L ${x - 5} ${y - 2} L ${x + 5} ${y + 2} L ${x - 5} ${y + 6} L ${x} ${y + 8} L ${x} ${y + 14}`
    : `M ${x - 14} ${y} L ${x - 8} ${y} L ${x - 6} ${y - 5} L ${x - 2} ${y + 5} L ${x + 2} ${y - 5} L ${x + 6} ${y + 5} L ${x + 8} ${y} L ${x + 14} ${y}`;

  return (
    <DrawOnPath d={d} progress={progress} startAt={at} endAt={at + 0.08}
      stroke="rgba(255,202,2,0.35)" strokeWidth={1} glow glowColor="rgba(255,202,2,0.08)" glowWidth={3} />
  );
}

/** Capacitor — two parallel lines draw on scroll */
function Capacitor({ x, y, at, progress, vertical = false }: {
  x: number; y: number; at: number; vertical?: boolean;
  progress: ReturnType<typeof useScrollSequence>;
}) {
  const d = vertical
    ? `M ${x} ${y - 12} L ${x} ${y - 3} M ${x - 6} ${y - 3} L ${x + 6} ${y - 3} M ${x - 6} ${y + 3} L ${x + 6} ${y + 3} M ${x} ${y + 3} L ${x} ${y + 12}`
    : `M ${x - 12} ${y} L ${x - 3} ${y} M ${x - 3} ${y - 6} L ${x - 3} ${y + 6} M ${x + 3} ${y - 6} L ${x + 3} ${y + 6} M ${x + 3} ${y} L ${x + 12} ${y}`;

  return (
    <DrawOnPath d={d} progress={progress} startAt={at} endAt={at + 0.06}
      stroke="rgba(255,202,2,0.35)" strokeWidth={1} glow glowColor="rgba(255,202,2,0.08)" glowWidth={3} />
  );
}

/**
 * Hand-crafted circuit board matching design/circuit-board-preview.html.
 * Single connected flow from origin, all traces connect, components inline.
 */
function CircuitBoardSVG() {
  const progress = useScrollSequence();

  // Stroke shorthand
  const s1 = { stroke: "rgba(255,202,2,0.45)", strokeWidth: 2, glow: true, glowColor: "rgba(255,202,2,0.12)", glowWidth: 4 };
  const s2 = { stroke: "rgba(255,202,2,0.35)", strokeWidth: 1.8, glow: true, glowColor: "rgba(255,202,2,0.08)", glowWidth: 3 };
  const s3 = { stroke: "rgba(255,202,2,0.25)", strokeWidth: 1.5 };
  const s4 = { stroke: "rgba(255,202,2,0.2)", strokeWidth: 1 };
  const sf = { stroke: "rgba(255,202,2,0.12)", strokeWidth: 1 }; // faint through-card traces
  const sComp = { stroke: "rgba(255,202,2,0.4)", strokeWidth: 1.8 }; // component inline

  return (
    <svg viewBox="0 0 1440 900" fill="none" className="absolute inset-0 w-full h-full pointer-events-none" preserveAspectRatio="xMidYMid slice">

      {/* ── ORIGIN PAD ── */}
      <PcbPad cx={40} cy={70} at={0} progress={progress} r={6} />

      {/* ── 1. ORIGIN → R1 → T-junction (440,70) ── */}
      <DrawOnPath d="M 40 70 L 76 70" progress={progress} startAt={0} endAt={0.03} {...s1} />
      <DrawOnPath d="M 76 70 L 82 70 L 85 63 L 91 77 L 97 63 L 103 77 L 109 63 L 112 70 L 120 70" progress={progress} startAt={0.02} endAt={0.06} {...sComp} />
      <DrawOnPath d="M 120 70 L 440 70" progress={progress} startAt={0.05} endAt={0.1} {...s1} />
      <PcbVia cx={440} cy={70} at={0.09} progress={progress} />

      {/* ── FORK A: right → C1 → IC → right spine ── */}
      <DrawOnPath d="M 440 70 L 600 70" progress={progress} startAt={0.1} endAt={0.14} {...s2} />
      {/* C1 */}
      <DrawOnPath d="M 600 70 L 609 70 M 609 62 L 609 78 M 615 62 L 615 78 M 615 70 L 626 70" progress={progress} startAt={0.13} endAt={0.16} {...sComp} />
      <DrawOnPath d="M 626 70 L 880 70" progress={progress} startAt={0.15} endAt={0.2} {...s3} />

      {/* IC chip inline */}
      <DrawOnPath d="M 880 55 L 880 85 L 920 85 L 920 55 L 880 55" progress={progress} startAt={0.18} endAt={0.24} stroke="rgba(255,202,2,0.35)" strokeWidth={1.2} />
      {/* IC pins */}
      <DrawOnPath d="M 872 63 L 880 63 M 872 70 L 880 70 M 872 77 L 880 77 M 920 63 L 928 63 M 920 70 L 928 70 M 920 77 L 928 77" progress={progress} startAt={0.2} endAt={0.25} stroke="rgba(255,202,2,0.3)" strokeWidth={1.2} />
      {/* IC left pin 1 → up stub */}
      <DrawOnPath d="M 872 63 L 860 63 L 860 40 L 700 40" progress={progress} startAt={0.22} endAt={0.28} stroke="rgba(255,202,2,0.15)" strokeWidth={1} />
      {/* IC left pin 3 → stub with terminator */}
      <DrawOnPath d="M 872 77 L 860 77 L 860 100" progress={progress} startAt={0.22} endAt={0.26} stroke="rgba(255,202,2,0.15)" strokeWidth={1} />
      <PcbVia cx={860} cy={100} at={0.25} progress={progress} />

      {/* IC right pin 2 → main trunk right → right spine */}
      <DrawOnPath d="M 928 70 L 1300 70 L 1300 250" progress={progress} startAt={0.24} endAt={0.32} {...s3} />
      {/* IC right pin 1 → Card 2 area */}
      <DrawOnPath d="M 928 63 L 1000 63 L 1000 250 L 760 250" progress={progress} startAt={0.24} endAt={0.32} {...s4} />
      <PcbPad cx={760} cy={250} at={0.31} progress={progress} />
      <PcbVia cx={1300} cy={250} at={0.31} progress={progress} />

      {/* ── RIGHT SPINE: Card 2 → R2 → Card 4 → OR → Card 6 ── */}
      <DrawOnPath d="M 1300 250 L 1240 250" progress={progress} startAt={0.32} endAt={0.35} {...s1} />
      <PcbPad cx={1240} cy={250} at={0.34} progress={progress} />
      {/* Through Card 2 → center */}
      <DrawOnPath d="M 1240 250 L 1240 290 L 700 290" progress={progress} startAt={0.35} endAt={0.4} {...sf} />

      <DrawOnPath d="M 1300 250 L 1300 400" progress={progress} startAt={0.34} endAt={0.4} {...s3} />
      {/* R2 inline */}
      <DrawOnPath d="M 1300 400 L 1300 406 L 1306 408 L 1294 412 L 1306 416 L 1294 420 L 1306 424 L 1300 426 L 1300 435" progress={progress} startAt={0.39} endAt={0.44} {...sComp} />
      <DrawOnPath d="M 1300 435 L 1300 450 L 1240 450" progress={progress} startAt={0.43} endAt={0.47} {...s1} />
      <PcbPad cx={1240} cy={450} at={0.46} progress={progress} />
      {/* Through Card 4 → center */}
      <DrawOnPath d="M 1240 450 L 1240 480 L 700 480" progress={progress} startAt={0.47} endAt={0.52} {...sf} />

      {/* Right spine → OR gate */}
      <DrawOnPath d="M 1300 450 L 1300 640" progress={progress} startAt={0.47} endAt={0.55} {...s4} />
      {/* OR input 1 from spine */}
      <DrawOnPath d="M 1300 640 L 1235 640" progress={progress} startAt={0.55} endAt={0.58} {...s2} />
      {/* OR input 2 from NOT gate below (separate wire) */}
      <DrawOnPath d="M 1300 660 L 1235 660" progress={progress} startAt={0.72} endAt={0.75} {...s2} />
      {/* OR gate body */}
      <DrawOnPath d="M 1240 630 L 1240 670" progress={progress} startAt={0.57} endAt={0.6} stroke="rgba(255,202,2,0.4)" strokeWidth={1.5} />
      <DrawOnPath d="M 1240 670 Q 1222 670 1208 650 Q 1222 630 1240 630" progress={progress} startAt={0.58} endAt={0.62} stroke="rgba(255,202,2,0.4)" strokeWidth={1.5} />
      <DrawOnPath d="M 1240 630 Q 1232 650 1240 670" progress={progress} startAt={0.59} endAt={0.62} stroke="rgba(255,202,2,0.3)" strokeWidth={1.2} />
      {/* OR output → Card 6 */}
      <DrawOnPath d="M 1208 650 L 1160 650" progress={progress} startAt={0.62} endAt={0.65} {...s1} />
      <PcbPad cx={1160} cy={650} at={0.64} progress={progress} />
      {/* Through Card 6 → center */}
      <DrawOnPath d="M 1160 650 L 1160 680 L 700 680" progress={progress} startAt={0.65} endAt={0.7} {...sf} />

      {/* ── FORK B: down from T-junction → left side → cards 1,3,5 ── */}
      <DrawOnPath d="M 440 70 L 440 140 L 160 140 L 160 250" progress={progress} startAt={0.1} endAt={0.18} {...s2} />
      <PcbVia cx={160} cy={140} at={0.15} progress={progress} />

      {/* Card 1 */}
      <DrawOnPath d="M 160 250 L 200 250" progress={progress} startAt={0.18} endAt={0.2} {...s1} />
      <PcbPad cx={200} cy={250} at={0.19} progress={progress} />
      {/* Through Card 1 → center */}
      <DrawOnPath d="M 200 250 L 200 280 L 700 280" progress={progress} startAt={0.2} endAt={0.26} {...sf} />

      {/* Left spine down through R3 */}
      <DrawOnPath d="M 160 250 L 160 380" progress={progress} startAt={0.2} endAt={0.28} {...s3} />
      {/* R3 */}
      <DrawOnPath d="M 160 380 L 160 386 L 166 388 L 154 392 L 166 396 L 154 400 L 166 404 L 160 406 L 160 420" progress={progress} startAt={0.27} endAt={0.32} {...sComp} />
      <DrawOnPath d="M 160 420 L 160 460" progress={progress} startAt={0.31} endAt={0.35} {...s3} />

      {/* Through Card 3 → from AND output pad → center */}
      <DrawOnPath d="M 300 480 L 700 480" progress={progress} startAt={0.44} endAt={0.5} {...sf} />
      <DrawOnPath d="M 300 480 L 300 435 L 700 435" progress={progress} startAt={0.44} endAt={0.5} stroke="rgba(255,202,2,0.1)" strokeWidth={0.8} />

      {/* AND GATE: input 1 from spine, input 2 from IC pin 3 long trace */}
      <DrawOnPath d="M 160 460 L 160 473 L 225 473" progress={progress} startAt={0.35} endAt={0.39} {...s2} />
      {/* Input 2: IC right pin 3 → long route left and down → into gate */}
      <DrawOnPath d="M 928 77 L 928 260 L 100 260 L 100 487 L 225 487" progress={progress} startAt={0.24} endAt={0.39} {...s4} />
      {/* AND body */}
      <DrawOnPath d="M 220 460 L 220 500 L 238 500 A 20 20 0 0 0 238 460 Z" progress={progress} startAt={0.38} endAt={0.42} stroke="rgba(255,202,2,0.4)" strokeWidth={1.5} />
      {/* AND output → Card 3 */}
      <DrawOnPath d="M 258 480 L 300 480" progress={progress} startAt={0.42} endAt={0.44} {...s1} />
      <PcbPad cx={300} cy={480} at={0.43} progress={progress} />

      {/* AND output fork → C2 → Card 5 */}
      <DrawOnPath d="M 300 480 L 300 530 L 80 530 L 80 590" progress={progress} startAt={0.44} endAt={0.5} {...s3} />
      {/* C2 */}
      <DrawOnPath d="M 80 590 L 80 597 M 72 597 L 88 597 M 72 603 L 88 603 M 80 603 L 80 610" progress={progress} startAt={0.49} endAt={0.53} {...sComp} />
      <DrawOnPath d="M 80 610 L 80 650 L 200 650" progress={progress} startAt={0.52} endAt={0.56} {...s1} />
      <PcbPad cx={200} cy={650} at={0.55} progress={progress} />
      {/* Through Card 5 → center */}
      <DrawOnPath d="M 200 650 L 200 670 L 700 670" progress={progress} startAt={0.56} endAt={0.62} {...sf} />

      {/* ── CENTER LINK: → NOT gate → feeds OR 2nd input ── */}
      <DrawOnPath d="M 700 670 L 700 700 L 710 700" progress={progress} startAt={0.62} endAt={0.66} {...s4} />
      {/* NOT body */}
      <DrawOnPath d="M 710 693 L 724 700 L 710 707 Z" progress={progress} startAt={0.65} endAt={0.68} stroke="rgba(255,202,2,0.4)" strokeWidth={1.2} />
      <DrawOnPath d="M 730 700 L 1300 700 L 1300 660" progress={progress} startAt={0.68} endAt={0.75} {...s3} />

      {/* ── BOTTOM RETURN ── */}
      <DrawOnPath d="M 80 650 L 80 830 L 280 830" progress={progress} startAt={0.56} endAt={0.64} stroke="rgba(255,202,2,0.15)" strokeWidth={1.2} />
      {/* R4 */}
      <DrawOnPath d="M 280 830 L 286 830 L 288 823 L 294 837 L 300 823 L 306 837 L 312 823 L 314 830 L 330 830" progress={progress} startAt={0.63} endAt={0.68} stroke="rgba(255,202,2,0.25)" strokeWidth={1.2} />
      <DrawOnPath d="M 330 830 L 680 830" progress={progress} startAt={0.67} endAt={0.73} stroke="rgba(255,202,2,0.15)" strokeWidth={1.2} />
      {/* C3 */}
      <DrawOnPath d="M 680 830 L 689 830 M 689 823 L 689 837 M 695 823 L 695 837 M 695 830 L 710 830" progress={progress} startAt={0.72} endAt={0.76} stroke="rgba(255,202,2,0.25)" strokeWidth={1.2} />
      <DrawOnPath d="M 710 830 L 1300 830 L 1300 700" progress={progress} startAt={0.75} endAt={0.82} stroke="rgba(255,202,2,0.15)" strokeWidth={1.2} />
      <PcbPad cx={1300} cy={830} at={0.8} progress={progress} />

      {/* ── CENTER VERTICAL ── */}
      <DrawOnPath d="M 700 40 L 700 700" progress={progress} startAt={0.05} endAt={0.65} stroke="rgba(255,202,2,0.1)" strokeWidth={1} />
      <PcbVia cx={700} cy={280} at={0.24} progress={progress} />
      <PcbVia cx={700} cy={290} at={0.38} progress={progress} />
      <PcbVia cx={700} cy={435} at={0.48} progress={progress} />
      <PcbVia cx={700} cy={480} at={0.5} progress={progress} />
      <PcbVia cx={700} cy={670} at={0.6} progress={progress} />
      <PcbVia cx={700} cy={680} at={0.68} progress={progress} />
    </svg>
  );
}

function ProjectsContent({ projects }: { projects: Project[] }) {
  const progress = useScrollSequence();

  const labelOpacity = useTransform(progress, [0, 0.05], [0, 1]);
  const labelY = useTransform(progress, [0, 0.05], [20, 0]);

  // Circuit traces parallax background
  const bgY = useTransform(progress, [0, 1], ["0%", "12%"]);
  const bgOpacity = useTransform(progress, [0, 0.1, 0.7, 1], [0.1, 0.2, 0.15, 0.05]);

  const cardSlice = 0.7 / projects.length;

  return (
    <div
      className="relative w-full min-h-screen flex flex-col pb-12"
      style={{ background: "rgb(9,9,11)" }}
    >
      {/* Navbar spacer */}
      <div className="h-20 shrink-0" />

      {/* Circuit traces parallax background */}
      <motion.div
        style={{ y: bgY, opacity: bgOpacity }}
        className="absolute -inset-y-[12%] inset-x-0 pointer-events-none"
      >
        <img
          src="/images/screen-overlay-circuit-traces.png"
          alt=""
          className="w-full h-full object-cover"
          style={{
            filter: "saturate(0.5) sepia(0.15) brightness(0.35) contrast(1.1)",
            maskImage: "linear-gradient(to bottom, black 40%, transparent 90%)",
            WebkitMaskImage: "linear-gradient(to bottom, black 40%, transparent 90%)",
          }}
        />
      </motion.div>

      {/* Zig-zag circuit traces leading to cards */}
      <CircuitBoardSVG />

      <div className="relative z-10 flex-1 flex items-center mx-auto max-w-7xl px-6 lg:px-8 w-full">
       <div className="w-full">
        <motion.div style={{ opacity: labelOpacity, y: labelY }} className="mb-12">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gold-400 tracking-wider uppercase mb-2">
                Open Source
              </p>
              <h2 className="text-3xl sm:text-4xl font-bold text-white">Featured Projects</h2>
            </div>
            <a
              href="/projects"
              className="hidden sm:flex items-center gap-2 text-sm text-zinc-400 hover:text-white transition-colors"
            >
              View all projects
              <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
              </svg>
            </a>
          </div>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {projects.map((project, i) => {
            const start = 0.05 + i * cardSlice;
            const end = start + cardSlice * 0.7;
            return (
              <ProjectCardAnimated key={project.name} project={project} progress={progress} start={start} end={end} />
            );
          })}
        </div>
       </div>
      </div>

      <div className="absolute bottom-0 inset-x-0 h-[10vh] bg-gradient-to-b from-transparent to-zinc-950 z-[5] pointer-events-none" />
    </div>
  );
}

function ProjectCardAnimated({
  project,
  progress,
  start,
  end,
}: {
  project: Project;
  progress: ReturnType<typeof useScrollSequence>;
  start: number;
  end: number;
}) {
  const opacity = useTransform(progress, [start, end], [0, 1]);
  const y = useTransform(progress, [start, end], [30, 0]);

  return (
    <motion.div style={{ opacity, y }}>
      <ProjectCard project={project} />
    </motion.div>
  );
}

function ProjectsFallback({ projects }: { projects: Project[] }) {
  return (
    <section className="py-20 sm:py-28">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <FadeIn>
          <div className="flex items-center justify-between mb-12">
            <div>
              <p className="text-sm font-medium text-gold-400 tracking-wider uppercase mb-2">Open Source</p>
              <h2 className="text-3xl sm:text-4xl font-bold text-white">Featured Projects</h2>
            </div>
          </div>
        </FadeIn>
        <FadeInStagger className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {projects.map((project) => (
            <FadeInItem key={project.name}>
              <ProjectCard project={project} />
            </FadeInItem>
          ))}
        </FadeInStagger>
      </div>
    </section>
  );
}

export function ProjectsSequence({ projects, zIndex }: { projects: Project[]; zIndex?: number }) {
  return (
    <ScrollSequence
      scrollHeight="130vh"
      fallback={<ProjectsFallback projects={projects} />}
      zIndex={zIndex}
    >
      <ProjectsContent projects={projects} />
    </ScrollSequence>
  );
}
