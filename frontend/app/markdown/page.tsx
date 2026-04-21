"use client";

import { useState } from "react";
import { DocumentArrowDownIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { ToMarkdownResult } from "@/lib/api/types";
import { PageHeader } from "@/components/primitives/PageHeader";
import { CodeBlock } from "@/components/primitives/CodeBlock";
import { Button } from "@/components/primitives/Button";
import { Input } from "@/components/primitives/Input";
import { FormField } from "@/components/primitives/FormField";

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
          <FormField label={<>URL or file path <span className="text-danger">*</span></>} htmlFor="md-source">
            <Input
              id="md-source"
              type="text"
              value={source}
              onChange={(e) => setSource(e.target.value)}
              placeholder="https://example.com or /path/to/file.html"
            />
          </FormField>

          {/* Heading filter */}
          <FormField
            label={<>Heading filter <span className="normal-case font-normal">(optional)</span></>}
            htmlFor="md-heading-filter"
          >
            <Input
              id="md-heading-filter"
              type="text"
              value={headingFilter}
              onChange={(e) => setHeadingFilter(e.target.value)}
              placeholder='e.g. "Overview" or "API Reference"'
            />
          </FormField>

          {/* Collapse depth */}
          <FormField
            label={<>Collapse depth <span className="normal-case font-normal">(1–6, optional)</span></>}
            htmlFor="md-collapse-depth"
            className="w-28"
          >
            <Input
              id="md-collapse-depth"
              type="number"
              min={1}
              max={6}
              value={collapseDepth}
              onChange={(e) => setCollapseDepth(e.target.value)}
              placeholder="e.g. 3"
            />
          </FormField>

          {/* Checkboxes */}
          <div className="flex flex-col gap-2">
            <label className="flex items-center gap-2 cursor-pointer select-none">
              <input
                type="checkbox"
                checked={bare}
                onChange={(e) => setBare(e.target.checked)}
                className="focus-ring h-4 w-4 rounded border-border accent-accent"
              />
              <span className="text-sm text-foreground">Bare mode (extract matched section only)</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer select-none">
              <input
                type="checkbox"
                checked={withImageDescriptions}
                onChange={(e) => setWithImageDescriptions(e.target.checked)}
                className="focus-ring h-4 w-4 rounded border-border accent-accent"
              />
              <span className="text-sm text-foreground">Inject image descriptions</span>
            </label>
          </div>

          {/* Convert button */}
          <Button
            onClick={handleConvert}
            disabled={loading || !source.trim()}
            loading={loading}
            leadingIcon={!loading ? <DocumentArrowDownIcon className="h-4 w-4" /> : undefined}
          >
            {loading ? "Converting…" : "Convert"}
          </Button>

          {/* Error */}
          {error && (
            <div
              role="alert"
              className="rounded-lg border border-danger/20 bg-danger/10 px-4 py-3"
            >
              <p className="text-sm text-danger">{error}</p>
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
