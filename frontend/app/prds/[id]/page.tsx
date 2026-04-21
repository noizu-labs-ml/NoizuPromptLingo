import { PRD_SUMMARIES } from "@/lib/api/mock/prds";
import { PRDDetailClient } from "./PRDDetailClient";

export function generateStaticParams() {
  return PRD_SUMMARIES.map((p) => ({ id: p.id }));
}

export default function PRDDetailPage() {
  return <PRDDetailClient />;
}
