import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams, diagramForks, diagramPullRequests, users } from '$lib/server/db/schema';
import { generateId } from '$lib/server/id';
import { eq, and, desc } from 'drizzle-orm';
import type { RequestHandler } from './$types';
import type { PRCreateBody, PRListResponse, PullRequest, PullRequestSummary } from '$lib/types/api';

const MAX_TITLE_LENGTH = 200;
const MAX_DESCRIPTION_LENGTH = 2_000;

/**
 * POST /api/diagrams/:id/prs — Create a pull request against a diagram
 *
 * Auth required. The user must own a fork of the target diagram (checked via diagramForks).
 * Captures current fork code + target code at creation time via the linked diagrams.
 */
export const POST: RequestHandler = async ({ params, request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  // Verify target diagram exists
  const target = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, params.id)
  });
  if (!target) {
    return json({ message: 'Diagram not found' }, { status: 404 });
  }

  // Verify user owns a fork of this diagram
  const fork = await db.query.diagramForks.findFirst({
    where: and(
      eq(diagramForks.sourceDiagramId, params.id),
      eq(diagramForks.forkedBy, locals.user.id)
    )
  });
  if (!fork) {
    return json(
      { message: 'You must own a fork of this diagram to create a pull request' },
      { status: 403 }
    );
  }

  // Parse and validate body
  const body = (await request.json().catch(() => null)) as PRCreateBody | null;
  if (!body || typeof body.title !== 'string' || !body.title.trim()) {
    return json({ message: 'Missing or empty "title" field' }, { status: 400 });
  }

  const title = body.title.slice(0, MAX_TITLE_LENGTH).trim();
  const description =
    typeof body.description === 'string'
      ? body.description.slice(0, MAX_DESCRIPTION_LENGTH).trim() || null
      : null;

  // Fetch the fork diagram to capture its current code
  const forkDiagram = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, fork.forkedDiagramId)
  });
  if (!forkDiagram) {
    return json({ message: 'Fork diagram no longer exists' }, { status: 404 });
  }

  const prId = generateId();
  const now = new Date();

  const [pr] = await db
    .insert(diagramPullRequests)
    .values({
      createdAt: now,
      createdBy: locals.user.id,
      description,
      id: prId,
      sourceDiagramId: fork.forkedDiagramId,
      status: 'open',
      targetDiagramId: params.id,
      title,
      updatedAt: now
    })
    .returning();

  // Fetch author info for the response
  const author = await db.query.users.findFirst({
    where: eq(users.id, locals.user.id)
  });

  const response: PullRequest = {
    authorHandle: author?.handle ?? null,
    authorName: author?.name ?? null,
    closedAt: null,
    createdAt: pr.createdAt.toISOString(),
    createdBy: pr.createdBy ?? '',
    description: pr.description,
    id: pr.id,
    mergedAt: null,
    sourceCode: forkDiagram.code,
    sourceDiagramId: pr.sourceDiagramId,
    status: pr.status as PullRequest['status'],
    targetCode: target.code,
    targetDiagramId: pr.targetDiagramId,
    title: pr.title,
    updatedAt: pr.updatedAt.toISOString()
  };

  return json(response, { status: 201 });
};

/**
 * GET /api/diagrams/:id/prs — List pull requests for a diagram
 *
 * Auth required.
 * - If the user owns the target diagram: return all PRs.
 * - If the user is a fork author: return only their PRs.
 * - Otherwise: 403.
 */
export const GET: RequestHandler = async ({ params, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  // Verify target diagram exists
  const target = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, params.id)
  });
  if (!target) {
    return json({ message: 'Diagram not found' }, { status: 404 });
  }

  const isOwner = target.userId === locals.user.id;

  // Build the query conditions
  const conditions = [eq(diagramPullRequests.targetDiagramId, params.id)];

  if (!isOwner) {
    // Non-owner: only see their own PRs
    conditions.push(eq(diagramPullRequests.createdBy, locals.user.id));
  }

  const rows = await db
    .select({
      createdAt: diagramPullRequests.createdAt,
      createdBy: diagramPullRequests.createdBy,
      id: diagramPullRequests.id,
      status: diagramPullRequests.status,
      title: diagramPullRequests.title
    })
    .from(diagramPullRequests)
    .where(conditions.length === 1 ? conditions[0] : and(...conditions))
    .orderBy(desc(diagramPullRequests.createdAt));

  // Resolve author names/handles
  const authorIds = [...new Set(rows.map((r) => r.createdBy).filter(Boolean))] as string[];
  const authorMap = new Map<string, { name: string | null; handle: string | null }>();

  if (authorIds.length > 0) {
    for (const authorId of authorIds) {
      const author = await db.query.users.findFirst({
        where: eq(users.id, authorId)
      });
      if (author) {
        authorMap.set(authorId, { name: author.name, handle: author.handle });
      }
    }
  }

  const pullRequests: PullRequestSummary[] = rows.map((r) => {
    const author = r.createdBy ? authorMap.get(r.createdBy) : null;
    return {
      authorHandle: author?.handle ?? null,
      authorName: author?.name ?? null,
      createdAt: r.createdAt.toISOString(),
      id: r.id,
      status: r.status as PullRequestSummary['status'],
      title: r.title
    };
  });

  const response: PRListResponse = { pullRequests };
  return json(response);
};
