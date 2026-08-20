import { SESSIONS } from "@/lib/api/mock/sessions";
import SessionDetailClient from "./SessionDetailClient";

export function generateStaticParams() {
  return SESSIONS.map((s) => ({ uuid: s.uuid }));
}

export default function SessionDetailPage() {
  return <SessionDetailClient />;
}
