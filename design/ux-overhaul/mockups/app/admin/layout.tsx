import type { ReactNode } from "react";
import { Shell } from "@/components/Shell";
import { Rail } from "@/components/Rail";
import { adminRailDestinations, currentUser } from "@/lib/fixtures";

export default function AdminLayout({ children }: { children: ReactNode }) {
  return (
    <Shell>
      <Rail destinations={adminRailDestinations} basePath="/admin" mode="admin" />
      <header className="topbar">
        <p className="chip">Admin mode</p>
        <nav aria-label="Breadcrumb">
          <a href="/">Home</a> / <span>Admin</span>
        </nav>
        <div style={{ flex: 1 }} />
        <span>{currentUser.name}</span>
      </header>
      <main className="main">{children}</main>
    </Shell>
  );
}
