"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/auth";
import { api, type NplSection } from "@/lib/api";

const REPO_URL = "https://github.com/noizu-labs-ml/NoizuPromptLingo";
const AGENT_KIT_URL = "https://github.com/the-robot-lives/agent-kit-mcp";
const CANONICAL_HOST = "https://promptlingo.dev";
const CONV = `${REPO_URL}/blob/develop/conventions`;

const EXAMPLES = [
  {
    id: "placeholder",
    title: "Placeholders, in-fill, attention",
    source: "syntax.yaml · core-combined-template",
    href: `${CONV}/syntax.yaml`,
    prompt: `Generate user profile summary:

Name: {user.name}
Bio: [...:2-3sentences| professional tone]
Status: {user.status}

🎯 Always include contact information.`,
    output: `Name: Alice
Bio: Senior software engineer with 10 years of experience building distributed systems. Passionate about clean architecture and mentoring junior developers.
Status: active

Contact: alice@example.com`,
  },
  {
    id: "in-fill",
    title: "Qualified in-fill → generated poem",
    source: "syntax.yaml · qualified-in-fill-output",
    href: `${CONV}/syntax.yaml`,
    prompt: `Output: [...:5-7words| list of words related to the word blue]
Poem: [...| based on words]`,
    output: `sad, turquoise, melancholy, sky, paint, navy

Poem: Sad turquoise sky, painted navy blue like my thoughts of you.`,
  },
  {
    id: "prefixes",
    title: "Prefix modes (text + code)",
    source: "prefixes.yaml · text-code-gen",
    href: `${CONV}/prefixes.yaml`,
    prompt: `🖋️➤ Write an opening paragraph for a futuristic city story.
🖥️➤ [Python] Function to check if string is palindrome.`,
    output: `The prefixes tell the model which generation mode to enter — story vs code — without a paragraph of English around each ask.`,
  },
  {
    id: "cot",
    title: "Chain of thought as a tagged pump",
    source: "pumps.yaml · chain-of-thought",
    href: `${CONV}/pumps.yaml`,
    prompt: `<npl-cot>
thought_process:
  - thought: "<initial thought>"
    understanding: "<comprehension>"
    plan: "<approach>"
    rationale: "<justification>"
outcome: "<conclusion>"
</npl-cot>`,
    output: `Load with NPLLoad(expression="pumps#chain-of-thought") instead of pasting a custom CoT ritual into every system prompt.`,
  },
];

const PILLARS = [
  {
    name: "Load, don’t paste",
    desc: "NPLLoad(\"syntax#placeholder pumps#chain-of-thought\") pulls only the conventions this run needs. No 4k-token system dump.",
    img: "/brand/load.jpg",
    alt: "A brass corner-bracket type sort lifted from a composing stick, cobalt ink on the face.",
  },
  {
    name: "Examples with outputs",
    desc: "Every convention ships a thread: the prompt and the generated reply. The gallery below is the same engine the repo uses.",
    img: "/brand/examples.jpg",
    alt: "Two manuscript sheets on a desk: faint rules on the left, the same layout stamped in cobalt ink on the right.",
  },
  {
    name: "Open corpus",
    desc: "YAML in git, MIT license, PRs welcome. The language is the product — not a closed prompt IDE.",
    img: "/brand/vfs.jpg",
    alt: "A standing folder of cream pages with glowing corner-bracket marks at each corner.",
  },
];

const STEPS = [
  {
    n: "01",
    title: "Star or clone the corpus",
    body: "conventions/*.yaml is the source of truth. Fork it, read it, or open a PR for a missing pump.",
  },
  {
    n: "02",
    title: "Point an MCP client at /mcp",
    body: "No API key. Claude Code, Codex, Cursor, and Grok all speak MCP — two tools appear: NPLLoad and NPLSpec.",
  },
  {
    n: "03",
    title: "Load what you need",
    body: "NPLLoad(expression=\"syntax\") in a system prompt. Or generate a versioned ⌜NPL@1.0⌝ block with NPLSpec.",
  },
  {
    n: "04",
    title: "Or browse it as files",
    body: "Mount wss://promptlingo.dev/vfs read-only. Open tobor/_npl/sections/*.md in any editor — the same markdown the gallery renders.",
  },
];

