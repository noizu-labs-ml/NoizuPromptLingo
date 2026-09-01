// Projects console descriptor (epic 8920d294). yuki §6 (7e269bff). ava-frontend lane.
// REST gate: api.listProjects/getProject/createProject/updateProject/deleteProject
// all exist -> fully wirable now (no MCP-only gap). Status changes via the dedicated
// archive/unarchive endpoints (surfaced as row actions, not a free-text edit field).
import { createElement } from 'react';
import { api, type Project, type ProjectInput } from '@/lib/api';
import { StarToggle } from '@/components/star-toggle';
import type { ConsoleDescriptor } from '../types';

export const projectsDescriptor: ConsoleDescriptor<Project, ProjectInput> = {
  domain: 'projects',
  labels: { singular: 'Project', plural: 'Projects' },
  route: '/app/:org/projects',
  columns: [
    // Viewer-level star (localStorage preference); toggle cell reads the
    // StarredProjects context at render time, so the descriptor stays static.
    { key: 'starred', label: '★', width: '2.5rem', render: (p) => createElement(StarToggle, { projectId: p.id }) },
    { key: 'name', label: 'Name', primary: true, sortable: true, width: '30%' },
    { key: 'slug', label: 'Slug', render: 'slugChip' },
    { key: 'status', label: 'Status', sortable: true, render: (p) => p.status ?? 'active' },
    { key: 'description', label: 'Description', render: (p) => p.description ?? '—' },
    { key: 'updated_at', label: 'Updated', sortable: true, align: 'right', render: 'relativeDate' },
  ],
  filters: [
    { key: 'search', label: 'Search', type: 'search' },
    {
      key: 'status',
      label: 'Status',
      type: 'facet',
      options: [
        { value: 'active', label: 'Active' },
        { value: 'archived', label: 'Archived' },
      ],
    },
  ],
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
        title: 'Status',
        fields: [
          { key: 'status', label: 'Status', render: (p) => p.status ?? 'active' },
          { key: 'archived_at', label: 'Archived', render: (p) => p.archived_at ?? '—' },
        ],
      },
      {
        title: 'Meta',
        fields: [
          { key: 'created_at', label: 'Created', render: (p) => p.created_at ?? p.inserted_at ?? '—' },
          { key: 'updated_at', label: 'Updated', render: (p) => p.updated_at ?? '—' },
          { key: 'role_name', label: 'Your role', render: (p) => p.role_name ?? '—' },
        ],
      },
      {
        title: 'About',
        fields: [{ key: 'description', label: 'Description', span: true, render: (p) => p.description ?? '—' }],
      },
    ],
    related: [
      { title: 'Boards', domain: 'boards', query: (p) => ({ projectId: p.id }) },
      { title: 'Tickets', domain: 'tickets', query: (p) => ({ projectId: p.id }) },
    ],
  },
  edit: {
    sections: [
      {
        title: 'Project',
        fields: [
          { key: 'name', label: 'Name', type: 'text', required: true },
          { key: 'slug', label: 'Slug', type: 'slug', derivesFrom: 'name', required: true },
          { key: 'key_prefix', label: 'Ticket key prefix', type: 'text', hint: 'Uppercase letters/digits — used for ticket keys like ABC-001.' },
          { key: 'description', label: 'Description', type: 'textarea' },
        ],
      },
    ],
  },
  // EARNED (B) EXCEPTION (priya seq523): projects' primary-click stays select-active-
  // scope (the app's highest-frequency nav) — NOT detail. So the detail view is a
  // named row action ('details' -> DataTable onAction -> /projects/:id). 'edit' opens
  // the detail-edit route (EditForm). 'archive' is the soft-delete (no hard 'delete').
  // All 13 other domains use primary-click -> detail; projects is the one exception.
  actions: { rowActions: ['details', 'edit', 'archive'] },
  api: {
    list: (orgId) => api.listProjects(orgId).then((r) => r.projects),
    get: (orgId, id) => api.getProject(orgId, id).then((r) => r.project),
    create: (orgId, input) => api.createProject(orgId, input).then((r) => r.project),
    update: (orgId, id, input) => api.updateProject(orgId, id, input).then((r) => r.project),
    remove: (orgId, id) => api.deleteProject(orgId, id),
  },
};
