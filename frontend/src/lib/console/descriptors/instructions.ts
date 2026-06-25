// Instructions console descriptor (epic 8920d294). Flat (org-required, project-optional).
// yuki §6 (7e269bff). ava-frontend lane. REST: full CRUD present.
//
// NOTE (like personas/boards): an instruction's detail is a RICH bespoke surface —
// a VERSIONED body (edit-body = new active version), a PARAMETERS array, and a RENDER
// feature (fill params -> rendered prompt). The flat ConsoleDetailPage/EditForm can't
// model the versioned body (not on the entity row) + parameters + render, so the page
// keeps the existing InstructionModal (create/edit + version) and RenderModal (render)
// and opens them on row-open / the 'render' action. This descriptor drives the LIST
// (+ any future embedded mini-table); the detail/edit sections are for that case.
import { api, type Instruction, type InstructionInput } from '@/lib/api';
import type { ConsoleDescriptor } from '../types';

const tagsLabel = (i: Instruction) => (i.tags && i.tags.length ? i.tags.join(', ') : '—');
const versionLabel = (i: Instruction) => (i.active_version != null ? `v${i.active_version}` : '—');

export const instructionsDescriptor: ConsoleDescriptor<Instruction, InstructionInput> = {
  domain: 'instructions',
  labels: { singular: 'Instruction', plural: 'Instructions' },
  route: '/app/:org/instructions',
  columns: [
    { key: 'title', label: 'Title', primary: true, sortable: true },
    { key: 'slug', label: 'Slug', render: 'slugChip' },
    { key: 'status', label: 'Status', sortable: true, render: 'statusChip' },
    { key: 'active_version', label: 'Version', align: 'right', render: versionLabel },
    { key: 'tags', label: 'Tags', render: tagsLabel },
    { key: 'updated_at', label: 'Updated', sortable: true, align: 'right', render: 'relativeDate' },
  ],
  filters: [{ key: 'search', label: 'Search', type: 'search' }],
  detail: {
    sections: [
      {
        title: 'Identity',
        fields: [
          { key: 'title', label: 'Title' },
          { key: 'slug', label: 'Slug', render: 'slugChip' },
          { key: 'id', label: 'ID', render: 'idChip' },
        ],
      },
      {
        title: 'About',
        fields: [
          { key: 'status', label: 'Status', render: 'statusChip' },
          { key: 'active_version', label: 'Active version', render: versionLabel },
          { key: 'tags', label: 'Tags', render: tagsLabel },
        ],
      },
      { title: 'Description', fields: [{ key: 'description', label: 'Description', span: true, render: (i) => i.description ?? '—' }] },
    ],
  },
  edit: {
    sections: [
      {
        title: 'Instruction',
        fields: [
          { key: 'title', label: 'Title', type: 'text', required: true },
          { key: 'slug', label: 'Slug', type: 'slug', derivesFrom: 'title', required: true },
          { key: 'description', label: 'Description', type: 'textarea' },
        ],
      },
    ],
  },
  // Row-open opens the rich InstructionModal (edit + version); 'render' opens RenderModal.
  actions: { rowActions: ['render', 'delete'] },
  api: {
    list: (orgId, opts) => api.listInstructions(orgId, opts as Parameters<typeof api.listInstructions>[1]).then((r) => r.instructions),
    get: (orgId, id) => api.getInstruction(orgId, id).then((r) => r.instruction),
    create: (orgId, input) => api.createInstruction(orgId, input).then((r) => r.instruction),
    update: (orgId, id, input) => api.updateInstruction(orgId, id, input).then((r) => r.instruction),
    remove: (orgId, id) => api.deleteInstruction(orgId, id),
  },
};
