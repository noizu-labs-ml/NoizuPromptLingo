'use client';

// DataTable — config-driven console list primitive (ticket 0f8453f5, diego-frontend).
// Driven entirely by a ConsoleDescriptor (yuki §6): sort / filter / paginate, row +
// empty/loading/error states, density, bulk-select, and an accessible row kebab.
//
// a11y bar (§4): the table is a roving-tabindex grid — ArrowUp/Down move the active
// row, Home/End jump, Enter opens detail; only the active row is in the tab order.
// Sortable headers are buttons with aria-sort. The kebab is a real menu-button
// (aria-haspopup/expanded, arrow roving, Esc-restores-focus, outside-click dismiss)
// — same contract as the ReactionPicker. visibleWhen gates action visibility only.
import { useState, useEffect, useMemo, useRef, useCallback } from 'react';
import type { ReactNode, KeyboardEvent } from 'react';
import type {
  ConsoleDescriptor,
  ConsoleContext,
  ColumnDef,
  ActionDef,
  BuiltinRowAction,
  FacetOption,
} from '@/lib/console/types';
import { renderField } from '@/lib/console/render-hints';

type Row = Record<string, unknown>;

export interface DataTableProps<T, TInput> {
  descriptor: ConsoleDescriptor<T, TInput>;
  ctx: ConsoleContext;
  /** Row opened (primary-cell click or Enter) → detail. */
  onOpenRow?: (row: T) => void;
  onEditRow?: (row: T) => void;
  onDeleteRow?: (row: T) => void;
  /** Handler for bare custom row-action keys (e.g. 'archive'). */
  onAction?: (key: string, row: T) => void;
  /**
   * G1 (priya seq495): bump this to refetch IN PLACE after a create/edit/delete —
   * preserves sort/filter/page state (vs a key-remount, which loses it).
   */
  refreshKey?: number;
  /** G2 (priya seq495): per-row class hook — e.g. mark the active scope / unread / selected. */
  rowClassName?: (row: T, ctx: ConsoleContext) => string | undefined;
  /**
   * Mei #2 (seq493): resolved options for `dynamic` facets, keyed by filter key.
   * DataTable doesn't fetch domain options itself (it can't know how); the page
   * resolves them (e.g. api.listProjects) and injects them here.
   */
  facetOptions?: Record<string, { value: string; label: string }[]>;
  /** Embedded related mini-table: drops the filter/pagination chrome, fixed scope. */
  embedded?: boolean;
  /** Extra api.list opts (related-table scope query, or a parent facet). */
  scope?: Record<string, unknown>;
  density?: 'comfortable' | 'compact';
  pageSize?: number;
}

function cell(row: Row, key: string): unknown {
  return row[key];
}

