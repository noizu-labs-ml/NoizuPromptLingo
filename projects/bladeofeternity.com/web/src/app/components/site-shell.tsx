"use client";

import { useState } from "react";
import { useAuth } from "@/context/auth";
import { cyAttrs } from "@/lib/cy-attrs";

export function SiteHeader() {
  const { user, loading, logout } = useAuth();

  return (
    <header className="mx-auto w-full max-w-[1000px] border-b border-white/10" {...cyAttrs({ cy: "header", cyId: "site-header" })}>
      <nav style={{ background: "#070707" }} {...cyAttrs({ cy: "navbar", cyId: "main-nav" })}>
        <div className="px-2 sm:px-6 lg:px-8">
          <div className="relative flex h-16 items-center justify-between">
            <a href="/" className="flex items-center" {...cyAttrs({ cy: "logo", cyId: "site-logo" })}>
              <span
                className="text-2xl tracking-widest"
                style={{
                  fontFamily: "var(--font-display)",
                  color: "var(--gold)",
                  textShadow: "0 0 12px rgba(201,168,76,0.3)",
                }}
              >
                BoE
              </span>
            </a>
            {!loading && (
              <div className="flex items-center gap-3">
                {user ? (
                  <>
                    <span className="text-sm" style={{ color: "var(--gold-light)" }} {...cyAttrs({ cy: "username" })}>
                      {user.email.split("@")[0]}
                    </span>
                    <a
                      href="/game"
                      className="text-sm transition-colors hover:text-[var(--gold)]"
                      style={{ color: "var(--text-secondary)" }}
                      {...cyAttrs({ cy: "nav-link", cyId: "play" })}
                    >
                      Play
                    </a>
                    <button
                      onClick={() => {
                        logout();
                        window.location.href = "/";
                      }}
                      className="text-sm transition-colors hover:text-[var(--gold)]"
                      style={{ color: "var(--text-muted)" }}
                      {...cyAttrs({ cy: "logout-button" })}
                    >
                      Logout
                    </button>
                  </>
                ) : (
                  <>
                    <a
                      href="/login"
                      className="text-sm font-semibold text-white transition-colors hover:text-[var(--gold)]"
                      {...cyAttrs({ cy: "nav-link", cyId: "login" })}
                    >
                      Login
                    </a>
                    <span className="text-sm text-gray-100"> or </span>
                    <a
                      href="/signup"
                      className="text-sm text-blue-400 transition-colors hover:text-blue-300"
                      {...cyAttrs({ cy: "nav-link", cyId: "signup" })}
                    >
                      Create Account
                    </a>
                  </>
                )}
              </div>
            )}
          </div>
        </div>
      </nav>
    </header>
  );
}

export function SiteFooter() {
  const [modal, setModal] = useState<string | null>(null);

  return (
    <>
      <footer className="mx-auto w-full max-w-[1000px] pb-8 pt-16" {...cyAttrs({ cy: "footer", cyId: "site-footer" })}>
        <div className="text-center text-sm" style={{ color: "var(--text-muted)" }}>
          Copyright {new Date().getFullYear()} Noizu Labs, Inc. All rights reserved.
        </div>
        <nav className="mt-2 flex justify-center gap-4" aria-label="Footer links" {...cyAttrs({ cy: "footer-nav" })}>
          {[
            { label: "Contact Us", key: "contact" },
            { label: "Terms of Service", key: "terms" },
            { label: "Privacy Policy", key: "privacy" },
            { label: "Cookie", key: "cookie" },
          ].map((link) => (
            <button
              key={link.key}
              onClick={() => setModal(link.key)}
              className="cursor-pointer text-xs transition-colors hover:underline"
              style={{ color: "var(--text-muted)" }}
              {...cyAttrs({ cy: "footer-link", cyId: link.key })}
            >
              {link.label}
            </button>
          ))}
        </nav>
      </footer>

      {modal && <FooterModal page={modal} onClose={() => setModal(null)} />}
    </>
  );
}

function FooterModal({ page, onClose }: { page: string; onClose: () => void }) {
  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center"
      style={{ background: "rgba(0,0,0,0.85)" }}
      onClick={onClose}
      {...cyAttrs({ cy: "modal-overlay", cyFor: page })}
    >
      <div
        className="relative mx-4 max-h-[80vh] w-full max-w-[700px] overflow-y-auto rounded-lg border border-white/10 p-8"
        style={{ background: "var(--bg-surface)" }}
        onClick={(e) => e.stopPropagation()}
        {...cyAttrs({ cy: "modal", cyId: page })}
      >
        <button
          onClick={onClose}
          className="absolute right-4 top-4 text-2xl leading-none transition-colors hover:text-[var(--gold)]"
          style={{ color: "var(--text-muted)" }}
          aria-label="Close"
          {...cyAttrs({ cy: "modal-close", cyFor: page })}
        >
          &times;
        </button>
        <ModalContent page={page} />
      </div>
    </div>
  );
}

