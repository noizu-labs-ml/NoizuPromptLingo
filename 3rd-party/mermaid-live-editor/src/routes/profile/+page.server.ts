import { redirect } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { organizations, orgMembers, diagrams } from '$lib/server/db/schema';
import { eq, count, sql } from 'drizzle-orm';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  if (!locals.user) {
    throw redirect(302, '/auth/login?redirect=/profile');
  }

  // Fetch user's organizations with role
  const orgs = await db
    .select({
      createdAt: organizations.createdAt,
      id: organizations.id,
      name: organizations.name,
      role: orgMembers.role,
      slug: organizations.slug
    })
    .from(orgMembers)
    .innerJoin(organizations, eq(orgMembers.orgId, organizations.id))
    .where(eq(orgMembers.userId, locals.user.id))
    .orderBy(organizations.name);

  // Diagram stats
  const [stats] = await db
    .select({
      totalDiagrams: count(diagrams.id),
      publicDiagrams: count(sql`CASE WHEN ${diagrams.visibility} = 'public' THEN 1 END`),
      starredDiagrams: count(sql`CASE WHEN ${diagrams.starred} = true THEN 1 END`)
    })
    .from(diagrams)
    .where(eq(diagrams.userId, locals.user.id));

  return {
    user: {
      createdAt: locals.user.createdAt,
      email: locals.user.email,
      handle: locals.user.handle,
      id: locals.user.id,
      image: locals.user.image,
      name: locals.user.name
    },
    organizations: orgs,
    stats: stats ?? { totalDiagrams: 0, publicDiagrams: 0, starredDiagrams: 0 }
  };
};
