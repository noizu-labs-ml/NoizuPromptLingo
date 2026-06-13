import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams, diagramShares, users, organizations, orgMembers } from '$lib/server/db/schema';
import { generateId } from '$lib/server/id';
import { eq, and } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const VALID_PERMISSIONS = ['view', 'edit'] as const;

/**
 * POST /api/diagrams/:id/shares — Grant access to a diagram
 *
 * Body: { userId?: string, orgId?: string, permission?: 'view' | 'edit' }
 * At least one of userId or orgId must be provided.
 * Owner only.
 */
export const POST: RequestHandler = async ({ params, request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  // Verify diagram ownership
  const diagram = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, params.id)
  });
  if (!diagram) {
    return json({ message: 'Diagram not found' }, { status: 404 });
  }
  if (diagram.userId !== locals.user.id) {
    return json(
      { message: 'Not authorized — only the diagram owner can share it' },
      { status: 403 }
    );
  }

  const body = await request.json().catch(() => null);
  if (!body || typeof body !== 'object') {
    return json({ message: 'Invalid request body' }, { status: 400 });
  }

  const sharedWithUserId = typeof body.userId === 'string' ? body.userId : null;
  const sharedWithOrgId = typeof body.orgId === 'string' ? body.orgId : null;

  if (!sharedWithUserId && !sharedWithOrgId) {
    return json({ message: 'Provide at least one of "userId" or "orgId"' }, { status: 400 });
  }

  const permission =
    typeof body.permission === 'string' && VALID_PERMISSIONS.includes(body.permission as never)
      ? (body.permission as (typeof VALID_PERMISSIONS)[number])
      : 'view';

  // Validate target user exists
  if (sharedWithUserId) {
    const target = await db.query.users.findFirst({ where: eq(users.id, sharedWithUserId) });
    if (!target) {
      return json({ message: 'Target user not found' }, { status: 404 });
    }
    // Cannot share with yourself
    if (sharedWithUserId === locals.user.id) {
      return json({ message: 'Cannot share a diagram with yourself' }, { status: 400 });
    }
  }

  // Validate target org exists and user is a member
  if (sharedWithOrgId) {
    const org = await db.query.organizations.findFirst({
      where: eq(organizations.id, sharedWithOrgId)
    });
    if (!org) {
      return json({ message: 'Target organization not found' }, { status: 404 });
    }
    // Verify the sharer is a member of the org
    const membership = await db.query.orgMembers.findFirst({
      where: and(eq(orgMembers.orgId, sharedWithOrgId), eq(orgMembers.userId, locals.user.id))
    });
    if (!membership) {
      return json({ message: 'You must be a member of the target organization' }, { status: 403 });
    }
  }

  const id = generateId();
  const now = new Date();

  const [share] = await db
    .insert(diagramShares)
    .values({
      createdAt: now,
      diagramId: params.id,
      id,
      permission,
      sharedWithOrgId,
      sharedWithUserId
    })
    .returning();

  return json(share, { status: 201 });
};

/**
 * GET /api/diagrams/:id/shares — List shares for a diagram (owner only)
 */
export const GET: RequestHandler = async ({ params, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const diagram = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, params.id)
  });
  if (!diagram) {
    return json({ message: 'Diagram not found' }, { status: 404 });
  }
  if (diagram.userId !== locals.user.id) {
    return json({ message: 'Not authorized' }, { status: 403 });
  }

  const shares = await db
    .select({
      createdAt: diagramShares.createdAt,
      id: diagramShares.id,
      permission: diagramShares.permission,
      sharedWithOrgId: diagramShares.sharedWithOrgId,
      sharedWithUserId: diagramShares.sharedWithUserId
    })
    .from(diagramShares)
    .where(eq(diagramShares.diagramId, params.id))
    .orderBy(diagramShares.createdAt);

  return json({ shares });
};
