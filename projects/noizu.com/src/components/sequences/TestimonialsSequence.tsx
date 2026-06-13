"use client";

import { motion, useTransform } from "framer-motion";
import { ScrollSequence } from "@/components/ScrollSequence";
import { useScrollSequence } from "@/components/ScrollSequenceContext";
import { DrawOnPath } from "@/components/DrawOnPath";
import { PcbPad, PcbVia } from "@/components/CircuitComponents";
import { FadeIn, FadeInStagger, FadeInItem } from "@/components/FadeIn";

interface Recommendation {
  feedback: string;
  name: string;
  title: string;
}

/**
 * Testimonials circuit: diagonal ladder topology.
 * Origin bottom-center, splits left and right, climbs upward through rows.
 * Each row has inline components. Unique feel — not a copy of Projects or Services.
 */
function TestimonialCircuitSVG() {
  const progress = useScrollSequence();
  const s1 = { stroke: "rgba(255,202,2,0.4)", strokeWidth: 2, glow: true, glowColor: "rgba(255,202,2,0.1)", glowWidth: 4 };
  const s2 = { stroke: "rgba(255,202,2,0.3)", strokeWidth: 1.5, glow: true, glowColor: "rgba(255,202,2,0.06)", glowWidth: 3 };
  const s3 = { stroke: "rgba(255,202,2,0.2)", strokeWidth: 1.2 };
  const sf = { stroke: "rgba(255,202,2,0.1)", strokeWidth: 0.8 };
  const sc = { stroke: "rgba(255,202,2,0.35)", strokeWidth: 1.5 };

  return (
    <svg viewBox="0 0 1440 900" fill="none" className="absolute inset-0 w-full h-full pointer-events-none" preserveAspectRatio="xMidYMid slice">

      {/* Origin: bottom center */}
      <PcbPad cx={720} cy={850} at={0.08} progress={progress} r={5} />

      {/* Trunk up from origin → T-junction */}
      <DrawOnPath d="M 720 850 L 720 760" progress={progress} startAt={0.08} endAt={0.14} {...s1} />
      {/* C1 inline on vertical */}
      <DrawOnPath d="M 720 760 L 720 753 M 712 753 L 728 753 M 712 747 L 728 747 M 720 747 L 720 740" progress={progress} startAt={0.13} endAt={0.17} {...sc} />
      <DrawOnPath d="M 720 740 L 720 700" progress={progress} startAt={0.16} endAt={0.2} {...s2} />
      <PcbVia cx={720} cy={700} at={0.19} progress={progress} />

      {/* ── LEFT BRANCH: cards 7,4,1 (bottom-up, left side) ── */}
      <DrawOnPath d="M 720 700 L 300 700" progress={progress} startAt={0.2} endAt={0.26} {...s2} />
      {/* R1 inline */}
      <DrawOnPath d="M 500 700 L 494 700 L 491 693 L 485 707 L 479 693 L 473 707 L 470 700 L 462 700" progress={progress} startAt={0.23} endAt={0.27} {...sc} />
      {/* Card 7 (bottom-left) */}
      <DrawOnPath d="M 300 700 L 300 650" progress={progress} startAt={0.26} endAt={0.29} {...s1} />
      <PcbPad cx={300} cy={650} at={0.28} progress={progress} />

      {/* Left spine up → Card 4 */}
      <DrawOnPath d="M 300 700 L 100 700 L 100 440" progress={progress} startAt={0.26} endAt={0.34} {...s3} />
      <PcbVia cx={100} cy={700} at={0.28} progress={progress} />
      {/* R2 on vertical */}
      <DrawOnPath d="M 100 580 L 100 574 L 106 572 L 94 568 L 106 564 L 94 560 L 100 558 L 100 550" progress={progress} startAt={0.3} endAt={0.34} {...sc} />
      <DrawOnPath d="M 100 440 L 300 440" progress={progress} startAt={0.34} endAt={0.38} {...s2} />
      {/* Card 4 (mid-left) */}
      <DrawOnPath d="M 300 440 L 300 400" progress={progress} startAt={0.38} endAt={0.41} {...s1} />
      <PcbPad cx={300} cy={400} at={0.4} progress={progress} />

      {/* Left spine up → Card 1 */}
      <DrawOnPath d="M 100 440 L 100 180 L 300 180" progress={progress} startAt={0.38} endAt={0.48} {...s3} />
      <PcbVia cx={100} cy={440} at={0.37} progress={progress} />
      {/* C2 on vertical */}
      <DrawOnPath d="M 100 320 L 100 313 M 92 313 L 108 313 M 92 307 L 108 307 M 100 307 L 100 300" progress={progress} startAt={0.42} endAt={0.46} {...sc} />
      {/* Card 1 (top-left) */}
      <DrawOnPath d="M 300 180 L 300 140" progress={progress} startAt={0.48} endAt={0.51} {...s1} />
      <PcbPad cx={300} cy={140} at={0.5} progress={progress} />

      {/* ── RIGHT BRANCH: cards 9,6,3 (bottom-up, right side) ── */}
      <DrawOnPath d="M 720 700 L 1140 700" progress={progress} startAt={0.2} endAt={0.26} {...s2} />
      {/* C3 inline */}
      <DrawOnPath d="M 940 700 L 949 700 M 949 692 L 949 708 M 955 692 L 955 708 M 955 700 L 966 700" progress={progress} startAt={0.23} endAt={0.27} {...sc} />
      {/* Card 9 (bottom-right) */}
      <DrawOnPath d="M 1140 700 L 1140 650" progress={progress} startAt={0.26} endAt={0.29} {...s1} />
      <PcbPad cx={1140} cy={650} at={0.28} progress={progress} />

      {/* Right spine up → Card 6 */}
      <DrawOnPath d="M 1140 700 L 1340 700 L 1340 440" progress={progress} startAt={0.26} endAt={0.34} {...s3} />
      <PcbVia cx={1340} cy={700} at={0.28} progress={progress} />
      {/* R3 on vertical */}
      <DrawOnPath d="M 1340 580 L 1340 574 L 1346 572 L 1334 568 L 1346 564 L 1334 560 L 1340 558 L 1340 550" progress={progress} startAt={0.3} endAt={0.34} {...sc} />
      <DrawOnPath d="M 1340 440 L 1140 440" progress={progress} startAt={0.34} endAt={0.38} {...s2} />
      {/* Card 6 (mid-right) */}
      <DrawOnPath d="M 1140 440 L 1140 400" progress={progress} startAt={0.38} endAt={0.41} {...s1} />
      <PcbPad cx={1140} cy={400} at={0.4} progress={progress} />

      {/* Right spine up → Card 3 */}
      <DrawOnPath d="M 1340 440 L 1340 180 L 1140 180" progress={progress} startAt={0.38} endAt={0.48} {...s3} />
      <PcbVia cx={1340} cy={440} at={0.37} progress={progress} />
      {/* IC chip on vertical */}
      <DrawOnPath d="M 1325 310 L 1325 280 L 1355 280 L 1355 310 L 1325 310" progress={progress} startAt={0.42} endAt={0.47} stroke="rgba(255,202,2,0.3)" strokeWidth={1} />
      <DrawOnPath d="M 1318 290 L 1325 290 M 1318 300 L 1325 300 M 1355 290 L 1362 290 M 1355 300 L 1362 300" progress={progress} startAt={0.44} endAt={0.48} stroke="rgba(255,202,2,0.25)" strokeWidth={0.8} />
      {/* Card 3 (top-right) */}
      <DrawOnPath d="M 1140 180 L 1140 140" progress={progress} startAt={0.48} endAt={0.51} {...s1} />
      <PcbPad cx={1140} cy={140} at={0.5} progress={progress} />

      {/* ── CENTER COLUMN: cards 8,5,2 ── */}
      {/* Card 8 from trunk */}
      <DrawOnPath d="M 720 700 L 720 650" progress={progress} startAt={0.2} endAt={0.24} {...s1} />
      <PcbPad cx={720} cy={650} at={0.23} progress={progress} />

      {/* Center up → Card 5 */}
      <DrawOnPath d="M 720 700 L 720 440" progress={progress} startAt={0.24} endAt={0.34} {...s3} />
      {/* R4 on vertical */}
      <DrawOnPath d="M 720 580 L 720 574 L 726 572 L 714 568 L 726 564 L 714 560 L 720 558 L 720 550" progress={progress} startAt={0.28} endAt={0.32} {...sc} />
      <DrawOnPath d="M 720 440 L 720 400" progress={progress} startAt={0.34} endAt={0.37} {...s1} />
      <PcbPad cx={720} cy={400} at={0.36} progress={progress} />

      {/* Center up → Card 2 */}
      <DrawOnPath d="M 720 440 L 720 180" progress={progress} startAt={0.37} endAt={0.47} {...s3} />
      {/* C4 on vertical */}
      <DrawOnPath d="M 720 320 L 720 313 M 712 313 L 728 313 M 712 307 L 728 307 M 720 307 L 720 300" progress={progress} startAt={0.41} endAt={0.45} {...sc} />
      <DrawOnPath d="M 720 180 L 720 140" progress={progress} startAt={0.47} endAt={0.5} {...s1} />
      <PcbPad cx={720} cy={140} at={0.49} progress={progress} />

      {/* ── CROSS-LINKS between columns (faint horizontals) ── */}
      <DrawOnPath d="M 300 400 L 720 400" progress={progress} startAt={0.4} endAt={0.48} {...sf} />
      <DrawOnPath d="M 720 400 L 1140 400" progress={progress} startAt={0.4} endAt={0.48} {...sf} />
      <DrawOnPath d="M 300 140 L 720 140" progress={progress} startAt={0.5} endAt={0.58} {...sf} />
      <DrawOnPath d="M 720 140 L 1140 140" progress={progress} startAt={0.5} endAt={0.58} {...sf} />
      <DrawOnPath d="M 300 650 L 720 650" progress={progress} startAt={0.28} endAt={0.36} {...sf} />
      <DrawOnPath d="M 720 650 L 1140 650" progress={progress} startAt={0.28} endAt={0.36} {...sf} />

      {/* Bottom return loop */}
      <DrawOnPath d="M 100 180 L 100 80 L 1340 80 L 1340 180" progress={progress} startAt={0.48} endAt={0.6} stroke="rgba(255,202,2,0.08)" strokeWidth={0.8} />
      <PcbVia cx={720} cy={80} at={0.54} progress={progress} />
    </svg>
  );
}

