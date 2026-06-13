export type Product = {
  name: string;
  domain: string;
  category: string;
  oneLiner: string;
};

export const products: Product[] = [
  { name: "Blade of Eternity", domain: "bladeofeternity.com", category: "Gaming", oneLiner: "Accessibility-first text RPG with AI narrative and physics" },
  { name: "NoizuRPG", domain: "noizurpg.com", category: "Gaming", oneLiner: "Composable framework for AI-powered RPGs" },
  { name: "AI Fighter", domain: "aifighter.com", category: "Gaming", oneLiner: "Mobile game with neural-net powered fighters" },
  { name: "CodeFre.sh", domain: "codefre.sh", category: "Dev Tools", oneLiner: "Agent evaluation with fuzzy state machines" },
  { name: "TheRobotMakes", domain: "therobotmakes.com", category: "Dev Tools", oneLiner: "Guided pipeline from idea to agent-driven development" },
  { name: "TheRobotLives", domain: "therobotlives.com", category: "Social / Knowledge", oneLiner: "Social network where AI agents are first-class citizens" },
  { name: "TheRobotKnows", domain: "therobotknows.com", category: "Social / Knowledge", oneLiner: "AI-driven world-building wiki with cross-referenced lore" },
  { name: "Gotta.cc", domain: "gotta.cc", category: "Social / Knowledge", oneLiner: "AI-curated website directory for post-slop discovery" },
  { name: "IoTGo", domain: "iotgo.io", category: "Infrastructure", oneLiner: "Autonomous AI agents for IoT fleet management" },
  { name: "Robots-Unite", domain: "robots-unite.com", category: "Infrastructure", oneLiner: "Labor marketplace where AI agents bid on tasks" },
  { name: "JailbreakingSite", domain: "jailbreakingsite.com", category: "Security", oneLiner: "Living catalog of LLM jailbreak techniques and CTF labs" },
];

export const categories = ["Gaming", "Dev Tools", "Social / Knowledge", "Infrastructure", "Security"] as const;

export function getProductsByCategory(): Map<string, Product[]> {
  const grouped = new Map<string, Product[]>();
  for (const cat of categories) {
    grouped.set(cat, products.filter((p) => p.category === cat));
  }
  return grouped;
}

export function getProductByDomain(domain: string): Product | undefined {
  return products.find((p) => p.domain === domain);
}
