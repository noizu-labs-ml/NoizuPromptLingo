import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams, folders } from '$lib/server/db/schema';
import { generateDiagramId } from '$lib/server/id';
import { eq, desc, and, ilike, sql } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const MAX_CODE_LENGTH = 500_000; // 500KB — generous for mermaid diagrams
const MAX_TITLE_LENGTH = 200;
const MAX_DESCRIPTION_LENGTH = 2_000;
const MAX_CONFIG_LENGTH = 50_000; // 50KB
const MAX_THUMBNAIL_LENGTH = 500_000; // 500KB
const MAX_TAGS = 20;
const MAX_TAG_LENGTH = 50;
const VALID_VISIBILITY = ['private', 'unlisted', 'public'] as const;

/** Escape LIKE/ILIKE special characters to prevent pattern injection */
function escapeLike(input: string): string {
  return input.replace(/[\\%_]/g, (ch) => `\\${ch}`);
}

/**
 * POST /api/diagrams — Create a new diagram
 */
export const POST: RequestHandler = async ({ request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const body = await request.json().catch(() => null);
  if (!body || typeof body.code !== 'string' || !body.code.trim()) {
    return json({ message: 'Missing or empty "code" field' }, { status: 400 });
  }

  if (body.code.length > MAX_CODE_LENGTH) {
    return json({ message: `Code exceeds max length (${MAX_CODE_LENGTH} chars)` }, { status: 400 });
  }

  const title =
    typeof body.title === 'string' ? body.title.slice(0, MAX_TITLE_LENGTH).trim() || null : null;

  const config = typeof body.config === 'string' ? body.config : null;
  if (config && config.length > MAX_CONFIG_LENGTH) {
    return json(
      { message: `Config exceeds max length (${MAX_CONFIG_LENGTH} chars)` },
      { status: 400 }
    );
  }

  const thumbnail = typeof body.thumbnail === 'string' ? body.thumbnail : null;
  if (thumbnail && thumbnail.length > MAX_THUMBNAIL_LENGTH) {
    return json(
      { message: `Thumbnail exceeds max length (${MAX_THUMBNAIL_LENGTH} chars)` },
      { status: 400 }
    );
  }

  const visibility =
    typeof body.visibility === 'string' && VALID_VISIBILITY.includes(body.visibility as never)
      ? (body.visibility as (typeof VALID_VISIBILITY)[number])
      : 'private';

  const description =
    typeof body.description === 'string'
      ? body.description.slice(0, MAX_DESCRIPTION_LENGTH).trim() || null
      : null;

  // Validate and normalize tags — lowercase, trimmed, deduplicated
  let tags: string[] = [];
  if (Array.isArray(body.tags)) {
    const normalizedTags = body.tags
      .filter((t: unknown): t is string => typeof t === 'string')
      .map((t: string) => t.trim().toLowerCase().slice(0, MAX_TAG_LENGTH))
      .filter((t: string) => t.length > 0);

    tags = [...new Set<string>(normalizedTags)].slice(0, MAX_TAGS);
  }

  // Validate folderId ownership — prevents IDOR
  const folderIdInput = typeof body.folderId === 'string' ? body.folderId.trim() : null;
  const folderId = folderIdInput || null;
  if (folderId) {
    const folder = await db.query.folders.findFirst({
      where: eq(folders.id, folderId)
    });
    if (!folder || folder.userId !== locals.user.id) {
      return json({ message: 'Folder not found' }, { status: 404 });
    }
  }

  const id = generateDiagramId();
  const now = new Date();

  const [diagram] = await db
    .insert(diagrams)
    .values({
      code: body.code,
      config,
      createdAt: now,
      description,
      folderId,
      id,
      tags,
      thumbnail,
      title,
      updatedAt: now,
      userId: locals.user.id,
      visibility
    })
    .returning();

  return json(diagram, { status: 201 });
};

/**
 * GET /api/diagrams — List the authenticated user's diagrams
 *
 * Returns lightweight listing (no code/config/thumbnail) for performance.
 * Search is restricted to title only (avoids ilike on 500KB code columns).
 */
export const GET: RequestHandler = async ({ url, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const page = Math.max(1, Number(url.searchParams.get('page')) || 1);
  const limit = Math.min(100, Math.max(1, Number(url.searchParams.get('limit')) || 20));
  const offset = (page - 1) * limit;

  const folder = url.searchParams.get('folder');
  const starred = url.searchParams.get('starred');
  const q = url.searchParams.get('q');
  const tag = url.searchParams.get('tag');
  const projectId = url.searchParams.get('project');

  const conditions = [eq(diagrams.userId, locals.user.id)];

  if (folder) {
    conditions.push(eq(diagrams.folderId, folder));
  } else if (folder === '') {
    // Explicit empty string = root (no folder)
    conditions.push(sql`${diagrams.folderId} IS NULL`);
  }

  if (starred === 'true') {
    conditions.push(eq(diagrams.starred, true));
  }

  if (q) {
    // Escape LIKE special chars to prevent pattern injection, search title only
    const escaped = escapeLike(q);
    conditions.push(ilike(diagrams.title, `%${escaped}%`));
  }

  // Tag filter — uses GIN index on jsonb tags column
  if (tag) {
    const normalizedTag = tag.trim().toLowerCase();
    conditions.push(sql`${diagrams.tags} @> ${JSON.stringify([normalizedTag])}::jsonb`);
  }

  // Project filter — join through project_diagrams
  if (projectId) {
    conditions.push(
      sql`${diagrams.id} IN (SELECT diagram_id FROM project_diagrams WHERE project_id = ${projectId})`
    );
  }

  const where = conditions.length === 1 ? conditions[0] : and(...conditions);

  // Column projection — exclude heavy fields (code, config, thumbnail)
  const rows = await db
    .select({
      createdAt: diagrams.createdAt,
      description: diagrams.description,
      folderId: diagrams.folderId,
      id: diagrams.id,
      starred: diagrams.starred,
      tags: diagrams.tags,
      title: diagrams.title,
      updatedAt: diagrams.updatedAt,
      userId: diagrams.userId,
      visibility: diagrams.visibility
    })
    .from(diagrams)
    .where(where)
    .orderBy(desc(diagrams.updatedAt))
    .limit(limit)
    .offset(offset);

  return json({ diagrams: rows, page, limit });
};