function TestimonialCard({ rec }: { rec: Recommendation }) {
  return (
    <div className="glass rounded-2xl p-6 h-full flex flex-col">
      <svg className="w-8 h-8 text-gold-500/30 mb-4 flex-shrink-0" fill="currentColor" viewBox="0 0 32 32">
        <path d="M10 8c-3.3 0-6 2.7-6 6v10h10V14H8c0-1.1.9-2 2-2V8zm14 0c-3.3 0-6 2.7-6 6v10h10V14h-6c0-1.1.9-2 2-2V8z" />
      </svg>
      <p className="text-[0.9375rem] text-zinc-300 leading-relaxed flex-1 mb-6">{rec.feedback}</p>
      <div className="border-t border-white/[0.06] pt-4">
        <p className="text-sm font-semibold text-white">{rec.name}</p>
        <p className="text-xs text-zinc-400 mt-0.5">{rec.title}</p>
      </div>
    </div>
  );
}

function TestimonialCardAnimated({
  rec,
  progress,
  start,
  end,
}: {
  rec: Recommendation;
  progress: ReturnType<typeof useScrollSequence>;
  start: number;
  end: number;
}) {
  const opacity = useTransform(progress, [start, end], [0, 1]);
  const y = useTransform(progress, [start, end], [25, 0]);

  return (
    <motion.div style={{ opacity, y }}>
      <TestimonialCard rec={rec} />
    </motion.div>
  );
}

