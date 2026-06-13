import { TaskDetailClient } from "./TaskDetailClient";

// Task IDs are DB-generated integers; we don't know them at build time.
// Pre-generate a small window so the route exists under static export; SWR
// will fetch live data at runtime for any id that was pre-rendered.
export function generateStaticParams() {
  return [1, 2, 3, 4, 5].map((id) => ({ id: String(id) }));
}

export default function TaskDetailPage() {
  return <TaskDetailClient />;
}
