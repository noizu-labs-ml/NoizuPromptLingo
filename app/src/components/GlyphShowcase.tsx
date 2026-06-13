"use client";

import { useState, useCallback } from "react";
import type { GlyphLanguage, GlyphEntry } from "@styleguide-engine/lib/types";
import { Subsection } from "./pkg/subsection";

interface Props {
  glyphLanguage?: GlyphLanguage;
}


function glyphToSVG(glyph: string): string {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><text x="12" y="17" text-anchor="middle" font-size="18" fill="currentColor">${glyph}</text></svg>`;
}

type CopyFormat = "char" | "svg" | "code";

function GlyphCard({ g, onCopy }: {
  g: GlyphEntry;
  onCopy: (text: string, key: string) => void;
}) {
  const [hovered, setHovered] = useState(false);
  const [copied, setCopied] = useState<CopyFormat | null>(null);

  const key = (g.code ?? g.glyph) + g.name;

  const copy = useCallback((format: CopyFormat, e: React.MouseEvent) => {
    e.stopPropagation();
    const text =
      format === "char" ? g.glyph :
      format === "svg"  ? glyphToSVG(g.glyph) :
      (g.code ?? g.glyph);
    navigator.clipboard.writeText(text).then(() => {
      setCopied(format);
      onCopy(text, key);
      setTimeout(() => setCopied(null), 1200);
    });
  }, [g, key, onCopy]);

  const copyChar = useCallback((e: React.MouseEvent) => copy("char", e), [copy]);

  return (
    <div
      key={key}
      onClick={copyChar}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      className={`flex flex-col gap-[var(--space-1)] p-[var(--space-1)] border border-border rounded-[var(--radius)] cursor-pointer relative select-none transition-colors ${hovered ? "bg-surface-alt" : "bg-surface"}`}
    >
      {/* Copied flash overlay */}
      {copied === "char" && (
        <div style={{
          position: "absolute", inset: 0,
          display: "flex", alignItems: "center", justifyContent: "center",
          background: "rgba(255,255,255,0.88)",
          fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)",
          fontWeight: 700, color: "var(--text)", letterSpacing: "0.06em",
          pointerEvents: "none", zIndex: 2,
        }}>
          ✓ copied
        </div>
      )}

      <div style={{ display: "flex", gap: "var(--space-3)", alignItems: "flex-start" }}>
        <div style={{
          fontSize: "var(--font-size-2xl)", lineHeight: 1, width: 36, flexShrink: 0,
          display: "flex", alignItems: "center", justifyContent: "center",
          paddingTop: 2,
        }}>
          {g.glyph}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontWeight: 600, fontSize: "var(--font-size-sm)", marginBottom: "var(--space-half)" }}>{g.name}</div>
          <div style={{ fontSize: "var(--font-size-sm)", color: "var(--text-muted)", lineHeight: 1.4, marginBottom: "var(--space-half)" }}>{g.use}</div>
          <div style={{ display: "flex", alignItems: "center", gap: "var(--space-2)", flexWrap: "wrap" }}>
            {"code" in g && g.code && (
              <code style={{
                fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)",
                background: "var(--surface-alt)", border: "1px solid var(--border)",
                padding: "1px var(--space-1)", color: "var(--text-secondary)",
              }}>
                {g.code}
              </code>
            )}
            <span style={{ fontSize: "var(--font-size-sm)", color: "var(--text-muted)", fontStyle: "italic" }}>{g.example}</span>
          </div>
        </div>
      </div>

      {/* Hover action bar */}
      <div style={{
        display: "flex", gap: 4,
        opacity: hovered ? 1 : 0,
        transition: "opacity 0.12s",
        pointerEvents: hovered ? "auto" : "none",
      }}>
        {(["char", "svg", "code"] as CopyFormat[]).map((fmt) => (
          <button
            key={fmt}
            onClick={(e) => copy(fmt, e)}
            style={{
              fontFamily: "var(--font-mono)",
              fontSize: "10px",
              fontWeight: 600,
              letterSpacing: "0.05em",
              padding: "2px 6px",
              border: "1px solid var(--border)",
              background: copied === fmt ? "var(--surface-inverse)" : "var(--surface)",
              color: copied === fmt ? "var(--text-inverse)" : "var(--text-secondary)",
              cursor: "pointer",
              transition: "background 0.1s, color 0.1s",
            }}
          >
            {copied === fmt ? "✓" : fmt}
          </button>
        ))}
      </div>
    </div>
  );
}

function GlyphGrid({ glyphs }: { glyphs: GlyphEntry[] }) {
  const handleCopy = useCallback((_text: string, _key: string) => {}, []);

  return (
    <div className="grid grid-cols-[repeat(auto-fill,minmax(280px,1fr))] gap-[var(--space-half)]">
      {glyphs.map((g) => (
        <GlyphCard key={(g.code ?? g.glyph) + g.name} g={g} onCopy={handleCopy} />
      ))}
    </div>
  );
}


export function GlyphShowcase({ glyphLanguage }: Props) {
  const uiSection = glyphLanguage?.sections.find((s) => s.name === "ui");
  const typoSection = glyphLanguage?.sections.find((s) => s.name === "typography");
  const [search, setSearch] = useState("");

  const uiGlyphs = uiSection?.glyphs ?? [];
  const textGlyphs = typoSection?.glyphs ?? [];
  const allGlyphs = [...uiGlyphs, ...textGlyphs];

  const q = search.toLowerCase().trim();
  const filteredUI = q ? uiGlyphs.filter((g) => matches(g, q)) : uiGlyphs;
  const filteredText = q ? textGlyphs.filter((g) => matches(g, q)) : textGlyphs;

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-4)" }}>

      {glyphLanguage?.description && (
        <p style={{ fontSize: "var(--font-size-sm)", color: "var(--text-muted)", maxWidth: 720, lineHeight: 1.7, margin: 0 }}>
          {glyphLanguage.description}
        </p>
      )}

      {glyphLanguage?.principles && glyphLanguage.principles.length > 0 && (
        <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)" }}>
          {glyphLanguage.principles.map((p) => (
            <div key={p.rule} style={{ display: "flex", gap: "var(--space-3)", alignItems: "baseline" }}>
              <div style={{
                fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 700,
                color: "var(--border-strong)", whiteSpace: "nowrap", minWidth: 200,
              }}>
                {p.rule}
              </div>
              <p style={{ fontSize: "var(--font-size-sm)", color: "var(--text-muted)", lineHeight: 1.6, margin: 0 }}>
                {p.detail}
              </p>
            </div>
          ))}
        </div>
      )}

      <div className="hr hr-muted" />

      {/* Search */}
      <div className="flex items-center gap-[var(--space-2)]">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search glyphs..."
          className="field-input"
          style={{ maxWidth: 320 }}
        />
        {q && (
          <span className="text-xs font-mono text-[var(--text-muted)]">
            {filteredUI.length + filteredText.length} / {allGlyphs.length}
          </span>
        )}
      </div>

      <Subsection id="glyph-ui-navigation" title={uiSection?.title ?? "UI & Navigation"}>
        {uiSection?.description && (
          <p style={{ fontSize: "var(--font-size-sm)", color: "var(--text-muted)", maxWidth: 640, lineHeight: 1.65, marginBottom: "var(--space-2)" }}>
            {uiSection.description}
          </p>
        )}
        {filteredUI.length > 0
          ? <GlyphGrid glyphs={filteredUI} />
          : q && <p className="text-sm text-[var(--text-muted)] font-mono py-[var(--space-1)]">No UI glyphs match &ldquo;{search}&rdquo;</p>
        }
      </Subsection>

      <Subsection id="glyph-typography-text" title={typoSection?.title ?? "Typography & Text"}>
        {typoSection?.description && (
          <p style={{ fontSize: "var(--font-size-sm)", color: "var(--text-muted)", maxWidth: 640, lineHeight: 1.65, marginBottom: "var(--space-2)" }}>
            {typoSection.description}
          </p>
        )}
        {filteredText.length > 0
          ? <GlyphGrid glyphs={filteredText} />
          : q && <p className="text-sm text-[var(--text-muted)] font-mono py-[var(--space-1)]">No text glyphs match &ldquo;{search}&rdquo;</p>
        }
      </Subsection>

    </div>
  );
}

function matches(g: GlyphEntry, q: string): boolean {
  return g.name.toLowerCase().includes(q)
    || g.use.toLowerCase().includes(q)
    || g.glyph.includes(q)
    || (g.code?.toLowerCase().includes(q) ?? false);
}
