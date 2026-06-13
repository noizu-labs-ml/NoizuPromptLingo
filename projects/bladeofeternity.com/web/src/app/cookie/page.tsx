import { cyAttrs } from "@/lib/cy-attrs";

export default function CookiePage() {
  return (
    <div className="mx-auto w-full max-w-[800px] px-4 py-16 text-white" {...cyAttrs({ cy: "cookie-page", cyScope: "cookie" })}>
      <h1
        className="mb-2 text-3xl tracking-wide"
        style={{ fontFamily: "var(--font-heading)", color: "var(--gold)" }}
      >
        Cookie Policy
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
            What Are Cookies
          </h2>
          <p>
            Cookies are small text files stored on your device when you visit a
            website. They help the site remember your preferences, keep you
            logged in, and understand how you use the service.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            Cookies We Use
          </h2>

          <div className="mt-4 overflow-hidden rounded border border-white/10">
            <table className="w-full text-sm" {...cyAttrs({ cy: "cookie-table" })}>
              <thead>
                <tr style={{ background: "var(--bg-surface)" }}>
                  <th className="px-4 py-2 text-left" style={{ color: "var(--gold-light)" }}>Cookie</th>
                  <th className="px-4 py-2 text-left" style={{ color: "var(--gold-light)" }}>Type</th>
                  <th className="px-4 py-2 text-left" style={{ color: "var(--gold-light)" }}>Purpose</th>
                  <th className="px-4 py-2 text-left" style={{ color: "var(--gold-light)" }}>Duration</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5">
                <tr>
                  <td className="px-4 py-2 font-mono text-xs">_boe_session</td>
                  <td className="px-4 py-2">Essential</td>
                  <td className="px-4 py-2">Maintains your login session</td>
                  <td className="px-4 py-2">Session</td>
                </tr>
                <tr>
                  <td className="px-4 py-2 font-mono text-xs">_boe_csrf</td>
                  <td className="px-4 py-2">Essential</td>
                  <td className="px-4 py-2">Protects against cross-site request forgery</td>
                  <td className="px-4 py-2">Session</td>
                </tr>
                <tr>
                  <td className="px-4 py-2 font-mono text-xs">_boe_remember</td>
                  <td className="px-4 py-2">Functional</td>
                  <td className="px-4 py-2">Keeps you logged in between visits</td>
                  <td className="px-4 py-2">60 days</td>
                </tr>
                <tr>
                  <td className="px-4 py-2 font-mono text-xs">_boe_prefs</td>
                  <td className="px-4 py-2">Functional</td>
                  <td className="px-4 py-2">Stores accessibility and UI preferences</td>
                  <td className="px-4 py-2">1 year</td>
                </tr>
                <tr>
                  <td className="px-4 py-2 font-mono text-xs">_boe_analytics</td>
                  <td className="px-4 py-2">Analytics</td>
                  <td className="px-4 py-2">Anonymous usage statistics</td>
                  <td className="px-4 py-2">90 days</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            Essential Cookies
          </h2>
          <p>
            These cookies are required for the Game to function. They handle
            authentication, security, and session management. They cannot be
            disabled without breaking core functionality.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            Functional Cookies
          </h2>
          <p>
            These cookies remember your preferences — such as accessibility
            settings, audio preferences, and UI layout — so you don&rsquo;t
            have to reconfigure them each visit.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            Analytics Cookies
          </h2>
          <p>
            We use anonymized analytics to understand how players interact with
            the Game. This data helps us improve performance, balance gameplay,
            and prioritize accessibility features. No personally identifiable
            information is collected through analytics cookies.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            Third-Party Cookies
          </h2>
          <p>
            Blade of Eternity does not use third-party advertising cookies. We
            do not serve ads or allow third-party ad networks to place cookies
            on our site.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            Managing Cookies
          </h2>
          <p>
            You can control cookies through your browser settings. Most browsers
            allow you to block or delete cookies. Note that disabling essential
            cookies will prevent you from logging in and playing the Game.
          </p>
        </section>

        <section>
          <h2
            className="mb-2 text-lg"
            style={{ fontFamily: "var(--font-heading)", color: "var(--gold-light)" }}
          >
            Contact
          </h2>
          <p>
            Questions about our cookie practices? Contact{" "}
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
