import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { db } from '$lib/server/db';
import { inviteTokens } from '$lib/server/db/schema';
import { eq, sql } from 'drizzle-orm';
import { auth } from '$lib/server/auth';

export const POST: RequestHandler = async ({ request }) => {
  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return json({ message: 'Invalid JSON body' }, { status: 400 });
  }

  const { email, password, name, inviteToken } = body as {
    email?: string;
    password?: string;
    name?: string | null;
    inviteToken?: string;
  };

  if (!email || !password || !inviteToken) {
    return json({ message: 'Email, password, and invite token are required' }, { status: 400 });
  }

  const rows = await db
    .select()
    .from(inviteTokens)
    .where(eq(inviteTokens.token, inviteToken))
    .limit(1);
  const token = rows[0];

  if (!token) {
    return json({ message: 'Invalid invite token' }, { status: 403 });
  }

  if (token.expiresAt && token.expiresAt < new Date()) {
    return json({ message: 'Invite token has expired' }, { status: 403 });
  }

  if (token.useCount >= token.maxUses) {
    return json({ message: 'Invite token has been fully used' }, { status: 403 });
  }

  let result: unknown;
  try {
    result = await auth.api.signUpEmail({
      body: {
        email,
        password,
        name: name || email.split('@')[0]
      }
    });
  } catch (e: unknown) {
    const msg =
      (e as { body?: { message?: string } })?.body?.message ||
      (e as Error)?.message ||
      'Signup failed';
    const code =
      (e as { status?: number; statusCode?: number })?.status ||
      (e as { status?: number; statusCode?: number })?.statusCode ||
      500;
    return json({ message: msg }, { status: code });
  }

  await db
    .update(inviteTokens)
    .set({
      useCount: sql`use_count + 1`,
      usedAt: new Date()
    })
    .where(eq(inviteTokens.id, token.id));

  const typedResult = result as Record<string, unknown> & { user?: unknown; token?: string };
  return json({ success: true, user: typedResult.user, token: typedResult.token });
};
