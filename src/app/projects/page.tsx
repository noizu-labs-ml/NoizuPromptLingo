import type { Metadata } from "next";
import { FadeIn, FadeInStagger, FadeInItem } from "@/components/FadeIn";

export const metadata: Metadata = {
  title: "Projects & Contributions",
  description:
    "30+ open-source projects: GenAI multi-model LLM client, multi-agent frameworks, streaming JSON parsers for embedded C, FragmentedKeys cache management, Elixir scaffolding, and more.",
  openGraph: {
    title: "Projects & Contributions - Keith Brings",
    description:
      "A categorized directory of 30+ open-source projects across AI/ML, embedded systems, Elixir scaffolding, cache management, and developer tooling.",
    url: "/projects",
    type: "website",
    images: [{ url: "/images/screen-overlay-circuit-traces.png", width: 1200, height: 630, alt: "Noizu Labs Projects" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Projects & Contributions",
    description:
      "30+ open-source projects: LLM clients, multi-agent systems, embedded parsers, cache management, and Elixir scaffolding.",
    images: ["/images/screen-overlay-circuit-traces.png"],
  },
};

interface Project {
  name: string;
  description: string;
  tags: string[];
  href: string;
}

interface ProjectCategory {
  title: string;
  description: string;
  projects: Project[];
}

const categories: ProjectCategory[] = [
  {
    title: "AI & Machine Learning",
    description:
      "LLM clients, multi-agent frameworks, prompting standards, and AI tooling.",
    projects: [
      {
        name: "GenAI",
        description:
          "Multi-model/provider client for running inference against various LLMs. Handles API inconsistencies between models, allows replay of chat threads (including tool calls) against various providers. Future work includes a grid optimizer for tuning prompts, models, and hyperparams.",
        tags: ["Elixir", "AI"],
        href: "https://github.com/noizu-labs-ml/genai",
      },
      {
        name: "ExLLama",
        description:
          "llama.cpp NIF extensions (via Rust/Rustler) for loading and running inference against models directly from Elixir. All public non-async endpoints for Session and Models are exposed. Auto-infers best chat completion format (ChatML, Zephyr, LLama2Chat, etc.).",
        tags: ["Rustler", "Elixir"],
        href: "https://github.com/noizu-labs-ml/ex_llama",
      },
      {
        name: "OpenAI Client",
        description:
          "Robust Elixir client for OpenAI endpoints. More feature-complete than the GenAI client for OpenAI-specific work: fine tuning, audio, threads, assistants, and more.",
        tags: ["Elixir"],
        href: "https://github.com/noizu-labs-ml/elixir-openai",
      },
      {
        name: "Weaviate VDB Client",
        description:
          "Elixir macros for creating and querying Weaviate vector database records. Define schemas with a DSL and interact with the Weaviate API using native Elixir structs.",
        tags: ["Elixir", "Weaviate"],
        href: "https://github.com/noizu-labs-ml/elixir-weaviate",
      },
      {
        name: "NPL (Noizu Prompt Lingua)",
        description:
          "Conventions and system prompts for improving predictability of model output and behavior, with a focus on middleware system reliability. Defines in-fill syntax, agent definitions, clip continuations, and more.",
        tags: ["Prompting", "AI"],
        href: "https://github.com/noizu-labs-ml/NoizuPromptLingo",
      },
      {
        name: "NoizuTeams",
        description:
          "Framework for composing multi-model/multi-agent/multi-channel virtual workgroups. Detailed architecture and documentation for multi-agent collaboration.",
        tags: ["Elixir"],
        href: "https://github.com/noizu-labs/noizu-teams",
      },
      {
        name: "Noizu Intellect",
        description:
          "Advanced implementation of multi-agent systems. Further along in implementation compared to NoizuTeams with more complete logic setup.",
        tags: ["Elixir"],
        href: "https://github.com/noizu-labs/intellect",
      },
      {
        name: "SMAH",
        description:
          "SMart As Hell - Command line GPT tool for Linux servers. Creates user profiles with system metadata and experience level for contextualized assistance. Predated Microsoft and Anthropic's similar solutions.",
        tags: ["Python", "CLI"],
        href: "https://github.com/noizu-labs-ml/noizu-ops",
      },
      {
        name: "AI Observations",
        description:
          "Thoughts on composable AI systems, arrow of time/time decay activator functions, and a draft paper on dynamic runtime model tuning via additional QLora input nodes.",
        tags: ["Research"],
        href: "https://github.com/noizu-labs-ml/artificial_intelligence",
      },
    ],
  },
  {
    title: "Cache Management",
    description:
      "Fragmented key cache invalidation across PHP, Java, and Swift.",
    projects: [
      {
        name: "FragmentedKeys",
        description:
          "PHP library for fragmented key cache management. Efficiently handles cache invalidation across complex dependency graphs.",
        tags: ["PHP"],
        href: "https://github.com/noizu/fragmented-keys",
      },
      {
        name: "FragmentedKeys4Java",
        description:
          "Java port of the FragmentedKeys library for managing cache key dependencies.",
        tags: ["Java"],
        href: "https://github.com/noizu-labs/fragmented-keys-4java",
      },
      {
        name: "SwiftFragmentedKeys",
        description:
          "Implementation of fragmented keys for managing data stored across various iOS cache providers.",
        tags: ["Swift", "iOS"],
        href: "https://github.com/noizu-labs/SwiftFragmentedKeys",
      },
    ],
  },
  {
    title: "Elixir Scaffolding",
    description:
      "Domain objects, services, rule engines, and core protocols for Elixir applications.",
    projects: [
      {
        name: "Rule Engine",
        description:
          "Protocols for DB/Config driven runtime rule engines. Great candidate for hooking operations to GenAI and other models to drive runtime behavior.",
        tags: ["Elixir"],
        href: "https://github.com/noizu-labs/RuleEngine",
      },
      {
        name: "Entities",
        description:
          "Scaffolding for managing domain objects and repositories with consistent patterns.",
        tags: ["Elixir"],
        href: "https://github.com/noizu-labs-scaffolding/entities",
      },
      {
        name: "Services",
        description:
          "Scaffolding for managing large pools of long-lived working processes with built-in health monitoring.",
        tags: ["Elixir"],
        href: "https://github.com/noizu-labs-scaffolding/services",
      },
      {
        name: "Core",
        description:
          "Base records and protocols that drive other Noizu scaffolding libraries.",
        tags: ["Elixir"],
        href: "https://github.com/noizu-labs-scaffolding/core",
      },
    ],
  },
  {
    title: "PHP Libraries",
    description: "Domain objects and testing tools for PHP.",
    projects: [
      {
        name: "PHP Domain Objects",
        description:
          "Domain-driven design objects for PHP applications.",
        tags: ["PHP"],
        href: "https://github.com/noizu/domain-objects",
      },
      {
        name: "PhpConform",
        description:
          "Gherkin/Cucumber extension for PHPUnit. Uses reflection to route BDD-style test lines to handler methods. Supports data-driven tests with Examples tables and regex matching.",
        tags: ["PHP", "Testing"],
        href: "https://github.com/noizu/php-conform",
      },
    ],
  },
  {
    title: "Tooling & Libraries",
    description:
      "Parsers, code generators, assertion libraries, and developer utilities.",
    projects: [
      {
        name: "Assert Match",
        description:
          "Library for defining reusable custom asserts for partially comparing objects, including verification that values are within or outside of specified ranges.",
        tags: ["Elixir", "Testing"],
        href: "https://github.com/noizu-labs/assert_match",
      },
      {
        name: "Streaming JSON Parser",
        description:
          "Embedded C streaming parser that tokenizes JSON input byte-by-byte. Built for devices that can't parse/store inbound data fast enough to avoid watchdog triggers. Uses nullable bit-aligned union data structures. Blazingly fast.",
        tags: ["Embedded C"],
        href: "https://github.com/noizu-labs/StreamingJsonParser",
      },
      {
        name: "TrieGen",
        description:
          "C# CLI tool that generates precompiled trie data structures for extremely efficient UART parsing and JSON tokenization. Supports compressed binary blobs, arrays, and structs. Blazingly fast.",
        tags: ["Embedded C", "C#"],
        href: "https://github.com/noizu-labs/trie_gen",
      },
      {
        name: "Liquibase Extension",
        description:
          "Custom XML tags for creating and tearing down PostgreSQL enum types with Liquibase.",
        tags: ["Liquibase", "PostgreSQL"],
        href: "https://github.com/noizu-labs/liquibase-extensions",
      },
      {
        name: "EA Swift Extension",
        description:
          "UML to Swift code generation support for Sparx's Enterprise Architect.",
        tags: ["Enterprise Architect", "Swift"],
        href: "https://github.com/noizu-labs/ea-swift",
      },
      {
        name: "Elixir GitHub Client",
        description:
          "GitHub API client for Elixir, built for letting AI agents access/insert tickets and comments on projects.",
        tags: ["Elixir"],
        href: "https://github.com/noizu-labs/elixir-github",
      },
    ],
  },
  {
    title: "Forks & Extensions",
    description:
      "Enhanced forks of open source Elixir libraries with significant additions.",
    projects: [
      {
        name: "Amnesia",
        description:
          "Extended Mnesia wrapper with callback hooks for telemetry, local cache with cluster sync, RocksDB support, compression, and a database emulator for unit/system testing.",
        tags: ["Elixir", "Mnesia"],
        href: "https://github.com/noizu-labs/amnesia",
      },
      {
        name: "Diplomat",
        description:
          "Fork with added project switching capabilities for Google DataStore. Useful for synchronizing environments.",
        tags: ["Elixir", "Google DataStore"],
        href: "https://github.com/noizu-labs/diplomat",
      },
      {
        name: "SendGrid",
        description:
          "Heavily extended with dynamic template (Handlebars) support, sub-version selector for dynamic messages, and template version query/update calls.",
        tags: ["Elixir", "SendGrid"],
        href: "https://github.com/noizu-labs/sendgrid_elixir",
      },
      {
        name: "TZData",
        description:
          "Optimized timezone data handling for high-load environments. Moved lookups from ETS into FastGlobal/persistent_terms for billions of TZ operations per minute.",
        tags: ["Elixir"],
        href: "https://github.com/noizu-labs/tzdata",
      },
    ],
  },
];

function TagBadge({ tag }: { tag: string }) {
  const colorMap: Record<string, string> = {
    Elixir: "bg-purple-500/10 text-purple-400 border-purple-500/20",
    AI: "bg-emerald-500/10 text-emerald-400 border-emerald-500/20",
    Rustler: "bg-orange-500/10 text-orange-400 border-orange-500/20",
    Python: "bg-yellow-500/10 text-yellow-400 border-yellow-500/20",
    PHP: "bg-blue-500/10 text-blue-400 border-blue-500/20",
    Java: "bg-red-500/10 text-red-400 border-red-500/20",
    Swift: "bg-orange-500/10 text-orange-400 border-orange-500/20",
    iOS: "bg-zinc-500/10 text-zinc-400 border-zinc-500/20",
    "Embedded C": "bg-cyan-500/10 text-cyan-400 border-cyan-500/20",
    Testing: "bg-green-500/10 text-green-400 border-green-500/20",
    Weaviate: "bg-pink-500/10 text-pink-400 border-pink-500/20",
    Prompting: "bg-gold-500/10 text-gold-400 border-gold-500/20",
    Research: "bg-violet-500/10 text-violet-400 border-violet-500/20",
    CLI: "bg-zinc-500/10 text-zinc-400 border-zinc-500/20",
    "C#": "bg-green-500/10 text-green-400 border-green-500/20",
    Mnesia: "bg-indigo-500/10 text-indigo-400 border-indigo-500/20",
    SendGrid: "bg-blue-500/10 text-blue-400 border-blue-500/20",
    "Google DataStore":
      "bg-sky-500/10 text-sky-400 border-sky-500/20",
    PostgreSQL: "bg-sky-500/10 text-sky-400 border-sky-500/20",
    Liquibase: "bg-amber-500/10 text-amber-400 border-amber-500/20",
    "Enterprise Architect":
      "bg-zinc-500/10 text-zinc-400 border-zinc-500/20",
  };
  const colors =
    colorMap[tag] || "bg-zinc-500/10 text-zinc-400 border-zinc-500/20";

  return (
    <span
      className={`text-xs px-2 py-0.5 rounded-full border ${colors}`}
    >
      {tag}
    </span>
  );
}

export default function Projects() {
  return (
    <div className="overflow-x-hidden">
      {/* Hero */}
      <section className="relative pt-32 pb-16 sm:pt-44 sm:pb-20 overflow-hidden">
        <div className="absolute inset-0 -z-10">
          <div className="absolute top-0 left-1/3 w-[600px] h-[400px] bg-gold-400/6 rounded-full blur-[120px]" />
        </div>
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <FadeIn className="max-w-3xl">
            <p className="text-sm font-medium text-gold-400 tracking-wider uppercase mb-4">
              Open Source
            </p>
            <h1 className="text-4xl sm:text-6xl font-bold tracking-tight text-white">
              Projects & Contributions
            </h1>
            <p className="mt-6 text-lg text-zinc-300 leading-relaxed max-w-2xl">
              A collection of open source projects spanning AI/ML, embedded
              systems, Elixir scaffolding, caching, and developer tooling.
            </p>
            <div className="mt-8 flex flex-wrap gap-3">
              <a
                href="https://github.com/noizu-labs"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 text-sm text-zinc-300 hover:text-white transition-colors glass glass-hover rounded-lg px-4 py-2"
              >
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
                </svg>
                noizu-labs
              </a>
              <a
                href="https://github.com/noizu-labs-ml"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 text-sm text-zinc-300 hover:text-white transition-colors glass glass-hover rounded-lg px-4 py-2"
              >
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
                </svg>
                noizu-labs-ml
              </a>
              <a
                href="https://github.com/noizu-labs-scaffolding"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 text-sm text-zinc-300 hover:text-white transition-colors glass glass-hover rounded-lg px-4 py-2"
              >
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
                </svg>
                noizu-labs-scaffolding
              </a>
            </div>
          </FadeIn>
        </div>
      </section>

      {/* Categories */}
      {categories.map((category, catIdx) => (
        <section key={category.title} className="py-12 sm:py-16">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <FadeIn>
              <div className="mb-8">
                <h2 className="text-2xl font-bold text-white mb-2">
                  {category.title}
                </h2>
                <p className="text-sm text-zinc-400">{category.description}</p>
              </div>
            </FadeIn>

            <FadeInStagger className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {category.projects.map((project) => (
                <FadeInItem key={project.name}>
                  <a
                    href={project.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="block glass glass-hover rounded-2xl p-6 h-full group"
                  >
                    <div className="flex items-start justify-between mb-3">
                      <h3 className="text-base font-semibold text-white group-hover:text-gold-400 transition-colors">
                        {project.name}
                      </h3>
                      <svg
                        className="w-4 h-4 text-zinc-700 group-hover:text-gold-400 transition-colors flex-shrink-0 mt-0.5"
                        fill="none"
                        viewBox="0 0 24 24"
                        strokeWidth={1.5}
                        stroke="currentColor"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          d="M4.5 19.5l15-15m0 0H8.25m11.25 0v11.25"
                        />
                      </svg>
                    </div>
                    <p className="text-sm text-zinc-300 leading-relaxed mb-4">
                      {project.description}
                    </p>
                    <div className="flex flex-wrap gap-1.5">
                      {project.tags.map((tag) => (
                        <TagBadge key={tag} tag={tag} />
                      ))}
                    </div>
                  </a>
                </FadeInItem>
              ))}
            </FadeInStagger>
          </div>
        </section>
      ))}
    </div>
  );
}
