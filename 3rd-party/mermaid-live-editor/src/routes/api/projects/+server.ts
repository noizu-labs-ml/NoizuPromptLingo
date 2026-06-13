import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { projects, projectDiagrams } from '$lib/server/db/schema';
import { generateId } from '$lib/server/id';
import { eq, desc, sql } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const MAX_NAME_LENGTH = 200;
const MAX_DESCRIPTION_LENGTH = 2_000;
const VALID_VISIBILITY = ['private', 'unlisted', 'public'] as const;

/**
 * POST /api/projects — Create a new project
 */
export const POST: RequestHandler = async ({ request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const body = await request.json().catch(() => null);
  if (!body || typeof body.name !== 'string' || !body.name.trim()) {
    return json({ message: 'Missing or empty "name" field' }, { status: 400 });
  }

  const name = body.name.slice(0, MAX_NAME_LENGTH).trim();

  const description =
    typeof body.description === 'string'
      ? body.description.slice(0, MAX_DESCRIPTION_LENGTH).trim() || null
      : null;

  const visibility =
    typeof body.visibility === 'string' && VALID_VISIBILITY.includes(body.visibility as never)
      ? (body.visibility as (typeof VALID_VISIBILITY)[number])
      : 'private';

  const id = generateId();
  const now = new Date();

  const [project] = await db
    .insert(projects)
    .values({
      createdAt: now,
      description,
      id,
      name,
      ownerId: locals.user.id,
      updatedAt: now,
      visibility
    })
    .returning();

  return json(project, { status: 201 });
};

/**
 * GET /api/projects — List the authenticated user's projects with diagram counts
 */
export const GET: RequestHandler = async ({ url, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const page = Math.max(1, Number(url.searchParams.get('page')) || 1);
  const limit = Math.min(100, Math.max(1, Number(url.searchParams.get('limit')) || 20));
  const offset = (page - 1) * limit;

  const rows = await db
    .select({
      createdAt: projects.createdAt,
      description: projects.description,
      diagramCount: sql<number>`count(${projectDiagrams.id})::int`,
      id: projects.id,
      name: projects.name,
      ownerId: projects.ownerId,
      updatedAt: projects.updatedAt,
      visibility: projects.visibility
    })
    .from(projects)
    .leftJoin(projectDiagrams, eq(projectDiagrams.projectId, projects.id))
    .where(eq(projects.ownerId, locals.user.id))
    .groupBy(projects.id)
    .orderBy(desc(projects.updatedAt))
    .limit(limit)
    .offset(offset);

  return json({ projects: rows, page, limit });
};
