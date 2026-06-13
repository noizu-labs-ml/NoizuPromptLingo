"use client";

import { useState, useCallback } from "react";
import Editor from "@monaco-editor/react";
import { Listbox, ListboxButton, ListboxOptions, ListboxOption } from "@headlessui/react";
import { useMonacoTheme } from "@styleguide-engine/lib/use-monaco-theme";
import type { CssSection } from "@styleguide-engine/lib/css-gen";

interface Props {
  sections: CssSection[];
}

export function CssViewer({ sections }: Props) {
  const [activeIdx, setActiveIdx] = useState(0);
  const [copied, setCopied] = useState(false);
  const monacoTheme = useMonacoTheme();

  const current = sections[activeIdx];
  const lineCount = current.css.split("\n").length;
  const editorHeight = Math.min(Math.max(lineCount * 19, 200), 600);

  const copyAll = useCallback(() => {
    navigator.clipboard.writeText(sections.map((s) => s.css).join("\n\n")).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 1200);
    });
  }, [sections]);

  const copyCurrent = useCallback(() => {
    navigator.clipboard.writeText(current.css).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 1200);
    });
  }, [current]);

  return (
    <div className="flex flex-col">
      {/* Toolbar */}
      <div className="flex items-center gap-3 border border-border px-3 py-2" style={{ background: "var(--surface-alt)" }}>
        {/* Section selector */}
        <Listbox value={activeIdx} onChange={setActiveIdx}>
          <div className="relative">
            <ListboxButton className="hui listbox-btn" style={{ minWidth: 180 }}>
              <span className="font-mono text-xs font-semibold">{current.name}.css</span>
            </ListboxButton>
            <ListboxOptions className="hui listbox-options" style={{ minWidth: 220 }}>
              {sections.map((s, i) => (
                <ListboxOption key={s.name} value={i} className="hui listbox-option">
                  <span className="flex items-center gap-1.5 w-full">
                    <span className="font-mono text-xs">{s.name}</span>
                    <span className="text-text-muted text-xs ml-auto">
                      {s.css.split("\n").length} lines
                    </span>
                  </span>
                </ListboxOption>
              ))}
            </ListboxOptions>
          </div>
        </Listbox>

        {/* Prev / Next */}
        <div className="flex gap-0.5">
          <button
            className="btn btn-sm btn-outline"
            style={{ padding: "4px 8px", fontSize: "var(--font-size-xs)" }}
            onClick={() => setActiveIdx(Math.max(0, activeIdx - 1))}
            disabled={activeIdx === 0}
          >
            ‹
          </button>
          <button
            className="btn btn-sm btn-outline"
            style={{ padding: "4px 8px", fontSize: "var(--font-size-xs)" }}
            onClick={() => setActiveIdx(Math.min(sections.length - 1, activeIdx + 1))}
            disabled={activeIdx === sections.length - 1}
          >
            ›
          </button>
        </div>

        {/* Status + actions */}
        <div className="ml-auto flex items-center gap-2">
          <span className="font-mono text-xs text-text-muted">
            {lineCount} lines
          </span>
          <button className="btn btn-sm btn-outline" onClick={copyCurrent} style={{ fontSize: "var(--font-size-xs)" }}>
            {copied ? "Copied" : "Copy section"}
          </button>
          <button className="btn btn-sm" onClick={copyAll} style={{ fontSize: "var(--font-size-xs)" }}>
            Copy all
          </button>
        </div>
      </div>

      {/* Editor */}
      <div className="border border-t-0 border-border">
        <Editor
          height={editorHeight}
          language="css"
          value={current.css}
          theme={monacoTheme}
          options={{
            readOnly: true,
            minimap: { enabled: false },
            fontSize: 12,
            lineHeight: 19,
            fontFamily: "'IBM Plex Mono', 'Menlo', monospace",
            scrollBeyondLastLine: false,
            wordWrap: "off",
            renderLineHighlight: "gutter",
            overviewRulerBorder: false,
            hideCursorInOverviewRuler: true,
            folding: true,
            foldingHighlight: false,
            showFoldingControls: "mouseover",
            padding: { top: 12, bottom: 12 },
            scrollbar: {
              verticalScrollbarSize: 8,
              horizontalScrollbarSize: 8,
            },
          }}
        />
      </div>
    </div>
  );
}
