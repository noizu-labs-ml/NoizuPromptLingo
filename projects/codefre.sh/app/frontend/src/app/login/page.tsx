"use client";

import { useState, useEffect } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Card, FormField, TextInput, Button, toast } from "@/components/ui";

export default function LoginPage() {
  const { login } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (process.env.NEXT_PUBLIC_DEMO_MODE === 'true') {
      router.push('/app');
    }
  }, [router]);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      await login(email, password);
      toast.success("Logged in");
      router.push("/app");
    } catch {
      const msg = "Invalid email or password";
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
        data-cy-id="login"
        style={{ width: "100%", maxWidth: 420, padding: "2rem" }}
      >
        <h1
          className="sg-page-header__title"
          data-cy="auth-title"
          style={{ marginTop: 0, marginBottom: "1.5rem" }}
        >
          Log In
        </h1>

        {error && (
          <p className="sg-error" data-cy="auth-error" role="alert">
            {error}
          </p>
        )}

        <form onSubmit={handleSubmit} data-cy="auth-form" data-cy-id="login">
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
                error={!!error}
              />
            )}
          </FormField>

          <FormField label="Password" name="password" required>
            {(p) => (
              <TextInput
                {...p}
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="current-password"
                data-cy="auth-password-input"
                error={!!error}
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
            {loading ? "Logging in..." : "Log In"}
          </Button>
        </form>

        <div style={{ marginTop: "1rem" }}>
          <p>
            Don&apos;t have an account?{" "}
            <Link href="/signup" data-cy="auth-signup-link">
              Sign up
            </Link>
          </p>
        </div>
      </Card>
    </div>
  );
}
