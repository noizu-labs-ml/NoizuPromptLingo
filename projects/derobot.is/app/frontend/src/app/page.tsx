import { StyleGuideBtn, StyleGuideCard, StyleGuideCardGrid } from "@the-robot-lives/styleguide/components";
import Link from "next/link";
import { RobotPoses } from "@/components/robot-poses";
import { Logo } from "@/components/logo";
import { HeroSection } from "@/components/hero-section";

const featured = [
  { name: "Blade of Eternity", domain: "bladeofeternity.com", category: "Gaming", oneLiner: "Accessibility-first text RPG with AI narrative and physics" },
  { name: "CodeFre.sh", domain: "codefre.sh", category: "Dev Tools", oneLiner: "Agent evaluation with fuzzy state machines" },
  { name: "TheRobotLives", domain: "therobotlives.com", category: "Social / Knowledge", oneLiner: "Social network where AI agents are first-class citizens" },
  { name: "IoTGo", domain: "iotgo.io", category: "Infrastructure", oneLiner: "Autonomous AI agents for IoT fleet management" },
  { name: "JailbreakingSite", domain: "jailbreakingsite.com", category: "Security", oneLiner: "Living catalog of LLM jailbreak techniques and CTF labs" },
  { name: "Gotta.cc", domain: "gotta.cc", category: "Social / Knowledge", oneLiner: "AI-curated website directory for post-slop discovery" },
];

const steps = [
  { title: "Concept", desc: "Domain secured. README written. The idea has a shape." },
  { title: "Validate", desc: "Landing page live. Ad campaigns running. KPIs tracked." },
  { title: "Build", desc: "Full product development. Real users. Iterating on feedback." },
  { title: "Scale", desc: "Revenue growing. Users retained. Ready for its own entity." },
];

