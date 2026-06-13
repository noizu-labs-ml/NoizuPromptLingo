import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams, diagramBranches, diagramCommits } from '$lib/server/db/schema';
import { eq, and, desc } from 'drizzle-orm';
import type { RequestHandler } from './$types';

/**
 * Find the HEAD commit (most recent) on a branch.
 */
async function getBranchHead(branchId: string) {
  const [head] = await db
    .select()
    .from(diagramCommits)
    .where(eq(diagramCommits.branchId, branchId))
    .orderBy(desc(diagramCommits.createdAt))
    .limit(1);
  return head ?? null;
}

/**
 * PATCH /api/diagrams/:id/branches/:branchId — Switch active branch
 *
 * Sets diagram.activeBranchId to this branch.
 * Updates diagram code/config to match the branch HEAD commit.
 * Owner only.
 */
export const PATCH: RequestHandler = async ({ params, locals }) => {
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

  // Verify branch belongs to this diagram
  const branch = await db.query.diagramBranches.findFirst({
    where: and(eq(diagramBranches.id, params.branchId), eq(diagramBranches.diagramId, params.id))
  });
  if (!branch) {
    return json({ message: 'Branch not found' }, { status: 404 });
  }

  // Get HEAD commit to update diagram code/config
  const head = await getBranchHead(branch.id);

  const now = new Date();
  const updates: Record<string, unknown> = {
    activeBranchId: branch.id,
    updatedAt: now
  };

  if (head) {
    updates.code = head.code;
    updates.config = head.config;
  }

  await db.update(diagrams).set(updates).where(eq(diagrams.id, params.id)).returning();

  return json({
    createdAt: branch.createdAt.toISOString(),
    createdBy: branch.createdBy,
    diagramId: branch.diagramId,
    headCommitId: head?.id ?? null,
    id: branch.id,
    name: branch.name
  });
};

/**
 * DELETE /api/diagrams/:id/branches/:branchId — Delete a branch
 *
 * Cannot delete the "main" branch.
 * If deleting the active branch, switches active to "main".
 * Owner only.
 */
export const DELETE: RequestHandler = async ({ params, locals }) => {
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

  // Verify branch belongs to this diagram
  const branch = await db.query.diagramBranches.findFirst({
    where: and(eq(diagramBranches.id, params.branchId), eq(diagramBranches.diagramId, params.id))
  });
  if (!branch) {
    return json({ message: 'Branch not found' }, { status: 404 });
  }

  if (branch.name === 'main') {
    return json({ message: 'Cannot delete the "main" branch' }, { status: 400 });
  }

  // If this was the active branch, switch to main
  if (diagram.activeBranchId === branch.id) {
    const mainBranch = await db.query.diagramBranches.findFirst({
      where: and(eq(diagramBranches.diagramId, params.id), eq(diagramBranches.name, 'main'))
    });

    if (mainBranch) {
      const head = await getBranchHead(mainBranch.id);
      const updates: Record<string, unknown> = {
        activeBranchId: mainBranch.id,
        updatedAt: new Date()
      };
      if (head) {
        updates.code = head.code;
        updates.config = head.config;
      }
      await db.update(diagrams).set(updates).where(eq(diagrams.id, params.id));
    }
  }

  // Delete branch (cascades to commits via FK)
  await db.delete(diagramBranches).where(eq(diagramBranches.id, branch.id));

  return json({ deleted: true });
};
