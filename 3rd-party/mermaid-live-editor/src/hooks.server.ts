import { randomUUID } from 'node:crypto';
import { auth } from '$lib/server/auth';
import { installConsoleJsonLogger, logger, parseTraceparent } from '$lib/server/logger';
import type { Handle, HandleServerError } from '@sveltejs/kit';

installConsoleJsonLogger();

const HEALTH_PATHS = new Set(['/healthz', '/readyz']);

function requestIdFor(headers: Headers): string {
  return headers.get('x-request-id') ?? headers.get('cf-ray') ?? randomUUID();
}

export const handle: Handle = async ({ event, resolve }) => {
  const startedAt = Date.now();
  const requestId = requestIdFor(event.request.headers);
  const trace = parseTraceparent(event.request.headers.get('traceparent'));
  const path = event.url.pathname;

  event.locals.requestId = requestId;

  let status = 500;
  let error: unknown;

  try {
    const session = await auth.api.getSession({
      headers: event.request.headers
    });

    event.locals.session = session?.session ?? null;
    event.locals.user = session?.user ?? null;

    const response = await resolve(event);
    status = response.status;
    try {
      response.headers.set('x-request-id', requestId);
    } catch {
      logger.debug('Response headers are immutable', {
        event: 'response_header_immutable',
        request_id: requestId
      });
    }

    return response;
  } catch (caughtError) {
    error = caughtError;
    throw caughtError;
  } finally {
    if (!HEALTH_PATHS.has(path) || process.env.LOG_HEALTHCHECKS === 'true') {
      const durationMs = Date.now() - startedAt;
      const level = error || status >= 500 ? 'error' : status >= 400 ? 'warn' : 'info';

      logger[level](`${event.request.method} ${path} ${status}`, {
        ...trace,
        authenticated: Boolean(event.locals.user),
        duration_ms: durationMs,
        error,
        event: 'http_request',
        method: event.request.method,
        path,
        request_id: requestId,
        route: event.route.id,
        status,
        user_id: event.locals.user?.id
      });
    }
  }
};

export const handleError: HandleServerError = ({ error, event, message, status }) => {
  logger.error(message, {
    error,
    event: 'sveltekit_error',
    method: event.request.method,
    path: event.url.pathname,
    request_id: event.locals.requestId,
    route: event.route.id,
    status
  });

  return {
    message,
    requestId: event.locals.requestId
  };
};
