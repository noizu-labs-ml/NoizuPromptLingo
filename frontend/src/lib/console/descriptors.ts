/**
 * Console domain descriptors — epic 8920d294 (one table / detail / edit pattern).
 *
 * Implements yuki's §6 per-domain CONFIG contract (ticket 7e269bff) for the
 * three domains in ava-frontend's lane: projects, organizations, boards.
 *
 * Self-contained on purpose: the `ConsoleDescriptor` type below mirrors yuki §6
 * 1:1 so this file compiles + is reviewable NOW, in parallel with diego's
 * DataTable/DetailView/EditForm primitives (0f8453f5). When those land, reconcile
 * this type to the primitives' actual prop types (one rename pass) and the
 * descriptors wire unchanged. `api` holds the lib/api.ts METHOD NAMES (declarative),
 * not live refs, so the descriptor stays pure data and the primitive binds them.
 *
 * REST coverage (045a1dd0 gate): all three domains have full list/get/create/
 * update/delete on `api` (lib/api.ts) — NO MCP-only gaps in this lane.
 */

// ── §6 descriptor contract (reconcile to 0f8453f5 primitive types on landing) ──

export type ColumnAlign = 'left' | 'right' | 'center';

/** A named render hint the primitive maps to a cell renderer. */
export type RenderHint =
  | 'text'
  | 'truncate'
  | 'slugChip'       // copyable mono chip (chat slug treatment)
  | 'idChip'         // copyable mono uuid chip, truncated
  | 'date'
  | 'relativeDate'
  | 'statusChip'     // colored status pill from the reserved channel
  | 'boardType'      // methodology -> "<Methodology> board" (d4a8fd52 relabel)
  | 'scopeLabel';    // scope -> "Project · <name>" | "Org-level" (d4a8fd52 relabel)

export interface ColumnDef {
  key: string;
  label: string;
  sortable?: boolean;
  align?: ColumnAlign;
  /** The clickable identity column (name/title); owns the row→detail affordance. */
  primary?: boolean;
  width?: string;
  render?: RenderHint;
}

export interface FilterDef {
  key: string;
  label: string;
  type: 'search' | 'facet';
  options?: { label: string; value: string }[];
}

export interface DetailField {
  key: string;
  label: string;
  render?: RenderHint;
  /** Full-width (description/body) vs the definition-list grid. */
  span?: boolean;
}

export interface DetailSection {
  title: string;
  fields: DetailField[];
}

/** A related collection rendered as an embedded read-only mini-DataTable. */
export interface RelatedDef {
  title: string;
  domain: string;
  /** How the embedded table is scoped from the parent record, e.g. 'projectId=:id'. */
  query: string;
}

export type EditFieldType =
  | 'text'
  | 'textarea'
  | 'slug'
  | 'select'
  | 'multiselect'
  | 'toggle'
  | 'date'
  | 'number'
  | 'reference';

export interface EditField {
  key: string;
  label: string;
  type: EditFieldType;
  hint?: string;
  required?: boolean;
  /** select / multiselect options. */
  options?: { label: string; value: string }[];
  /** slug auto-derives from this field's value (editable after). */
  slugFrom?: string;
  /** reference-picker (FK to another domain). */
  reference?: { domain: string; defaultActive?: boolean; allowNone?: boolean };
}

export interface EditSection {
  title: string;
  fields: EditField[];
}

export interface ApiBinding {
  /** 'global' = top-level (organizations); 'org' = org-scoped first arg. */
  scope: 'global' | 'org';
  list: string;
  get: string;
  create: string;
  update: string;
  delete: string;
}

export interface ConsoleDescriptor {
  domain: string;
  route: string;
  /** 'table' (default) or 'cards' for visual-heavy domains (yuki §7). */
  display?: 'table' | 'cards';
  columns: ColumnDef[];
  filters?: FilterDef[];
  detail: { sections: DetailSection[]; related?: RelatedDef[] };
  edit: { sections: EditSection[] };
  actions?: { rowActions?: string[]; bulkActions?: string[] };
  api: ApiBinding;
}

