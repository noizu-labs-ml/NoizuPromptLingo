"use client";

import { useEffect, useRef, useState } from "react";
import type { ColorGroup, SemanticClass, SemanticGroup } from "@styleguide-engine/lib/types";
import { ResolvedColor } from "@styleguide-engine/components/pkg/resolved-color";
import { SwatchPopunder } from "@styleguide-engine/components/pkg/swatch-popunder";
import { AnchorHeading } from "@styleguide-engine/components/pkg/anchor-heading";

function isLight(value: string): boolean {
  if (value.startsWith("#") && value.length >= 7) {
    const r = parseInt(value.slice(1, 3), 16);
    const g = parseInt(value.slice(3, 5), 16);
    const b = parseInt(value.slice(5, 7), 16);
    return (r * 0.299 + g * 0.587 + b * 0.114) > 150;
  }
  return false;
}

/** Resolves the computed background-color of its parent element and displays the hex value. */
function ResolvedBgHex() {
  const ref = useRef<HTMLSpanElement>(null);
  const [hex, setHex] = useState("");

  useEffect(() => {
    function resolve() {
      const el = ref.current?.parentElement;
      if (!el) return;
      const raw = getComputedStyle(el).backgroundColor;
      if (!raw || raw === "rgba(0, 0, 0, 0)") { setHex("—"); return; }
      const m = raw.match(/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/);
      if (m) {
        const h = (v: number) => Math.round(v).toString(16).padStart(2, "0");
        setHex(`#${h(+m[1])}${h(+m[2])}${h(+m[3])}`);
      } else {
        setHex(raw);
      }
    }
    resolve();
    const observer = new MutationObserver(resolve);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ["class", "data-design-theme"] });
    return () => observer.disconnect();
  }, []);

  return <span ref={ref} className="sg-palette-swatch-value">{hex}</span>;
}

interface Props {
  palette: ColorGroup[];
  semanticClasses?: SemanticClass[];
  semanticGroups?: SemanticGroup[];
}

function toColorGroup(name: string, classes: SemanticClass[], description?: string): ColorGroup {
  const withNotes = classes.filter((sc) => sc.note);
  return {
    group: name,
    description,
    colors: classes.map((sc) => ({
      name: sc.title,
      value: sc.vars.find((v) => v.name === "accent")?.value || "#888",
      cssClass: sc.class,
    })),
    notes: withNotes.length
      ? withNotes.map((sc) => {
          const accent = sc.vars.find((v) => v.name === "accent");
          return { swatch: accent?.value || "#888", label: sc.title, text: sc.note!, cssClass: sc.class };
        })
      : undefined,
  };
}

