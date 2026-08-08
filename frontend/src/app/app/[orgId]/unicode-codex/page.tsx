'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import { toast } from 'sonner';
import {
  ClipboardIcon,
  CodeBracketIcon,
  ExclamationTriangleIcon,
  LinkIcon,
  MagnifyingGlassIcon,
  XMarkIcon,
} from '@heroicons/react/24/outline';
import { useOrg, useOrgId } from '@/context/org';
import {
  api,
  type Project,
  type UnicodeElement,
  type UnicodeSpecialUsage,
} from '@/lib/api';

type PrintableFilter = 'all' | 'printable' | 'non-printable';

function ScopeBadge({ scope }: { scope: string }) {
  return <span className={`unicode-scope unicode-scope--${scope}`}>{scope}</span>;
}

function UnicodeDisplay({ element }: { element: UnicodeElement }) {
  const unsafe = element.warnings.length > 0 || !element.copy_value;
  return (
    <span className={`unicode-display${unsafe ? ' unicode-display--safe-label' : ''}`}>
      {element.display}
    </span>
  );
}

function DetailDrawer({
  detail,
  layers,
  onClose,
}: {
  detail: UnicodeElement;
  layers: UnicodeElement[];
  onClose: () => void;
}) {
  async function copy(label: string, value?: string | null) {
    if (!value) {
      toast.error(`${label} is not safe to copy directly`);
      return;
    }
    await navigator.clipboard.writeText(value);
    toast.success(`${label} copied`);
  }

  const escapeValues = [
    detail.codepoint,
    ...(detail.escape_forms.unicode ?? []),
    ...(detail.escape_forms.hex ?? []),
    ...(detail.escape_forms.html ?? []),
  ].filter(Boolean) as string[];

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card modal-card--wide unicode-detail" onClick={(e) => e.stopPropagation()}>
        <div className="npl-detail__head">
          <div className="unicode-detail__identity">
            <UnicodeDisplay element={detail} />
            <div>
              <div className="npl-detail__breadcrumb">
                {detail.codepoint || detail.slug} / {detail.visibility}
              </div>
              <h2 className="modal-title">{detail.title}</h2>
            </div>
          </div>
          <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={onClose} aria-label="Close">
            <XMarkIcon className="npl-icon" />
          </button>
        </div>

        <div className="unicode-meta-row">
          <ScopeBadge scope={detail.scope} />
          <span className="npl-chip">{detail.name}</span>
          {detail.warnings.map((warning) => (
            <span key={warning} className="npl-chip unicode-chip--warn">
              <ExclamationTriangleIcon className="npl-icon" /> {warning}
            </span>
          ))}
        </div>

        {detail.description && <p className="npl-detail__desc">{detail.description}</p>}
        {detail.meaning && (
          <div className="npl-detail__purpose">
            <span className="npl-detail__purpose-label">Meaning</span>
            <p>{detail.meaning}</p>
          </div>
        )}

        <section className="npl-detail__section">
          <h3 className="npl-detail__h">Copy</h3>
          <div className="unicode-copy-grid">
            <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => copy('Character', detail.copy_value)}>
              <ClipboardIcon className="npl-icon" /> Character
            </button>
            {escapeValues.map((value) => (
              <button key={value} className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => copy(value, value)}>
                <CodeBracketIcon className="npl-icon" /> {value}
              </button>
            ))}
          </div>
        </section>

        <section className="npl-detail__section">
          <h3 className="npl-detail__h">Tags</h3>
          <div className="npl-chips">
            {detail.flags.map((flag) => <span key={flag} className="npl-chip">{flag}</span>)}
            {detail.topics.map((topic) => <span key={topic} className="npl-chip npl-chip--cat">{topic}</span>)}
          </div>
        </section>

        {detail.special_usages.length > 0 && (
          <section className="npl-detail__section">
            <h3 className="npl-detail__h">Special Usage</h3>
            <div className="unicode-usage-list">
              {detail.special_usages.map((usage) => (
                <span key={`${usage.scope}-${usage.slug}`} className="unicode-usage">
                  <LinkIcon className="npl-icon" /> {usage.title}
                </span>
              ))}
            </div>
          </section>
        )}

        {layers.length > 1 && (
          <section className="npl-detail__section">
            <h3 className="npl-detail__h">Layers</h3>
            <div className="unicode-layer-list">
              {layers.map((layer) => (
                <div key={layer.id} className="unicode-layer-row">
                  <ScopeBadge scope={layer.scope} />
                  <span>{layer.title}</span>
                  {layer.shadowed_by && <span className="unicode-muted">shadowed</span>}
                </div>
              ))}
            </div>
          </section>
        )}
      </div>
    </div>
  );
}

