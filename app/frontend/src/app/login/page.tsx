"use client";

import { useState, useEffect } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import Link from "next/link";

const SSO_LABELS: Record<string, string> = {
  oidc: "Sign in with derobot.is",
  google: "Sign in with Google",
  github: "Sign in with GitHub",
  saml: "Sign in with SAML",
};

const SSO_PATHS: Record<string, string> = {
  oidc: "/auth/oidc",
  google: "/auth/google",
  github: "/auth/github",
  saml: "/sso/saml/auth/signin",
};

export default function LoginPage() {
  const { login } = useAuth();
  const router = useRouter();
  const [ssoProviders, setSsoProviders] = useState<string[]>([]);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    api.ssoProviders().then((res) => setSsoProviders(res.providers)).catch(() => {});
  }, []);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      await login(email, password);
      router.push("/");
    } catch {
      setError("Invalid email or password");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Log In</h1>

        {ssoProviders.length > 0 && (
          <div style={{ maxWidth: 400, marginBottom: "2rem" }}>
            {ssoProviders.map((provider) => (
              <a
                key={provider}
                href={SSO_PATHS[provider] || `/auth/${provider}`}
                className="sg-btn sg-btn--primary"
                style={{ display: "block", textAlign: "center", marginBottom: "0.5rem" }}
              >
                {SSO_LABELS[provider] || `Sign in with ${provider}`}
              </a>
            ))}
            <div style={{ display: "flex", alignItems: "center", gap: "1rem", margin: "1.5rem 0" }}>
              <hr style={{ flex: 1 }} />
              <span style={{ color: "var(--text-muted, #888)", fontSize: "0.875rem" }}>or</span>
              <hr style={{ flex: 1 }} />
            </div>
          </div>
        )}

        <form onSubmit={handleSubmit} style={{ maxWidth: 400 }}>
          {error && <p className="sg-error">{error}</p>}
          <div className="sg-field">
            <label htmlFor="email">Email</label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoComplete="email"
            />
          </div>
          <div className="sg-field">
            <label htmlFor="password">Password</label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              autoComplete="current-password"
            />
          </div>
          <button type="submit" className="sg-btn sg-btn--primary" disabled={loading}>
            {loading ? "Logging in..." : "Log In"}
          </button>
          <p style={{ marginTop: "1rem" }}>
            Don&apos;t have an account? <Link href="/signup">Sign up</Link>
          </p>
        </form>
      </main>
    </div>
  );
}
