"use client";

import { Suspense, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";

const ERROR_MESSAGES: Record<string, string> = {
  not_provisioned: "No account exists for this email. Please contact your administrator.",
  sso_failed: "SSO authentication failed. Please try again.",
  oidc_failed: "OpenID Connect authentication failed.",
  google_failed: "Google sign-in failed.",
  github_failed: "GitHub sign-in failed.",
};

function SSOCallback() {
  const { ssoExchange } = useAuth();
  const router = useRouter();
  const searchParams = useSearchParams();
  const [error, setError] = useState("");
  const [verifying, setVerifying] = useState(true);

  useEffect(() => {
    const code = searchParams.get("code");
    const errorParam = searchParams.get("error");

    if (errorParam) {
      setError(ERROR_MESSAGES[errorParam] || "Authentication failed.");
      setVerifying(false);
      return;
    }

    if (!code) {
      setError("No authorization code provided.");
      setVerifying(false);
      return;
    }

    ssoExchange(code)
      .then(() => router.push("/"))
      .catch(() => {
        setError("Failed to complete sign-in. The code may have expired.");
        setVerifying(false);
      });
  }, [searchParams, ssoExchange, router]);

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Signing In</h1>
        {verifying && <p>Completing authentication...</p>}
        {error && (
          <>
            <p className="sg-error">{error}</p>
            <p><Link href="/login">Back to login</Link></p>
          </>
        )}
      </main>
    </div>
  );
}

export default function SSOCallbackPage() {
  return (
    <Suspense fallback={<div className="content"><main><p>Loading...</p></main></div>}>
      <SSOCallback />
    </Suspense>
  );
}
