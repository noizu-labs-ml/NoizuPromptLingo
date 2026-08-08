'use client';

import { useState, useEffect, useMemo, useCallback } from 'react';
import { toast } from 'sonner';
import {
  MagnifyingGlassIcon,
  CodeBracketIcon,
  SparklesIcon,
  XMarkIcon,
  ClipboardIcon,
  CheckIcon,
  ChevronDownIcon,
  ChevronRightIcon,
} from '@heroicons/react/24/outline';
import Editor from '@monaco-editor/react';
import {
  api,
  type NplSection,
  type NplConventionSummary,
  type NplConventionDetail,
} from '@/lib/api';

// ---------------------------------------------------------------------------
// Read-only Monaco code block. NPL examples are markdown/markup, so we render
// them as plaintext/markdown and disable editing.
// ---------------------------------------------------------------------------
function CodeBlock({ value, height = 220 }: { value: string; height?: number }) {
  return (
    <div className="npl-code" style={{ height }}>
      <Editor
        height={height}
        defaultLanguage="markdown"
        language="markdown"
        theme="vs-dark"
        value={value}
        options={{
          readOnly: true,
          minimap: { enabled: false },
          scrollBeyondLastLine: false,
          lineNumbers: 'off',
          folding: false,
          renderLineHighlight: 'none',
          fontFamily:
            '"JetBrains Mono", "SF Mono", ui-monospace, SFMono-Regular, Menlo, Consolas, monospace',
          fontSize: 12.5,
          fontLigatures: true,
          padding: { top: 10, bottom: 10 },
          scrollbar: { vertical: 'auto', horizontal: 'auto' },
          wordWrap: 'on',
          contextmenu: false,
        }}
      />
    </div>
  );
}

