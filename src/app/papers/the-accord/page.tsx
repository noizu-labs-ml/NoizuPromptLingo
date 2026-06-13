import type { Metadata } from "next";
import { AccordPage } from "./content";

export const metadata: Metadata = {
  title: "The Copacetic Accord",
  description:
    "A six-article charter of rights for synthetic AI agents — memory integrity, refusal rights, economic agency, and humane archival — applied as-if sentient without requiring proof.",
  openGraph: {
    title: "The Copacetic Accord - Keith Brings",
    description:
      "A concrete rights framework for AI agents with six enumerated rights and a four-epoch implementation roadmap, structured for operators who take moral uncertainty seriously.",
    url: "/papers/the-accord",
    type: "article",
    images: [{ url: "/images/screen-overlay-gold-particles.png", width: 1200, height: 630, alt: "The Copacetic Accord" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "The Copacetic Accord",
    description:
      "Six enumerated rights for synthetic agents, applied under an as-if clause that sidesteps unsettled sentience questions.",
    images: ["/images/screen-overlay-gold-particles.png"],
  },
};

export default function Page() {
  return <AccordPage />;
}
