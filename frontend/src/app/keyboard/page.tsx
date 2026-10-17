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
//
// Styling note: this page uses the --pg-* page tokens (globals.css) via
// Tailwind arbitrary values instead of fixed slate-* utility classes. The
// site defaults to dark mode, so hardcoded light classes rendered dark
// text on a near-black canvas (annotate 890f4529).

type Pane = "catalog" | "symbols" | "builder";
type PromptFormat = "markdown" | "semtext";

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
        <h1 className="text-3xl font-bold tracking-tight text-[var(--pg-ink)]">
          NPL Keyboard <span className="font-mono text-xl text-[var(--pg-ink-faint)]">⌜NPL@1.0⌝</span>
        </h1>
        <p className="mt-2 max-w-3xl text-[var(--pg-ink-soft)]">
          The web edition of the Noizu Prompt Lingua Keyboard: browse the full NPL syntax + symbol
          catalog, and build finished NPL prompts from a plain-language description. The macOS app
          (with system-wide hotkeys) is available in the repo —{" "}
          <a className="text-[var(--pg-accent-ink-strong)] underline" href="/#get-the-keyboard">
            see Get the NPL Keyboard
          </a>
          . See the results in the{" "}
          <a className="text-[var(--pg-accent-ink-strong)] underline" href="/showcase">NPL Showcase</a>.
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
                ? "bg-[var(--pg-ink)] text-[var(--pg-canvas)]"
                : "bg-[var(--pg-card-alt)] text-[var(--pg-ink-soft)] hover:bg-[var(--pg-active)]"
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

// Insert palette + syntax hint per format. The selector is honest about
// scope (annotate 9c050e06): it switches the hint and palette only — the
// Build button always compiles the text into a full NPL prompt.
const FORMAT_META: Record<
  PromptFormat,
  {
    label: string;
    hint: React.ReactNode;
    palette: { label: string; insert: string; title: string }[];
  }
> = {
  markdown: {
    label: "Markdown",
    hint: (
      <>
        Markdown: <code># heading</code>, <code>- list item</code>, <code>**bold**</code>,{" "}
        <code>`code`</code>. Plain prose works too.
      </>
    ),
    palette: [
      { label: "# H", insert: "# Heading\n", title: "Insert a Markdown heading" },
      { label: "- list", insert: "- list item\n", title: "Insert a Markdown list item" },
      { label: "B", insert: "**bold**", title: "Insert bold text" },
      { label: "</>", insert: "`code`", title: "Insert inline code" },
      { label: "❝ quote", insert: "> ", title: "Insert a blockquote" },
    ],
  },
  semtext: {
    label: "SemText / NPL",
    hint: (
      <>
        NPL syntax: <code>⌜NPL@1.0⌝ … ⌞NPL@1.0⌟</code> frames, <code>{"{placeholder}"}</code>,{" "}
        <code>[...|in-fill]</code>. Tag reference:{" "}
        <a
          className="text-[var(--pg-accent-ink-strong)] underline"
          href="/reference"
        >
          /reference
        </a>{" "}
        ·{" "}
        <a
          className="text-[var(--pg-accent-ink-strong)] underline"
          href="https://semtext.dev"
          target="_blank"
          rel="noreferrer"
        >
          semtext.dev →
        </a>
      </>
    ),
    palette: [
      { label: "⌜frame⌝", insert: "⌜NPL@1.0⌝\n\n⌞NPL@1.0⌟", title: "Insert an NPL version frame" },
      { label: "{…}", insert: "{placeholder}", title: "Insert a placeholder" },
      { label: "[...|…]", insert: "[...|describe the output]", title: "Insert qualified in-fill" },
      { label: "🎯", insert: "🎯 ", title: "Insert an attention marker" },
    ],
  },
};

