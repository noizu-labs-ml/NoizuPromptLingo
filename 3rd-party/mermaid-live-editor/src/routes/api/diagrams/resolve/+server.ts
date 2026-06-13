import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { diagrams } from '$lib/server/db/schema';
import { inArray } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const MAX_IDS = 50; // Cap to prevent abuse

/**
 * GET /api/diagrams/resolve?ids=id1,id2,id3 — Resolve diagram titles for link tooltips
 *
 * Returns a map of { id: title } for the requested diagram IDs.
 * Only returns titles for diagrams that are public, unlisted, or owned by the requester.
 * Private diagrams owned by others are omitted silently (no information leak).
 */
export const GET: RequestHandler = async ({ url, locals }) => {
  const idsParam = url.searchParams.get('ids');
  if (!idsParam) {
    return json({ message: 'Missing "ids" query parameter' }, { status: 400 });
  }

  const ids = idsParam
    .split(',')
    .map((id) => id.trim())
    .filter((id) => id.length > 0)
    .slice(0, MAX_IDS);

  if (ids.length === 0) {
    return json({ resolved: {} });
  }

  // Fetch all matching diagrams — lightweight projection
  const rows = await db
    .select({
      id: diagrams.id,
      title: diagrams.title,
      userId: diagrams.userId,
      visibility: diagrams.visibility
    })
    .from(diagrams)
    .where(inArray(diagrams.id, ids));

  // Filter: only return titles for diagrams the requester can see
  const resolved: Record<string, string | null> = {};
  for (const row of rows) {
    if (row.visibility === 'public' || row.visibility === 'unlisted') {
      resolved[row.id] = row.title;
    } else if (locals.user && row.userId === locals.user.id) {
      resolved[row.id] = row.title;
    }
    // Private diagrams owned by others: silently omit
  }

  return json({ resolved });
};