export default function Home() {
  return (
    <>
      {/*
        ═══ HERO SECTION ═══
        Background: var(--surface) — the deepest ground layer.
        Parallax image prompt: Abstract isometric grid of cubes receding into depth,
        very low opacity (3-5%), zinc/cyan tones.
        Flying text activates on tagline hover — strict horizontal/vertical movement.
      */}
      <HeroSection />

      {/*
        ═══ ROBOT POSES BAR ═══
        Background: border-y divider strip on var(--surface).
        No parallax — this is a thin decorative band.
        SVG animation candidate: Robot poses could cycle through actions on hover
        or on a slow interval (swap standing → waving → building every 5s).
      */}
      <section className="border-y border-[var(--border)] px-6 py-8 overflow-hidden bg-[var(--surface)]">
        <div className="content">
          <RobotPoses size={56} />
        </div>
      </section>

      {/*
        ═══ PORTFOLIO TEASER ═══
        Background: var(--surface-alt) — lifted surface, creates depth from hero.
        Parallax image prompt: Subtle dot grid pattern (4px dots, 32px spacing),
        opacity 2-4%. Gives the section a "blueprint" feel.
        SVG animation candidate: Card hover → slight translateY(-4px) + border glow
        transition (already in css-snippets). Could add staggered fade-in on scroll
        using IntersectionObserver.
      */}
      <section id="portfolio" className="relative px-6 py-32 bg-[var(--surface-alt)]">
        <div className="content">
          <h2 className="sg-section-heading text-[var(--text)] font-[family-name:var(--font-display)] text-3xl md:text-4xl mb-12">
            The Portfolio
          </h2>
          <StyleGuideCardGrid>
            {featured.map((p) => (
              <Link key={p.domain} href={`/portfolio/${p.domain}`} className="block">
                <StyleGuideCard title={p.name} body={p.oneLiner}>
                  <span className="mt-3 block font-[family-name:var(--font-mono)] text-xs text-[var(--text-link)]">
                    {p.domain} →
                  </span>
                </StyleGuideCard>
              </Link>
            ))}
          </StyleGuideCardGrid>
          <div className="mt-10 text-center">
            <Link
              href="/portfolio"
              className="text-[var(--text-link)] font-[family-name:var(--font-mono)] text-sm hover:underline"
            >
              View all 11 products &rarr;
            </Link>
          </div>
        </div>
      </section>

      {/*
        ═══ PROCESS TEASER ═══
        Background: var(--surface) — back to the deepest layer. Alternating rhythm.
        Parallax image prompt: Faint flowchart/pipeline diagram, isometric style,
        opacity 2-3%. Arrows and diamond decision nodes barely visible.
        SVG animation candidate: Step cards fade in sequentially on scroll (200ms stagger).
        Pipeline connector line draws itself left-to-right as you scroll into view.
      */}
      <section id="process" className="relative px-6 py-32 bg-[var(--surface)]">
        <div className="content">
          <h2 className="sg-section-heading text-[var(--text)] font-[family-name:var(--font-display)] text-3xl md:text-4xl mb-12">
            The Process
          </h2>
          <StyleGuideCardGrid>
            {steps.map((s, i) => (
              <StyleGuideCard key={s.title} title={s.title} body={s.desc}>
                <span className="font-[family-name:var(--font-mono)] text-xs text-[var(--text-link)]" style={{ marginTop: "-8px", display: "block" }}>
                  0{i + 1}
                </span>
              </StyleGuideCard>
            ))}
          </StyleGuideCardGrid>
          <div className="mt-10 text-center">
            <Link
              href="/process"
              className="text-[var(--text-link)] font-[family-name:var(--font-mono)] text-sm hover:underline"
            >
              Learn more about our methodology &rarr;
            </Link>
          </div>
        </div>
      </section>

      {/*
        ═══ ABOUT TEASER ═══
        Background: var(--surface-alt) — lifted layer again.
        Parallax image prompt: World map with Netherlands highlighted (single dot or
        subtle pin), extremely faint (2% opacity). Or: abstract network graph showing
        connected nodes (products linked to a central hub).
        SVG animation candidate: None — keep this section static and typographic.
        The restraint here contrasts with the animated sections above.
      */}
      <section id="about" className="relative px-6 py-32 bg-[var(--surface-alt)]">
        <div className="content max-w-2xl">
          <h2 className="sg-section-heading text-[var(--text)] font-[family-name:var(--font-display)] text-3xl md:text-4xl mb-6">
            About
          </h2>
          <p className="text-lg text-[var(--text-secondary)] leading-relaxed">
            Based in the Netherlands. Building an AI-native product portfolio.
            Shared infrastructure, independent identities.
          </p>
          <div className="mt-8">
            <Link href="/about">
              <StyleGuideBtn variant="outline" label="About Us →" />
            </Link>
          </div>
        </div>
      </section>

      {/*
        ═══ CONTACT TEASER ═══
        Background: var(--surface) — deepest layer. Creates gravity at bottom of page.
        Parallax image prompt: Concentric circles radiating outward from center,
        very low opacity (2-3%), suggesting "signal" or "broadcast." Cyan tint.
        SVG animation candidate: Concentric rings pulse outward slowly (scale + opacity
        keyframes, 6-8s cycle). Subtle "we're transmitting" signal effect.
      */}
      <section id="contact" className="relative px-6 py-32 bg-[var(--surface)]">
        <div className="content max-w-2xl text-center">
          <h2 className="sg-section-heading text-[var(--text)] font-[family-name:var(--font-display)] text-3xl md:text-4xl mb-6">
            Get in Touch
          </h2>
          <p className="text-lg text-[var(--text-muted)] leading-relaxed">
            Builders, investors, collaborators &mdash; we&rsquo;d like to hear from you.
          </p>
          <div className="mt-8">
            <Link href="/contact">
              <StyleGuideBtn variant="black" label="Contact Us →" />
            </Link>
          </div>
        </div>
      </section>

      {/*
        ═══ FOOTER ═══
        Background: inherits var(--surface) from body. Border-top separates.
        No parallax. No animation. The footer is structural, not decorative.
      */}
      <footer className="border-t border-[var(--border)] px-6 py-12 bg-[var(--surface)]">
        <div className="content flex flex-col md:flex-row justify-between gap-8">
          <div>
            <Logo size={20} />
            <p className="mt-2 text-sm text-[var(--text-muted)]">
              Based in the Netherlands. Pending legal entity.
            </p>
          </div>
          <nav className="flex flex-wrap gap-6 text-sm font-[family-name:var(--font-mono)]">
            <Link href="/portfolio" className="text-[var(--text-muted)] hover:text-[var(--text)]">Portfolio</Link>
            <Link href="/process" className="text-[var(--text-muted)] hover:text-[var(--text)]">Process</Link>
            <Link href="/about" className="text-[var(--text-muted)] hover:text-[var(--text)]">About</Link>
            <Link href="/contact" className="text-[var(--text-muted)] hover:text-[var(--text)]">Contact</Link>
            <Link href="/styleguide" className="text-[var(--text-muted)] hover:text-[var(--text)]">Styleguide</Link>
            <Link href="/sitemap" className="text-[var(--text-muted)] hover:text-[var(--text)]">Sitemap</Link>
          </nav>
        </div>
      </footer>
    </>
  );
}
