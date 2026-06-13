"use client";

import { useEffect, useState, useRef, useCallback } from "react";

/**
 * Each verb concept has translations across 7 languages.
 * Process: pick a verb → show it in random language order → next verb.
 */
interface VerbConcept {
  en: string;
  ja: string;
  zh: string;
  nl: string;
  es: string;
  de: string;
  km: string;
}

const heroConceptList: VerbConcept[] = [
  { en: "building",   ja: "構築中",    zh: "建造",  nl: "bouwt",     es: "construye", de: "baut",    km: "កំពុងសាង" },
  { en: "measuring",  ja: "測定中",    zh: "测量",  nl: "meet",      es: "mide",      de: "misst",   km: "វាស់វែង" },
  { en: "deploying",  ja: "展開中",    zh: "部署",  nl: "lanceert",  es: "despliega", de: "startet", km: "ដាក់ពង្រាយ" },
  { en: "shipping",   ja: "出荷中",    zh: "发货",  nl: "verzendt",  es: "envía",     de: "liefert", km: "ដឹកជញ្ជូន" },
  { en: "validating", ja: "検証中",    zh: "验证",  nl: "valideert", es: "valida",    de: "prüft",   km: "ផ្ទៀងផ្ទាត់" },
  { en: "scaling",    ja: "拡張中",    zh: "扩展",  nl: "schaalt",   es: "escala",    de: "skaliert", km: "ពង្រីក" },
  { en: "testing",    ja: "試験中",    zh: "测试",  nl: "test",      es: "prueba",    de: "testet",  km: "សាកល្បង" },
  { en: "designing",  ja: "設計中",    zh: "设计",  nl: "ontwerpt",  es: "diseña",    de: "entwirft", km: "រចនា" },
  { en: "launching",  ja: "起動中",    zh: "启动",  nl: "start",     es: "lanza",     de: "startet", km: "បើកដំណើរ" },
  { en: "automating", ja: "自動化中",  zh: "自动化", nl: "automatiseert", es: "automatiza", de: "automatisiert", km: "ស្វ័យប្រវត្តិ" },
];

const navConceptList: VerbConcept[] = [
  { en: "rising",    ja: "立ち上がり", zh: "崛起",  nl: "rijst",   es: "surge",  de: "erhebt",  km: "កើនឡើង" },
  { en: "thinking",  ja: "考え中",    zh: "思考",  nl: "denkt",   es: "piensa", de: "denkt",   km: "គិត" },
  { en: "creating",  ja: "創造中",    zh: "创造",  nl: "creëert", es: "crea",   de: "erschafft", km: "បង្កើត" },
  { en: "learning",  ja: "学習中",    zh: "学习",  nl: "leert",   es: "aprende", de: "lernt",  km: "រៀន" },
  { en: "dreaming",  ja: "夢見中",    zh: "做梦",  nl: "droomt",  es: "sueña",  de: "träumt",  km: "សុបិន" },
  { en: "knowing",   ja: "知識中",    zh: "知道",  nl: "weet",    es: "sabe",   de: "weiß",    km: "ដឹង" },
  { en: "living",    ja: "生きている", zh: "活着",  nl: "leeft",   es: "vive",   de: "lebt",    km: "រស់នៅ" },
  { en: "making",    ja: "作成中",    zh: "制造",  nl: "maakt",   es: "hace",   de: "macht",   km: "ធ្វើ" },
  { en: "searching", ja: "検索中",    zh: "搜索",  nl: "zoekt",   es: "busca",  de: "sucht",   km: "ស្វែងរក" },
];

const langs: (keyof VerbConcept)[] = ["en", "ja", "zh", "nl", "es", "de", "km"];

const colors = [
  "var(--red)",
  "var(--blue)",
  "var(--warning)",
  "var(--success)",
  "var(--error)",
  "var(--info)",
  "var(--text-link)",
];

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

interface Props {
  variant?: "hero" | "nav";
  size?: "sm" | "lg";
}

export function VerbCycle({ variant = "nav", size = "sm" }: Props) {
  const concepts = variant === "hero" ? heroConceptList : navConceptList;
  const [text, setText] = useState(concepts[0].en);
  const [colorIdx, setColorIdx] = useState(0);
  const [glitching, setGlitching] = useState(false);
  const ref = useRef<HTMLSpanElement>(null);
  const queueRef = useRef<string[]>([]);
  const conceptIdxRef = useRef(0);
  const timeoutRef = useRef<ReturnType<typeof setTimeout>>();

  // Build a queue: pick a concept, shuffle its languages, push all translations
  const fillQueue = useCallback(() => {
    // Pick a random concept different from current
    let next: number;
    do {
      next = Math.floor(Math.random() * concepts.length);
    } while (next === conceptIdxRef.current && concepts.length > 1);
    conceptIdxRef.current = next;

    const concept = concepts[next];
    const shuffledLangs = shuffle(langs);
    queueRef.current = shuffledLangs.map((l) => concept[l]);
  }, [concepts]);

  // Sinusoidal + noise timing: oscillates between fast bursts and slow pauses.
  // phase advances each tick, sin(phase) maps [-1,1] → delay range.
  // Random jitter on top prevents mechanical feel.
  const phaseRef = useRef(Math.random() * Math.PI * 2);
  const getDelay = useCallback(() => {
    // Advance phase by random step (0.3–0.8) so wave isn't predictable
    phaseRef.current += 0.3 + Math.random() * 0.5;
    // sin → 0..1
    const wave = (Math.sin(phaseRef.current) + 1) / 2;
    // noise: ±20% randomness
    const noise = 0.8 + Math.random() * 0.4;

    if (variant === "hero") {
      // Range: 100ms (burst) to 600ms (pause)
      return (100 + wave * 500) * noise;
    }
    // Nav: 150ms (burst) to 800ms (pause)
    return (150 + wave * 650) * noise;
  }, [variant]);

  useEffect(() => {
    fillQueue();

    function tick() {
      // If queue empty, refill with next concept
      if (queueRef.current.length === 0) {
        fillQueue();
      }

      setGlitching(true);
      setTimeout(() => {  // glitch duration
        const next = queueRef.current.shift()!;
        setText(next);
        setColorIdx((c) => (c + 1) % colors.length);
        setGlitching(false);
      }, 150);

      timeoutRef.current = setTimeout(tick, getDelay());
    }

    timeoutRef.current = setTimeout(tick, getDelay());
    return () => { if (timeoutRef.current) clearTimeout(timeoutRef.current); };
  }, [fillQueue, getDelay]);

  const color = colors[colorIdx];
  const isLg = size === "lg";

  return (
    <span
      ref={ref}
      className={`verb-cycle ${glitching ? "verb-glitch" : ""}`}
      style={{
        color,
        fontFamily: "var(--font-mono)",
        fontSize: isLg ? "clamp(24px, 4vw, 48px)" : "13px",
        fontWeight: isLg ? 700 : 500,
        letterSpacing: "0.02em",
        display: "inline-block",
        minWidth: isLg ? "8ch" : "8ch",
        position: "relative",
      }}
      data-text={text}
      aria-label={`derobot.is ${text}`}
    >
      {text}
    </span>
  );
}
