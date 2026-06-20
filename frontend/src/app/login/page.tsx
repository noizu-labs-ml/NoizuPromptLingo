"use client";

import { useEffect } from "react";

export default function LoginPage() {
  useEffect(() => {
    window.location.href = "/auth/oidc";
  }, []);

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Signing In</h1>
        <p>Redirecting to sign in&hellip;</p>
      </main>
    </div>
  );
}
