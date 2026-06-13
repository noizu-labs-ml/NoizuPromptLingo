"use client";

import { useState, useEffect } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Card, FormField, TextInput, Button, toast } from "@/components/ui";

export default function SignupPage() {
  const { register } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (process.env.NEXT_PUBLIC_DEMO_MODE === 'true') {
      router.push('/app');
    }
  }, [router]);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [inviteToken, setInviteToken] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    if (!inviteToken.trim()) {
      const msg = "Invite token is required";
      setError(msg);
      toast.error(msg);
      return;
    }

    setLoading(true);

    try {
      await register(email, password, inviteToken);
      toast.success("Account created");
      router.push("/app");
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Registration failed";
      setError(msg);
      toast.error(msg);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div
      className="auth-card-wrap"
      data-cy="auth-card-wrap"
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "calc(100vh - 80px)",
        padding: "2rem 1rem",
      }}
    >
      <Card
        className="sg-card--auth"
        data-cy="auth-card"
        data-cy-id="signup"
        style={{ width: "100%", maxWidth: 420, padding: "2rem" }}
      >
        <h1
          className="sg-page-header__title"
          data-cy="auth-title"
          style={{ marginTop: 0, marginBottom: "1.5rem" }}
        >
          Sign Up
        </h1>

        {error && (
          <p className="sg-error" data-cy="auth-error" role="alert">
            {error}
          </p>
        )}

        <form onSubmit={handleSubmit} data-cy="auth-form" data-cy-id="signup">
          <FormField label="Invite token" name="invite_token" required>
            {(p) => (
              <TextInput
                {...p}
                type="text"
                value={inviteToken}
                onChange={(e) => setInviteToken(e.target.value)}
                autoComplete="off"
                placeholder="ct_..."
                data-cy="invite-token-input"
                error={!!error && !inviteToken.trim()}
              />
            )}
          </FormField>

          <FormField label="Email" name="email" required>
            {(p) => (
              <TextInput
                {...p}
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                autoComplete="email"
                placeholder="you@example.com"
                data-cy="auth-email-input"
                error={!!error && !!inviteToken.trim()}
              />
            )}
          </FormField>

          <FormField
            label="Password"
            name="password"
            hint="At least 8 characters"
            required
          >
            {(p) => (
              <TextInput
                {...p}
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                minLength={8}
                autoComplete="new-password"
                data-cy="auth-password-input"
                error={!!error && !!inviteToken.trim()}
              />
            )}
          </FormField>

          <Button
            type="submit"
            variant="primary"
            loading={loading}
            cy="auth-submit"
            cyValue={loading ? "loading" : "ready"}
            style={{ width: "100%", marginTop: "0.5rem" }}
          >
            {loading ? "Creating account..." : "Sign Up"}
          </Button>
        </form>

        <div style={{ marginTop: "1rem" }}>
          <p>
            Already have an account?{" "}
            <Link href="/login" data-cy="auth-login-link">
              Log in
            </Link>
          </p>
        </div>
      </Card>
    </div>
  );
}
