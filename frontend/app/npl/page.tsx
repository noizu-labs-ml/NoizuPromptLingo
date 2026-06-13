"use client";

import { Suspense, useEffect, useState } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { TabGroup, TabList, Tab, TabPanels, TabPanel } from "@headlessui/react";
import { ArrowPathIcon, TableCellsIcon } from "@heroicons/react/24/outline";
import clsx from "clsx";

import { api } from "@/lib/api/client";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { CodeBlock } from "@/components/primitives/CodeBlock";
import { PageHeader } from "@/components/primitives/PageHeader";
import { Button } from "@/components/primitives/Button";
import { Select } from "@/components/primitives/Select";
import { FormField } from "@/components/primitives/FormField";
import type { NPLResponse } from "@/lib/api/types";

// ── Quick-pick pills ─────────────────────────────────────────────────────

const QUICK_PICKS = [
  "syntax",
  "pumps",
  "directives",
  "syntax#placeholder",
  "pumps#chain-of-thought",
];

// ── Shared sub-components ────────────────────────────────────────────────

function ErrorBlock({ message }: { message: string }) {
  return (
    <div role="alert" className="bg-danger/10 text-danger p-3 rounded-md text-sm">
      {message}
    </div>
  );
}

function PreviewPanel({
  response,
  loading,
}: {
  response: NPLResponse | null;
  loading: boolean;
}) {
  return (
    <div className="sticky top-6 flex flex-col gap-3">
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-foreground">Preview</span>
        {response && (
          <Badge variant="default" size="sm">
            {response.char_count.toLocaleString()} chars
          </Badge>
        )}
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-16 text-muted">
          <ArrowPathIcon className="h-6 w-6 animate-spin" />
        </div>
      ) : response ? (
        <CodeBlock code={response.markdown} language="markdown" maxHeight="70vh" />
      ) : (
        <div className="rounded-lg border border-border bg-surface-1 px-6 py-12 text-center text-sm text-muted">
          Results will appear here.
        </div>
      )}
    </div>
  );
}

// ── Tab 1: Expression DSL ────────────────────────────────────────────────

