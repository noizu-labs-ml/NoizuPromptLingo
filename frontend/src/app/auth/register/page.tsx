"use client";

import { Suspense, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter, useSearchParams } from "next/navigation";
import { api } from "@/lib/api";

function Register() {
  const { ssoRegister } = useAuth();
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = searchParams.get("token");

  const [email, setEmail] = useState("");
  const [first, setFirst] = useState("");
  const [last, setLast] = useState("");
  const [bio, setBio] = useState("");
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!token) return;
    api.getRegistration(token)
      .then((res) => setEmail(res.email))
      .catch(() => {});
  }, [token]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!token) return;
    setError("");
    setSubmitting(true);
    try {
      await ssoRegister({ token, first, last, bio });
      router.push("/");
    } catch {
      setError("Failed to complete registration. The link may have expired — please sign in again.");
      setSubmitting(false);
    }
  }

  if (!token) {
    return (
      <div className="content">
        <main>
          <h1 className="sg-page-title">Complete Registration</h1>
          <p className="sg-error">No registration token provided.</p>
          <p><a href="/auth/oidc">Start sign in again</a></p>
        </main>
      </div>
    );
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Complete Registration</h1>
        <p className="sg-page-intro">Finish setting up your account.</p>
        <form onSubmit={handleSubmit} style={{ maxWidth: 400 }}>
          {error && (
            <>
              <p className="sg-error">{error}</p>
              <p><a href="/auth/oidc">Sign in again</a></p>
            </>
          )}
          {email && (
            <div className="sg-field">
              <label htmlFor="email">Email</label>
              <input id="email" type="email" value={email} readOnly disabled />
            </div>
          )}
          <div className="sg-field">
            <label htmlFor="first">First name</label>
            <input id="first" type="text" value={first} onChange={(e) => setFirst(e.target.value)} required autoComplete="given-name" />
          </div>
          <div className="sg-field">
            <label htmlFor="last">Last name</label>
            <input id="last" type="text" value={last} onChange={(e) => setLast(e.target.value)} required autoComplete="family-name" />
          </div>
          <div className="sg-field">
            <label htmlFor="bio">Bio</label>
            <textarea id="bio" value={bio} onChange={(e) => setBio(e.target.value)} rows={4} />
          </div>
          <button type="submit" className="sg-btn sg-btn--black" disabled={submitting}>
            {submitting ? "Creating account..." : "Create Account"}
          </button>
        </form>
      </main>
    </div>
  );
}

export default function RegisterPage() {
  return (
    <Suspense fallback={<div className="content"><main><p>Loading...</p></main></div>}>
      <Register />
    </Suspense>
  );
}
