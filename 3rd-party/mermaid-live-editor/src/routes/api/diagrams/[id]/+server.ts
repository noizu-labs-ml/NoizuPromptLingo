import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import {
  diagrams,
  folders,
  diagramShares,
  orgMembers,
  diagramBranches,
  diagramCommits
} from '$lib/server/db/schema';
import { generateId } from '$lib/server/id';
import { eq, and, desc } from 'drizzle-orm';
import type { RequestHandler } from './$types';

/**
 * Check if a user has share access to a private diagram.
 * Checks both direct user shares and org-level shares.
 */
async function checkShareAccess(diagramId: string, userId: string): Promise<boolean> {
  // Direct user share
  const directShare = await db.query.diagramShares.findFirst({
    where: and(eq(diagramShares.diagramId, diagramId), eq(diagramShares.sharedWithUserId, userId))
  });
  if (directShare) return true;

  // Org share: find orgs the user belongs to, then check if diagram is shared with any
  const userOrgs = await db
    .select({ orgId: orgMembers.orgId })
    .from(orgMembers)
    .where(eq(orgMembers.userId, userId));

  if (userOrgs.length > 0) {
    for (const { orgId } of userOrgs) {
      const orgShare = await db.query.diagramShares.findFirst({
        where: and(eq(diagramShares.diagramId, diagramId), eq(diagramShares.sharedWithOrgId, orgId))
      });
      if (orgShare) return true;
    }
  }

  return false;
}

const MAX_CODE_LENGTH = 500_000;
const MAX_TITLE_LENGTH = 200;
const MAX_DESCRIPTION_LENGTH = 2_000;
const MAX_CONFIG_LENGTH = 50_000; // 50KB
const MAX_THUMBNAIL_LENGTH = 500_000; // 500KB
const MAX_TAGS = 20;
const MAX_TAG_LENGTH = 50;
const VALID_VISIBILITY = ['private', 'unlisted', 'public'] as const;

/**
 * GET /api/diagrams/:id — Fetch a diagram by short ID
 *
 * Access rules:
 *  - public/unlisted: anyone can read
 *  - private: owner only (or shared-with, Phase 2)
 */
export const GET: RequestHandler = async ({ params, locals }) => {
  const diagram = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, params.id)
  });

  if (!diagram) {
    return json({ message: 'Diagram not found' }, { status: 404 });
  }

  // Access control
  if (diagram.visibility === 'private') {
    if (!locals.user) {
      return json({ message: 'Diagram not found' }, { status: 404 });
    }
    if (diagram.userId !== locals.user.id) {
      // Check if the user has been granted explicit access (direct share or org share)
      const hasAccess = await checkShareAccess(diagram.id, locals.user.id);
      if (!hasAccess) {
        return json({ message: 'Diagram not found' }, { status: 404 });
      }
    }
  }

  return json(diagram);
};

/**
 * PATCH /api/diagrams/:id — Update a diagram (owner only)
 */
