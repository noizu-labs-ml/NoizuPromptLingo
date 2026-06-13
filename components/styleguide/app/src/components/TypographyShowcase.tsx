"use client";

import { useState } from "react";
import type { StyleGuideConfig, TypographyClass, TypographyEntry } from "@styleguide-engine/lib/types";
import { Disclosure, DisclosureButton, DisclosurePanel } from "@headlessui/react";
import { Subsection } from "./pkg/subsection";

interface Props {
  config: StyleGuideConfig;
}

const SAMPLE = "The quick brown fox jumps over the lazy dog. 0123456789";
const CLASS_SAMPLE = "The quick brown fox";

const CSS_PROP_LABELS: Record<string, string> = {
  "font-family": "family",
  "font-size": "size",
  "font-weight": "weight",
  "font-style": "style",
  "line-height": "leading",
  "letter-spacing": "tracking",
  "text-transform": "transform",
  color: "color",
};

function SubLabel({ children }: { children: React.ReactNode }) {
  return (
    <div className="sg-subsection">
      {children}
    </div>
  );
}

function FontEntry({ entry, fontValue, fontSize, lineHeight }: {
  entry: TypographyEntry;
  fontValue: string;
  fontSize: string;
  lineHeight: string;
}) {
  const hasColors = entry.colors && entry.colors.length > 0;
  const [activeColor, setActiveColor] = useState<string | null>(null);
  const activeEntry = hasColors ? entry.colors!.find((c) => c.value === activeColor) : null;
  const specimenColor = activeColor || "var(--text-secondary)";
  const headingColor = activeColor || "inherit";
  const specimenBg = activeEntry?.background || undefined;

  return (
    <div className="font-entry">
      {/* Left column: meta */}
      <div className="font-entry-meta">
        <div className="font-entry-name">{entry.name}</div>
        <div className="font-entry-var">--{entry.var}</div>
        <p className="font-entry-desc">{entry.description}</p>
        <div className="font-entry-detail">Usage: {entry.usage}</div>
        <div className="font-entry-detail">Weights: {entry.weights.join(", ")}</div>
      </div>

      {/* Specimen */}
      <div className="font-entry-specimen">
        <div
          className="font-entry-specimen-bg"
          style={{
            background: specimenBg,
            borderRadius: specimenBg ? "var(--radius)" : undefined,
          }}
        >
          <div
            className="font-entry-heading"
            style={{ fontFamily: fontValue, color: headingColor }}
          >
            Aa Bb Cc Dd
          </div>
          <div className="overflow-x-auto">
            {entry.weights.map((w) => (
              <div
                key={w}
                className="font-entry-weight"
                style={{ fontFamily: fontValue, fontSize, fontWeight: w, lineHeight, color: specimenColor }}
              >
                {SAMPLE}
                <span className="font-entry-weight-label">{w}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Color palette swatches + note (spans full width on desktop) */}
      {hasColors && (
        <div className="font-entry-colors">
          <div className="font-entry-swatches">
            {entry.colors!.map((c) => (
              <button
                key={c.value}
                type="button"
                title={c.label}
                onClick={() => setActiveColor(activeColor === c.value ? null : c.value)}
                className={`font-entry-swatch${activeColor === c.value ? " active" : ""}`}
                style={{ background: c.value }}
              />
            ))}
          </div>
          {activeEntry && (
            <div className="font-entry-swatch-label">{activeEntry.label}</div>
          )}
          {activeEntry?.note && (
            <div
              className="alert mt-[var(--space-2)]"
              style={{ borderLeftColor: activeColor || undefined }}
            >
              <div className="alert-title" style={{ color: activeColor || undefined }}>{activeEntry.label}</div>
              <div className="alert-body">{activeEntry.note}</div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export function FontsSection({ config }: { config: StyleGuideConfig }) {
  const typoGroup = config.vars.groups.find((g) => g.name === "Typography");
  const entries = config.typography;
  if (!typoGroup || !entries.length) return null;

  const fontSize = typoGroup.vars.find((v) => v.name === "font-size-base")?.value || "16px";
  const lineHeight = typoGroup.vars.find((v) => v.name === "line-height-base")?.value || "1.5";

  return (
    <div>
      {entries.map((entry) => {
        const fontVar = typoGroup.vars.find((v) => v.name === entry.var);
        const fontValue = fontVar?.value || "";
        return <FontEntry key={entry.var} entry={entry} fontValue={fontValue} fontSize={fontSize} lineHeight={lineHeight} />;
      })}
    </div>
  );
}

export function ClassesSection({ classes }: { classes: TypographyClass[] }) {
  if (!classes.length) return null;

  return (
    <div>
      {classes.map((tc) => {
        const props = Object.entries(CSS_PROP_LABELS)
          .filter(([p]) => tc[p as keyof TypographyClass] !== undefined)
          .map(([p, label]) => `${label}: ${tc[p as keyof TypographyClass]}`);

        return (
          <div
            key={tc.class}
            className="sg-type-specimen grid grid-cols-1 @sm:grid-cols-[180px_1fr] gap-[var(--space-3)] items-center"
          >
            <div>
              <div className="font-mono text-[length:var(--font-size-xs)] font-bold text-text mb-[var(--space-half)]">
                .{tc.class}
              </div>
              {tc.usage && (
                <div className="text-[length:var(--font-size-xs)] text-text-muted mb-[var(--space-half)]">
                  {tc.usage}
                </div>
              )}
              <div className="font-mono text-[length:var(--font-size-xs)] text-text-muted leading-relaxed">
                {props.join(" · ")}
              </div>
            </div>
            <div className={`${tc.class} whitespace-pre-wrap`}>
              {tc.sample || CLASS_SAMPLE}
            </div>
          </div>
        );
      })}
    </div>
  );
}

const DECORATIONS: { label: string; style: React.CSSProperties }[] = [
  { label: "Normal", style: {} },
  { label: "Italic", style: { fontStyle: "italic" } },
  { label: "Underline", style: { textDecoration: "underline" } },
  { label: "Strikethrough", style: { textDecoration: "line-through" } },
  { label: "Underline + Italic", style: { fontStyle: "italic", textDecoration: "underline" } },
  { label: "Overline", style: { textDecoration: "overline" } },
  { label: "Small Caps", style: { fontVariant: "small-caps" } },
  { label: "Uppercase", style: { textTransform: "uppercase", letterSpacing: "0.08em" } },
];

const TEXT_COLORS: { label: string; varName: string }[] = [
  { label: "Text (default)", varName: "--text" },
  { label: "Text Secondary", varName: "--text-secondary" },
  { label: "Text Muted", varName: "--text-muted" },
  { label: "Brand Red", varName: "--brand-red" },
  { label: "Brand Blue", varName: "--brand-blue" },
  { label: "Brand Yellow", varName: "--brand-yellow" },
  { label: "Success", varName: "--success" },
  { label: "Warning", varName: "--warning" },
  { label: "Error", varName: "--error" },
  { label: "Info", varName: "--info" },
];

export function DecorationsSection() {
  return (
    <div className="grid grid-cols-1 @sm:grid-cols-2 gap-[var(--space-2)]">
      {DECORATIONS.map((d) => (
        <div key={d.label} className="flex items-baseline gap-[var(--space-2)] py-[var(--space-half)]">
          <span className="font-mono text-[length:var(--font-size-xs)] text-[var(--text-muted)] shrink-0 w-40">{d.label}</span>
          <span style={{ fontSize: "var(--font-size-base)", ...d.style }}>{SAMPLE}</span>
        </div>
      ))}
    </div>
  );
}

export function ColorUsageSection() {
  return (
    <div className="grid grid-cols-1 @sm:grid-cols-2 gap-[var(--space-2)]">
      {TEXT_COLORS.map((c) => (
        <div key={c.varName} className="flex items-center gap-[var(--space-2)] py-[var(--space-half)]">
          <span
            className="inline-block w-3 h-3 rounded-full border border-border shrink-0"
            style={{ background: `var(${c.varName})` }}
          />
          <span className="font-mono text-[length:var(--font-size-xs)] text-[var(--text-muted)] shrink-0 w-32">{c.label}</span>
          <span style={{ fontSize: "var(--font-size-sm)", color: `var(${c.varName})` }}>{CLASS_SAMPLE}</span>
        </div>
      ))}
    </div>
  );
}

export function TypographyShowcase({ config }: Props) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-3)" }}>
      <Subsection id="typo-fonts" title="Fonts & Usage">
        <FontsSection config={config} />
      </Subsection>

      <Subsection id="typo-decorations" title="Decorations & Styles">
        <DecorationsSection />
      </Subsection>

      <Subsection id="typo-colors" title="Text Colors">
        <ColorUsageSection />
      </Subsection>

      <Subsection id="typo-classes" title="Typography Classes" defaultOpen={true}>
        <ClassesSection classes={config.typographyClasses} />
      </Subsection>
    </div>
  );
}
