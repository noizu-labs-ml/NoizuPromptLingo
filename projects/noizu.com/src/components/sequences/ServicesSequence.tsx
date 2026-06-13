"use client";

import { ReactNode } from "react";
import { motion, useTransform } from "framer-motion";
import { ScrollSequence } from "@/components/ScrollSequence";
import { useScrollSequence } from "@/components/ScrollSequenceContext";
import { DrawOnPath } from "@/components/DrawOnPath";
import { PcbPad, PcbVia } from "@/components/CircuitComponents";
import { MouseLightCard } from "@/components/MouseLightCard";
import { FadeIn, FadeInStagger, FadeInItem } from "@/components/FadeIn";

interface Service {
  title: string;
  icon: ReactNode;
  items: string[];
}

/**
 * Services circuit: serpentine path flowing right-left-right across the section.
 * Origin top-right, snakes through resistors/capacitors, branches to card positions.
 */
function ServiceCircuitSVG() {
  const progress = useScrollSequence();
  const s1 = { stroke: "rgba(255,202,2,0.4)", strokeWidth: 2, glow: true, glowColor: "rgba(255,202,2,0.1)", glowWidth: 4 };
  const s2 = { stroke: "rgba(255,202,2,0.3)", strokeWidth: 1.5, glow: true, glowColor: "rgba(255,202,2,0.06)", glowWidth: 3 };
  const s3 = { stroke: "rgba(255,202,2,0.2)", strokeWidth: 1.2 };
  const sf = { stroke: "rgba(255,202,2,0.1)", strokeWidth: 0.8 };
  const sc = { stroke: "rgba(255,202,2,0.35)", strokeWidth: 1.5 };

  return (
    <svg viewBox="0 0 1440 900" fill="none" className="absolute inset-0 w-full h-full pointer-events-none" preserveAspectRatio="xMidYMid slice">
      {/* Origin top-right */}
      <PcbPad cx={1400} cy={60} at={0.08} progress={progress} r={5} />

      {/* Row 1: RIGHT → LEFT through R1 → C1 → branches to cards 1-4 */}
      <DrawOnPath d="M 1400 60 L 1100 60" progress={progress} startAt={0.08} endAt={0.14} {...s1} />
      <DrawOnPath d="M 1100 60 L 1094 60 L 1091 53 L 1085 67 L 1079 53 L 1073 67 L 1070 60 L 1060 60" progress={progress} startAt={0.13} endAt={0.17} {...sc} />
      <DrawOnPath d="M 1060 60 L 600 60" progress={progress} startAt={0.16} endAt={0.22} {...s2} />
      <DrawOnPath d="M 600 60 L 591 60 M 591 52 L 591 68 M 585 52 L 585 68 M 585 60 L 574 60" progress={progress} startAt={0.21} endAt={0.25} {...sc} />
      <DrawOnPath d="M 574 60 L 60 60" progress={progress} startAt={0.24} endAt={0.3} {...s2} />
      <PcbVia cx={60} cy={60} at={0.29} progress={progress} />

      {/* Drop branches to row 1 cards (top row of 4) */}
      <DrawOnPath d="M 300 60 L 300 200" progress={progress} startAt={0.26} endAt={0.32} {...s3} />
      <PcbPad cx={300} cy={200} at={0.31} progress={progress} />
      <DrawOnPath d="M 600 60 L 600 200" progress={progress} startAt={0.22} endAt={0.28} {...s3} />
      <PcbPad cx={600} cy={200} at={0.27} progress={progress} />
      <DrawOnPath d="M 900 60 L 900 200" progress={progress} startAt={0.18} endAt={0.24} {...s3} />
      <PcbPad cx={900} cy={200} at={0.23} progress={progress} />
      <DrawOnPath d="M 1200 60 L 1200 200" progress={progress} startAt={0.14} endAt={0.2} {...s3} />
      <PcbPad cx={1200} cy={200} at={0.19} progress={progress} />

      {/* Turn 1: left edge drops down */}
      <DrawOnPath d="M 60 60 L 60 420" progress={progress} startAt={0.3} endAt={0.4} {...s3} />
      {/* R2 on vertical */}
      <DrawOnPath d="M 60 230 L 60 236 L 66 238 L 54 242 L 66 246 L 54 250 L 60 252 L 60 260" progress={progress} startAt={0.33} endAt={0.37} {...sc} />

      {/* Row 2: LEFT → RIGHT through IC → branches to cards 5-8 */}
      <DrawOnPath d="M 60 420 L 400 420" progress={progress} startAt={0.4} endAt={0.46} {...s2} />
      {/* IC chip inline */}
      <DrawOnPath d="M 400 408 L 400 432 L 435 432 L 435 408 L 400 408" progress={progress} startAt={0.44} endAt={0.49} stroke="rgba(255,202,2,0.3)" strokeWidth={1.2} />
      <DrawOnPath d="M 393 415 L 400 415 M 393 420 L 400 420 M 393 425 L 400 425 M 435 415 L 442 415 M 435 420 L 442 420 M 435 425 L 442 425" progress={progress} startAt={0.46} endAt={0.5} stroke="rgba(255,202,2,0.25)" strokeWidth={1} />
      <DrawOnPath d="M 442 420 L 700 420" progress={progress} startAt={0.49} endAt={0.54} {...s2} />
      {/* C2 inline */}
      <DrawOnPath d="M 700 420 L 709 420 M 709 412 L 709 428 M 715 412 L 715 428 M 715 420 L 726 420" progress={progress} startAt={0.53} endAt={0.57} {...sc} />
      <DrawOnPath d="M 726 420 L 1400 420" progress={progress} startAt={0.56} endAt={0.64} {...s2} />
      <PcbVia cx={1400} cy={420} at={0.63} progress={progress} />

      {/* Drop branches to row 2 cards (bottom row of 4) */}
      <DrawOnPath d="M 300 420 L 300 560" progress={progress} startAt={0.44} endAt={0.5} {...s3} />
      <PcbPad cx={300} cy={560} at={0.49} progress={progress} />
      <DrawOnPath d="M 600 420 L 600 560" progress={progress} startAt={0.5} endAt={0.56} {...s3} />
      <PcbPad cx={600} cy={560} at={0.55} progress={progress} />
      <DrawOnPath d="M 900 420 L 900 560" progress={progress} startAt={0.54} endAt={0.6} {...s3} />
      <PcbPad cx={900} cy={560} at={0.59} progress={progress} />
      <DrawOnPath d="M 1200 420 L 1200 560" progress={progress} startAt={0.58} endAt={0.64} {...s3} />
      <PcbPad cx={1200} cy={560} at={0.63} progress={progress} />

      {/* Bottom return: right edge → down → left across bottom → R3 → C3 → back to left */}
      <DrawOnPath d="M 1400 420 L 1400 750 L 1100 750" progress={progress} startAt={0.64} endAt={0.72} {...sf} />
      <DrawOnPath d="M 1100 750 L 1094 750 L 1091 743 L 1085 757 L 1079 743 L 1073 757 L 1070 750 L 1060 750" progress={progress} startAt={0.71} endAt={0.75} stroke="rgba(255,202,2,0.2)" strokeWidth={1} />
      <DrawOnPath d="M 1060 750 L 740 750" progress={progress} startAt={0.74} endAt={0.78} {...sf} />
      <DrawOnPath d="M 740 750 L 731 750 M 731 743 L 731 757 M 725 743 L 725 757 M 725 750 L 714 750" progress={progress} startAt={0.77} endAt={0.8} stroke="rgba(255,202,2,0.2)" strokeWidth={1} />
      <DrawOnPath d="M 714 750 L 60 750 L 60 420" progress={progress} startAt={0.79} endAt={0.88} {...sf} />
      <PcbPad cx={60} cy={750} at={0.85} progress={progress} r={4} />

      {/* Faint verticals connecting rows */}
      <DrawOnPath d="M 720 60 L 720 750" progress={progress} startAt={0.12} endAt={0.7} stroke="rgba(255,202,2,0.06)" strokeWidth={0.6} />
    </svg>
  );
}