export function DataTable<T, TInput>({
  descriptor,
  ctx,
  onOpenRow,
  onEditRow,
  onDeleteRow,
  onAction,
  refreshKey = 0,
  rowClassName,
  facetOptions,
  embedded = false,
  scope,
  density = 'comfortable',
  pageSize = 25,
}: DataTableProps<T, TInput>) {
  const { columns, filters, labels, idKey = 'id', actions } = descriptor;

  const [rows, setRows] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [query, setQuery] = useState('');
  // Facet value is a string (single-select) or string[] (multi-select).
  const [facets, setFacets] = useState<Record<string, string | string[]>>({});
  const [sortKey, setSortKey] = useState<string | null>(null);
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>('asc');
  const [page, setPage] = useState(0);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [activeRow, setActiveRow] = useState(0);

  const rowId = useCallback((row: T) => String((row as Row)[idKey]), [idKey]);

  // Fetch on mount + whenever server-side facet scope changes (search/sort/paginate
  // stay client-side over the result set — console scale, deterministic).
  useEffect(() => {
    let live = true;
    setLoading(true);
    setError(null);
    const opts: Record<string, unknown> = { ...scope };
    // Single facet -> string; multi facet -> non-empty array (BE accepts array params).
    for (const [k, v] of Object.entries(facets)) {
      if (Array.isArray(v) ? v.length > 0 : v) opts[k] = v;
    }
    descriptor.api
      .list(ctx.orgId, opts)
      .then((data) => {
        if (!live) return;
        setRows(data);
      })
      .catch((e: unknown) => {
        if (!live) return;
        setError(e instanceof Error ? e.message : `Failed to load ${labels.plural.toLowerCase()}`);
        setRows([]);
      })
      .finally(() => live && setLoading(false));
    return () => {
      live = false;
    };
    // refreshKey forces a refetch in place (G1) — page/sort/filter state is NOT reset
    // here; only a genuine scope change (below) resets paging.
  }, [descriptor.api, ctx.orgId, facets, scope, refreshKey, labels.plural]);

  // Reset paging/active row only when the dataset SCOPE changes — not on a refresh-in-place.
  useEffect(() => {
    setPage(0);
    setActiveRow(0);
  }, [ctx.orgId, facets, scope]);

  const searched = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return rows;
    return rows.filter((r) =>
      columns.some((c) => String(cell(r as Row, c.key) ?? '').toLowerCase().includes(q)),
    );
  }, [rows, query, columns]);

  const sorted = useMemo(() => {
    if (!sortKey) return searched;
    const dir = sortDir === 'asc' ? 1 : -1;
    return [...searched].sort((a, b) => {
      const av = cell(a as Row, sortKey);
      const bv = cell(b as Row, sortKey);
      if (av == null) return 1;
      if (bv == null) return -1;
      if (typeof av === 'number' && typeof bv === 'number') return (av - bv) * dir;
      return String(av).localeCompare(String(bv)) * dir;
    });
  }, [searched, sortKey, sortDir]);

  const pageCount = Math.max(1, Math.ceil(sorted.length / pageSize));
  const pageRows = embedded ? sorted : sorted.slice(page * pageSize, page * pageSize + pageSize);

  function toggleSort(key: string) {
    if (sortKey === key) setSortDir((d) => (d === 'asc' ? 'desc' : 'asc'));
    else {
      setSortKey(key);
      setSortDir('asc');
    }
  }

  function onRowsKeyDown(e: KeyboardEvent<HTMLTableSectionElement>) {
    const n = pageRows.length;
    if (n === 0) return;
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setActiveRow((i) => Math.min(n - 1, i + 1));
        break;
      case 'ArrowUp':
        e.preventDefault();
        setActiveRow((i) => Math.max(0, i - 1));
        break;
      case 'Home':
        e.preventDefault();
        setActiveRow(0);
        break;
      case 'End':
        e.preventDefault();
        setActiveRow(n - 1);
        break;
      case 'Enter':
        e.preventDefault();
        if (onOpenRow && pageRows[activeRow]) onOpenRow(pageRows[activeRow]);
        break;
      default:
        break;
    }
  }

  const bulkEnabled = !embedded && (actions?.bulkActions?.length ?? 0) > 0;

  function renderCell(col: ColumnDef<T>, row: T): ReactNode {
    return renderField(col.render, col.key, row);
  }

  if (loading) return <p className="console-state" role="status">Loading {labels.plural.toLowerCase()}…</p>;
  if (error)
    return (
      <div className="console-state console-state--error" role="alert">
        {error}
        <button type="button" className="sg-btn" onClick={() => setFacets((f) => ({ ...f }))}>
          Retry
        </button>
      </div>
    );

  return (
    <div className={`console-table console-table--${density}`}>
      {!embedded && (filters?.length ?? 0) > 0 && (
        <div className="console-filters" role="search">
          {filters!.map((f) => {
            if (f.type === 'search') {
              return (
                <input
                  key={f.key}
                  type="search"
                  className="console-filters__search"
                  placeholder={`${f.label}…`}
                  aria-label={f.label}
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                />
              );
            }
            // dynamic facets take their options from the page-injected facetOptions (Mei #2).
            const opts = (f.dynamic ? facetOptions?.[f.key] : f.options) ?? [];
            if (f.multi) {
              const sel = Array.isArray(facets[f.key]) ? (facets[f.key] as string[]) : [];
              return (
                <FacetMultiSelect
                  key={f.key}
                  label={f.label}
                  options={opts}
                  selected={sel}
                  onChange={(vals) => setFacets((prev) => ({ ...prev, [f.key]: vals }))}
                />
              );
            }
            const single = typeof facets[f.key] === 'string' ? (facets[f.key] as string) : '';
            return (
              <label key={f.key} className="console-filters__facet">
                <span className="sr-only">{f.label}</span>
                <select
                  value={single}
                  onChange={(e) => setFacets((prev) => ({ ...prev, [f.key]: e.target.value }))}
                  aria-label={f.label}
                >
                  <option value="">{f.label}: all</option>
                  {opts.map((o) => (
                    <option key={o.value} value={o.value}>
                      {o.label}
                    </option>
                  ))}
                </select>
              </label>
            );
          })}
        </div>
      )}

      {pageRows.length === 0 ? (
        <p className="console-state console-state--empty">No {labels.plural.toLowerCase()} found.</p>
      ) : (
        <table className="console-table__grid">
          <thead>
            <tr>
              {bulkEnabled && <th className="console-table__check" scope="col" aria-label="Select" />}
              {columns.map((c) => {
                const isSorted = sortKey === c.key;
                return (
                  <th
                    key={c.key}
                    scope="col"
                    style={c.width ? { width: c.width } : undefined}
                    aria-sort={isSorted ? (sortDir === 'asc' ? 'ascending' : 'descending') : undefined}
                    className={c.align ? `is-${c.align}` : undefined}
                  >
                    {c.sortable ? (
                      <button type="button" className="console-table__sort" onClick={() => toggleSort(c.key)}>
                        {c.label}
                        <span aria-hidden className="console-table__sort-ind">
                          {isSorted ? (sortDir === 'asc' ? '▲' : '▼') : ''}
                        </span>
                      </button>
                    ) : (
                      c.label
                    )}
                  </th>
                );
              })}
              <th scope="col" className="console-table__actions-col" aria-label="Actions" />
            </tr>
          </thead>
          <tbody onKeyDown={onRowsKeyDown}>
            {pageRows.map((row, i) => {
              const id = rowId(row);
              return (
                <tr
                  key={id}
                  className={`console-table__row${i === activeRow ? ' is-active' : ''}${
                    rowClassName?.(row, ctx) ? ` ${rowClassName(row, ctx)}` : ''
                  }`}
                  tabIndex={i === activeRow ? 0 : -1}
                  aria-selected={selected.has(id) || undefined}
                  onFocus={() => setActiveRow(i)}
                >
                  {bulkEnabled && (
                    <td className="console-table__check">
                      <input
                        type="checkbox"
                        aria-label={`Select row ${i + 1}`}
                        checked={selected.has(id)}
                        onChange={(e) =>
                          setSelected((prev) => {
                            const next = new Set(prev);
                            if (e.target.checked) next.add(id);
                            else next.delete(id);
                            return next;
                          })
                        }
                      />
                    </td>
                  )}
                  {columns.map((c) => (
                    <td key={c.key} className={c.align ? `is-${c.align}` : undefined}>
                      {c.primary && onOpenRow ? (
                        <button type="button" className="console-table__open" onClick={() => onOpenRow(row)}>
                          {renderCell(c, row)}
                        </button>
                      ) : (
                        renderCell(c, row)
                      )}
                    </td>
                  ))}
                  <td className="console-table__actions-col">
                    <RowMenu
                      row={row}
                      ctx={ctx}
                      actions={actions?.rowActions}
                      api={descriptor.api}
                      onOpenRow={onOpenRow}
                      onEditRow={onEditRow}
                      onDeleteRow={onDeleteRow}
                      onAction={onAction}
                      canEdit={actions?.canEdit}
                      canDelete={actions?.canDelete}
                      label={labels.singular}
                    />
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      )}

      {!embedded && pageCount > 1 && (
        <nav className="console-pager" aria-label="Pagination">
          <button type="button" className="sg-btn" disabled={page === 0} onClick={() => setPage((p) => p - 1)}>
            ← Prev
          </button>
          <span className="console-pager__status" aria-live="polite">
            Page {page + 1} of {pageCount}
          </span>
          <button
            type="button"
            className="sg-btn"
            disabled={page >= pageCount - 1}
            onClick={() => setPage((p) => p + 1)}
          >
            Next →
          </button>
        </nav>
      )}
    </div>
  );
}

// Accessible per-row kebab menu-button (same focus contract as ReactionPicker):
// aria-haspopup/expanded, arrow-key roving, Home/End, Esc-closes-and-restores-focus,
// outside-click dismiss. Built-ins (view/edit/delete) wire from the api + callbacks;
// custom ActionDefs honor their visibleWhen(ctx) gate (visibility only).
function RowMenu<T, TInput>({
  row,
  ctx,
  actions,
  api,
  onOpenRow,
  onEditRow,
  onDeleteRow,
  onAction,
  canEdit,
  canDelete,
  label,
}: {
  row: T;
  ctx: ConsoleContext;
  actions?: (BuiltinRowAction | (string & {}) | ActionDef<T>)[];
  api: ConsoleDescriptor<T, TInput>['api'];
  onOpenRow?: (row: T) => void;
  onEditRow?: (row: T) => void;
  onDeleteRow?: (row: T) => void;
  onAction?: (key: string, row: T) => void;
  canEdit?: (row: T, ctx: ConsoleContext) => boolean;
  canDelete?: (row: T, ctx: ConsoleContext) => boolean;
  label: string;
}) {
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState(0);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const menuRef = useRef<HTMLDivElement>(null);
  const itemRefs = useRef<(HTMLButtonElement | null)[]>([]);

  type Item = { key: string; label: string; run: () => void | Promise<void>; danger?: boolean };
  const items: Item[] = [];
  const titleCase = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);
  const list: (BuiltinRowAction | (string & {}) | ActionDef<T>)[] = actions ?? ['view', 'edit', 'delete'];
  for (const a of list) {
    if (a === 'view' && onOpenRow) items.push({ key: 'view', label: 'View', run: () => onOpenRow(row) });
    else if (a === 'edit' && api.update && onEditRow && (canEdit?.(row, ctx) ?? true))
      items.push({ key: 'edit', label: 'Edit', run: () => onEditRow(row) });
    else if (a === 'delete' && api.remove && onDeleteRow && (canDelete?.(row, ctx) ?? true))
      items.push({ key: 'delete', label: 'Delete', run: () => onDeleteRow(row), danger: true });
    else if (typeof a === 'object') {
      if (a.visibleWhen && !a.visibleWhen(row, ctx)) continue; // RBAC per-row visibility gate
      items.push({ key: a.key, label: a.label, run: () => a.run(row, ctx), danger: a.danger });
    } else if (typeof a === 'string' && onAction) {
      // Bare custom key (e.g. 'archive') — render only when the page supplies a handler.
      items.push({ key: a, label: titleCase(a), run: () => onAction(a, row) });
    }
  }

  useEffect(() => {
    if (!open) return;
    function onDown(e: PointerEvent) {
      const t = e.target as Node;
      if (!menuRef.current?.contains(t) && !triggerRef.current?.contains(t)) setOpen(false);
    }
    document.addEventListener('pointerdown', onDown);
    return () => document.removeEventListener('pointerdown', onDown);
  }, [open]);

  useEffect(() => {
    if (open) itemRefs.current[active]?.focus();
  }, [open, active]);

  if (items.length === 0) return null;

  function close(restore: boolean) {
    setOpen(false);
    if (restore) triggerRef.current?.focus();
  }

  function onMenuKey(e: KeyboardEvent<HTMLDivElement>) {
    const n = items.length;
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setActive((i) => (i + 1) % n);
        break;
      case 'ArrowUp':
        e.preventDefault();
        setActive((i) => (i - 1 + n) % n);
        break;
      case 'Home':
        e.preventDefault();
        setActive(0);
        break;
      case 'End':
        e.preventDefault();
        setActive(n - 1);
        break;
      case 'Escape':
        e.preventDefault();
        close(true);
        break;
      case 'Tab':
        setOpen(false);
        break;
      default:
        break;
    }
  }

  return (
    <div className="console-rowmenu">
      <button
        ref={triggerRef}
        type="button"
        className="console-rowmenu__trigger"
        aria-haspopup="true"
        aria-expanded={open}
        aria-label={`${label} actions`}
        onClick={() => (open ? close(false) : (setActive(0), setOpen(true)))}
        onKeyDown={(e) => {
          if (!open && (e.key === 'ArrowDown' || e.key === 'ArrowUp')) {
            e.preventDefault();
            setActive(0);
            setOpen(true);
          }
        }}
      >
        ⋯
      </button>
      <div
        ref={menuRef}
        className={`console-rowmenu__menu${open ? ' is-open' : ''}`}
        role="menu"
        aria-label={`${label} actions`}
        onKeyDown={onMenuKey}
      >
        {items.map((it, i) => (
          <button
            key={it.key}
            ref={(el) => {
              itemRefs.current[i] = el;
            }}
            type="button"
            role="menuitem"
            tabIndex={open && i === active ? 0 : -1}
            className={`console-rowmenu__item${it.danger ? ' console-rowmenu__item--danger' : ''}`}
            onClick={() => {
              void it.run();
              close(true);
            }}
          >
            {it.label}
          </button>
        ))}
      </div>
    </div>
  );
}

// Multi-select facet (ticket 3c2d6bbe): a keyboard-accessible checklist popover —
// pick several values, OR-within-facet, passed to api.list as an array. Same focus
// contract as the kebab (aria-haspopup/expanded, Esc-restores-focus, outside-click).
function FacetMultiSelect({
  label,
  options,
  selected,
  onChange,
}: {
  label: string;
  options: FacetOption[];
  selected: string[];
  onChange: (values: string[]) => void;
}) {
  const [open, setOpen] = useState(false);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    function onDown(e: PointerEvent) {
      const t = e.target as Node;
      if (!menuRef.current?.contains(t) && !triggerRef.current?.contains(t)) setOpen(false);
    }
    document.addEventListener('pointerdown', onDown);
    return () => document.removeEventListener('pointerdown', onDown);
  }, [open]);

  function toggle(value: string, checked: boolean) {
    onChange(checked ? [...selected, value] : selected.filter((v) => v !== value));
  }

  const summary = selected.length === 0 ? `${label}: all` : `${label}: ${selected.length}`;

  return (
    <div className="console-filters__facet console-multifacet">
      <button
        ref={triggerRef}
        type="button"
        className="console-multifacet__trigger"
        aria-haspopup="true"
        aria-expanded={open}
        onClick={() => setOpen((o) => !o)}
      >
        {summary}
        <span aria-hidden className="console-multifacet__caret">▾</span>
      </button>
      <div
        ref={menuRef}
        className={`console-multifacet__menu${open ? ' is-open' : ''}`}
        role="group"
        aria-label={label}
        onKeyDown={(e) => {
          if (e.key === 'Escape') {
            e.preventDefault();
            setOpen(false);
            triggerRef.current?.focus();
          }
        }}
      >
        {options.length === 0 ? (
          <p className="console-muted console-multifacet__empty">No options</p>
        ) : (
          options.map((o) => (
            <label key={o.value} className="console-multifacet__option">
              <input
                type="checkbox"
                checked={selected.includes(o.value)}
                onChange={(e) => toggle(o.value, e.target.checked)}
              />
              {o.label}
            </label>
          ))
        )}
        {selected.length > 0 && (
          <button type="button" className="console-multifacet__clear" onClick={() => onChange([])}>
            Clear
          </button>
        )}
      </div>
    </div>
  );
}