export default function UnicodeCodexPage() {
  const { orgId } = useOrgId();
  const { projects, projectsLoading, currentProject, switchProject } = useOrg();
  const [elements, setElements] = useState<UnicodeElement[]>([]);
  const [specialUsages, setSpecialUsages] = useState<UnicodeSpecialUsage[]>([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState('');
  const [topic, setTopic] = useState('');
  const [flag, setFlag] = useState('');
  const [usage, setUsage] = useState('');
  const [printable, setPrintable] = useState<PrintableFilter>('all');
  const [includeShadowed, setIncludeShadowed] = useState(false);
  const [detail, setDetail] = useState<{ element: UnicodeElement; layers: UnicodeElement[] } | null>(null);

  const projectId = currentProject?.id ?? null;

  const load = useCallback(async () => {
    if (!orgId) return;
    setLoading(true);
    try {
      const printableValue =
        printable === 'all' ? null : printable === 'printable';

      const [elementRes, usageRes] = await Promise.all([
        api.listUnicodeElements(orgId, {
          projectId,
          q: query.trim() || undefined,
          topic: topic || undefined,
          flag: flag || undefined,
          usage: usage || undefined,
          printable: printableValue,
          includeShadowed,
          limit: 250,
        }),
        api.listUnicodeSpecialUsages(orgId, { projectId }),
      ]);
      setElements(elementRes.elements ?? []);
      setSpecialUsages(usageRes.special_usages ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load Unicode Codex');
    } finally {
      setLoading(false);
    }
  }, [flag, includeShadowed, orgId, printable, projectId, query, topic, usage]);

  useEffect(() => {
    load();
  }, [load]);

  const topics = useMemo(
    () => Array.from(new Set(elements.flatMap((element) => element.topics))).sort(),
    [elements],
  );
  const flags = useMemo(
    () => Array.from(new Set(elements.flatMap((element) => element.flags))).sort(),
    [elements],
  );

  async function openElement(element: UnicodeElement) {
    if (!orgId) return;
    try {
      const result = await api.getUnicodeElement(orgId, element.slug, { projectId });
      setDetail({ element: result.element, layers: result.layers });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load Unicode element');
    }
  }

  function onProjectChange(projectValue: string) {
    const next: Project | null = projectValue
      ? projects.find((project) => project.id === projectValue) ?? null
      : null;
    switchProject(next);
  }

  return (
    <div className="content">
      <main>
        <div className="unicode-title-row">
          <div>
            <h1 className="sg-page-title">Unicode Codex</h1>
          </div>
          <label className="unicode-toggle">
            <input
              type="checkbox"
              checked={includeShadowed}
              onChange={(event) => setIncludeShadowed(event.target.checked)}
            />
            <span>Show shadowed layers</span>
          </label>
        </div>

        <div className="npl-toolbar unicode-toolbar">
          <div className="npl-search">
            <MagnifyingGlassIcon className="npl-icon npl-search__icon" />
            <input
              className="npl-search__input"
              type="search"
              placeholder="Search Unicode, controls, NPL markers..."
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              aria-label="Search Unicode Codex"
            />
          </div>

          <div className="unicode-filter-row">
            <select value={projectId ?? ''} onChange={(event) => onProjectChange(event.target.value)} disabled={projectsLoading}>
              <option value="">Organization scope</option>
              {projects.map((project) => (
                <option key={project.id} value={project.id}>{project.name}</option>
              ))}
            </select>
            <select value={usage} onChange={(event) => setUsage(event.target.value)}>
              <option value="">All usages</option>
              {specialUsages.map((item) => (
                <option key={`${item.scope}-${item.slug}`} value={item.slug}>{item.title}</option>
              ))}
            </select>
            <select value={topic} onChange={(event) => setTopic(event.target.value)}>
              <option value="">All topics</option>
              {topics.map((item) => <option key={item} value={item}>{item}</option>)}
            </select>
            <select value={flag} onChange={(event) => setFlag(event.target.value)}>
              <option value="">All flags</option>
              {flags.map((item) => <option key={item} value={item}>{item}</option>)}
            </select>
          </div>

          <div className="npl-section-chips">
            {(['all', 'printable', 'non-printable'] as PrintableFilter[]).map((mode) => (
              <button
                key={mode}
                className={`npl-section-chip${printable === mode ? ' is-active' : ''}`}
                onClick={() => setPrintable(mode)}
              >
                {mode === 'all' ? 'All' : mode}
              </button>
            ))}
          </div>
        </div>

        {loading ? (
          <p className="sg-page-intro">Loading Unicode Codex...</p>
        ) : elements.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No Unicode entries match the current filters.</p>
          </div>
        ) : (
          <div className="unicode-grid">
            {elements.map((element) => (
              <button
                key={`${element.scope}-${element.id}`}
                className={`unicode-card${element.shadowed_by ? ' is-shadowed' : ''}`}
                onClick={() => openElement(element)}
              >
                <div className="unicode-card__glyph">
                  <UnicodeDisplay element={element} />
                </div>
                <div className="unicode-card__body">
                  <div className="unicode-card__head">
                    <span className="unicode-card__title">{element.title}</span>
                    <ScopeBadge scope={element.scope} />
                  </div>
                  <div className="unicode-card__meta">
                    <span>{element.codepoint || element.slug}</span>
                    <span>{element.visibility}</span>
                  </div>
                  <p className="unicode-card__desc">{element.description || element.name}</p>
                  <div className="npl-chips npl-chips--compact">
                    {element.warnings.slice(0, 2).map((warning) => (
                      <span key={warning} className="npl-chip unicode-chip--warn">
                        {warning}
                      </span>
                    ))}
                    {element.flags.slice(0, Math.max(0, 3 - element.warnings.length)).map((item) => (
                      <span key={item} className="npl-chip">{item}</span>
                    ))}
                  </div>
                </div>
              </button>
            ))}
          </div>
        )}
      </main>

      {detail && (
        <DetailDrawer
          detail={detail.element}
          layers={detail.layers}
          onClose={() => setDetail(null)}
        />
      )}
    </div>
  );
}
