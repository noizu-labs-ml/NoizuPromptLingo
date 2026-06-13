import { db } from '$lib/server/db';
import { diagrams, diagramPullRequests, users } from '$lib/server/db/schema';
import { eq, and } from 'drizzle-orm';
import { error, redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params, locals, url }) => {
  const diagram = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, params.id)
  });

  if (!diagram) {
    error(404, 'Diagram not found');
  }

  // Only the diagram owner can view PR details
  if (!locals.user) {
    redirect(302, `/auth/login?redirect=${encodeURIComponent(url.pathname)}`);
  }
  if (diagram.userId !== locals.user.id) {
    error(403, 'Only the diagram owner can view pull request details');
  }

  // Fetch the specific PR
  const pr = await db.query.diagramPullRequests?.findFirst({
    where: and(
      eq(diagramPullRequests.id, params.prId),
      eq(diagramPullRequests.targetDiagramId, params.id)
    )
  });

  if (!pr) {
    error(404, 'Pull request not found');
  }

  // Resolve author info
  let authorName: string | null = null;
  let authorHandle: string | null = null;
  if (pr.createdBy) {
    const author = await db.query.users.findFirst({
      where: eq(users.id, pr.createdBy),
      columns: { name: true, handle: true }
    });
    if (author) {
      authorName = author.name;
      authorHandle = author.handle;
    }
  }

  // Fetch source diagram code for diff (the fork's current code)
  let sourceCode = '';
  if (pr.sourceDiagramId) {
    const sourceDiagram = await db.query.diagrams.findFirst({
      where: eq(diagrams.id, pr.sourceDiagramId),
      columns: { code: true }
    });
    sourceCode = sourceDiagram?.code ?? '';
  }

  return {
    diagram: {
      id: diagram.id,
      title: diagram.title,
      code: diagram.code
    },
    pullRequest: {
      authorHandle,
      authorName,
      closedAt: pr.closedAt?.toISOString() ?? null,
      createdAt: pr.createdAt.toISOString(),
      description: pr.description,
      id: pr.id,
      sourceDiagramId: pr.sourceDiagramId,
      status: pr.status as 'open' | 'merged' | 'closed',
      targetDiagramId: pr.targetDiagramId,
      title: pr.title,
      updatedAt: pr.updatedAt.toISOString()
    },
    sourceCode,
    targetCode: diagram.code
  };
};
