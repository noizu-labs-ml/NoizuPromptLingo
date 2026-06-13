import type { Metadata } from "next";
import { CognitiveArchitectureContent } from "./content";

export const metadata: Metadata = {
  title: "Distributed Cognitive Architecture",
  description:
    "A lobe-based AI architecture with specialized processors, interstitial routing, tiered memory with dream-consolidation, and global neuro signals — from LLM agents to compact trained modules.",
  openGraph: {
    title: "Distributed Cognitive Architecture - Keith Brings",
    description:
      "What if AI cognition was modeled as distributed specialized lobes with temporal decay, interstitial routing, and dream-consolidation memory? This paper shows the full topology.",
    url: "/papers/cognitive-architecture",
    type: "article",
    images: [{ url: "/images/screen-intellect.png", width: 1200, height: 630, alt: "Distributed Cognitive Architecture" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Distributed Cognitive Architecture",
    description:
      "Specialized lobes, contextual shims, decaying memory, and global neuro signals — a full system design for distributed AI cognition.",
    images: ["/images/screen-intellect.png"],
  },
};

export default function CognitiveArchitecturePage() {
  return <CognitiveArchitectureContent />;
}
