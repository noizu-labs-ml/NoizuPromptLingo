import React, { useState, useEffect, useRef, useId } from "react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import remarkMath from "remark-math";
import rehypeKatex from "rehype-katex";
import { Prism as SyntaxHighlighter } from "react-syntax-highlighter";
import { oneDark } from "react-syntax-highlighter/dist/esm/styles/prism";
import mermaid from "mermaid";

mermaid.initialize({
  startOnLoad: false,
  theme: "dark",
  themeVariables: {
    primaryColor: "#0891b2",
    primaryTextColor: "#e2e8f0",
    primaryBorderColor: "#334155",
    lineColor: "#64748b",
    secondaryColor: "#1e293b",
    tertiaryColor: "#0f172a",
    fontFamily: "ui-monospace, monospace",
  },
});

interface MarkdownViewProps {
  content: string;
}

export function MarkdownView({ content }: MarkdownViewProps) {
  const [mode, setMode] = useState<"rendered" | "source">("rendered");
  const hasRichContent = /[#*`\[|>~]|^\d+\./m.test(content);

  return (
    <div>
      {/* Tab bar — only show when content has actual markdown formatting */}
      {hasRichContent && (
        <div className="flex gap-1 mb-2">
          <button
            onClick={() => setMode("rendered")}
            className={`rounded-md px-2 py-0.5 text-xs transition-colors ${
              mode === "rendered"
                ? "bg-glow/15 text-glow"
                : "text-text-dim hover:text-text-muted"
            }`}
          >
            Rendered
          </button>
          <button
            onClick={() => setMode("source")}
            className={`rounded-md px-2 py-0.5 text-xs transition-colors ${
              mode === "source"
                ? "bg-glow/15 text-glow"
                : "text-text-dim hover:text-text-muted"
            }`}
          >
            Source
          </button>
        </div>
      )}

      {mode === "source" ? (
        <SyntaxHighlighter
          language="markdown"
          style={oneDark}
          customStyle={{
            margin: 0,
            borderRadius: "0.375rem",
            fontSize: "0.75rem",
            background: "#0E0E12",
          }}
          wrapLongLines
        >
          {content}
        </SyntaxHighlighter>
      ) : (
        <div className="prose prose-invert prose-base max-w-none text-text-bright
          prose-headings:text-white prose-headings:font-medium prose-headings:mt-5 prose-headings:mb-2
          prose-p:my-2 prose-p:leading-relaxed
          prose-a:text-glow prose-a:no-underline hover:prose-a:underline
          prose-strong:text-white prose-strong:font-semibold
          prose-code:text-glow prose-code:bg-surface prose-code:px-1 prose-code:py-0.5 prose-code:rounded prose-code:text-xs prose-code:before:content-none prose-code:after:content-none
          prose-pre:my-2 prose-pre:p-0 prose-pre:bg-transparent
          prose-ul:my-1.5 prose-ol:my-1.5 prose-li:my-0.5
          prose-blockquote:border-glow/40 prose-blockquote:text-text-muted
          prose-table:text-xs prose-th:text-text-bright prose-td:border-border-subtle prose-th:border-border-subtle
          prose-hr:border-border-subtle
        ">
          <ReactMarkdown
            remarkPlugins={[remarkGfm, remarkMath]}
            rehypePlugins={[rehypeKatex]}
            components={{
              code({ className, children, ...props }) {
                const match = /language-(\w+)/.exec(className || "");
                const codeStr = String(children).replace(/\n$/, "");

                if (match && match[1] === "mermaid") {
                  return <MermaidBlock chart={codeStr} />;
                }

                if (match) {
                  return (
                    <div className="relative group">
                      <SyntaxHighlighter
                        style={oneDark}
                        language={match[1]}
                        customStyle={{
                          margin: 0,
                          borderRadius: "0.375rem",
                          fontSize: "0.75rem",
                          background: "#0E0E12",
                        }}
                        wrapLongLines
                      >
                        {codeStr}
                      </SyntaxHighlighter>
                      <button
                        onClick={() => navigator.clipboard.writeText(codeStr)}
                        className="absolute top-2 right-2 rounded bg-surface-active px-1.5 py-0.5 text-xs text-text-dim opacity-0 group-hover:opacity-100 transition-opacity"
                      >
                        Copy
                      </button>
                    </div>
                  );
                }

                return (
                  <code className={className} {...props}>
                    {children}
                  </code>
                );
              },
            }}
          >
            {content}
          </ReactMarkdown>
        </div>
      )}
    </div>
  );
}

function MermaidBlock({ chart }: { chart: string }) {
  const ref = useRef<HTMLDivElement>(null);
  const uniqueId = useId().replace(/:/g, "-");
  const [svg, setSvg] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    mermaid
      .render(`mermaid-${uniqueId}`, chart)
      .then(({ svg }) => {
        if (!cancelled) setSvg(svg);
      })
      .catch((err) => {
        if (!cancelled) setError(err.message ?? "Failed to render diagram");
      });
    return () => { cancelled = true; };
  }, [chart, uniqueId]);

  if (error) {
    return (
      <div className="rounded border border-red-900/50 bg-red-950/20 p-3 text-xs text-red-400">
        <p className="font-medium mb-1">Mermaid error</p>
        <pre className="whitespace-pre-wrap">{error}</pre>
        <pre className="mt-2 text-text-dim whitespace-pre-wrap">{chart}</pre>
      </div>
    );
  }

  if (!svg) {
    return <div className="text-xs text-text-dim p-2">Rendering diagram...</div>;
  }

  return (
    <div
      ref={ref}
      className="my-2 flex justify-center rounded bg-surface p-4 overflow-x-auto"
      dangerouslySetInnerHTML={{ __html: svg }}
    />
  );
}
