"use client";

import { useState, useRef, useCallback } from "react";
import Editor, { type OnMount } from "@monaco-editor/react";
import type { editor } from "monaco-editor";
import { Listbox, ListboxButton, ListboxOptions, ListboxOption } from "@headlessui/react";
import { useMonacoTheme } from "@styleguide-engine/lib/use-monaco-theme";

interface YamlFile {
  name: string;
  content: string;
}

interface Props {
  styleGuideFiles: YamlFile[];
  brandingYaml: string;
}

function shortName(name: string): string {
  return name.replace("style-guide.", "").replace(".yaml", "");
}

export function YamlConfigViewer({ styleGuideFiles, brandingYaml }: Props) {
  const allFiles: YamlFile[] = [
    ...styleGuideFiles,
    { name: "branding.yaml", content: brandingYaml },
  ];

  const [activeFile, setActiveFile] = useState(allFiles[0]?.name ?? "");
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState<string | null>(null);
  const [dirty, setDirty] = useState<Record<string, string>>({});
  const editorRef = useRef<editor.IStandaloneCodeEditor | null>(null);
  const monacoTheme = useMonacoTheme();

  const current = allFiles.find((f) => f.name === activeFile) ?? allFiles[0];
  const currentContent = dirty[activeFile] ?? current?.content ?? "";
  const lineCount = currentContent.split("\n").length;
  const editorHeight = Math.min(Math.max(lineCount * 19, 300), 600);

  const isSaveable = current?.name.startsWith("style-guide.") && current?.name.endsWith(".yaml");
  const isDirty = activeFile in dirty;
  const dirtyCount = Object.keys(dirty).length;

  const handleMount: OnMount = (editor) => {
    editorRef.current = editor;
  };

  const handleChange = useCallback((value: string | undefined) => {
    if (value !== undefined && current) {
      if (value === current.content) {
        setDirty((d) => { const next = { ...d }; delete next[activeFile]; return next; });
      } else {
        setDirty((d) => ({ ...d, [activeFile]: value }));
      }
    }
  }, [activeFile, current]);

  const handleSave = useCallback(async () => {
    if (!isSaveable || !current) return;
    const variantName = prompt("Variant name (e.g. dark, compact, v2):", "user");
    if (!variantName) return;
    const sanitized = variantName.toLowerCase().replace(/[^a-z0-9-]/g, "-").replace(/(^-|-$)/g, "");
    if (!sanitized) return;
    const section = current.name.replace("style-guide.", "").replace(/\..*\.yaml$/, "").replace(".yaml", "");
    const content = dirty[activeFile] ?? current.content;
    setSaving(true);
    try {
      const res = await fetch("/api/save-config", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action: "save", section, variant: sanitized, content }),
      });
      const data = await res.json();
      if (res.ok) {
        setSaved(data.saved);
        setDirty((d) => { const next = { ...d }; delete next[activeFile]; return next; });
        setTimeout(() => setSaved(null), 3000);
      }
    } finally {
      setSaving(false);
    }
  }, [activeFile, current, dirty, isSaveable]);

  return (
    <div className="flex flex-col">
      {/* Toolbar */}
      <div className="flex items-center gap-3 border border-border px-3 py-2" style={{ background: "var(--surface-alt)" }}>
        {/* File selector */}
        <Listbox value={activeFile} onChange={setActiveFile}>
          <div className="relative">
            <ListboxButton className="hui listbox-btn" style={{ minWidth: 220 }}>
              <span className="flex items-center gap-1.5">
                {isDirty && <span style={{ color: "var(--warning)" }}>●</span>}
                <span className="font-mono text-xs font-semibold">{shortName(current?.name ?? "")}</span>
                <span className="text-text-muted text-xs">.yaml</span>
              </span>
            </ListboxButton>
            <ListboxOptions className="hui listbox-options" style={{ minWidth: 280 }}>
              {allFiles.map((f) => {
                const fileIsDirty = f.name in dirty;
                return (
                  <ListboxOption key={f.name} value={f.name} className="hui listbox-option">
                    <span className="flex items-center gap-1.5 w-full">
                      {fileIsDirty && <span style={{ color: "var(--warning)" }}>●</span>}
                      <span className="font-mono text-xs">{shortName(f.name)}</span>
                      <span className="text-text-muted text-xs ml-auto">
                        {f.name.endsWith(".css") ? "css" : "yaml"}
                      </span>
                    </span>
                  </ListboxOption>
                );
              })}
            </ListboxOptions>
          </div>
        </Listbox>

        {/* Prev / Next */}
        <div className="flex gap-0.5">
          <button
            className="btn btn-sm btn-outline"
            style={{ padding: "4px 8px", fontSize: "var(--font-size-xs)" }}
            onClick={() => {
              const idx = allFiles.findIndex((f) => f.name === activeFile);
              if (idx > 0) setActiveFile(allFiles[idx - 1].name);
            }}
            disabled={allFiles.findIndex((f) => f.name === activeFile) === 0}
          >
            ‹
          </button>
          <button
            className="btn btn-sm btn-outline"
            style={{ padding: "4px 8px", fontSize: "var(--font-size-xs)" }}
            onClick={() => {
              const idx = allFiles.findIndex((f) => f.name === activeFile);
              if (idx < allFiles.length - 1) setActiveFile(allFiles[idx + 1].name);
            }}
            disabled={allFiles.findIndex((f) => f.name === activeFile) === allFiles.length - 1}
          >
            ›
          </button>
        </div>

        {/* Status */}
        <div className="ml-auto flex items-center gap-2">
          {dirtyCount > 0 && (
            <span className="font-mono text-xs" style={{ color: "var(--warning)" }}>
              {dirtyCount} unsaved
            </span>
          )}
          <span className="font-mono text-xs text-text-muted">
            {lineCount} lines
          </span>
          <button
            className="btn btn-sm"
            onClick={handleSave}
            disabled={saving || !isSaveable}
            style={{ fontSize: "var(--font-size-xs)" }}
          >
            {saving ? "Saving…" : saved ? `→ ${saved}` : isDirty ? "Save variant" : "Save copy"}
          </button>
        </div>
      </div>

      {/* Editor */}
      <div className="border border-t-0 border-border">
        <Editor
          height={editorHeight}
          language={"yaml"}
          value={currentContent}
          theme={monacoTheme}
          onMount={handleMount}
          onChange={handleChange}
          options={{
            readOnly: false,
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
