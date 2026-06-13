"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { SiteHeader, SiteFooter } from "../components/site-shell";
import { useAuth } from "@/context/auth";
import { cyAttrs } from "@/lib/cy-attrs";

export default function LoginPage() {
  const { user, loading, login } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!loading && user) router.replace("/game");
  }, [loading, user, router]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setSubmitting(true);
    try {
      await login(email, password);
      router.push("/game");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Login failed");
    } finally {
      setSubmitting(false);
    }
  }

  if (loading || user) return null;

  return (
    <div className="min-h-screen" style={{ background: "#070707" }}>
      <SiteHeader />

      <main className="mx-auto flex w-full max-w-[1000px] flex-col items-center px-4 py-20">
        <div
          className="w-full max-w-[400px] rounded-lg border border-white/10 p-8"
          style={{ background: "var(--bg-surface)" }}
          {...cyAttrs({ cy: "login-form", cyScope: "login" })}
        >
          <h1
            className="mb-6 text-center text-2xl tracking-wide"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold)" }}
          >
            Login
          </h1>

          {error && (
            <div
              className="mb-4 rounded border px-3 py-2 text-sm"
              style={{
                borderColor: "var(--red)",
                background: "rgba(205,92,92,0.1)",
                color: "var(--red)",
              }}
              role="alert"
              {...cyAttrs({ cy: "error-alert" })}
            >
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label
                htmlFor="email"
                className="mb-1 block text-sm"
                style={{ color: "var(--text-secondary)" }}
              >
                Email
              </label>
              <input
                id="email"
                type="email"
                required
                autoComplete="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full rounded border px-3 py-2 text-sm outline-none transition-colors focus:border-[var(--gold)]"
                style={{
                  background: "var(--bg-elevated)",
                  borderColor: "var(--metal-mid)",
                  color: "var(--text-primary)",
                }}
                {...cyAttrs({ cy: "email-input", cyId: "login-email" })}
              />
            </div>

            <div>
              <label
                htmlFor="password"
                className="mb-1 block text-sm"
                style={{ color: "var(--text-secondary)" }}
              >
                Password
              </label>
              <input
                id="password"
                type="password"
                required
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full rounded border px-3 py-2 text-sm outline-none transition-colors focus:border-[var(--gold)]"
                style={{
                  background: "var(--bg-elevated)",
                  borderColor: "var(--metal-mid)",
                  color: "var(--text-primary)",
                }}
                {...cyAttrs({ cy: "password-input", cyId: "login-password" })}
              />
            </div>

            <div className="flex items-center justify-between">
              <label className="flex items-center gap-2 text-sm" style={{ color: "var(--text-secondary)" }}>
                <input
                  type="checkbox"
                  className="rounded"
                  style={{ accentColor: "var(--gold)" }}
                  {...cyAttrs({ cy: "remember-me" })}
                />
                Remember me
              </label>
              <a
                href="#"
                className="text-sm transition-colors hover:text-[var(--gold)]"
                style={{ color: "var(--text-muted)" }}
                {...cyAttrs({ cy: "forgot-password" })}
              >
                Forgot password?
              </a>
            </div>

            <button
              type="submit"
              disabled={submitting}
              className="w-full rounded py-2.5 text-sm font-semibold tracking-wide transition-colors disabled:opacity-50"
              style={{
                fontFamily: "var(--font-heading)",
                background: "var(--gold)",
                color: "#070707",
              }}
              {...cyAttrs({ cy: "submit-button", cyId: "login" })}
            >
              {submitting ? "Signing in..." : "Sign In"}
            </button>
          </form>

          <p className="mt-6 text-center text-sm" style={{ color: "var(--text-muted)" }}>
            Don&rsquo;t have an account?{" "}
            <a
              href="/signup"
              className="transition-colors hover:text-[var(--gold)]"
              style={{ color: "var(--gold-light)" }}
              {...cyAttrs({ cy: "signup-link" })}
            >
              Create one
            </a>
          </p>
        </div>
      </main>

      <SiteFooter />
    </div>
  );
}
