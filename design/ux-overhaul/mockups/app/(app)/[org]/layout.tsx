import type { ReactNode } from "react";
import { Shell } from "@/components/Shell";
import { Rail } from "@/components/Rail";
import { TopBar } from "@/components/TopBar";
import { LiveRegion } from "@/components/LiveRegion";
import { railDestinations } from "@/lib/fixtures";

export default async function OrgLayout({
  children,
  params,
}: {
  children: ReactNode;
  params: Promise<{ org: string }>;
}) {
  const { org } = await params;
  const basePath = `/${org}`;
  return (
    <Shell>
      <Rail destinations={railDestinations} basePath={basePath} mode="org" />
      <TopBar basePath={basePath} orgSlug={org} />
      <main className="main">{children}</main>
      <LiveRegion />
    </Shell>
  );
}
