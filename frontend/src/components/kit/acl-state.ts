/**
 * Pure ACL-state reducers for the F4 ACLEditor. Every function takes the
 * current state/entry and returns a new one — no React, no DOM, no mutation —
 * so the editor's rule-patching, member dedupe, and resource-nulling
 * semantics are directly unit-testable (see acl-state.test.ts).
 */

import type { AclGroup, AclRule, AclState, EntityRef } from '@/types/tool-state';
import { newRowId } from './ids';

/** Two EntityRefs match when kind AND id match (label is display-only). */
export function sameRef(a: EntityRef, b: EntityRef): boolean {
  return a.kind === b.kind && a.id === b.id;
}

/** Append a fresh deny rule for "any" subject; `defaultScope` seeds the scope. */
export function addRule(state: AclState, defaultScope: string | null = 'read'): AclState {
  return {
    ...state,
    rules: [
      ...state.rules,
      {
        id: newRowId('acl'),
        subject: { kind: 'any', id: '' },
        resource: null,
        effect: 'deny',
        scope: defaultScope,
        priority: 0,
      },
    ],
  };
}

/** Merge `patch` into the rule with `ruleId`; other rules pass through untouched. */
export function patchRule(state: AclState, ruleId: string, patch: Partial<AclRule>): AclState {
  return {
    ...state,
    rules: state.rules.map((r) => (r.id === ruleId ? { ...r, ...patch } : r)),
  };
}

/** Drop the rule with `ruleId`. */
export function removeRule(state: AclState, ruleId: string): AclState {
  return { ...state, rules: state.rules.filter((r) => r.id !== ruleId) };
}

/**
 * Patch one half of a rule's resource ref. An empty kind AND id nulls the
 * resource (wildcard); either half present keeps the ref alive — mirroring
 * the editor inputs, where clearing either field with the other still
 * populated must not silently detach the resource.
 */
export function patchResource(rule: AclRule, patch: Partial<Pick<EntityRef, 'kind' | 'id'>>): AclRule {
  const kind = patch.kind ?? rule.resource?.kind ?? '';
  const id = patch.id ?? rule.resource?.id ?? '';
  return { ...rule, resource: kind || id ? { kind, id } : null };
}

/**
 * Append `member` to a group unless an identical (kind+id) member is already
 * present — dedupe is a no-op, not a duplicate or an error.
 */
export function addGroupMember(group: AclGroup, member: EntityRef): AclGroup {
  if (group.members.some((x) => sameRef(x, member))) return group;
  return { ...group, members: [...group.members, member] };
}

/** Remove every member matching `member` (kind+id). */
export function removeGroupMember(group: AclGroup, member: EntityRef): AclGroup {
  return { ...group, members: group.members.filter((x) => !sameRef(x, member)) };
}
