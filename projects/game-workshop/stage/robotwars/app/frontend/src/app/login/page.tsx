"use client";

import { useState, useEffect } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import Link from "next/link";

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
  const { login, requestMagicLink, requestOtpLogin, verifyOtpLogin } = useAuth();
  const router = useRouter();
  const [mode, setMode] = useState<LoginMode>("password");
  const [ssoProviders, setSsoProviders] = useState<string[]>([]);
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
    api.ssoProviders().then((res) => setSsoProviders(res.providers)).catch(() => {});
  }, []);

  async function handlePasswordSubmit(e: React.FormEvent) {
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
      router.push("/");
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
        <p><a href="#" onClick={(e) => { e.preventDefault(); switchMode("password"); }}>Sign in with password</a></p>
      )}
      {mode !== "magic-link" && (
        <p><a href="#" onClick={(e) => { e.preventDefault(); switchMode("magic-link"); }}>Sign in with magic link</a></p>
      )}
      {mode !== "otp" && (
        <p><a href="#" onClick={(e) => { e.preventDefault(); switchMode("otp"); }}>Sign in with email code</a></p>
      )}
      <p><Link href="/forgot-password">Forgot password?</Link></p>
      <p>Don&apos;t have an account? <Link href="/signup">Sign up</Link></p>
    </div>
  );

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
                className="sg-btn sg-btn--black"
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
          <form onSubmit={handlePasswordSubmit} style={{ maxWidth: 400 }}>
            {error && <p className="sg-error">{error}</p>}
            <div className="sg-field">
              <label htmlFor="email">Email</label>
              <input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
            </div>
            <div className="sg-field">
              <label htmlFor="password">Password</label>
              <input id="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required autoComplete="current-password" />
            </div>
            <button type="submit" className="sg-btn sg-btn--black" disabled={loading}>
              {loading ? "Logging in..." : "Log In"}
            </button>
            {modeLinks}
          </form>
        )}

        {mode === "magic-link" && !magicLinkSent && (
          <form onSubmit={handleMagicLinkSubmit} style={{ maxWidth: 400 }}>
            {error && <p className="sg-error">{error}</p>}
            <p>Enter your email and we&apos;ll send you a sign-in link.</p>
            <div className="sg-field">
              <label htmlFor="magic-email">Email</label>
              <input id="magic-email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
            </div>
            <button type="submit" className="sg-btn sg-btn--black" disabled={loading}>
              {loading ? "Sending..." : "Send Magic Link"}
            </button>
            {modeLinks}
          </form>
        )}

        {mode === "magic-link" && magicLinkSent && (
          <div style={{ maxWidth: 400 }}>
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
          <form onSubmit={handleOtpRequest} style={{ maxWidth: 400 }}>
            {error && <p className="sg-error">{error}</p>}
            <p>Enter your email and we&apos;ll send you a login code.</p>
            <div className="sg-field">
              <label htmlFor="otp-email">Email</label>
              <input id="otp-email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
            </div>
            <button type="submit" className="sg-btn sg-btn--black" disabled={loading}>
              {loading ? "Sending..." : "Send Login Code"}
            </button>
            {modeLinks}
          </form>
        )}

        {mode === "otp" && otpSent && (
          <form onSubmit={handleOtpVerify} style={{ maxWidth: 400 }}>
            {error && <p className="sg-error">{error}</p>}
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
            <button type="submit" className="sg-btn sg-btn--black" disabled={loading || otpCode.length !== 6}>
              {loading ? "Verifying..." : "Verify Code"}
            </button>
            {modeLinks}
          </form>
        )}
      </main>
    </div>
  );
}
