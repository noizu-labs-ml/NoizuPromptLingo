"use client";

import { useState, useCallback } from "react";
import Editor from "@monaco-editor/react";
import { useMonacoTheme } from "@styleguide-engine/lib/use-monaco-theme";

type View = "preview" | "html" | "react";

interface Props {
  html: string;
  jsx?: string;
  children: React.ReactNode;
}

const TABS: { view: View; label: string }[] = [
  { view: "preview", label: "Preview" },
  { view: "html", label: "HTML" },
  { view: "react", label: "React" },
];

export function PreviewCode({ html, jsx, children }: Props) {
  const [view, setView] = useState<View>("preview");
  const [copied, setCopied] = useState(false);
  const monacoTheme = useMonacoTheme();
  const activeCode = view === "react" ? jsx || "" : html;
  const language = view === "react" ? "typescript" : "html";
  const lineCount = activeCode.split("\n").length;
  const editorHeight = Math.min(Math.max(lineCount * 19 + 24, 80), 400);

  const copyCode = useCallback(() => {
    navigator.clipboard.writeText(activeCode).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 1200);
    });
  }, [activeCode]);

  return (
    <div className="sg-preview-code">
      <div className="sg-preview-code-tabs">
        {TABS.map((t) => {
          if (t.view === "react" && !jsx) return null;
          return (
            <button
              key={t.view}
              className={`sg-preview-code-tab${view === t.view ? " active" : ""}`}
              onClick={() => setView(t.view)}
            >
              {t.label}
            </button>
          );
        })}
        <button className="sg-preview-code-copy" onClick={copyCode}>
          {copied ? "Copied" : "Copy"}
        </button>
      </div>
      {view === "preview" ? (
        <div className="sg-preview-code-preview">{children}</div>
      ) : (
        <Editor
          height={editorHeight}
          language={language}
          value={activeCode}
          theme={monacoTheme}
          options={{
            readOnly: true,
            minimap: { enabled: false },
            fontSize: 12,
            lineHeight: 19,
            fontFamily: "'IBM Plex Mono', 'Menlo', monospace",
            scrollBeyondLastLine: false,
            wordWrap: "on",
            renderLineHighlight: "none",
            overviewRulerBorder: false,
            hideCursorInOverviewRuler: true,
            folding: true,
            showFoldingControls: "mouseover",
            lineNumbers: "on",
            padding: { top: 12, bottom: 12 },
            scrollbar: {
              verticalScrollbarSize: 6,
              horizontalScrollbarSize: 6,
            },
          }}
        />
      )}
    </div>
  );
}
