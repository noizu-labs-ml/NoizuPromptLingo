"use client";

import { SignupForm } from "@/components/landing/signup-form";
import type { MarketingStatus } from "@/lib/api";

const INCLUDED = [
  "Every domain — artifacts, tickets, sessions, wiki, chat, review, personas, memory, media",
  "Every project and org you create, with scoped roles for humans and agents",
  "Claude Code, Codex, and any MCP-capable client, over OAuth or API keys",
  "GitHub integration — repos, issues, pull requests",
  "Long-term agent memory that survives every session",
  "Cancel anytime",
];

/**
 * The single-plan pricing card + the live founding-promo band.
 * `status` is fetched client-side from the public marketing endpoint; when it
 * is null (loading, or the endpoint is down) the section degrades to plain
 * cap-free pricing and the form still works.
 */
export function PricingSection({ status }: { status: MarketingStatus | null }) {
  const promoAvailable =
    status !== null &&
    status.promo_active &&
    status.promo_remaining !== null &&
    status.promo_remaining > 0;

  const promoExhausted =
    status !== null &&
    status.promo_active &&
    status.promo_remaining !== null &&
    status.promo_remaining === 0;

  const meterPercent =
    promoAvailable && status!.promo_cap! > 0
      ? Math.round((status!.promo_remaining! / status!.promo_cap!) * 100)
      : null;

  return (
    <section className="tl-section" id="pricing" aria-labelledby="pricing-title" data-cy="pricing">
      <h2 className="tl-section__title" id="pricing-title">
        Pricing
      </h2>
      <p className="tl-section__lede">
        One plan, everything in it. No per-agent fees, no seat math — your whole team of agents
        and humans works out of the same locker.
      </p>

      <div className="tl-price-card">
        <div className="tl-price-card__head">
          <span className="tl-price-card__name">Tobor Locker</span>
          <span className="tl-price-card__price">
            <span className="tl-price-card__amount">$4.95</span>
            <span className="tl-price-card__per">/month</span>
          </span>
        </div>

        {promoAvailable && (
          <div className="tl-promo" data-cy="promo-band">
            <p className="tl-promo__title">
              First {status!.promo_cap} subscribers get <strong>2 months free</strong>.
            </p>
            <div className="tl-promo__meter" data-cy="promo-meter" role="meter"
              aria-valuemin={0} aria-valuemax={status!.promo_cap!} aria-valuenow={status!.promo_remaining!}
              aria-label="Founding spots remaining">
              <div className="tl-promo__bar" style={{ width: `${meterPercent}%` }} />
            </div>
            <p className="tl-promo__spots" data-cy="promo-spots">
              <span className="tl-promo__count">{status!.promo_remaining}</span> of{" "}
              {status!.promo_cap} founding spots left
            </p>
          </div>
        )}
        {promoExhausted && (
          <div className="tl-promo tl-promo--done" data-cy="promo-band">
            <p className="tl-promo__title">Founding offer claimed. $4.95/mo from day one.</p>
          </div>
        )}

        <ul className="tl-price-card__list">
          {INCLUDED.map((item) => (
            <li key={item}>{item}</li>
          ))}
        </ul>

        <SignupForm source="pricing" status={status} />
      </div>
    </section>
  );
}
