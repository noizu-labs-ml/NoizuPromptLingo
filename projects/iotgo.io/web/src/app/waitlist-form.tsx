"use client";

import { useState } from "react";

const LISTMONK_URL = "https://listmonk.noizu.com/api/public/subscription";
const LIST_UUID = "90a7e213-44a9-4c64-a6cd-df28703f4556";

export function WaitlistForm({
  buttonText = "REQUEST ACCESS",
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
      <div className="mx-auto max-w-md border-2 border-healthy bg-healthy-bg px-4 py-3 text-center">
        <p className="text-sm font-bold uppercase tracking-widest text-healthy">
          [CONFIRMED]
        </p>
        <p className="mt-1 text-xs text-text-secondary">
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
          placeholder="OPERATOR@FLEET.IO"
          required
          disabled={status === "loading"}
          className="w-full border-2 border-border bg-surface px-3 py-2.5 font-mono text-sm uppercase tracking-wider text-text-primary placeholder:text-text-tertiary transition-[border-color] duration-100 focus:border-accent focus:outline-none disabled:opacity-50"
        />
        {status === "error" && (
          <p className="text-xs text-critical">{errorMsg}</p>
        )}
      </div>
      <button
        type="submit"
        disabled={status === "loading"}
        className="border-2 border-accent bg-transparent px-5 py-2.5 text-sm font-bold uppercase tracking-widest text-accent transition-all duration-100 hover:bg-accent hover:text-black disabled:opacity-50"
      >
        {status === "loading" ? "CONNECTING..." : buttonText}
      </button>
    </form>
  );
}
