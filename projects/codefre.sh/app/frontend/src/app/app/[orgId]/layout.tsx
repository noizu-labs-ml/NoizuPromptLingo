"use client";

import { useAuth } from "@/context/auth";
import { useRouter, usePathname } from "next/navigation";
import { useEffect, useState, use, useMemo } from "react";
import { cyAttrs } from "@/utils/cypress";
import {
  TopBar,
  Breadcrumbs,
  Button,
  OrgSwitcher,
  UserMenu,
  KeyboardCheatsheet,
} from "@/components/ui";
import { useCommandPalette } from "@/components/ui/CommandPaletteProvider";
import { MobileTopBar } from "@/components/ui/MobileTopBar";
import { useKeyboardShortcuts } from "@/hooks/useKeyboardShortcuts";
import type { BreadcrumbItem, TopBarNavItem } from "@/components/ui";

interface NavGroup {
  label: string;
  slug: string;
  /** Slugs considered "under" this tab for active highlighting */
  match: string[];
}

const NAV_GROUPS: NavGroup[] = [
  {
    label: "Library",
    slug: "prompts",
    match: ["prompts", "rubrics", "personas", "agents"],
  },
  { label: "Scripts", slug: "scripts", match: ["scripts"] },
  {
    label: "Execution",
    slug: "runs",
    match: ["runs", "review", "datasets"],
  },
  {
    label: "Observability",
    slug: "otel",
    match: ["otel", "webhooks"],
  },
];

const SLUG_TITLES: Record<string, string> = {
  prompts: "Prompts",
  rubrics: "Rubrics",
  personas: "Personas",
  scripts: "Scripts",
  agents: "Agents",
  runs: "Runs",
  review: "Review",
  datasets: "Datasets",
  otel: "OTel",
  webhooks: "Webhooks",
  settings: "Settings",
  new: "New",
  import: "Import",
};

function titleize(segment: string): string {
  if (SLUG_TITLES[segment]) return SLUG_TITLES[segment];
  if (/^[0-9a-f]{8}-/.test(segment)) return segment.slice(0, 8);
  return segment;
}

export default function OrgLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const palette = useCommandPalette();
  const [mobileNavOpen, setMobileNavOpen] = useState(false);
  const [cheatsheetOpen, setCheatsheetOpen] = useState(false);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
    }
  }, [user, authLoading, router]);

  useEffect(() => {
    setMobileNavOpen(false);
  }, [pathname]);

  const base = `/app/${orgId}`;

  const activeSlug = useMemo(() => {
    if (!pathname) return null;
    const parts = pathname.split("/").filter(Boolean);
    return parts[2] || null;
  }, [pathname]);

  const navItems: TopBarNavItem[] = useMemo(
    () =>
      NAV_GROUPS.map((g) => ({
        label: g.label,
        href: `${base}/${g.slug}`,
        active: activeSlug ? g.match.includes(activeSlug) : false,
      })),
    [base, activeSlug],
  );

  const breadcrumbs: BreadcrumbItem[] = useMemo(() => {
    const items: BreadcrumbItem[] = [{ label: "workspace", href: base }];
    if (!pathname) return items;
    const parts = pathname.split("/").filter(Boolean);
    const rest = parts.slice(2);
    let acc = base;
    rest.forEach((seg, i) => {
      acc = `${acc}/${seg}`;
      items.push({
        label: titleize(seg).toLowerCase(),
        href: i === rest.length - 1 ? undefined : acc,
        current: i === rest.length - 1,
      });
    });
    return items;
  }, [pathname, base]);

  useKeyboardShortcuts({
    "g p": () => router.push(`${base}/prompts`),
    "g r": () => router.push(`${base}/runs`),
    "g s": () => router.push(`${base}/scripts`),
    "g a": () => router.push(`${base}/agents`),
    "g e": () => router.push(`${base}/review`),
    "?": () => setCheatsheetOpen(true),
  });

  if (authLoading) {
    return (
      <div
        data-cy="app-loading"
        style={{ padding: "3rem 1rem", textAlign: "center" }}
      >
        Loading…
      </div>
    );
  }

  if (!user) return null;

  return (
    <div
      data-cy="org-shell"
      {...cyAttrs({ cyScope: "org", cyId: orgId })}
      className="sg-org-shell"
    >
      <div className="sg-shell__topbar-desktop">
        <TopBar
          logoHref={base}
          navItems={navItems}
          onOpenPalette={palette.open}
          orgSwitcher={<OrgSwitcher currentOrgId={orgId} />}
          primaryAction={
            <Button
              variant="primary"
              size="sm"
              href={`${base}/runs?new=1`}
              cy="topbar-run-cta"
            >
              + Run
            </Button>
          }
          userMenu={<UserMenu orgId={orgId} />}
        />
      </div>
      <div className="sg-shell__topbar-mobile">
        <MobileTopBar
          base={base}
          orgId={orgId}
          navOpen={mobileNavOpen}
          setNavOpen={setMobileNavOpen}
          navItems={navItems}
          onOpenPalette={palette.open}
        />
      </div>

      <div
        className="sg-breadcrumb-bar"
        style={{
          position: "sticky",
          top: "var(--topbar-height)",
          zIndex: 55,
        }}
      >
        <Breadcrumbs items={breadcrumbs} />
      </div>

      <main
        data-cy="org-main"
        className="sg-workspace sg-page-main"
        key={pathname}
        style={{
          maxWidth: "var(--container-max)",
          margin: "0 auto",
          padding: "var(--space-6) var(--space-6)",
        }}
      >
        {children}
      </main>

      <div id="context-panel-root" data-cy="context-panel-root" />

      <KeyboardCheatsheet
        open={cheatsheetOpen}
        onClose={() => setCheatsheetOpen(false)}
      />
    </div>
  );
}
