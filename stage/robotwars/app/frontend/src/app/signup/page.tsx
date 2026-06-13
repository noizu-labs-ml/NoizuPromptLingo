"use client";

import { useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import Link from "next/link";

export default function SignupPage() {
  const { register } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [inviteToken, setInviteToken] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      await register(email, password, inviteToken);
      router.push("/");
    } catch (err: unknown) {
      if (err instanceof Error) {
        setError(err.message);
      } else {
        setError("Registration failed");
      }
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Sign Up</h1>
        <form onSubmit={handleSubmit} style={{ maxWidth: 400 }}>
          {error && <p className="sg-error">{error}</p>}
          <div className="sg-field">
            <label htmlFor="invite-token">Invite Token</label>
            <input
              id="invite-token"
              type="text"
              value={inviteToken}
              onChange={(e) => setInviteToken(e.target.value)}
              required
              autoComplete="off"
            />
          </div>
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
              minLength={8}
              autoComplete="new-password"
            />
          </div>
          <button type="submit" className="sg-btn sg-btn--black" disabled={loading}>
            {loading ? "Creating account..." : "Sign Up"}
          </button>
          <p style={{ marginTop: "1rem" }}>
            Already have an account? <Link href="/login">Log in</Link>
          </p>
        </form>
      </main>
    </div>
  );
}
