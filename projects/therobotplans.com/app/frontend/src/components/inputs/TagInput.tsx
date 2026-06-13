"use client";

import React, { useState, useRef } from "react";

/**
 * TagInput — Multi-value tag input with autocomplete, create-new, and visual chips.
 *
 * @example
 * ```tsx
 * <TagInput tags={["backend","urgent"]} onChange={setTags} suggestions={["backend","frontend","ops"]} allowCreate />
 * ```
 */

interface TagInputProps {
  tags: string[];
  onChange: (tags: string[]) => void;
  suggestions?: string[];
  allowCreate?: boolean;
  maxTags?: number;
  placeholder?: string;
}

export function TagInput({ tags, onChange, suggestions = [], allowCreate = true, maxTags, placeholder = "Add tag..." }: TagInputProps) {
  const [input, setInput] = useState("");
  const [showSuggestions, setShowSuggestions] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const filtered = suggestions.filter((s) => s.toLowerCase().includes(input.toLowerCase()) && !tags.includes(s));

  const addTag = (tag: string) => {
    const t = tag.trim();
    if (!t || tags.includes(t)) return;
    if (maxTags && tags.length >= maxTags) return;
    onChange([...tags, t]);
    setInput("");
    setShowSuggestions(false);
  };

  const removeTag = (tag: string) => onChange(tags.filter((t) => t !== tag));

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && input.trim()) { e.preventDefault(); if (filtered.length > 0) addTag(filtered[0]); else if (allowCreate) addTag(input); }
    if (e.key === "Backspace" && !input && tags.length > 0) removeTag(tags[tags.length - 1]);
  };

  return (
    <div style={{ position: "relative" }}>
      <div onClick={() => inputRef.current?.focus()} style={{ display: "flex", flexWrap: "wrap", gap: "4px", padding: "4px 8px", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--surface)", minHeight: 32, alignItems: "center", cursor: "text" }}>
        {tags.map((tag) => (
          <span key={tag} style={{ display: "inline-flex", alignItems: "center", gap: "3px", padding: "1px 8px", borderRadius: "999px", background: "color-mix(in srgb, var(--info, var(--blue)) 12%, transparent)", color: "var(--info, var(--blue))", fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 500 }}>
            {tag}
            <button type="button" onClick={() => removeTag(tag)} style={{ background: "none", border: "none", color: "var(--info, var(--blue))", cursor: "pointer", padding: 0, fontSize: "var(--font-size-xs)", lineHeight: 1 }}>✕</button>
          </span>
        ))}
        <input ref={inputRef} type="text" value={input} onChange={(e) => { setInput(e.target.value); setShowSuggestions(true); }} onFocus={() => setShowSuggestions(true)} onBlur={() => setTimeout(() => setShowSuggestions(false), 150)} onKeyDown={handleKeyDown} placeholder={tags.length === 0 ? placeholder : ""} style={{ flex: 1, minWidth: 60, background: "none", border: "none", outline: "none", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", padding: 0 }} />
      </div>
      {showSuggestions && filtered.length > 0 && (
        <div style={{ position: "absolute", top: "100%", left: 0, right: 0, marginTop: 4, borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: "var(--bg)", boxShadow: "var(--shadow, 0 2px 8px rgba(0,0,0,0.1))", zIndex: 10, maxHeight: 160, overflow: "auto" }}>
          {filtered.map((s) => (
            <div key={s} onMouseDown={() => addTag(s)} style={{ padding: "4px 10px", cursor: "pointer", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", color: "var(--text)" }}>{s}</div>
          ))}
        </div>
      )}
    </div>
  );
}

export default TagInput;
