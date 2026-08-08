import type { Organization } from './api';

/**
 * Resolve the org-scoped route segment to a known org.
 *
 * The `[orgId]` route segment is canonically the org **slug**, but we tolerate a
 * UUID **id** landing there too (e.g. a link that interpolated `org.id` instead
 * of `org.slug`). Matching on slug OR id means a stray non-slug segment resolves
 * the org instead of silently returning "no org" — which is what cascades empty/
 * 404 states across every org-scoped page and reads to the user as "the active
 * org was unset".
 *
 * Pure on purpose: the single source of truth for the slug-or-id rule, shared by
 * `useOrgId` (data layer) and `useAppNav` (navigation), and unit-testable without
 * React or a route context.
 *
 * Returns `null` for an empty/unknown segment; callers fall back to the already
 * active org rather than treating `null` as an explicit clear.
 */
export function resolveOrg(
  orgs: Organization[],
  param: string | null | undefined,
): Organization | null {
  if (!param) return null;
  return orgs.find((o) => o.slug === param || o.id === param) ?? null;
}
