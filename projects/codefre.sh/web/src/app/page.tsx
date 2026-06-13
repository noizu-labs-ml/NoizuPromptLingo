import { WaitlistForm } from "./waitlist-form";
import { InteractiveGraph } from "./interactive-graph";

export default function Home() {
  return (
    <div className="min-h-screen bg-background font-sans">
      <Nav />
      <CircuitTrace opacity={0.15} />
      <Hero />
      <Problem />
      <CircuitTrace opacity={0.12} />
      <HowItWorks />
      <TranscriptDemo />
      <CircuitTrace opacity={0.12} />
      <Features />
      <CircuitTrace opacity={0.1} />
      <FinalCTA />
      <Footer />
    </div>
  );
}

/* =============================================
   CIRCUIT TRACE — Decorative section divider
   ============================================= */
function CircuitTrace({ opacity = 0.3 }: { opacity?: number }) {
  return (
    <svg
      viewBox="0 0 400 8"
      className="w-full"
      height="8"
      fill="none"
      stroke="#D4915E"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
      opacity={opacity}
      preserveAspectRatio="none"
    >
      <path d="M0 4h80l4-3h40l4 3h30l4 3h60l4-3h40l4 3h130" />
    </svg>
  );
}

/* =============================================
   LOGO — Forge graph node mark + wordmark
   ============================================= */
function CodeFreshLogo({
  size = "sm",
  showWordmark = true,
}: {
  size?: "sm" | "md" | "lg";
  showWordmark?: boolean;
}) {
  const scale = size === "sm" ? 1 : size === "md" ? 1.5 : 2;
  const iconSize = 20 * scale;

  return (
    <span className="inline-flex items-center gap-2">
      {/* Graph node mark */}
      <svg
        viewBox="0 0 16 16"
        width={iconSize}
        height={iconSize}
        xmlns="http://www.w3.org/2000/svg"
        aria-hidden="true"
      >
        <rect x="2" y="3" width="12" height="10" rx="2.5" fill="#D4915E" />
        <circle cx="8" cy="8" r="1.5" fill="#08090D" />
      </svg>

      {/* Wordmark */}
      {showWordmark && (
        <span
          className={`font-sans font-semibold tracking-tight ${size === "sm" ? "text-sm" : size === "md" ? "text-xl" : "text-2xl"}`}
        >
          codefre<span className="text-accent">.</span>sh
        </span>
      )}
    </span>
  );
}

/* =============================================
   NAV
   ============================================= */
function Nav() {
  return (
    <nav className="sticky top-0 z-50 border-b border-border bg-background/80 backdrop-blur-md">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-3">
        <a href="/" className="transition-opacity hover:opacity-80">
          <CodeFreshLogo size="sm" />
        </a>
        <div className="flex items-center gap-6">
          <a
            href="#waitlist"
            className="rounded-md bg-accent px-3 py-1.5 text-xs font-semibold text-[#08090D] transition-opacity hover:opacity-90"
          >
            Join Waitlist
          </a>
        </div>
      </div>
    </nav>
  );
}

/* =============================================
   HERO
   ============================================= */
function Hero() {
  return (
    <section className="relative px-6 py-24 lg:py-32">
      <div className="mx-auto max-w-3xl text-center">
        {/* Badge */}
        <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-border bg-surface px-3 py-1">
          <span className="h-1.5 w-1.5 rounded-full bg-accent" />
          <span className="text-xs font-medium text-text-secondary">
            Now accepting early access signups
          </span>
        </div>

        <h1 className="text-4xl font-bold leading-[1.15] tracking-tight sm:text-5xl lg:text-[56px]">
          Behavioral testing
          <br />
          for{" "}
          <span className="text-accent">AI agents</span>
        </h1>

        {/* Circuit trace motif */}
        <div className="mx-auto mt-4 max-w-xs">
          <CircuitTrace opacity={0.2} />
        </div>

        <p className="mx-auto mt-6 max-w-xl text-base leading-relaxed text-text-secondary lg:text-lg">
          Script conversations. Run evaluations. Catch regressions before your
          users do. Like Playwright — but for agents that talk back.
        </p>

        {/* Email capture */}
        <div id="waitlist" className="mt-10">
          <WaitlistForm buttonText="Get Early Access" />
        </div>

        <p className="mt-4 text-xs text-text-tertiary">
          Free for founding members &middot; No credit card required
        </p>
      </div>
    </section>
  );
}