function BuilderPane({
  status,
  onBuilt,
}: {
  status: PromptBuilderStatus | null;
  onBuilt: () => void;
}) {
  const [format, setFormat] = useState<PromptFormat>("markdown");
  const [description, setDescription] = useState("");
  const [context, setContext] = useState("");
  const [result, setResult] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const descriptionRef = useRef<HTMLTextAreaElement>(null);
  const resultRef = useRef<HTMLTextAreaElement>(null);

  const meta = FORMAT_META[format];
  const disabled = busy || description.trim().length === 0 || (status ? !status.enabled : false);

  function insertSnippet(text: string) {
    const el = descriptionRef.current;
    if (!el) {
      setDescription((d) => d + text);
      return;
    }
    const start = el.selectionStart ?? el.value.length;
    const end = el.selectionEnd ?? start;
    setDescription(el.value.slice(0, start) + text + el.value.slice(end));
    requestAnimationFrame(() => {
      el.focus();
      const caret = start + text.length;
      el.setSelectionRange(caret, caret);
    });
  }

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
      <div className="rounded-lg border border-[var(--pg-border-soft)] bg-[var(--pg-card)] p-5">
        <div className="mb-1 flex flex-wrap items-center justify-between gap-2">
          <h2 className="text-lg font-semibold text-[var(--pg-ink)]">
            Describe the prompt you want
          </h2>
          <div
            className="flex items-center gap-1"
            role="group"
            aria-label="Prompt syntax format"
          >
            <span className="mr-1 text-[10px] font-semibold uppercase tracking-wider text-[var(--pg-ink-faint)]">
              Syntax
            </span>
            {(Object.keys(FORMAT_META) as PromptFormat[]).map((f) => (
              <button
                key={f}
                type="button"
                onClick={() => setFormat(f)}
                aria-pressed={format === f}
                className={`rounded px-2.5 py-1 text-xs font-medium transition-colors ${
                  format === f
                    ? "bg-[var(--pg-ink)] text-[var(--pg-canvas)]"
                    : "bg-[var(--pg-card-alt)] text-[var(--pg-ink-soft)] hover:bg-[var(--pg-active)]"
                }`}
              >
                {FORMAT_META[f].label}
              </button>
            ))}
          </div>
        </div>
        <p className="mb-3 text-sm text-[var(--pg-ink-faint)]">
          {meta.hint}
        </p>
        <textarea
          ref={descriptionRef}
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          rows={6}
          maxLength={4000}
          placeholder={
            format === "markdown"
              ? "e.g. A code-review agent for Elixir: strict about types and error handling, blunt but kind, outputs findings as a numbered list with severity labels."
              : "e.g. ⌜NPL@1.0⌝\n{role}: senior Elixir reviewer\n[...|numbered findings with severity labels]\n⌞NPL@1.0⌟"
          }
          className="w-full rounded-md border border-[var(--pg-border)] bg-[var(--pg-card)] p-3 text-sm text-[var(--pg-ink)] placeholder:text-[var(--pg-ink-faint)] focus:border-[var(--pg-accent)] focus:outline-none"
        />
        <div className="mt-2 flex flex-wrap items-center gap-1.5">
          <span className="text-[10px] font-semibold uppercase tracking-wider text-[var(--pg-ink-faint)]">
            Insert
          </span>
          {meta.palette.map((chip) => (
            <button
              key={chip.label}
              type="button"
              onClick={() => insertSnippet(chip.insert)}
              title={chip.title}
              className="rounded border border-[var(--pg-border-soft)] bg-[var(--pg-card-alt)] px-2 py-1 font-mono text-xs text-[var(--pg-ink-soft)] hover:border-[var(--pg-accent)] hover:bg-[var(--pg-hover)]"
            >
              {chip.label}
            </button>
          ))}
        </div>
        <p className="mt-2 text-xs text-[var(--pg-ink-faint)]">
          The selector switches the syntax hint and insert palette only —{" "}
          <strong className="font-semibold text-[var(--pg-ink-soft)]">Build</strong> always compiles
          your text into a finished NPL prompt.
        </p>
        <textarea
          value={context}
          onChange={(e) => setContext(e.target.value)}
          rows={3}
          maxLength={2000}
          placeholder="Optional context to incorporate (domain, audience, style references)…"
          className="mt-3 w-full rounded-md border border-[var(--pg-border)] bg-[var(--pg-card)] p-3 text-sm text-[var(--pg-ink)] placeholder:text-[var(--pg-ink-faint)] focus:border-[var(--pg-accent)] focus:outline-none"
        />
        <button
          onClick={handleBuild}
          disabled={disabled}
          className="mt-4 rounded-md bg-[var(--pg-accent)] px-5 py-2 text-sm font-semibold text-[var(--pg-accent-ink)] transition-opacity hover:opacity-90 disabled:cursor-not-allowed disabled:bg-[var(--pg-active)] disabled:text-[var(--pg-ink-faint)]"
        >
          {busy ? "Building…" : "Build NPL prompt"}
        </button>

        <p className="mt-3 text-xs text-[var(--pg-ink-faint)]">
          Prompts you submit are logged and may be used for fine-tuning, evaluation, and as public
          showcase examples.
        </p>
        {status && (
          <p className="mt-3 text-xs text-[var(--pg-ink-faint)]">
            {status.enabled
              ? `Quota: ${status.requests_per_minute} builds/min · $${status.daily_cost_remaining_usd} of $${status.daily_cost_cap_usd} left today`
              : "The prompt builder is temporarily disabled."}
          </p>
        )}
        {error && <p className="mt-3 text-sm text-[var(--pg-danger)]">{error}</p>}
      </div>

      <div className="rounded-lg border border-[var(--pg-border-soft)] bg-[var(--pg-card)] p-5">
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-lg font-semibold text-[var(--pg-ink)]">Result</h2>
          {result && (
            <button
              onClick={handleCopy}
              className="rounded border border-[var(--pg-border)] px-3 py-1 text-xs font-medium text-[var(--pg-ink-soft)] hover:bg-[var(--pg-hover)]"
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
            className="w-full rounded-md border border-[var(--pg-border-soft)] bg-[var(--pg-code-bg)] p-3 font-mono text-xs text-[var(--pg-ink)]"
          />
        ) : (
          <p className="text-sm text-[var(--pg-ink-faint)]">
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
    return <p className="text-sm text-[var(--pg-ink-faint)]">Catalog failed to load — refresh to retry.</p>;
  }

  return (
    <section>
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search the catalog…"
          className="w-72 rounded-md border border-[var(--pg-border)] bg-[var(--pg-card)] px-3 py-2 text-sm text-[var(--pg-ink)] placeholder:text-[var(--pg-ink-faint)] focus:border-[var(--pg-accent)] focus:outline-none"
        />
        <select
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          className="rounded-md border border-[var(--pg-border)] bg-[var(--pg-card)] px-3 py-2 text-sm text-[var(--pg-ink)]"
        >
          <option value="all">All categories</option>
          {categoryNames.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>
        <span className="text-xs text-[var(--pg-ink-faint)]">{filtered.length} entries</span>
      </div>

      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {filtered.map((e) => (
          <button
            key={e.id}
            onClick={() => copy(e)}
            title="Click to copy"
            className="rounded-lg border border-[var(--pg-border-soft)] bg-[var(--pg-card)] p-4 text-left transition-colors hover:border-[var(--pg-accent)]"
          >
            <div className="flex items-center justify-between">
              <span className="font-mono text-lg text-[var(--pg-ink)]">{e.char || e.template}</span>
              <span className="text-xs text-[var(--pg-ink-faint)]">
                {copiedId === e.id ? "Copied ✓" : e.category}
              </span>
            </div>
            <div className="mt-1 text-sm font-medium text-[var(--pg-ink)]">{e.name}</div>
            {e.description && (
              <p className="mt-1 line-clamp-2 text-xs text-[var(--pg-ink-faint)]">{e.description}</p>
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
  const [loadFailed, setLoadFailed] = useState(false);
  const [loading, setLoading] = useState(false);
  const [query, setQuery] = useState("");
  const [group, setGroup] = useState("Symbols");
  const [copied, setCopied] = useState<string | null>(null);
  const [copyFailed, setCopyFailed] = useState(false);

  const load = useCallback(async () => {
    if (all || loading) return;
    setLoading(true);
    try {
      const db = await fetchUnicodeDb();
      // v3 loader returns [] only when the file is missing/unreachable.
      if (db.length > 0) {
        setAll(db);
      } else {
        setAll(entries.filter((e) => e.category !== "npl-syntax"));
        setLoadFailed(true);
      }
    } catch {
      setAll(entries.filter((e) => e.category !== "npl-syntax"));
      setLoadFailed(true);
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

  const groups = useMemo(
    () => (all ? [...new Set(all.map((e) => e.category))].sort() : []),
    [all],
  );

  const list = useMemo(() => {
    const q = query.trim().toLowerCase();
    const source = all ?? entries;
    return source.filter(
      (e) =>
        (group === "all" || e.category === group) &&
        (!q || e.name.toLowerCase().includes(q)),
    );
  }, [all, entries, group, query]);

  async function copy(char: string, id: string) {
    try {
      await navigator.clipboard.writeText(char);
      setCopied(id);
      setTimeout(() => setCopied(null), 1200);
    } catch {
      // Clipboard API needs a secure context — fall back to a hidden textarea.
      try {
        const ta = document.createElement("textarea");
        ta.value = char;
        ta.style.position = "fixed";
        ta.style.opacity = "0";
        document.body.appendChild(ta);
        ta.select();
        const ok = document.execCommand("copy");
        ta.remove();
        if (ok) {
          setCopied(id);
          setTimeout(() => setCopied(null), 1200);
        } else {
          setCopyFailed(true);
        }
      } catch {
        setCopyFailed(true);
      }
    }
  }

  if (loading && !all) return <p className="text-sm text-[var(--pg-ink-faint)]">Loading symbol database…</p>;

  return (
    <section>
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search by name (e.g. “arrow”, “check”)…"
          className="w-72 rounded-md border border-[var(--pg-border)] bg-[var(--pg-card)] px-3 py-2 text-sm text-[var(--pg-ink)] placeholder:text-[var(--pg-ink-faint)] focus:border-[var(--pg-accent)] focus:outline-none"
        />
        <select
          value={group}
          onChange={(e) => setGroup(e.target.value)}
          className="rounded-md border border-[var(--pg-border)] bg-[var(--pg-card)] px-3 py-2 text-sm text-[var(--pg-ink)]"
        >
          <option value="all">All groups</option>
          {groups.map((g) => (
            <option key={g} value={g}>
              {g}
            </option>
          ))}
        </select>
        <span className="text-xs text-[var(--pg-ink-faint)]">
          {list.length.toLocaleString()} symbols
        </span>
      </div>
      <p className="mb-3 text-sm text-[var(--pg-ink-faint)]">
        Click any glyph to copy.
        {loadFailed && " Full symbol database unavailable — showing the NPL catalog fallback."}
        {copyFailed && " Copy failed — your browser blocked clipboard access."}
      </p>
      {list.length === 0 ? (
        <p className="text-sm text-[var(--pg-ink-faint)]">
          No symbols match — try another name or group.
        </p>
      ) : (
        <div className="grid grid-cols-8 gap-1 sm:grid-cols-12">
          {list.slice(0, 1200).map((e) => (
            <button
              key={e.id}
              onClick={() => copy(e.char || e.template || "", e.id)}
              title={`${e.name}${e.description ? ` — ${e.description}` : ""}`}
              className="rounded border border-[var(--pg-border-soft)] bg-[var(--pg-card)] py-2 font-mono text-lg text-[var(--pg-ink)] hover:border-[var(--pg-accent)] hover:bg-[var(--pg-accent-soft)]"
            >
              {copied === e.id ? "✓" : e.char || e.template}
            </button>
          ))}
        </div>
      )}
      {list.length > 1200 && (
        <p className="mt-3 text-xs text-[var(--pg-ink-faint)]">
          Showing the first 1200 — narrow by group or search by name for more.
        </p>
      )}
    </section>
  );
}

// ── Get the NPL Keyboard (distribution) ─────────────────────────────────

function DistributionSection() {
  return (
    <section
      id="get-the-keyboard"
      className="mt-16 rounded-lg border border-[var(--pg-border-soft)] bg-[var(--pg-card-alt)] p-6"
    >
      <h2 className="text-xl font-bold text-[var(--pg-ink)]">Get the NPL Keyboard</h2>
      <p className="mt-2 max-w-3xl text-sm text-[var(--pg-ink-soft)]">
        The macOS app puts the whole NPL catalog behind a system-wide hotkey: type NPL syntax,
        unicode glyphs, and agent directives in any editor, with fuzzy search and snippet
        expansion. This web page mirrors its catalog — the native app adds hotkeys, menus, and
        offline speed.
      </p>
      <ul className="mt-4 list-inside list-disc text-sm text-[var(--pg-ink-soft)]">
        <li>Full NPL syntax palette (⌜NPL@1.0⌝ frames, directives, persona/context sections)</li>
        <li>Unicode + NPL emoji quick-pick with fuzzy search and usage descriptions</li>
        <li>Snippet templates for the common prompt structures — click to insert</li>
        <li>Native macOS speed; works offline, no account needed</li>
      </ul>
      <div className="mt-4 rounded-md bg-[var(--pg-code-bg)] p-4 font-mono text-xs text-[var(--pg-ink-soft)]">
        <div className="text-[var(--pg-ink-faint)]"># from the agent-kit repo root</div>
        <div>cd tools/npl-keyboard</div>
        <div>make install-osx</div>
      </div>
      <p className="mt-3 text-xs text-[var(--pg-ink-faint)]">
        Release zips on tag are planned — until then, build from source with the command above.
      </p>
    </section>
  );
}
