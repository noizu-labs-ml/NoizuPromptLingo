import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams, diagramShares } from '$lib/server/db/schema';
import { eq, and } from 'drizzle-orm';
import type { RequestHandler } from './$types';

/**
 * DELETE /api/diagrams/:id/shares/:shareId — Revoke a share (diagram owner only)
 */
export const DELETE: RequestHandler = async ({ params, locals }) => {
  if (!locals.user) {
    return json({ message: 'Authentication required' }, { status: 401 });
  }

  // Verify diagram ownership
  const diagram = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, params.id)
  });
  if (!diagram) {
    return json({ message: 'Diagram not found' }, { status: 404 });
  }
  if (diagram.userId !== locals.user.id) {
    return json({ message: 'Not authorized' }, { status: 403 });
  }

  // Verify share exists and belongs to this diagram
  const share = await db.query.diagramShares.findFirst({
    where: and(eq(diagramShares.id, params.shareId), eq(diagramShares.diagramId, params.id))
  });
  if (!share) {
    return json({ message: 'Share not found' }, { status: 404 });
  }

  await db.delete(diagramShares).where(eq(diagramShares.id, params.shareId));

  return json({ revoked: true });
};