function ServiceCard({ service }: { service: Service }) {
  return (
    <MouseLightCard className="glass rounded-2xl h-full">
      <div className="p-6 h-full">
        <div className="w-10 h-10 rounded-xl bg-gold-600/10 border border-gold-500/20 flex items-center justify-center text-gold-400 mb-4">
          {service.icon}
        </div>
        <h3 className="text-base font-semibold text-white mb-3">{service.title}</h3>
        <ul className="space-y-2">
          {service.items.map((item, idx) => (
            <li key={idx} className="text-sm text-zinc-300/80 flex items-start gap-2">
              <span className="text-gold-500 mt-1.5 flex-shrink-0">
                <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 8 8">
                  <circle cx="4" cy="4" r="1.5" />
                </svg>
              </span>
              {item}
            </li>
          ))}
        </ul>
      </div>
    </MouseLightCard>
  );
}

function ServicesContent({ services }: { services: Service[] }) {
  const progress = useScrollSequence();

  // Non-sticky: progress 0=entering viewport, 0.5=centered, 1=leaving
  const headerOpacity = useTransform(progress, [0.1, 0.2], [0, 1]);
  const headerY = useTransform(progress, [0.1, 0.2], [30, 0]);

  const cardSlice = 0.4 / services.length;

  return (
    <div
      className="relative w-full min-h-screen flex flex-col pb-12"
      style={{ background: "rgb(9,9,11)" }}
    >
      {/* Navbar spacer */}
      <div className="h-20 shrink-0" />

      <ServiceCircuitSVG />

      <div className="relative z-10 flex-1 flex items-center mx-auto max-w-7xl px-6 lg:px-8 w-full">
       <div className="w-full">
        <motion.div style={{ opacity: headerOpacity, y: headerY }} className="max-w-2xl mb-10">
          <p className="text-sm font-medium text-gold-400 tracking-wider uppercase mb-2">Services</p>
          <h2 className="text-3xl sm:text-4xl font-bold text-white mb-4">
            Expert guidance for your most complex challenges
          </h2>
          <p className="text-base text-zinc-300 leading-relaxed">
            From strategic technology leadership to hands-on engineering, I help organizations build and scale great software.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {services.map((service, i) => {
            const start = 0.2 + i * cardSlice;
            const end = start + cardSlice * 0.8;
            return (
              <ServiceCardAnimated key={service.title} service={service} progress={progress} start={start} end={end} />
            );
          })}
        </div>
       </div>
      </div>

      <div className="absolute bottom-0 inset-x-0 h-[10vh] bg-gradient-to-b from-transparent to-zinc-950 z-[5] pointer-events-none" />
    </div>
  );
}

