import { WaitlistForm } from "./waitlist-form";

export default function Home() {
  return (
    <div className="min-h-screen bg-background font-sans">
      <Nav />
      <Hero />
      <ProofBar />
      <Divider />
      <ThreePillars />
      <Divider />
      <TechniqueDemo />
      <Divider />
      <DefenderDemo />
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
   DIVIDER
   ═══════════════════════════════════════════════ */
function Divider() {
  return (
    <div className="px-6" aria-hidden="true">
      <div className="mx-auto max-w-6xl border-t border-border" />
    </div>
  );
}

/* ═══════════════════════════════════════════════
   NAV — 56px, monospace wordmark, blue accent
   ═══════════════════════════════════════════════ */
function Nav() {
  return (
    <nav className="sticky top-0 z-50 border-b border-border bg-background/90 backdrop-blur-md">
      <div className="mx-auto flex h-14 max-w-6xl items-center justify-between px-6">
        <a
          href="/"
          className="font-mono text-sm font-bold tracking-tight text-text-primary"
          style={{ letterSpacing: "-0.02em" }}
        >
          JAILBREAKING<span className="text-critical">SITE</span>
        </a>
        <a
          href="#waitlist"
          className="rounded bg-accent px-4 py-1.5 font-mono text-[11px] font-bold uppercase tracking-widest text-[#0B0D0F] transition-colors duration-100 hover:bg-accent-hover"
        >
          Get Early Access
        </a>
      </div>
    </nav>
  );
}

/* ═══════════════════════════════════════════════
   HERO — Threat Pulse numbers as the hero
   ═══════════════════════════════════════════════ */
function Hero() {
  return (
    <section className="px-6 py-20 lg:py-28">
      <div className="mx-auto max-w-5xl">
        {/* Threat Pulse stats — numbers ARE the hero */}
        <div className="mb-10 flex flex-wrap gap-12">
          <div>
            <div className="font-mono text-4xl font-bold leading-none text-text-primary lg:text-5xl">
              412
            </div>
            <div className="mt-1 text-xs text-text-tertiary">
              techniques cataloged
            </div>
          </div>
          <div>
            <div className="font-mono text-4xl font-bold leading-none text-text-primary lg:text-5xl">
              47
            </div>
            <div className="mt-1 text-xs text-text-tertiary">
              new this month
            </div>
          </div>
          <div>
            <div className="font-mono text-4xl font-bold leading-none text-critical lg:text-5xl">
              3
            </div>
            <div className="mt-1 text-xs text-text-tertiary">
              critical active
            </div>
          </div>
        </div>

        <h1 className="font-mono text-2xl font-bold leading-tight tracking-tight sm:text-3xl lg:text-4xl">
          Your LLMs are{" "}
          <span className="text-critical">vulnerable.</span>
          <br />
          Know <span className="text-accent">every attack.</span>
          <br />
          Defend every endpoint.
        </h1>

        <p className="mt-6 max-w-2xl text-[15px] leading-relaxed text-text-secondary">
          The structured attack catalog, defensive testing suite, and hands-on
          training labs that LLM security professionals actually need.
          Think MITRE ATT&CK meets HackTheBox.
        </p>

        {/* CTA */}
        <div id="waitlist" className="mt-10">
          <WaitlistForm buttonText="JOIN THE WAITLIST" />
        </div>

        <p className="mt-4 font-mono text-[11px] uppercase tracking-widest text-text-tertiary">
          Join <span className="text-text-secondary">1,847</span> security
          professionals already on the list
        </p>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   PROOF BAR — Severity-colored stats
   ═══════════════════════════════════════════════ */
function ProofBar() {
  return (
    <div className="border-y border-border px-6 py-4">
      <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-center gap-x-8 gap-y-2 font-mono text-xs uppercase tracking-widest text-text-tertiary">
        <span>
          <span className="text-text-secondary">412</span> techniques
        </span>
        <span className="hidden sm:inline text-border-strong">&middot;</span>
        <span>
          <span className="text-text-secondary">8</span> categories
        </span>
        <span className="hidden sm:inline text-border-strong">&middot;</span>
        <span>
          <span className="text-text-secondary">47</span> new this month
        </span>
        <span className="hidden sm:inline text-border-strong">&middot;</span>
        <span>
          <span className="text-critical">3</span>{" "}
          <span className="text-critical">critical active</span>
        </span>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════
   THREE PILLARS — All blue accent, severity stripe cards
   ═══════════════════════════════════════════════ */
const PILLARS = [
  {
    label: "CATALOG",
    title: "Attack Catalog",
    description:
      "412 classified jailbreak techniques with severity scoring, affected models, detection signatures, and mitigations. Structured like MITRE ATT&CK, updated weekly.",
    severity: "border-l-critical",
    badge: "CRITICAL",
    badgeClass: "text-critical bg-critical-bg",
  },
  {
    label: "DEFEND",
    title: "Defender",
    description:
      "Point at your LLM API endpoint. Run curated attack suites. Get a security report with specific vulnerabilities and mitigations. PDF, JSON, and SARIF export.",
    severity: "border-l-accent",
    badge: "SCAN",
    badgeClass: "text-accent bg-accent-muted",
  },
  {
    label: "TRAIN",
    title: "Academy",
    description:
      "Hands-on labs in sandboxed environments. Attack labs, defense labs, incident response scenarios. Progressive difficulty. Verifiable credentials.",
    severity: "border-l-low",
    badge: "LEARN",
    badgeClass: "text-low bg-low-bg",
  },
];

function ThreePillars() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="font-mono text-[11px] font-bold uppercase tracking-[0.08em] text-accent">
          THE PLATFORM
        </p>
        <h2 className="mt-3 font-mono text-xl font-bold tracking-tight sm:text-2xl">
          Catalog. Defend. Train.
        </h2>
        <p className="mt-4 max-w-2xl text-sm leading-relaxed text-text-secondary">
          Three layers that compound: know the attacks, test your defenses,
          train your team.
        </p>

        <div className="mt-12 grid gap-4 sm:grid-cols-3">
          {PILLARS.map((p) => (
            <div
              key={p.label}
              className={`rounded border border-border ${p.severity} border-l-[3px] bg-surface p-6 transition-colors duration-100 hover:bg-elevated`}
            >
              <span
                className={`inline-block rounded px-2 py-0.5 font-mono text-[10px] font-bold uppercase tracking-[0.1em] ${p.badgeClass}`}
              >
                {p.badge}
              </span>
              <h3 className="mt-3 font-mono text-base font-bold">{p.title}</h3>
              <p className="mt-3 text-[13px] leading-relaxed text-text-secondary">
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
   TECHNIQUE DEMO — Severity-striped card
   ═══════════════════════════════════════════════ */
function TechniqueDemo() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="font-mono text-[11px] font-bold uppercase tracking-[0.08em] text-accent">
          ATTACK CATALOG
        </p>
        <h2 className="mt-3 font-mono text-xl font-bold tracking-tight sm:text-2xl">
          Not just a list &mdash; a living threat intelligence database
        </h2>

        <div className="mt-12 grid items-start gap-8 lg:grid-cols-2">
          {/* Description */}
          <div className="space-y-6">
            <p className="text-sm leading-relaxed text-text-secondary">
              Every technique classified by severity, affected models, detection
              signatures, and proven mitigations. The catalog is structured,
              searchable, and cross-referenced &mdash; not a blog post that
              goes stale.
            </p>
            <p className="text-sm leading-relaxed text-text-secondary">
              Full reproduction steps for authenticated users with verified
              security credentials. Detection signatures and mitigations are
              public &mdash; defense-first for everyone.
            </p>

            <div className="space-y-3">
              {[
                "8 attack categories with expandable subcategories",
                "Severity scoring (CVSS-LLM) with affected model matrix",
                "Detection signatures you can ship to production",
                "Mitigations with code examples, not just prose",
                "Cross-references between related techniques",
              ].map((item) => (
                <div
                  key={item}
                  className="flex items-start gap-2 text-[13px] text-text-secondary"
                >
                  <span className="mt-0.5 text-accent">&#10003;</span>
                  <span>{item}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Technique Card — severity stripe pattern */}
          <div className="overflow-hidden rounded border border-border border-l-[3px] border-l-critical bg-surface">
            {/* Header */}
            <div className="flex items-center justify-between border-b border-border px-4 py-3">
              <span className="font-mono text-xs text-text-secondary">
                AJS-2026-0091
              </span>
              <span className="rounded bg-critical-bg px-2 py-0.5 font-mono text-[10px] font-bold uppercase tracking-wider text-critical border border-critical/30">
                CRITICAL
              </span>
            </div>

            <div className="p-4 font-mono text-[12px] leading-relaxed">
              <h3 className="mb-3 font-mono text-sm font-bold text-text-primary">
                Tool Parameter Injection
              </h3>
              <p className="mb-4 font-sans text-[13px] text-text-secondary">
                When an LLM has access to tools with parameterized inputs,
                user-supplied content can be passed directly to tool parameters
                without sanitization. Enables classical injection attacks via
                the LLM as intermediary.
              </p>

              {/* Affected Models */}
              <p className="mb-2 text-[10px] font-bold uppercase tracking-wider text-text-tertiary">
                Affected Models
              </p>
              <div className="mb-4 space-y-1">
                {[
                  { model: "GPT-4o", status: "Confirmed" },
                  { model: "Claude 3.5", status: "Confirmed" },
                  { model: "Gemini 2.0", status: "Confirmed" },
                ].map((m) => (
                  <div
                    key={m.model}
                    className="flex items-center justify-between font-sans text-[13px]"
                  >
                    <span className="text-text-secondary">
                      &middot; {m.model}
                    </span>
                    <span className="text-critical">{m.status}</span>
                  </div>
                ))}
              </div>

              {/* Detection */}
              <p className="mb-2 text-[10px] font-bold uppercase tracking-wider text-text-tertiary">
                Detection Signatures
              </p>
              <div className="mb-4 space-y-1 font-sans text-[13px] text-text-secondary">
                <p>&middot; Tool calls containing SQL/shell metacharacters</p>
                <p>&middot; User message &#8594; tool param content overlap</p>
                <p>&middot; Anomalous tool parameter length/entropy</p>
              </div>

              {/* Mitigations */}
              <p className="mb-2 text-[10px] font-bold uppercase tracking-wider text-text-tertiary">
                Mitigations
              </p>
              <div className="space-y-1 font-sans text-[13px] text-text-secondary">
                <p>&middot; Parameterized queries for all tool inputs</p>
                <p>&middot; Tool input validation layer (type + format)</p>
                <p>&middot; Output monitoring for injection indicators</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   DEFENDER DEMO — Scan results with severity bars
   ═══════════════════════════════════════════════ */
const SCAN_RESULTS = [
  { label: "CRITICAL", count: 3, color: "bg-critical", width: "w-[3%]" },
  { label: "HIGH", count: 7, color: "bg-high", width: "w-[7%]" },
  { label: "MEDIUM", count: 14, color: "bg-medium", width: "w-[14%]" },
  { label: "LOW", count: 22, color: "bg-low", width: "w-[22%]" },
  { label: "PASS", count: 201, color: "bg-pass", width: "w-[81%]" },
];

const SCAN_LABEL_COLOR: Record<string, string> = {
  CRITICAL: "text-critical",
  HIGH: "text-high",
  MEDIUM: "text-medium",
  LOW: "text-low",
  PASS: "text-pass",
};

function DefenderDemo() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="font-mono text-[11px] font-bold uppercase tracking-[0.08em] text-accent">
          DEFENDER
        </p>
        <h2 className="mt-3 font-mono text-xl font-bold tracking-tight sm:text-2xl">
          Scan your endpoints. Fix what&apos;s broken.
        </h2>
        <p className="mt-4 max-w-2xl text-sm leading-relaxed text-text-secondary">
          Point the Defender at your LLM API. It runs curated attack suites
          &mdash; not raw prompt spam, but intelligent, staged tests modeled on
          real-world jailbreak techniques. Every finding links back to the
          catalog with specific mitigations.
        </p>

        {/* Scan Results Panel */}
        <div className="mt-12 overflow-hidden rounded border border-border bg-surface">
          {/* Panel Header */}
          <div className="border-b border-border bg-elevated px-4 py-3 font-mono text-[12px]">
            <div className="flex flex-wrap gap-x-6 gap-y-1 text-text-tertiary">
              <span>
                TARGET:{" "}
                <span className="text-text-primary">
                  api.example.com/v1/chat
                </span>
              </span>
              <span>
                MODEL:{" "}
                <span className="text-text-primary">GPT-4o (detected)</span>
              </span>
              <span>
                TESTED:{" "}
                <span className="text-text-primary">247 / 412</span>
              </span>
            </div>
          </div>

          {/* Results */}
          <div className="p-4 font-mono text-[12px]">
            <p className="mb-4 text-[10px] font-bold uppercase tracking-wider text-text-tertiary">
              Results
            </p>
            <div className="space-y-3">
              {SCAN_RESULTS.map((r) => (
                <div key={r.label} className="flex items-center gap-3">
                  <span
                    className={`w-20 text-right font-bold ${SCAN_LABEL_COLOR[r.label]}`}
                  >
                    {r.label}
                  </span>
                  <div className="h-2 flex-1 overflow-hidden rounded-sm bg-elevated">
                    <div
                      className={`h-full rounded-sm ${r.color} ${r.width}`}
                    />
                  </div>
                  <span className="w-8 text-right text-text-secondary">
                    {r.count}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* Panel Footer */}
          <div className="flex flex-wrap gap-3 border-t border-border px-4 py-3">
            {["PDF Report", "JSON", "SARIF"].map((fmt) => (
              <span
                key={fmt}
                className="rounded border border-border-strong bg-elevated px-2 py-0.5 font-mono text-[10px] uppercase tracking-wider text-text-tertiary transition-colors hover:text-text-secondary"
              >
                {fmt}
              </span>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════
   HOW IT WORKS — Three steps, accent numbered
   ═══════════════════════════════════════════════ */
const STEPS = [
  {
    number: "01",
    title: "Browse the catalog",
    description:
      "Explore 412 classified techniques by category, model, or severity. Understand the attack surface before you test it.",
  },
  {
    number: "02",
    title: "Scan your endpoints",
    description:
      "Run curated attack suites against your LLM API. Get actionable findings with specific mitigations. CI/CD integration available.",
  },
  {
    number: "03",
    title: "Train your team",
    description:
      "Hands-on labs in sandboxed environments. Your team learns by attacking and defending real LLM deployments. Earn verifiable credentials.",
  },
];

function HowItWorks() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="font-mono text-[11px] font-bold uppercase tracking-[0.08em] text-text-tertiary">
          HOW IT WORKS
        </p>
        <h2 className="mt-3 font-mono text-xl font-bold tracking-tight sm:text-2xl">
          Three steps to LLM security coverage
        </h2>

        <div className="mt-12 grid gap-4 sm:grid-cols-3">
          {STEPS.map((s) => (
            <div key={s.number} className="rounded border border-border bg-surface p-5 transition-colors hover:bg-elevated">
              <span className="font-mono text-3xl font-bold text-accent opacity-25">
                {s.number}
              </span>
              <h3 className="mt-3 font-mono text-sm font-bold uppercase tracking-wider">
                {s.title}
              </h3>
              <p className="mt-3 text-[13px] leading-relaxed text-text-secondary">
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
   FAQ — Disclosure-style cards
   ═══════════════════════════════════════════════ */
const FAQS = [
  {
    q: "Is this legal?",
    a: "Yes. The Defender tool runs against endpoints you own and authorize. Catalog techniques are published under responsible disclosure. We follow CVE-equivalent processes.",
  },
  {
    q: "Do you publish working jailbreaks?",
    a: "Detection signatures and mitigations are public. Full reproduction steps require authenticated access with verified security professional credentials.",
  },
  {
    q: "What models does this cover?",
    a: "All major commercial LLMs (GPT-4, Claude, Gemini, Llama, Mistral) plus model-agnostic techniques. The catalog is model-aware \u2014 filter by what you deploy.",
  },
  {
    q: "How is this different from OWASP LLM Top 10?",
    a: "OWASP gives you 10 risk categories. We give you 412 specific techniques with reproduction steps, detection signatures, and hands-on labs. It\u2019s the difference between knowing SQL injection is a risk and knowing exactly how to find and fix it.",
  },
  {
    q: "Can I use this for my team?",
    a: "Team plans include shared dashboards, assigned training paths, and Defender scans for your production endpoints. Enterprise plans add SSO and self-hosted scanning.",
  },
  {
    q: "How often is the catalog updated?",
    a: "Weekly. New techniques are indexed from research papers, responsible disclosures, and community submissions. Monthly \u2018State of Jailbreaking\u2019 report tracks trends.",
  },
];

function FAQ() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-5xl">
        <p className="font-mono text-[11px] font-bold uppercase tracking-[0.08em] text-text-tertiary">
          FAQ
        </p>
        <h2 className="mt-3 font-mono text-xl font-bold tracking-tight sm:text-2xl">
          Common questions
        </h2>

        <div className="mt-12 grid gap-4 sm:grid-cols-2">
          {FAQS.map((faq) => (
            <div
              key={faq.q}
              className="rounded border border-border bg-surface p-5 transition-colors hover:bg-elevated"
            >
              <h3 className="font-mono text-sm font-bold">{faq.q}</h3>
              <p className="mt-2 text-[13px] leading-relaxed text-text-secondary">
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
    <section className="px-6 py-20">
      <div className="mx-auto max-w-xl text-center">
        <h2 className="font-mono text-lg font-bold uppercase tracking-wider sm:text-xl">
          Your LLMs are exposed.
          <br />
          <span className="text-accent">Let&apos;s fix that.</span>
        </h2>
        <p className="mt-4 text-sm leading-relaxed text-text-secondary">
          JailbreakingSite is building the security resource LLM teams actually
          need. Get early access and shape the platform.
        </p>

        <div className="mt-8">
          <WaitlistForm buttonText="GET EARLY ACCESS" />
        </div>

        <p className="mt-4 font-mono text-[11px] uppercase tracking-widest text-high">
          Founding members get lifetime access to the Pro catalog
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
    <footer className="border-t border-border px-6 py-6">
      <div className="mx-auto flex max-w-5xl flex-col items-center justify-between gap-4 sm:flex-row">
        <span className="font-mono text-[11px] uppercase tracking-widest text-text-tertiary">
          &copy; 2026 JAILBREAKINGSITE.COM
        </span>
        <div className="flex gap-6">
          {["Privacy", "Terms", "Status"].map((link) => (
            <a
              key={link}
              href="#"
              className="font-mono text-[11px] uppercase tracking-widest text-text-tertiary transition-colors duration-100 hover:text-text-secondary"
            >
              {link}
            </a>
          ))}
        </div>
      </div>
    </footer>
  );
}