export const PATCH: RequestHandler = async ({ params, request, locals }) => {
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

  const body = await request.json().catch(() => null);
  if (!body || typeof body !== 'object') {
    return json({ message: 'Invalid request body' }, { status: 400 });
  }

  const updates: Record<string, unknown> = { updatedAt: new Date() };

  if (typeof body.code === 'string') {
    if (body.code.length > MAX_CODE_LENGTH) {
      return json(
        { message: `Code exceeds max length (${MAX_CODE_LENGTH} chars)` },
        { status: 400 }
      );
    }
    if (!body.code.trim()) {
      return json({ message: 'Code cannot be empty' }, { status: 400 });
    }
    updates.code = body.code;
  }

  if (typeof body.title === 'string') {
    updates.title = body.title.slice(0, MAX_TITLE_LENGTH).trim() || null;
  }

  if (typeof body.config === 'string') {
    if (body.config.length > MAX_CONFIG_LENGTH) {
      return json(
        { message: `Config exceeds max length (${MAX_CONFIG_LENGTH} chars)` },
        { status: 400 }
      );
    }
    updates.config = body.config;
  }

  if (typeof body.visibility === 'string') {
    if (!VALID_VISIBILITY.includes(body.visibility as never)) {
      return json(
        { message: `Invalid visibility. Must be: ${VALID_VISIBILITY.join(', ')}` },
        { status: 400 }
      );
    }
    updates.visibility = body.visibility;
  }

  if (typeof body.description === 'string') {
    updates.description = body.description.slice(0, MAX_DESCRIPTION_LENGTH).trim() || null;
  }

  if (Array.isArray(body.tags)) {
    const tags = body.tags
      .filter((t: unknown): t is string => typeof t === 'string')
      .map((t: string) => t.trim().toLowerCase().slice(0, MAX_TAG_LENGTH))
      .filter((t: string) => t.length > 0)
      .slice(0, MAX_TAGS);
    updates.tags = JSON.stringify(tags);
  }

  if (typeof body.starred === 'boolean') {
    updates.starred = body.starred;
  }

  if (typeof body.thumbnail === 'string') {
    if (body.thumbnail.length > MAX_THUMBNAIL_LENGTH) {
      return json(
        { message: `Thumbnail exceeds max length (${MAX_THUMBNAIL_LENGTH} chars)` },
        { status: 400 }
      );
    }
    updates.thumbnail = body.thumbnail;
  }

  // Validate folderId ownership — prevents IDOR
  if (body.folderId === null) {
    updates.folderId = null;
  } else if (typeof body.folderId === 'string') {
    const folder = await db.query.folders.findFirst({
      where: eq(folders.id, body.folderId)
    });
    if (!folder || folder.userId !== locals.user.id) {
      return json({ message: 'Folder not found' }, { status: 404 });
    }
    updates.folderId = body.folderId;
  }

  const [updated] = await db
    .update(diagrams)
    .set(updates)
    .where(eq(diagrams.id, params.id))
    .returning();

  // ─── Auto-commit on code/config changes (non-blocking) ──────────────────
  if (updates.code !== undefined || updates.config !== undefined) {
    try {
      // Ensure "main" branch exists
      let activeBranchId = updated.activeBranchId;
      if (!activeBranchId) {
        const mainBranch = await db.query.diagramBranches.findFirst({
          where: and(eq(diagramBranches.diagramId, params.id), eq(diagramBranches.name, 'main'))
        });
        if (mainBranch) {
          activeBranchId = mainBranch.id;
        } else {
          const branchId = generateId();
          const now = new Date();
          await db.insert(diagramBranches).values({
            createdAt: now,
            createdBy: locals.user.id,
            diagramId: params.id,
            id: branchId,
            name: 'main',
            updatedAt: now
          });
          activeBranchId = branchId;
          // Set as active branch
          await db
            .update(diagrams)
            .set({ activeBranchId: branchId })
            .where(eq(diagrams.id, params.id));
        }
      }

      // Get current HEAD to set as parent
      const [head] = await db
        .select()
        .from(diagramCommits)
        .where(eq(diagramCommits.branchId, activeBranchId))
        .orderBy(desc(diagramCommits.createdAt))
        .limit(1);

      const commitId = generateId();
      const commitNow = new Date();

      await db.insert(diagramCommits).values({
        branchId: activeBranchId,
        code: updated.code,
        committedBy: locals.user.id,
        config: updated.config,
        createdAt: commitNow,
        id: commitId,
        message: 'Auto-save',
        parentCommitId: head?.id ?? null
      });

      // Update branch updatedAt
      await db
        .update(diagramBranches)
        .set({ updatedAt: commitNow })
        .where(eq(diagramBranches.id, activeBranchId));
    } catch (err) {
      console.error('[auto-commit] Failed to create auto-commit for diagram', params.id, err);
    }
  }

  return json(updated);
};

/**
 * DELETE /api/diagrams/:id — Delete a diagram (owner only)
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

  await db.delete(diagrams).where(eq(diagrams.id, params.id));

  return json({ deleted: true });
};
