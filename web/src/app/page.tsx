import { WaitlistForm } from "./waitlist-form";

/* ═══════════════════════════════════════════════
   ASTERISK MARK — Inline SVG logomark component
   3 rounded bars at 0°/60°/120° = 6-armed asterisk
   ═══════════════════════════════════════════════ */
function AsteriskMark({ className = "h-7 w-7" }: { className?: string }) {
  return (
    <svg
      className={`shrink-0 ${className}`}
      viewBox="0 0 200 200"
      aria-hidden="true"
    >
      <g transform="translate(100,100)" style={{ fill: "var(--coral)" }}>
        <rect x="-8" y="-65" width="16" height="130" rx="8" />
        <rect x="-8" y="-65" width="16" height="130" rx="8" transform="rotate(60)" />
        <rect x="-8" y="-65" width="16" height="130" rx="8" transform="rotate(120)" />
      </g>
    </svg>
  );
}

export default function Home() {
  return (
    <div className="min-h-screen bg-cream">
      <Nav />
      <Hero />
      <Rule />
      <Problem />
      <Rule />
      <Scoring />
      <Rule />
      <Categories />
      <Rule />
      <Features />
      <Rule />
      <FinalCTA />
      <Footer />
    </div>
  );
}

/* ═══════════════════════════════════════════════
   RULE — Editorial horizontal divider
   ═══════════════════════════════════════════════ */
function Rule() {
  return (
    <div className="px-6" aria-hidden="true">
      <div className="mx-auto max-w-[960px] border-t border-rule" />
    </div>
  );
}

/* ═══════════════════════════════════════════════
   NAV
   ═══════════════════════════════════════════════ */
function Nav() {
  return (
    <nav className="sticky top-0 z-50 border-b border-rule bg-cream/95 backdrop-blur-sm">
      <div className="mx-auto flex max-w-[960px] items-center justify-between px-6 py-4">
        <a
          href="/"
          className="flex items-center gap-2.5"
        >
          <AsteriskMark className="h-7 w-7" />
          <span
            className="font-display text-2xl font-bold text-ink"
            style={{ fontVariationSettings: "'WONK' 1" }}
          >
            gotta.cc
          </span>
        </a>
        <div className="flex items-center gap-8">
          <a
            href="#categories"
            className="hidden font-ui text-sm font-semibold text-ink-secondary transition-colors duration-200 hover:text-ink sm:inline"
          >
            Browse
          </a>
          <a
            href="#scoring"
            className="hidden font-ui text-sm font-semibold text-ink-secondary transition-colors duration-200 hover:text-ink sm:inline"
          >
            How It Works
          </a>
          <a
            href="#waitlist"
            className="rounded-xl bg-coral px-5 py-2 font-ui text-sm font-semibold text-white transition-all duration-150 hover:-translate-y-0.5 hover:bg-coral-hover"
          >
            Join Waitlist
          </a>
        </div>
      </div>
    </nav>
  );
}

/* ═══════════════════════════════════════════════
   HERO
   ═══════════════════════════════════════════════ */
