"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";

import {
  buildPrompt,
  fetchCatalog,
  fetchCategories,
  fetchUnicodeDb,
  getPromptBuilderStatus,
  PromptBuilderError,
  type CatalogEntry,
  type CategoryDef,
  type PromptBuilderStatus,
} from "@/lib/api/prompt-builder";

// ── Web NPL Keyboard ──
// Public page (proxy.ts only gates /app/*). Catalog browsing and the symbol
// picker work fully offline from the static catalog JSONs; only the Build
// pane consumes the rate-limited prompt-construction API.

type Pane = "catalog" | "symbols" | "builder";

export default function KeyboardPage() {
  const [pane, setPane] = useState<Pane>("builder");
  const [entries, setEntries] = useState<CatalogEntry[]>([]);
  const [categories, setCategories] = useState<CategoryDef[]>([]);
  const [status, setStatus] = useState<PromptBuilderStatus | null>(null);
  const [catalogError, setCatalogError] = useState(false);

  useEffect(() => {
    fetchCatalog()
      .then(setEntries)
      .catch(() => setCatalogError(true));
    fetchCategories().then(setCategories).catch(() => {});
    getPromptBuilderStatus()
      .then(setStatus)
      .catch(() => setStatus(null));
  }, []);

  const categoryNames = useMemo(() => {
    const fromRegistry = categories
      .map((c) => (typeof c.id === "string" ? c.id : null))
      .filter((v): v is string => Boolean(v));
    return fromRegistry.length ? fromRegistry : [...new Set(entries.map((e) => e.category))];
  }, [categories, entries]);

  return (
    <main className="mx-auto max-w-6xl px-4 pb-20 pt-10">
      <header className="mb-10">
        <h1 className="text-3xl font-bold tracking-tight text-slate-900">
          NPL Keyboard <span className="font-mono text-xl text-slate-500">⌜NPL@1.0⌝</span>
        </h1>
        <p className="mt-2 max-w-3xl text-slate-600">
          The web edition of the Noizu Prompt Lingua Keyboard: browse the full NPL syntax + symbol
          catalog, and build finished NPL prompts from a plain-language description. The macOS app
          (with system-wide hotkeys) is available in the repo —{" "}
          <a className="text-blue-600 underline" href="/#get-the-keyboard">
            see Get the NPL Keyboard
          </a>
          . See the results in the{" "}
          <a className="text-blue-600 underline" href="/showcase">NPL Showcase</a>.
        </p>
      </header>

      <nav className="mb-6 flex gap-2" aria-label="Keyboard sections">
        {(
          [
            ["builder", "Prompt Builder"],
            ["catalog", "Syntax Catalog"],
            ["symbols", "Symbol Picker"],
          ] as [Pane, string][]
        ).map(([id, label]) => (
          <button
            key={id}
            onClick={() => setPane(id)}
            aria-current={pane === id ? "page" : undefined}
            className={`rounded-md px-4 py-2 text-sm font-medium transition-colors ${
              pane === id
                ? "bg-slate-900 text-white"
                : "bg-slate-100 text-slate-700 hover:bg-slate-200"
            }`}
          >
            {label}
          </button>
        ))}
      </nav>

      {pane === "builder" && (
        <BuilderPane status={status} onBuilt={refreshStatus} />
      )}
      {pane === "catalog" && (
        <CatalogPane entries={entries} categoryNames={categoryNames} error={catalogError} />
      )}
      {pane === "symbols" && <SymbolsPane entries={entries} />}

      <DistributionSection />
    </main>
  );

  function refreshStatus() {
    getPromptBuilderStatus()
      .then(setStatus)
      .catch(() => {});
  }
}

// ── Prompt Builder pane ─────────────────────────────────────────────────

