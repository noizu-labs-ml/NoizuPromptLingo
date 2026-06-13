import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { organizations, orgMembers, users } from '$lib/server/db/schema';
import { eq, and } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const MAX_NAME_LENGTH = 100;

/**
 * Helper: get the authenticated user's membership in an org.
 * Returns null if not a member.
 */
async function getMembership(orgId: string, userId: string) {
  return db.query.orgMembers.findFirst({
    where: and(eq(orgMembers.orgId, orgId), eq(orgMembers.userId, userId))
  });
}

/**
 * GET /api/orgs/:id — Get organization details + members
 * Only accessible to org members.
 */
export const GET: RequestHandler = async ({ params, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const membership = await getMembership(params.id, locals.user.id);
  if (!membership) {
    return json({ message: 'Organization not found' }, { status: 404 });
  }

  const org = await db.query.organizations.findFirst({
    where: eq(organizations.id, params.id)
  });
  if (!org) {
    return json({ message: 'Organization not found' }, { status: 404 });
  }

  // Fetch members with user info
  const members = await db
    .select({
      email: users.email,
      handle: users.handle,
      image: users.image,
      joinedAt: orgMembers.createdAt,
      name: users.name,
      role: orgMembers.role,
      userId: orgMembers.userId
    })
    .from(orgMembers)
    .innerJoin(users, eq(orgMembers.userId, users.id))
    .where(eq(orgMembers.orgId, params.id))
    .orderBy(orgMembers.createdAt);

  return json({
    ...org,
    myRole: membership.role,
    members
  });
};

/**
 * PATCH /api/orgs/:id — Update organization (admin+ only)
 */
export const PATCH: RequestHandler = async ({ params, request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const membership = await getMembership(params.id, locals.user.id);
  if (!membership || membership.role === 'member') {
    return json({ message: 'Not authorized' }, { status: 403 });
  }

  const body = await request.json().catch(() => null);
  if (!body || typeof body !== 'object') {
    return json({ message: 'Invalid request body' }, { status: 400 });
  }

  const updates: Record<string, unknown> = { updatedAt: new Date() };

  if (typeof body.name === 'string' && body.name.trim()) {
    updates.name = body.name.slice(0, MAX_NAME_LENGTH).trim();
  }

  const [updated] = await db
    .update(organizations)
    .set(updates)
    .where(eq(organizations.id, params.id))
    .returning();

  return json(updated);
};

/**
 * DELETE /api/orgs/:id — Delete organization (owner only)
 */
export const DELETE: RequestHandler = async ({ params, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const membership = await getMembership(params.id, locals.user.id);
  if (!membership || membership.role !== 'owner') {
    return json({ message: 'Only the organization owner can delete it' }, { status: 403 });
  }

  // CASCADE handles orgMembers + diagramShares cleanup
  await db.delete(organizations).where(eq(organizations.id, params.id));

  return json({ deleted: true });
};