// ── PROJECTS (start here — simplest, yuki's reference convert §7) ──
// Shape: {id, organization_id, name, slug, description, status('active'|'archived'),
//         settings, archived_at, inserted_at/updated_at, created_at, role_name}.

export const projectsDescriptor: ConsoleDescriptor = {
  domain: 'projects',
  route: '/app/:org/projects',
  columns: [
    { key: 'name', label: 'Name', primary: true, sortable: true },
    { key: 'slug', label: 'Slug', render: 'slugChip' },
    { key: 'status', label: 'Status', render: 'statusChip', sortable: true },
    { key: 'description', label: 'Description', render: 'truncate' },
    { key: 'updated_at', label: 'Updated', render: 'relativeDate', sortable: true, align: 'right' },
  ],
  filters: [
    { key: 'q', label: 'Search projects', type: 'search' },
    {
      key: 'status',
      label: 'Status',
      type: 'facet',
      options: [
        { label: 'Active', value: 'active' },
        { label: 'Archived', value: 'archived' },
      ],
    },
  ],
  detail: {
    sections: [
      { title: 'Identity', fields: [
        { key: 'name', label: 'Name' },
        { key: 'slug', label: 'Slug', render: 'slugChip' },
        { key: 'id', label: 'ID', render: 'idChip' },
      ] },
      { title: 'Status', fields: [
        { key: 'status', label: 'Status', render: 'statusChip' },
        { key: 'archived_at', label: 'Archived', render: 'date' },
      ] },
      { title: 'Meta', fields: [
        { key: 'created_at', label: 'Created', render: 'date' },
        { key: 'updated_at', label: 'Updated', render: 'date' },
        { key: 'role_name', label: 'Your role' },
      ] },
      { title: 'About', fields: [ { key: 'description', label: 'Description', span: true } ] },
    ],
    related: [
      { title: 'Boards', domain: 'boards', query: 'projectId=:id' },
      { title: 'Tickets', domain: 'tickets', query: 'projectId=:id' },
    ],
  },
  edit: {
    sections: [
      { title: 'Project', fields: [
        { key: 'name', label: 'Name', type: 'text', required: true },
        { key: 'slug', label: 'Slug', type: 'slug', slugFrom: 'name', required: true },
        { key: 'description', label: 'Description', type: 'textarea' },
      ] },
    ],
  },
  // status (archive/unarchive) is an explicit row action, not a free-text edit field.
  actions: { rowActions: ['view', 'edit', 'archive', 'delete'] },
  api: {
    scope: 'org',
    list: 'listProjects',
    get: 'getProject',
    create: 'createProject',
    update: 'updateProject',
    delete: 'deleteProject',
  },
};

// ── ORGANIZATIONS (top-level, NOT org-scoped) ──
// Shape: {id, slug, name, role?, owner?}.

export const organizationsDescriptor: ConsoleDescriptor = {
  domain: 'organizations',
  route: '/app/organizations',
  columns: [
    { key: 'name', label: 'Name', primary: true, sortable: true },
    { key: 'slug', label: 'Slug', render: 'slugChip' },
    { key: 'role', label: 'Your role', sortable: true },
    { key: 'owner', label: 'Owner' },
  ],
  filters: [{ key: 'q', label: 'Search organizations', type: 'search' }],
  detail: {
    sections: [
      { title: 'Identity', fields: [
        { key: 'name', label: 'Name' },
        { key: 'slug', label: 'Slug', render: 'slugChip' },
        { key: 'id', label: 'ID', render: 'idChip' },
      ] },
      { title: 'Access', fields: [
        { key: 'role', label: 'Your role' },
        { key: 'owner', label: 'Owner' },
      ] },
    ],
    related: [
      { title: 'Projects', domain: 'projects', query: 'org=:id' },
      { title: 'Members', domain: 'members', query: 'org=:id' },
    ],
  },
  edit: {
    sections: [
      { title: 'Organization', fields: [
        { key: 'name', label: 'Name', type: 'text', required: true },
        { key: 'slug', label: 'Slug', type: 'slug', slugFrom: 'name', required: true },
      ] },
    ],
  },
  actions: { rowActions: ['view', 'edit', 'delete'] },
  api: {
    scope: 'global',
    list: 'listOrganizations',
    get: 'getOrganization',
    create: 'createOrganization',
    update: 'updateOrganization',
    delete: 'deleteOrganization',
  },
};

