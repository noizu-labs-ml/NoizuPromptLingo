import { json } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import { users } from '$lib/server/db/schema';
import { eq } from 'drizzle-orm';
import type { RequestHandler } from './$types';

const HANDLE_PATTERN = /^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$/;

export const POST: RequestHandler = async ({ request, locals }) => {
  if (!locals.user) {
    return json({ message: 'Not authenticated' }, { status: 401 });
  }

  const body = await request.json();
  const handle = String(body.handle ?? '')
    .toLowerCase()
    .trim();

  if (!HANDLE_PATTERN.test(handle)) {
    return json(
      {
        message:
          'Handle must be 3-30 characters: lowercase letters, numbers, and hyphens. Must start and end with a letter or number.'
      },
      { status: 400 }
    );
  }

  const existing = await db.query.users.findFirst({
    where: eq(users.handle, handle)
  });

  if (existing && existing.id !== locals.user.id) {
    return json({ message: 'Handle is already taken' }, { status: 409 });
  }

  await db.update(users).set({ handle, updatedAt: new Date() }).where(eq(users.id, locals.user.id));

  return json({ handle });
};
