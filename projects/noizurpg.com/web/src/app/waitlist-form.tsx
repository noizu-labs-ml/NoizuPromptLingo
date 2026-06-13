"use client";

import { useState } from "react";

const LISTMONK_URL = "https://listmonk.noizu.com/api/public/subscription";
const LIST_UUID = "d0611a6b-e9b9-4e4e-9801-15cb8194116b";

export function WaitlistForm({
  buttonText = "GET EARLY ACCESS",
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
      <div className="mx-auto max-w-md rounded-sm border border-accent bg-accent-muted px-4 py-3 text-center">
        <p className="font-flavor text-sm uppercase tracking-[0.08em] text-accent">
          [Confirmed]
        </p>
        <p className="mt-1 font-serif text-xs text-text-secondary">
          Check your inbox to confirm your subscription.
        </p>
      </div>
    );
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="mx-auto flex max-w-lg flex-col gap-3 sm:flex-row"
    >
      <div className="flex flex-1 flex-col gap-1">
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="dev@yourstudio.com"
          required
          disabled={status === "loading"}
          className="w-full rounded-sm border border-border bg-inset px-3 py-2.5 font-serif text-sm text-text-primary placeholder:text-text-tertiary transition-[border-color,box-shadow] duration-150 focus:border-accent focus:shadow-[0_0_0_3px_var(--accent-glow)] focus:outline-none disabled:opacity-50"
        />
        {status === "error" && (
          <p className="text-xs text-error">{errorMsg}</p>
        )}
      </div>
      <button
        type="submit"
        disabled={status === "loading"}
        className="rounded-sm bg-accent px-5 py-2.5 font-mono text-sm font-bold uppercase tracking-wider text-[#0D0B0E] transition-all duration-150 hover:bg-[#E8B75E] hover:shadow-[0_0_20px_rgba(212,160,74,0.3)] disabled:opacity-50"
      >
        {status === "loading" ? "CONNECTING..." : buttonText}
      </button>
    </form>
  );
}
