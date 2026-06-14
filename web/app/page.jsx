import { auth } from "../auth";
import { redirect } from "next/navigation";
import Link from "next/link";

export default async function Home() {
  const session = await auth();

  if (session) {
    redirect("/dashboard");
  }

  return (
    <div style={{
      display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
      minHeight: "100vh", padding: 40, textAlign: "center",
      background: "var(--bg-0)", marginLeft: 0
    }}>
      <div style={{
        width: 64, height: 64, borderRadius: 16,
        background: "linear-gradient(135deg, #7c3aed, #a855f7)",
        display: "flex", alignItems: "center", justifyContent: "center",
        fontSize: 28, fontWeight: 700, marginBottom: 24
      }}>T</div>

      <h1 style={{ fontSize: 36, fontWeight: 700, letterSpacing: "-0.03em", marginBottom: 8 }}>
        Tobor Locker
      </h1>
      <p style={{ fontSize: 16, color: "var(--text-2)", maxWidth: 480, marginBottom: 32, lineHeight: 1.6 }}>
        MCP collaboration portal for managing sessions, tickets, assets, reviews, and agent workflows across distributed instances.
      </p>

      <Link
        href="/api/auth/signin"
        style={{
          display: "inline-flex", alignItems: "center", gap: 8,
          padding: "12px 32px", borderRadius: 8,
          background: "var(--accent)", color: "white",
          fontSize: 15, fontWeight: 600, textDecoration: "none",
          transition: "opacity 0.15s"
        }}
      >
        Sign in
      </Link>

      <div style={{ marginTop: 48, display: "flex", gap: 32, color: "var(--text-3)", fontSize: 13 }}>
        <span>120+ MCP tools</span>
        <span>9 domains</span>
        <span>Real-time collaboration</span>
      </div>
    </div>
  );
}
