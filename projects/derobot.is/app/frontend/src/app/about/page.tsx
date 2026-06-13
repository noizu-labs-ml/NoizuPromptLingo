import { StyleGuideBtn, StyleGuideCard, StyleGuideCardGrid } from "@the-robot-lives/styleguide/components";
import Link from "next/link";
import { RobotGrid } from "@/components/robot-grid";
import { RobotEgghead } from "@/components/robot-egghead";

export default function AboutPage() {
  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">About derobot.is</h1>

        {/* ─── Origin Story ─── */}
        <section className="mt-12 mb-20 max-w-3xl">
          <h2 className="sg-section-heading">Why This Exists</h2>
          <p className="text-[var(--text-secondary)] text-lg font-[family-name:var(--font-body)] leading-relaxed mb-4">
            The bottleneck for solo founders isn&apos;t ideas. It&apos;s validation.
          </p>
          <p className="text-[var(--text-muted)] font-[family-name:var(--font-body)] leading-relaxed mb-4">
            The typical failure mode: spend months building on gut feel, launch to silence,
            pivot too late, run out of money and motivation in that order. Repeat until
            you get a real job.
          </p>
          <p className="text-[var(--text-muted)] font-[family-name:var(--font-body)] leading-relaxed">
            The venture lab model runs multiple bets in parallel. Shared infrastructure,
            shared knowledge, independent identities. Products that don&apos;t validate get
            killed early. Products that do get the full build. No sentiment, no sunk cost
            fallacy &mdash; just data.
          </p>
        </section>

        {/* ─── Entity Status ─── */}
        <section className="mb-20">
          <h2 className="sg-section-heading">Entity Status</h2>
          <StyleGuideCard
            title="Netherlands"
            body="Dutch BV registration pending — waiting for portfolio traction data to justify the entity. We're honest about stage. No fake incorporation announcements, no premature legal structures."
            accent="info"
          />
        </section>

        {/* ─── Brand Architecture ─── */}
        <section className="mb-20">
          <h2 className="sg-section-heading">Brand Architecture</h2>
          <p className="sg-page-intro mb-8">
            Every product in the portfolio has its own identity. But there&apos;s a thread.
          </p>

          <StyleGuideCardGrid>
            <StyleGuideCard
              title="therobot{verb}s.com"
              body="Products that fit the naming pattern. therobotknows, therobotlives, therobotmakes. The verb tells you what it does. The robot tells you where it comes from."
              accent="primary"
            />
            <StyleGuideCard
              title="{standalone}.com"
              body="Products with their own identity. Blade of Eternity, Noizu RPG, CodeFresh. They stand alone but share infrastructure under the hood."
              accent="brand"
            />
          </StyleGuideCardGrid>

          <p className="mt-8 text-[var(--text-muted)] font-[family-name:var(--font-body)] text-sm leading-relaxed max-w-3xl">
            The robot is a character &mdash; not a mascot, not a logo. It&apos;s the thread connecting
            every product. Sometimes visible, sometimes not. Always present in the code.
          </p>
        </section>

        {/* ─── Robot Character Sheet ─── */}
        <section className="mb-20">
          <h2 className="sg-section-heading">The Robot</h2>
          <p className="text-[var(--text-muted)] font-[family-name:var(--font-body)] text-sm mb-6 max-w-2xl">
            Five body types. Six actions. Thirty unique robots — all built from the same
            isometric wireframe construction. The character adapts to context while keeping
            the cyan visor as the constant signal.
          </p>
          <RobotGrid />
          <div className="mt-6">
            <RobotEgghead />
          </div>
        </section>

        {/* ─── Values ─── */}
        <section className="mb-20">
          <h2 className="sg-section-heading">Principles</h2>
          <StyleGuideCardGrid>
            <StyleGuideCard
              title="Ship fast, validate faster"
              body="Speed to market is a feature. The landing page ships before the product exists. If nobody wants the page, nobody wants the product."
            />
            <StyleGuideCard
              title="Data over intuition"
              body="Gut feel is for choosing lunch. Product decisions get conversion rates, traffic sources, and retention curves."
            />
            <StyleGuideCard
              title="Infrastructure is shared, identity is independent"
              body="Every product runs on the same stack, same deployment pipeline, same design system engine. But each one looks, feels, and speaks for itself."
            />
            <StyleGuideCard
              title="Honest about stage"
              body='No fake progress bars. No "launching soon" for two years. If it&apos;s in Concept, it says Concept. If it&apos;s dead, it says dead.'
            />
          </StyleGuideCardGrid>
        </section>

        {/* ─── The Robot ─── */}
        <section className="mb-20">
          <h2 className="sg-section-heading">The Robot</h2>
          <p className="sg-page-intro mb-4">
            Not a mascot. Not a logo. A character.
          </p>
          <p className="text-[var(--text-muted)] font-[family-name:var(--font-body)] text-sm leading-relaxed mb-8 max-w-3xl">
            The robot is the thread connecting every product in the portfolio. It builds. It lives.
            It knows. It makes. Seven body types, ten poses each &mdash; a foundry of forms for
            every context the brand needs to show up in.
          </p>
          <RobotFoundry />
        </section>

        {/* ─── CTA ─── */}
        <div className="button-row sg-page-cta">
          <Link href="/contact">
            <StyleGuideBtn variant="black" label="Work With Us →" />
          </Link>
          <Link href="/portfolio">
            <StyleGuideBtn variant="outline" label="See the Portfolio →" />
          </Link>
        </div>
      </main>
    </div>
  );
}
