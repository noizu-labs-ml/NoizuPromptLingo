import { ARTIFACTS } from "@/lib/api/mock/collab";
import ArtifactDetailClient from "./ArtifactDetailClient";

export function generateStaticParams() {
  return ARTIFACTS.map((artifact) => ({ id: String(artifact.id) }));
}

export default function ArtifactDetailPage() {
  return <ArtifactDetailClient />;
}
