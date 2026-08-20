"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { TabGroup, TabList, Tab, TabPanels, TabPanel } from "@headlessui/react";
import { ArrowPathIcon } from "@heroicons/react/24/outline";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import clsx from "clsx";

import { api } from "@/lib/api/client";
import type { NPLElement, NPLResponse } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { CodeBlock } from "@/components/primitives/CodeBlock";
import { PageHeader } from "@/components/primitives/PageHeader";

const SECTIONS: string[] = [
  "syntax",
  "declarations",
  "pumps",
  "directives",
  "prefixes",
  "prompt-sections",
  "special-sections",
];

type ViewMode = "render" | "code";

interface SectionState {
  componentPriority: number;
  examplePriority: number;
  concise: boolean;
  xml: boolean;
  excluded: Set<string>;
  response: NPLResponse | null;
  loading: boolean;
  error: string | null;
  viewMode: ViewMode;
  // version tick so effect can re-fire on manual "Re-render"
  nonce: number;
}

function defaultSectionState(): SectionState {
  return {
    componentPriority: 1,
    examplePriority: 1,
    concise: true,
    xml: false,
    excluded: new Set(),
    response: null,
    loading: false,
    error: null,
    viewMode: "render",
    nonce: 0,
  };
}

export default function NPLBookPage() {
  const [selected, setSelected] = useState(0);
  const [states, setStates] = useState<Record<string, SectionState>>(() =>
    Object.fromEntries(SECTIONS.map((s) => [s, defaultSectionState()]))
  );
  const [elements, setElements] = useState<NPLElement[] | null>(null);

  // Load element catalog (for per-section exclusion checkboxes)
  useEffect(() => {
    let cancelled = false;
    void (async () => {
      try {
        const els = await api.npl.elements();
        if (!cancelled) setElements(els);
      } catch {
        /* non-fatal */
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const elementsBySection = useMemo(() => {
    const m: Record<string, NPLElement[]> = {};
    for (const el of elements ?? []) {
      (m[el.section] ||= []).push(el);
    }
    return m;
  }, [elements]);

  const updateSection = (key: string, patch: Partial<SectionState>) =>
    setStates((s) => ({ ...s, [key]: { ...s[key], ...patch } }));

  const activeKey = SECTIONS[selected];
  const active = states[activeKey];

  // Auto-render whenever a new tab becomes active OR nonce bumps
  useEffect(() => {
    const key = activeKey;
    const st = states[key];
    if (!st) return;
    let cancelled = false;
    void (async () => {
      updateSection(key, { loading: true, error: null });
      try {
        const rendered = Array.from(st.excluded).map((spec) => ({ spec }));
        const result = await api.npl.spec({
          components: [
            {
              spec: `${key}:*`,
              component_priority: st.componentPriority,
              example_priority: st.examplePriority,
            },
          ],
          rendered,
          concise: st.concise,
          xml: st.xml,
        });
        if (!cancelled)
          updateSection(key, { response: result, loading: false });
      } catch (err) {
        if (!cancelled)
          updateSection(key, {
            loading: false,
            error: err instanceof Error ? err.message : "Failed to render",
          });
      }
    })();
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeKey, active?.nonce]);

  const toggleExcluded = (spec: string) => {
    const next = new Set(active.excluded);
    if (next.has(spec)) next.delete(spec);
    else next.add(spec);
    updateSection(activeKey, { excluded: next });
  };

  const reRender = () =>
    updateSection(activeKey, { nonce: active.nonce + 1 });

  return (
    <div className="space-y-6">
      <PageHeader
        title="NPL Book"
        description="Browse the Noizu Prompt Lingua specification one section at a time. Each tab renders on open with default verbosity."
        actions={
          <div className="flex items-center gap-3">
            <Link
              href="/npl"
              className="text-sm text-accent hover:text-accent/80 transition-colors"
            >
              Playground
            </Link>
            <Link
              href="/npl/elements"
              className="text-sm text-accent hover:text-accent/80 transition-colors"
            >
              Elements
            </Link>
            <Badge variant="info" size="sm">
              live
            </Badge>
          </div>
        }
      />

      <TabGroup selectedIndex={selected} onChange={setSelected}>
        <TabList className="flex flex-wrap gap-1 rounded-lg bg-surface-1 border border-border p-1 w-fit">
          {SECTIONS.map((s) => (
            <Tab
              key={s}
              className={({ selected: sel }: { selected: boolean }) =>
                clsx(
                  "rounded-md px-3 py-1.5 text-sm font-mono transition-colors focus:outline-none",
                  sel
                    ? "bg-accent text-accent-on shadow-sm"
                    : "text-muted hover:text-foreground"
                )
              }
            >
              {s}
            </Tab>
          ))}
        </TabList>

        <TabPanels className="mt-6">
          {SECTIONS.map((key) => {
            const st = states[key];
            const sectionElements = elementsBySection[key] ?? [];
            return (
              <TabPanel key={key}>
                <div className="grid grid-cols-1 gap-6 lg:grid-cols-[320px_1fr]">
                  {/* Left: controls */}
                  <div className="space-y-4">
                    <Card className="space-y-4">
                      <h3 className="text-sm font-semibold text-foreground font-mono">
                        {key}
                      </h3>
                      <label className="text-xs text-muted flex flex-col gap-1">
                        <span>Component priority: {st.componentPriority}</span>
                        <input
                          type="range"
                          min={0}
                          max={3}
                          value={st.componentPriority}
                          onChange={(e) =>
                            updateSection(key, {
                              componentPriority: parseInt(e.target.value, 10),
                            })
                          }
                          className="w-full accent-[hsl(var(--accent))]"
                        />
                      </label>
                      <label className="text-xs text-muted flex flex-col gap-1">
                        <span>Example priority: {st.examplePriority}</span>
                        <input
                          type="range"
                          min={0}
                          max={3}
                          value={st.examplePriority}
                          onChange={(e) =>
                            updateSection(key, {
                              examplePriority: parseInt(e.target.value, 10),
                            })
                          }
                          className="w-full accent-[hsl(var(--accent))]"
                        />
                      </label>
                      <div className="space-y-1.5 pt-1">
                        <label className="flex items-center gap-2 text-sm text-foreground cursor-pointer">
                          <input
                            type="checkbox"
                            checked={st.concise}
                            onChange={(e) =>
                              updateSection(key, { concise: e.target.checked })
                            }
                            className="focus-ring h-4 w-4 rounded border-border bg-surface-1 accent-[hsl(var(--accent))]"
                          />
                          Concise
                        </label>
                        <label className="flex items-center gap-2 text-sm text-foreground cursor-pointer">
                          <input
                            type="checkbox"
                            checked={st.xml}
                            onChange={(e) =>
                              updateSection(key, { xml: e.target.checked })
                            }
                            className="focus-ring h-4 w-4 rounded border-border bg-surface-1 accent-[hsl(var(--accent))]"
                          />
                          XML examples
                        </label>
                      </div>
                      <button
                        type="button"
                        onClick={reRender}
                        disabled={st.loading}
                        className={clsx(
                          "focus-ring w-full flex items-center justify-center gap-2 rounded-md px-4 py-2 text-sm font-semibold text-accent-on transition-colors",
                          st.loading
                            ? "bg-accent/50 cursor-not-allowed"
                            : "bg-accent hover:bg-accent-soft"
                        )}
                      >
                        {st.loading && (
                          <ArrowPathIcon className="h-4 w-4 animate-spin" />
                        )}
                        Re-render
                      </button>
                    </Card>

                    {sectionElements.length > 0 && (
                      <Card className="space-y-2">
                        <div className="flex items-center justify-between">
                          <h4 className="text-sm font-semibold text-foreground">
                            Exclude
                          </h4>
                          {st.excluded.size > 0 && (
                            <Badge variant="warning" size="sm">
                              {st.excluded.size}
                            </Badge>
                          )}
                        </div>
                        <div className="max-h-72 overflow-y-auto space-y-1 pr-1">
                          {sectionElements.map((el) => {
                            const spec = `${el.section}:${el.slug}`;
                            return (
                              <label
                                key={spec}
                                className="flex items-start gap-2 text-xs text-foreground cursor-pointer"
                              >
                                <input
                                  type="checkbox"
                                  checked={st.excluded.has(spec)}
                                  onChange={() => toggleExcluded(spec)}
                                  className="focus-ring mt-0.5 h-3.5 w-3.5 rounded border-border bg-surface-1 accent-[hsl(var(--accent))]"
                                />
                                <span className="font-mono">{el.name}</span>
                              </label>
                            );
                          })}
                        </div>
                      </Card>
                    )}
                  </div>

                  {/* Right: preview */}
                  <div className="min-w-0 space-y-3">
                    <div className="mx-auto w-full max-w-6xl">
                      <div className="flex items-center justify-between gap-3">
                        <div className="flex items-center gap-2">
                          {(["render", "code"] as ViewMode[]).map((m) => (
                            <button
                              key={m}
                              type="button"
                              onClick={() =>
                                updateSection(key, { viewMode: m })
                              }
                              className={clsx(
                                "focus-ring rounded-md px-3 py-1 text-xs font-medium transition-colors",
                                st.viewMode === m
                                  ? "bg-accent text-accent-on"
                                  : "bg-surface-1 text-muted hover:text-foreground border border-border"
                              )}
                            >
                              {m === "render" ? "Render" : "Code"}
                            </button>
                          ))}
                        </div>
                        {st.response && (
                          <Badge variant="default" size="sm">
                            {st.response.char_count.toLocaleString()} chars
                          </Badge>
                        )}
                      </div>
                      {st.error && (
                        <div
                          role="alert"
                          className="mt-3 bg-danger/10 text-danger p-3 rounded-md text-sm"
                        >
                          {st.error}
                        </div>
                      )}
                      <div className="mt-3">
                        {st.loading && !st.response ? (
                          <div className="flex items-center justify-center py-24 text-muted">
                            <ArrowPathIcon className="h-6 w-6 animate-spin" />
                          </div>
                        ) : st.response ? (
                          st.viewMode === "code" ? (
                            <CodeBlock
                              code={st.response.markdown}
                              language="markdown"
                              maxHeight="75vh"
                            />
                          ) : (
                            <div
                              className="prose prose-invert prose-sm max-w-none rounded-lg border border-border/50 bg-surface-1 p-6 overflow-auto"
                              style={{ maxHeight: "75vh" }}
                            >
                              <ReactMarkdown remarkPlugins={[remarkGfm]}>
                                {st.response.markdown}
                              </ReactMarkdown>
                            </div>
                          )
                        ) : null}
                      </div>
                    </div>
                  </div>
                </div>
              </TabPanel>
            );
          })}
        </TabPanels>
      </TabGroup>
    </div>
  );
}
