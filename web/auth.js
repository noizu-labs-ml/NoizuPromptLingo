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
        const res = await fetch(`${backendUrl}/api/auth/sync`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            sub: profile.sub,
            email: profile.email || user.email,
            name: profile.name || user.name,
          }),
        });
        if (res.ok) {
          const data = await res.json();
          user.backendId = data.id;
          user.profileComplete = data.profile_complete;
        }
      } catch (e) {
        console.error("Failed to sync user to backend:", e);
      }
      return true;
    },
    async jwt({ token, profile, user }) {
      if (profile) {
        token.oidc_sub = profile.sub;
      }
      if (user?.backendId) {
        token.backendId = user.backendId;
        token.profileComplete = user.profileComplete;
      }
      return token;
    },
    async session({ session, token }) {
      session.user.oidc_sub = token.oidc_sub;
      session.user.backendId = token.backendId;
      session.user.profileComplete = token.profileComplete;
      return session;
    },
    authorized({ auth }) {
      return !!auth;
    },
  },
});