function PaletteGroup({ group }: { group: ColorGroup }) {
  const [open, setOpen] = useState(true);

  return (
    <div className="sg-palette-group">
      <div onClick={() => setOpen(!open)} className="cursor-pointer select-none flex items-center gap-[var(--space-1)]">
        <AnchorHeading className="sg-subsection-title mb-0">{group.group}</AnchorHeading>
        <span className="inline-flex items-center text-[var(--toggle-icon-size)] text-[var(--text-muted)] ml-auto" style={{ transition: "transform 0.15s", transform: open ? "rotate(90deg)" : "rotate(0deg)" }}>&#9654;</span>
      </div>
      {group.description && <p className="sg-description">{group.description}</p>}

      {open ? (
        <>
          <div className="sg-palette-grid">
            {group.colors.map((c) => {
              const hasClass = !!c.cssClass;
              const isDirectHex = !hasClass && (c.value.startsWith("#") || c.value.startsWith("rgb"));
              const isVar = !hasClass && c.value.startsWith("var(");
              const inlineStyle = isDirectHex
                ? { background: c.value, color: isLight(c.value) ? "#000" : "#fff" }
                : isVar
                  ? { background: c.value }
                  : undefined;
              return (
                <div key={c.name} className="sg-palette-swatch">
                  <div
                    className={`sg-palette-swatch-inner${hasClass ? ` bg-${c.cssClass} text-on-${c.cssClass}` : ""}`}
                    style={inlineStyle}
                  >
                    <span className="sg-palette-swatch-label">{c.name}</span>
                    {hasClass ? <ResolvedColor cssClass={`bg-${c.cssClass}`} /> : isVar ? <ResolvedBgHex /> : <span className="sg-palette-swatch-value">{c.value}</span>}
                  </div>
                  {hasClass && <SwatchPopunder name={c.cssClass!} />}
                </div>
              );
            })}
          </div>
          {group.notes && group.notes.length > 0 && (
            <div className="sg-palette-notes">
              {group.notes.map((note) => {
                const noteIsVar = note.swatch?.startsWith("var(");
                return (
                  <div key={note.label} className="sg-palette-note">
                    <span
                      className={`sg-palette-note-dot${note.cssClass ? ` bg-${note.cssClass}` : ""}`}
                      style={note.swatch && !note.cssClass ? { background: note.swatch } : undefined}
                    />
                    <strong
                      className={note.cssClass ? `color-${note.cssClass}` : undefined}
                      style={note.swatch && !note.cssClass ? { color: note.swatch } : undefined}
                    >
                      {note.label}
                    </strong>
                    <span>&mdash;{note.text}{noteIsVar && !note.cssClass ? ` (${note.swatch})` : ""}</span>
                  </div>
                );
              })}
            </div>
          )}
        </>
      ) : (
        <div className="max-h-32 overflow-hidden relative cursor-pointer" onClick={() => setOpen(true)}>
          <div className="sg-palette-grid">
            {group.colors.map((c) => {
              const hasClass = !!c.cssClass;
              const isDirectHex = !hasClass && (c.value.startsWith("#") || c.value.startsWith("rgb"));
              const isVar = !hasClass && c.value.startsWith("var(");
              const inlineStyle = isDirectHex
                ? { background: c.value, color: isLight(c.value) ? "#000" : "#fff" }
                : isVar
                  ? { background: c.value }
                  : undefined;
              return (
                <div key={c.name} className="sg-palette-swatch">
                  <div
                    className={`sg-palette-swatch-inner${hasClass ? ` bg-${c.cssClass} text-on-${c.cssClass}` : ""}`}
                    style={inlineStyle}
                  >
                    <span className="sg-palette-swatch-label">{c.name}</span>
                    {hasClass ? <ResolvedColor cssClass={`bg-${c.cssClass}`} /> : isVar ? <ResolvedBgHex /> : <span className="sg-palette-swatch-value">{c.value}</span>}
                  </div>
                </div>
              );
            })}
          </div>
          <div className="sg-default-collapse-fade" />
        </div>
      )}
    </div>
  );
}

function buildSemanticColorGroups(semanticClasses?: SemanticClass[], semanticGroups?: SemanticGroup[]): ColorGroup[] {
  if (!semanticClasses) return [];
  if (semanticGroups && semanticGroups.length > 0) {
    return semanticGroups
      .map((sg) => {
        const classes = semanticClasses.filter((sc) => sc.group === sg.name);
        return classes.length ? toColorGroup(sg.name, classes, sg.description) : null;
      })
      .filter(Boolean) as ColorGroup[];
  }
  return [toColorGroup("Semantic Classes", semanticClasses)];
}

export function PaletteSection({ palette }: { palette: ColorGroup[] }) {
  return (
    <div>
      {palette.map((group) => (
        <PaletteGroup key={group.group} group={group} />
      ))}
    </div>
  );
}

export function SemanticColorSection({ semanticClasses, semanticGroups }: { semanticClasses?: SemanticClass[]; semanticGroups?: SemanticGroup[] }) {
  const groups = buildSemanticColorGroups(semanticClasses, semanticGroups);
  if (!groups.length) return null;
  return (
    <div>
      {groups.map((group) => (
        <PaletteGroup key={group.group} group={group} />
      ))}
    </div>
  );
}

export function ColorPalette({ palette, semanticClasses, semanticGroups }: Props) {
  const semanticColorGroups = buildSemanticColorGroups(semanticClasses, semanticGroups);
  const allGroups = [...palette, ...semanticColorGroups];

  return (
    <div>
      {allGroups.map((group) => (
        <PaletteGroup key={group.group} group={group} />
      ))}
    </div>
  );
}
