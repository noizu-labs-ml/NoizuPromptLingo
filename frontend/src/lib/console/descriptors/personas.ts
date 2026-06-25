// Personas console descriptor (epic 8920d294). Flat (org-required, project-optional).
// yuki §6 (7e269bff). ava-frontend lane. REST: list/get/create/update/delete all present.
//
// NOTE: a persona's DETAIL is its rich bio + JOURNAL + KNOWLEDGE-BASE surface (the
// "authored identity" view) — kept as the existing DetailsModal, like boards' kanban
// detail, NOT a generic DetailView. So the personas page opens that modal on row-open
// rather than routing to a ConsoleDetailPage. This descriptor drives the LIST (and, if
// ever embedded as a related collection, the read-only mini-table); the detail/edit
// sections below are for that embedded/generic case + completeness.
import { api, type Persona, type PersonaInput } from '@/lib/api';
import type { ConsoleDescriptor } from '../types';

const tagsLabel = (p: Persona) => (p.tags && p.tags.length ? p.tags.join(', ') : '—');

export const personasDescriptor: ConsoleDescriptor<Persona, PersonaInput> = {
  domain: 'personas',
  labels: { singular: 'Persona', plural: 'Personas' },
  route: '/app/:org/personas',
  columns: [
    { key: 'name', label: 'Name', primary: true, sortable: true },
    { key: 'slug', label: 'Slug', render: 'slugChip' },
    { key: 'role', label: 'Role', render: (p) => p.role ?? '—' },
    { key: 'status', label: 'Status', sortable: true, render: 'statusChip' },
    { key: 'tags', label: 'Tags', render: tagsLabel },
    { key: 'updated_at', label: 'Updated', sortable: true, align: 'right', render: 'relativeDate' },
  ],
  filters: [{ key: 'search', label: 'Search', type: 'search' }],
  detail: {
    sections: [
      {
        title: 'Identity',
        fields: [
          { key: 'name', label: 'Name' },
          { key: 'slug', label: 'Slug', render: 'slugChip' },
          { key: 'id', label: 'ID', render: 'idChip' },
        ],
      },
      {
        title: 'Profile',
        fields: [
          { key: 'role', label: 'Role', render: (p) => p.role ?? '—' },
          { key: 'status', label: 'Status', render: 'statusChip' },
          { key: 'tags', label: 'Tags', render: tagsLabel },
        ],
      },
      { title: 'Bio', fields: [{ key: 'bio', label: 'Bio', span: true, render: (p) => p.bio ?? '—' }] },
    ],
  },
  edit: {
    sections: [
      {
        title: 'Persona',
        fields: [
          { key: 'name', label: 'Name', type: 'text', required: true },
          { key: 'slug', label: 'Slug', type: 'slug', derivesFrom: 'name', required: true },
          { key: 'role', label: 'Role', type: 'text' },
          { key: 'bio', label: 'Bio', type: 'textarea' },
          { key: 'avatar', label: 'Avatar URL', type: 'text' },
          { key: 'status', label: 'Status', type: 'text' },
        ],
      },
    ],
  },
  actions: { rowActions: ['view', 'edit', 'delete'] },
  api: {
    list: (orgId, opts) => api.listPersonas(orgId, opts as Parameters<typeof api.listPersonas>[1]).then((r) => r.personas),
    get: (orgId, id) => api.getPersona(orgId, id).then((r) => r.persona),
    create: (orgId, input) => api.createPersona(orgId, input).then((r) => r.persona),
    update: (orgId, id, input) => api.updatePersona(orgId, id, input).then((r) => r.persona),
    remove: (orgId, id) => api.deletePersona(orgId, id),
  },
};
