import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { folders } from '$lib/server/db/schema';
import { generateId } from '$lib/server/id';
import { eq } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const MAX_NAME_LENGTH = 100;

/**
 * POST /api/folders — Create a folder
 */
export const POST: RequestHandler = async ({ request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const body = await request.json().catch(() => null);
  if (!body || typeof body.name !== 'string' || !body.name.trim()) {
    return json({ message: 'Missing or empty "name" field' }, { status: 400 });
  }

  const name = body.name.slice(0, MAX_NAME_LENGTH).trim();
  const parentId = typeof body.parentId === 'string' ? body.parentId : null;

  // Validate parent exists and belongs to user
  if (parentId) {
    const parent = await db.query.folders.findFirst({
      where: eq(folders.id, parentId)
    });
    if (!parent || parent.userId !== locals.user.id) {
      return json({ message: 'Parent folder not found' }, { status: 404 });
    }
  }

  const id = generateId();
  const now = new Date();

  const [folder] = await db
    .insert(folders)
    .values({
      createdAt: now,
      id,
      name,
      parentId,
      updatedAt: now,
      userId: locals.user.id
    })
    .returning();

  return json(folder, { status: 201 });
};

/**
 * GET /api/folders — List the authenticated user's folders
 */
export const GET: RequestHandler = async ({ locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const rows = await db
    .select()
    .from(folders)
    .where(eq(folders.userId, locals.user.id))
    .orderBy(folders.name);

  return json({ folders: rows });
};
