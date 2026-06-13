import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams, diagramBranches, diagramCommits, users } from '$lib/server/db/schema';
import { eq, and } from 'drizzle-orm';
import type { RequestHandler } from './$types';
import type { CommitDetail } from '$lib/types/api';

const CODE_PREVIEW_LENGTH = 200;

/**
 * GET /api/diagrams/:id/commits/:commitId — Full commit detail
 *
 * Returns the complete commit including code and config.
 * Owner only.
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

  const commit = await db.query.diagramCommits.findFirst({
    where: eq(diagramCommits.id, params.commitId)
  });
  if (!commit) {
    return json({ message: 'Commit not found' }, { status: 404 });
  }

  // Verify this commit belongs to a branch of this diagram
  const branch = await db.query.diagramBranches.findFirst({
    where: and(eq(diagramBranches.id, commit.branchId), eq(diagramBranches.diagramId, params.id))
  });
  if (!branch) {
    return json({ message: 'Commit not found' }, { status: 404 });
  }

  // Resolve author
  const author = commit.committedBy
    ? await db.query.users.findFirst({ where: eq(users.id, commit.committedBy) })
    : null;

  const detail: CommitDetail = {
    authorName: author?.name ?? null,
    branchId: commit.branchId,
    code: commit.code,
    codePreview: commit.code.slice(0, CODE_PREVIEW_LENGTH),
    committedBy: commit.committedBy ?? '',
    config: commit.config,
    createdAt: commit.createdAt.toISOString(),
    diagramId: params.id,
    id: commit.id,
    message: commit.message,
    parentCommitId: commit.parentCommitId
  };

  return json(detail);
};
