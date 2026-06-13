import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams, diagramBranches, diagramCommits, users } from '$lib/server/db/schema';
import { generateId } from '$lib/server/id';
import { eq, and, desc, lt } from 'drizzle-orm';
import type { RequestHandler } from './$types';
import type { Commit, CommitDetail, CommitListResponse, CommitCreateBody } from '$lib/types/api';

const MAX_LIMIT = 100;
const DEFAULT_LIMIT = 50;
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
 * Ensure a "main" branch exists for a diagram, creating it if necessary.
 * Returns the branch row.
 */
async function ensureMainBranch(diagramId: string, userId: string) {
  const existing = await db.query.diagramBranches.findFirst({
    where: and(eq(diagramBranches.diagramId, diagramId), eq(diagramBranches.name, 'main'))
  });
  if (existing) return existing;

  const now = new Date();
  const id = generateId();
  const [branch] = await db
    .insert(diagramBranches)
    .values({
      createdAt: now,
      createdBy: userId,
      diagramId,
      id,
      name: 'main',
      updatedAt: now
    })
    .returning();

  // Set as active branch if diagram has none
  await db
    .update(diagrams)
    .set({ activeBranchId: id, updatedAt: now })
    .where(and(eq(diagrams.id, diagramId), eq(diagrams.activeBranchId, null as unknown as string)));

  return branch;
}

/**
 * GET /api/diagrams/:id/commits — List commits
 *
 * Query params:
 *   branch  — filter by branch name (default: active branch)
 *   limit   — max results (default 50, max 100)
 *   before  — cursor: return commits created before this commitId
 */
export const GET: RequestHandler = async ({ params, url, locals }) => {
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

  const branchName = url.searchParams.get('branch');
  const limitParam = parseInt(url.searchParams.get('limit') ?? '', 10);
  const limit = Number.isFinite(limitParam)
    ? Math.min(Math.max(limitParam, 1), MAX_LIMIT)
    : DEFAULT_LIMIT;
  const beforeId = url.searchParams.get('before');

  // Resolve branch
  let branchId: string | null = null;
  if (branchName) {
    const branch = await db.query.diagramBranches.findFirst({
      where: and(eq(diagramBranches.diagramId, params.id), eq(diagramBranches.name, branchName))
    });
    if (!branch) {
      return json({ message: `Branch "${branchName}" not found` }, { status: 404 });
    }
    branchId = branch.id;
  } else if (diagram.activeBranchId) {
    branchId = diagram.activeBranchId;
  }

  // If no branch exists yet, return empty
  if (!branchId) {
    return json({ commits: [], hasMore: false } satisfies CommitListResponse);
  }

  // Build cursor condition
  let cursorCreatedAt: Date | null = null;
  if (beforeId) {
    const cursorCommit = await db.query.diagramCommits.findFirst({
      where: eq(diagramCommits.id, beforeId)
    });
    if (cursorCommit) {
      cursorCreatedAt = cursorCommit.createdAt;
    }
  }

  const conditions = [eq(diagramCommits.branchId, branchId)];
  if (cursorCreatedAt) {
    conditions.push(lt(diagramCommits.createdAt, cursorCreatedAt));
  }

  // Fetch limit+1 to detect hasMore
  const rows = await db
    .select({
      branchId: diagramCommits.branchId,
      code: diagramCommits.code,
      committedBy: diagramCommits.committedBy,
      createdAt: diagramCommits.createdAt,
      id: diagramCommits.id,
      message: diagramCommits.message,
      parentCommitId: diagramCommits.parentCommitId
    })
    .from(diagramCommits)
    .where(and(...conditions))
    .orderBy(desc(diagramCommits.createdAt))
    .limit(limit + 1);

  const hasMore = rows.length > limit;
  const page = hasMore ? rows.slice(0, limit) : rows;

  // Batch-resolve author names
  const userIds = [...new Set(page.map((r) => r.committedBy).filter(Boolean))] as string[];
  const userMap = new Map<string, string | null>();
  if (userIds.length > 0) {
    for (const uid of userIds) {
      const u = await db.query.users.findFirst({ where: eq(users.id, uid) });
      userMap.set(uid, u?.name ?? null);
    }
  }

  const commits: Commit[] = page.map((r) => ({
    authorName: r.committedBy ? (userMap.get(r.committedBy) ?? null) : null,
    branchId: r.branchId,
    codePreview: r.code.slice(0, CODE_PREVIEW_LENGTH),
    committedBy: r.committedBy ?? '',
    createdAt: r.createdAt.toISOString(),
    diagramId: params.id,
    id: r.id,
    message: r.message,
    parentCommitId: r.parentCommitId
  }));

  return json({ commits, hasMore } satisfies CommitListResponse);
};

/**
 * POST /api/diagrams/:id/commits — Create a commit
 *
 * Body: CommitCreateBody { code, message?, config?, branchId? }
 * If branchId is omitted, uses the diagram's active branch or creates "main".
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

  const body: CommitCreateBody = await request.json().catch(() => null);
  if (!body || typeof body !== 'object' || typeof body.code !== 'string' || !body.code.trim()) {
    return json({ message: 'Invalid request body — "code" is required' }, { status: 400 });
  }

  // Resolve target branch
  let targetBranchId: string;
  if (body.branchId) {
    const branch = await db.query.diagramBranches.findFirst({
      where: and(eq(diagramBranches.id, body.branchId), eq(diagramBranches.diagramId, params.id))
    });
    if (!branch) {
      return json({ message: 'Branch not found' }, { status: 404 });
    }
    targetBranchId = branch.id;
  } else if (diagram.activeBranchId) {
    targetBranchId = diagram.activeBranchId;
  } else {
    const mainBranch = await ensureMainBranch(params.id, locals.user.id);
    targetBranchId = mainBranch.id;
  }

  // Get current HEAD to set as parent
  const head = await getBranchHead(targetBranchId);
  const parentCommitId = head?.id ?? null;

  const now = new Date();
  const commitId = generateId();

  const [commit] = await db
    .insert(diagramCommits)
    .values({
      branchId: targetBranchId,
      code: body.code,
      committedBy: locals.user.id,
      config: body.config ?? null,
      createdAt: now,
      id: commitId,
      message: body.message ?? null,
      parentCommitId
    })
    .returning();

  // Update branch updatedAt
  await db
    .update(diagramBranches)
    .set({ updatedAt: now })
    .where(eq(diagramBranches.id, targetBranchId));

  // Resolve author name
  const author = await db.query.users.findFirst({ where: eq(users.id, locals.user.id) });

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

  return json(detail, { status: 201 });
};
