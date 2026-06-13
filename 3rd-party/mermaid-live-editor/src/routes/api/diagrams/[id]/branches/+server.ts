import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams, diagramBranches, diagramCommits } from '$lib/server/db/schema';
import { generateId } from '$lib/server/id';
import { eq, and, desc } from 'drizzle-orm';
import type { RequestHandler } from './$types';
import type { Branch, BranchListResponse, BranchCreateBody } from '$lib/types/api';

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
 * GET /api/diagrams/:id/branches — List branches for a diagram
 *
 * Owner only. Returns branches with computed headCommitId.
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

  const rows = await db
    .select()
    .from(diagramBranches)
    .where(eq(diagramBranches.diagramId, params.id))
    .orderBy(diagramBranches.createdAt);

  const branches: Branch[] = [];
  for (const row of rows) {
    const head = await getBranchHead(row.id);
    branches.push({
      createdAt: row.createdAt.toISOString(),
      createdBy: row.createdBy,
      diagramId: row.diagramId,
      headCommitId: head?.id ?? null,
      id: row.id,
      name: row.name
    });
  }

  return json({ branches } satisfies BranchListResponse);
};

/**
 * POST /api/diagrams/:id/branches — Create a new branch
 *
 * Body: BranchCreateBody { name, fromCommitId? }
 * If fromCommitId is provided, copies that commit onto the new branch.
 * Otherwise, starts from the active branch's HEAD.
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

  const body: BranchCreateBody = await request.json().catch(() => null);
  if (!body || typeof body !== 'object' || typeof body.name !== 'string' || !body.name.trim()) {
    return json({ message: 'Invalid request body — "name" is required' }, { status: 400 });
  }

  const branchName = body.name.trim();

  // Check for duplicate branch name
  const existing = await db.query.diagramBranches.findFirst({
    where: and(eq(diagramBranches.diagramId, params.id), eq(diagramBranches.name, branchName))
  });
  if (existing) {
    return json({ message: `Branch "${branchName}" already exists` }, { status: 409 });
  }

  const now = new Date();
  const branchId = generateId();

  const [branch] = await db
    .insert(diagramBranches)
    .values({
      createdAt: now,
      createdBy: locals.user.id,
      diagramId: params.id,
      id: branchId,
      name: branchName,
      updatedAt: now
    })
    .returning();

  // Determine starting commit to copy onto the new branch
  let sourceCommit: typeof diagramCommits.$inferSelect | null = null;

  if (body.fromCommitId) {
    const commit = await db.query.diagramCommits.findFirst({
      where: eq(diagramCommits.id, body.fromCommitId)
    });
    if (!commit) {
      return json({ message: 'Source commit not found' }, { status: 404 });
    }
    // Verify commit belongs to this diagram
    const commitBranch = await db.query.diagramBranches.findFirst({
      where: and(eq(diagramBranches.id, commit.branchId), eq(diagramBranches.diagramId, params.id))
    });
    if (!commitBranch) {
      return json({ message: 'Source commit does not belong to this diagram' }, { status: 400 });
    }
    sourceCommit = commit;
  } else if (diagram.activeBranchId) {
    sourceCommit = await getBranchHead(diagram.activeBranchId);
  }

  // Create an initial commit on the new branch from the source
  let headCommitId: string | null = null;
  if (sourceCommit) {
    const commitId = generateId();
    await db.insert(diagramCommits).values({
      branchId: branchId,
      code: sourceCommit.code,
      committedBy: locals.user.id,
      config: sourceCommit.config,
      createdAt: now,
      id: commitId,
      message: `Branch "${branchName}" created`,
      parentCommitId: null
    });
    headCommitId = commitId;
  }

  const result: Branch = {
    createdAt: branch.createdAt.toISOString(),
    createdBy: branch.createdBy,
    diagramId: branch.diagramId,
    headCommitId,
    id: branch.id,
    name: branch.name
  };

  return json(result, { status: 201 });
};
