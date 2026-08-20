import { STORIES } from "@/lib/api/mock/projects";
import { StoryDetailClient } from "./StoryDetailClient";

export function generateStaticParams() {
  return STORIES.map((s) => ({ id: s.id }));
}

export default function StoryDetailPage() {
  return <StoryDetailClient />;
}