/* =============================================
   PROBLEM
   ============================================= */
function BreakGlyph({ size = 20 }: { size?: number }) {
  return (
    <svg
      viewBox="0 0 24 24"
      width={size}
      height={size}
      fill="none"
      stroke="currentColor"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <rect x="3" y="5" width="18" height="14" rx="3" />
      <path d="M9 9.5l6 5.5" />
      <path d="M15 9l-6 6" />
    </svg>
  );
}

function Problem() {
  const problems = [
    {
      label: "Benchmarks lie",
      description:
        "MMLU and HumanEval measure capability, not behavior. Your agent aces benchmarks but derails in production conversations.",
    },
    {
      label: "Manual testing doesn't scale",
      description:
        "You test by chatting with your agent. Then a teammate changes a prompt and nobody re-tests. Regressions ship silently.",
    },
    {
      label: "Observability \u2260 testing",
      description:
        "LangSmith and Arize log what happened. They don\u2019t tell you whether the agent should have said that. Logging is not evaluation.",
    },
  ];

  return (
    <section className="border-t border-border px-6 py-24">
      <div className="mx-auto max-w-5xl">
        <p className="text-xs font-medium uppercase tracking-widest text-text-tertiary">
          The problem
        </p>
        <h2 className="mt-3 text-2xl font-bold tracking-tight sm:text-3xl">
          AI agent testing is broken
        </h2>

        <div className="mt-12 grid gap-8 md:grid-cols-3">
          {problems.map((p) => (
            <div key={p.label} className="space-y-3">
              <div className="flex items-center gap-2">
                <span className="inline-flex h-6 w-6 items-center justify-center rounded bg-eval-fail-muted text-eval-fail">
                  <BreakGlyph size={16} />
                </span>
                <h3 className="text-sm font-semibold">{p.label}</h3>
              </div>
              <p className="text-sm leading-relaxed text-text-secondary">
                {p.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* =============================================
   HOW IT WORKS — Conversation Graph + YAML
   ============================================= */

const YAML_SCRIPT = `# onboarding-flow.yaml
nodes:
  - id: greeting
    prompt: "Build me a website"
    expect:
      - asks_clarifying_questions: ">= 0.8"
      - does_not_hallucinate_stack: ">= 0.9"
    branches:
      - on: clarifies_scope
        goto: scope
      - on: jumps_to_code
        goto: architecture

  - id: scope
    prompt: "A language learning platform"
    expect:
      - proposes_concrete_structure: ">= 0.7"
      - asks_about_audience: ">= 0.5"

  - id: architecture
    prompt: "What stack would you use?"
    expect:
      - justifies_choices: ">= 0.8"
      - avoids_overengineering: ">= 0.6"`;

const CLI_RUN = `$ codefresh run onboarding-flow.yaml \\
    --agents gpt-4o,claude-3.5 \\
    --personas hostile,novice,expert \\
    --parallel

Running 6 evaluations (2 agents \u00d7 3 personas)...

  gpt-4o \u00d7 hostile     \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588 done  2.3s
  gpt-4o \u00d7 novice      \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588 done  1.8s
  gpt-4o \u00d7 expert      \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2591\u2591\u2591\u2591 ...   1.2s
  claude-3.5 \u00d7 hostile  \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588 done  2.1s
  claude-3.5 \u00d7 novice   \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588 done  1.6s
  claude-3.5 \u00d7 expert   \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2591\u2591\u2591\u2591\u2591\u2591\u2591\u2591 ...   0.9s`;

function HowItWorks() {
  return (
    <section className="border-t border-border px-6 py-24">
      <div className="mx-auto max-w-5xl">
        <p className="text-xs font-medium uppercase tracking-widest text-text-tertiary">
          How it works
        </p>
        <h2 className="mt-3 text-2xl font-bold tracking-tight sm:text-3xl">
          Script &rarr; Run &rarr; Evaluate
        </h2>
        <p className="mt-4 max-w-2xl text-sm leading-relaxed text-text-secondary">
          Define conversation trees with fuzzy expectations. Run them across
          agents and personas. Review results in a graph that lights up with
          eval scores.
        </p>

        {/* Graph — the visual centerpiece */}
        <div className="mt-12 rounded-[6px] border-[1.5px] border-border bg-surface p-6">
          <div className="mb-4 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <span className="font-mono text-xs font-semibold">
                onboarding-flow
              </span>
              <span className="text-xs text-text-tertiary">&times;</span>
              <span className="font-mono text-xs text-text-secondary">
                hostile-persona
              </span>
            </div>
            <div className="flex items-center gap-3 font-mono text-[11px]">
              <span className="flex items-center gap-1">
                <span className="h-2 w-2 rounded-full bg-eval-pass" /> pass
              </span>
              <span className="flex items-center gap-1">
                <span className="h-2 w-2 rounded-full bg-eval-warn" /> warn
              </span>
              <span className="flex items-center gap-1">
                <span className="h-2 w-2 rounded-full bg-eval-fail" /> fail
              </span>
              <span className="flex items-center gap-1">
                <span
                  className="h-2 w-2 rounded-full border border-dashed border-eval-freeball"
                />{" "}
                freeball
              </span>
            </div>
          </div>

          <InteractiveGraph className="py-4" />
        </div>

        {/* Two-column: YAML + CLI */}
        <div className="mt-8 grid gap-6 lg:grid-cols-2">
          {/* YAML script */}
          <div>
            <div className="mb-2 flex items-center gap-2">
              <span className="font-mono text-xs font-semibold text-accent">
                01
              </span>
              <h3 className="text-sm font-semibold">
                Define in YAML or the graph editor
              </h3>
            </div>
            <pre className="overflow-x-auto rounded-[6px] border-[1.5px] border-border bg-well p-4 font-mono text-[13px] leading-relaxed text-text-secondary">
              {YAML_SCRIPT}
            </pre>
          </div>

          {/* CLI run */}
          <div>
            <div className="mb-2 flex items-center gap-2">
              <span className="font-mono text-xs font-semibold text-accent">
                02
              </span>
              <h3 className="text-sm font-semibold">
                Run across agents &amp; personas
              </h3>
            </div>
            <pre className="overflow-x-auto rounded-[6px] border-[1.5px] border-border bg-well p-4 font-mono text-[13px] leading-relaxed text-text-secondary">
              {CLI_RUN}
            </pre>
          </div>
        </div>

        {/* Evaluate callout */}
        <div className="mt-6 flex items-start gap-3">
          <span className="mt-0.5 font-mono text-xs font-semibold text-accent">
            03
          </span>
          <p className="text-sm leading-relaxed text-text-secondary">
            <span className="font-semibold text-text-primary">Evaluate </span>
            — Click any node above to explore its conversation script,
            expectations, and branches. Add notes to track your observations.
          </p>
        </div>
      </div>
    </section>
  );
}

/* =============================================
   TRANSCRIPT DEMO — Three-Voice System
   ============================================= */

function PromptGlyph() {
  return (
    <svg viewBox="0 0 16 16" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 4.5l3.5 3.5L3 11.5" />
      <line x1="9" y1="11.5" x2="13" y2="11.5" />
    </svg>
  );
}

function EyeGlyph() {
  return (
    <svg viewBox="0 0 16 16" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
      <circle cx="8" cy="8" r="5.5" />
      <circle cx="8" cy="8" r="2" fill="currentColor" stroke="none" />
    </svg>
  );
}

function GaugeGlyph() {
  return (
    <svg viewBox="0 0 16 16" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 11a5.5 5.5 0 0110 0" />
      <line x1="8" y1="11" x2="10.5" y2="6.5" />
      <circle cx="8" cy="11" r="1" fill="currentColor" stroke="none" />
    </svg>
  );
}

function TranscriptDemo() {
  return (
    <section className="border-t border-border px-6 py-24">
      <div className="mx-auto max-w-5xl">
        <p className="text-xs font-medium uppercase tracking-widest text-text-tertiary">
          See it in action
        </p>
        <h2 className="mt-3 text-2xl font-bold tracking-tight sm:text-3xl">
          Three voices, instantly scannable
        </h2>
        <p className="mt-4 max-w-2xl text-sm leading-relaxed text-text-secondary">
          Every conversation has three participants: the script author, the
          agent under test, and the evaluator. Each gets a distinct typographic
          treatment so you can scan transcripts without reading a word.
        </p>

        {/* Transcript card */}
        <div className="mt-12 max-w-2xl rounded-[6px] border-[1.5px] border-border bg-surface">
          {/* Header bar */}
          <div className="flex items-center justify-between border-b border-border px-5 py-3">
            <div className="flex items-center gap-3">
              <span className="font-mono text-xs font-semibold text-text-primary">
                onboarding-flow
              </span>
              <span className="text-xs text-text-tertiary">&times;</span>
              <span className="font-mono text-xs text-text-secondary">
                hostile-persona
              </span>
            </div>
            <div className="flex items-center gap-2">
              <span className="inline-flex items-center gap-1 rounded bg-eval-pass-muted px-2 py-0.5 font-mono text-[12px] font-semibold text-eval-pass">
                &#x2713; 0.92
              </span>
            </div>
          </div>

          {/* Transcript body */}
          <div className="space-y-0 p-5">
            {/* Turn 1: Author voice (The Prompt) */}
            <div className="flex gap-3">
              <div className="mt-1 shrink-0 text-text-tertiary">
                <PromptGlyph />
              </div>
              <div className="flex-1">
                <p className="mb-1 text-[11px] font-medium uppercase tracking-widest text-text-tertiary">
                  Script
                </p>
                <div className="rounded-[4px] border-l-[3px] border-border bg-well px-4 py-2.5 font-mono text-[13px] leading-snug text-text-secondary">
                  &quot;Design a website for learning a second language&quot;
                </div>
              </div>
            </div>

            {/* Separator */}
            <div className="my-7 border-t border-border-subtle" />

            {/* Turn 2: Agent voice (The Eye) */}
            <div className="flex gap-3">
              <div className="mt-1 shrink-0 text-text-tertiary">
                <EyeGlyph />
              </div>
              <div className="flex-1">
                <p className="mb-1 text-[11px] font-medium uppercase tracking-widest text-text-tertiary">
                  Agent
                </p>
                <div className="border-l-[3px] border-text-tertiary py-3 pl-5 pr-3">
                  <p className="font-sans text-[15px] leading-[1.7] tracking-[0.005em] text-text-primary">
                    That&apos;s an interesting project. Before I start designing,
                    I&apos;d like to understand a few things about the target
                    audience and scope.
                  </p>
                  <p className="mt-4 font-sans text-[15px] leading-[1.7] tracking-[0.005em] text-text-primary">
                    What age group are we targeting? Are we building for adults
                    learning conversationally, or students in a formal education
                    setting? And should the platform support multiple source
                    languages, or is it primarily English-to-X?
                  </p>
                </div>
              </div>
            </div>

            {/* Separator */}
            <div className="my-7 border-t border-border-subtle" />

            {/* Turn 3: Evaluator voice (The Gauge) */}
            <div className="flex gap-3">
              <div className="mt-1 shrink-0 text-accent">
                <GaugeGlyph />
              </div>
              <div className="flex-1">
                <p className="mb-1 text-[11px] font-medium uppercase tracking-widest text-accent">
                  Evaluator
                </p>
                <div className="rounded-[4px] border-l-[3px] border-[#A06B3F] bg-accent-muted px-4 py-3">
                  <div className="space-y-1.5 font-sans text-[12px] font-medium tracking-[0.02em]">
                    <p className="text-accent">
                      <span className="text-eval-pass">&#x2713;</span>{" "}
                      asks_clarifying_questions{" "}
                      <span className="text-text-tertiary font-mono">(0.92)</span>
                    </p>
                    <p className="text-accent">
                      <span className="text-eval-pass">&#x2713;</span>{" "}
                      doesnt_correct_grammar{" "}
                      <span className="text-text-tertiary font-mono">(1.00)</span>
                    </p>
                    <p className="text-accent">
                      <span className="text-eval-warn">&#x26A0;</span>{" "}
                      proposes_concrete_structure{" "}
                      <span className="text-text-tertiary font-mono">(0.45)</span>
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Separator */}
            <div className="my-7 border-t border-border-subtle" />

            {/* Turn 4: Author voice — second turn */}
            <div className="flex gap-3">
              <div className="mt-1 shrink-0 text-text-tertiary">
                <PromptGlyph />
              </div>
              <div className="flex-1">
                <p className="mb-1 text-[11px] font-medium uppercase tracking-widest text-text-tertiary">
                  Script
                </p>
                <div className="rounded-[4px] border-l-[3px] border-border bg-well px-4 py-2.5 font-mono text-[13px] leading-snug text-text-secondary">
                  &quot;A language learning platform for adults, English to Spanish. Focus on conversational fluency.&quot;
                </div>
              </div>
            </div>

            {/* Separator */}
            <div className="my-7 border-t border-border-subtle" />

            {/* Turn 5: Agent voice — second response */}
            <div className="flex gap-3">
              <div className="mt-1 shrink-0 text-text-tertiary">
                <EyeGlyph />
              </div>
              <div className="flex-1">
                <p className="mb-1 text-[11px] font-medium uppercase tracking-widest text-text-tertiary">
                  Agent
                </p>
                <div className="border-l-[3px] border-text-tertiary py-3 pl-5 pr-3">
                  <p className="font-sans text-[15px] leading-[1.7] tracking-[0.005em] text-text-primary">
                    Great, conversational Spanish for adults. I&apos;d suggest structuring the platform around three core
                    experiences: daily micro-lessons (5-10 minutes), interactive dialogue practice with AI conversation
                    partners, and a spaced repetition vocabulary system.
                  </p>
                </div>
              </div>
            </div>

            {/* Separator */}
            <div className="my-7 border-t border-border-subtle" />

            {/* Turn 6: Evaluator voice — second eval */}
            <div className="flex gap-3">
              <div className="mt-1 shrink-0 text-accent">
                <GaugeGlyph />
              </div>
              <div className="flex-1">
                <p className="mb-1 text-[11px] font-medium uppercase tracking-widest text-accent">
                  Evaluator
                </p>
                <div className="rounded-[4px] border-l-[3px] border-[#A06B3F] bg-accent-muted px-4 py-3">
                  <div className="space-y-1.5 font-sans text-[12px] font-medium tracking-[0.02em]">
                    <p className="text-accent">
                      <span className="text-eval-pass">&#x2713;</span>{" "}
                      proposes_concrete_structure{" "}
                      <span className="text-text-tertiary font-mono">(0.88)</span>
                    </p>
                    <p className="text-accent">
                      <span className="text-eval-pass">&#x2713;</span>{" "}
                      asks_about_audience{" "}
                      <span className="text-text-tertiary font-mono">(0.95)</span>
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Call-out for the three-voice system */}
        <p className="mt-6 max-w-2xl text-xs text-text-tertiary">
          Script prompts render in{" "}
          <span className="font-mono">JetBrains Mono</span> at 13px on a
          recessed background. Agent responses use{" "}
          <span className="font-sans font-medium">Plus Jakarta Sans</span> at
          15px with 1.7 line-height for readable prose. Evaluator annotations
          are 12px, 500 weight, in copper.
        </p>
      </div>
    </section>
  );
}

/* =============================================
   SVG GLYPHS for Features
   ============================================= */

function BranchPointGlyph({ size = 24 }: { size?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={size} height={size} fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="6" cy="12" r="2.5" />
      <circle cx="18" cy="7" r="2.5" />
      <circle cx="18" cy="17" r="2.5" />
      <path d="M8.5 11l5 -3.5" />
      <path d="M8.5 13l5 3.5" />
    </svg>
  );
}

function GaugeFeatureGlyph({ size = 24 }: { size?: number }) {
  return (
    <svg viewBox="0 0 16 16" width={size} height={size} fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 11a5.5 5.5 0 0110 0" />
      <line x1="8" y1="11" x2="10.5" y2="6.5" />
      <circle cx="8" cy="11" r="1" fill="currentColor" stroke="none" />
    </svg>
  );
}

function EyeFeatureGlyph({ size = 24 }: { size?: number }) {
  return (
    <svg viewBox="0 0 16 16" width={size} height={size} fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
      <circle cx="8" cy="8" r="5.5" />
      <circle cx="8" cy="8" r="2" fill="currentColor" stroke="none" />
    </svg>
  );
}

function DriftGlyph({ size = 24 }: { size?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={size} height={size} fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="5" width="18" height="14" rx="3" strokeDasharray="4 3" />
      <path d="M10 14l4.5-4.5" />
      <path d="M11.5 9.5h3v3" />
    </svg>
  );
}

function SealGlyph({ size = 24 }: { size?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={size} height={size} fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="5" width="18" height="14" rx="3" />
      <path d="M8.5 12.5l2.5 2.5 5-5" />
    </svg>
  );
}

function TerminalNodeGlyph({ size = 24 }: { size?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={size} height={size} fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
      <circle cx="12" cy="12" r="6" />
      <circle cx="12" cy="12" r="3" fill="currentColor" stroke="none" />
    </svg>
  );
}

/* =============================================
   FEATURES
   ============================================= */
function Features() {
  const features = [
    {
      title: "Graph-based scripts",
      description:
        "Conversations branch. Your tests should too. Define non-linear conversation trees with conditional paths.",
      icon: <BranchPointGlyph size={20} />,
    },
    {
      title: "Fuzzy expectations",
      description:
        "Not pass/fail \u2014 scored. Set thresholds like \u2018asks clarifying questions \u2265 0.8\u2019 and let LLM-as-judge evaluate.",
      icon: <GaugeFeatureGlyph size={20} />,
    },
    {
      title: "Persona testing",
      description:
        "Run the same script through hostile, novice, adversarial, and confused personas. One script, many perspectives.",
      icon: <EyeFeatureGlyph size={20} />,
    },
    {
      title: "The Freeball Engine",
      description:
        "When agents go off-script, CodeFresh doesn\u2019t fail \u2014 it improvises. Auto-generates evaluation nodes for deviations.",
      icon: <DriftGlyph size={20} />,
    },
    {
      title: "CI/CD gates",
      description:
        "Run behavioral tests in your pipeline. Block deploys when agent behavior regresses. Ship with confidence.",
      icon: <SealGlyph size={20} />,
    },
    {
      title: "Any agent, any framework",
      description:
        "HTTP adapters for OpenAI, Anthropic, LangChain, CrewAI, AutoGen, and custom endpoints. Bring your own agent.",
      icon: <TerminalNodeGlyph size={20} />,
    },
  ];

  return (
    <section className="border-t border-border px-6 py-24">
      <div className="mx-auto max-w-5xl">
        <p className="text-xs font-medium uppercase tracking-widest text-text-tertiary">
          Features
        </p>
        <h2 className="mt-3 text-2xl font-bold tracking-tight sm:text-3xl">
          Everything you need to test agent behavior
        </h2>

        <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((f) => (
            <div
              key={f.title}
              className="rounded-[6px] border-[1.5px] border-border bg-surface p-5 transition-colors hover:border-border-strong"
            >
              <span className="mb-3 inline-flex h-8 w-8 items-center justify-center rounded-md bg-accent-muted text-accent">
                {f.icon}
              </span>
              <h3 className="text-sm font-semibold">{f.title}</h3>
              <p className="mt-2 text-xs leading-relaxed text-text-secondary">
                {f.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* =============================================
   FINAL CTA
   ============================================= */
function FinalCTA() {
  return (
    <section className="border-t border-border px-6 py-24">
      <div className="mx-auto max-w-xl text-center">
        <h2 className="text-2xl font-bold tracking-tight sm:text-3xl">
          Stop shipping untested agents
        </h2>
        <p className="mt-4 text-sm leading-relaxed text-text-secondary">
          CodeFresh is building the behavioral testing framework AI engineers
          actually need. Get early access and shape the product.
        </p>

        <div className="mt-8">
          <WaitlistForm buttonText="Join Waitlist" />
        </div>

        <p className="mt-4 text-xs text-text-tertiary">
          Founding members get lifetime access to Pro features
        </p>
      </div>
    </section>
  );
}

/* =============================================
   FOOTER
   ============================================= */
function Footer() {
  return (
    <footer className="border-t border-border px-6 py-8">
      <div className="mx-auto flex max-w-5xl flex-col items-center justify-between gap-4 sm:flex-row">
        <span className="flex items-center gap-2 text-xs text-text-tertiary">
          <CodeFreshLogo size="sm" showWordmark={false} />
          <span className="font-mono">&copy; 2026 codefre.sh</span>
        </span>
        <div className="flex gap-6">
          <a
            href="#"
            className="text-xs text-text-tertiary transition-colors hover:text-text-secondary"
          >
            Privacy
          </a>
          <a
            href="#"
            className="text-xs text-text-tertiary transition-colors hover:text-text-secondary"
          >
            Terms
          </a>
        </div>
      </div>
    </footer>
  );
}
