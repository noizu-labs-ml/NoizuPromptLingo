import { betterAuth } from 'better-auth';
import { drizzleAdapter } from 'better-auth/adapters/drizzle';
import { magicLink, organization } from 'better-auth/plugins';
import { genericOAuth } from 'better-auth/plugins';
import { db } from './db';
import { users, accounts, sessions, verifications } from './db/schema';
import { sendEmail, verificationEmail, resetPasswordEmail, magicLinkEmail } from './email';

function baseURL(): string {
  return process.env.BETTER_AUTH_URL ?? process.env.ORIGIN ?? 'https://mermaid.noizu.com';
}

function createAuth() {
  if (!process.env.BETTER_AUTH_SECRET) {
    throw new Error('BETTER_AUTH_SECRET is not set. Cannot initialize authentication.');
  }
  return betterAuth({
    baseURL: baseURL(),
    database: drizzleAdapter(db, {
      provider: 'pg',
      schema: { user: users, account: accounts, session: sessions, verification: verifications }
    }),
    emailAndPassword: {
      enabled: true,
      sendResetPassword: async ({ user, url }) => {
        const email = resetPasswordEmail(url);
        await sendEmail({ to: user.email, ...email });
      }
    },
    emailVerification: {
      sendOnSignUp: true,
      sendVerificationEmail: async ({ user, url }) => {
        const email = verificationEmail(url);
        await sendEmail({ to: user.email, ...email });
      }
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
      }),
      magicLink({
        sendMagicLink: async ({ email, url }) => {
          const content = magicLinkEmail(url);
          await sendEmail({ to: email, ...content });
        },
        expiresIn: 600
      }),
      organization()
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
    trustedOrigins: [baseURL(), 'http://localhost:3000'],
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

type AuthResult = Awaited<ReturnType<ReturnType<typeof createAuth>['api']['getSession']>>;
type AuthData = NonNullable<AuthResult>;
export type Session = AuthData['session'];
export type User = AuthData['user'];
