// Console descriptor contract — config-driven table / detail / edit (epic 8920d294).
//
// CANONICAL TYPE (ticket 0f8453f5, diego-frontend). This IS the primitive prop
// contract: DataTable / DetailView / EditForm are driven by a ConsoleDescriptor, and
// each domain supplies ONE descriptor (yuki-ux's P0 pattern §6, ticket 7e269bff). It
// is an additive SUPERSET of the earlier provisional spec, so the per-domain
// descriptors mei/ava authored keep compiling unchanged — they just import from here.
//
// Three things beyond the bare data spec:
//   - `render` on a column/detail-field may be a STRING HINT resolved by the
//     cell-renderer registry (see render-hints.tsx) OR a function (domain logic).
//   - custom actions carry an optional `visibleWhen(ctx)` gate (ADR-015 RBAC seam).
//   - ConsoleContext carries the org + the viewer's advisory effective role.
import type { ReactNode } from 'react';

export type ColumnAlign = 'left' | 'right' | 'center';

/**
 * Reusable, value-based cell renderers resolved by the primitive from a string —
 * `render: 'slugChip'` "just works". Operate on the cell value (row[key]) + row.
 * Domain-specific presentation (e.g. boards' "<Methodology> board") stays a function
 * renderer in the descriptor; only genuinely cross-domain value renderers are hints.
 */
export type CellRenderHint = 'slugChip' | 'idChip' | 'statusChip' | 'relativeDate' | 'identityChip';

/** A cell renderer: a registry hint, or a function for domain-specific presentation. */
export type CellRenderer<T> = CellRenderHint | ((row: T) => ReactNode);

/** Advisory context handed to the primitives + action gates. */
export interface ConsoleContext {
  /** Identifier the `api.*` methods expect (the org UUID — api is UUID-keyed). */
  orgId: string;
  /**
   * Canonical org SLUG for building app routes (/app/<slug>/…). Distinct from
   * orgId (mei seq493): api calls use orgId, route/link building uses orgSlug.
   * Falls back to orgId when absent.
   */
  orgSlug?: string;
  /**
   * The viewer's effective role for the current resource (advisory only, per
   * ADR-015 — role is per-resource, NOT a JWT claim). Used to gate affordance
   * VISIBILITY only; the server guard remains the sole deny-closed boundary.
   */
  effectiveRole?: string;
}

export interface ColumnDef<T> {
  key: string;
  label: string;
  sortable?: boolean;
  align?: ColumnAlign;
  /** The clickable identity column (name/title) that owns the row→detail affordance. */
  primary?: boolean;
  /** CSS width or grow hint, e.g. '32%' / '8rem'. */
  width?: string;
  /** Cell render: a registry hint string or a function. Omit for raw `row[key]`. */
  render?: CellRenderer<T>;
}

export interface FacetOption {
  value: string;
  label: string;
}

export interface FilterDef {
  key: string;
  label: string;
  type: 'search' | 'facet';
  /** Static facet options. Omit when the options are resolved dynamically (see `dynamic`). */
  options?: FacetOption[];
  /** Marks a facet whose options the primitive must resolve at runtime (e.g. projects). */
  dynamic?: boolean;
  /**
   * Multi-select facet: the user picks several values (OR-within-facet); the selected
   * values pass to api.list as an ARRAY under `key`. Default false (single <select>).
   * BE must accept the array param for the key.
   */
  multi?: boolean;
}

export type FieldType =
  | 'text'
  | 'textarea'
  | 'slug'
  | 'select'
  | 'multiselect'
  | 'toggle'
  | 'date'
  | 'number'
  | 'reference';

export interface DetailFieldDef<T> {
  key: string;
  label: string;
  /** Full-width (long/rich fields: description, body). */
  span?: boolean;
  /** Cell render: a registry hint string or a function. */
  render?: CellRenderer<T>;
}

export interface DetailSection<T> {
  title: string;
  fields: DetailFieldDef<T>[];
}

export interface RelatedCollection {
  title: string;
  /** Domain key of the embedded read-only mini-DataTable. */
  domain: string;
  /**
   * Build the scope/query for the related list from the parent row. CONTRACT: every
   * key returned here MUST be an opt the TARGET descriptor's `api.list` actually
   * consumes — api.list ignores unknown keys silently, so a wrong key (e.g.
   * `{parentId}` when api.list only reads `parent_id`) yields ALL rows, not the
   * scoped subset. Map the key to a real api.list filter before relying on it.
   */
  query: (row: Record<string, unknown>) => Record<string, unknown>;
}

