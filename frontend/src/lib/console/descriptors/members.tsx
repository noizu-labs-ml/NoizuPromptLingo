// Members console descriptor (epic 8920d294 / ticket 7bddfd70). The members/agents +
// roles table, now on aniket's PBAC members list (4a9aa9d9): each row carries
// member_type, the target's canonical role, scope (resource_type/id), and the caller's
// effective_role (16dc3df2) for the per-row RBAC gates.
//
// PERSONA-AS-MEMBER polish (priya seq741, ccaf5684 / ADR-017): the list is member_type-
// agnostic, so persona/agent rows appear with zero structural change. This descriptor
// adds the DISPLAY polish aniket's unified shape (seq740) enables:
//   - PRIMARY cell renders display_name (the unified name) — persona rows have nil
//     user_id/email, so the old user_name||email would blank on agent rows.
//   - member_type=='persona' rows get an "Agent" badge to distinguish them from users.
//   - avatar (persona avatar; nil for users -> deterministic identity dot fallback).
//   - persona_slug shows as a slug chip on agent rows. (A true deep-LINK to the persona
//     view is deferred: personas have no standalone route yet — they open in a modal on
//     the personas list — and the primary cell is wrapped in a <button>, which can't
//     legally nest an anchor. Wire the link when a persona route lands.)
//
// This is a .tsx descriptor (not .ts) because the identity cell is domain-specific
// presentation — a function renderer with JSX — per the render-hints division of labor
// (cross-domain value renderers are string hints; domain presentation stays a function).
import { api, type OrgMember } from '@/lib/api';
import type { ConsoleDescriptor } from '../types';
import { atLeast, outranks } from '../roles';
import { hueFor } from '../render-hints';

export type { OrgMember };

const scopeLabel = (m: OrgMember) => (m.resource_type === 'project' ? 'Project' : 'Organization');

// Unified display name across user + persona rows (aniket seq740). Falls back through the
// user fields, then the persona slug, so the primary cell never blanks on either row type.
const memberName = (m: OrgMember): string =>
  m.display_name || m.user_name || m.email || m.persona_slug || '—';

// Identity cell: avatar (or deterministic dot) + name, plus an Agent badge + slug chip on
// persona rows. All children are non-interactive spans — the cell is wrapped in DataTable's
// row-open <button>, so no nested anchors/buttons here.
function MemberIdentity(m: OrgMember) {
  const isPersona = m.member_type === 'persona';
  const name = memberName(m);
  return (
    <span className="console-identity">
      {m.avatar ? (
        // eslint-disable-next-line @next/next/no-img-element -- avatar URL is arbitrary/remote
        <img className="console-identity__avatar" src={m.avatar} alt="" aria-hidden />
      ) : (
        <span
          className="console-identity__dot"
          aria-hidden
          style={{ background: `hsl(${hueFor(name)} 55% 45%)` }}
        />
      )}
      <span className="console-identity__label">{name}</span>
      {isPersona && (
        <span
          className="console-chip console-chip--member-type"
          data-member-type="persona"
          title="AI agent member"
        >
          Agent
        </span>
      )}
      {isPersona && m.persona_slug && (
        <span className="console-chip console-chip--slug" title={m.persona_slug}>
          {m.persona_slug}
        </span>
      )}
    </span>
  );
}

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
    { key: 'display_name', label: 'Member', primary: true, sortable: true, render: MemberIdentity },
    { key: 'email', label: 'Email', render: (m) => m.email ?? '—' },
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
          { key: 'display_name', label: 'Name', render: (m) => memberName(m) },
          { key: 'email', label: 'Email', render: (m) => m.email ?? '—' },
          { key: 'member_type', label: 'Type' },
          { key: 'persona_slug', label: 'Persona', render: (m) => m.persona_slug ?? '—' },
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
