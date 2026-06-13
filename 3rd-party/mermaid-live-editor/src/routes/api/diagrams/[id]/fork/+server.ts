import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams, diagramForks } from '$lib/server/db/schema';
import { generateDiagramId, generateId } from '$lib/server/id';
import { eq } from 'drizzle-orm';
import type { RequestHandler } from './$types';
import type { ForkResponse } from '$lib/types/api';

/**
 * POST /api/diagrams/:id/fork — Fork a diagram
 *
 * Auth required. Source diagram must be public, unlisted, or owned by the user.
 * Creates a new private diagram (copy of code/config/title with "Fork of" prefix)
 * and a diagramForks record linking source to fork.
 */
export const POST: RequestHandler = async ({ params, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  // Fetch source diagram
  const source = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, params.id)
  });

  if (!source) {
    return json({ message: 'Diagram not found' }, { status: 404 });
  }

  // Access check: must be public, unlisted, or owned by the user
  if (source.visibility === 'private' && source.userId !== locals.user.id) {
    return json({ message: 'Diagram not found' }, { status: 404 });
  }

  const forkId = generateDiagramId();
  const forkRecordId = generateId();
  const now = new Date();

  const forkTitle = source.title ? `Fork of ${source.title}` : 'Fork of untitled diagram';

  // Create the forked diagram (private, owned by the current user)
  const [forkedDiagram] = await db
    .insert(diagrams)
    .values({
      code: source.code,
      config: source.config,
      createdAt: now,
      id: forkId,
      title: forkTitle,
      updatedAt: now,
      userId: locals.user.id,
      visibility: 'private'
    })
    .returning();

  // Create the fork record linking source to fork
  const [forkRecord] = await db
    .insert(diagramForks)
    .values({
      createdAt: now,
      forkedBy: locals.user.id,
      forkedDiagramId: forkId,
      id: forkRecordId,
      sourceDiagramId: source.id
    })
    .returning();

  const response: ForkResponse = {
    fork: {
      code: forkedDiagram.code,
      config: forkedDiagram.config,
      createdAt: forkedDiagram.createdAt.toISOString(),
      id: forkedDiagram.id,
      title: forkedDiagram.title,
      visibility: forkedDiagram.visibility
    },
    forkRecord: {
      forkedBy: forkRecord.forkedBy ?? '',
      forkedDiagramId: forkRecord.forkedDiagramId,
      id: forkRecord.id,
      sourceDiagramId: forkRecord.sourceDiagramId
    }
  };

  return json(response, { status: 201 });
};
