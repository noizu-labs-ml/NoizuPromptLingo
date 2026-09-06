"use client";

import { usePathname } from "next/navigation";

type Destination = { id: string; label: string; href: string };

export function Rail({
  destinations,
  basePath,
  mode = "org",
}: {
  destinations: Destination[];
  basePath: string;
  mode?: "org" | "admin";
}) {
  const pathname = usePathname();
  const activeId =
    destinations.find((d) => {
      const href = mode === "admin" ? d.href : `${basePath}/${d.href}`.replace(/\/$/, "") || basePath;
      return pathname === href || pathname.startsWith(`${href}/`);
    })?.id ?? destinations[0]?.id;
  return (
    <nav className="rail" aria-label={mode === "admin" ? "Admin navigation" : "Primary navigation"}>
      <p className="chip">rail: {mode}</p>
      <ul>
        {destinations.map((d) => {
          const href = mode === "admin" ? d.href : `${basePath}/${d.href}`.replace(/\/$/, "") || basePath;
          const current = d.id === activeId;
          return (
            <li key={d.id}>
              <a href={href} aria-current={current ? "page" : undefined}>
                {d.label}
              </a>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
