"use client";

import { useState } from "react";

const LISTMONK_URL = "https://listmonk.noizu.com/api/public/subscription";
const LIST_UUID = "b5ddf546-2ea1-4a5f-882c-f48612377f0e";

export function WaitlistForm({
  buttonText = "Join the Waitlist",
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
      <div className="mx-auto max-w-md rounded-2xl border-2 border-olive bg-olive-light px-6 py-4 text-center">
        <p className="font-ui text-sm font-semibold text-olive">
          You&apos;re on the list.
        </p>
        <p className="mt-1 font-ui text-xs text-ink-secondary">
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
          placeholder="you@example.com"
          required
          disabled={status === "loading"}
          className="w-full rounded-xl border-2 border-rule bg-surface px-4 py-3 font-ui text-base text-ink placeholder:text-ink-tertiary transition-all duration-200 focus:border-coral focus:shadow-[0_0_0_4px_rgba(232,112,74,0.1)] focus:outline-none disabled:opacity-50"
        />
        {status === "error" && (
          <p className="font-ui text-xs text-error">{errorMsg}</p>
        )}
      </div>
      <button
        type="submit"
        disabled={status === "loading"}
        className="rounded-xl bg-coral px-6 py-3 font-ui text-base font-semibold text-white shadow-[0_2px_8px_rgba(232,112,74,0.2)] transition-all duration-150 hover:-translate-y-0.5 hover:bg-coral-hover hover:shadow-[0_4px_16px_rgba(232,112,74,0.3)] active:translate-y-0 disabled:opacity-50"
      >
        {status === "loading" ? "Joining..." : buttonText}
      </button>
    </form>
  );
}