function BuilderPane({
  status,
  onBuilt,
}: {
  status: PromptBuilderStatus | null;
  onBuilt: () => void;
}) {
  const [description, setDescription] = useState("");
  const [context, setContext] = useState("");
  const [result, setResult] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const resultRef = useRef<HTMLTextAreaElement>(null);

  const disabled = busy || description.trim().length === 0 || (status ? !status.enabled : false);

  async function handleBuild() {
    setBusy(true);
    setError(null);
    setResult(null);
    try {
      const out = await buildPrompt(description, context);
      setResult(out.prompt);
      onBuilt();
      requestAnimationFrame(() => resultRef.current?.focus());
    } catch (e) {
      if (e instanceof PromptBuilderError) {
        const retry = e.retryAfter ? ` Try again in ${e.retryAfter}s.` : "";
        setError(e.message + retry);
      } else {
        setError("Build failed — try rephrasing.");
      }
    } finally {
      setBusy(false);
    }
  }

  async function handleCopy() {
    if (!result) return;
    await navigator.clipboard.writeText(result);
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  }

  return (
    <section className="grid gap-6 lg:grid-cols-2">
      <div className="rounded-lg border border-slate-200 bg-white p-5">
        <h2 className="mb-1 text-lg font-semibold text-slate-900">Describe the prompt you want</h2>
        <p className="mb-4 text-sm text-slate-500">
          Plain language — what the agent should do, its tone, constraints. This tool only
          constructs NPL prompts; it does not answer questions.
        </p>
        <textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          rows={6}
          maxLength={4000}
          placeholder="e.g. A code-review agent for Elixir: strict about types and error handling, blunt but kind, outputs findings as a numbered list with severity labels."
          className="w-full rounded-md border border-slate-300 p-3 text-sm focus:border-slate-500 focus:outline-none"
        />
        <textarea
          value={context}
          onChange={(e) => setContext(e.target.value)}
          rows={3}
          maxLength={2000}
          placeholder="Optional context to incorporate (domain, audience, style references)…"
          className="mt-3 w-full rounded-md border border-slate-300 p-3 text-sm focus:border-slate-500 focus:outline-none"
        />
        <button
          onClick={handleBuild}
          disabled={disabled}
          className="mt-4 rounded-md bg-blue-600 px-5 py-2 text-sm font-semibold text-white transition-colors hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-slate-300"
        >
          {busy ? "Building…" : "Build NPL prompt"}
        </button>

        <p className="mt-3 text-xs text-slate-400">
          Prompts you submit are logged and may be used for fine-tuning, evaluation, and as public
          showcase examples.
        </p>
        {status && (
          <p className="mt-3 text-xs text-slate-400">
            {status.enabled
              ? `Quota: ${status.requests_per_minute} builds/min · $${status.daily_cost_remaining_usd} of $${status.daily_cost_cap_usd} left today`
              : "The prompt builder is temporarily disabled."}
          </p>
        )}
        {error && <p className="mt-3 text-sm text-red-600">{error}</p>}
      </div>

      <div className="rounded-lg border border-slate-200 bg-white p-5">
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-lg font-semibold text-slate-900">Result</h2>
          {result && (
            <button
              onClick={handleCopy}
              className="rounded border border-slate-300 px-3 py-1 text-xs font-medium hover:bg-slate-50"
            >
              {copied ? "Copied ✓" : "Copy"}
            </button>
          )}
        </div>
        {result ? (
          <textarea
            ref={resultRef}
            readOnly
            value={result}
            rows={16}
            className="w-full rounded-md border border-slate-200 bg-slate-50 p-3 font-mono text-xs"
          />
        ) : (
          <p className="text-sm text-slate-400">
            Your composed NPL prompt appears here. Browsing the catalog below is always free — only
            builds count against the quota.
          </p>
        )}
      </div>
    </section>
  );
}

// ── Catalog pane ────────────────────────────────────────────────────────

