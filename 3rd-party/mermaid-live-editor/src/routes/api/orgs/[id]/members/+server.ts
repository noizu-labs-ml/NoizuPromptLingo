import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { orgMembers, users } from '$lib/server/db/schema';
import { generateId } from '$lib/server/id';
import { eq, and } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const VALID_ROLES = ['admin', 'member'] as const;

/**
 * Helper: get the authenticated user's membership in an org.
 */
async function getMembership(orgId: string, userId: string) {
  return db.query.orgMembers.findFirst({
    where: and(eq(orgMembers.orgId, orgId), eq(orgMembers.userId, userId))
  });
}

/**
 * POST /api/orgs/:id/members — Invite a member (admin+ only)
 *
 * Body: { userId: string, role?: 'admin' | 'member' }
 * Admins can add members/admins. Only owners can add admins.
 */
export const POST: RequestHandler = async ({ params, request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const membership = await getMembership(params.id, locals.user.id);
  if (!membership || membership.role === 'member') {
    return json({ message: 'Not authorized — admin or owner required' }, { status: 403 });
  }

  const body = await request.json().catch(() => null);
  if (!body || typeof body.userId !== 'string') {
    return json({ message: 'Missing "userId" field' }, { status: 400 });
  }

  const role =
    typeof body.role === 'string' && VALID_ROLES.includes(body.role as never)
      ? (body.role as (typeof VALID_ROLES)[number])
      : 'member';

  // Only owners can add admins
  if (role === 'admin' && membership.role !== 'owner') {
    return json({ message: 'Only the owner can add admins' }, { status: 403 });
  }

  // Verify target user exists
  const targetUser = await db.query.users.findFirst({
    where: eq(users.id, body.userId)
  });
  if (!targetUser) {
    return json({ message: 'User not found' }, { status: 404 });
  }

  // Check not already a member
  const existing = await getMembership(params.id, body.userId);
  if (existing) {
    return json({ message: 'User is already a member of this organization' }, { status: 409 });
  }

  const id = generateId();
  const now = new Date();

  await db.insert(orgMembers).values({
    createdAt: now,
    id,
    orgId: params.id,
    role,
    userId: body.userId
  });

  return json(
    {
      email: targetUser.email,
      handle: targetUser.handle,
      joinedAt: now,
      name: targetUser.name,
      role,
      userId: body.userId
    },
    { status: 201 }
  );
};
