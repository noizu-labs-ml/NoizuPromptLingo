import { PROJECTS } from "@/lib/api/mock/projects";
import { ProjectDetailClient } from "./ProjectDetailClient";

export function generateStaticParams() {
  return PROJECTS.map((p) => ({ id: p.id }));
}

export default function ProjectDetailPage() {
  return <ProjectDetailClient />;
}
