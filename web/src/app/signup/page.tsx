"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { GoogleReCaptchaProvider, useGoogleReCaptcha } from "react-google-recaptcha-v3";
import { SiteHeader, SiteFooter } from "../components/site-shell";
import { useAuth } from "@/context/auth";
import { cyAttrs } from "@/lib/cy-attrs";

const RECAPTCHA_KEY = process.env.NEXT_PUBLIC_RECAPTCHA_SITE_KEY ?? "";

export default function SignupPage() {
  if (!RECAPTCHA_KEY) return <SignupFormInner />;
  return (
    <GoogleReCaptchaProvider reCaptchaKey={RECAPTCHA_KEY}>
      <SignupFormWithCaptcha />
    </GoogleReCaptchaProvider>
  );
}

function SignupFormWithCaptcha() {
  const { executeRecaptcha } = useGoogleReCaptcha();
  return <SignupFormInner executeRecaptcha={executeRecaptcha} />;
}

function SignupFormInner({
  executeRecaptcha,
}: {
  executeRecaptcha?: ((action?: string) => Promise<string>) | null;
} = {}) {
  const { user, loading, register } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const honeypotRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (!loading && user) router.replace("/create-character");
  }, [loading, user, router]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (honeypotRef.current?.value) return;

    setError("");

    if (password !== confirm) {
      setError("Passwords do not match");
      return;
    }

    if (password.length < 8) {
      setError("Password must be at least 8 characters");
      return;
    }

    setSubmitting(true);
    try {
      if (executeRecaptcha) {
        await executeRecaptcha("signup");
      }

      await register({ email, password });
      router.push("/create-character");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Registration failed");
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
          {...cyAttrs({ cy: "signup-form", cyScope: "signup" })}
        >
          <h1
            className="mb-6 text-center text-2xl tracking-wide"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold)" }}
          >
            Create Account
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
                {...cyAttrs({ cy: "email-input", cyId: "signup-email" })}
                className="w-full rounded border px-3 py-2 text-sm outline-none transition-colors focus:border-[var(--gold)]"
                style={{
                  background: "var(--bg-elevated)",
                  borderColor: "var(--metal-mid)",
                  color: "var(--text-primary)",
                }}
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
                autoComplete="new-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                {...cyAttrs({ cy: "password-input", cyId: "signup-password" })}
                className="w-full rounded border px-3 py-2 text-sm outline-none transition-colors focus:border-[var(--gold)]"
                style={{
                  background: "var(--bg-elevated)",
                  borderColor: "var(--metal-mid)",
                  color: "var(--text-primary)",
                }}
              />
            </div>

            <div>
              <label
                htmlFor="confirm"
                className="mb-1 block text-sm"
                style={{ color: "var(--text-secondary)" }}
              >
                Confirm Password
              </label>
              <input
                id="confirm"
                type="password"
                required
                autoComplete="new-password"
                value={confirm}
                onChange={(e) => setConfirm(e.target.value)}
                {...cyAttrs({ cy: "confirm-input", cyId: "signup-confirm" })}
                className="w-full rounded border px-3 py-2 text-sm outline-none transition-colors focus:border-[var(--gold)]"
                style={{
                  background: "var(--bg-elevated)",
                  borderColor: "var(--metal-mid)",
                  color: "var(--text-primary)",
                }}
              />
            </div>

            {/* Honeypot */}
            <div aria-hidden="true" style={{ position: "absolute", left: "-9999px", opacity: 0, height: 0, overflow: "hidden" }}>
              <label htmlFor="website">Website</label>
              <input id="website" type="text" name="website" tabIndex={-1} autoComplete="off" ref={honeypotRef} {...cyAttrs({ cy: "honeypot" })} />
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
              {...cyAttrs({ cy: "submit-button", cyId: "signup" })}
            >
              {submitting ? "Creating account..." : "Create Account"}
            </button>
          </form>

          <p className="mt-6 text-center text-sm" style={{ color: "var(--text-muted)" }}>
            Already have an account?{" "}
            <a
              href="/login"
              className="transition-colors hover:text-[var(--gold)]"
              style={{ color: "var(--gold-light)" }}
              {...cyAttrs({ cy: "login-link" })}
            >
              Sign in
            </a>
          </p>
        </div>
      </main>

      <SiteFooter />
    </div>
  );
}
