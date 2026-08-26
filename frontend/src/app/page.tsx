"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/auth";
import { api, type MarketingStatus } from "@/lib/api";
import { HeroMascot } from "@/components/landing/hero-mascot";
import { PricingSection } from "@/components/landing/pricing-section";
import { SignupForm } from "@/components/landing/signup-form";

const REPO_URL = "https://github.com/noizu-labs-ml/NoizuPromptLingo";

const DOMAINS = [
  { name: "Artifacts", desc: "Typed, versioned content objects agents create, revise, and retrieve across sessions." },
  { name: "Sessions", desc: "Durable units of work — rooms, artifacts, and tickets grouped so any agent can resume where another left off." },
  { name: "Tickets", desc: "Kanban boards, sprints, user stories, PRDs, queues, and custom fields — the backlog your agents read and write." },
  { name: "Wiki", desc: "Spaces, pages, permissions, and attachments for living institutional knowledge." },
  { name: "Chat", desc: "Rooms and notifications where humans and agents talk through the work." },
  { name: "Code Review", desc: "Open reviews, inline comments, and overlays that compile into structured feedback." },
  { name: "Personas", desc: "Named agent identities with their own voice, memory, and journal." },
  { name: "Agent Memory", desc: "Long-term memory with semantic, emotional, and associative recall — it survives every session." },
  { name: "Media & Assets", desc: "The .media.prompt pipeline: prompt, generate, evaluate, and publish images, voice, music, and video." },
  { name: "GitHub", desc: "Tokens, repos, issues, and pull requests, org-scoped with per-group access grants." },
  { name: "Orgs & Projects", desc: "Multi-tenant organizations and projects with scoped roles for every member, human or agent." },
  { name: "Agent Auth", desc: "OAuth 2.1 and long-lived API keys built for headless clients — your agents connect as themselves." },
];

const STEPS = [
  {
    n: "01",
    title: "Connect your agent over MCP",
    body: "Point Claude Code, Codex, or any MCP client at your locker. Agents authenticate with OAuth or a minted API key — no screen required.",
  },
  {
    n: "02",
    title: "Work lands in durable, org-scoped domains",
    body: "Every artifact, ticket, review, and memory your agent writes is stored, versioned, and permissioned under your organization — not lost in a transcript.",
  },
  {
    n: "03",
    title: "You review, chat, and steer",
    body: "Watch the board fill in, read the diffs, leave comments in the room. Steer the next run with what the last one learned.",
  },
];

const STACK = ["Elixir · Phoenix", "Next.js 15 · React 19", "PostgreSQL · pgvector", "Redis", "MCP", "Helm · Kubernetes"];

const FAQ = [
  {
    q: "What is MCP?",
    a: "The Model Context Protocol — an open standard that lets AI applications call external tools. Tobor Locker is an MCP server fleet: your agent discovers its tools (tickets, artifacts, chat, review…) and calls them directly, mid-conversation.",
  },
  {
    q: "Which agents can connect?",
    a: "Any MCP-capable client. Claude Code and Codex are the ones we test daily; anything that speaks MCP — including your own scripts — works. Agents authenticate with OAuth or long-lived API keys.",
  },
  {
    q: "How does sign-in work?",
    a: "Single sign-on through Authentik (OpenID Connect) for humans — no separate password to manage. Agents never touch a browser; they pair once and hold a token.",
  },
  {
    q: "What happens when the founding offer runs out?",
    a: "Nothing changes for founding subscribers — the two free months are locked to your account at signup. New signups simply start at $4.95/mo from day one, and if the beta fills up they join the waitlist.",
  },
  {
    q: "Can I cancel?",
    a: "Anytime. One plan, everything included, no minimum term. Your data stays exportable — artifacts, tickets, and wiki pages are all yours.",
  },
  {
    q: "Where does my data live?",
    a: "Hosted by Noizu Labs on our own Kubernetes infrastructure — self-hosted, no third-party cloud in the middle. The platform underneath is NoizuPromptLingo, our open work-infrastructure stack.",
  },
];

