import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams, diagramBranches, diagramCommits, users } from '$lib/server/db/schema';
import { generateId } from '$lib/server/id';
import { eq, and, desc } from 'drizzle-orm';
import type { RequestHandler } from './$types';
import type { CommitDetail, RevertBody } from '$lib/types/api';

const CODE_PREVIEW_LENGTH = 200;

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
 * POST /api/diagrams/:id/revert — Revert to a previous commit
 *
 * Body: RevertBody { commitId }
 * Creates a NEW commit on the active branch with the target commit's code/config.
 * Updates diagram code/config to match.
 * Owner only.
 */
export const POST: RequestHandler = async ({ params, request, locals }) => {
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

  const body: RevertBody = await request.json().catch(() => null);
  if (!body || typeof body !== 'object' || typeof body.commitId !== 'string') {
    return json({ message: 'Invalid request body — "commitId" is required' }, { status: 400 });
  }

  // Fetch the target commit
  const targetCommit = await db.query.diagramCommits.findFirst({
    where: eq(diagramCommits.id, body.commitId)
  });
  if (!targetCommit) {
    return json({ message: 'Target commit not found' }, { status: 404 });
  }

  // Verify the target commit belongs to this diagram
  const targetBranch = await db.query.diagramBranches.findFirst({
    where: and(
      eq(diagramBranches.id, targetCommit.branchId),
      eq(diagramBranches.diagramId, params.id)
    )
  });
  if (!targetBranch) {
    return json({ message: 'Target commit does not belong to this diagram' }, { status: 400 });
  }

  // Must have an active branch
  if (!diagram.activeBranchId) {
    return json({ message: 'No active branch — cannot revert' }, { status: 400 });
  }

  // Get current HEAD on the active branch
  const head = await getBranchHead(diagram.activeBranchId);

  const now = new Date();
  const commitId = generateId();

  // Create a new revert commit on the active branch
  const [revertCommit] = await db
    .insert(diagramCommits)
    .values({
      branchId: diagram.activeBranchId,
      code: targetCommit.code,
      committedBy: locals.user.id,
      config: targetCommit.config,
      createdAt: now,
      id: commitId,
      message: `Revert to ${body.commitId}`,
      parentCommitId: head?.id ?? null
    })
    .returning();

  // Update branch updatedAt
  await db
    .update(diagramBranches)
    .set({ updatedAt: now })
    .where(eq(diagramBranches.id, diagram.activeBranchId));

  // Update diagram code/config
  await db
    .update(diagrams)
    .set({
      code: targetCommit.code,
      config: targetCommit.config,
      updatedAt: now
    })
    .where(eq(diagrams.id, params.id));

  // Resolve author
  const author = await db.query.users.findFirst({ where: eq(users.id, locals.user.id) });

  const detail: CommitDetail = {
    authorName: author?.name ?? null,
    branchId: revertCommit.branchId,
    code: revertCommit.code,
    codePreview: revertCommit.code.slice(0, CODE_PREVIEW_LENGTH),
    committedBy: revertCommit.committedBy ?? '',
    config: revertCommit.config,
    createdAt: revertCommit.createdAt.toISOString(),
    diagramId: params.id,
    id: revertCommit.id,
    message: revertCommit.message,
    parentCommitId: revertCommit.parentCommitId
  };

  return json(detail, { status: 201 });
};