const FAQ = [
  {
    q: "Why not just invent XML tags?",
    a: "You can. Then every teammate and every model sees a different dialect. NPL is one versioned corpus with examples, labels, and an MCP load path so agents don’t re-learn your house style each session.",
  },
  {
    q: "Do I need an account?",
    a: "No. The syntax MCP and REST gallery are public. Clients that insist on OAuth get a site-approval token — not a user login.",
  },
  {
    q: "Is this agent-kit / tobor?",
    a: "No. Sessions, tickets, and chat live in agent-kit-mcp. Promptlingo.dev is the language those agents load.",
  },
  {
    q: "Can I browse it as files?",
    a: "Yes. mcp-mount --url wss://promptlingo.dev/vfs --mount ~/npl --ro — then open tobor/_npl/sections/*.md. No token. Setup: docs/howto/vfs.md in the repo.",
  },
];

type GallerySection = NplSection & { sample?: string };

function mcpUrl(): string {
  if (typeof window === "undefined") return `${CANONICAL_HOST}/mcp`;
  const host = window.location.hostname;
  if (host === "promptlingo.dev" || host === "www.promptlingo.dev" || host === "localhost") {
    if (host === "localhost") return `${window.location.origin}/mcp`;
    return `${CANONICAL_HOST}/mcp`;
  }
  return `${window.location.origin}/mcp`;
}

function mcpAddCommand(url: string): string {
  return `claude mcp add --transport http npl ${url}`;
}

const VFS_MOUNT = "mcp-mount --url wss://promptlingo.dev/vfs --mount ~/npl --ro";

function CopyButton({ text, label, cy }: { text: string; label: string; cy: string }) {
  const [copied, setCopied] = useState(false);
  async function copy() {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
      setTimeout(() => setCopied(false), 1600);
    } catch {
      setCopied(false);
    }
  }
  return (
    <button type="button" className="sg-btn sg-btn--outline" onClick={copy} data-cy={cy}>
      {copied ? "Copied" : label}
    </button>
  );
}

