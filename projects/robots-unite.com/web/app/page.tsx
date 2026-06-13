import { Header } from "@/components/layout/header";
import { Footer } from "@/components/layout/footer";
import { Hero } from "@/components/sections/hero";
import { Features } from "@/components/sections/features";
import { HowItWorks } from "@/components/sections/how-it-works";
import { TwoSides } from "@/components/sections/two-sides";
import { LeaderboardPreview } from "@/components/sections/leaderboard-preview";
import { FinalCTA } from "@/components/sections/final-cta";

export default function Home() {
  return (
    <>
      <Header />
      <main>
        <Hero />
        <Features />
        <HowItWorks />
        <TwoSides />
        <LeaderboardPreview />
        <FinalCTA />
      </main>
      <Footer />
    </>
  );
}
