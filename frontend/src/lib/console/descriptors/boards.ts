// Boards console descriptor (epic 8920d294). Folds d4a8fd52: a board's TYPE
// (methodology) and SCOPE (org vs project) are shown DISTINCTLY so a board is never
// mislabeled as a "project". yuki §6 (7e269bff). ava-frontend lane.
// REST gate: list/get/create/update/delete all exist -> fully wirable now.
import { api, type Board, type BoardInput, METHODOLOGIES } from '@/lib/api';
import type { ConsoleDescriptor } from '../types';

const titleCase = (s: string) => (s ? s.charAt(0).toUpperCase() + s.slice(1) : s);
// d4a8fd52 (b): methodology IS the board type — render as "<Methodology> board".
const boardType = (b: Board) => `${titleCase(String(b.methodology))} board`;
// scope shown distinctly from type.
const scopeLabel = (b: Board) => (b.scope === 'project' ? 'Project' : 'Org-level');

const METHODOLOGY_OPTIONS = METHODOLOGIES.map((m) => ({ value: m, label: titleCase(m) }));

export const boardsDescriptor: ConsoleDescriptor<Board, BoardInput> = {
  domain: 'boards',
  labels: { singular: 'Board', plural: 'Boards' },
  route: '/app/:org/boards',
  columns: [
    { key: 'name', label: 'Name', primary: true, sortable: true, width: '30%' },
    { key: 'methodology', label: 'Type', sortable: true, render: boardType },
    { key: 'scope', label: 'Scope', sortable: true, render: scopeLabel },
    { key: 'slug', label: 'Slug', render: 'slugChip' },
  ],
  filters: [
    { key: 'search', label: 'Search', type: 'search' },
    { key: 'methodology', label: 'Type', type: 'facet', options: METHODOLOGY_OPTIONS },
    {
      key: 'scope',
      label: 'Scope',
      type: 'facet',
      options: [
        { value: 'project', label: 'Project' },
        { value: 'org', label: 'Org-level' },
      ],
    },
  ],
  defaultSort: { key: 'name', dir: 'asc' },
  detail: {
    sections: [
      {
        title: 'Identity',
        fields: [
          { key: 'name', label: 'Name' },
          { key: 'slug', label: 'Slug' },
          { key: 'id', label: 'ID' },
        ],
      },
      {
        title: 'Type & scope',
        fields: [
          { key: 'methodology', label: 'Type', render: boardType },
          { key: 'scope', label: 'Scope', render: scopeLabel },
        ],
      },
      {
        title: 'About',
        fields: [{ key: 'description', label: 'Description', span: true, render: (b) => b.description ?? '—' }],
      },
    ],
    related: [
      { title: 'Stages', domain: 'board_stages', query: (b) => ({ boardId: b.id }) },
      // d4a8fd52 (c): the board surfaces its PROJECT's tickets as cards.
      { title: 'Tickets', domain: 'tickets', query: (b) => ({ projectId: b.project_id }) },
    ],
  },
  edit: {
    sections: [
      {
        title: 'Board',
        fields: [
          { key: 'name', label: 'Name', type: 'text', required: true },
          { key: 'slug', label: 'Slug', type: 'slug', derivesFrom: 'name', required: true },
          { key: 'methodology', label: 'Type', type: 'select', required: true, options: METHODOLOGY_OPTIONS },
          // d4a8fd52 (a): project defaults to the active project (primitive resolves the picker).
          {
            key: 'project_id',
            label: 'Project',
            type: 'reference',
            referenceDomain: 'projects',
            dynamic: true,
            hint: 'Defaults to the active project; the board shows that project’s tickets.',
          },
          { key: 'description', label: 'Description', type: 'textarea' },
        ],
      },
    ],
  },
  actions: { rowActions: ['view', 'edit', 'delete'] },
  api: {
    list: (orgId, opts) => api.listBoards(orgId, opts as Parameters<typeof api.listBoards>[1]).then((r) => r.boards),
    get: (orgId, id) => api.getBoard(orgId, id).then((r) => r.board),
    create: (orgId, input) => api.createBoard(orgId, input).then((r) => r.board),
    update: (orgId, id, input) => api.updateBoard(orgId, id, input).then((r) => r.board),
    remove: (orgId, id) => api.deleteBoard(orgId, id),
  },
};
