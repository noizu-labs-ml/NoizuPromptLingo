/**
 * Converters between the two ACL vocabularies in this app:
 *
 *  - Wire flavor (`@/lib/acl-api`): mirrors the D3 backend payloads —
 *    subjects/resources are opaque ERP ref strings ("Type:id") and group
 *    members are `{ref, ref_string, expires_at}`.
 *  - EntityRef flavor (`@/types/tool-state`): the F4 kit contract — refs are
 *    `{kind, id, label?}` and group members are plain EntityRefs.
 *
 * The shapes are NOT round-trippable: wire members carry `expires_at` and a
 * group `status`/`description` that the EntityRef flavor has nowhere to put,
 * and EntityRef `label` is display-only and dropped on the way out. These
 * helpers only convert what is convertible.
 */

import type { AclGroup, EntityRef } from '@/types/tool-state';
import type { AclGroupWire, AclGroupMember } from '@/lib/acl-api';

/**
 * Parse an opaque ERP ref string ("Type:id", or a bare "id" → kind "any")
 * into an EntityRef. Inverse of `entityRefToSref` for refs without labels.
 */
export function srefToEntityRef(s: string): EntityRef {
  const trimmed = s.trim();
  if (!trimmed) return { kind: 'any', id: '' };
  const sep = trimmed.indexOf(':');
  if (sep === -1) return { kind: 'any', id: trimmed };
  const kind = trimmed.slice(0, sep).trim();
  const id = trimmed.slice(sep + 1).trim();
  return { kind: kind || 'any', id };
}

/** Serialize an EntityRef to its opaque ERP ref string ("kind:id"). */
export function entityRefToSref(r: EntityRef): string {
  return `${r.kind}:${r.id}`;
}

/**
 * The ref string for a wire group member — prefers the backend-provided
 * `ref_string`, falls back to rendering the jsonb ref map (members fetched
 * before ref_string backfill may only have `{ref}`).
 */
export function wireMemberSref(m: AclGroupMember): string {
  return m.ref_string || `${m.ref.type}:${m.ref.id}`;
}

/** Membership test for a wire group: does `sref` belong to `group`? */
export function wireGroupHasMember(group: AclGroupWire, sref: string): boolean {
  return group.members.some((m) => wireMemberSref(m) === sref);
}

/**
 * Convert an EntityRef-flavored group to the wire shape. `expires_at` is
 * null (the EntityRef flavor has no expiry concept) and `label` is dropped
 * — it is display-only metadata that never persists in the ref itself.
 */
export function toWireGroup(group: AclGroup): AclGroupWire {
  return {
    id: group.id,
    name: group.name,
    description: null,
    status: 'active',
    members: group.members.map((m) => ({
      ref: { type: m.kind, id: m.id },
      ref_string: entityRefToSref(m),
      expires_at: null,
    })),
  };
}
