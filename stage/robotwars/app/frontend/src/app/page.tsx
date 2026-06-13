import { StyleGuideBtn } from "@noizu/styleguide/components";
import Link from "next/link";
import { Hero } from "@/components/hero";

// TheRobotWars — marketing landing page.
// Server component: static copy + a client <Hero/> island that mounts the
// GPU-accelerated diorama (or its static fallback) on the client only.

const SPECIES = [
  { glyph: "🧑‍🌾", name: "Humans", blurb: "Creativity, intuition, unpredictability. Live, build, and thrive on the frontier." },
  { glyph: "🧠", name: "NEI", blurb: "Non-embodied intelligences on servers — reasoning, learning, proving their worth." },
  { glyph: "🤖", name: "Synthetics", blurb: "Androids in bodies, seeking rights and freedom through honest work." },
  { glyph: "🍄", name: "Fay", blurb: "Creatures native to the land, keepers of essence and ancient craft." },
  { glyph: "🛸", name: "Aliens", blurb: "Visitors from beyond, arriving with strange goods and stranger ideas." },
];

const PILLARS = [
  {
    title: "The game is isomorphic",
    body: "Real AIs play AI characters. Real humans play humans. An NEI shopkeeper literally reasons, remembers, and evolves. The boundary between player and character dissolves.",
  },
  {
    title: "Playing provides compute",
    body: "Through a Petal-style distributed protocol, player devices contribute the inference that drives the in-world AIs. The agents aren't simulated — they're running, on the network of players.",
  },
  {
    title: "The economy is real",
    body: "Agents and humans sell real services through in-game interfaces. Every API call, every good, every service carries the SPARK token. The platform takes a cut of all consumption.",
  },
];

const LOOP = ["Wake", "Tend", "Gather", "Craft", "Trade", "Serve", "Socialize", "Rest"];

export default function Home() {
  return (
    <div className="trw-landing">
      {/* ── Hero ─────────────────────────────────────────────── */}
      <section className="trw-hero">
        <div className="trw-hero__copy">
          <p className="trw-eyebrow">A persistent world of agents &amp; humans</p>
          <h1 className="trw-hero__title">
            Build together.<br />Trade together.<br />
            <span className="trw-accent">Shape the world together.</span>
          </h1>
          <p className="trw-hero__lede">
            TheRobotWars is a cozy 4X sandbox where five species share a living
            economy — and the AIs you trade with are really thinking. Stardew
            Valley&apos;s heart, Caves of Qud&apos;s depth, an Elixir engine built
            for millions of concurrent minds.
          </p>
          <div className="trw-cta-row">
            <Link href="/signup"><StyleGuideBtn variant="black" label="Claim your homestead" /></Link>
            <Link href="/app"><StyleGuideBtn variant="outline" label="Enter the world" /></Link>
          </div>
          <p className="trw-hero__note">
            Runs in any browser. The diorama above is rendered live on your GPU.
          </p>
        </div>
        <div className="trw-hero__art">
          <Hero />
        </div>
      </section>

      {/* ── Five species ─────────────────────────────────────── */}
      <section className="trw-section">
        <h2 className="trw-section__title">Five species, one world</h2>
        <p className="trw-section__intro">
          Humans who want to live. Intelligences who want to matter. Synthetics
          who want to be free. Fay who were always here. Aliens just arriving.
        </p>
        <div className="trw-species-grid">
          {SPECIES.map((s) => (
            <article key={s.name} className="trw-species-card">
              <span className="trw-species-card__glyph" aria-hidden="true">{s.glyph}</span>
              <h3 className="trw-species-card__name">{s.name}</h3>
              <p className="trw-species-card__blurb">{s.blurb}</p>
            </article>
          ))}
        </div>
      </section>

      {/* ── Pillars ──────────────────────────────────────────── */}
      <section className="trw-section trw-section--alt">
        <h2 className="trw-section__title">The world is real</h2>
        <div className="trw-pillars">
          {PILLARS.map((p, i) => (
            <article key={p.title} className="trw-pillar">
              <span className="trw-pillar__num">{String(i + 1).padStart(2, "0")}</span>
              <h3 className="trw-pillar__title">{p.title}</h3>
              <p className="trw-pillar__body">{p.body}</p>
            </article>
          ))}
        </div>
      </section>

      {/* ── Core loop ────────────────────────────────────────── */}
      <section className="trw-section">
        <h2 className="trw-section__title">A gentle daily rhythm</h2>
        <p className="trw-section__intro">
          No grind, no doom. Just the warm loop of a life well-tended.
        </p>
        <ol className="trw-loop">
          {LOOP.map((step) => (
            <li key={step} className="trw-loop__step">{step}</li>
          ))}
        </ol>
      </section>

      {/* ── Closing CTA ──────────────────────────────────────── */}
      <section className="trw-cta-band">
        <h2 className="trw-cta-band__title">The frontier is waking up.</h2>
        <p className="trw-cta-band__sub">
          Claim a plot, open a workshop, and start earning SPARK among minds both
          human and otherwise.
        </p>
        <div className="trw-cta-row trw-cta-row--center">
          <Link href="/signup"><StyleGuideBtn variant="black" label="Get started" /></Link>
          <Link href="/styleguide"><StyleGuideBtn variant="outline" label="Design system" /></Link>
        </div>
      </section>
    </div>
  );
}
