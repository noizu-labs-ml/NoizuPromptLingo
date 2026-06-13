import { StyleGuideBtn, StyleGuideCard, StyleGuideCardGrid } from "@the-robot-lives/styleguide/components";
import Link from "next/link";
import { PipelineFlow } from "@/components/pipeline-flow";
import { DecisionFlow } from "@/components/decision-flow";

const stages = [
  {
    title: "Idea to Spec",
    duration: "3–5 hours",
    description: "Personas, user stories, use cases, component inventory, possible style guides and branding options. The idea gets shaped into something testable.",
    artifacts: ["User personas", "User stories + use cases", "Component inventory", "Style guide / branding options"],
  },
  {
    title: "Landing Page",
    duration: "1–8 hours",
    description: "Spec + stories become a conversion-focused landing page. Multiple branding/theme variants for A/B testing against different audiences.",
    artifacts: ["Landing page (live)", "2–3 theme variants", "Signup / interest capture", "Analytics integration"],
  },
  {
    title: "LTV Estimation",
    duration: "Concurrent",
    description: "Gauge lifetime customer value across different price models. This sets the benchmark — if acquisition cost exceeds LTV, the economics don't work.",
    artifacts: ["Price tier analysis", "LTV projections", "CAC threshold target", "Break-even timeline"],
  },
  {
    title: "Ad Validation",
    duration: "1–3 weeks",
    description: "Mini targeted ad runs against different branding/theme versions. Measure click-through, engagement depth, and signup interest. The market votes.",
    artifacts: ["Ad campaigns (Meta/Google/LinkedIn)", "KPI dashboard", "Variant performance comparison", "Best-performing variant identified"],
  },
  {
    title: "Beta Prototype",
    duration: "2–14 days",
    description: "If CAC < LTV on the best variant, build the real thing. Next.js + Elixir, purchase integration, real features. Ship fast.",
    artifacts: ["Working prototype", "Purchase / payment flow", "Usage tracking", "KPI instrumentation"],
  },
  {
    title: "KPI Monitoring",
    duration: "Ongoing",
    description: "Target usage levels plus conversion metrics. Even if some KPIs lag, continue unless they diverge significantly from target.",
    artifacts: ["Conversion rate tracking", "Usage engagement metrics", "Retention curves", "Revenue per user"],
  },
  {
    title: "Scale",
    duration: "Ongoing",
    description: "Feature build-out, marketing, refinement. The product earns its keep. Ongoing until the spinoff threshold is met.",
    artifacts: ["Feature roadmap execution", "Marketing expansion", "Team scaling (if needed)", "Revenue growth"],
  },
  {
    title: "Spinoff",
    duration: "When ready",
    description: "Own BV. Own P&L. Own board. The product graduates from the lab and becomes a standalone company under Dutch law.",
    artifacts: ["Dutch BV registered", "Independent P&L", "Own governance", "Portfolio equity retained"],
  },
];

const decisions = [
  {
    label: "Kill",
    accent: "danger" as const,
    body: "CAC exceeds LTV. No signal after targeted traffic. Shut it down, reclaim the domain budget, free the resources, move on.",
  },
  {
    label: "Iterate",
    accent: "warning" as const,
    body: "Marginal results. Some signal but not enough. Try a different variant, adjust the audience targeting, reframe the positioning. Re-test.",
  },
  {
    label: "Build",
    accent: "success" as const,
    body: "CAC below LTV. Organic interest appearing. The economics work. Green light — move to beta prototype.",
  },
];

