"use client";

import { useEffect, useRef, useState, useCallback } from "react";

const words = ["The", "Robot", "Builds.", "The", "Robot", "Shares."];

/** Phrases that fly around on hover */
const phrases = [
  // English
  "The Robot Is.", "The Robot Builds.", "The Robot Shares.",
  // Dutch
  "De Robot Bouwt.", "De Robot Leeft.", "De Robot Deelt.",
  "De Robot Weet.", "De Robot Droomt.", "De Robot Maakt.",
  "De Robot Zoekt.", "De Robot Denkt.", "De Robot Groeit.",
  // German
  "Der Roboter Baut.", "Der Roboter Lebt.", "Der Roboter Teilt.",
  "Der Roboter Weiß.", "Der Roboter Träumt.", "Der Roboter Denkt.",
  "Der Roboter Sucht.", "Der Roboter Wächst.",
  // French
  "Le Robot Construit.", "Le Robot Vit.", "Le Robot Partage.",
  "Le Robot Sait.", "Le Robot Rêve.", "Le Robot Crée.",
  "Le Robot Pense.", "Le Robot Grandit.",
  // Spanish
  "El Robot Construye.", "El Robot Vive.", "El Robot Comparte.",
  "El Robot Sabe.", "El Robot Sueña.", "El Robot Crea.",
  "El Robot Piensa.", "El Robot Crece.",
  // Japanese
  "ロボットは知る", "ロボットは建てる", "ロボットは共有する",
  "ロボットは夢を見る", "ロボットは考える", "ロボットは生きる",
  "ロボットは作る", "ロボットは成長する",
  // Chinese
  "机器人在建造", "机器人在分享", "机器人在思考",
  "机器人在做梦", "机器人在创造", "机器人在成长",
  "机器人知道", "机器人活着",
  // Khmer
  "មនុស្សយន្តស្វែងរក", "មនុស្សយន្តកំពុងសាង", "មនុស្សយន្តរស់នៅ",
  "មនុស្សយន្តគិត", "មនុស្សយន្តបង្កើត", "មនុស្សយន្តរៀន",
];

const flyColors = [
  "var(--zinc-100)", "var(--zinc-200)", "var(--zinc-300)",
  "var(--zinc-400)", "var(--zinc-500)", "var(--zinc-600)",
  "var(--zinc-700)", "var(--zinc-800)",
];

interface FlyingWord {
  id: number;
  text: string;
  x: number; // percentage
  y: number; // percentage
  vx: number;
  vy: number;
  opacity: number;
  fontSize: number;
  color: string;
  blur: number;
  horizontal: boolean; // true = moves horizontally, false = vertically
}

/** The blur-wave tagline at the bottom of the hero */
export function BlurTagline({ onHoverChange }: { onHoverChange?: (h: boolean) => void }) {
  const spanRefs = useRef<(HTMLSpanElement | null)[]>([]);
  const frameRef = useRef<number>(0);
  const [hovered, setHovered] = useState(false);

  const setHover = useCallback((h: boolean) => {
    setHovered(h);
    onHoverChange?.(h);
  }, [onHoverChange]);

  // Blur wave animation
  useEffect(() => {
    if (hovered) return;
    const baseFreq = 0.4;
    const params = words.map((_, i) => ({
      phase: (words.length - 1 - i) * 1.0,
    }));
    let t = 0;
    function animate() {
      t += 0.016;
      spanRefs.current.forEach((span, i) => {
        if (!span) return;
        const { phase } = params[i];
        const wave = (Math.sin(t * baseFreq * Math.PI * 2 + phase) + 1) / 2;
        span.style.filter = `blur(${wave * 3.5}px)`;
        span.style.opacity = String(0.5 + wave * 0.5);
      });
      frameRef.current = requestAnimationFrame(animate);
    }
    frameRef.current = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(frameRef.current);
  }, [hovered]);

  useEffect(() => {
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    if (mq.matches) {
      spanRefs.current.forEach((span) => {
        if (span) { span.style.filter = "blur(2px)"; span.style.opacity = "0.6"; }
      });
      cancelAnimationFrame(frameRef.current);
    }
  }, []);

  return (
    <div
      className="relative"
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      style={{ cursor: "default" }}
    >
      <p
        className="relative text-center font-[family-name:var(--font-display)] text-4xl md:text-6xl tracking-tight flex flex-wrap justify-center gap-x-[0.3em]"
        style={{ zIndex: 1 }}
      >
        {words.map((word, i) => (
          <span
            key={i}
            ref={(el) => { spanRefs.current[i] = el; }}
            className="text-white inline-block"
            style={{ filter: "blur(2px)", opacity: 0.6, transition: "none" }}
          >
            {word}
          </span>
        ))}
      </p>
    </div>
  );
}

