"use client";

import { useState } from "react";

const LISTMONK_URL = "https://listmonk.noizu.com/api/public/subscription";
const LIST_UUID = "3d7f6e9c-da0c-40e1-8989-1e2ecf7f6a35";

export default function WaitlistForm({
  buttonText = "Join Waitlist",
}: {
  buttonText?: string;
}) {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<
    "idle" | "loading" | "success" | "error"
  >("idle");
  const [errorMsg, setErrorMsg] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setStatus("loading");
    setErrorMsg("");

    try {
      const res = await fetch(LISTMONK_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email,
          name: "",
          list_uuids: [LIST_UUID],
        }),
      });

      if (res.ok) {
        setStatus("success");
      } else {
        const data = await res.json().catch(() => null);
        setErrorMsg(data?.message || `Subscription failed (${res.status})`);
        setStatus("error");
      }
    } catch {
      setErrorMsg("Network error — please try again.");
      setStatus("error");
    }
  }

  if (status === "success") {
    return (
      <div className="form-success">
        <p>You&apos;re in.</p>
        <span>We&apos;ll notify you when the arena opens.</span>
      </div>
    );
  }

  return (
    <>
      {status === "error" && (
        <div className="form-error">
          <p>{errorMsg}</p>
        </div>
      )}
      <form className="email-form" onSubmit={handleSubmit}>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="you@email.com"
          required
          disabled={status === "loading"}
          aria-label="Email address"
        />
        <button type="submit" disabled={status === "loading"}>
          {status === "loading" ? "Joining..." : buttonText}
        </button>
      </form>
    </>
  );
}