function CatalogPane({
  entries,
  categoryNames,
  error,
}: {
  entries: CatalogEntry[];
  categoryNames: string[];
  error: boolean;
}) {
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState<string>("all");
  const [copiedId, setCopiedId] = useState<string | null>(null);

  const filtered = useMemo(() => {
    const q = query.toLowerCase();
    return entries.filter(
      (e) =>
        (category === "all" || e.category === category) &&
        (!q ||
          e.name.toLowerCase().includes(q) ||
          (e.tags ?? []).some((t) => t.toLowerCase().includes(q)) ||
          (e.description ?? "").toLowerCase().includes(q)),
    );
  }, [entries, query, category]);

  async function copy(e: CatalogEntry) {
    const text = e.template || e.char || e.text || "";
    await navigator.clipboard.writeText(text);
    setCopiedId(e.id);
    setTimeout(() => setCopiedId(null), 1500);
  }

  if (error) {
    return <p className="text-sm text-slate-500">Catalog failed to load — refresh to retry.</p>;
  }

  return (
    <section>
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search the catalog…"
          className="w-72 rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-slate-500 focus:outline-none"
        />
        <select
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          className="rounded-md border border-slate-300 px-3 py-2 text-sm"
        >
          <option value="all">All categories</option>
          {categoryNames.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>
        <span className="text-xs text-slate-400">{filtered.length} entries</span>
      </div>

      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {filtered.map((e) => (
          <button
            key={e.id}
            onClick={() => copy(e)}
            title="Click to copy"
            className="rounded-lg border border-slate-200 bg-white p-4 text-left transition-colors hover:border-blue-400"
          >
            <div className="flex items-center justify-between">
              <span className="font-mono text-lg">{e.char || e.template}</span>
              <span className="text-xs text-slate-400">
                {copiedId === e.id ? "Copied ✓" : e.category}
              </span>
            </div>
            <div className="mt-1 text-sm font-medium text-slate-800">{e.name}</div>
            {e.description && (
              <p className="mt-1 line-clamp-2 text-xs text-slate-500">{e.description}</p>
            )}
          </button>
        ))}
      </div>
    </section>
  );
}

// ── Symbol picker pane ──────────────────────────────────────────────────

function SymbolsPane({ entries }: { entries: CatalogEntry[] }) {
  const [all, setAll] = useState<CatalogEntry[] | null>(null);
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (all || loading) return;
    setLoading(true);
    try {
      setAll(await fetchUnicodeDb());
    } catch {
      setAll(entries.filter((e) => e.category !== "npl-syntax"));
    } finally {
      setLoading(false);
    }
  }, [all, loading, entries]);

  useEffect(() => {
    // Preload shortly after the pane mounts.
    const t = setTimeout(load, 50);
    return () => clearTimeout(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const list = all ?? entries;

  async function copy(char: string, id: string) {
    await navigator.clipboard.writeText(char);
    setCopied(id);
    setTimeout(() => setCopied(null), 1200);
  }

  if (loading && !all) return <p className="text-sm text-slate-500">Loading symbol database…</p>;

  return (
    <section>
      <p className="mb-3 text-sm text-slate-500">
        Click any glyph to copy. {list.length} symbols loaded.
      </p>
      <div className="grid grid-cols-8 gap-1 sm:grid-cols-12 lg:grid-cols-16">
        {list.slice(0, 1200).map((e) => (
          <button
            key={e.id}
            onClick={() => copy(e.char || e.template || "", e.id)}
            title={`${e.name}${e.description ? ` — ${e.description}` : ""}`}
            className="rounded border border-slate-100 bg-white py-2 font-mono text-lg hover:border-blue-400 hover:bg-blue-50"
          >
            {copied === e.id ? "✓" : e.char || e.template}
          </button>
        ))}
      </div>
      {list.length > 1200 && (
        <p className="mt-3 text-xs text-slate-400">Showing the first 1200 — use the catalog search for more.</p>
      )}
    </section>
  );
}

// ── Get the NPL Keyboard (distribution) ─────────────────────────────────

function DistributionSection() {
  return (
    <section id="get-the-keyboard" className="mt-16 rounded-lg border border-slate-200 bg-slate-50 p-6">
      <h2 className="text-xl font-bold text-slate-900">Get the NPL Keyboard</h2>
      <p className="mt-2 max-w-3xl text-sm text-slate-600">
        The macOS app puts the whole NPL catalog behind a system-wide hotkey: type NPL syntax,
        unicode glyphs, and agent directives in any editor, with fuzzy search and snippet
        expansion. This web page mirrors its catalog — the native app adds hotkeys, menus, and
        offline speed.
      </p>
      <ul className="mt-4 list-inside list-disc text-sm text-slate-700">
        <li>Full NPL syntax palette (⌜NPL@1.0⌝ frames, directives, persona/context sections)</li>
        <li>Unicode + NPL emoji quick-pick with fuzzy search and usage descriptions</li>
        <li>Snippet templates for the common prompt structures — click to insert</li>
        <li>Native macOS speed; works offline, no account needed</li>
      </ul>
      <div className="mt-4 rounded-md bg-white p-4 font-mono text-xs text-slate-700">
        <div className="text-slate-400"># from the agent-kit repo root</div>
        <div>cd tools/npl-keyboard</div>
        <div>make install-osx</div>
      </div>
      <p className="mt-3 text-xs text-slate-400">
        Release zips on tag are planned — until then, build from source with the command above.
      </p>
    </section>
  );
}
