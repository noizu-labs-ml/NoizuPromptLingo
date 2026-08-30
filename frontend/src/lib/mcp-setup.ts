/**
 * Env var name for the MCP bearer token in generated setup snippets.
 *
 * Org-scoped so a user wiring multiple orgs (or a personal + org setup) does
 * not have colliding `AUTH_TOKEN` exports in one shell. Falls back to the
 * historical name when no org slug is resolvable.
 */
export const DEFAULT_MCP_AUTH_ENV_VAR = 'TOBOR_LOCKER_AUTH_TOKEN';

export function mcpAuthEnvVar(slug?: string | null): string {
  if (!slug) return DEFAULT_MCP_AUTH_ENV_VAR;
  return `${slug.replace(/[^a-zA-Z0-9]+/g, '_').toUpperCase()}_AUTH_TOKEN`;
}
