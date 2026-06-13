"use client";

import { Subsection } from "./pkg/subsection";

// ── Static example code fragments ──
// No syntax highlighting library — just styled spans mapped to CSS vars.

function KW({ children }: { children: React.ReactNode }) {
  return <span style={{ color: "var(--code-keyword)" }}>{children}</span>;
}
function STR({ children }: { children: React.ReactNode }) {
  return <span style={{ color: "var(--code-string)" }}>{children}</span>;
}
function CMT({ children }: { children: React.ReactNode }) {
  return <span style={{ color: "var(--code-comment)", fontStyle: "italic" }}>{children}</span>;
}
function FN({ children }: { children: React.ReactNode }) {
  return <span style={{ color: "var(--code-function)" }}>{children}</span>;
}
function NUM({ children }: { children: React.ReactNode }) {
  return <span style={{ color: "var(--code-number)" }}>{children}</span>;
}

function CodeWindow({
  filename,
  children,
  lineNumbers = false,
}: {
  filename?: string;
  children: React.ReactNode;
  lineNumbers?: boolean;
}) {
  return (
    <div className="code-window">
      {filename && (
        <div className="code-title-bar">
          <span className="code-title-bar-dots">
            <span />
            <span />
            <span />
          </span>
          <span className="code-title-bar-filename">{filename}</span>
        </div>
      )}
      <pre className={`code-block${lineNumbers ? " code-block-lined" : ""}`}>
        {children}
      </pre>
    </div>
  );
}

const SAMPLE_LINES = [
  <><CMT>{"// Fibonacci with memoization"}</CMT></>,
  <><KW>function</KW> <FN>fib</FN>(<KW>n</KW>: <KW>number</KW>, memo: Map&lt;<KW>number</KW>, <KW>number</KW>&gt; = <KW>new</KW> <FN>Map</FN>()): <KW>number</KW> {"{"}</>,
  <>{"  "}<KW>if</KW> (n &lt;= <NUM>1</NUM>) <KW>return</KW> n;</>,
  <>{"  "}<KW>if</KW> (memo.<FN>has</FN>(n)) <KW>return</KW> memo.<FN>get</FN>(n)!;</>,
  <>{"  "}<KW>const</KW> result = <FN>fib</FN>(n - <NUM>1</NUM>, memo) + <FN>fib</FN>(n - <NUM>2</NUM>, memo);</>,
  <>{"  "}memo.<FN>set</FN>(n, result);</>,
  <>{"  "}<KW>return</KW> result;</>,
  <>{"}"}</>,
  <></>,
  <><FN>console</FN>.<FN>log</FN>(<FN>fib</FN>(<NUM>10</NUM>)); <CMT>{"// → 55"}</CMT></>,
];

function LineNumberedCode() {
  return (
    <CodeWindow filename="fibonacci.ts" lineNumbers>
      {SAMPLE_LINES.map((line, i) => (
        <div key={i} className="code-line">
          <span className="code-line-number">{i + 1}</span>
          <span className="code-line-content">{line}</span>
        </div>
      ))}
    </CodeWindow>
  );
}

function PlainCode() {
  return (
    <CodeWindow>
      <code>
        {SAMPLE_LINES.map((line, i) => (
          <div key={i}>{line}</div>
        ))}
      </code>
    </CodeWindow>
  );
}

function InlineCodeExamples() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
      <p style={{ fontSize: "var(--font-size-sm)", color: "var(--text-secondary)", lineHeight: "var(--line-height-relaxed)" }}>
        Use <code className="code-inline">Array.from()</code> to convert iterables. The{" "}
        <code className="code-inline">Promise.all()</code> method runs tasks concurrently.
        Pass <code className="code-inline">--watch</code> to enable live reload.
      </p>
      <p style={{ fontSize: "var(--font-size-sm)", color: "var(--text-secondary)", lineHeight: "var(--line-height-relaxed)" }}>
        Set the <code className="code-inline">NODE_ENV</code> variable to{" "}
        <code className="code-inline">&quot;production&quot;</code> before deploying.
      </p>
    </div>
  );
}

export function CodeBlockShowcase() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-3)" }}>
      <Subsection id="code-inline" title="Inline Code">
        <InlineCodeExamples />
      </Subsection>

      <Subsection id="code-block" title="Code Block">
        <PlainCode />
      </Subsection>

      <Subsection id="code-lined" title="Code Block with Filename & Line Numbers">
        <LineNumberedCode />
      </Subsection>
    </div>
  );
}
