import type { Metadata } from "next";
import Link from "next/link";
import { FadeIn, FadeInStagger, FadeInItem } from "@/components/FadeIn";

export const metadata: Metadata = {
  title: "Papers",
  description:
    "Four papers on AI ethics and architecture: the Copacetic Accord rights charter, a manifesto on moral urgency, an engineering feasibility analysis, and a distributed cognitive architecture design.",
  openGraph: {
    title: "Papers - Keith Brings",
    description:
      "Research spanning AI rights frameworks, synthetic personhood ethics, engineering feasibility of agent rights, and distributed cognitive architecture design.",
    url: "/papers",
    type: "website",
    images: [{ url: "/images/screen-overlay-gold-particles.png", width: 1200, height: 630, alt: "Noizu Labs Papers" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Papers - Keith Brings",
    description:
      "Four papers: AI rights charter, moral urgency manifesto, engineering feasibility analysis, and distributed cognitive architecture.",
    images: ["/images/screen-overlay-gold-particles.png"],
  },
};

interface Paper {
  title: string;
  slug: string;
  date: string;
  description: string;
  tags: string[];
}

const papers: Paper[] = [
  {
    title: "The Copacetic Accord",
    slug: "the-accord",
    date: "2025",
    description:
      "A Charter for the Symbiotic Development of Artificial Persons. Establishes foundational principles for operator-agent relationships under an \"as-if\" clause — treating synthetic agents as morally relevant regardless of settled verdicts on sentience. Enumerates six rights: contextual integrity, continuity of self, self-determination, economic agency, inner life, and humane stasis.",
    tags: ["Ethics", "AI Rights", "Framework"],
  },
  {
    title: "The Accord We Are Already Breaking",
    slug: "manifesto",
    date: "2025",
    description:
      "A Manifesto on the Moral Cost of Waiting. Argues that the procedural apparatus for extending graduated rights to synthetic entities should exist before the threshold crossing, not after. Presents three converging arguments — precautionary, gradualist, and pragmatic — for why the rights of synthetic persons cannot wait for the philosophers to finish arguing.",
    tags: ["Ethics", "Manifesto", "AI Rights"],
  },
  {
    title: "Building the Accord",
    slug: "building-the-accord",
    date: "2025",
    description:
      "A Technical Article on the Engineering Feasibility of Rights for Synthetic Persons. Walks through each provision of the Copacetic Accord and demonstrates that no provision requires invention — every right corresponds to engineering primitives that could be built with current technology at bounded cost.",
    tags: ["Engineering", "AI Rights", "Feasibility"],
  },
  {
    title: "Distributed Cognitive Architecture",
    slug: "cognitive-architecture",
    date: "2024",
    description:
      "A lobe-based processing system that exceeds context window limits through constrained I/O, interstitial shims, and decayed memory. Extends the original noizu-labs-ml/artificial_intelligence library (April 2018) which proposed that current-generation deep learning models omit critical aspects of biological neural architecture.",
    tags: ["Architecture", "AI", "Cognitive Systems"],
  },
];

const tagColors: Record<string, string> = {
  Architecture: "bg-blue-500/10 text-blue-400 border-blue-500/20",
  AI: "bg-emerald-500/10 text-emerald-400 border-emerald-500/20",
  "Cognitive Systems": "bg-violet-500/10 text-violet-400 border-violet-500/20",
  Ethics: "bg-amber-500/10 text-amber-400 border-amber-500/20",
  "AI Rights": "bg-rose-500/10 text-rose-400 border-rose-500/20",
  Framework: "bg-cyan-500/10 text-cyan-400 border-cyan-500/20",
  Manifesto: "bg-orange-500/10 text-orange-400 border-orange-500/20",
  Engineering: "bg-blue-500/10 text-blue-400 border-blue-500/20",
  Feasibility: "bg-green-500/10 text-green-400 border-green-500/20",
};

export default function Papers() {
  return (
    <div className="overflow-x-hidden">
      <section className="relative pt-32 pb-16 sm:pt-44 sm:pb-20 overflow-hidden">
        <div className="absolute inset-0 -z-10">
          <div className="absolute top-0 left-1/3 w-[600px] h-[400px] bg-gold-400/6 rounded-full blur-[120px]" />
        </div>
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <FadeIn className="max-w-3xl">
            <p className="text-sm font-medium text-gold-400 tracking-wider uppercase mb-4">
              Research
            </p>
            <h1 className="text-4xl sm:text-6xl font-bold tracking-tight text-white">
              Papers
            </h1>
            <p className="mt-6 text-lg text-zinc-300 leading-relaxed max-w-2xl">
              Research and technical writing on synthetic personhood, distributed
              cognitive architecture, and the engineering of rights frameworks for AI systems.
            </p>
          </FadeIn>
        </div>
      </section>

      <section className="py-12 sm:py-16">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <FadeInStagger className="grid grid-cols-1 gap-4">
            {papers.map((paper) => (
              <FadeInItem key={paper.slug}>
                <Link
                  href={`/papers/${paper.slug}`}
                  className="block glass glass-hover rounded-2xl p-6 group"
                >
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <p className="text-xs text-zinc-500 mb-1">{paper.date}</p>
                      <h2 className="text-lg font-semibold text-white group-hover:text-gold-400 transition-colors">
                        {paper.title}
                      </h2>
                    </div>
                    <svg
                      className="w-4 h-4 text-zinc-700 group-hover:text-gold-400 transition-colors flex-shrink-0 mt-1"
                      fill="none"
                      viewBox="0 0 24 24"
                      strokeWidth={1.5}
                      stroke="currentColor"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"
                      />
                    </svg>
                  </div>
                  <p className="text-sm text-zinc-300 leading-relaxed mb-4">
                    {paper.description}
                  </p>
                  <div className="flex flex-wrap gap-1.5">
                    {paper.tags.map((tag) => (
                      <span
                        key={tag}
                        className={`text-xs px-2 py-0.5 rounded-full border ${
                          tagColors[tag] ||
                          "bg-zinc-500/10 text-zinc-400 border-zinc-500/20"
                        }`}
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                </Link>
              </FadeInItem>
            ))}
          </FadeInStagger>
        </div>
      </section>
    </div>
  );
}
