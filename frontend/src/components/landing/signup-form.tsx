"use client";

import { useState } from "react";
import { api, type MarketingStatus } from "@/lib/api";

type Outcome =
  | { kind: "promo_awarded"; promoRemaining: number | null }
  | { kind: "accepted" }
  | { kind: "waitlisted" }
  | { kind: "already" };

type SignupFormProps = {
  /** Where on the page this form lives — lands in the signup row's source column. */
  source: string;
  /** Live marketing status; null while loading or when the endpoint is unreachable. */
  status: MarketingStatus | null;
};

/**
 * Public email capture for the landing page. Mode is driven by the live
 * status endpoint: when signups are closed or the beta cap is full the same
 * form becomes "join the waitlist" (the backend waitlists it either way).
 */
export function SignupForm({ source, status }: SignupFormProps) {
  const [email, setEmail] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [outcome, setOutcome] = useState<Outcome | null>(null);

  const waitlistMode =
    status !== null && (!status.signups_open || status.beta_remaining === 0);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    const trimmed = email.trim();
    if (!trimmed || submitting) return;

    setSubmitting(true);
    setError(null);
    try {
      const res = await api.marketingSignup(trimmed, source);
      if (res.waitlisted) {
        setOutcome({ kind: "waitlisted" });
      } else if (res.already_registered) {
        setOutcome({ kind: "already" });
      } else if (res.promo_awarded) {
        setOutcome({ kind: "promo_awarded", promoRemaining: res.promo_remaining });
      } else {
        // Accepted, but the founding promo is gone.
        setOutcome({ kind: "accepted" });
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something went wrong — try again.");
    } finally {
      setSubmitting(false);
    }
  }

  if (outcome) {
    return (
      <p className="tl-form__success" data-cy="signup-success" data-cy-outcome={outcome.kind} role="status">
        {outcome.kind === "promo_awarded" && (
          <>
            <strong data-cy="promo-awarded">You&apos;re in — 2 months free at launch.</strong>{" "}
            We&apos;ll email {email.trim()} when your account is ready.
          </>
        )}
        {outcome.kind === "accepted" && (
          <>
            <strong>You&apos;re in.</strong> We&apos;ll email {email.trim()} when your account is ready.
          </>
        )}
        {outcome.kind === "waitlisted" && (
          <>
            <strong data-cy="waitlisted">You&apos;re on the waitlist.</strong>{" "}
            We&apos;ll email {email.trim()} as soon as a spot opens.
          </>
        )}
        {outcome.kind === "already" && (
          <>
            <strong>You&apos;re already on the list.</strong> We&apos;ll be in touch at {email.trim()}.
          </>
        )}
      </p>
    );
  }

  return (
    <form className="tl-form" onSubmit={onSubmit} data-cy="signup-form" data-cy-mode={waitlistMode ? "waitlist" : "signup"}>
      <label className="tl-form__label" htmlFor={`signup-email-${source}`}>
        {waitlistMode ? "Join the waitlist" : "Get early access"}
      </label>
      <div className="tl-form__row">
        <input
          id={`signup-email-${source}`}
          className="tl-form__input"
          type="email"
          name="email"
          autoComplete="email"
          placeholder="you@company.com"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          disabled={submitting}
          data-cy="signup-email"
          required
        />
        <button className="sg-btn sg-btn--black" type="submit" disabled={submitting || !email.trim()} data-cy="signup-submit">
          {submitting ? "Sending…" : waitlistMode ? "Join the waitlist" : "Request access"}
        </button>
      </div>
      {error && (
        <p className="tl-form__error" role="alert">
          {error}{" "}
          <button type="button" className="tl-form__retry" onClick={() => setError(null)} data-cy="signup-retry">
            Try again
          </button>
        </p>
      )}
    </form>
  );
}
