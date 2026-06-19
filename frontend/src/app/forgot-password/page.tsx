"use client";

import { useState } from "react";
import { api } from "@/lib/api";
import { useRouter } from "next/navigation";
import Link from "next/link";

type Step = "request" | "verify" | "done";

export default function ForgotPasswordPage() {
  const router = useRouter();
  const [step, setStep] = useState<Step>("request");
  const [email, setEmail] = useState("");
  const [code, setCode] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [devCode, setDevCode] = useState<string | null>(null);

  async function handleRequest(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      const res = await api.requestPasswordReset(email);
      if (res.dev_code) setDevCode(res.dev_code);
      setStep("verify");
    } catch {
      setError("Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  async function handleVerify(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    if (newPassword.length < 8) {
      setError("Password must be at least 8 characters");
      return;
    }
    if (newPassword !== confirmPassword) {
      setError("Passwords do not match");
      return;
    }

    setLoading(true);
    try {
      await api.verifyPasswordReset(email, code, newPassword);
      setStep("done");
    } catch {
      setError("Invalid or expired code");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Reset Password</h1>

        {step === "request" && (
          <form onSubmit={handleRequest} style={{ maxWidth: 400 }}>
            {error && <p className="sg-error">{error}</p>}
            <p>Enter your email and we&apos;ll send you a reset code.</p>
            <div className="sg-field">
              <label htmlFor="email">Email</label>
              <input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
            </div>
            <button type="submit" className="sg-btn sg-btn--black" disabled={loading}>
              {loading ? "Sending..." : "Send Reset Code"}
            </button>
            <p style={{ marginTop: "1rem" }}>
              <Link href="/login">Back to login</Link>
            </p>
          </form>
        )}

        {step === "verify" && (
          <form onSubmit={handleVerify} style={{ maxWidth: 400 }}>
            {error && <p className="sg-error">{error}</p>}
            <p>Enter the 6-digit code sent to {email} and your new password.</p>
            {devCode && (
              <p style={{ marginBottom: "1rem", padding: "0.75rem", background: "var(--surface-alt, #f5f5f5)", borderRadius: "4px" }}>
                <strong>Dev mode:</strong> {devCode}
              </p>
            )}
            <div className="sg-field">
              <label htmlFor="reset-code">Code</label>
              <input
                id="reset-code"
                type="text"
                inputMode="numeric"
                pattern="[0-9]*"
                maxLength={6}
                value={code}
                onChange={(e) => setCode(e.target.value.replace(/\D/g, ""))}
                required
                autoComplete="one-time-code"
                style={{ letterSpacing: "0.5em", fontSize: "1.5rem", textAlign: "center" }}
              />
            </div>
            <div className="sg-field">
              <label htmlFor="new-password">New Password</label>
              <input id="new-password" type="password" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} required autoComplete="new-password" minLength={8} />
            </div>
            <div className="sg-field">
              <label htmlFor="confirm-password">Confirm Password</label>
              <input id="confirm-password" type="password" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} required autoComplete="new-password" minLength={8} />
            </div>
            <button type="submit" className="sg-btn sg-btn--black" disabled={loading || code.length !== 6}>
              {loading ? "Resetting..." : "Reset Password"}
            </button>
            <p style={{ marginTop: "1rem" }}>
              <Link href="/login">Back to login</Link>
            </p>
          </form>
        )}

        {step === "done" && (
          <div style={{ maxWidth: 400 }}>
            <p>Your password has been reset.</p>
            <button className="sg-btn sg-btn--black" onClick={() => router.push("/login")} style={{ marginTop: "1rem" }}>
              Go to Login
            </button>
          </div>
        )}
      </main>
    </div>
  );
}
