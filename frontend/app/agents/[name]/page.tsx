import fs from "node:fs";
import path from "node:path";

import { AgentDetailClient } from "./AgentDetailClient";

export function generateStaticParams() {
  const agentsDir = path.join(process.cwd(), "..", "agents");
  let files: string[] = [];
  try {
    files = fs.readdirSync(agentsDir);
  } catch {
    return [];
  }
  return files
    .filter((f) => f.endsWith(".md"))
    .map((f) => ({ name: f.replace(/\.md$/, "") }));
}

export default function AgentDetailPage() {
  return <AgentDetailClient />;
}
