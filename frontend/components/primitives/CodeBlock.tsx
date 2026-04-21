"use client";

import clsx from "clsx";
import { useState } from "react";
import { ClipboardIcon, CheckIcon } from "@heroicons/react/20/solid";

export interface CodeBlockProps {
  code: string;
  language?: string;
  maxHeight?: string;
}

export function CodeBlock({ code, language, maxHeight }: CodeBlockProps) {
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    await navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="relative group rounded-lg bg-surface-sunken border border-border overflow-hidden">
      {language && (
        <div className="px-4 py-1.5 text-xs text-muted border-b border-border bg-surface-raised/50">
          {language}
        </div>
      )}
      <button
        type="button"
        onClick={handleCopy}
        className={clsx(
          "absolute top-2 right-2 p-1.5 rounded-md transition-colors",
          "bg-surface-raised/80 hover:bg-surface-raised border border-border",
          "text-muted hover:text-foreground",
          "opacity-0 group-hover:opacity-100 focus:opacity-100"
        )}
        aria-label="Copy code"
      >
        {copied ? (
          <CheckIcon className="h-4 w-4 text-success" />
        ) : (
          <ClipboardIcon className="h-4 w-4" />
        )}
      </button>
      <pre
        className={clsx(
          "font-mono text-sm p-4 overflow-x-auto",
          maxHeight && "overflow-y-auto"
        )}
        style={maxHeight ? { maxHeight } : undefined}
      >
        <code>{code}</code>
      </pre>
    </div>
  );
}