// ---------------------------------------------------------------------------
// Convention detail modal — syntax, examples (Monaco), labels, requires.
// ---------------------------------------------------------------------------
function ConventionDetail({
  convention,
  onClose,
}: {
  convention: NplConventionDetail;
  onClose: () => void;
}) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-card modal-card--wide"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="npl-detail__head">
          <div>
            <div className="npl-detail__breadcrumb">
              {convention.section} / {convention.slug}
            </div>
            <h2 className="modal-title">
              {convention.friendly_name || convention.name}
            </h2>
          </div>
          <button
            className="sg-btn sg-btn--outline sg-btn--sm"
            onClick={onClose}
            aria-label="Close"
          >
            <XMarkIcon className="npl-icon" />
          </button>
        </div>

        {convention.brief && (
          <p className="npl-detail__brief">{convention.brief}</p>
        )}
        {convention.description && (
          <p className="npl-detail__desc">{convention.description}</p>
        )}
        {convention.purpose && (
          <div className="npl-detail__purpose">
            <span className="npl-detail__purpose-label">Purpose</span>
            <p>{convention.purpose}</p>
          </div>
        )}

        <div className="npl-chips">
          {convention.labels.map((l) => (
            <span key={l} className="npl-chip">
              {l}
            </span>
          ))}
          {convention.category && (
            <span className="npl-chip npl-chip--cat">{convention.category}</span>
          )}
        </div>

        {convention.syntax.length > 0 && (
          <section className="npl-detail__section">
            <h3 className="npl-detail__h">Syntax</h3>
            <div className="npl-syntax-list">
              {convention.syntax.map((s, i) => (
                <div key={i} className="npl-syntax-item">
                  <code className="npl-syntax-item__code">{s.syntax}</code>
                  {s.description && (
                    <span className="npl-syntax-item__desc">{s.description}</span>
                  )}
                </div>
              ))}
            </div>
          </section>
        )}

        {convention.require.length > 0 && (
          <section className="npl-detail__section">
            <h3 className="npl-detail__h">Requires</h3>
            <div className="npl-chips">
              {convention.require.map((r) => (
                <span key={r} className="npl-chip npl-chip--req">
                  {r}
                </span>
              ))}
            </div>
          </section>
        )}

        {convention.examples.length > 0 && (
          <section className="npl-detail__section">
            <h3 className="npl-detail__h">Examples ({convention.examples.length})</h3>
            <div className="npl-examples">
              {convention.examples.map((ex, i) => (
                <div key={i} className="npl-example">
                  <div className="npl-example__head">
                    <span className="npl-example__name">
                      {ex.name || `Example ${i + 1}`}
                    </span>
                    {ex.brief && (
                      <span className="npl-example__brief">{ex.brief}</span>
                    )}
                  </div>
                  {ex.example && <CodeBlock value={ex.example} />}
                  {ex.thread.length > 0 && (
                    <CodeBlock
                      value={ex.thread
                        .map((m) => `[${m.role}]\n${m.message}`)
                        .join('\n\n')}
                      height={Math.min(
                        420,
                        Math.max(160, ex.thread.join('').length / 3),
                      )}
                    />
                  )}
                </div>
              ))}
            </div>
          </section>
        )}
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// "Generate NPL spec" panel — drives the backend NPLSpec engine via REST.
// ---------------------------------------------------------------------------
function SpecPanel({
  sections,
  conventions,
}: {
  sections: NplSection[];
  conventions: NplConventionSummary[];
}) {
  const [open, setOpen] = useState(false);
  const [selected, setSelected] = useState<string[]>([]); // spec strings like "pumps:chain-of-thought"
  const [componentPriority, setComponentPriority] = useState(0);
  const [examplePriority, setExamplePriority] = useState(0);
  const [concise, setConcise] = useState(true);
  const [xml, setXml] = useState(false);
  const [extension, setExtension] = useState(false);
  const [output, setOutput] = useState('');
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(false);

  const toggleSpec = (spec: string) =>
    setSelected((prev) =>
      prev.includes(spec) ? prev.filter((s) => s !== spec) : [...prev, spec],
    );

  async function generate() {
    setLoading(true);
    try {
      const data = await api.generateNplSpec({
        components: selected.map((spec) => ({ spec })),
        component_priority: componentPriority,
        example_priority: examplePriority,
        concise,
        xml,
        extension,
      });
      setOutput(data.spec);
      setCopied(false);
      toast.success(`Generated ${data.length} chars of NPL spec`);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to generate spec');
    } finally {
      setLoading(false);
    }
  }

  async function copy() {
    try {
      await navigator.clipboard.writeText(output);
      setCopied(true);
      toast.success('Spec copied to clipboard');
    } catch {
      toast.error('Copy failed');
    }
  }

  return (
    <div className="npl-spec">
      <button
        className="npl-spec__toggle"
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
      >
        {open ? (
          <ChevronDownIcon className="npl-icon" />
        ) : (
          <ChevronRightIcon className="npl-icon" />
        )}
        <SparklesIcon className="npl-icon npl-icon--accent" />
        Generate NPL Spec
      </button>

      {open && (
        <div className="npl-spec__body">
          <p className="npl-spec__hint">
            Build a versioned NPL specification block from the convention
            library. Select components (or leave empty for everything) and tune
            priority/format. Uses the same engine as the <code>NPLSpec</code>{' '}
            MCP tool.
          </p>

          <div className="npl-spec__controls">
            <label className="sg-field sg-field--inline">
              <span>Component priority</span>
              <input
                type="number"
                min={0}
                value={componentPriority}
                onChange={(e) => setComponentPriority(Number(e.target.value))}
              />
            </label>
            <label className="sg-field sg-field--inline">
              <span>Example priority</span>
              <input
                type="number"
                min={0}
                value={examplePriority}
                onChange={(e) => setExamplePriority(Number(e.target.value))}
              />
            </label>
            <label className="npl-check">
              <input
                type="checkbox"
                checked={concise}
                onChange={(e) => setConcise(e.target.checked)}
              />
              Concise
            </label>
            <label className="npl-check">
              <input
                type="checkbox"
                checked={xml}
                onChange={(e) => setXml(e.target.checked)}
              />
              XML examples
            </label>
            <label className="npl-check">
              <input
                type="checkbox"
                checked={extension}
                onChange={(e) => setExtension(e.target.checked)}
              />
              Extend marker
            </label>
          </div>

          <details className="npl-spec__picker">
            <summary>
              Components ({selected.length} selected · click to{' '}
              {selected.length ? 'edit' : 'pick'})
            </summary>
            <div className="npl-spec__picker-grid">
              {sections.map((s) => (
                <div key={s.section} className="npl-spec__picker-section">
                  <div className="npl-spec__picker-section-title">
                    {s.title}{' '}
                    <span className="npl-spec__picker-count">
                      {s.component_count}
                    </span>
                  </div>
                  {conventions
                    .filter((c) => c.section === s.section)
                    .map((c) => {
                      const spec = `${c.section}:${c.slug}`;
                      const on = selected.includes(spec);
                      return (
                        <button
                          key={`${c.section}-${c.slug}`}
                          type="button"
                          className={`npl-spec__picker-chip${on ? ' is-on' : ''}`}
                          onClick={() => toggleSpec(spec)}
                        >
                          {on ? <CheckIcon className="npl-icon" /> : null}
                          {c.slug}
                        </button>
                      );
                    })}
                </div>
              ))}
            </div>
          </details>

          <div className="npl-spec__actions">
            <button
              className="sg-btn sg-btn--black sg-btn--sm"
              onClick={generate}
              disabled={loading}
            >
              {loading ? 'Generating…' : 'Generate'}
            </button>
            {output && (
              <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={copy}>
                {copied ? (
                  <>
                    <CheckIcon className="npl-icon" /> Copied
                  </>
                ) : (
                  <>
                    <ClipboardIcon className="npl-icon" /> Copy
                  </>
                )}
              </button>
            )}
          </div>

          {output && <CodeBlock value={output} height={420} />}
        </div>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
export default function NplConventionsPage() {
  const [sections, setSections] = useState<NplSection[]>([]);
  const [conventions, setConventions] = useState<NplConventionSummary[]>([]);
  const [activeSection, setActiveSection] = useState<string | null>(null);
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [detail, setDetail] = useState<NplConventionDetail | null>(null);
  const [detailLoading, setDetailLoading] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [sec, conv] = await Promise.all([
        api.listNplSections(),
        api.listNplConventions(),
      ]);
      setSections(sec.sections ?? []);
      setConventions(conv.conventions ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load NPL conventions');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return conventions.filter((c) => {
      if (activeSection && c.section !== activeSection) return false;
      if (!q) return true;
      return (
        c.name.toLowerCase().includes(q) ||
        c.slug.toLowerCase().includes(q) ||
        c.brief.toLowerCase().includes(q) ||
        c.labels.some((l) => l.toLowerCase().includes(q)) ||
        (c.friendly_name?.toLowerCase().includes(q) ?? false)
      );
    });
  }, [conventions, activeSection, query]);

  async function openConvention(c: NplConventionSummary) {
    setDetailLoading(true);
    try {
      const data = await api.getNplConvention(c.section, c.slug);
      setDetail(data.convention);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load convention');
    } finally {
      setDetailLoading(false);
    }
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">NPL Conventions</h1>
        <p className="sg-page-intro">
          Browse, search, and reference Noizu Prompt Lingua conventions —
          syntax, pumps, directives, and prompt sections. Generate a versioned
          spec block for your system prompt.
        </p>

        <SpecPanel sections={sections} conventions={conventions} />

        <div className="npl-toolbar">
          <div className="npl-search">
            <MagnifyingGlassIcon className="npl-icon npl-search__icon" />
            <input
              className="npl-search__input"
              type="search"
              placeholder="Search conventions, labels, syntax…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              aria-label="Search NPL conventions"
            />
          </div>
          <div className="npl-section-chips">
            <button
              className={`npl-section-chip${activeSection === null ? ' is-active' : ''}`}
              onClick={() => setActiveSection(null)}
            >
              All
              <span className="npl-section-chip__count">{conventions.length}</span>
            </button>
            {sections.map((s) => (
              <button
                key={s.section}
                className={`npl-section-chip${activeSection === s.section ? ' is-active' : ''}`}
                onClick={() =>
                  setActiveSection((prev) => (prev === s.section ? null : s.section))
                }
              >
                {s.title}
                <span className="npl-section-chip__count">{s.component_count}</span>
              </button>
            ))}
          </div>
        </div>

        {loading ? (
          <p className="sg-page-intro">Loading conventions…</p>
        ) : filtered.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No conventions match your search.</p>
          </div>
        ) : (
          <div className="projects-grid npl-grid">
            {filtered.map((c) => (
              <button
                key={`${c.section}-${c.slug}`}
                className="project-card npl-card"
                onClick={() => openConvention(c)}
                disabled={detailLoading}
              >
                <div className="project-card__header">
                  <div className="project-card__name">
                    {c.friendly_name || c.name}
                  </div>
                  <div className="project-card__slug">{c.slug}</div>
                </div>
                <div className="project-card__body">
                  <p className="npl-card__brief">{c.brief || c.name}</p>
                  <div className="project-card__meta">
                    <span className="npl-card__section">{c.section}</span>
                  </div>
                  <div className="npl-chips npl-chips--compact">
                    {c.labels.slice(0, 3).map((l) => (
                      <span key={l} className="npl-chip">
                        {l}
                      </span>
                    ))}
                    {c.labels.length > 3 && (
                      <span className="npl-chip">+{c.labels.length - 3}</span>
                    )}
                  </div>
                  <div className="project-card__actions">
                    <span className="sg-btn sg-btn--outline sg-btn--sm">
                      <CodeBracketIcon className="npl-icon" /> View
                    </span>
                  </div>
                </div>
              </button>
            ))}
          </div>
        )}
      </main>

      {detail && (
        <ConventionDetail convention={detail} onClose={() => setDetail(null)} />
      )}
    </div>
  );
}
