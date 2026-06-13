"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface CodeEditorProps {
  value: string;
  onChange?: (value: string) => void;
  language?: "yaml" | "json" | "plaintext" | "markdown" | "typescript";
  readOnly?: boolean;
  rows?: number;
  name?: string;
  id?: string;
  placeholder?: string;
  className?: string;
  style?: React.CSSProperties;
  cy?: string;
  "aria-describedby"?: string;
  "aria-invalid"?: boolean;
  "aria-required"?: boolean;
}

/**
 * Mono-font code input. Ships as a styled textarea to stay dependency-light —
 * callers wanting full Monaco features can swap in `@monaco-editor/react` directly.
 *
 * @example
 * <CodeEditor value={yaml} onChange={setYaml} language="yaml" rows={14} />
 */
export function CodeEditor({
  value,
  onChange,
  language = "yaml",
  readOnly = false,
  rows = 12,
  name,
  id,
  placeholder,
  className,
  style,
  cy = "code-editor",
  ...ariaProps
}: CodeEditorProps) {
  return (
    <textarea
      id={id}
      name={name}
      value={value}
      onChange={onChange ? (e) => onChange(e.target.value) : undefined}
      readOnly={readOnly}
      rows={rows}
      placeholder={placeholder}
      spellCheck={false}
      data-language={language}
      className={["sg-input", "sg-input--code", className || ""]
        .filter(Boolean)
        .join(" ")}
      style={{ width: "100%", resize: "vertical", ...style }}
      {...cyAttrs({ cy })}
      {...ariaProps}
    />
  );
}
