import { cyAttrs } from "@/lib/cy-attrs";

export default function TermsPage() {
  return (
    <div className="mx-auto w-full max-w-[800px] px-4 py-16 text-white" {...cyAttrs({ cy: "terms-page", cyScope: "terms" })}>
      <h1
        className="mb-2 text-3xl tracking-wide"
        style={{ fontFamily: "var(--font-heading)", color: "var(--gold)" }}
      >
        Terms of Service
      </h1>
      <hr className="mb-8 border-white/20" />
      <p className="mb-4 text-sm" style={{ color: "var(--text-muted)" }}>
        Last updated: March 13, 2026
      </p>

      <div className="space-y-8 leading-7" style={{ color: "var(--text-primary)" }}>
        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            1. Acceptance of Terms
          </h2>
          <p>
            By accessing or using Blade of Eternity (&ldquo;the Game&rdquo;),
            operated by Noizu Labs, Inc. (&ldquo;we,&rdquo; &ldquo;us,&rdquo;
            or &ldquo;our&rdquo;), you agree to be bound by these Terms of
            Service. If you do not agree, do not use the Game.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            2. Eligibility
          </h2>
          <p>
            You must be at least 13 years old to create an account. If you are
            under 18, you represent that a parent or legal guardian has reviewed
            and agreed to these Terms on your behalf.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            3. Account Responsibilities
          </h2>
          <p>
            You are responsible for maintaining the security of your account
            credentials. You may not share, sell, or transfer your account. We
            reserve the right to suspend or terminate accounts that violate
            these Terms.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            4. Code of Conduct
          </h2>
          <p className="mb-2">While using the Game, you agree not to:</p>
          <ul className="list-inside list-disc space-y-1 pl-4">
            <li>Harass, threaten, or abuse other players</li>
            <li>Use exploits, bots, or third-party automation software</li>
            <li>Attempt to reverse-engineer or modify the Game client</li>
            <li>Engage in real-money trading of in-game items or accounts</li>
            <li>Impersonate staff or other players</li>
          </ul>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            5. Intellectual Property
          </h2>
          <p>
            All content within Blade of Eternity — including artwork, text,
            code, game mechanics, and audio — is the property of Noizu Labs,
            Inc. and is protected by copyright and trademark law. You may not
            reproduce, distribute, or create derivative works without written
            permission.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            6. Service Availability
          </h2>
          <p>
            We strive to keep the Game available but do not guarantee
            uninterrupted access. We may perform maintenance, updates, or
            modifications at any time without prior notice. We are not liable
            for any loss of progress or data resulting from downtime.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            7. Limitation of Liability
          </h2>
          <p>
            To the fullest extent permitted by law, Noizu Labs, Inc. shall not
            be liable for any indirect, incidental, or consequential damages
            arising from your use of the Game.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            8. Changes to Terms
          </h2>
          <p>
            We may update these Terms at any time. Continued use of the Game
            after changes constitutes acceptance of the revised Terms. We will
            make reasonable efforts to notify users of material changes.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            9. Contact
          </h2>
          <p>
            Questions about these Terms? Contact us at{" "}
            <a
              href="mailto:legal@bladeofeternity.com"
              className="underline transition-colors hover:text-[var(--gold)]"
            >
              legal@bladeofeternity.com
            </a>
          </p>
        </section>
      </div>
    </div>
  );
}
