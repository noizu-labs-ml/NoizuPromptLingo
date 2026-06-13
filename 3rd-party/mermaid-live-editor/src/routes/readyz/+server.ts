// =============================================================================
// Readiness Probe — GET /readyz
// =============================================================================
// Returns 200 only when the service can handle traffic. Checks external
// dependencies that must be available for requests to succeed.
//
// On failure: returns 503 with the failing check identified. Kubernetes
// removes the pod from the Service (no traffic routed) without killing it —
// the pod stays alive and re-enters the pool once dependencies recover.
// =============================================================================
import { json } from '@sveltejs/kit';
import { checkReadiness } from '$lib/server/health';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async () => {
  const report = await checkReadiness();

  return json(report, {
    status: report.status === 'ready' ? 200 : 503,
    headers: { 'Cache-Control': 'no-store' }
  });
};
