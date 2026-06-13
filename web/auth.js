import NextAuth from "next-auth";

const backendUrl = process.env.BACKEND_URL || "http://localhost:4040";

export const { handlers, signIn, signOut, auth } = NextAuth({
  providers: [
    {
      id: "authentik",
      name: "Authentik",
      type: "oidc",
      issuer: process.env.AUTHENTIK_ISSUER,
      clientId: process.env.AUTHENTIK_CLIENT_ID,
      clientSecret: process.env.AUTHENTIK_CLIENT_SECRET,
    },
  ],
  callbacks: {
    async signIn({ user, profile }) {
      try {
        await fetch(`${backendUrl}/api/auth/sync`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            sub: profile.sub,
            email: profile.email || user.email,
            name: profile.name || user.name,
          }),
        });
      } catch (e) {
        console.error("Failed to sync user to backend:", e);
      }
      return true;
    },
    async jwt({ token, profile }) {
      if (profile) {
        token.oidc_sub = profile.sub;
      }
      return token;
    },
    async session({ session, token }) {
      session.user.oidc_sub = token.oidc_sub;
      return session;
    },
    authorized({ auth }) {
      return !!auth;
    },
  },
});
