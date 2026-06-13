import { db } from '$lib/server/db';
import {
  diagrams,
  users,
  diagramShares,
  diagramForks,
  orgMembers,
  projectDiagrams,
  projects
} from '$lib/server/db/schema';
import { eq, and } from 'drizzle-orm';
import { error, redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

async function checkShareAccess(diagramId: string, userId: string): Promise<boolean> {
  const directShare = await db.query.diagramShares?.findFirst({
    where: and(eq(diagramShares.diagramId, diagramId), eq(diagramShares.sharedWithUserId, userId))
  });
  if (directShare) return true;

  const userOrgs = await db
    .select({ orgId: orgMembers.orgId })
    .from(orgMembers)
    .where(eq(orgMembers.userId, userId));

  for (const { orgId } of userOrgs) {
    const orgShare = await db.query.diagramShares?.findFirst({
      where: and(eq(diagramShares.diagramId, diagramId), eq(diagramShares.sharedWithOrgId, orgId))
    });
    if (orgShare) return true;
  }

  return false;
}

export const load: PageServerLoad = async ({ params, locals, url }) => {
  const diagram = await db.query.diagrams.findFirst({
    where: eq(diagrams.id, params.id)
  });

  if (!diagram) {
    error(404, 'Diagram not found');
  }

  // Access control: private requires auth + ownership or share access
  if (diagram.visibility === 'private') {
    if (!locals.user) {
      redirect(302, `/auth/login?redirect=${encodeURIComponent(url.pathname)}`);
    }
    if (diagram.userId !== locals.user.id) {
      const hasAccess = await checkShareAccess(diagram.id, locals.user.id);
      if (!hasAccess) {
        error(404, 'Diagram not found');
      }
    }
  }

  // Fetch author info
  let author: { name: string | null; handle: string | null } | null = null;
  if (diagram.userId) {
    const user = await db.query.users.findFirst({
      where: eq(users.id, diagram.userId),
      columns: { name: true, handle: true }
    });
    author = user ?? null;
  }

  // Fetch projects this diagram belongs to
  let diagramProjects: { id: string; name: string }[] = [];
  try {
    const pds = await db
      .select({
        projectId: projectDiagrams.projectId,
        projectName: projects.name
      })
      .from(projectDiagrams)
      .innerJoin(projects, eq(projectDiagrams.projectId, projects.id))
      .where(eq(projectDiagrams.diagramId, diagram.id));
    diagramProjects = pds.map((p) => ({
      id: p.projectId,
      name: p.projectName
    }));
  } catch {
    // Projects table may not exist yet during migration
  }

  // Parse tags — jsonb column, should already be an array
  let tags: string[] = [];
  if (diagram.tags) {
    if (Array.isArray(diagram.tags)) {
      tags = diagram.tags as string[];
    } else if (typeof diagram.tags === 'string') {
      try {
        tags = JSON.parse(diagram.tags);
      } catch {
        // Invalid JSON — ignore
      }
    }
  }

  const isOwner = locals.user?.id === diagram.userId;

  // Check if this diagram is a fork of another diagram
  let isFork = false;
  let sourceDiagramId: string | null = null;
  try {
    const forkRecord = await db.query.diagramForks?.findFirst({
      where: eq(diagramForks.forkedDiagramId, diagram.id)
    });
    if (forkRecord?.sourceDiagramId) {
      isFork = true;
      sourceDiagramId = forkRecord.sourceDiagramId;
    }
  } catch {
    // diagramForks table may not exist yet during migration
  }

  return {
    author,
    diagram: {
      code: diagram.code,
      config: diagram.config,
      createdAt: diagram.createdAt.toISOString(),
      description: diagram.description ?? null,
      id: diagram.id,
      tags,
      title: diagram.title,
      updatedAt: diagram.updatedAt.toISOString(),
      visibility: diagram.visibility
    },
    isFork,
    isOwner,
    projects: diagramProjects,
    sourceDiagramId,
    userId: locals.user?.id ?? null
  };
};
