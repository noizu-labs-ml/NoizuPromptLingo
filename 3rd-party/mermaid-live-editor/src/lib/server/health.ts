// =============================================================================
// Health Check Logic — shared by /healthz and /readyz
// =============================================================================
//
// Helm probe updates for Derek (deployment.yaml):
//
//   livenessProbe:
//     httpGet:
//       path: /healthz
//       port: 8080
//     initialDelaySeconds: 15    # healthz is instant — no reason to wait 30s
//     periodSeconds: 30
//     timeoutSeconds: 3          # no I/O, sub-ms response — 5s is overkill
//     failureThreshold: 3
//
//   readinessProbe:
//     httpGet:
//       path: /readyz
//       port: 8080
//     initialDelaySeconds: 5     # DB check is fast, start probing early
//     periodSeconds: 10
//     timeoutSeconds: 5
//     failureThreshold: 2
//
// =============================================================================
import { sql } from 'drizzle-orm';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface CheckResult {
  status: 'ok' | 'fail';
  latency_ms?: number;
  error?: string;
}

export interface ReadinessReport {
  status: 'ready' | 'not_ready';
  checks: {
    postgres: CheckResult;
  };
}

export interface LivenessReport {
  status: 'ok';
  uptime: number;
}

// ---------------------------------------------------------------------------
// Uptime tracking (module-level — set once when the module first loads)
// ---------------------------------------------------------------------------

const startTime = Date.now();

export function getUptimeSeconds(): number {
  return Math.floor((Date.now() - startTime) / 1000);
}

// ---------------------------------------------------------------------------
// Postgres connectivity check
// ---------------------------------------------------------------------------
// Uses dynamic import so that a missing DATABASE_URL surfaces as a failed
// check rather than crashing the module (the db proxy throws on first access
// when the env var is absent). This also keeps healthz independent — if the
// db module fails to load, /healthz still works because it never imports it.
// ---------------------------------------------------------------------------

export async function checkPostgres(): Promise<CheckResult> {
  try {
    const { db } = await import('$lib/server/db');

    const start = performance.now();
    await db.execute(sql`SELECT 1`);
    const latency_ms = Math.round(performance.now() - start);

    return { status: 'ok', latency_ms };
  } catch (err) {
    return {
      status: 'fail',
      error: err instanceof Error ? err.message : 'Unknown database error'
    };
  }
}

// ---------------------------------------------------------------------------
// Aggregate readiness (add future checks here — e.g. Redis, external APIs)
// ---------------------------------------------------------------------------

export async function checkReadiness(): Promise<ReadinessReport> {
  const postgres = await checkPostgres();

  const allOk = postgres.status === 'ok';

  return {
    status: allOk ? 'ready' : 'not_ready',
    checks: {
      postgres
    }
  };
}
