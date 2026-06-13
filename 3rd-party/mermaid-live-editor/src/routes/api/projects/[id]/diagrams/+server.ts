import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { projects, projectDiagrams, diagrams } from '$lib/server/db/schema';
import { generateId, generateDiagramId } from '$lib/server/id';
import { eq, sql } from 'drizzle-orm';
import type { RequestHandler } from './$types';

/**
 * POST /api/projects/:id/diagrams — Add a diagram to a project
 *
 * Body:
 *  - diagramId: string (required) — the source diagram
 *  - mode: 'linked' | 'clone' (default: 'linked')
 *
 * 'linked' creates a reference to the existing diagram.
 * 'clone' copies the diagram's code/config/title into a new diagram owned by the user,
 *  then links the clone to the project.
 */
export const POST: RequestHandler = async ({ params, request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  // Validate project ownership
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
  if (!body || typeof body.diagramId !== 'string' || !body.diagramId.trim()) {
    return json({ message: 'Missing or empty "diagramId" field' }, { status: 400 });
  }

  const mode = body.mode === 'clone' ? 'clone' : 'linked';

  // Validate source diagram exists and user has access
  const sourceDiagram = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, body.diagramId)
  });

  if (!sourceDiagram) {
    return json({ message: 'Diagram not found' }, { status: 404 });
  }

  // For linked mode, user must own the diagram (no linking to others' private diagrams)
  // For clone mode, the diagram must be accessible (public/unlisted or owned)
  if (mode === 'linked') {
    if (sourceDiagram.userId !== locals.user.id) {
      return json({ message: 'Can only link your own diagrams' }, { status: 403 });
    }
  } else {
    // Clone: allow if public/unlisted, or owned
    if (sourceDiagram.visibility === 'private' && sourceDiagram.userId !== locals.user.id) {
      return json({ message: 'Diagram not found' }, { status: 404 });
    }
  }

  let targetDiagramId = body.diagramId;

  if (mode === 'clone') {
    // Create a copy of the diagram owned by the current user
    const cloneId = generateDiagramId();
    const now = new Date();

    await db.insert(diagrams).values({
      code: sourceDiagram.code,
      config: sourceDiagram.config,
      createdAt: now,
      description: sourceDiagram.description,
      id: cloneId,
      tags: sourceDiagram.tags,
      title: sourceDiagram.title ? `${sourceDiagram.title} (copy)` : null,
      updatedAt: now,
      userId: locals.user.id,
      visibility: 'private'
    });

    targetDiagramId = cloneId;
  }

  // Determine next position
  const [maxPos] = await db
    .select({ max: sql<number>`coalesce(max(${projectDiagrams.position}), -1)` })
    .from(projectDiagrams)
    .where(eq(projectDiagrams.projectId, params.id));

  const position = (maxPos?.max ?? -1) + 1;

  // Check for duplicate (linked mode — same diagram already in project)
  if (mode === 'linked') {
    const [dup] = await db
      .select({ id: projectDiagrams.id })
      .from(projectDiagrams)
      .where(
        sql`${projectDiagrams.projectId} = ${params.id} AND ${projectDiagrams.diagramId} = ${targetDiagramId}`
      )
      .limit(1);

    if (dup) {
      return json({ message: 'Diagram already in project' }, { status: 409 });
    }
  }

  const id = generateId();

  const [row] = await db
    .insert(projectDiagrams)
    .values({
      addedAt: new Date(),
      diagramId: targetDiagramId,
      id,
      position,
      projectId: params.id
    })
    .returning();

  // Touch project updatedAt
  await db.update(projects).set({ updatedAt: new Date() }).where(eq(projects.id, params.id));

  return json(row, { status: 201 });
};
