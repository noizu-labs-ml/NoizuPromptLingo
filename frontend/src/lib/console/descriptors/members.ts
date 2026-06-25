// Members console descriptor (epic 8920d294 / ticket 7bddfd70). The members/agents +
// roles table. yuki §6 (7e269bff). ava-frontend lane (TABLE/data-UI); the RBAC-gated
// role-management ROW ACTIONS (assign-role @ admin, remove @ lead) are diego's lane,
// wired on marcus's per-row effective_role echo (16dc3df2). The LIST RENDER below is
// independent of that echo (priya seq611), so the shell ships now.
//
// DATA NOTES (flagged for the gated-actions phase):
//  - api.listMembers returns ORG user-members only ({id,user_id,email,user_name,role,
//    joined_at}); there is no scope/project field, so the Scope column is constant
//    "Organization". A members/agents view WITH project scope + persona/agent
//    memberships needs an extended BE list (scoped_memberships) — BE follow-up.
//  - no getMember endpoint -> no generic detail route; api.get is a stub (unused).
//  - listMembers takes no filter opts -> role can't be a server facet; search only.
import { api } from '@/lib/api';
import type { ConsoleDescriptor } from '../types';
import { atLeast, outranks } from '../roles';

export interface OrgMember {
  id: string;
  user_id: string;
  email: string;
  user_name: string;
  role: string;
  joined_at: string;
}

export const membersDescriptor: ConsoleDescriptor<OrgMember, Partial<OrgMember>> = {
  domain: 'members',
  labels: { singular: 'Member', plural: 'Members' },
  route: '/app/:org/members',
  columns: [
    { key: 'user_name', label: 'Member', primary: true, sortable: true, render: (m) => m.user_name || m.email },
    { key: 'email', label: 'Email' },
    { key: 'role', label: 'Role', sortable: true, render: 'statusChip' },
    { key: 'scope', label: 'Scope', render: () => 'Organization' },
    { key: 'joined_at', label: 'Joined', sortable: true, align: 'right', render: 'relativeDate' },
  ],
  filters: [{ key: 'search', label: 'Search', type: 'search' }],
  detail: {
    sections: [
      {
        title: 'Member',
        fields: [
          { key: 'user_name', label: 'Name' },
          { key: 'email', label: 'Email' },
          { key: 'role', label: 'Role', render: 'statusChip' },
          { key: 'id', label: 'ID', render: 'idChip' },
        ],
      },
    ],
  },
  edit: { sections: [] }, // role-management is the gated row actions below, not a generic edit
  // RBAC-gated role-management row actions (diego, ticket 7bddfd70). The built-in
  // 'edit' = assign role (the page wires onEditRow -> a role picker); 'delete' = remove
  // member (page wires onDeleteRow -> confirm). The GATES use the caller's
  // ctx.effectiveRole (per-row echo, 16dc3df2) vs the target's row.role:
  //   - roles:assign @ admin  -> canEdit   (caller >= admin)
  //   - members:manage remove @ lead, can't remove an admin/lead (target-rank rule)
  //     -> canDelete (caller >= lead AND caller outranks the target member)
  // Until the echo populates ctx.effectiveRole, atLeast(undefined,...) is false, so the
  // actions stay HIDDEN (deny-closed advisory) — safe interim, no 403 buttons. Gating
  // is VISIBILITY only; the server guard is the sole deny-closed boundary.
  actions: {
    rowActions: ['edit', 'delete'],
    canEdit: (_m, ctx) => atLeast(ctx.effectiveRole, 'admin'),
    canDelete: (m, ctx) => atLeast(ctx.effectiveRole, 'lead') && outranks(ctx.effectiveRole, m.role),
  },
  api: {
    list: (orgId) => api.listMembers(orgId).then((r) => r.members),
    // No getMember endpoint; members has no generic detail route.
    get: () => Promise.reject(new Error('Member detail is not available')),
    // Present so the gated 'edit'/'delete' row actions render; the page drives the
    // actual role-picker / remove-confirm UI (ava's data-UI lane).
    update: (orgId, id, input) =>
      api
        .updateMemberRole(orgId, id, String((input as Partial<OrgMember>).role ?? ''))
        .then((r) => r.members.find((m) => m.id === id) ?? r.members[0]),
    remove: (orgId, id) => api.removeMember(orgId, id),
  },
};
