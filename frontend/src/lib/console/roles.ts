// FE role-rank helper (ticket 0f8453f5 / 7bddfd70, diego-frontend). The affordance-
// gating LOGIC behind per-row RBAC visibility (ADR-015). Ranks mirror the BE
// @role_ranks (lucia 053): owner > admin > lead > member > viewer — LOWER number =
// HIGHER privilege. Tolerates the LEGACY org-member vocabulary (editor == member) so
// the members table (legacy role values) and the RBAC ctx.effectiveRole compare on
// ONE scale (ava seq628 reconcile).
//
// INVARIANT: this gates affordance VISIBILITY/keyboard-reachability ONLY — never
// enforcement. The server guard is the sole deny-closed boundary; a forged client
// that un-hides an action still 403s. Unknown roles rank 99 (deny-closed).

export const ROLE_RANK: Record<string, number> = {
  owner: 0,
  admin: 1,
  lead: 2,
  member: 3,
  editor: 3, // legacy alias for member
  viewer: 4,
};

/** Rank of a role; unknown/absent ranks 99 (deny-closed). */
export function roleRank(role?: string | null): number {
  return role != null && role in ROLE_RANK ? ROLE_RANK[role] : 99;
}

/** True when `role` is at least `min` privilege (rank <= min's rank). */
export function atLeast(role: string | undefined | null, min: string): boolean {
  return roleRank(role) <= roleRank(min);
}

/** True when `caller` strictly outranks `target` (higher privilege) — e.g. a lead may
 *  not remove an admin or another lead (target-rank rule, ADR-015 B1 in-tool check). */
export function outranks(caller?: string | null, target?: string | null): boolean {
  return roleRank(caller) < roleRank(target);
}
