"use client";

import { Suspense } from "react";
import type { StyleGuideConfig, CssSnippet, JsxSnippet } from "@styleguide-engine/lib/types";
import { Subsection } from "./pkg/subsection";
import { PreviewCode } from "./pkg/preview-code";

// Static imports for known generated sections
// Add new generated sections here as they're created
let generatedModules: Record<string, Record<string, React.ComponentType>> = {};
try {
  // This will be populated at build time if the file exists
  const demo = require("@/components/generated/demo");
  generatedModules["demo"] = demo;
} catch {
  // File doesn't exist yet — that's fine
}

interface Props {
  config: StyleGuideConfig;
}

/* ─── CSS Snippet Card ─── */

function CssSnippetCard({ snippet }: { snippet: CssSnippet }) {
  return (
    <div
      className="flex flex-col"
      data-search-name={snippet.slug}
      data-search-title={snippet.title || ""}
      data-search-description={[snippet.description, snippet["target-section"], snippet.body].filter(Boolean).join(" ")}
    >
      <div className="min-w-full my-1 px-[var(--space-3)] py-[var(--space-1)] flex items-baseline gap-[var(--space-2)]">
        <span className="font-mono text-[length:var(--font-size-xs)] font-bold text-text">.{snippet.slug}</span>
        {snippet.title && (
          <span className="text-[length:var(--font-size-xs)] text-text-muted">{snippet.title}</span>
        )}
        {snippet["target-section"] && (
          <span className="font-mono text-[length:10px] text-text-muted bg-surface px-1 rounded-[var(--radius)]">
            {snippet["target-section"]}
          </span>
        )}
      </div>
      {snippet.description && (
        <p className="text-[length:var(--font-size-sm)] text-text-secondary leading-normal m-0 mb-[var(--space-1)]">
          {snippet.description}
        </p>
      )}
      <PreviewCode html={snippet.body}>
        {/* Render a live preview by injecting the CSS and showing a sample element */}
        <div dangerouslySetInnerHTML={{ __html: renderCssPreview(snippet) }} />
      </PreviewCode>
    </div>
  );
}

function renderCssPreview(snippet: CssSnippet): string {
  // Extract the primary class selector from the body
  const matches = [...snippet.body.matchAll(/\.([a-zA-Z][\w-]*(?:\.[a-zA-Z][\w-]*)*)/g)];
  if (!matches.length) return `<div style="padding: var(--space-2); font-family: var(--font-mono); font-size: var(--font-size-xs); color: var(--text-muted);">CSS snippet — no preview element</div>`;
  const cls = matches[0][1].replace(/\./g, " ");
  // Detect if it's a card variant
  const isCard = cls.includes("card");
  if (isCard) {
    return `<div class="${cls} regal" style="max-width: 320px;">
      <div class="card-header"><div class="card-title">.${matches[0][1]}</div></div>
      <div class="card-body">
        <p style="font-size: var(--font-size-sm); color: var(--text-secondary); margin: 0;">Live preview with snippet CSS applied</p>
      </div>
    </div>`;
  }
  return `<div class="${cls}" style="padding: var(--space-3);">
    <div style="font-family: var(--font-mono); font-size: var(--font-size-sm); margin-bottom: var(--space-1);">.${matches[0][1]}</div>
    <div style="font-size: var(--font-size-sm); color: var(--text-secondary);">Live preview with snippet CSS applied</div>
  </div>`;
}

/* ─── JSX Snippet Card ─── */

function JsxSnippetCard({ snippet, sectionComponents }: {
  snippet: JsxSnippet;
  sectionComponents: Record<string, React.ComponentType> | null;
}) {
  // Try to find an exported component matching the snippet
  const exportMatch = snippet.body.match(/export\s+function\s+(\w+)/);
  const componentName = exportMatch?.[1];
  const Component = componentName && sectionComponents?.[componentName] ? sectionComponents[componentName] : null;

  return (
    <div
      className="flex flex-col"
      data-search-name={snippet.slug}
      data-search-title={snippet.title || ""}
      data-search-description={[snippet.description, snippet["target-section"], snippet.body].filter(Boolean).join(" ")}
    >
      <div className="min-w-full my-1 px-[var(--space-3)] py-[var(--space-1)] flex items-baseline gap-[var(--space-2)]">
        <span className="font-mono text-[length:var(--font-size-xs)] font-bold text-text">@{snippet.slug}</span>
        {snippet.title && (
          <span className="text-[length:var(--font-size-xs)] text-text-muted">{snippet.title}</span>
        )}
        <span className="font-mono text-[length:10px] text-text-muted bg-surface px-1 rounded-[var(--radius)]">
          {snippet["target-section"]}
        </span>
      </div>
      {snippet.description && (
        <p className="text-[length:var(--font-size-sm)] text-text-secondary leading-normal m-0 mb-[var(--space-1)]">
          {snippet.description}
        </p>
      )}
      {Component ? (
        <PreviewCode html={`<!-- ${snippet.slug} -->`} jsx={snippet.body}>
          <Suspense fallback={<div className="text-sm text-text-muted">Loading...</div>}>
            <Component />
          </Suspense>
        </PreviewCode>
      ) : (
        <PreviewCode html={`<!-- ${snippet.slug} -->`} jsx={snippet.body}>
          <div className="font-mono text-[length:var(--font-size-xs)] text-text-muted p-[var(--space-2)]">
            {componentName ? `Component ${componentName} — render via import` : "Code fragment — no live preview"}
          </div>
        </PreviewCode>
      )}
    </div>
  );
}

