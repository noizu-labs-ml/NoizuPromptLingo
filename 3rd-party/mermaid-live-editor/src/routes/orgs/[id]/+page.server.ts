import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  if (!locals.user) {
    throw redirect(302, '/auth/login?redirect=/diagrams');
  }

  return {
    user: {
      id: locals.user.id,
      name: locals.user.name,
      handle: locals.user.handle
    }
  };
};
