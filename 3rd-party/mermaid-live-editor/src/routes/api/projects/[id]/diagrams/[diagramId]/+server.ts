import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { projects, projectDiagrams } from '$lib/server/db/schema';
import { eq, and } from 'drizzle-orm';
import type { RequestHandler } from './$types';

/**
 * DELETE /api/projects/:id/diagrams/:diagramId — Remove a diagram from a project
 *
 * Removes the project_diagrams join row. Does NOT delete the diagram itself.
 */
export const DELETE: RequestHandler = async ({ params, locals }) => {
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

  // Find and delete the join row
  const [deleted] = await db
    .delete(projectDiagrams)
    .where(
      and(eq(projectDiagrams.projectId, params.id), eq(projectDiagrams.diagramId, params.diagramId))
    )
    .returning();

  if (!deleted) {
    return json({ message: 'Diagram not found in project' }, { status: 404 });
  }

  // Touch project updatedAt
  await db.update(projects).set({ updatedAt: new Date() }).where(eq(projects.id, params.id));

  return json({ deleted: true });
};