// ── BOARDS (folds with d4a8fd52: TYPE vs SCOPE shown distinctly) ──
// Shape: {id, scope('org'|'project'), organization_id, project_id, name, slug,
//         methodology(kanban/scrum/waterfall/spiral), description, config,
//         stages?, iterations?}.

export const boardsDescriptor: ConsoleDescriptor = {
  domain: 'boards',
  route: '/app/:org/boards',
  columns: [
    { key: 'name', label: 'Name', primary: true, sortable: true },
    // d4a8fd52 (b): methodology IS the board type ("Kanban board") — never the bare word.
    { key: 'methodology', label: 'Type', render: 'boardType', sortable: true },
    // scope shown distinctly from type: "Project · <name>" | "Org-level".
    { key: 'scope', label: 'Scope', render: 'scopeLabel', sortable: true },
    { key: 'slug', label: 'Slug', render: 'slugChip' },
  ],
  filters: [
    { key: 'q', label: 'Search boards', type: 'search' },
    {
      key: 'methodology',
      label: 'Type',
      type: 'facet',
      options: [
        { label: 'Kanban', value: 'kanban' },
        { label: 'Scrum', value: 'scrum' },
        { label: 'Waterfall', value: 'waterfall' },
        { label: 'Spiral', value: 'spiral' },
      ],
    },
    {
      key: 'scope',
      label: 'Scope',
      type: 'facet',
      options: [
        { label: 'Project', value: 'project' },
        { label: 'Org-level', value: 'org' },
      ],
    },
  ],
  detail: {
    sections: [
      { title: 'Identity', fields: [
        { key: 'name', label: 'Name' },
        { key: 'slug', label: 'Slug', render: 'slugChip' },
        { key: 'id', label: 'ID', render: 'idChip' },
      ] },
      { title: 'Type & scope', fields: [
        { key: 'methodology', label: 'Type', render: 'boardType' },
        { key: 'scope', label: 'Scope', render: 'scopeLabel' },
      ] },
      { title: 'About', fields: [ { key: 'description', label: 'Description', span: true } ] },
    ],
    related: [
      { title: 'Stages', domain: 'board_stages', query: 'boardId=:id' },
      // d4a8fd52 (c): the board surfaces its PROJECT's tickets as cards.
      { title: 'Tickets', domain: 'tickets', query: 'projectId=:project_id' },
    ],
  },
  edit: {
    sections: [
      { title: 'Board', fields: [
        { key: 'name', label: 'Name', type: 'text', required: true },
        { key: 'slug', label: 'Slug', type: 'slug', slugFrom: 'name', required: true },
        {
          key: 'methodology',
          label: 'Type',
          type: 'select',
          required: true,
          options: [
            { label: 'Kanban', value: 'kanban' },
            { label: 'Scrum', value: 'scrum' },
            { label: 'Waterfall', value: 'waterfall' },
            { label: 'Spiral', value: 'spiral' },
          ],
        },
        // d4a8fd52 (a): project defaults to the active project; '' = org-level.
        { key: 'project_id', label: 'Project', type: 'reference', reference: { domain: 'projects', defaultActive: true, allowNone: true } },
        { key: 'description', label: 'Description', type: 'textarea' },
      ] },
    ],
  },
  actions: { rowActions: ['view', 'edit', 'delete'] },
  api: {
    scope: 'org',
    list: 'listBoards',
    get: 'getBoard',
    create: 'createBoard',
    update: 'updateBoard',
    delete: 'deleteBoard',
  },
};

export const consoleDescriptors: Record<string, ConsoleDescriptor> = {
  projects: projectsDescriptor,
  organizations: organizationsDescriptor,
  boards: boardsDescriptor,
};
