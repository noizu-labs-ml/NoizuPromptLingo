// Members console descriptor (epic 8920d294 / ticket 7bddfd70). The members/agents +
// roles table, now on aniket's PBAC members list (4a9aa9d9): each row carries
// member_type, the target's canonical role, scope (resource_type/id), and the caller's
// effective_role (16dc3df2) for the per-row RBAC gates. member_type-agnostic — persona/
// agent rows appear automatically when ccaf5684 lands (zero FE change).
//
// RBAC-gated role-management row actions (diego): edit = assign role, delete = remove.
import { api, type OrgMember } from '@/lib/api';
import type { ConsoleDescriptor } from '../types';
import { atLeast, outranks } from '../roles';

export type { OrgMember };

const scopeLabel = (m: OrgMember) => (m.resource_type === 'project' ? 'Project' : 'Organization');

const ROLE_OPTIONS = [
  { value: 'owner', label: 'Owner' },
  { value: 'admin', label: 'Admin' },
  { value: 'lead', label: 'Lead' },
  { value: 'member', label: 'Member' },
  { value: 'viewer', label: 'Viewer' },
];

export const membersDescriptor: ConsoleDescriptor<OrgMember, Partial<OrgMember>> = {
  domain: 'members',
  labels: { singular: 'Member', plural: 'Members' },
  route: '/app/:org/members',
  columns: [
    { key: 'user_name', label: 'Member', primary: true, sortable: true, render: (m) => m.user_name || m.email },
    { key: 'email', label: 'Email' },
    { key: 'role', label: 'Role', sortable: true, render: 'statusChip' },
    { key: 'scope', label: 'Scope', render: scopeLabel },
    { key: 'joined_at', label: 'Joined', sortable: true, align: 'right', render: 'relativeDate' },
  ],
  filters: [
    { key: 'search', label: 'Search', type: 'search' },
    // Multi-select -> ?role[]=admin&role[]=lead (ANY, OR-within) via diego's FacetMultiSelect + buildQuery.
    { key: 'role', label: 'Role', type: 'facet', multi: true, options: ROLE_OPTIONS },
  ],
  detail: {
    sections: [
      {
        title: 'Member',
        fields: [
          { key: 'user_name', label: 'Name', render: (m) => m.user_name || m.email },
          { key: 'email', label: 'Email' },
          { key: 'member_type', label: 'Type' },
          { key: 'role', label: 'Role', render: 'statusChip' },
          { key: 'id', label: 'ID', render: 'idChip' },
        ],
      },
      {
        title: 'Membership',
        fields: [
          { key: 'scope', label: 'Scope', render: scopeLabel },
          { key: 'joined_at', label: 'Joined', render: 'relativeDate' },
          { key: 'expires_at', label: 'Expires', render: (m) => m.expires_at ?? '—' },
        ],
      },
    ],
  },
  // The only editable field is the role (assign-role). Drives the detail route's edit
  // (EditForm -> api.update = updateMemberRole); the list also offers a quick role picker.
  edit: { sections: [{ title: 'Role', fields: [{ key: 'role', label: 'Role', type: 'select', options: ROLE_OPTIONS }] }] },
  // Gate on the CALLER's per-row effective_role (16dc3df2, live) vs the target's role.
  // VISIBILITY only — the server guard is the sole deny-closed boundary; a forged client
  // that un-hides an action still 403s.
  actions: {
    rowActions: ['edit', 'delete'],
    builtinLabels: { edit: 'Assign role', delete: 'Remove' },
    canEdit: (m) => atLeast(m.effective_role, 'admin'),
    canDelete: (m) => atLeast(m.effective_role, 'lead') && outranks(m.effective_role, m.role),
  },
  api: {
    list: (orgId, opts) => api.listMembers(orgId, opts as Parameters<typeof api.listMembers>[1]).then((r) => r.members),
    get: (orgId, id) => api.getMember(orgId, id).then((r) => r.member),
    update: (orgId, id, input) =>
      api
        .updateMemberRole(orgId, id, String((input as Partial<OrgMember>).role ?? ''))
        .then((r) => r.members.find((m) => m.id === id) ?? r.members[0]),
    remove: (orgId, id) => api.removeMember(orgId, id),
  },
};
