"use client";

import { Suspense, useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import { api } from "@/lib/api";

function VerifyEmailContent() {
  const searchParams = useSearchParams();
  const token = searchParams.get("token");
  const [status, setStatus] = useState<"loading" | "success" | "error">("loading");
  const [message, setMessage] = useState("");

  useEffect(() => {
    if (!token) {
      setStatus("error");
      setMessage("No verification token provided.");
      return;
    }

    api.verifyEmail(token)
      .then(() => {
        setStatus("success");
        setMessage("Your email has been verified successfully!");
      })
      .catch((err) => {
        setStatus("error");
        setMessage(err.message || "Verification failed. The link may have expired.");
      });
  }, [token]);

  return (
    <div style={{ maxWidth: 480, margin: "80px auto", textAlign: "center", padding: "0 24px" }}>
      <h1 style={{ fontSize: 24, marginBottom: 16 }}>
        {status === "loading" ? "Verifying..." : status === "success" ? "Email Verified" : "Verification Failed"}
      </h1>
      <p style={{ color: status === "error" ? "#dc2626" : "#666", marginBottom: 24 }}>{message}</p>
      {status !== "loading" && (
        <a href={status === "success" ? "/app" : "/login"} style={{ color: "#000", textDecoration: "underline" }}>
          {status === "success" ? "Go to Dashboard" : "Back to Login"}
        </a>
      )}
    </div>
  );
}

export default function VerifyEmailPage() {
  return (
    <Suspense fallback={<div style={{ maxWidth: 480, margin: "80px auto", textAlign: "center", padding: "0 24px" }}>Loading...</div>}>
      <VerifyEmailContent />
    </Suspense>
  );
}