function ExpressionTab() {
  const searchParams = useSearchParams();
  const initialExpr = searchParams.get("expr") ?? "syntax#placeholder:+2";
  const [expression, setExpression] = useState(initialExpr);
  const [skipInput, setSkipInput] = useState("");
  const [layout, setLayout] = useState<"yaml_order" | "classic" | "grouped">(
    "yaml_order"
  );
  const [loading, setLoading] = useState(false);
  const [response, setResponse] = useState<NPLResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  const parseSkip = (raw: string): string[] =>
    raw
      .split(/[,\n]+/)
      .map((s) => s.trim())
      .filter(Boolean);

  // Auto-load when navigated in with ?expr=
  const autoLoadExpr = searchParams.get("expr");
  useEffect(() => {
    if (autoLoadExpr) {
      setExpression(autoLoadExpr);
      void (async () => {
        setLoading(true);
        setError(null);
        try {
          const result = await api.npl.load({ expression: autoLoadExpr, layout: "yaml_order" });
          setResponse(result);
        } catch (err) {
          setError(err instanceof Error ? err.message : "An unexpected error occurred.");
        } finally {
          setLoading(false);
        }
      })();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [autoLoadExpr]);

  const handleLoad = async () => {
    setLoading(true);
    setError(null);
    try {
      const skip = parseSkip(skipInput);
      const result = await api.npl.load({
        expression,
        layout,
        ...(skip.length > 0 ? { skip } : {}),
      });
      setResponse(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : "An unexpected error occurred.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
      {/* Left: Input panel */}
      <Card className="flex flex-col gap-5">
        {/* Expression input */}
        <div className="flex flex-col gap-1.5">
          <label
            htmlFor="npl-expression"
            className="text-sm font-medium text-foreground"
          >
            Expression
          </label>
          <input
            id="npl-expression"
            type="text"
            value={expression}
            onChange={(e) => setExpression(e.target.value)}
            className="focus-ring rounded-md border border-border bg-surface-1 px-3 py-2 text-sm text-foreground placeholder:text-muted transition-colors"
          />
          <p className="text-xs text-muted leading-relaxed">
            Grammar:{" "}
            <code className="font-mono text-accent">
              section[#component][:+priority]
            </code>
            , space-separated,{" "}
            <code className="font-mono text-accent">-</code> to subtract.
            Example:{" "}
            <code className="font-mono text-accent">
              syntax#placeholder directives -syntax#literal
            </code>
          </p>
        </div>

        {/* Skip input */}
        <div className="flex flex-col gap-1.5">
          <label
            htmlFor="npl-skip"
            className="text-sm font-medium text-foreground"
          >
            Skip already-loaded resources
          </label>
          <input
            id="npl-skip"
            type="text"
            value={skipInput}
            onChange={(e) => setSkipInput(e.target.value)}
            placeholder="e.g. syntax#placeholder, pumps"
            className="focus-ring rounded-md border border-border bg-surface-1 px-3 py-2 text-sm text-foreground placeholder:text-muted transition-colors"
          />
          <p className="text-xs text-muted leading-relaxed">
            Comma-separated terms to exclude, using the same grammar as the
            expression (no leading <code className="font-mono text-accent">-</code>).
          </p>
        </div>

        {/* Layout select */}
        <FormField label="Layout" htmlFor="npl-layout">
          <Select
            id="npl-layout"
            value={layout}
            onChange={(e) =>
              setLayout(e.target.value as "yaml_order" | "classic" | "grouped")
            }
          >
            <option value="yaml_order">yaml_order</option>
            <option value="classic">classic</option>
            <option value="grouped">grouped</option>
          </Select>
        </FormField>

        {/* Quick-pick pills */}
        <div className="flex flex-col gap-2">
          <span className="text-sm font-medium text-foreground">
            Quick picks
          </span>
          <div className="flex flex-wrap gap-2">
            {QUICK_PICKS.map((pill) => (
              <Button
                key={pill}
                type="button"
                variant="ghost"
                size="sm"
                onClick={() => setExpression(pill)}
                className="font-mono"
              >
                {pill}
              </Button>
            ))}
          </div>
        </div>

        {/* Load button */}
        <button
          type="button"
          onClick={handleLoad}
          disabled={loading || !expression.trim()}
          className={clsx(
            "focus-ring flex items-center justify-center gap-2 rounded-md px-4 py-2 text-sm font-semibold text-accent-on transition-colors",
            loading || !expression.trim()
              ? "bg-accent/50 cursor-not-allowed"
              : "bg-accent hover:bg-accent-soft"
          )}
        >
          {loading && <ArrowPathIcon className="h-4 w-4 animate-spin" />}
          Load
        </button>
      </Card>

      {/* Right: Preview panel */}
      <div>
        {error && <ErrorBlock message={error} />}
        <div className={clsx(error && "mt-3")}>
          <PreviewPanel response={response} loading={loading} />
        </div>
      </div>
    </div>
  );
}

// ── Tab 2: Component Composer ────────────────────────────────────────────

function ComponentComposerTab() {
  const [components, setComponents] = useState("");
  const [concise, setConcise] = useState(true);
  const [xml, setXml] = useState(false);
  const [extension, setExtension] = useState(false);
  const [loading, setLoading] = useState(false);
  const [response, setResponse] = useState<NPLResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  const parseComponents = (raw: string): string[] =>
    raw
      .split(/[\n,]+/)
      .map((s) => s.trim())
      .filter(Boolean);

  const handleGenerate = async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await api.npl.spec({
        components: parseComponents(components),
        concise,
        xml,
        extension,
      });
      setResponse(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : "An unexpected error occurred.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
      {/* Left: Input panel */}
      <Card className="flex flex-col gap-5">
        {/* Textarea */}
        <div className="flex flex-col gap-1.5">
          <label
            htmlFor="npl-components"
            className="text-sm font-medium text-foreground"
          >
            Component specs
          </label>
          <textarea
            id="npl-components"
            rows={6}
            value={components}
            onChange={(e) => setComponents(e.target.value)}
            placeholder={
              "pumps#chain-of-thought\nsyntax#placeholder\ndirectives"
            }
            className="focus-ring rounded-md border border-border bg-surface-1 px-3 py-2 text-sm font-mono text-foreground placeholder:text-muted transition-colors resize-y"
          />
          <p className="text-xs text-muted">
            Comma- or newline-separated entries, e.g.{" "}
            <code className="font-mono text-accent">
              pumps#chain-of-thought
            </code>
          </p>
        </div>

        {/* Checkboxes */}
        <div className="flex flex-col gap-2">
          {(
            [
              { id: "concise", label: "Concise", value: concise, setter: setConcise },
              { id: "xml", label: "XML examples", value: xml, setter: setXml },
              {
                id: "extension",
                label: "Extension block",
                value: extension,
                setter: setExtension,
              },
            ] as const
          ).map(({ id, label, value, setter }) => (
            <label
              key={id}
              htmlFor={`npl-${id}`}
              className="flex items-center gap-2 text-sm text-foreground cursor-pointer"
            >
              <input
                id={`npl-${id}`}
                type="checkbox"
                checked={value}
                onChange={(e) => setter(e.target.checked)}
                className="focus-ring h-4 w-4 rounded border-border bg-surface-1 accent-[hsl(var(--accent))]"
              />
              {label}
            </label>
          ))}
        </div>

        {/* Generate button */}
        <button
          type="button"
          onClick={handleGenerate}
          disabled={loading || !components.trim()}
          className={clsx(
            "focus-ring flex items-center justify-center gap-2 rounded-md px-4 py-2 text-sm font-semibold text-accent-on transition-colors",
            loading || !components.trim()
              ? "bg-accent/50 cursor-not-allowed"
              : "bg-accent hover:bg-accent-soft"
          )}
        >
          {loading && <ArrowPathIcon className="h-4 w-4 animate-spin" />}
          Generate
        </button>
      </Card>

      {/* Right: Preview panel */}
      <div>
        {error && <ErrorBlock message={error} />}
        <div className={clsx(error && "mt-3")}>
          <PreviewPanel response={response} loading={loading} />
        </div>
      </div>
    </div>
  );
}

// ── Page ─────────────────────────────────────────────────────────────────

export default function NPLPlaygroundPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="NPL Playground"
        description="Generate NPL snippets and full specs from the conventions directory."
        actions={
          <div className="flex items-center gap-3">
            <Link
              href="/npl/elements"
              className="flex items-center gap-1.5 text-sm text-accent hover:text-accent/80 transition-colors"
            >
              <TableCellsIcon className="h-4 w-4" />
              See all elements
            </Link>
            <Link
              href="/metrics"
              className="flex items-center gap-1.5 text-sm text-accent hover:text-accent/80 transition-colors"
            >
              Coverage stats
            </Link>
            <Badge variant="info" size="sm">
              mock preview
            </Badge>
          </div>
        }
      />

      <TabGroup>
        <TabList className="flex gap-1 rounded-lg bg-surface-1 border border-border p-1 w-fit">
          {["Expression DSL", "Component Composer"].map((tab) => (
            <Tab
              key={tab}
              className={({ selected }: { selected: boolean }) =>
                clsx(
                  "rounded-md px-4 py-1.5 text-sm font-medium transition-colors focus:outline-none",
                  selected
                    ? "bg-accent text-accent-on shadow-sm"
                    : "text-muted hover:text-foreground"
                )
              }
            >
              {tab}
            </Tab>
          ))}
        </TabList>

        <TabPanels className="mt-6">
          <TabPanel>
            <Suspense fallback={<div className="py-16 text-center text-sm text-muted">Loading…</div>}>
              <ExpressionTab />
            </Suspense>
          </TabPanel>
          <TabPanel>
            <ComponentComposerTab />
          </TabPanel>
        </TabPanels>
      </TabGroup>
    </div>
  );
}
