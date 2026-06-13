import { db } from '$lib/server/db';
import { diagrams, diagramPullRequests, users } from '$lib/server/db/schema';
import { eq } from 'drizzle-orm';
import { error, redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import type { PullRequestSummary } from '$lib/types/api';

export const load: PageServerLoad = async ({ params, locals, url }) => {
  const diagram = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, params.id)
  });

  if (!diagram) {
    error(404, 'Diagram not found');
  }

  // Only the diagram owner can view PRs
  if (!locals.user) {
    redirect(302, `/auth/login?redirect=${encodeURIComponent(url.pathname)}`);
  }
  if (diagram.userId !== locals.user.id) {
    error(403, 'Only the diagram owner can view pull requests');
  }

  // Fetch all PRs targeting this diagram
  const pullRequests: PullRequestSummary[] = [];
  try {
    const rows = await db
      .select({
        createdAt: diagramPullRequests.createdAt,
        createdBy: diagramPullRequests.createdBy,
        id: diagramPullRequests.id,
        status: diagramPullRequests.status,
        title: diagramPullRequests.title
      })
      .from(diagramPullRequests)
      .where(eq(diagramPullRequests.targetDiagramId, params.id))
      .orderBy(diagramPullRequests.createdAt);

    // Resolve author names
    for (const row of rows) {
      let authorName: string | null = null;
      let authorHandle: string | null = null;
      if (row.createdBy) {
        const author = await db.query.users.findFirst({
          where: eq(users.id, row.createdBy),
          columns: { name: true, handle: true }
        });
        if (author) {
          authorName = author.name;
          authorHandle = author.handle;
        }
      }
      pullRequests.push({
        authorHandle,
        authorName,
        createdAt: row.createdAt.toISOString(),
        id: row.id,
        status: row.status as 'open' | 'merged' | 'closed',
        title: row.title
      });
    }
  } catch {
    // Table may not exist yet
  }

  return {
    diagram: {
      id: diagram.id,
      title: diagram.title
    },
    pullRequests
  };
};
