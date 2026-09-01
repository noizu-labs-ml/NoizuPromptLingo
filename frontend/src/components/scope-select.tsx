'use client';

import { useMemo, useRef, useState, useEffect, useCallback } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { ChevronDownIcon, MagnifyingGlassIcon } from '@heroicons/react/24/outline';
import { useOrg } from '@/context/org';
import type { Project } from '@/lib/api';

/**
 * Header scope selectors. Two comboboxes (org / project) built on the same
 * {@link Combobox} primitive: click opens a filter-as-you-type dropdown with
 * arrow-key navigation; the trigger always shows the full selected value
 * (wrapping, never truncating).
 */

export interface ComboboxOption {
  id: string;
  label: string;
  /** Secondary text (e.g. slug) shown right-aligned in the list. */
  hint?: string;
}

interface ComboboxProps {
  value: string | null;
  options: ComboboxOption[];
  onChange: (id: string) => void;
  placeholder: string;
  ariaLabel: string;
  disabled?: boolean;
}

const GLOBAL_OPTION_ID = '__global__';
const ALL_PROJECTS_OPTION_ID = '__all__';

function Combobox({ value, options, onChange, placeholder, ariaLabel, disabled }: ComboboxProps) {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState('');
  const [activeIndex, setActiveIndex] = useState(0);

  const rootRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const listRef = useRef<HTMLUListElement>(null);

  const selected = options.find((o) => o.id === value) ?? null;

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return options;
    return options.filter(
      (o) => o.label.toLowerCase().includes(q) || (o.hint ?? '').toLowerCase().includes(q),
    );
  }, [options, query]);

  // Close on outside click.
  useEffect(() => {
    if (!open) return;
    function onDown(e: MouseEvent) {
      if (rootRef.current && !rootRef.current.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener('mousedown', onDown);
    return () => document.removeEventListener('mousedown', onDown);
  }, [open]);

  // Fresh filter state + focus the input whenever the panel opens.
  useEffect(() => {
    if (!open) return;
    setQuery('');
    const idx = filtered.findIndex((o) => o.id === value);
    setActiveIndex(idx >= 0 ? idx : 0);
    const t = setTimeout(() => inputRef.current?.focus(), 0);
    return () => clearTimeout(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open]);

  // Keep the active option in view while arrowing through the list.
  useEffect(() => {
    listRef.current?.children[activeIndex]?.scrollIntoView({ block: 'nearest' });
  }, [activeIndex]);

  const commit = useCallback(
    (id: string) => {
      setOpen(false);
      onChange(id);
    },
    [onChange],
  );

  function onKeyDown(e: React.KeyboardEvent) {
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      setActiveIndex((i) => Math.min(i + 1, filtered.length - 1));
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setActiveIndex((i) => Math.max(i - 1, 0));
    } else if (e.key === 'Enter') {
      e.preventDefault();
      const opt = filtered[activeIndex];
      if (opt) commit(opt.id);
    } else if (e.key === 'Escape') {
      setOpen(false);
    }
  }

  return (
    <div className="scope-select" ref={rootRef}>
      <button
        type="button"
        className="scope-select__trigger"
        onClick={() => setOpen((v) => !v)}
        disabled={disabled}
        aria-label={ariaLabel}
        aria-haspopup="listbox"
        aria-expanded={open}
        title={ariaLabel}
      >
        <span className="scope-select__value">{selected?.label ?? placeholder}</span>
        <ChevronDownIcon className="scope-select__chevron" aria-hidden="true" />
      </button>

      {open && (
        <div className="scope-select__panel" role="dialog" aria-label={ariaLabel}>
          <div className="scope-select__search">
            <MagnifyingGlassIcon aria-hidden="true" />
            <input
              ref={inputRef}
              type="text"
              role="combobox"
              aria-controls="scope-select-list"
              aria-activedescendant={filtered[activeIndex] ? `scope-opt-${filtered[activeIndex].id}` : undefined}
              placeholder="Filter…"
              aria-label={`Filter ${ariaLabel}`}
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                setActiveIndex(0);
              }}
              onKeyDown={onKeyDown}
            />
          </div>
          <ul id="scope-select-list" className="scope-select__list" role="listbox" ref={listRef}>
            {filtered.length === 0 ? (
              <li className="scope-select__empty">No matches for “{query}”.</li>
            ) : (
              filtered.map((opt, i) => (
                <li
                  key={opt.id}
                  id={`scope-opt-${opt.id}`}
                  role="option"
                  aria-selected={opt.id === value}
                  data-active={i === activeIndex}
                  className="scope-select__option"
                  onMouseEnter={() => setActiveIndex(i)}
                  onClick={() => commit(opt.id)}
                >
                  <span className="scope-select__option-label">{opt.label}</span>
                  {opt.hint && <span className="scope-select__option-hint">{opt.hint}</span>}
                </li>
              ))
            )}
          </ul>
        </div>
      )}
    </div>
  );
}

