"use client";

import React, { useState, useMemo } from "react";

/**
 * InlineMetadataInput — Text input that parses inline syntax (#project, @priority, !date) into structured metadata chips.
 * Depends on: VoiceCaptureButton (T2).
 *
 * @example
 * ```tsx
 * <InlineMetadataInput value={text} onChange={setText} onMetadata={setMeta} placeholder="Buy groceries #personal @p2 !tomorrow" />
 * ```
 */

interface ParsedMeta { type: "project" | "priority" | "date" | "tag"; value: string; raw: string; }

interface InlineMetadataInputProps {
  value: string;
  onChange: (value: string) => void;
  onMetadata?: (meta: ParsedMeta[]) => void;
  placeholder?: string;
  variant?: "inline" | "expanded";
}

function parseMeta(text: string): ParsedMeta[] {
  const meta: ParsedMeta[] = [];
  const patterns: [RegExp, ParsedMeta["type"]][] = [
    [/#(\S+)/g, "project"],
    [/@(p[0-3])\b/g, "priority"],
    [/!(tomorrow|today|next\s+week|next\s+month|\d{4}-\d{2}-\d{2})/gi, "date"],
    [/\+(\S+)/g, "tag"],
  ];
  for (const [re, type] of patterns) {
    let m;
    while ((m = re.exec(text)) !== null) {
      meta.push({ type, value: m[1], raw: m[0] });
    }
  }
  return meta;
}

const metaColors: Record<string, string> = {
  project: "var(--info, var(--blue))",
  priority: "var(--warning)",
  date: "var(--success)",
  tag: "var(--violet, #7C3AED)",
};

export function InlineMetadataInput({ value, onChange, onMetadata, placeholder = "Type with #project @p1 !tomorrow...", variant = "inline" }: InlineMetadataInputProps) {
  const meta = useMemo(() => parseMeta(value), [value]);

  const handleChange = (v: string) => {
    onChange(v);
    const parsed = parseMeta(v);
    onMetadata?.(parsed);
  };

  const removeMeta = (raw: string) => {
    handleChange(value.replace(raw, "").replace(/\s{2,}/g, " ").trim());
  };

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
      {variant === "expanded" ? (
        <textarea value={value} onChange={(e) => handleChange(e.target.value)} placeholder={placeholder} rows={3} style={{ padding: "var(--space-2)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", resize: "vertical" }} />
      ) : (
        <input type="text" value={value} onChange={(e) => handleChange(e.target.value)} placeholder={placeholder} style={{ padding: "6px 10px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-sm)", outline: "none" }} />
      )}
      {meta.length > 0 && (
        <div style={{ display: "flex", flexWrap: "wrap", gap: "4px" }}>
          {meta.map((m, i) => (
            <span key={i} style={{ display: "inline-flex", alignItems: "center", gap: "3px", padding: "1px 8px", borderRadius: "999px", background: `color-mix(in srgb, ${metaColors[m.type]} 12%, transparent)`, color: metaColors[m.type], fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 500 }}>
              {m.type === "project" ? "#" : m.type === "priority" ? "@" : m.type === "date" ? "!" : "+"}{m.value}
              <button type="button" onClick={() => removeMeta(m.raw)} style={{ background: "none", border: "none", color: metaColors[m.type], cursor: "pointer", padding: 0, fontSize: "var(--font-size-xs)", lineHeight: 1 }}>✕</button>
            </span>
          ))}
        </div>
      )}
    </div>
  );
}

export default InlineMetadataInput;