/** Flying text layer — rendered at the hero section level, not inside the tagline */
export function FlyingTextLayer({ active }: { active: boolean }) {
  const [flyingWords, setFlyingWords] = useState<FlyingWord[]>([]);
  const flyingRef = useRef<FlyingWord[]>([]);
  const frameRef = useRef<number>(0);
  const idCounter = useRef(0);

  const spawnWord = useCallback(() => {
    const text = phrases[Math.floor(Math.random() * phrases.length)];
    const color = flyColors[Math.floor(Math.random() * flyColors.length)];
    const horizontal = Math.random() > 0.5;

    let x: number, y: number, vx: number, vy: number;
    if (horizontal) {
      // Strict horizontal movement
      const fromLeft = Math.random() > 0.5;
      x = fromLeft ? -15 : 115;
      y = 10 + Math.random() * 80;
      vx = (fromLeft ? 1 : -1) * (0.2 + Math.random() * 0.4);
      vy = 0;
    } else {
      // Strict vertical movement
      const fromTop = Math.random() > 0.5;
      x = 5 + Math.random() * 90;
      y = fromTop ? -10 : 110;
      vx = 0;
      vy = (fromTop ? 1 : -1) * (0.2 + Math.random() * 0.4);
    }

    const word: FlyingWord = {
      id: idCounter.current++,
      text, x, y, vx, vy,
      opacity: 0.1 + Math.random() * 0.5,
      fontSize: 14 + Math.random() * 30,
      color,
      blur: Math.random() * 2.5,
      horizontal,
    };
    flyingRef.current = [...flyingRef.current, word];
  }, []);

  useEffect(() => {
    if (!active) {
      flyingRef.current = [];
      setFlyingWords([]);
      return;
    }

    for (let i = 0; i < 40; i++) spawnWord();

    let spawnTimer = 0;
    function animate() {
      spawnTimer += 0.016;
      if (spawnTimer > 0.05 + Math.random() * 0.1) {
        spawnTimer = 0;
        if (flyingRef.current.length < 80) spawnWord();
      }

      flyingRef.current = flyingRef.current
        .map((w) => ({ ...w, x: w.x + w.vx, y: w.y + w.vy }))
        .filter((w) => w.x > -20 && w.x < 120 && w.y > -15 && w.y < 115);

      setFlyingWords([...flyingRef.current]);
      frameRef.current = requestAnimationFrame(animate);
    }

    frameRef.current = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(frameRef.current);
  }, [active, spawnWord]);

  if (!active) return null;

  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none" style={{ zIndex: 0 }}>
      {flyingWords.map((w) => (
        <span
          key={w.id}
          className="absolute whitespace-nowrap font-[family-name:var(--font-display)]"
          style={{
            left: `${w.x}%`,
            top: `${w.y}%`,
            fontSize: `${w.fontSize}px`,
            opacity: w.opacity,
            color: w.color,
            filter: `blur(${w.blur}px)`,
            fontWeight: 700,
            letterSpacing: "-0.02em",
            transform: w.horizontal
              ? "translate(-50%, -50%)"
              : "translate(-50%, -50%) rotate(90deg)",
            transformOrigin: "center center",
          }}
        >
          {w.text}
        </span>
      ))}
    </div>
  );
}
