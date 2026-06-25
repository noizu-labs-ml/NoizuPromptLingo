// Organizations console descriptor (epic 8920d294). TOP-LEVEL domain — NOT org-scoped,
// so the api bindings ignore the orgId arg. yuki §6 (7e269bff). ava-frontend lane.
// REST gate: list/get/create/update/delete all exist -> fully wirable now.
import { api, type Organization } from '@/lib/api';
import type { ConsoleDescriptor } from '../types';
import { atLeast } from '../roles';

// The caller's effective role in each org (per-row, ticket 16dc3df2; = role today).
const orgRole = (o: Organization) => o.effective_role ?? o.role;

// createOrganization(slug, name) / updateOrganization(id, {name?, slug?}) — the
// editable surface is name + slug only.
interface OrganizationInput {
  name: string;
  slug: string;
}

export const organizationsDescriptor: ConsoleDescriptor<Organization, OrganizationInput> = {
  domain: 'organizations',
  labels: { singular: 'Organization', plural: 'Organizations' },
  route: '/app/organizations',
  columns: [
    { key: 'name', label: 'Name', primary: true, sortable: true },
    { key: 'slug', label: 'Slug', render: 'slugChip' },
    { key: 'role', label: 'Your role', sortable: true, render: (o) => o.role ?? '—' },
    { key: 'owner', label: 'Owner', render: (o) => o.owner ?? '—' },
  ],
  filters: [{ key: 'search', label: 'Search', type: 'search' }],
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
        title: 'Access',
        fields: [
          { key: 'role', label: 'Your role', render: (o) => o.role ?? '—' },
          { key: 'owner', label: 'Owner', render: (o) => o.owner ?? '—' },
        ],
      },
    ],
    related: [
      { title: 'Projects', domain: 'projects', query: (o) => ({ org: o.id }) },
      { title: 'Members', domain: 'members', query: (o) => ({ org: o.id }) },
    ],
  },
  edit: {
    sections: [
      {
        title: 'Organization',
        fields: [
          { key: 'name', label: 'Name', type: 'text', required: true },
          { key: 'slug', label: 'Slug', type: 'slug', derivesFrom: 'name', required: true },
        ],
      },
    ],
  },
  // Primary-click opens the org (page-wired: switchOrg + navigate). RBAC-gated kebab:
  // 'edit' @ admin+, 'delete' @ owner — advisory visibility off the per-row effective
  // role (16dc3df2); the server guard is the sole deny-closed boundary.
  actions: {
    rowActions: ['edit', 'delete'],
    canEdit: (o) => atLeast(orgRole(o), 'admin'),
    canDelete: (o) => atLeast(orgRole(o), 'owner'),
  },
  api: {
    // Top-level: orgId arg is ignored (organizations are not org-scoped).
    list: () => api.listOrganizations().then((r) => r.organizations),
    get: (_orgId, id) => api.getOrganization(id).then((r) => r.organization),
    create: (_orgId, input) => api.createOrganization(input.slug, input.name).then((r) => r.organization),
    update: (_orgId, id, input) => api.updateOrganization(id, input).then((r) => r.organization),
    remove: (_orgId, id) => api.deleteOrganization(id),
  },
};
