// =============================================================================
// Liveness Probe — GET /healthz
// =============================================================================
// Pure in-process check. Returns 200 if the Node process is responsive.
// MUST NOT check external dependencies (DB, auth, etc.) — a liveness probe
// that fails on a downstream outage will restart the pod, turning a transient
// issue into a cascading failure. Readiness handles dependency checks.
// =============================================================================
import { json } from '@sveltejs/kit';
import { getUptimeSeconds } from '$lib/server/health';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async () => {
  return json(
    {
      status: 'ok',
      uptime: getUptimeSeconds()
    },
    {
      status: 200,
      headers: { 'Cache-Control': 'no-store' }
    }
  );
};