/**
 * Org half of the header scope pair. Includes a "Global" option (no org) —
 * picking it clears the org and its project scope.
 */
export function OrgSelect() {
  const router = useRouter();
  const pathname = usePathname();
  const { currentOrg, organizations, switchOrg, clearOrg } = useOrg();

  const options: ComboboxOption[] = useMemo(
    () => [
      { id: GLOBAL_OPTION_ID, label: 'Global — all orgs' },
      ...organizations.map((o) => ({ id: o.id, label: o.name, hint: o.slug })),
    ],
    [organizations],
  );

  // An org switch navigates (the org slug is part of the route). Preserve any
  // deeper path (…/<slug>/tickets → …/<new-slug>/tickets) and query string.
  function navigateToOrg(slug: string) {
    const search = typeof window !== 'undefined' ? window.location.search : '';
    const segs = pathname.split('/').filter(Boolean);
    if (segs[0] === 'app' && segs.length > 1) {
      segs[1] = slug;
      router.push(`/${segs.join('/')}${search}`);
    } else {
      router.push(`/app/${slug}${search}`);
    }
  }

  function handleSelect(id: string) {
    if (id === GLOBAL_OPTION_ID) {
      clearOrg();
      router.push('/app');
      return;
    }
    const org = organizations.find((o) => o.id === id);
    if (!org) return;
    switchOrg(id);
    navigateToOrg(org.slug);
  }

  return (
    <Combobox
      value={currentOrg?.id ?? GLOBAL_OPTION_ID}
      options={options}
      onChange={handleSelect}
      placeholder="Global"
      ariaLabel="Organization"
    />
  );
}

/**
 * Project half of the header scope pair. Disabled until an org is active;
 * "All projects" clears the project scope. Scope changes apply in place
 * (org-scoped pages read the project from context); deep-link routes and
 * query params are untouched.
 */
export function ProjectSelect() {
  const { currentOrg, currentProject, projects, projectsLoading, switchProject } = useOrg();

  const options: ComboboxOption[] = useMemo(
    () => [
      { id: ALL_PROJECTS_OPTION_ID, label: 'All projects' },
      ...projects.map((p: Project) => ({ id: p.id, label: p.name, hint: p.slug })),
    ],
    [projects],
  );

  function handleSelect(id: string) {
    if (!currentOrg) return;
    if (id === ALL_PROJECTS_OPTION_ID) {
      switchProject(null, currentOrg.id);
      return;
    }
    const project = projects.find((p) => p.id === id);
    if (project) switchProject(project, currentOrg.id);
  }

  return (
    <Combobox
      value={currentProject?.id ?? ALL_PROJECTS_OPTION_ID}
      options={options}
      onChange={handleSelect}
      placeholder="All projects"
      ariaLabel="Project"
      disabled={!currentOrg || projectsLoading}
    />
  );
}
