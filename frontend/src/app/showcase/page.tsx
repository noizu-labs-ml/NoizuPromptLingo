"use client";

import { useEffect, useState } from "react";

import { fetchShowcase, type ShowcaseEntry } from "@/lib/api/prompt-builder";

// ── NPL Showcase Gallery ──
// Public page: logged (consented) builder prompts, rewritten as full NPL
// prompts and evaluated OP-vs-NPL by a fixed rubric. Visible on both sites;
// the NPL site (tobor.locker) is the primary showcase venue.

export default function ShowcasePage() {
  const [entries, setEntries] = useState<ShowcaseEntry[] | null>(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    fetchShowcase()
      .then((r) => setEntries(r.entries))
      .catch(() => setError(true));
  }, []);

  return (
    <main className="mx-auto max-w-6xl px-4 pb-20 pt-10">
      <header className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight text-slate-900">NPL Showcase</h1>
        <p className="mt-2 max-w-3xl text-slate-600">
          Real prompts from the NPL Keyboard builder, rewritten as full Noizu Prompt Lingua
          documents and put to the test: both versions run against the same input, then a fixed
          rubric (structure, clarity, completeness, conventions, fitness) scores each 0–100.
        </p>
        <p className="mt-2 text-xs text-slate-400">
          Entries are built from logged builder prompts — prompts you submit are logged and may be
          used for fine-tuning, evaluation, and as public showcase examples.
        </p>
      </header>

      {error && <p className="text-sm text-slate-500">Showcase is unavailable right now.</p>}
      {entries === null && !error && <p className="text-sm text-slate-500">Loading…</p>}
      {entries !== null && entries.length === 0 && (
        <p className="text-sm text-slate-500">No showcase entries yet — build a prompt on the{" "}
          <a className="text-blue-600 underline" href="/keyboard">keyboard page</a> to seed the first.
        </p>
      )}

      <div className="flex flex-col gap-8">
        {(entries ?? []).map((e) => (
          <ShowcaseCard key={e.id} entry={e} />
        ))}
      </div>
    </main>
  );
}

function ShowcaseCard({ entry }: { entry: ShowcaseEntry }) {
  const [tab, setTab] = useState<"outputs" | "prompts" | "rubric">("outputs");
  const nplWon = entry.winner === "npl";

  return (
    <article className="rounded-lg border border-slate-200 bg-white p-5">
      <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
        <h2 className="max-w-3xl text-sm font-medium text-slate-700">{entry.original_prompt}</h2>
        <span
          className={`rounded px-2 py-1 text-xs font-semibold ${
            nplWon ? "bg-green-100 text-green-800" : entry.winner === "tie" ? "bg-slate-100 text-slate-700" : "bg-amber-100 text-amber-800"
          }`}
        >
          {entry.score_original} vs {entry.score_npl} —{" "}
          {entry.winner === "tie" ? "Tie" : nplWon ? "NPL wins!" : "Original wins"}
        </span>
      </div>

      <div className="mb-3 grid gap-3 text-xs text-slate-500 sm:grid-cols-2">
        <div className="rounded bg-slate-50 p-2">
          <strong className="text-slate-600">Original context</strong> · {entry.context_sizes.original.chars} chars ≈{" "}
          {entry.context_sizes.original.tokens} tokens
        </div>
        <div className="rounded bg-slate-50 p-2">
          <strong className="text-slate-600">NPL context</strong> · {entry.context_sizes.npl.chars} chars ≈{" "}
          {entry.context_sizes.npl.tokens} tokens
        </div>
      </div>

      <nav className="mb-3 flex gap-2">
        {(
          [
            ["outputs", "Outputs"],
            ["prompts", "Prompts"],
            ["rubric", "Rubric + Analysis"],
          ] as [typeof tab, string][]
        ).map(([id, label]) => (
          <button
            key={id}
            onClick={() => setTab(id)}
            className={`rounded px-3 py-1 text-xs font-medium ${tab === id ? "bg-slate-900 text-white" : "bg-slate-100 text-slate-600 hover:bg-slate-200"}`}
          >
            {label}
          </button>
        ))}
      </nav>

      {tab === "outputs" && (
        <div className="grid gap-4 lg:grid-cols-2">
          <Panel title="Original output" body={entry.original_output} />
          <Panel title="NPL output" body={entry.npl_output} />
        </div>
      )}

      {tab === "prompts" && (
        <div className="grid gap-4 lg:grid-cols-2">
          <Panel title="Original prompt (as submitted)" body={entry.original_prompt} mono />
          <Panel title="NPL prompt (rewrite)" body={entry.npl_prompt} mono />
        </div>
      )}

      {tab === "rubric" && (
        <div className="grid gap-4 lg:grid-cols-2">
          <div className="text-xs text-slate-600">
            {entry.rubric && (
              <table className="w-full border-collapse">
                <thead>
                  <tr className="text-left text-slate-400">
                    <th className="py-1">Dimension (0–25)</th>
                    <th className="py-1">Original</th>
                    <th className="py-1">NPL</th>
                  </tr>
                </thead>
                <tbody>
                  {["structure", "clarity", "completeness", "conventions", "fitness", "total"].map((dim) => (
                    <tr key={dim} className={dim === "total" ? "font-semibold" : ""}>
                      <td className="py-1">{dim}</td>
                      <td className="py-1">{entry.rubric?.original?.[dim] ?? "—"}</td>
                      <td className="py-1">{entry.rubric?.npl?.[dim] ?? "—"}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
          <div className="rounded bg-slate-50 p-3 text-xs leading-relaxed text-slate-700">
            <strong>Difference analysis.</strong> {entry.difference_analysis}
          </div>
        </div>
      )}
    </article>
  );
}

function Panel({ title, body, mono }: { title: string; body: string | null; mono?: boolean }) {
  return (
    <div className="rounded border border-slate-200">
      <div className="border-b border-slate-100 px-3 py-2 text-xs font-semibold text-slate-500">{title}</div>
      <pre className={`max-h-72 overflow-auto whitespace-pre-wrap p-3 text-xs leading-relaxed text-slate-800 ${mono ? "font-mono" : ""}`}>
        {body || "—"}
      </pre>
    </div>
  );
}
