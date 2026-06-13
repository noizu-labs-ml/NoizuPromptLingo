"use client";

import { useState, useEffect, useCallback } from "react";
import { createPortal } from "react-dom";
import { RadioGroup, Radio } from "@headlessui/react";
import type { PageLayout } from "@styleguide-engine/lib/types";
import { readLayout, writeLayout, readColorMode, writeColorMode, readTheme, writeTheme } from "@styleguide-engine/lib/section-cookie";

export const VIEWPORT_BREAKPOINTS = [
  { name: "0", px: 0 },
  { name: "xs", px: 480 },
  { name: "sm", px: 640 },
  { name: "md", px: 768 },
  { name: "lg", px: 1024 },
  { name: "xl", px: 1280 },
  { name: "2xl", px: 1536 },
];

export const CONTAINER_BREAKPOINTS = [
  { name: "0", rem: 0, bp: "0" },
  { name: "@xs", rem: 20, bp: "xs" },
  { name: "@sm", rem: 24, bp: "sm" },
  { name: "@md", rem: 28, bp: "md" },
  { name: "@lg", rem: 32, bp: "lg" },
  { name: "@xl", rem: 36, bp: "xl" },
  { name: "@2xl", rem: 42, bp: "2xl" },
];

interface Props {
  pageLayouts: PageLayout[];
  themes?: { slug: string; name: string }[];
}

function modifierOf(pl: PageLayout): string {
  return pl.selector.replace(".content", "").replace(".", "").trim() || "standard";
}

export function LayoutBar({ pageLayouts, themes }: Props) {
  const [selected, setSelected] = useState(() => readLayout() || "standard");
  const [activeTheme, setActiveTheme] = useState(() => readTheme() || "");
  const [mode, setMode] = useState<"light" | "dark">("light");

  useEffect(() => {
    const stored = readColorMode();
    if (stored === "dark" || (!stored && document.documentElement.classList.contains("dark"))) {
      setMode("dark");
      document.documentElement.classList.add("dark");
    }
    const storedTheme = readTheme();
    if (storedTheme) {
      setActiveTheme(storedTheme);
      document.documentElement.setAttribute("data-design-theme", storedTheme);
    } else {
      setActiveTheme(document.documentElement.getAttribute("data-design-theme") || "");
    }
  }, []);

  const applyLayout = useCallback((mod: string) => {
    setSelected(mod);
    writeLayout(mod === "standard" ? "" : mod);
    const el = document.querySelector(".content");
    if (!el) return;
    pageLayouts.forEach((pl) => {
      const m = modifierOf(pl);
      if (m && m !== "standard") el.classList.remove(m);
    });
    if (mod && mod !== "standard") el.classList.add(mod);
  }, [pageLayouts]);

  const applyMode = useCallback((next: "light" | "dark") => {
    setMode(next);
    document.documentElement.classList.toggle("dark", next === "dark");
    writeColorMode(next);
  }, []);

  const applyTheme = useCallback((slug: string) => {
    setActiveTheme(slug);
    document.documentElement.setAttribute("data-design-theme", slug);
    writeTheme(slug);
  }, []);

  useEffect(() => {
    const observer = new MutationObserver(() => {
      const el = document.querySelector(".content");
      if (!el) return;
      const current = pageLayouts.find((pl) => {
        const m = modifierOf(pl);
        return m === "standard" ? !["wide", "full", "narrow", "article"].some((c) => el.classList.contains(c)) : el.classList.contains(m);
      });
      if (current) setSelected(modifierOf(current));
    });
    const el = document.querySelector(".content");
    if (el) observer.observe(el, { attributes: true, attributeFilter: ["class"] });
    return () => observer.disconnect();
  }, [pageLayouts]);

  type RulerMode = "off" | "viewport" | "container";
  const [rulerMode, setRulerMode] = useState<RulerMode>("off");

  function cycleRuler() {
    setRulerMode((m) => m === "off" ? "viewport" : m === "viewport" ? "container" : "off");
  }

  return (
    <div className="sg-floating-controls">
      <div className="sg-layout-bar">
        <RadioGroup value={selected} onChange={applyLayout} className="sg-layout-bar-group">
          {pageLayouts.map((pl) => {
            const mod = modifierOf(pl);
            return (
              <Radio key={mod} value={mod} className="sg-layout-bar-option">
                <span className="sg-layout-bar-label">{pl.title}</span>
              </Radio>
            );
          })}
        </RadioGroup>
      </div>

      {themes && themes.length > 1 && (
        <div className="sg-mode-bar">
          <div className="sg-layout-bar-group">
            {themes.map((t) => (
              <button
                key={t.slug}
                type="button"
                className={`sg-layout-bar-option${activeTheme === t.slug ? " sg-layout-bar-option-active" : ""}`}
                onClick={() => applyTheme(t.slug)}
                title={`Switch to ${t.name} theme`}
              >
                <span className="sg-layout-bar-label">{t.name}</span>
              </button>
            ))}
          </div>
        </div>
      )}

      <div className="sg-mode-bar">
        <div className="sg-layout-bar-group">
          <button
            type="button"
            className={`sg-layout-bar-option${rulerMode !== "off" ? " sg-layout-bar-option-active" : ""}`}
            onClick={cycleRuler}
            title={`Breakpoints: ${rulerMode === "off" ? "off" : rulerMode} (click to cycle)`}
          >
            <span className="sg-layout-bar-label">{rulerMode === "container" ? "┊@" : "┊"}</span>
          </button>
          <button
            type="button"
            className={`sg-layout-bar-option${mode === "light" ? " sg-mode-active-light" : ""}`}
            onClick={() => applyMode(mode === "light" ? "dark" : "light")}
          >
            <span className="sg-layout-bar-label">🌞</span>
          </button>
          <button
            type="button"
            className={`sg-layout-bar-option${mode === "dark" ? " sg-mode-active-dark" : ""}`}
            onClick={() => applyMode(mode === "light" ? "dark" : "light")}
          >
            <span className="sg-layout-bar-label">🌙</span>
          </button>
        </div>
      </div>

      {rulerMode === "viewport" && createPortal(
        <div className="breakpoint-rulers">
          {VIEWPORT_BREAKPOINTS.map((bp) => (
            <div key={bp.name} className="breakpoint-ruler" data-bp={bp.name}>
              <span className="breakpoint-ruler-label">{bp.name} {bp.px}px</span>
            </div>
          ))}
        </div>,
        document.body
      )}
      {rulerMode === "container" && (() => {
        const container = document.querySelector(".content");
        return container ? createPortal(
          <div className="container-breakpoint-rulers">
            {CONTAINER_BREAKPOINTS.map((bp) => (
              <div key={bp.name} className="container-bp-ruler" data-bp={bp.bp} style={{ left: `${bp.rem}rem` }}>
                <span className="container-bp-label">{bp.name} {bp.rem}rem</span>
              </div>
            ))}
          </div>,
          container
        ) : null;
      })()}
    </div>
  );
}
