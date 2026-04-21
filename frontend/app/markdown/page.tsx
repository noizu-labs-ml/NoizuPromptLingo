"use client";

import { useState } from "react";
import clsx from "clsx";
import { DocumentArrowDownIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { ToMarkdownResult } from "@/lib/api/types";
import { PageHeader } from "@/components/primitives/PageHeader";
import { CodeBlock } from "@/components/primitives/CodeBlock";

// ── Page ──────────────────────────────────────────────────────────────────

export default function MarkdownConverterPage() {
  const [source, setSource] = useState("");
  const [headingFilter, setHeadingFilter] = useState("");
  const [collapseDepth, setCollapseDepth] = useState<string>("");
  const [bare, setBare] = useState(false);
  const [withImageDescriptions, setWithImageDescriptions] = useState(false);
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<ToMarkdownResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function handleConvert() {
    if (!source.trim()) return;
    setLoading(true);
    setError(null);
    setResult(null);
    try {
      const depth = collapseDepth ? parseInt(collapseDepth, 10) : undefined;
      const res = await api.browser.toMarkdown({
        source: source.trim(),
        heading_filter: headingFilter.trim() || null,
        collapse_depth: depth ?? null,
        bare,
        with_image_descriptions: withImageDescriptions,
      });
      setResult(res);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Conversion request failed.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex flex-col gap-6 p-6 max-w-7xl mx-auto">
      <PageHeader
        title="Markdown Converter"
        description="Fetch a URL or local file and convert to Markdown."
      />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
        {/* Left column: form */}
        <div className="flex flex-col gap-4">
          {/* Source input */}
          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium text-muted uppercase tracking-wide">
              URL or file path <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              value={source}
              onChange={(e) => setSource(e.target.value)}
              placeholder="https://example.com or /path/to/file.html"
              className="rounded-md border border-border bg-surface px-3 py-1.5 text-sm text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/40"
            />
          </div>

          {/* Heading filter */}
          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium text-muted uppercase tracking-wide">
              Heading filter <span className="normal-case font-normal">(optional)</span>
            </label>
            <input
              type="text"
              value={headingFilter}
              onChange={(e) => setHeadingFilter(e.target.value)}
              placeholder='e.g. "Overview" or "API Reference"'
              className="rounded-md border border-border bg-surface px-3 py-1.5 text-sm text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/40"
            />
          </div>

          {/* Collapse depth */}
          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium text-muted uppercase tracking-wide">
              Collapse depth <span className="normal-case font-normal">(1–6, optional)</span>
            </label>
            <input
              type="number"
              min={1}
              max={6}
              value={collapseDepth}
              onChange={(e) => setCollapseDepth(e.target.value)}
              placeholder="e.g. 3"
              className="rounded-md border border-border bg-surface px-3 py-1.5 text-sm text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/40 w-28"
            />
          </div>

          {/* Checkboxes */}
          <div className="flex flex-col gap-2">
            <label className="flex items-center gap-2 cursor-pointer select-none">
              <input
                type="checkbox"
                checked={bare}
                onChange={(e) => setBare(e.target.checked)}
                className="h-4 w-4 rounded border-border accent-accent"
              />
              <span className="text-sm text-foreground">Bare mode (extract matched section only)</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer select-none">
              <input
                type="checkbox"
                checked={withImageDescriptions}
                onChange={(e) => setWithImageDescriptions(e.target.checked)}
                className="h-4 w-4 rounded border-border accent-accent"
              />
              <span className="text-sm text-foreground">Inject image descriptions</span>
            </label>
          </div>

          {/* Convert button */}
          <button
            onClick={handleConvert}
            disabled={loading || !source.trim()}
            className={clsx(
              "flex items-center justify-center gap-2 rounded-md px-4 py-2 text-sm font-medium transition-colors",
              loading || !source.trim()
                ? "bg-surface-raised text-subtle cursor-not-allowed"
                : "bg-accent text-white hover:bg-accent/90"
            )}
          >
            <DocumentArrowDownIcon className="h-4 w-4" />
            {loading ? "Converting…" : "Convert"}
          </button>

          {/* Error */}
          {error && (
            <div className="rounded-lg border border-red-500/20 bg-red-500/10 px-4 py-3">
              <p className="text-sm text-red-500">{error}</p>
            </div>
          )}
        </div>

        {/* Right column: preview (sticky) */}
        <div className="lg:sticky lg:top-6 flex flex-col gap-3">
          <div className="flex items-center justify-between">
            <p className="text-xs font-medium text-muted uppercase tracking-wide">
              Preview
            </p>
            {result && (
              <span className="rounded-full bg-accent/10 text-accent border border-accent/20 px-2 py-0.5 text-[11px] font-semibold">
                {result.char_count.toLocaleString()} chars
              </span>
            )}
          </div>

          {!result && !loading && (
            <div className="flex flex-col items-center justify-center rounded-lg border border-dashed border-border p-12 text-center">
              <DocumentArrowDownIcon className="h-8 w-8 text-subtle mb-2" />
              <p className="text-sm text-muted">Enter a URL or file path and click Convert.</p>
            </div>
          )}

          {loading && (
            <div className="flex items-center justify-center p-12">
              <div className="h-6 w-6 rounded-full border-2 border-accent border-t-transparent animate-spin" />
            </div>
          )}

          {result && (
            <CodeBlock
              code={result.markdown}
              language="markdown"
              maxHeight="75vh"
            />
          )}
        </div>
      </div>
    </div>
  );
}
