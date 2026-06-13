"use client";

import { heading } from "@/lib/ui/typography";
import { Swatch } from "../_components/Swatch";

interface SwatchDef {
  name: string;
  token: string;
  className: string;
}

const surfaces: SwatchDef[] = [
  { name: "canvas", token: "--canvas", className: "bg-canvas" },
  { name: "surface-0", token: "--surface-0", className: "bg-surface-0" },
  { name: "surface-1", token: "--surface-1", className: "bg-surface-1" },
  { name: "surface-2", token: "--surface-2", className: "bg-surface-2" },
  { name: "elevated", token: "--elevated", className: "bg-elevated" },
];

const borders: SwatchDef[] = [
  { name: "border", token: "--border", className: "bg-border" },
  { name: "border-strong", token: "--border-strong", className: "bg-border-strong" },
];

const textTokens: SwatchDef[] = [
  { name: "foreground", token: "--foreground", className: "bg-foreground" },
  { name: "muted", token: "--muted", className: "bg-muted" },
  { name: "subtle", token: "--subtle", className: "bg-subtle" },
];

const accents: SwatchDef[] = [
  { name: "accent", token: "--accent", className: "bg-accent" },
  { name: "accent-soft", token: "--accent-soft", className: "bg-accent-soft" },
  { name: "accent-on", token: "--accent-on", className: "bg-accent-on" },
];

const semantic: SwatchDef[] = [
  { name: "success", token: "--success", className: "bg-success" },
  { name: "warning", token: "--warning", className: "bg-warning" },
  { name: "danger", token: "--danger", className: "bg-danger" },
  { name: "info", token: "--info", className: "bg-info" },
];

function SwatchRow({ title, items }: { title: string; items: SwatchDef[] }) {
  return (
    <div className="flex flex-col gap-3">
      <h3 className={heading.heading}>{title}</h3>
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3">
        {items.map((s) => (
          <Swatch key={s.name} name={s.name} token={s.token} className={s.className} />
        ))}
      </div>
    </div>
  );
}

export function Tokens() {
  return (
    <div className="flex flex-col gap-8">
      <h2 className={heading.title}>Tokens</h2>

      <div className="flex flex-col gap-6">
        <SwatchRow title="Surfaces" items={surfaces} />
        <SwatchRow title="Borders" items={borders} />
        <SwatchRow title="Text" items={textTokens} />
        <SwatchRow title="Accents" items={accents} />
        <SwatchRow title="Semantic" items={semantic} />
      </div>

      {/* Radii */}
      <div className="flex flex-col gap-3">
        <h3 className={heading.heading}>Radii</h3>
        <div className="flex flex-wrap gap-4">
          {[
            { label: "none", cls: "rounded-none" },
            { label: "sm", cls: "rounded-sm" },
            { label: "md", cls: "rounded-md" },
            { label: "lg", cls: "rounded-lg" },
            { label: "xl", cls: "rounded-xl" },
          ].map((r) => (
            <div key={r.label} className="flex flex-col items-center gap-1.5">
              <div
                className={`${r.cls} h-14 w-14 bg-surface-2 border border-border`}
              />
              <code className="text-[10px] font-mono text-subtle">{r.label}</code>
            </div>
          ))}
        </div>
      </div>

      {/* Shadows */}
      <div className="flex flex-col gap-3">
        <h3 className={heading.heading}>Shadows</h3>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          {[
            { label: "shadow-ambient", cls: "shadow-ambient" },
            { label: "shadow-elevated", cls: "shadow-elevated" },
            { label: "shadow-glow", cls: "shadow-glow" },
          ].map((s) => (
            <div
              key={s.label}
              className={`${s.cls} rounded-lg bg-surface-1 border border-border p-6 flex items-center justify-center`}
            >
              <code className="text-xs font-mono text-muted">{s.label}</code>
            </div>
          ))}
        </div>
      </div>

      {/* Motion */}
      <div className="flex flex-col gap-3">
        <h3 className={heading.heading}>Motion</h3>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
          {[
            { label: "animate-fade-in", cls: "animate-fade-in" },
            { label: "animate-slide-up", cls: "animate-slide-up" },
            { label: "animate-spin-slow", cls: "animate-spin-slow" },
            { label: "animate-shimmer", cls: "animate-shimmer" },
          ].map((m) => (
            <div
              key={m.label}
              className="rounded-lg border border-border bg-surface-0 p-3 flex flex-col items-center gap-2"
            >
              <div
                className={`${m.cls} h-12 w-12 rounded-md bg-surface-1 border border-border`}
              />
              <code className="text-[10px] font-mono text-subtle">{m.label}</code>
            </div>
          ))}
        </div>
        <p className="text-xs text-subtle">
          <code className="font-mono">animate-shimmer</code> honors
          <code className="font-mono"> prefers-reduced-motion</code>.
        </p>
      </div>
    </div>
  );
}
