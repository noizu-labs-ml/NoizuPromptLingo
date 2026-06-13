import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { projects, projectDiagrams, diagrams } from '$lib/server/db/schema';
import { eq, asc } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const MAX_NAME_LENGTH = 200;
const MAX_DESCRIPTION_LENGTH = 2_000;
const VALID_VISIBILITY = ['private', 'unlisted', 'public'] as const;

/**
 * GET /api/projects/:id — Fetch a project with its diagrams
 *
 * Access rules:
 *  - public/unlisted: anyone can read
 *  - private: owner only
 */
export const GET: RequestHandler = async ({ params, locals }) => {
  const project = await db.query.projects.findFirst({
    where: eq(projects.id, params.id)
  });

  if (!project) {
    return json({ message: 'Project not found' }, { status: 404 });
  }

  // Access control
  if (project.visibility === 'private') {
    if (!locals.user || project.ownerId !== locals.user.id) {
      return json({ message: 'Project not found' }, { status: 404 });
    }
  }

  // Fetch associated diagrams via join — lightweight projection (no code/config/thumbnail)
  const diagramRows = await db
    .select({
      addedAt: projectDiagrams.addedAt,
      diagramId: projectDiagrams.diagramId,
      id: projectDiagrams.id,
      position: projectDiagrams.position,
      title: diagrams.title,
      updatedAt: diagrams.updatedAt,
      visibility: diagrams.visibility
    })
    .from(projectDiagrams)
    .innerJoin(diagrams, eq(diagrams.id, projectDiagrams.diagramId))
    .where(eq(projectDiagrams.projectId, params.id))
    .orderBy(asc(projectDiagrams.position), asc(projectDiagrams.addedAt));

  return json({ ...project, diagrams: diagramRows });
};

/**
 * PATCH /api/projects/:id — Update a project (owner only)
 */
export const PATCH: RequestHandler = async ({ params, request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const project = await db.query.projects.findFirst({
    where: eq(projects.id, params.id)
  });

  if (!project) {
    return json({ message: 'Project not found' }, { status: 404 });
  }

  if (project.ownerId !== locals.user.id) {
    return json({ message: 'Not authorized' }, { status: 403 });
  }

  const body = await request.json().catch(() => null);
  if (!body || typeof body !== 'object') {
    return json({ message: 'Invalid request body' }, { status: 400 });
  }

  const updates: Record<string, unknown> = { updatedAt: new Date() };

  if (typeof body.name === 'string') {
    const name = body.name.slice(0, MAX_NAME_LENGTH).trim();
    if (!name) {
      return json({ message: 'Name cannot be empty' }, { status: 400 });
    }
    updates.name = name;
  }

  if (typeof body.description === 'string') {
    updates.description = body.description.slice(0, MAX_DESCRIPTION_LENGTH).trim() || null;
  }

  if (body.description === null) {
    updates.description = null;
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

  const [updated] = await db
    .update(projects)
    .set(updates)
    .where(eq(projects.id, params.id))
    .returning();

  return json(updated);
};

/**
 * DELETE /api/projects/:id — Delete a project (owner only)
 *
 * Deletes the project and all project_diagrams join rows.
 * Does NOT delete the diagrams themselves — they remain in the user's library.
 */
export const DELETE: RequestHandler = async ({ params, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  const project = await db.query.projects.findFirst({
    where: eq(projects.id, params.id)
  });

  if (!project) {
    return json({ message: 'Project not found' }, { status: 404 });
  }

  if (project.ownerId !== locals.user.id) {
    return json({ message: 'Not authorized' }, { status: 403 });
  }

  // CASCADE on project_diagrams handles join-row cleanup
  await db.delete(projects).where(eq(projects.id, params.id));

  return json({ deleted: true });
};