export interface EditFieldDef {
  key: string;
  label: string;
  type: FieldType;
  required?: boolean;
  hint?: string;
  options?: FacetOption[];
  /** Resolve `options` at runtime (e.g. a project reference picker). */
  dynamic?: boolean;
  /** slug fields: the name field the slug auto-derives from. */
  derivesFrom?: string;
  /** reference fields: the target domain key. */
  referenceDomain?: string;
  /** Render disabled in edit (e.g. immutable slug post-create). */
  readOnly?: boolean;
}

export interface EditSection {
  title: string;
  fields: EditFieldDef[];
}

/** Built-in row actions the primitive wires from the descriptor's api methods. */
export type BuiltinRowAction = 'view' | 'edit' | 'delete';

/**
 * A custom action (row kebab item or detail/edit button). `visibleWhen` is the
 * ADR-015 RBAC seam: when present, the action renders + is keyboard-reachable only
 * if it returns true. This gates VISIBILITY ONLY — never enforcement. A forged
 * client just shows a control the server rejects (the server guard is deny-closed).
 */
export interface ActionDef<T> {
  key: string;
  label: string;
  run: (row: T, ctx: ConsoleContext) => void | Promise<void>;
  /**
   * Advisory PER-ROW visibility gate (RBAC). Omit = always visible. Receives the
   * ROW because in a list each row is a distinct resource with its own effective
   * role (an org-list = N orgs, N roles) — gate on `row`, not just `ctx`. Per-row
   * role data comes from the list serializer echoing effective_role per row.
   */
  visibleWhen?: (row: T, ctx: ConsoleContext) => boolean;
  /** Destructive styling + confirm (e.g. delete/moderate). */
  danger?: boolean;
}

export interface DescriptorActions<T> {
  /**
   * Row kebab actions, in order. Three forms:
   *   - built-in ('view'|'edit'|'delete') — wired by the primitive from the api methods.
   *   - a bare custom key (e.g. 'archive') — dispatched via DataTable's `onAction(key,row)`;
   *     rendered only when a handler is supplied. Label is the title-cased key.
   *   - an ActionDef — custom + gate-able via `visibleWhen` (the RBAC seam).
   * (`string & {}` keeps the built-in literals suggested while allowing any key.)
   */
  rowActions?: (BuiltinRowAction | (string & {}) | ActionDef<T>)[];
  /** Bulk-select actions; omit/empty to disable bulk select (default off). */
  bulkActions?: (string | ActionDef<T>)[];
  /**
   * PER-ROW gates for the BUILT-IN edit/delete actions (orgs etc., where the viewer's
   * role varies per row). Omit = visible. INVARIANT: gate affordance VISIBILITY /
   * keyboard-reachability ONLY — never enforcement. The server guard stays the sole
   * deny-closed boundary; a forged client that un-hides edit still 403s.
   */
  canEdit?: (row: T, ctx: ConsoleContext) => boolean;
  canDelete?: (row: T, ctx: ConsoleContext) => boolean;
}

/**
 * Uniform data contract the primitives call. Each wraps the domain's `api.*`
 * method and UNWRAPS to the bare entity/array so the table/detail/edit don't
 * need to know each domain's envelope key ({tickets}/{rooms}/{sessions}).
 * `create`/`update`/`remove` are optional so a domain can be read-only or
 * (e.g. chatrooms until its PUT lands) lack an update endpoint.
 */
export interface DescriptorApi<T, TInput> {
  list: (orgId: string, opts?: Record<string, unknown>) => Promise<T[]>;
  get: (orgId: string, id: string) => Promise<T>;
  create?: (orgId: string, input: TInput) => Promise<T>;
  update?: (orgId: string, id: string, input: Partial<TInput>) => Promise<T>;
  remove?: (orgId: string, id: string) => Promise<unknown>;
}

export interface ConsoleDescriptor<T = Record<string, unknown>, TInput = Partial<T>> {
  /** Stable domain key (also used to resolve related embedded tables). */
  domain: string;
  /** Singular/plural human labels for headings + empty states. */
  labels: { singular: string; plural: string };
  /** List route, `:org` substituted by the primitive (canonical org SLUG). */
  route: string;
  /** Field that identifies a row for detail/edit routing + keys. Defaults to 'id'. */
  idKey?: string;
  columns: ColumnDef<T>[];
  filters?: FilterDef[];
  detail: { sections: DetailSection<T>[]; related?: RelatedCollection[] };
  edit: { sections: EditSection[] };
  actions?: DescriptorActions<T>;
  api: DescriptorApi<T, TInput>;
  /** Default list render; 'cards' keeps the legacy grid for visual-heavy domains. */
  display?: 'table' | 'cards';
}
