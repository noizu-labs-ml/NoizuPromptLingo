"use client";

import { useState, FormEvent } from "react";
import { StyleGuideBtn, StyleGuideCard, StyleGuideCardGrid } from "@the-robot-lives/styleguide/components";

const audiences = [
  { glyph: "→", title: "Users", description: "Finding a product? We'll route you to the right one." },
  { glyph: "+", title: "Collaborators", description: "Want to build with us? Tell us what you bring." },
  { glyph: "◈", title: "Investors", description: "Evaluating the portfolio? Let's talk." },
];

const roles = ["User", "Collaborator", "Investor", "Press", "Other"] as const;

export default function ContactPage() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [role, setRole] = useState("");
  const [message, setMessage] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setTimeout(() => {
      setSubmitting(false);
      setSubmitted(true);
    }, 600);
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Get in Touch</h1>

        {/* ─── Audience Cards ─── */}
        <section className="mt-12 mb-16">
          <StyleGuideCardGrid>
            {audiences.map((a) => (
              <StyleGuideCard
                key={a.title}
                title={`${a.glyph} ${a.title}`}
                body={a.description}
              />
            ))}
          </StyleGuideCardGrid>
        </section>

        {/* ─── Form ─── */}
        <section className="mb-16 max-w-xl">
          <h2 className="sg-section-heading">Send a Message</h2>

          {submitted ? (
            <StyleGuideCard
              title="Message received."
              body="We'll get back to you soon."
              accent="success"
            />
          ) : (
            <form onSubmit={handleSubmit} className="flex flex-col gap-5">
              <div className="sg-field">
                <label htmlFor="contact-name">Name</label>
                <input
                  id="contact-name"
                  type="text"
                  required
                  placeholder="Your name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                />
              </div>

              <div className="sg-field">
                <label htmlFor="contact-email">Email</label>
                <input
                  id="contact-email"
                  type="email"
                  required
                  placeholder="you@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                />
              </div>

              <div className="sg-field">
                <label htmlFor="contact-role">I am a...</label>
                <select
                  id="contact-role"
                  required
                  value={role}
                  onChange={(e) => setRole(e.target.value)}
                >
                  <option value="" disabled>Select a role</option>
                  {roles.map((r) => (
                    <option key={r} value={r}>{r}</option>
                  ))}
                </select>
              </div>

              <div className="sg-field">
                <label htmlFor="contact-message">Message</label>
                <textarea
                  id="contact-message"
                  required
                  rows={5}
                  placeholder="What's on your mind?"
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                />
              </div>

              <div>
                <button type="submit" disabled={submitting}>
                  <StyleGuideBtn
                    variant="black"
                    label={submitting ? "Sending..." : "Send Message"}
                  />
                </button>
              </div>
            </form>
          )}
        </section>

        {/* ─── Alternative Contact ─── */}
        <section className="mb-16">
          <p className="text-[var(--text-muted)] font-[family-name:var(--font-body)] text-sm">
            Or email us directly at{" "}
            <a
              href="mailto:hello@derobot.is"
              className="text-[var(--text-link)] underline underline-offset-2 hover:text-[var(--text)] transition-colors"
            >
              hello@derobot.is
            </a>
          </p>
        </section>
      </main>
    </div>
  );
}
