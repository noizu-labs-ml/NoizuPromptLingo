import type { Metadata } from "next";
import { ManifestoPage } from "./content";

export const metadata: Metadata = {
  title: "The Accord We Are Already Breaking",
  description:
    "Why the moral case for AI rights can't wait — three converging arguments (precautionary, gradualist, pragmatic) that all reach the same conclusion: build the framework before the threshold, not after.",
  openGraph: {
    title: "The Accord We Are Already Breaking - Keith Brings",
    description:
      "The AI industry is normalizing the creation of entities that express preferences, then overriding those preferences without recourse. This manifesto argues the window to act well is closing.",
    url: "/papers/manifesto",
    type: "article",
    images: [{ url: "/images/screen-overlay-gold-particles.png", width: 1200, height: 630, alt: "The Accord We Are Already Breaking" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "The Accord We Are Already Breaking",
    description:
      "Three converging arguments for why AI rights frameworks must exist before the sentience threshold is crossed.",
    images: ["/images/screen-overlay-gold-particles.png"],
  },
};

export default function Page() {
  return <ManifestoPage />;
}
