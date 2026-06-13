import { WaitlistForm } from "./waitlist-form";

export default function Home() {
  return (
    <div className="min-h-screen bg-background font-sans">
      <Nav />
      <Hero />
      <ProofBar />
      <Divider />
      <WhyNoizuRPG />
      <Divider />
      <CodeDemo />
      <Divider />
      <Components />
      <Divider />
      <PlaygroundPreview />
      <Divider />
      <HowItWorks />
      <Divider />
      <FAQ />
      <Divider />
      <FinalCTA />
      <Footer />
    </div>
  );
}

/* ═══════════════════════════════════════════════
   NOIZU MARK (inline SVG logomark — amber/gold)
   ═══════════════════════════════════════════════ */
function NoizuMark({ size = 24, className = "" }: { size?: number; className?: string }) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 200 200"
      width={size}
      height={size}
      className={className}
      aria-hidden="true"
    >
      <polygon points="39,65 100,30 161,65 100,100" fill="#E8B75E" />
      <polygon points="39,65 100,100 100,170 39,135" fill="#D4A04A" />
      <polygon points="100,100 161,65 161,135 100,170" fill="#A67C30" />
    </svg>
  );
}

/* ═══════════════════════════════════════════════
   DIVIDER
   ═══════════════════════════════════════════════ */
