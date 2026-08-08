"use client";

import { StyleGuideBtn } from "@noizu/styleguide/components";
import Link from "next/link";
import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/auth";
import { HeroMascot } from "@/components/landing/hero-mascot";

const MCP_DOMAINS = [
  { name: "Artifacts", desc: "Create, version, and retrieve typed content objects across every session." },
  { name: "Sessions", desc: "Group rooms, artifacts, and tickets into durable units of work agents can resume." },
  { name: "Tickets", desc: "Track tickets, queues, and custom fields — the backlog your agents read and write." },
  { name: "Wiki", desc: "Spaces, pages, permissions, and attachments for living institutional knowledge." },
  { name: "Chat", desc: "Rooms, messages, members, and notifications for human ↔ agent collaboration." },
  { name: "Review", desc: "Open reviews, add inline comments and overlays, and compile structured feedback." },
  { name: "Projects", desc: "Spin up projects, manage members and invitations, and scope work cleanly." },
  { name: "Assets", desc: "Media prompt entries, generation, evaluation, and publishing in one pipeline." },
];

const PLATFORM = [
  { title: "Auth & SSO, ready", body: "Guardian JWT plus OIDC, SAML, Google, GitHub, and LinkedIn via Ueberauth — invite-only mode included." },
  { title: "YAML-driven design", body: "Twelve seed tokens expand into 300+ CSS properties through the @noizu/styleguide engine." },
  { title: "Containerized & shippable", body: "Three-container stack with multi-arch Docker images and a publishable Helm chart for Kubernetes." },
  { title: "Live remote sandbox", body: "Mount /workspace over SMB and edit in place — Next.js and Phoenix watchers rebuild on save." },
];

const STACK = ["Elixir 1.19", "Phoenix 1.8", "Next.js 15", "React 19", "PostgreSQL · pgvector", "Redis", "Tailwind v4", "Helm"];

const BOARD_PREVIEW = [
  {
    stage: "Backlog",
    tickets: [
      { title: "Draft agent onboarding runbook", type: "documentation", priority: "medium" },
      { title: "Map MCP tool coverage gaps", type: "research", priority: "high" },
    ],
  },
  {
    stage: "In Progress",
    tickets: [
      { title: "Wire board cards to project scope", type: "task", priority: "high" },
      { title: "Review session artifact lifecycle", type: "prd", priority: "medium" },
    ],
  },
  {
    stage: "Review",
    tickets: [
      { title: "Validate SSO callback routing", type: "bug", priority: "critical" },
    ],
  },
];

function Landing() {
  return (
    <div className="tl-landing">
      <section className="tl-hero tl-hero--with-mascot">
        <div className="tl-hero__copy">
          <span className="tl-badge">Model Context Protocol server</span>
          <h1 className="tl-hero__title">
            Tobor Locker <span className="tl-hero__mcp">(MCP)</span>
          </h1>
          <p className="tl-hero__sub">
            One MCP-native workspace your agents can actually live in. Artifacts, sessions, tickets,
            wiki, chat, and review — exposed as tools, backed by a production Phoenix API, and wired
            for SSO from day one.
          </p>
          <div className="tl-cta-row">
            <a href="/login"><StyleGuideBtn variant="black" label="Sign in to your locker" /></a>
            <Link href="/styleguide"><StyleGuideBtn variant="outline" label="View the design system" /></Link>
          </div>
        </div>
        <HeroMascot src="/brand/tobor-locker.svg" label="tobor · locker" />
      </section>

      <section className="tlk-band" aria-label="Vault note">
        <div className="tlk-band__frame">
          <span className="tlk-band__tag">[locked]</span>
          <p className="tlk-band__text">
            Key on the ring, vault in the chest — tobor holds agent work so sessions, tickets, and
            artifacts stay where your tools can find them.
          </p>
        </div>
      </section>

      <section className="tl-section tl-board-preview" aria-labelledby="board-preview-title">
        <div>
          <h2 id="board-preview-title" className="tl-section__title">Work cards, before the shell</h2>
          <p className="tl-section__lede">
            The same ticket-card language used inside the logged-in workspace is visible here as
            a public preview of how Tobor Locker organizes agent work.
          </p>
        </div>
        <div className="tl-board-preview__board" aria-label="Example project board">
          {BOARD_PREVIEW.map((column) => (
            <div key={column.stage} className="tl-board-preview__col">
              <div className="tl-board-preview__head">
                <span>{column.stage}</span>
                <span>{column.tickets.length}</span>
              </div>
              <div className="tl-board-preview__cards">
                {column.tickets.map((ticket) => (
                  <article key={ticket.title} className="tl-board-preview__card">
                    <h3>{ticket.title}</h3>
                    <div className="tl-board-preview__meta">
                      <span>{ticket.type}</span>
                      <span>{ticket.priority}</span>
                    </div>
                  </article>
                ))}
              </div>
            </div>
          ))}
        </div>
      </section>

      <section className="tl-section">
        <h2 className="tl-section__title">Eight domains, one protocol</h2>
        <p className="tl-section__lede">
          Every capability is a first-class MCP domain. Discover the tools, call them, and let your
          agents compose work across them without leaving the conversation.
        </p>
        <div className="tl-grid">
          {MCP_DOMAINS.map((d) => (
            <article key={d.name} className="tl-feature">
              <h3 className="tl-feature__name">{d.name}</h3>
              <p className="tl-feature__desc">{d.desc}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="tl-section">
        <h2 className="tl-section__title">A real platform underneath</h2>
        <p className="tl-section__lede">
          Tobor Locker is not a demo. It ships on the start-app stack: a Phoenix 1.8 JSON API, a
          Next.js 15 frontend, and an nginx reverse proxy — containerized and Kubernetes-ready.
        </p>
        <div className="tl-grid tl-grid--two">
          {PLATFORM.map((p) => (
            <article key={p.title} className="tl-feature">
              <h3 className="tl-feature__name">{p.title}</h3>
              <p className="tl-feature__desc">{p.body}</p>
            </article>
          ))}
        </div>
        <div className="tl-stack">
          {STACK.map((s) => (
            <span key={s} className="tl-chip">{s}</span>
          ))}
        </div>
      </section>

      <section className="tl-final">
        <h2 className="tl-final__title">Open the locker</h2>
        <p className="tl-final__sub">Sign in with your identity provider and start building on top of the toolchain.</p>
        <div className="tl-cta-row">
          <a href="/login"><StyleGuideBtn variant="black" label="Sign in" /></a>
          <Link href="/sitemap"><StyleGuideBtn variant="outline" label="Explore the site map" /></Link>
        </div>
      </section>
    </div>
  );
}

export default function Home() {
  const { user, loading } = useAuth();
  const router = useRouter();

  // Once authenticated, drop straight into the app shell (with the sidebar)
  // rather than showing a separate landing dashboard.
  useEffect(() => {
    if (!loading && user) router.replace("/app");
  }, [loading, user, router]);

  return (
    <div className="content">
      {loading || user ? (
        <div className="tl-loading" aria-busy="true" aria-label="Loading" />
      ) : (
        <Landing />
      )}
    </div>
  );
}
