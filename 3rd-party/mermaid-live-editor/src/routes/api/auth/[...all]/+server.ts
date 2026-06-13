import { json } from '@sveltejs/kit';
import { auth } from '$lib/server/auth';
import type { RequestHandler } from './$types';

const handler: RequestHandler = async ({ request, params }) => {
  if (params.all === 'sign-up/email' && request.method === 'POST') {
    return json(
      { message: 'Signup requires an invite token. Use /api/auth/signup instead.' },
      { status: 403 }
    );
  }
  return auth.handler(request);
};

export const GET = handler;
export const POST = handler;