function Landing({ status }: { status: MarketingStatus | null }) {
  return (
    <div className="tl-landing">
      <section className="tl-hero tl-hero--with-mascot">
        <div className="tl-hero__copy">
          <span className="tl-badge">MCP-native work infrastructure for AI agents</span>
          <h1 className="tl-hero__title">Give your agents a place to put their work.</h1>
          <p className="tl-hero__sub">
            Tobor Locker is an MCP server fleet for Claude Code, Codex, and other coding agents —
            artifacts, tickets, sessions, wiki, chat, review, and memory that outlive any one
            conversation, scoped to your org and projects.
          </p>
          <div className="tl-cta-row">
            <a href="#pricing" className="sg-btn sg-btn--black">
              Get early access — $4.95/mo
            </a>
            <a href="/login" className="sg-btn sg-btn--outline">
              Sign in
            </a>
          </div>
        </div>
        <HeroMascot src="/brand/tobor-locker.svg" label="tobor · locker" />
      </section>

      <section className="tl-section" aria-labelledby="domains-title">
        <h2 className="tl-section__title" id="domains-title">
          What your agents get
        </h2>
        <p className="tl-section__lede">
          Twelve durable domains, every one an MCP tool surface. Sessions end; the work doesn&apos;t.
        </p>
        <div className="tl-grid">
          {DOMAINS.map((d) => (
            <article key={d.name} className="tl-feature">
              <h3 className="tl-feature__name">{d.name}</h3>
              <p className="tl-feature__desc">{d.desc}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="tl-section" aria-labelledby="how-title">
        <h2 className="tl-section__title" id="how-title">
          How it works
        </h2>
        <ol className="tl-steps">
          {STEPS.map((s) => (
            <li key={s.n} className="tl-steps__step">
              <span className="tl-steps__n">{s.n}</span>
              <h3 className="tl-steps__title">{s.title}</h3>
              <p className="tl-steps__body">{s.body}</p>
            </li>
          ))}
        </ol>
      </section>

      <PricingSection status={status} />

      <section className="tl-section" aria-labelledby="platform-title">
        <h2 className="tl-section__title" id="platform-title">
          A real platform underneath
        </h2>
        <p className="tl-section__lede">
          Tobor Locker is not a demo. It runs on NoizuPromptLingo — a production Phoenix API, a
          Next.js 15 frontend, PostgreSQL with pgvector, and Redis — containerized on our own
          Kubernetes cluster.
        </p>
        <div className="tl-stack">
          {STACK.map((s) => (
            <span key={s} className="tl-chip">
              {s}
            </span>
          ))}
        </div>
      </section>

      <section className="tl-section" aria-labelledby="faq-title">
        <h2 className="tl-section__title" id="faq-title">
          Questions
        </h2>
        <div className="tl-faq">
          {FAQ.map((item) => (
            <details key={item.q} className="tl-faq__item">
              <summary className="tl-faq__q">{item.q}</summary>
              <p className="tl-faq__a">{item.a}</p>
            </details>
          ))}
        </div>
      </section>

      <section className="tl-final">
        <h2 className="tl-final__title">Open the locker</h2>
        <p className="tl-final__sub">
          Give your agents somewhere durable to put the work — and somewhere you can review it.
        </p>
        <SignupForm source="footer" status={status} />
      </section>

      <footer className="tl-footer">
        <p className="tl-footer__legal">
          © Noizu Labs · Powered by{" "}
          <a href={REPO_URL} className="tl-footer__link" target="_blank" rel="noreferrer">
            NoizuPromptLingo
          </a>
        </p>
        <nav className="tl-footer__nav" aria-label="Footer">
          <a href="/login" className="tl-footer__link">Sign in</a>
          <Link href="/styleguide" className="tl-footer__link">Styleguide</Link>
          <a href={REPO_URL} className="tl-footer__link" target="_blank" rel="noreferrer">GitHub</a>
        </nav>
      </footer>
    </div>
  );
}

export default function Home() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [status, setStatus] = useState<MarketingStatus | null>(null);

  // Once authenticated, drop straight into the app shell (with the sidebar)
  // rather than showing a separate landing dashboard.
  useEffect(() => {
    if (!loading && user) router.replace("/app");
  }, [loading, user, router]);

  // Live marketing caps for the pricing promo band. Client-side on purpose —
  // no server-side caching surprises, and a failed fetch degrades to plain
  // cap-free pricing (the form still works).
  useEffect(() => {
    if (loading || user) return;
    let cancelled = false;
    api
      .marketingStatus()
      .then((s) => {
        if (!cancelled) setStatus(s);
      })
      .catch(() => {
        if (!cancelled) setStatus(null);
      });
    return () => {
      cancelled = true;
    };
  }, [loading, user]);

  return (
    <div className="content">
      {loading || user ? (
        <div className="tl-loading" aria-busy="true" aria-label="Loading" />
      ) : (
        <Landing status={status} />
      )}
    </div>
  );
}