function ModalContent({ page }: { page: string }) {
  const heading = "mb-2 text-lg";
  const headingStyle = { fontFamily: "var(--font-heading)", color: "var(--gold-light)" };
  const bodyStyle = { color: "var(--text-primary)" };

  if (page === "contact") {
    return (
      <>
        <h2 className="mb-6 text-2xl tracking-wide" style={{ fontFamily: "var(--font-heading)", color: "var(--gold)" }}>Contact Us</h2>
        <div className="space-y-5 leading-7" style={bodyStyle}>
          <div><h3 className={heading} style={headingStyle}>General Inquiries</h3><p>Email: <a href="mailto:support@bladeofeternity.com" className="underline hover:text-[var(--gold)]">support@bladeofeternity.com</a></p></div>
          <div><h3 className={heading} style={headingStyle}>Bug Reports &amp; Feedback</h3><p>Found a bug or have a suggestion? Email <a href="mailto:feedback@bladeofeternity.com" className="underline hover:text-[var(--gold)]">feedback@bladeofeternity.com</a> with a description and any relevant details.</p></div>
          <div><h3 className={heading} style={headingStyle}>Business &amp; Partnerships</h3><p>For partnership or business inquiries, contact <a href="mailto:business@bladeofeternity.com" className="underline hover:text-[var(--gold)]">business@bladeofeternity.com</a></p></div>
          <p className="text-sm" style={{ color: "var(--text-muted)" }}>We typically respond within 1–2 business days.</p>
        </div>
      </>
    );
  }

  if (page === "terms") {
    return (
      <>
        <h2 className="mb-1 text-2xl tracking-wide" style={{ fontFamily: "var(--font-heading)", color: "var(--gold)" }}>Terms of Service</h2>
        <p className="mb-6 text-sm" style={{ color: "var(--text-muted)" }}>Last updated: March 13, 2026</p>
        <div className="space-y-6 leading-7" style={bodyStyle}>
          <section><h3 className={heading} style={headingStyle}>1. Acceptance of Terms</h3><p>By accessing or using Blade of Eternity, operated by Noizu Labs, Inc., you agree to be bound by these Terms of Service.</p></section>
          <section><h3 className={heading} style={headingStyle}>2. Eligibility</h3><p>You must be at least 13 years old to create an account.</p></section>
          <section><h3 className={heading} style={headingStyle}>3. Account Responsibilities</h3><p>You are responsible for maintaining the security of your account credentials. You may not share, sell, or transfer your account.</p></section>
          <section><h3 className={heading} style={headingStyle}>4. Code of Conduct</h3><p className="mb-2">While using the Game, you agree not to:</p><ul className="list-inside list-disc space-y-1 pl-4"><li>Harass, threaten, or abuse other players</li><li>Use exploits, bots, or third-party automation</li><li>Reverse-engineer or modify the Game client</li><li>Engage in real-money trading</li><li>Impersonate staff or other players</li></ul></section>
          <section><h3 className={heading} style={headingStyle}>5. Intellectual Property</h3><p>All content within Blade of Eternity is the property of Noizu Labs, Inc. and is protected by copyright and trademark law.</p></section>
          <section><h3 className={heading} style={headingStyle}>6. Service Availability</h3><p>We strive to keep the Game available but do not guarantee uninterrupted access.</p></section>
          <section><h3 className={heading} style={headingStyle}>7. Limitation of Liability</h3><p>To the fullest extent permitted by law, Noizu Labs, Inc. shall not be liable for any indirect, incidental, or consequential damages.</p></section>
          <section><h3 className={heading} style={headingStyle}>8. Changes to Terms</h3><p>We may update these Terms at any time. Continued use constitutes acceptance.</p></section>
          <section><h3 className={heading} style={headingStyle}>9. Contact</h3><p>Questions? Contact <a href="mailto:legal@bladeofeternity.com" className="underline hover:text-[var(--gold)]">legal@bladeofeternity.com</a></p></section>
        </div>
      </>
    );
  }

  if (page === "privacy") {
    return (
      <>
        <h2 className="mb-1 text-2xl tracking-wide" style={{ fontFamily: "var(--font-heading)", color: "var(--gold)" }}>Privacy Policy</h2>
        <p className="mb-6 text-sm" style={{ color: "var(--text-muted)" }}>Last updated: March 13, 2026</p>
        <div className="space-y-6 leading-7" style={bodyStyle}>
          <section><h3 className={heading} style={headingStyle}>1. Information We Collect</h3><p className="mb-2">When you use Blade of Eternity, we may collect:</p><ul className="list-inside list-disc space-y-1 pl-4"><li><strong>Account info:</strong> username, email, hashed password</li><li><strong>Game data:</strong> character progress, inventory, chat logs</li><li><strong>Technical data:</strong> IP address, browser type, device identifiers</li><li><strong>Usage data:</strong> pages visited, features used, session duration</li></ul></section>
          <section><h3 className={heading} style={headingStyle}>2. How We Use It</h3><ul className="list-inside list-disc space-y-1 pl-4"><li>Providing and maintaining the Game</li><li>Authentication and account security</li><li>Service announcements and updates</li><li>Enforcing Terms of Service</li><li>Improving performance and accessibility</li></ul></section>
          <section><h3 className={heading} style={headingStyle}>3. Data Sharing</h3><p>We do not sell your personal information. We may share data with trusted service providers contractually obligated to protect it.</p></section>
          <section><h3 className={heading} style={headingStyle}>4. Data Retention</h3><p>We retain data while your account is active. Deletion requests are honored within 30 days.</p></section>
          <section><h3 className={heading} style={headingStyle}>5. Security</h3><p>We use TLS encryption, bcrypt password hashing, and regular security audits.</p></section>
          <section><h3 className={heading} style={headingStyle}>6. Your Rights</h3><p>You may request access, correction, deletion, or portability of your data. Email <a href="mailto:privacy@bladeofeternity.com" className="underline hover:text-[var(--gold)]">privacy@bladeofeternity.com</a></p></section>
          <section><h3 className={heading} style={headingStyle}>7. Children&rsquo;s Privacy</h3><p>We do not knowingly collect data from children under 13.</p></section>
          <section><h3 className={heading} style={headingStyle}>8. Changes</h3><p>We may update this policy periodically. Continued use constitutes acceptance.</p></section>
        </div>
      </>
    );
  }

  return (
    <>
      <h2 className="mb-1 text-2xl tracking-wide" style={{ fontFamily: "var(--font-heading)", color: "var(--gold)" }}>Cookie Policy</h2>
      <p className="mb-6 text-sm" style={{ color: "var(--text-muted)" }}>Last updated: March 13, 2026</p>
      <div className="space-y-6 leading-7" style={bodyStyle}>
        <section><h3 className={heading} style={headingStyle}>What Are Cookies</h3><p>Small text files stored on your device to remember preferences and sessions.</p></section>
        <section>
          <h3 className={heading} style={headingStyle}>Cookies We Use</h3>
          <div className="mt-3 overflow-hidden rounded border border-white/10">
            <table className="w-full text-sm">
              <thead><tr style={{ background: "var(--bg-elevated)" }}><th className="px-3 py-2 text-left" style={{ color: "var(--gold-light)" }}>Cookie</th><th className="px-3 py-2 text-left" style={{ color: "var(--gold-light)" }}>Type</th><th className="px-3 py-2 text-left" style={{ color: "var(--gold-light)" }}>Purpose</th><th className="px-3 py-2 text-left" style={{ color: "var(--gold-light)" }}>Duration</th></tr></thead>
              <tbody className="divide-y divide-white/5">
                <tr><td className="px-3 py-2 font-mono text-xs">_boe_session</td><td className="px-3 py-2">Essential</td><td className="px-3 py-2">Login session</td><td className="px-3 py-2">Session</td></tr>
                <tr><td className="px-3 py-2 font-mono text-xs">_boe_csrf</td><td className="px-3 py-2">Essential</td><td className="px-3 py-2">CSRF protection</td><td className="px-3 py-2">Session</td></tr>
                <tr><td className="px-3 py-2 font-mono text-xs">_boe_remember</td><td className="px-3 py-2">Functional</td><td className="px-3 py-2">Persistent login</td><td className="px-3 py-2">60 days</td></tr>
                <tr><td className="px-3 py-2 font-mono text-xs">_boe_prefs</td><td className="px-3 py-2">Functional</td><td className="px-3 py-2">UI &amp; accessibility</td><td className="px-3 py-2">1 year</td></tr>
                <tr><td className="px-3 py-2 font-mono text-xs">_boe_analytics</td><td className="px-3 py-2">Analytics</td><td className="px-3 py-2">Anonymous stats</td><td className="px-3 py-2">90 days</td></tr>
              </tbody>
            </table>
          </div>
        </section>
        <section><h3 className={heading} style={headingStyle}>Managing Cookies</h3><p>Control cookies through your browser settings. Disabling essential cookies prevents login.</p></section>
      </div>
    </>
  );
}
