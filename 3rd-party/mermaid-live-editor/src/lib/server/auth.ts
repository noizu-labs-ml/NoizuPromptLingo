import { betterAuth } from 'better-auth';
import { drizzleAdapter } from 'better-auth/adapters/drizzle';
import { genericOAuth } from 'better-auth/plugins';
import { db } from './db';

function createAuth() {
  return betterAuth({
    baseURL: process.env.ORIGIN ?? 'https://mermaid.noizu.com',
    database: drizzleAdapter(db, { provider: 'pg' }),
    emailAndPassword: {
      enabled: false
    },
    plugins: [
      genericOAuth({
        config: [
          {
            clientId: process.env.AUTHENTIK_CLIENT_ID ?? '',
            clientSecret: process.env.AUTHENTIK_CLIENT_SECRET ?? '',
            discoveryUrl:
              (process.env.AUTHENTIK_ISSUER_URL ?? 'https://auth.noizu.com/application/o/mermaid') +
              '/.well-known/openid-configuration',
            pkce: true,
            providerId: 'authentik',
            scopes: ['openid', 'email', 'profile']
          }
        ]
      })
    ],
    secret: process.env.BETTER_AUTH_SECRET,
    session: {
      cookieCache: {
        enabled: true,
        maxAge: 300
      },
      expiresIn: 60 * 60 * 24 * 7,
      updateAge: 60 * 60 * 24
    },
    trustedOrigins: [process.env.ORIGIN ?? 'https://mermaid.noizu.com'],
    user: {
      additionalFields: {
        handle: {
          required: false,
          type: 'string'
        }
      }
    }
  });
}

let _auth: ReturnType<typeof createAuth>;

export function getAuth() {
  if (!_auth) {
    _auth = createAuth();
  }
  return _auth;
}

export const auth = new Proxy({} as ReturnType<typeof createAuth>, {
  get(_, prop) {
    return getAuth()[prop as keyof ReturnType<typeof createAuth>];
  }
});

export type Session = Awaited<
  ReturnType<ReturnType<typeof createAuth>['api']['getSession']>
>['session'];
export type User = Awaited<ReturnType<ReturnType<typeof createAuth>['api']['getSession']>>['user'];
