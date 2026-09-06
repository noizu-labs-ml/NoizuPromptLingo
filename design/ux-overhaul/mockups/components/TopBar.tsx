"use client";

import { usePathname } from "next/navigation";
import { orgs, unreadCount, currentUser } from "@/lib/fixtures";
import { Breadcrumbs } from "@/components/Breadcrumbs";

export function TopBar({ basePath, orgSlug }: { basePath: string; orgSlug: string }) {
  const pathname = usePathname();
  const rest = pathname.startsWith(basePath) ? pathname.slice(basePath.length) : pathname;
  const segments = rest.split("/").filter(Boolean);
  return (
    <header className="topbar">
      <form action={`/${orgSlug}`} method="get">
        <label>
          Org
          <select name="org" defaultValue={orgSlug} aria-label="Org switcher">
            {orgs.map((o) => (
              <option key={o.slug} value={o.slug}>
                {o.name}
              </option>
            ))}
          </select>
        </label>
      </form>
      <Breadcrumbs segments={segments} basePath={basePath} />
      <form action="/search" method="get" role="search" style={{ flex: 1, minWidth: "160px" }}>
        <label>
          <span className="sr-only">Search (press / to focus)</span>
          <input type="search" name="q" placeholder="Search… ( / )" />
        </label>
      </form>
      <a href="/palette">[⌘K]</a>
      <a href={`${basePath}/inbox`} aria-label={`Notifications, ${unreadCount} unread`}>
        Bell ({unreadCount})
      </a>
      <details>
        <summary>{currentUser.initials}</summary>
        <ul>
          <li>{currentUser.name}</li>
          <li>{currentUser.email}</li>
          <li>
            <a href={`${basePath}/settings/accessibility`}>Accessibility prefs</a>
          </li>
          <li>
            <a href="/login">Sign out</a>
          </li>
        </ul>
      </details>
    </header>
  );
}
