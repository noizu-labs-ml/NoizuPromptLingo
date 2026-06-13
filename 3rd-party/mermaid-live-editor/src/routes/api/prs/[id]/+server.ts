import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams, diagramPullRequests, users } from '$lib/server/db/schema';
import { eq } from 'drizzle-orm';
import type { RequestHandler } from './$types';
import type { PRUpdateBody, PullRequest } from '$lib/types/api';

/**
 * Build a full PullRequest response by joining PR + source/target diagrams + author.
 */
async function buildPullRequestResponse(
  pr: typeof diagramPullRequests.$inferSelect
): Promise<PullRequest> {
  // Fetch source and target diagram code
  const sourceDiagram = pr.sourceDiagramId
    ? await db.query.diagrams.findFirst({ where: eq(diagrams.id, pr.sourceDiagramId) })
    : null;

  const targetDiagram = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, pr.targetDiagramId)
  });

  // Fetch author info
  const author = pr.createdBy
    ? await db.query.users.findFirst({ where: eq(users.id, pr.createdBy) })
    : null;

  // Derive mergedAt / closedAt from status + closedAt column
  const mergedAt = pr.status === 'merged' && pr.closedAt ? pr.closedAt.toISOString() : null;
  const closedAt = pr.status === 'closed' && pr.closedAt ? pr.closedAt.toISOString() : null;

  return {
    authorHandle: author?.handle ?? null,
    authorName: author?.name ?? null,
    closedAt,
    createdAt: pr.createdAt.toISOString(),
    createdBy: pr.createdBy ?? '',
    description: pr.description,
    id: pr.id,
    mergedAt,
    sourceCode: sourceDiagram?.code ?? '',
    sourceDiagramId: pr.sourceDiagramId,
    status: pr.status as PullRequest['status'],
    targetCode: targetDiagram?.code ?? '',
    targetDiagramId: pr.targetDiagramId,
    title: pr.title,
    updatedAt: pr.updatedAt.toISOString()
  };
}

/**
 * GET /api/prs/:id — Fetch full PR detail
 *
 * Returns the PullRequest type including sourceCode and targetCode for diff rendering.
 */
export const GET: RequestHandler = async ({ params }) => {
  const pr = await db.query.diagramPullRequests.findFirst({
    where: eq(diagramPullRequests.id, params.id)
  });

  if (!pr) {
    return json({ message: 'Pull request not found' }, { status: 404 });
  }

  const response = await buildPullRequestResponse(pr);
  return json(response);
};

/**
 * PATCH /api/prs/:id — Merge or close a pull request
 *
 * Owner of the target diagram only.
 * Body: PRUpdateBody { status: 'merged' | 'closed' }
 *
 * If merging: updates the target diagram's code with the source diagram's code, sets closedAt.
 * If closing: sets closedAt without modifying the target diagram.
 */
export const PATCH: RequestHandler = async ({ params, request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const pr = await db.query.diagramPullRequests.findFirst({
    where: eq(diagramPullRequests.id, params.id)
  });

  if (!pr) {
    return json({ message: 'Pull request not found' }, { status: 404 });
  }

  // Only open PRs can be merged or closed
  if (pr.status !== 'open') {
    return json({ message: `Pull request is already ${pr.status}` }, { status: 400 });
  }

  // Verify the user owns the target diagram
  const targetDiagram = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, pr.targetDiagramId)
  });

  if (!targetDiagram) {
    return json({ message: 'Target diagram no longer exists' }, { status: 404 });
  }

  if (targetDiagram.userId !== locals.user.id) {
    return json(
      { message: 'Not authorized — only the target diagram owner can update this PR' },
      { status: 403 }
    );
  }

  // Parse and validate body
  const body = (await request.json().catch(() => null)) as PRUpdateBody | null;
  if (!body || (body.status !== 'merged' && body.status !== 'closed')) {
    return json({ message: 'Invalid status — must be "merged" or "closed"' }, { status: 400 });
  }

  const now = new Date();

  // If merging: apply source code to target diagram
  if (body.status === 'merged') {
    const sourceDiagram = pr.sourceDiagramId
      ? await db.query.diagrams.findFirst({ where: eq(diagrams.id, pr.sourceDiagramId) })
      : null;

    if (!sourceDiagram) {
      return json({ message: 'Source diagram no longer exists — cannot merge' }, { status: 404 });
    }

    // Update the target diagram's code with the source (fork) code
    await db
      .update(diagrams)
      .set({
        code: sourceDiagram.code,
        updatedAt: now
      })
      .where(eq(diagrams.id, pr.targetDiagramId));
  }

  // Update PR status and closedAt timestamp
  const [updated] = await db
    .update(diagramPullRequests)
    .set({
      closedAt: now,
      status: body.status,
      updatedAt: now
    })
    .where(eq(diagramPullRequests.id, params.id))
    .returning();

  const response = await buildPullRequestResponse(updated);
  return json(response);
};
