// Sessions console descriptor (epic 8920d294). Built to yuki §6 (7e269bff).
// REST gate: listSessions/getSession/createSession/updateSession all exist -> fully wirable.
import { api, type Session, type SessionInput } from '@/lib/api';
import type { ConsoleDescriptor } from '../types';

// Session status set is small + app-defined; not a tri-scoped definition, so static here.
// 'inactive' is set by the backend inactivity sweep (no events for NPL_SESSION_INACTIVITY_HOURS).
const STATUSES = [
  { value: 'active', label: 'Active' },
  { value: 'archived', label: 'Archived' },
  { value: 'completed', label: 'Completed' },
  { value: 'inactive', label: 'Inactive' },
];

export const sessionsDescriptor: ConsoleDescriptor<Session, SessionInput> = {
  domain: 'sessions',
  labels: { singular: 'Session', plural: 'Sessions' },
  route: '/app/:org/sessions',
  columns: [
    { key: 'title', label: 'Title', primary: true, sortable: true, width: '40%' },
    { key: 'status', label: 'Status', sortable: true, render: (s) => s.status ?? '—' },
    { key: 'project_id', label: 'Project', sortable: true, render: (s) => s.project_id ?? 'Org-level' },
    { key: 'updated_at', label: 'Updated', sortable: true, align: 'right' },
  ],
  filters: [
    { key: 'search', label: 'Search', type: 'search' },
    { key: 'status', label: 'Status', type: 'facet', options: STATUSES },
    { key: 'projectId', label: 'Project', type: 'facet', dynamic: true },
  ],
  detail: {
    sections: [
      {
        title: 'Overview',
        fields: [
          { key: 'title', label: 'Title' },
          { key: 'status', label: 'Status', render: (s) => s.status ?? '—' },
          { key: 'description', label: 'Description', span: true, render: (s) => s.description ?? '—' },
          { key: 'project_id', label: 'Project', render: (s) => s.project_id ?? 'Org-level' },
        ],
      },
      {
        title: 'Meta',
        fields: [
          { key: 'id', label: 'ID' },
          { key: 'archived_at', label: 'Archived', render: (s) => s.archived_at ?? '—' },
          { key: 'inserted_at', label: 'Created' },
          { key: 'updated_at', label: 'Updated' },
        ],
      },
    ],
    // A session groups rooms/artifacts/tickets — surface its rooms as an embedded mini-table.
    related: [{ title: 'Rooms', domain: 'chatrooms', query: (s) => ({ sessionId: s.id }) }],
  },
  edit: {
    sections: [
      {
        title: 'Session',
        fields: [
          { key: 'title', label: 'Title', type: 'text', required: true },
          { key: 'description', label: 'Description', type: 'textarea' },
          { key: 'status', label: 'Status', type: 'select', options: STATUSES },
          { key: 'project_id', label: 'Project', type: 'reference', referenceDomain: 'projects', dynamic: true, hint: 'Optional — leave unset for an org-level session.' },
        ],
      },
    ],
  },
  // 'archive' is a bare custom key dispatched via the page's onAction (soft-delete);
  // view/edit are builtins wired from onOpenRow/onEditRow.
  actions: { rowActions: ['view', 'edit', 'archive'] },
  api: {
    list: (orgId, opts) => api.listSessions(orgId, opts as Parameters<typeof api.listSessions>[1]).then((r) => r.sessions),
    get: (orgId, id) => api.getSession(orgId, id).then((r) => r.session),
    create: (orgId, input) => api.createSession(orgId, input).then((r) => r.session),
    update: (orgId, id, input) => api.updateSession(orgId, id, input).then((r) => r.session),
  },
};
