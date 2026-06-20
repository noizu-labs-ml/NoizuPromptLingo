"use client";

// Explicit global error boundary. Beyond catching root-level render errors,
// providing this file works around a Next.js 15.5 RSC-bundler bug where the
// App Router fails to resolve its built-in global-error module in the client
// manifest ("Could not find the module .../builtin/global-error.js#").
export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <html lang="en">
      <body
        style={{
          margin: 0,
          minHeight: "100dvh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontFamily:
            "Inter, -apple-system, BlinkMacSystemFont, sans-serif",
          background: "#eceff3",
          color: "#1c2128",
        }}
      >
        <main style={{ maxWidth: "32rem", padding: "2rem", textAlign: "center" }}>
          <h1 style={{ fontSize: "1.5rem", fontWeight: 700, marginBottom: "0.75rem" }}>
            Something went wrong
          </h1>
          <p style={{ color: "#4b5563", marginBottom: "1.5rem", lineHeight: 1.5 }}>
            An unexpected error occurred. You can try again, or head back to the
            home page.
          </p>
          <button
            onClick={() => reset()}
            style={{
              display: "inline-flex",
              alignItems: "center",
              padding: "0.5rem 1rem",
              fontWeight: 600,
              color: "#ffffff",
              background: "#1c2128",
              border: "none",
              borderRadius: "8px",
              cursor: "pointer",
            }}
          >
            Try again
          </button>
        </main>
      </body>
    </html>
  );
}