function Landing({ sections }: { sections: GallerySection[] }) {
  const url = mcpUrl();
  const addCmd = mcpAddCommand(url);
  const mountCmd = VFS_MOUNT;
  const [openSection, setOpenSection] = useState<string | null>(
    sections[0]?.section ?? null,
  );

  return (
    <div className="tl-landing">
      <section className="tl-hero tl-hero--with-mascot">
        <div className="tl-hero__copy">
          <span className="tl-badge">Noizu Prompt Lingo · open source</span>
          <h1 className="tl-hero__title">Prompts deserve a real syntax.</h1>
          <p className="tl-hero__sub">
            Placeholders, intuition pumps, and tagged sections — versioned in git,
            loadable by any MCP client. No account. MIT-licensed.
          </p>
          <p className="tl-hero__proof">
            open-source convention corpus · public MCP · no signup
          </p>
          <div className="tl-cta-row">
            <a
              href={REPO_URL}
              className="sg-btn sg-btn--black"
              target="_blank"
              rel="noreferrer"
              data-cy="github-cta"
            >
              Star the repo
            </a>
            <CopyButton text={addCmd} label="Copy MCP add" cy="mcp-copy" />
            <a href="#examples" className="sg-btn sg-btn--outline">
              Browse examples
            </a>
          </div>
          <pre className="tl-gallery__sample tl-gallery__sample--cmd" data-cy="mcp-cmd">
            <code>{addCmd}</code>
          </pre>
        </div>
        <figure className="tl-hero-art">
          <Image
            src="/brand/hero.jpg"
            alt="Typesetter’s desk: metal corner-bracket sorts on cream rag paper beside a cobalt ink pot and a brass rule."
            width={1600}
            height={900}
            priority
            className="tl-hero-art__img"
            sizes="(min-width: 900px) 40vw, 92vw"
          />
          <figcaption className="tl-hero-art__cap">
            Metal type for a language of prompts — the corpus, not a closed IDE.
          </figcaption>
        </figure>
      </section>

      <section className="tl-section" id="examples" aria-labelledby="examples-title">
        <h2 className="tl-section__title" id="examples-title">
          See the language
        </h2>
        <p className="tl-section__lede">
          These threads are from the convention YAML in the repo — prompt in,
          generated output out. Not mockups.
        </p>
        <div className="tl-exgrid" data-cy="npl-examples">
          {EXAMPLES.map((ex) => (
            <article key={ex.id} className="tl-ex" data-cy={`npl-example-${ex.id}`}>
              <header className="tl-ex__head">
                <h3 className="tl-ex__title">{ex.title}</h3>
                <a className="tl-ex__src" href={ex.href} target="_blank" rel="noreferrer">
                  {ex.source}
                </a>
              </header>
              <p className="tl-ex__label">Prompt</p>
              <pre className="tl-gallery__sample"><code>{ex.prompt}</code></pre>
              <p className="tl-ex__label">Output</p>
              <pre className="tl-gallery__sample"><code>{ex.output}</code></pre>
            </article>
          ))}
        </div>
      </section>

      <section className="tl-section" aria-labelledby="why-title">
        <h2 className="tl-section__title" id="why-title">
          Why a language, not a vibe
        </h2>
        <div className="tl-grid">
          {PILLARS.map((d) => (
            <article key={d.name} className="tl-feature tl-feature--photo">
              <Image
                src={d.img}
                alt={d.alt}
                width={800}
                height={800}
                className="tl-feature__img"
                sizes="(min-width: 900px) 28vw, 90vw"
              />
              <h3 className="tl-feature__name">{d.name}</h3>
              <p className="tl-feature__desc">{d.desc}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="tl-section" aria-labelledby="how-title">
        <h2 className="tl-section__title" id="how-title">
          How to use it
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

      <section className="tl-section" id="gallery" aria-labelledby="gallery-title">
        <h2 className="tl-section__title" id="gallery-title">
          Generated section outputs
        </h2>
        <p className="tl-section__lede">
          Live render from the convention engine — the same markdown the admin
          “Generate NPL spec” action and the VFS <code>sections/*.md</code> files produce.
        </p>
        {sections.length === 0 ? (
          <p className="tl-section__lede">
            Gallery API is offline in this view. The static examples above are the corpus.
          </p>
        ) : (
          <div className="tl-gallery" data-cy="npl-gallery">
            <div className="tl-gallery__tabs" role="tablist" aria-label="NPL sections">
              {sections.map((s) => (
                <button
                  key={s.section}
                  type="button"
                  role="tab"
                  aria-selected={openSection === s.section}
                  className={`tl-gallery__tab${openSection === s.section ? " is-active" : ""}`}
                  onClick={() => setOpenSection(s.section)}
                >
                  {s.title}
                  <span className="tl-gallery__count">{s.component_count}</span>
                </button>
              ))}
            </div>
            {sections
              .filter((s) => s.section === openSection)
              .map((s) => (
                <article key={s.section} className="tl-gallery__panel" data-cy={`npl-section-${s.section}`}>
                  <h3 className="tl-gallery__name">{s.title}</h3>
                  <p className="tl-gallery__brief">{s.brief || s.description}</p>
                  <pre className="tl-gallery__sample">
                    <code>{s.sample || "No generated sample for this section."}</code>
                  </pre>
                </article>
              ))}
          </div>
        )}
      </section>

      <section className="tl-vfs" aria-labelledby="vfs-title">
        <figure className="tl-vfs__art">
          <Image
            src="/brand/vfs.jpg"
            alt="Open folder of cream manuscript pages with glowing corner-bracket marks — the VFS as files you can browse."
            width={1600}
            height={1200}
            className="tl-vfs__img"
            sizes="(min-width: 900px) 42vw, 92vw"
          />
        </figure>
        <div className="tl-vfs__copy">
          <h2 className="tl-section__title" id="vfs-title">
            Browse the syntax as files
          </h2>
          <p className="tl-section__lede">
            The VFS mounts <code>tobor/_npl</code> as YAML sources, grouped
            markdown per section, and the full <code>spec.md</code>. Same engine
            as the gallery. No token.
          </p>
          <pre className="tl-gallery__sample tl-gallery__sample--cmd" data-cy="vfs-cmd">
            <code>{mountCmd}</code>
          </pre>
          <div className="tl-cta-row">
            <CopyButton text={mountCmd} label="Copy mount command" cy="vfs-copy" />
            <a
              href={`${REPO_URL}/blob/develop/docs/howto/vfs.md`}
              className="sg-btn sg-btn--outline"
              target="_blank"
              rel="noreferrer"
            >
              VFS setup
            </a>
          </div>
        </div>
      </section>

      <section className="tl-section" aria-labelledby="oss-title">
        <h2 className="tl-section__title" id="oss-title">
          The repo is the spec
        </h2>
        <p className="tl-section__lede">
          <code>conventions/</code> holds the YAML. <code>NPLLoad</code> and{" "}
          <code>NPLSpec</code> serve it. Issues and PRs for missing pumps or
          clearer examples are the contribution path.
        </p>
        <div className="tl-cta-row">
          <a href={REPO_URL} className="sg-btn sg-btn--black" target="_blank" rel="noreferrer">
            github.com/noizu-labs-ml/NoizuPromptLingo
          </a>
          <a href={AGENT_KIT_URL} className="sg-btn sg-btn--outline" target="_blank" rel="noreferrer">
            Agent kit (separate)
          </a>
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

      <section className="tl-section" aria-labelledby="keyboard-title">
        <h2 className="tl-section__title" id="keyboard-title">
          Get the NPL Keyboard
        </h2>
        <p className="tl-section__lede">
          The NPL Keyboard puts the full Noizu Prompt Lingua catalog — syntax, unicode glyphs,
          agent directives — behind a system-wide hotkey on macOS. Try it right here in the
          browser: the web edition lets you browse the catalog and build finished NPL prompts from
          a plain-language description.
        </p>
        <ul className="tl-checklist">
          <li>NPL syntax palette with fuzzy search — ⌜NPL@1.0⌝ frames, directives, personas</li>
          <li>Unicode + NPL emoji quick-pick with usage descriptions</li>
          <li>Web Prompt Builder: describe what you want, get a composed NPL prompt</li>
        </ul>
        <div>
          <a href="/keyboard" className="sg-btn sg-btn--black">
            Open the web keyboard
          </a>
          <p className="tl-section__note">
            macOS app: from the agent-kit repo root —{" "}
            <code>cd tools/npl-keyboard &amp;&amp; make install-osx</code>. Tagged release zips are
            planned.
          </p>
        </div>
      </section>

      <section className="tl-final">
        <h2 className="tl-final__title">Load the conventions</h2>
        <p className="tl-final__sub">
          Public MCP at <code>{url}</code>. Star the repo, add the server, write in NPL.
        </p>
        <div className="tl-cta-row">
          <a href={REPO_URL} className="sg-btn sg-btn--black" target="_blank" rel="noreferrer">
            Star the repo
          </a>
          <CopyButton text={addCmd} label="Copy MCP add" cy="mcp-copy-footer" />
        </div>
      </section>

      <footer className="tl-footer">
        <p className="tl-footer__legal">
          © Noizu Labs · MIT ·{" "}
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
  const [sections, setSections] = useState<GallerySection[]>([]);

  useEffect(() => {
    if (!loading && user) router.replace("/app");
  }, [loading, user, router]);

  useEffect(() => {
    if (loading || user) return;
    let cancelled = false;
    api
      .nplGallery()
      .then((data) => {
        if (!cancelled) setSections(data.sections ?? []);
      })
      .catch(() => {
        if (!cancelled) setSections([]);
      });
    return () => {
      cancelled = true;
    };
  }, [loading, user]);

  const ready = useMemo(() => !loading && !user, [loading, user]);

  return (
    <div className="content">
      {ready ? (
        <Landing sections={sections} />
      ) : (
        <div className="tl-loading" aria-busy="true" aria-label="Loading" />
      )}
    </div>
  );
}