function ServiceCardAnimated({
  service,
  progress,
  start,
  end,
}: {
  service: Service;
  progress: ReturnType<typeof useScrollSequence>;
  start: number;
  end: number;
}) {
  const opacity = useTransform(progress, [start, end], [0, 1]);
  const scale = useTransform(progress, [start, end], [0.9, 1]);
  const y = useTransform(progress, [start, end], [20, 0]);

  return (
    <motion.div style={{ opacity, scale, y }}>
      <ServiceCard service={service} />
    </motion.div>
  );
}

function ServicesFallback({ services }: { services: Service[] }) {
  return (
    <section id="services" className="py-20 sm:py-28">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <FadeIn className="max-w-2xl mb-16">
          <p className="text-sm font-medium text-gold-400 tracking-wider uppercase mb-2">Services</p>
          <h2 className="text-3xl sm:text-4xl font-bold text-white mb-4">
            Expert guidance for your most complex challenges
          </h2>
          <p className="text-base text-zinc-300 leading-relaxed">
            From strategic technology leadership to hands-on engineering, I help organizations build and scale great software.
          </p>
        </FadeIn>
        <FadeInStagger className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {services.map((service) => (
            <FadeInItem key={service.title}>
              <ServiceCard service={service} />
            </FadeInItem>
          ))}
        </FadeInStagger>
      </div>
    </section>
  );
}

export function ServicesSequence({ services, zIndex }: { services: Service[]; zIndex?: number }) {
  return (
    <ScrollSequence
      scrollHeight="200vh"
      sticky={false}
      fallback={<ServicesFallback services={services} />}
      id="services"
      zIndex={zIndex}
    >
      <ServicesContent services={services} />
    </ScrollSequence>
  );
}