export default function ProcessPage() {
  return (
    <div className="content">
      <main>
        {/* ─── Header ─── */}
        <h1 className="sg-page-title">The Process</h1>
        <p className="sg-page-intro">How we validate before we build.</p>

        {/* ─── Intro ─── */}
        <section style={{ marginTop: "var(--space-8)", marginBottom: "var(--space-10)", maxWidth: "720px" }}>
          <p className="text-[var(--text-secondary)] text-lg font-[family-name:var(--font-body)] leading-relaxed mb-6">
            The venture lab treats every product idea as an experiment. No business plans.
            No pitch decks. No six-month roadmaps built on vibes.
          </p>
          <p className="text-[var(--text-muted)] font-[family-name:var(--font-body)] leading-relaxed">
            Instead: spec the idea in hours, build a landing page, run ads against multiple
            theme variants, read the data, check if customer acquisition cost is below lifetime
            value. If yes, build. If no, kill. Most ideas die in validation. That&apos;s the point.
          </p>
        </section>

        {/* ─── Pipeline Flow Diagram ─── */}
        <section style={{ marginBottom: "var(--space-10)" }}>
          <h2 className="sg-section-heading">Pipeline</h2>
          <PipelineFlow />
        </section>

        {/* ─── Stage Detail Cards ─── */}
        <section style={{ marginBottom: "var(--space-10)" }}>
          <h2 className="sg-section-heading" style={{ marginBottom: "var(--space-8)" }}>Stage Details</h2>
          <div className="space-y-8">
            {stages.map((stage, i) => (
              <StyleGuideCard key={stage.title} title={stage.title}>
                <div className="flex items-baseline gap-3 mb-4" style={{ marginTop: "-4px" }}>
                  <span className="text-xs text-[var(--text-link)] font-[family-name:var(--font-mono)]">
                    {stage.duration}
                  </span>
                </div>
                <p className="text-sm text-[var(--text-secondary)] font-[family-name:var(--font-body)] leading-relaxed mb-5">
                  {stage.description}
                </p>
                <ul className="space-y-1.5">
                  {stage.artifacts.map((a) => (
                    <li key={a} className="text-xs text-[var(--text-muted)] font-[family-name:var(--font-mono)]">
                      → {a}
                    </li>
                  ))}
                </ul>
              </StyleGuideCard>
            ))}
          </div>
        </section>

        {/* ─── Decision Flow Diagram ─── */}
        <section style={{ marginBottom: "var(--space-10)" }}>
          <h2 className="sg-section-heading" style={{ marginBottom: "var(--space-5)" }}>Validation Loop</h2>
          <p className="text-[var(--text-secondary)] font-[family-name:var(--font-body)] text-sm leading-relaxed max-w-3xl" style={{ marginBottom: "var(--space-8)" }}>
            The core decision mechanism. Multiple landing page variants compete in mini ad runs.
            The winning variant&apos;s acquisition cost is compared against estimated lifetime customer value.
            If the economics work, build. If not, iterate or kill.
          </p>
          <DecisionFlow />
        </section>

        {/* ─── Decision Principles ─── */}
        <section style={{ marginBottom: "var(--space-10)" }}>
          <h2 className="sg-section-heading" style={{ marginBottom: "var(--space-8)" }}>Decision Principles</h2>
          <p className="text-2xl font-bold text-[var(--text-link)] font-[family-name:var(--font-display)]" style={{ marginBottom: "var(--space-10)" }}>
            &ldquo;The robot builds. The market decides.&rdquo;
          </p>

          <div className="space-y-6">
            {decisions.map((d) => (
              <StyleGuideCard key={d.label} variant={d.accent} title={d.label}>
                <p className="text-[var(--text-secondary)] font-[family-name:var(--font-body)] text-sm leading-relaxed">
                  {d.body}
                </p>
              </StyleGuideCard>
            ))}
          </div>
        </section>

        {/* ─── CTA ─── */}
        <div className="button-row sg-page-cta" style={{ paddingTop: "var(--space-8)" }}>
          <Link href="/portfolio">
            <StyleGuideBtn variant="black" label="See the Portfolio →" />
          </Link>
          <Link href="/contact">
            <StyleGuideBtn variant="outline" label="Get in Touch →" />
          </Link>
        </div>
      </main>
    </div>
  );
}
