"use client";

import { Suspense, useState, useEffect } from "react";
import { useAuth } from "@/context/auth";
import { useRouter, useSearchParams } from "next/navigation";
import { api } from "@/lib/api";
import Link from "next/link";
import { AuthCard } from "@/components/auth-card";
import { rememberAuthRedirect, safePostLoginPath } from "@/lib/auth-redirect";

type LoginMode = "password" | "magic-link" | "otp";

const SSO_LABELS: Record<string, string> = {
  oidc: "Sign in with SSO",
  google: "Sign in with Google",
  github: "Sign in with GitHub",
  facebook: "Sign in with Facebook",
  linkedin: "Sign in with LinkedIn",
  saml: "Sign in with SAML",
};

const SSO_PATHS: Record<string, string> = {
  oidc: "/auth/oidc",
  google: "/auth/google",
  github: "/auth/github",
  facebook: "/auth/facebook",
  linkedin: "/auth/linkedin",
  saml: "/sso/saml/auth/signin",
};

export default function LoginPage() {
  return (
    <Suspense fallback={<p>Loading…</p>}>
      <LoginForm />
    </Suspense>
  );
}

function LoginForm() {
  const { user, loading: authLoading, login, requestMagicLink, requestOtpLogin, verifyOtpLogin } = useAuth();
  const router = useRouter();
  const searchParams = useSearchParams();
  const nextPath = safePostLoginPath(searchParams.get("redirect") || searchParams.get("next"));
  const [mode, setMode] = useState<LoginMode>("password");
  const [ssoProviders, setSsoProviders] = useState<string[]>(["oidc"]);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [otpCode, setOtpCode] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [magicLinkSent, setMagicLinkSent] = useState(false);
  const [otpSent, setOtpSent] = useState(false);
  const [devLink, setDevLink] = useState<string | null>(null);
  const [devCode, setDevCode] = useState<string | null>(null);

  useEffect(() => {
    rememberAuthRedirect(nextPath);
  }, [nextPath]);

  useEffect(() => {
    if (!authLoading && user) router.replace(nextPath);
  }, [authLoading, user, router, nextPath]);

  useEffect(() => {
    // Authentik is the only IdP. Always offer SSO even if the providers
    // fetch fails (wrong baked API URL used to hide the only working button).
    api
      .ssoProviders()
      .then((res) => {
        const list = res.providers?.length ? res.providers : ["oidc"];
        setSsoProviders(list.includes("oidc") ? list : ["oidc", ...list]);
      })
      .catch(() => setSsoProviders(["oidc"]));
  }, []);

  async function handlePasswordSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      await login(email, password);
      router.push(nextPath);
    } catch {
      setError("Invalid email or password");
    } finally {
      setLoading(false);
    }
  }

  async function handleMagicLinkSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      const res = await requestMagicLink(email);
      setMagicLinkSent(true);
      if (res.dev_link) setDevLink(res.dev_link);
    } catch {
      setError("Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  async function handleOtpRequest(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      const res = await requestOtpLogin(email);
      setOtpSent(true);
      if (res.dev_code) setDevCode(res.dev_code);
    } catch {
      setError("Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  async function handleOtpVerify(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      await verifyOtpLogin(email, otpCode);
      router.push(nextPath);
    } catch {
      setError("Invalid or expired code");
    } finally {
      setLoading(false);
    }
  }

  function switchMode(newMode: LoginMode) {
    setMode(newMode);
    setError("");
    setMagicLinkSent(false);
    setOtpSent(false);
    setDevLink(null);
    setDevCode(null);
    setOtpCode("");
  }

  const modeLinks = (
    <div style={{ marginTop: "1rem" }}>
      {mode !== "password" && (
        <p><a href="#" data-cy="auth-mode-password" onClick={(e) => { e.preventDefault(); switchMode("password"); }}>Sign in with password</a></p>
      )}
      {mode !== "magic-link" && (
        <p><a href="#" data-cy="auth-mode-magic-link" onClick={(e) => { e.preventDefault(); switchMode("magic-link"); }}>Sign in with magic link</a></p>
      )}
      {mode !== "otp" && (
        <p><a href="#" data-cy="auth-mode-otp" onClick={(e) => { e.preventDefault(); switchMode("otp"); }}>Sign in with email code</a></p>
      )}
      <p><Link href="/forgot-password" data-cy="forgot-password-link">Forgot password?</Link></p>
      <p>Don&apos;t have an account? <Link href="/#pricing" data-cy="signup-link">Get early access</Link></p>
    </div>
  );

  if (authLoading || user) {
    return <p>Loading…</p>;
  }

  return (
    <AuthCard title="Sign in to your locker" cyId="login" error={error}>
        {ssoProviders.length > 0 && (
          <div style={{ marginBottom: "2rem" }} data-cy="sso-provider-list">
            {ssoProviders.map((provider) => (
              <a
                key={provider}
                href={SSO_PATHS[provider] || `/auth/${provider}`}
                className="sg-btn sg-btn--black"
                data-cy="sso-provider-link"
                data-cy-id={provider}
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

        {mode === "password" && (
          <form onSubmit={handlePasswordSubmit} data-cy="auth-form" data-cy-id="password">
            <div className="sg-field">
              <label htmlFor="email">Email</label>
              <input id="email" data-cy="email-input" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
            </div>
            <div className="sg-field">
              <label htmlFor="password">Password</label>
              <input id="password" data-cy="password-input" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required autoComplete="current-password" />
            </div>
            <button type="submit" className="sg-btn sg-btn--black" data-cy="submit-login" disabled={loading}>
              {loading ? "Logging in..." : "Log In"}
            </button>
            {modeLinks}
          </form>
        )}

        {mode === "magic-link" && !magicLinkSent && (
          <form onSubmit={handleMagicLinkSubmit} data-cy="auth-form" data-cy-id="magic-link">
            <p>Enter your email and we&apos;ll send you a sign-in link.</p>
            <div className="sg-field">
              <label htmlFor="magic-email">Email</label>
              <input id="magic-email" data-cy="email-input" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
            </div>
            <button type="submit" className="sg-btn sg-btn--black" data-cy="submit-magic-link" disabled={loading}>
              {loading ? "Sending..." : "Send Magic Link"}
            </button>
            {modeLinks}
          </form>
        )}

        {mode === "magic-link" && magicLinkSent && (
          <div data-cy="magic-link-sent">
            <p>Check your email for a magic link to sign in.</p>
            {devLink && (
              <p style={{ marginTop: "1rem", padding: "0.75rem", background: "var(--surface-alt, #f5f5f5)", borderRadius: "4px" }}>
                <strong>Dev mode:</strong> <a href={devLink}>Click here to verify</a>
              </p>
            )}
            {modeLinks}
          </div>
        )}

        {mode === "otp" && !otpSent && (
          <form onSubmit={handleOtpRequest} data-cy="auth-form" data-cy-id="otp-request">
            <p>Enter your email and we&apos;ll send you a login code.</p>
            <div className="sg-field">
              <label htmlFor="otp-email">Email</label>
              <input id="otp-email" data-cy="email-input" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
            </div>
            <button type="submit" className="sg-btn sg-btn--black" data-cy="submit-otp-request" disabled={loading}>
              {loading ? "Sending..." : "Send Login Code"}
            </button>
            {modeLinks}
          </form>
        )}

        {mode === "otp" && otpSent && (
          <form onSubmit={handleOtpVerify} data-cy="auth-form" data-cy-id="otp-verify">
            <p>Enter the 6-digit code sent to {email}.</p>
            {devCode && (
              <p style={{ marginBottom: "1rem", padding: "0.75rem", background: "var(--surface-alt, #f5f5f5)", borderRadius: "4px" }}>
                <strong>Dev mode:</strong> {devCode}
              </p>
            )}
            <div className="sg-field">
              <label htmlFor="otp-code">Code</label>
              <input
                id="otp-code"
                data-cy="otp-code-input"
                type="text"
                inputMode="numeric"
                pattern="[0-9]*"
                maxLength={6}
                value={otpCode}
                onChange={(e) => setOtpCode(e.target.value.replace(/\D/g, ""))}
                required
                autoComplete="one-time-code"
                style={{ letterSpacing: "0.5em", fontSize: "1.5rem", textAlign: "center" }}
              />
            </div>
            <button type="submit" className="sg-btn sg-btn--black" data-cy="submit-otp-verify" disabled={loading || otpCode.length !== 6}>
              {loading ? "Verifying..." : "Verify Code"}
            </button>
            {modeLinks}
          </form>
        )}
    </AuthCard>
  );
}
