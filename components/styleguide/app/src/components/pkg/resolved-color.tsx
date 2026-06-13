"use client";

import { useEffect, useRef, useState } from "react";

function toHex(raw: string): string {
  const h = (v: number) => Math.round(Math.min(255, Math.max(0, v))).toString(16).padStart(2, "0");

  // rgb(r, g, b) or rgba(r, g, b, a)
  const rgba = raw.match(/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+))?\s*\)/);
  if (rgba) {
    const [, rs, gs, bs, as] = rgba;
    const a = as !== undefined ? parseFloat(as) : 1;
    if (a >= 1) return `#${h(+rs)}${h(+gs)}${h(+bs)}`;
    return `#${h(+rs)}${h(+gs)}${h(+bs)}${h(Math.round(a * 255))}`;
  }

  // color(srgb 0.5 0.5 0.5) or color(srgb 0.5 0.5 0.5 / 0.8)
  const srgb = raw.match(/color\(srgb\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)(?:\s*\/\s*([\d.]+))?\)/);
  if (srgb) {
    const [, rs, gs, bs, as] = srgb;
    const r = Math.round(parseFloat(rs) * 255);
    const g = Math.round(parseFloat(gs) * 255);
    const b = Math.round(parseFloat(bs) * 255);
    const a = as !== undefined ? parseFloat(as) : 1;
    if (a >= 1) return `#${h(r)}${h(g)}${h(b)}`;
    return `#${h(r)}${h(g)}${h(b)}${h(Math.round(a * 255))}`;
  }

  return raw;
}

interface ResolvedColorProps {
  cssClass: string;
  property?: "background-color" | "color";
}

export function ResolvedColor({ cssClass, property = "background-color" }: ResolvedColorProps) {
  const ref = useRef<HTMLSpanElement>(null);
  const [hex, setHex] = useState<string>("");

  useEffect(() => {
    function resolve() {
      if (!ref.current) return;
      const computed = getComputedStyle(ref.current);
      const raw = computed.getPropertyValue(property).trim();
      setHex(raw ? toHex(raw) : "—");
    }
    resolve();

    // Re-resolve when dark mode toggles (class changes on <html>)
    const observer = new MutationObserver(resolve);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ["class"] });
    return () => observer.disconnect();
  }, [cssClass, property]);

  return (
    <span ref={ref} className={`${cssClass} sg-palette-swatch-value`}>
      {hex}
    </span>
  );
}
