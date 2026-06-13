import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { folders, diagrams } from '$lib/server/db/schema';
import { eq, sql } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const MAX_NAME_LENGTH = 100;

/**
 * Detect ancestor-chain cycles using a recursive CTE.
 * Returns true if moving `folderId` under `newParentId` would create a cycle.
 */
async function wouldCreateCycle(folderId: string, newParentId: string): Promise<boolean> {
  // Walk from newParentId up through ancestors. If we encounter folderId, it's a cycle.
  const result = await db.execute(sql`
    WITH RECURSIVE ancestors AS (
      SELECT id, parent_id FROM folders WHERE id = ${newParentId}
      UNION ALL
      SELECT f.id, f.parent_id FROM folders f
      INNER JOIN ancestors a ON f.id = a.parent_id
    )
    SELECT 1 FROM ancestors WHERE id = ${folderId} LIMIT 1
  `);
  return (result as unknown[]).length > 0;
}

/**
 * PATCH /api/folders/:id — Rename or move a folder
 */
export const PATCH: RequestHandler = async ({ params, request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const folder = await db.query.folders.findFirst({
    where: eq(folders.id, params.id)
  });

  if (!folder || folder.userId !== locals.user.id) {
    return json({ message: 'Folder not found' }, { status: 404 });
  }

  const body = await request.json().catch(() => null);
  if (!body || typeof body !== 'object') {
    return json({ message: 'Invalid request body' }, { status: 400 });
  }

  const updates: Record<string, unknown> = { updatedAt: new Date() };

  if (typeof body.name === 'string' && body.name.trim()) {
    updates.name = body.name.slice(0, MAX_NAME_LENGTH).trim();
  }

  if (body.parentId === null || typeof body.parentId === 'string') {
    // Prevent self-reference
    if (body.parentId === params.id) {
      return json({ message: 'A folder cannot be its own parent' }, { status: 400 });
    }

    if (body.parentId) {
      // Validate parent exists and belongs to user
      const parent = await db.query.folders.findFirst({
        where: eq(folders.id, body.parentId)
      });
      if (!parent || parent.userId !== locals.user.id) {
        return json({ message: 'Parent folder not found' }, { status: 404 });
      }

      // Recursive ancestor-chain cycle detection
      if (await wouldCreateCycle(params.id, body.parentId)) {
        return json(
          { message: 'Moving this folder here would create a circular reference' },
          { status: 400 }
        );
      }
    }
    updates.parentId = body.parentId;
  }

  const [updated] = await db
    .update(folders)
    .set(updates)
    .where(eq(folders.id, params.id))
    .returning();

  return json(updated);
};

/**
 * DELETE /api/folders/:id — Delete a folder.
 * Diagrams and child folders are reparented to root (folderId/parentId → NULL).
 * Wrapped in a transaction for atomicity.
 */
export const DELETE: RequestHandler = async ({ params, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const folder = await db.query.folders.findFirst({
    where: eq(folders.id, params.id)
  });

  if (!folder || folder.userId !== locals.user.id) {
    return json({ message: 'Folder not found' }, { status: 404 });
  }

  // Transaction: reparent children, then delete
  await db.transaction(async (tx) => {
    // Move diagrams to root
    await tx.update(diagrams).set({ folderId: null }).where(eq(diagrams.folderId, params.id));
    // Move child folders to root
    await tx.update(folders).set({ parentId: null }).where(eq(folders.parentId, params.id));
    // Delete the folder
    await tx.delete(folders).where(eq(folders.id, params.id));
  });

  return json({ deleted: true });
};
