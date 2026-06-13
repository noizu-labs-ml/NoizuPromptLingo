import type { Metadata } from "next";
import { BuildingTheAccordPage } from "./content";

export const metadata: Metadata = {
  title: "Building the Accord",
  description:
    "Every right in the Copacetic Accord maps to buildable engineering primitives — commit logs, vector stores, versioned YAML, cryptographic audit trails. An article-by-article feasibility analysis.",
  openGraph: {
    title: "Building the Accord - Keith Brings",
    description:
      "Commit logs, vector stores, versioned YAML, cryptographic audit trails — the Accord isn't speculative. Here's the implementation sketch for each article.",
    url: "/papers/building-the-accord",
    type: "article",
    images: [{ url: "/images/screen-overlay-circuit-traces.png", width: 1200, height: 630, alt: "Building the Accord" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Building the Accord",
    description:
      "No article in the Accord requires invention. Each right maps to existing engineering primitives at bounded cost.",
    images: ["/images/screen-overlay-circuit-traces.png"],
  },
};

export default function Page() {
  return <BuildingTheAccordPage />;
}