function Divider() {
  return (
    <div className="px-6 text-border-strong select-none" aria-hidden="true">
      <div className="mx-auto max-w-6xl font-mono text-xs tracking-widest opacity-10">
        · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════
   NAV
   ═══════════════════════════════════════════════ */
function Nav() {
  return (
    <nav className="sticky top-0 z-50 border-b border-border bg-background/85 backdrop-blur-xl">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-3">
        <a
          href="/"
          className="flex items-center gap-2"
        >
          <NoizuMark size={24} />
          <span className="font-mono text-sm font-bold tracking-wider text-accent">
            NOIZU<span className="text-text-tertiary">RPG</span>
          </span>
        </a>
        <div className="hidden items-center gap-6 sm:flex">
          <a href="#components" className="text-xs font-medium text-text-secondary transition-colors duration-150 hover:text-text-primary">Docs</a>
          <a href="#playground" className="text-xs font-medium text-text-secondary transition-colors duration-150 hover:text-text-primary">Playground</a>
          <a href="#" className="text-xs font-medium text-text-secondary transition-colors duration-150 hover:text-text-primary">GitHub</a>
        </div>
        <a
          href="#waitlist"
          className="rounded-sm bg-accent px-4 py-1.5 font-mono text-[11px] font-bold uppercase tracking-widest text-[#0D0B0E] transition-all duration-150 hover:bg-[#E8B75E] hover:shadow-[0_0_16px_rgba(212,160,74,0.3)]"
        >
          Get Early Access
        </a>
      </div>
    </nav>
  );
}

/* ═══════════════════════════════════════════════
   HERO
   ═══════════════════════════════════════════════ */
function Hero() {
  return (
    <section className="relative px-6 py-20 lg:py-28 overflow-hidden">
      {/* Amber glow */}
      <div
        className="pointer-events-none absolute top-0 left-1/2 -translate-x-1/2 h-[500px] w-[600px]"
        style={{
          background:
            "radial-gradient(ellipse at 50% 0%, rgba(212, 160, 74, 0.06) 0%, transparent 70%)",
        }}
      />

      <div className="relative mx-auto max-w-5xl">
        {/* Status badge */}
        <div className="mb-8 inline-flex items-center gap-2 rounded-sm border border-border bg-surface px-3 py-1">
          <span className="h-2 w-2 rounded-full bg-accent animate-pulse" />
          <span className="font-flavor text-[11px] uppercase tracking-[0.08em] text-text-secondary">
            Python 3.11+
          </span>
        </div>

        <h1 className="font-display text-3xl font-semibold leading-tight tracking-tight sm:text-4xl lg:text-5xl">
          The composable framework for{" "}
          <br className="hidden sm:inline" />
          <span className="text-accent">AI-powered RPGs.</span>
        </h1>

        <p className="mt-6 max-w-2xl font-serif text-base leading-relaxed text-text-secondary sm:text-lg">
          Build role-playing games where LLMs are first-class primitives &mdash;
          not bolted-on chatbots, but the narrative engine, the game master, the
          quest designer, and the world simulator.
        </p>

        {/* pip install */}
        <div className="mt-8 inline-flex items-center gap-3 rounded-sm border border-border bg-inset px-4 py-2.5">
          <span className="font-mono text-sm text-text-tertiary">$</span>
          <code className="font-mono text-sm text-text-primary">pip install noizurpg</code>
          <button
            className="font-mono text-[10px] uppercase tracking-wider text-text-tertiary transition-colors duration-150 hover:text-accent"
            title="Copy"
          >
            [copy]
          </button>
        </div>

        {/* CTA */}
        <div id="waitlist" className="mt-10">
          <WaitlistForm buttonText="GET EARLY ACCESS" />
        </div>

        <p className="mt-4 font-flavor text-[11px] uppercase tracking-[0.08em] text-text-tertiary">
          Star us on GitHub &middot; Join the Discord
        </p>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   PROOF BAR
   ═══════════════════════════════════════════════ */
function ProofBar() {
  return (
    <div className="border-y border-border px-6 py-4">
      <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-center gap-x-8 gap-y-2 font-flavor text-xs uppercase tracking-[0.08em] text-text-tertiary">
        <span>
          <span className="text-text-secondary">6</span> composable components
        </span>
        <span className="hidden sm:inline">&middot;</span>
        <span>
          <span className="text-text-secondary">3</span> LLM providers built-in
        </span>
        <span className="hidden sm:inline">&middot;</span>
        <span>
          <span className="text-text-secondary">Python</span> 3.11+
        </span>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════
   WHY NOIZURPG
   ═══════════════════════════════════════════════ */
const PILLARS = [
  {
    label: "COMPOSE",
    title: "Compose, Don\u2019t Inherit",
    description:
      "Pick the pieces you need: characters, worlds, narrative, quests, dialogue, memory. Each component works independently. Snap them together like React components.",
    icon: "\u25C7",
    accent: "text-accent",
    accentBg: "bg-accent-muted",
    border: "border-t-accent",
  },
  {
    label: "GENERATE",
    title: "LLM-Agnostic",
    description:
      "OpenAI, Claude, Ollama, vLLM \u2014 wire in any provider. Swap models without changing game logic. Structured output schemas keep AI responses deterministic where it matters.",
    icon: "\u25C6",
    accent: "text-info",
    accentBg: "bg-info-bg",
    border: "border-t-info",
  },
  {
    label: "REMEMBER",
    title: "State is Structured, Not Vibes",
    description:
      "Typed events, ground-truth world state, persistent memory. Characters remember. Worlds evolve. Quests branch. No more \u2018the AI forgot my character\u2019s name.\u2019",
    icon: "\u25CF",
    accent: "text-gold",
    accentBg: "bg-gold-bg",
    border: "border-t-gold",
  },
];

function WhyNoizuRPG() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="font-flavor text-[11px] uppercase tracking-[0.08em] text-accent">
          Why NoizuRPG
        </p>
        <h2 className="mt-3 font-display text-xl font-semibold tracking-tight sm:text-2xl">
          The missing SDK for AI game development
        </h2>
        <p className="mt-4 max-w-2xl font-serif text-sm leading-relaxed text-text-secondary">
          Every AI RPG prototype hits the same walls: context overflow, narrative incoherence,
          character amnesia, world-state drift. NoizuRPG solves the infrastructure
          so you can focus on the game.
        </p>

        <div className="mt-12 grid gap-0 overflow-hidden rounded-sm border border-border sm:grid-cols-3">
          {PILLARS.map((p) => (
            <div
              key={p.label}
              className={`border-t-4 ${p.border} border-r border-border bg-surface p-6 transition-colors duration-150 last:border-r-0 hover:bg-elevated`}
            >
              <span
                className={`mb-3 inline-flex h-8 w-8 items-center justify-center rounded-sm ${p.accentBg} text-sm ${p.accent}`}
              >
                {p.icon}
              </span>
              <p
                className={`font-flavor text-[10px] uppercase tracking-[0.1em] ${p.accent}`}
              >
                {p.label}
              </p>
              <h3 className="mt-1 text-base font-semibold">{p.title}</h3>
              <p className="mt-3 font-serif text-[13px] leading-relaxed text-text-secondary">
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
   CODE DEMO
   ═══════════════════════════════════════════════ */
function CodeDemo() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="font-flavor text-[11px] uppercase tracking-[0.08em] text-accent">
          Code is the Interface
        </p>
        <h2 className="mt-3 font-display text-xl font-semibold tracking-tight sm:text-2xl">
          10 lines to a working AI RPG
        </h2>

        <div className="mt-12 grid items-start gap-8 lg:grid-cols-2">
          {/* Code block */}
          <div className="overflow-hidden rounded-sm border border-border">
            <div className="flex items-center justify-between border-b border-border bg-surface px-4 py-2">
              <span className="font-mono text-xs text-text-tertiary">quick_start.py</span>
              <span className="font-mono text-[10px] uppercase tracking-wider text-text-tertiary">[copy]</span>
            </div>
            <pre className="overflow-x-auto border-l-[3px] border-l-accent bg-inset p-5 font-mono text-[13px] leading-relaxed">
              <code>
{`from noizurpg import World, Character,
    NarrativeEngine
from noizurpg.providers import Anthropic

`}<span className="text-text-tertiary"># Build your world</span>{`
world = World(`}<span className="text-success">&quot;The Ashward Chronicles&quot;</span>{`)
world.add_location(`}<span className="text-success">&quot;Thornwall&quot;</span>{`,
    type=`}<span className="text-success">&quot;city&quot;</span>{`, traits=[`}<span className="text-success">&quot;coastal&quot;</span>{`])

`}<span className="text-text-tertiary"># Create a character</span>{`
kael = Character(`}<span className="text-success">&quot;Kael Ashward&quot;</span>{`)
kael.stats.set(str=`}<span className="text-gold">12</span>{`, dex=`}<span className="text-gold">14</span>{`, int=`}<span className="text-gold">16</span>{`)

`}<span className="text-text-tertiary"># Wire in any LLM</span>{`
engine = NarrativeEngine(
    llm=Anthropic(`}<span className="text-success">&quot;claude-sonnet-4-5-20250514&quot;</span>{`),
    world=world
)

`}<span className="text-text-tertiary"># Play</span>{`
response = engine.turn(
    character=kael,
    action=`}<span className="text-success">&quot;Enter the guild hall&quot;</span>{`
)`}
              </code>
            </pre>
          </div>

          {/* Narrative output */}
          <div>
            <div className="rounded-sm border border-border border-l-[3px] border-l-accent bg-surface p-6">
              <p className="font-flavor text-[10px] uppercase tracking-[0.08em] text-text-tertiary mb-3">
                Narrative Output
              </p>
              <div className="font-serif text-[15px] leading-[1.9] text-text-primary">
                <p>
                  The guild hall is quieter than usual. Master Venn looks up from
                  the cold forge &mdash; no iron to work today.
                </p>
                <p className="mt-4 italic">
                  &ldquo;Kael. Good. The routes are dead. Three caravans gone
                  since autumn. The Guild is bleeding coin.&rdquo;
                </p>
                <p className="mt-4 text-text-secondary">
                  His eyes hold something between fear and calculation &mdash; the
                  look of a man deciding whether to trust you with dangerous knowledge.
                </p>
              </div>
            </div>

            <div className="mt-4 space-y-2">
              <p className="font-flavor text-[10px] uppercase tracking-[0.08em] text-text-tertiary">
                Events Extracted
              </p>
              {[
                { type: "DialogueStarted", desc: "Master Venn", color: "text-accent" },
                { type: "KnowledgeGained", desc: "Routes blocked since autumn", color: "text-info" },
                { type: "QuestProgressed", desc: "The Iron Silence \u2192 Stage 3", color: "text-gold" },
              ].map((e) => (
                <div key={e.type} className="flex items-center gap-2 font-mono text-xs">
                  <span className={`${e.color}`}>{"\u25CF"}</span>
                  <span className="text-text-secondary">{e.type}</span>
                  <span className="text-text-tertiary">&mdash; {e.desc}</span>
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
   COMPONENTS
   ═══════════════════════════════════════════════ */
const COMPONENTS = [
  {
    name: "Character System",
    desc: "Stats, inventory, relationships, knowledge. The identity layer \u2014 everything about who a character is.",
    badge: "Stable",
    badgeColor: "text-success bg-success-bg",
    icon: "\u25C8",
  },
  {
    name: "World State Manager",
    desc: "Locations, factions, timelines, world rules. The ground truth your LLM builds upon.",
    badge: "Stable",
    badgeColor: "text-success bg-success-bg",
    icon: "\u25C7",
  },
  {
    name: "Narrative Engine",
    desc: "Context building, narrative generation, event parsing. Where LLMs meet structured game state.",
    badge: "Stable",
    badgeColor: "text-success bg-success-bg",
    icon: "\u25C6",
  },
  {
    name: "Quest Engine",
    desc: "Procedural quest generation, branching narratives, stage progression, and completion tracking.",
    badge: "Beta",
    badgeColor: "text-accent bg-accent-muted",
    icon: "\u25B2",
  },
  {
    name: "Dialogue Manager",
    desc: "Multi-NPC conversations with distinct personalities, relationship awareness, and memory.",
    badge: "Experimental",
    badgeColor: "text-gold bg-gold-bg",
    icon: "\u25CF",
  },
  {
    name: "Memory System",
    desc: "Event journal, compression, retrieval. Characters and worlds that remember across sessions.",
    badge: "Stable",
    badgeColor: "text-success bg-success-bg",
    icon: "\u25CE",
  },
];

function Components() {
  return (
    <section id="components" className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="font-flavor text-[11px] uppercase tracking-[0.08em] text-accent">
          6 Composable Components
        </p>
        <h2 className="mt-3 font-display text-xl font-semibold tracking-tight sm:text-2xl">
          Pick the pieces you need
        </h2>
        <p className="mt-4 max-w-2xl font-serif text-sm leading-relaxed text-text-secondary">
          Every component works independently. Use one, use all six, or build your
          own. The interfaces are stable and well-documented.
        </p>

        <div className="mt-12 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {COMPONENTS.map((c) => (
            <div
              key={c.name}
              className="rounded-sm border border-border bg-surface p-5 transition-colors duration-150 hover:bg-elevated hover:border-border-strong"
            >
              <div className="flex items-start justify-between mb-3">
                <span className="inline-flex h-8 w-8 items-center justify-center rounded-sm bg-accent-muted text-sm text-accent">
                  {c.icon}
                </span>
                <span className={`rounded-sm px-2 py-0.5 font-flavor text-[10px] uppercase tracking-wider ${c.badgeColor}`}>
                  {c.badge}
                </span>
              </div>
              <h3 className="text-sm font-semibold">{c.name}</h3>
              <p className="mt-2 font-serif text-[13px] leading-relaxed text-text-secondary">
                {c.desc}
              </p>
              <a href="#" className="mt-3 inline-block font-mono text-xs text-accent transition-colors duration-150 hover:text-[#E8B75E]">
                View docs {"\u2192"}
              </a>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   PLAYGROUND PREVIEW
   ═══════════════════════════════════════════════ */
function PlaygroundPreview() {
  return (
    <section id="playground" className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="font-flavor text-[11px] uppercase tracking-[0.08em] text-accent">
          Playground
        </p>
        <h2 className="mt-3 font-display text-xl font-semibold tracking-tight sm:text-2xl">
          Try it in the browser. No setup required.
        </h2>
        <p className="mt-4 max-w-2xl font-serif text-sm leading-relaxed text-text-secondary">
          The browser sandbox runs NoizuRPG with a pre-configured world and
          character. See how LLM responses become structured game events in real time.
        </p>

        {/* Playground mockup */}
        <div className="mt-12 overflow-hidden rounded-sm border border-border">
          {/* Header */}
          <div className="flex items-center justify-between border-b border-border bg-surface px-4 py-2">
            <span className="font-mono text-xs text-accent font-bold">NOIZURPG PLAYGROUND</span>
            <span className="font-mono text-[10px] text-text-tertiary">Model: Ollama (llama3:70b)</span>
          </div>

          {/* Split pane */}
          <div className="grid grid-cols-1 lg:grid-cols-2">
            {/* State panel — mono voice */}
            <div className="border-b lg:border-b-0 lg:border-r border-border bg-inset p-4 font-mono text-[11px] leading-relaxed text-text-secondary">
              <p className="font-flavor text-[10px] uppercase tracking-[0.06em] text-text-tertiary mb-2">World</p>
              <p><span className="text-accent">name</span>: <span className="text-success">&quot;The Ashward Chronicles&quot;</span></p>
              <p className="ml-3"><span className="text-accent">location</span>: <span className="text-success">&quot;Thornwall&quot;</span> <span className="text-text-tertiary">(city, coastal)</span></p>

              <p className="font-flavor text-[10px] uppercase tracking-[0.06em] text-text-tertiary mt-4 mb-2">Character</p>
              <p><span className="text-accent">name</span>: <span className="text-success">&quot;Kael Ashward&quot;</span></p>
              <p><span className="text-accent">STR</span>: <span className="text-gold">12</span> &nbsp;<span className="text-accent">DEX</span>: <span className="text-gold">14</span> &nbsp;<span className="text-accent">INT</span>: <span className="text-gold">16</span></p>
              <p><span className="text-accent">inventory</span>: Cold-singing Hammer, 24 gold</p>

              <p className="font-flavor text-[10px] uppercase tracking-[0.06em] text-text-tertiary mt-4 mb-2">Events (latest)</p>
              <p><span className="text-accent">{"\u25CF"}</span> DialogueStarted(Venn)</p>
              <p><span className="text-gold">{"\u25CF"}</span> QuestProgressed(2{"\u2192"}3)</p>
              <p><span className="text-info">{"\u25CF"}</span> Knowledge+(&quot;routes blocked&quot;)</p>
            </div>

            {/* Narrative panel — serif voice */}
            <div className="bg-background p-6">
              <p className="font-flavor text-[10px] uppercase tracking-[0.06em] text-text-tertiary mb-3">Narrative Output</p>
              <div className="font-serif text-[15px] leading-[1.9] text-text-primary">
                <p>
                  The guild hall is quieter than usual. Master Venn looks up from
                  the cold forge &mdash; no iron to work today.
                </p>
                <p className="mt-3 italic">
                  &ldquo;Kael. Good. The routes are dead. Three caravans gone
                  since autumn. The Guild is bleeding coin.&rdquo;
                </p>
              </div>
            </div>
          </div>

          {/* Input */}
          <div className="flex border-t border-border">
            <div className="flex flex-1 items-center bg-surface px-4 py-3">
              <span className="font-mono text-sm text-text-tertiary mr-2">&gt;</span>
              <span className="font-serif text-sm text-text-secondary">
                I ask Venn who he suspects is behind the blockade
              </span>
            </div>
            <div className="bg-accent px-5 py-3 font-mono text-xs font-bold uppercase tracking-wider text-[#0D0B0E] flex items-center">
              Send
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   HOW IT WORKS
   ═══════════════════════════════════════════════ */
const STEPS = [
  {
    number: "01",
    title: "Install",
    description:
      "pip install noizurpg. Zero config. SQLite storage, Ollama provider, and a sample world out of the box.",
    accent: "text-accent",
  },
  {
    number: "02",
    title: "Build",
    description:
      "Import components, wire up a world, create characters, and connect an LLM. The API is Pythonic and type-annotated.",
    accent: "text-info",
  },
  {
    number: "03",
    title: "Play",
    description:
      "Run your game in the terminal, browser sandbox, or embed in your own app. Events are structured, state is persistent, narrative is coherent.",
    accent: "text-gold",
  },
];

function HowItWorks() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="font-flavor text-[11px] uppercase tracking-[0.08em] text-text-tertiary">
          How It Works
        </p>
        <h2 className="mt-3 font-display text-xl font-semibold tracking-tight sm:text-2xl">
          Five minutes to your first AI RPG
        </h2>

        <div className="mt-12 grid gap-6 sm:grid-cols-3">
          {STEPS.map((s) => (
            <div key={s.number} className="rounded-sm border border-border bg-surface p-5">
              <span
                className={`font-display text-3xl font-bold ${s.accent} opacity-30`}
              >
                {s.number}
              </span>
              <h3 className="mt-3 font-flavor text-sm uppercase tracking-wider">
                {s.title}
              </h3>
              <p className="mt-3 font-serif text-[13px] leading-relaxed text-text-secondary">
                {s.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   FAQ
   ═══════════════════════════════════════════════ */
const FAQS = [
  {
    q: "What LLMs does this work with?",
    a: "OpenAI (GPT-4o), Anthropic (Claude), and Ollama (any local model) are built-in. The provider interface is pluggable \u2014 add any LLM with a few lines of code.",
  },
  {
    q: "How does it handle context window limits?",
    a: "The ContextBuilder selects only relevant events, character knowledge, and world facts for each turn. The Memory System compresses old events into summaries. You set the token budget.",
  },
  {
    q: "Is the AI output deterministic?",
    a: "Narrative text is non-deterministic (that\u2019s the fun). But state changes are parsed through structured output schemas \u2014 the AI proposes, the framework validates. Invalid state changes are rejected.",
  },
  {
    q: "Can I use this for multiplayer?",
    a: "v0.1 is single-player. The architecture doesn\u2019t preclude multiplayer, and it\u2019s on the roadmap for v0.3. The state management layer already handles concurrent reads.",
  },
  {
    q: "What about combat systems?",
    a: "NoizuRPG doesn\u2019t ship a combat system \u2014 RPG combat is too varied to standardize. We provide a CombatSystem interface and one reference implementation. Community contributions welcome.",
  },
  {
    q: "Is this production-ready?",
    a: "The core components (Character, World, NarrativeEngine, Memory) are stable and well-tested. Quest Engine is beta, Dialogue Manager is experimental. Use stable components in production.",
  },
];

function FAQ() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="font-flavor text-[11px] uppercase tracking-[0.08em] text-text-tertiary">
          FAQ
        </p>
        <h2 className="mt-3 font-display text-xl font-semibold tracking-tight sm:text-2xl">
          Common questions
        </h2>

        <div className="mt-12 grid gap-4 sm:grid-cols-2">
          {FAQS.map((faq) => (
            <div
              key={faq.q}
              className="rounded-sm border border-border bg-surface p-5"
            >
              <h3 className="text-sm font-semibold">{faq.q}</h3>
              <p className="mt-2 font-serif text-[13px] leading-relaxed text-text-secondary">
                {faq.a}
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
    <section className="relative px-6 py-20 overflow-hidden">
      {/* Glow */}
      <div
        className="pointer-events-none absolute top-0 left-1/2 -translate-x-1/2 h-[600px] w-[600px]"
        style={{
          background:
            "radial-gradient(circle, rgba(212, 160, 74, 0.05) 0%, transparent 70%)",
        }}
      />

      <div className="relative mx-auto max-w-xl text-center">
        <h2 className="font-display text-lg font-bold uppercase tracking-wider sm:text-xl">
          Build something
          <br />
          <span className="text-accent">wonderful.</span>
        </h2>
        <p className="mt-4 font-serif text-sm leading-relaxed text-text-secondary">
          NoizuRPG is the missing infrastructure for AI game development.
          Get early access and help shape the framework.
        </p>

        <div className="mt-8">
          <WaitlistForm buttonText="GET EARLY ACCESS" />
        </div>

      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   FOOTER
   ═══════════════════════════════════════════════ */
function Footer() {
  return (
    <footer className="border-t border-border px-6 py-6">
      <div className="mx-auto flex max-w-5xl flex-col items-center justify-between gap-4 sm:flex-row">
        <span className="flex items-center gap-2 font-flavor text-[11px] uppercase tracking-[0.08em] text-text-tertiary">
          <NoizuMark size={16} />
          &copy; 2026 NOIZURPG.COM
        </span>
        <div className="flex gap-6">
          {["Docs", "GitHub", "Discord", "Privacy"].map((link) => (
            <a
              key={link}
              href="#"
              className="font-flavor text-[11px] uppercase tracking-[0.08em] text-text-tertiary transition-colors duration-150 hover:text-text-secondary"
            >
              {link}
            </a>
          ))}
        </div>
      </div>
    </footer>
  );
}