function Hero() {
  return (
    <section className="px-6 py-20 lg:py-28">
      <div className="mx-auto max-w-[960px]">
        {/* Overline */}
        <p className="mb-6 font-ui text-xs font-bold uppercase tracking-[0.08em] text-olive">
          AI-Curated Web Directory
        </p>

        {/* Headline */}
        <h1
          className="font-display text-[clamp(36px,5vw+1rem,56px)] font-semibold leading-[1.15] tracking-tight text-ink"
          style={{ fontVariationSettings: "'WONK' 1" }}
        >
          The web is big again.
        </h1>

        {/* Subheadline — editorial voice in body serif */}
        <p className="mt-6 max-w-2xl font-body text-lg leading-relaxed text-ink-secondary">
          Browse curated categories. Read editorial summaries. Discover sites
          scored for originality, depth, and human authorship. Like the Yahoo
          Directory, but for the post-slop web — powered by AI that rates
          quality instead of gaming it.
        </p>

        {/* CTA */}
        <div id="waitlist" className="mt-10">
          <WaitlistForm buttonText="Get Early Access" />
        </div>

        <p className="mt-4 font-ui text-xs text-ink-tertiary">
          Free during beta &middot; No credit card required
        </p>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   PROBLEM
   ═══════════════════════════════════════════════ */
function Problem() {
  const problems = [
    {
      number: "01",
      title: "Search is SEO-gamed",
      description:
        "74% of newly published English web pages contain AI-generated content. The first page of results for any commercial query is a content farm. You search for \"best standing desk\" and get 10 affiliate sites that have never touched a desk.",
    },
    {
      number: "02",
      title: "Discovery is fragmented",
      description:
        "You bounce between Google, Reddit, TikTok, and Hacker News because no single source is trusted. Each channel has its own bias — Google favors big brands, Reddit favors recency, Product Hunt favors novelty. Nobody favors quality.",
    },
    {
      number: "03",
      title: "The good web is invisible",
      description:
        "Thousands of excellent personal sites, niche blogs, and indie tools exist but have zero SEO. They don't play the game. The blogroll revival and indie web movement signal the same thing: people want to find real humans making real things.",
    },
  ];

  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-[960px]">
        <p className="font-ui text-xs font-bold uppercase tracking-[0.08em] text-olive">
          The Problem
        </p>
        <h2
          className="mt-3 font-display text-2xl font-semibold tracking-tight text-ink sm:text-3xl"
          style={{ fontVariationSettings: "'WONK' 1" }}
        >
          Web discovery is broken
        </h2>

        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {problems.map((p) => (
            <div
              key={p.number}
              className="rounded-2xl bg-surface p-6 shadow-[0_2px_8px_rgba(0,0,0,0.06)]"
            >
              <span className="font-display text-sm font-bold text-coral">
                {p.number}
              </span>
              <h3 className="mt-2 font-display text-xl font-medium text-ink">
                {p.title}
              </h3>
              <p className="mt-3 font-body text-sm leading-relaxed text-ink-secondary">
                {p.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   SCORING — The 5-dimension quality system
   ═══════════════════════════════════════════════ */
const SCORE_DIMENSIONS = [
  {
    name: "Originality",
    weight: "30%",
    score: 96,
    description: "Not a clone, not aggregated. Has a distinctive voice.",
  },
  {
    name: "Human Authorship",
    weight: "25%",
    score: 99,
    description: "Written by a human. Personal anecdotes, unique phrasing.",
  },
  {
    name: "Depth",
    weight: "20%",
    score: 91,
    description: "Long-form content, archives, sustained focus on topic.",
  },
  {
    name: "Freshness",
    weight: "15%",
    score: 88,
    description: "Recently updated. No link rot. Working features.",
  },
  {
    name: "Design Quality",
    weight: "10%",
    score: 92,
    description: "Usable, accessible, intentional. Respects its visitors.",
  },
];

function Scoring() {
  return (
    <section id="scoring" className="px-6 py-20">
      <div className="mx-auto max-w-[960px]">
        <p className="font-ui text-xs font-bold uppercase tracking-[0.08em] text-olive">
          How It Works
        </p>
        <h2
          className="mt-3 font-display text-2xl font-semibold tracking-tight text-ink sm:text-3xl"
          style={{ fontVariationSettings: "'WONK' 1" }}
        >
          Every site is scored. Nothing is faked.
        </h2>
        <p className="mt-4 max-w-2xl font-body text-base leading-relaxed text-ink-secondary">
          AI evaluates every listed site across five dimensions. Sites below
          60/100 are not listed. Sites above 90 get an Editor&apos;s Pick badge.
          The threshold is the editorial floor — AI sets the bar, humans raise
          it.
        </p>

        {/* Example site card + score breakdown */}
        <div className="mt-12 grid items-start gap-8 lg:grid-cols-[1fr_280px]">
          {/* Score bars */}
          <div className="rounded-2xl bg-surface p-6 shadow-[0_2px_8px_rgba(0,0,0,0.06)]">
            <div className="mb-1 flex items-center gap-3">
              <p className="font-ui text-xs font-bold uppercase tracking-[0.08em] text-olive">
                Technology / Interviews
              </p>
            </div>
            <h3
              className="font-display text-2xl font-medium text-ink"
              style={{ fontVariationSettings: "'WONK' 1" }}
            >
              Uses This
            </h3>
            <p className="mt-2 max-w-[55ch] font-body text-base leading-relaxed text-ink-secondary">
              Interviews with creative people about the hardware, software, and
              tools they use to get their work done. Running since 2009.
              Focused, niche, lovingly maintained.
            </p>
            <p className="mt-2 font-mono text-sm text-ink-tertiary">
              uses-this.com
            </p>

            {/* Score breakdown bars */}
            <div className="mt-6 flex flex-col gap-3">
              {SCORE_DIMENSIONS.map((d) => (
                <div
                  key={d.name}
                  className="grid grid-cols-[120px_1fr_32px] items-center gap-3"
                >
                  <span className="text-right font-ui text-xs font-medium text-ink-secondary">
                    {d.name}
                  </span>
                  <div className="h-1.5 overflow-hidden rounded-full bg-sunken">
                    <div
                      className="h-full rounded-full transition-all duration-700"
                      style={{
                        width: `${d.score}%`,
                        background:
                          d.score >= 90
                            ? "var(--score-high)"
                            : d.score >= 70
                              ? "var(--score-medium)"
                              : "var(--score-low)",
                      }}
                    />
                  </div>
                  <span className="text-right font-ui text-xs font-semibold text-ink">
                    {d.score}
                  </span>
                </div>
              ))}
            </div>

            {/* Tags */}
            <div className="mt-5 flex flex-wrap gap-2">
              {["interviews", "tools", "creative", "indie-web"].map((tag) => (
                <span
                  key={tag}
                  className="rounded-lg border border-rule px-3 py-1 font-ui text-xs font-medium text-ink-secondary"
                >
                  {tag}
                </span>
              ))}
            </div>
          </div>

          {/* Score badge — large */}
          <div className="flex flex-col items-center gap-4">
            <div className="flex h-20 w-20 flex-col items-center justify-center rounded-full bg-score-high text-white">
              <span
                className="font-display text-3xl font-bold leading-none"
                style={{ fontVariationSettings: "'WONK' 1" }}
              >
                94
              </span>
              <span className="font-ui text-[10px] font-medium opacity-85">
                /100
              </span>
            </div>
            <span className="font-ui text-xs font-bold uppercase tracking-wider text-coral">
              Editor&apos;s Pick
            </span>

            {/* Weight breakdown */}
            <div className="w-full rounded-2xl bg-surface p-5 shadow-[0_2px_8px_rgba(0,0,0,0.06)]">
              <p className="mb-3 font-ui text-xs font-bold uppercase tracking-[0.06em] text-ink-tertiary">
                Score Weights
              </p>
              {SCORE_DIMENSIONS.map((d) => (
                <div
                  key={d.name}
                  className="flex items-baseline justify-between border-b border-sunken py-2 last:border-0"
                >
                  <span className="font-ui text-xs text-ink-secondary">
                    {d.name}
                  </span>
                  <span className="font-ui text-xs font-semibold text-ink">
                    {d.weight}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   CATEGORIES — Bento grid preview
   ═══════════════════════════════════════════════ */
const CATEGORIES = [
  {
    name: "Technology",
    count: 247,
    featured: "uses-this.com",
    featuredScore: 94,
    bgClass: "bg-cat-technology-bg",
    textClass: "text-cat-technology-text",
    dotColor: "bg-cat-technology",
    span: "md:col-span-2",
  },
  {
    name: "Culture",
    count: 189,
    featured: "craigmod.com",
    featuredScore: 91,
    bgClass: "bg-cat-culture-bg",
    textClass: "text-cat-culture-text",
    dotColor: "bg-cat-culture",
    span: "",
  },
  {
    name: "Science",
    count: 156,
    featured: null,
    featuredScore: null,
    bgClass: "bg-cat-science-bg",
    textClass: "text-cat-science-text",
    dotColor: "bg-cat-science",
    span: "",
  },
  {
    name: "Making & Crafts",
    count: 98,
    featured: null,
    featuredScore: null,
    bgClass: "bg-cat-making-bg",
    textClass: "text-cat-making-text",
    dotColor: "bg-cat-making",
    span: "",
  },
  {
    name: "Games",
    count: 134,
    featured: null,
    featuredScore: null,
    bgClass: "bg-cat-games-bg",
    textClass: "text-cat-games-text",
    dotColor: "bg-cat-games",
    span: "md:col-span-2",
  },
  {
    name: "Weird & Wonderful",
    count: 73,
    featured: "wiby.me",
    featuredScore: 87,
    bgClass: "bg-cat-weird-bg",
    textClass: "text-cat-weird-text",
    dotColor: "bg-cat-weird",
    span: "md:col-span-2",
  },
];

function Categories() {
  return (
    <section id="categories" className="px-6 py-20">
      <div className="mx-auto max-w-[960px]">
        <p className="font-ui text-xs font-bold uppercase tracking-[0.08em] text-olive">
          Browse
        </p>
        <h2
          className="mt-3 font-display text-2xl font-semibold tracking-tight text-ink sm:text-3xl"
          style={{ fontVariationSettings: "'WONK' 1" }}
        >
          Navigate the web by topic
        </h2>
        <p className="mt-4 max-w-2xl font-body text-base leading-relaxed text-ink-secondary">
          No algorithms. No infinite scroll. Just a directory organized by
          humans, scored by AI. Click a category and start exploring.
        </p>

        {/* Bento grid */}
        <div className="mt-12 grid grid-cols-1 gap-5 sm:grid-cols-2 md:grid-cols-3">
          {CATEGORIES.map((cat) => (
            <div
              key={cat.name}
              className={`flex min-h-[180px] cursor-pointer flex-col justify-between rounded-2xl p-7 transition-all duration-200 hover:scale-[1.02] hover:shadow-[0_8px_24px_rgba(0,0,0,0.08)] ${cat.bgClass} ${cat.textClass} ${cat.span}`}
            >
              <div>
                <h3
                  className="font-display text-2xl font-semibold"
                  style={{ fontVariationSettings: "'WONK' 1" }}
                >
                  {cat.name}
                </h3>
                <p className="mt-1 font-ui text-sm font-medium opacity-70">
                  {cat.count} sites
                </p>
              </div>

              {cat.featured && (
                <div className="mt-4 flex items-center gap-2 border-t border-black/10 pt-4">
                  <span
                    className={`h-2 w-2 flex-shrink-0 rounded-full ${cat.dotColor}`}
                  />
                  <span className="font-ui text-[13px] font-medium">
                    {cat.featured}
                  </span>
                  <span className="ml-auto font-display text-sm font-bold text-coral">
                    {cat.featuredScore}
                  </span>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   FEATURES
   ═══════════════════════════════════════════════ */
function Features() {
  const features = [
    {
      icon: "🗂",
      title: "Category Browser",
      description:
        "Browse a hierarchical tree of 200+ categories. Visual browsing with site counts, featured picks, and deep-linking to any level.",
    },
    {
      icon: "🛡",
      title: "Anti-Slop Defense",
      description:
        "Human authorship scoring detects AI-generated text. Originality scoring catches content farms. Community flagging triggers manual review.",
    },
    {
      icon: "📝",
      title: "Editorial Summaries",
      description:
        "Every listed site gets an AI-generated editorial summary — concise, opinionated, useful. Not a keyword dump. A recommendation.",
    },
    {
      icon: "🎲",
      title: "Surprise Me",
      description:
        "Can't decide? Hit the button and land on a random high-quality site you've never heard of. The web is full of surprises.",
    },
    {
      icon: "📚",
      title: "Curated Collections",
      description:
        "\"Best personal blogs.\" \"Indie tools that actually work.\" Editor-curated lists updated regularly, plus user-created public collections.",
    },
    {
      icon: "📤",
      title: "Submit a Site",
      description:
        "Know a great site the directory is missing? Submit it. AI scores it across 5 dimensions. If it passes the bar, it gets listed.",
    },
  ];

  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-[960px]">
        <p className="font-ui text-xs font-bold uppercase tracking-[0.08em] text-olive">
          Features
        </p>
        <h2
          className="mt-3 font-display text-2xl font-semibold tracking-tight text-ink sm:text-3xl"
          style={{ fontVariationSettings: "'WONK' 1" }}
        >
          Everything you need to explore the web
        </h2>

        <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((f) => (
            <div
              key={f.title}
              className="rounded-2xl bg-surface p-6 shadow-[0_2px_8px_rgba(0,0,0,0.06)] transition-all duration-200 hover:-translate-y-0.5 hover:shadow-[0_8px_24px_rgba(0,0,0,0.08)]"
            >
              <span className="text-2xl" role="img" aria-hidden="true">
                {f.icon}
              </span>
              <h3 className="mt-3 font-display text-lg font-medium text-ink">
                {f.title}
              </h3>
              <p className="mt-2 font-body text-sm leading-relaxed text-ink-secondary">
                {f.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   FINAL CTA
   ═══════════════════════════════════════════════ */
function FinalCTA() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-xl text-center">
        <p
          className="font-display text-xl font-medium italic text-ink-secondary"
          style={{ fontVariationSettings: "'WONK' 1" }}
        >
          &ldquo;Someone smart picked these for you.&rdquo;
        </p>
        <h2
          className="mt-6 font-display text-2xl font-semibold tracking-tight text-ink sm:text-3xl"
          style={{ fontVariationSettings: "'WONK' 1" }}
        >
          The directory launches soon.
          <br />
          Be first to browse.
        </h2>
        <p className="mx-auto mt-4 max-w-md font-body text-base leading-relaxed text-ink-secondary">
          We&apos;re curating the first 500 sites across every category. Early
          members get lifetime access to submit, save, and collect.
        </p>

        <div className="mt-8">
          <WaitlistForm buttonText="Join the Waitlist" />
        </div>

        <p className="mt-4 font-ui text-xs text-ink-tertiary">
          Early members get unlimited submissions &middot; Forever
        </p>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   FOOTER
   ═══════════════════════════════════════════════ */
function Footer() {
  return (
    <footer className="border-t border-rule px-6 py-6">
      <div className="mx-auto flex max-w-[960px] flex-col items-center justify-between gap-4 sm:flex-row">
        <span className="flex items-center gap-1.5 font-ui text-xs text-ink-tertiary">
          <AsteriskMark className="h-3.5 w-3.5" />
          &copy; 2026 gotta.cc
        </span>
        <div className="flex gap-6">
          <a
            href="#"
            className="font-ui text-xs text-ink-tertiary transition-colors duration-150 hover:text-ink-secondary"
          >
            Privacy
          </a>
          <a
            href="#"
            className="font-ui text-xs text-ink-tertiary transition-colors duration-150 hover:text-ink-secondary"
          >
            Terms
          </a>
        </div>
      </div>
    </footer>
  );
}