/* ─── Exported Sub-Panels ─── */

export function CssSnippetsPanel({ config }: Props) {
  const cssSnippets = config.cssSnippets;
  if (!cssSnippets.length) return null;

  const cssSections = new Map<string, CssSnippet[]>();
  for (const s of cssSnippets) {
    const sec = s["target-section"] || "ungrouped";
    if (!cssSections.has(sec)) cssSections.set(sec, []);
    cssSections.get(sec)!.push(s);
  }

  return (
    <div className="flex flex-col gap-[var(--space-4)]">
      {[...cssSections.entries()].map(([section, snippets]) => (
        <div key={section}>
          <div className="bg-surface-inverse/15 min-w-full my-4 py-2 px-[var(--space-3)] font-mono text-[length:var(--font-size-xs)] font-bold text-text-muted uppercase tracking-widest">
            {section}
          </div>
          <div className="flex flex-col gap-[var(--space-3)]">
            {snippets.map((s) => <CssSnippetCard key={s.slug} snippet={s} />)}
          </div>
        </div>
      ))}
    </div>
  );
}

export function JsxSnippetsPanel({ config }: Props) {
  const jsxSnippets = config.jsxSnippets;
  if (!jsxSnippets.length) return null;

  const jsxSections = new Map<string, JsxSnippet[]>();
  for (const s of jsxSnippets) {
    const sec = s["target-section"];
    if (!jsxSections.has(sec)) jsxSections.set(sec, []);
    jsxSections.get(sec)!.push(s);
  }

  const loadedModules = generatedModules;

  return (
    <div className="flex flex-col gap-[var(--space-4)]">
      {[...jsxSections.entries()].map(([section, snippets]) => (
        <div key={section}>
          <div className="bg-surface-inverse/15 min-w-full my-4 py-2 px-[var(--space-3)] font-mono text-[length:var(--font-size-xs)] font-bold text-text-muted uppercase tracking-widest">
            {section}
          </div>
          <div className="flex flex-col gap-[var(--space-3)]">
            {snippets
              .filter((s) => s.body.includes("export function") || s.body.includes("export default"))
              .map((s) => (
                <JsxSnippetCard
                  key={s.slug}
                  snippet={s}
                  sectionComponents={loadedModules[section] || null}
                />
              ))}
            {snippets
              .filter((s) => !s.body.includes("export function") && !s.body.includes("export default"))
              .map((s) => (
                <div
                  key={s.slug}
                  className="flex items-baseline gap-[var(--space-2)]"
                  data-search-name={s.slug}
                  data-search-title={s.title || "imports"}
                  data-search-description=""
                >
                  <span className="font-mono text-[length:var(--font-size-xs)] text-text-muted">@{s.slug}</span>
                  <span className="text-[length:var(--font-size-xs)] text-text-muted">{s.title || "imports"}</span>
                </div>
              ))}
          </div>
        </div>
      ))}
    </div>
  );
}

/* ─── Main Showcase ─── */

export function SnippetShowcase({ config }: Props) {
  const cssSnippets = config.cssSnippets;
  const jsxSnippets = config.jsxSnippets;

  if (!cssSnippets.length && !jsxSnippets.length) {
    return <p className="text-sm text-text-muted font-mono">No snippets defined. Add css-snippets or jsx-snippets to your YAML config.</p>;
  }

  return (
    <div className="flex flex-col gap-[var(--space-3)]">
      {cssSnippets.length > 0 && (
        <Subsection id="snippets-css" title={`CSS Snippets (${cssSnippets.length})`}>
          <CssSnippetsPanel config={config} />
        </Subsection>
      )}
      {jsxSnippets.length > 0 && (
        <Subsection id="snippets-jsx" title={`JSX Snippets (${jsxSnippets.length})`}>
          <JsxSnippetsPanel config={config} />
        </Subsection>
      )}
    </div>
  );
}