function TestimonialsContent({ recommendations }: { recommendations: Recommendation[] }) {
  const progress = useScrollSequence();

  // Non-sticky: progress 0=entering viewport, 0.5=centered, 1=leaving
  const headerOpacity = useTransform(progress, [0.1, 0.2], [0, 1]);
  const headerY = useTransform(progress, [0.1, 0.2], [30, 0]);

  const cardSlice = 0.4 / recommendations.length;

  return (
    <div className="relative w-full min-h-screen bg-zinc-950 flex flex-col pb-12">
      {/* Navbar spacer */}
      <div className="h-20 shrink-0" />

      <TestimonialCircuitSVG />

      <div className="relative z-10 flex-1 flex items-center mx-auto max-w-7xl px-6 lg:px-8 w-full">
       <div className="w-full">
        <motion.div style={{ opacity: headerOpacity, y: headerY }} className="text-center max-w-2xl mx-auto mb-10">
          <p className="text-sm font-medium text-gold-400 tracking-wider uppercase mb-2">Testimonials</p>
          <h2 className="text-3xl sm:text-4xl font-bold text-white">What people say</h2>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {recommendations.map((rec, i) => (
            <TestimonialCardAnimated
              key={i}
              rec={rec}
              progress={progress}
              start={0.05 + i * cardSlice}
              end={0.05 + i * cardSlice + cardSlice * 0.75}
            />
          ))}
        </div>
       </div>
      </div>
    </div>
  );
}

function TestimonialsFallback({ recommendations }: { recommendations: Recommendation[] }) {
  return (
    <section id="testimonials" className="py-20 sm:py-28">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <FadeIn className="text-center max-w-2xl mx-auto mb-16">
          <p className="text-sm font-medium text-gold-400 tracking-wider uppercase mb-2">Testimonials</p>
          <h2 className="text-3xl sm:text-4xl font-bold text-white">What people say</h2>
        </FadeIn>
        <FadeInStagger className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {recommendations.map((rec, idx) => (
            <FadeInItem key={idx}>
              <TestimonialCard rec={rec} />
            </FadeInItem>
          ))}
        </FadeInStagger>
      </div>
    </section>
  );
}

export function TestimonialsSequence({ recommendations, zIndex }: { recommendations: Recommendation[]; zIndex?: number }) {
  return (
    <ScrollSequence
      scrollHeight="200vh"
      sticky={false}
      fallback={<TestimonialsFallback recommendations={recommendations} />}
      id="testimonials"
      zIndex={zIndex}
    >
      <TestimonialsContent recommendations={recommendations} />
    </ScrollSequence>
  );
}
