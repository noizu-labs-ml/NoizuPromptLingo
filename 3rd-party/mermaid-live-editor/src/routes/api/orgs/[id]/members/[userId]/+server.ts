import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { orgMembers } from '$lib/server/db/schema';
import { eq, and } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const VALID_ROLES = ['admin', 'member'] as const;

/**
 * Helper: get membership record.
 */
async function getMembership(orgId: string, userId: string) {
  return db.query.orgMembers.findFirst({
    where: and(eq(orgMembers.orgId, orgId), eq(orgMembers.userId, userId))
  });
}

/**
 * PATCH /api/orgs/:id/members/:userId — Change member role (owner only)
 */
export const PATCH: RequestHandler = async ({ params, request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const myMembership = await getMembership(params.id, locals.user.id);
  if (!myMembership || myMembership.role !== 'owner') {
    return json({ message: 'Only the owner can change roles' }, { status: 403 });
  }

  // Cannot change own role
  if (params.userId === locals.user.id) {
    return json({ message: 'Cannot change your own role' }, { status: 400 });
  }

  const targetMembership = await getMembership(params.id, params.userId);
  if (!targetMembership) {
    return json({ message: 'Member not found' }, { status: 404 });
  }

  const body = await request.json().catch(() => null);
  if (!body || typeof body.role !== 'string' || !VALID_ROLES.includes(body.role as never)) {
    return json({ message: `Invalid role. Must be: ${VALID_ROLES.join(', ')}` }, { status: 400 });
  }

  await db
    .update(orgMembers)
    .set({ role: body.role })
    .where(and(eq(orgMembers.orgId, params.id), eq(orgMembers.userId, params.userId)));

  return json({ userId: params.userId, role: body.role });
};

/**
 * DELETE /api/orgs/:id/members/:userId — Remove member (admin+ only, or self-leave)
 *
 * Rules:
 * - Members can remove themselves (leave)
 * - Admins can remove members
 * - Owners can remove anyone except themselves
 * - Cannot remove the last owner
 */
export const DELETE: RequestHandler = async ({ params, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const myMembership = await getMembership(params.id, locals.user.id);
  if (!myMembership) {
    return json({ message: 'Not a member of this organization' }, { status: 403 });
  }

  const isSelf = params.userId === locals.user.id;

  if (!isSelf) {
    // Non-self removal: need admin+ and cannot remove someone of equal/higher rank
    if (myMembership.role === 'member') {
      return json({ message: 'Not authorized' }, { status: 403 });
    }

    const targetMembership = await getMembership(params.id, params.userId);
    if (!targetMembership) {
      return json({ message: 'Member not found' }, { status: 404 });
    }

    // Admins cannot remove other admins or owners
    if (myMembership.role === 'admin' && targetMembership.role !== 'member') {
      return json({ message: 'Admins can only remove members' }, { status: 403 });
    }

    // Owners cannot remove themselves via this path (handled by isSelf block)
    if (targetMembership.role === 'owner') {
      return json({ message: 'Cannot remove the organization owner' }, { status: 403 });
    }
  } else {
    // Self-leave: owners cannot leave (must transfer ownership or delete org)
    if (myMembership.role === 'owner') {
      return json(
        { message: 'Owners cannot leave. Transfer ownership first or delete the organization.' },
        { status: 400 }
      );
    }
  }

  await db
    .delete(orgMembers)
    .where(and(eq(orgMembers.orgId, params.id), eq(orgMembers.userId, params.userId)));

  return json({ removed: true });
};
