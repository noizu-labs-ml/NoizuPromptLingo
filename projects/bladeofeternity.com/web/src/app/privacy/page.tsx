import { cyAttrs } from "@/lib/cy-attrs";

export default function PrivacyPage() {
  return (
    <div className="mx-auto w-full max-w-[800px] px-4 py-16 text-white" {...cyAttrs({ cy: "privacy-page", cyScope: "privacy" })}>
      <h1
        className="mb-2 text-3xl tracking-wide"
        style={{ fontFamily: "var(--font-heading)", color: "var(--gold)" }}
      >
        Privacy Policy
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
            1. Information We Collect
          </h2>
          <p className="mb-2">
            When you use Blade of Eternity, we may collect the following:
          </p>
          <ul className="list-inside list-disc space-y-1 pl-4">
            <li>
              <strong>Account information:</strong> username, email address, and
              hashed password
            </li>
            <li>
              <strong>Game data:</strong> character progress, inventory, chat
              logs, and gameplay statistics
            </li>
            <li>
              <strong>Technical data:</strong> IP address, browser type,
              operating system, and device identifiers
            </li>
            <li>
              <strong>Usage data:</strong> pages visited, features used, session
              duration, and referring URLs
            </li>
          </ul>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            2. How We Use Your Information
          </h2>
          <ul className="list-inside list-disc space-y-1 pl-4">
            <li>Providing and maintaining the Game</li>
            <li>Authenticating your identity and securing your account</li>
            <li>Communicating updates, patches, and service announcements</li>
            <li>Enforcing our Terms of Service and Code of Conduct</li>
            <li>Improving game performance, balance, and accessibility</li>
            <li>Analyzing aggregate usage patterns (anonymized)</li>
          </ul>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            3. Data Sharing
          </h2>
          <p>
            We do not sell your personal information. We may share data with
            trusted third-party service providers (hosting, analytics, email
            delivery) who are contractually obligated to protect your data. We
            may also disclose information when required by law or to protect the
            safety of our users.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            4. Data Retention
          </h2>
          <p>
            We retain your account data for as long as your account is active.
            If you request account deletion, we will remove your personal data
            within 30 days, except where retention is required by law or
            necessary for fraud prevention.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            5. Security
          </h2>
          <p>
            We employ industry-standard security measures including encryption
            in transit (TLS), hashed passwords (bcrypt), and regular security
            audits. However, no system is perfectly secure. You are responsible
            for keeping your login credentials confidential.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            6. Your Rights
          </h2>
          <p className="mb-2">Depending on your jurisdiction, you may have the right to:</p>
          <ul className="list-inside list-disc space-y-1 pl-4">
            <li>Access the personal data we hold about you</li>
            <li>Request correction of inaccurate data</li>
            <li>Request deletion of your data</li>
            <li>Object to or restrict certain processing</li>
            <li>Data portability (receive your data in a structured format)</li>
          </ul>
          <p className="mt-2">
            To exercise these rights, email{" "}
            <a
              href="mailto:privacy@bladeofeternity.com"
              className="underline transition-colors hover:text-[var(--gold)]"
            >
              privacy@bladeofeternity.com
            </a>
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            7. Children&rsquo;s Privacy
          </h2>
          <p>
            Blade of Eternity is not directed at children under 13. We do not
            knowingly collect personal information from children under 13. If
            you believe a child has provided us data, contact us and we will
            delete it promptly.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            8. Changes to This Policy
          </h2>
          <p>
            We may update this Privacy Policy periodically. We will notify
            registered users of material changes via email or in-game
            notification. Continued use after changes constitutes acceptance.
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
            Privacy questions? Contact{" "}
            <a
              href="mailto:privacy@bladeofeternity.com"
              className="underline transition-colors hover:text-[var(--gold)]"
            >
              privacy@bladeofeternity.com
            </a>
          </p>
        </section>
      </div>
    </div>
  );
}
