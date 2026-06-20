"use client";

import { Suspense, useEffect, useRef, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter, useSearchParams } from "next/navigation";

const ERROR_MESSAGES: Record<string, string> = {
  not_provisioned: "No account exists for this email. Please contact your administrator.",
  sso_failed: "SSO authentication failed. Please try again.",
  oidc_failed: "OpenID Connect authentication failed.",
  google_failed: "Google sign-in failed.",
  facebook_failed: "Facebook sign-in failed.",
  github_failed: "GitHub sign-in failed.",
  linkedin_failed: "LinkedIn sign-in failed.",
};

function SSOCallback() {
  const { ssoExchange } = useAuth();
  const router = useRouter();
  const searchParams = useSearchParams();
  const [error, setError] = useState("");
  const [verifying, setVerifying] = useState(true);
  // The SSO code is single-use (GETDEL). React StrictMode double-invokes effects
  // in dev, so guard to exchange exactly once — otherwise the second call 401s
  // and the api client redirects to login even though the first call logged in.
  const ran = useRef(false);

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

    if (ran.current) return;
    ran.current = true;

    ssoExchange(code)
      .then(() => router.push("/app"))
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
            <p><a href="/auth/oidc">Back to sign in</a></p>
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
