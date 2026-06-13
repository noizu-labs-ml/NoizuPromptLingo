import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { organizations, orgMembers } from '$lib/server/db/schema';
import { generateId } from '$lib/server/id';
import { eq } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const MAX_NAME_LENGTH = 100;
const MAX_SLUG_LENGTH = 60;
const SLUG_PATTERN = /^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/;

/**
 * POST /api/orgs — Create a new organization
 * Creator automatically becomes owner.
 */
export const POST: RequestHandler = async ({ request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const body = await request.json().catch(() => null);
  if (!body || typeof body.name !== 'string' || !body.name.trim()) {
    return json({ message: 'Missing or empty "name" field' }, { status: 400 });
  }
  if (typeof body.slug !== 'string' || !body.slug.trim()) {
    return json({ message: 'Missing or empty "slug" field' }, { status: 400 });
  }

  const name = body.name.slice(0, MAX_NAME_LENGTH).trim();
  const slug = body.slug.slice(0, MAX_SLUG_LENGTH).trim().toLowerCase();

  if (!SLUG_PATTERN.test(slug)) {
    return json(
      {
        message: 'Slug must be lowercase alphanumeric with hyphens, not starting/ending with hyphen'
      },
      { status: 400 }
    );
  }

  // Check slug uniqueness
  const existing = await db.query.organizations.findFirst({
    where: eq(organizations.slug, slug)
  });
  if (existing) {
    return json({ message: 'An organization with this slug already exists' }, { status: 409 });
  }

  const orgId = generateId();
  const memberId = generateId();
  const now = new Date();

  // Transaction: create org + add creator as owner
  await db.transaction(async (tx) => {
    await tx.insert(organizations).values({
      createdAt: now,
      id: orgId,
      name,
      slug,
      updatedAt: now
    });
    await tx.insert(orgMembers).values({
      createdAt: now,
      id: memberId,
      orgId,
      role: 'owner',
      userId: locals.user.id
    });
  });

  const [org] = await db.select().from(organizations).where(eq(organizations.id, orgId));

  return json({ ...org, role: 'owner' }, { status: 201 });
};

/**
 * GET /api/orgs — List the authenticated user's organizations
 */
export const GET: RequestHandler = async ({ locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const rows = await db
    .select({
      createdAt: organizations.createdAt,
      id: organizations.id,
      name: organizations.name,
      role: orgMembers.role,
      slug: organizations.slug,
      updatedAt: organizations.updatedAt
    })
    .from(orgMembers)
    .innerJoin(organizations, eq(orgMembers.orgId, organizations.id))
    .where(eq(orgMembers.userId, locals.user.id))
    .orderBy(organizations.name);

  return json({ organizations: rows });
};
