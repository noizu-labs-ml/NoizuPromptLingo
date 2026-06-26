'use client';

import { usePathname, useParams } from 'next/navigation';
import type { ComponentType, SVGProps } from 'react';
import {
  BuildingOffice2Icon,
  Squares2X2Icon,
  ClockIcon,
  CubeIcon,
  PhotoIcon,
  CheckBadgeIcon,
  ChatBubbleLeftRightIcon,
  TicketIcon,
  ViewColumnsIcon,
  TagIcon,
  AdjustmentsHorizontalIcon,
  BookOpenIcon,
  KeyIcon,
  DocumentTextIcon,
  BeakerIcon,
  CodeBracketIcon,
  UserCircleIcon,
  UsersIcon,
  ClipboardDocumentListIcon,
  WindowIcon,
  SparklesIcon,
  ShieldCheckIcon,
  CpuChipIcon,
  FilmIcon,
  BuildingOfficeIcon,
} from '@heroicons/react/24/outline';
import { useOrg } from '@/context/org';
import { useAuth } from '@/context/auth';
import { resolveOrg } from '@/lib/org-resolve';

export type HeroIcon = ComponentType<SVGProps<SVGSVGElement>>;

interface NavDef {
  href: string;
  Icon: HeroIcon;
  label: string;
  orgScoped?: boolean;
  /** Admin-only item, grouped under the Admin section and gated by role. */
  admin?: boolean;
}

export interface ResolvedNavItem {
  href: string;
  label: string;
  Icon: HeroIcon;
  active: boolean;
  admin?: boolean;
}

const NAV: NavDef[] = [
  { href: '/app/organizations', Icon: BuildingOffice2Icon, label: 'Organizations' },
  { href: '/members', Icon: UsersIcon, label: 'Members', orgScoped: true },
  { href: '/projects', Icon: Squares2X2Icon, label: 'Projects', orgScoped: true },
  { href: '/sessions', Icon: ClockIcon, label: 'Sessions', orgScoped: true },
  { href: '/personas', Icon: UserCircleIcon, label: 'Personas', orgScoped: true },
  { href: '/memory', Icon: SparklesIcon, label: 'Memory', orgScoped: true },
  { href: '/instructions', Icon: ClipboardDocumentListIcon, label: 'Instructions', orgScoped: true },
  { href: '/artifacts', Icon: CubeIcon, label: 'Artifacts', orgScoped: true },
  { href: '/assets', Icon: PhotoIcon, label: 'Assets', orgScoped: true },
  { href: '/browser', Icon: WindowIcon, label: 'Browser', orgScoped: true },
  { href: '/reviews', Icon: CheckBadgeIcon, label: 'Reviews', orgScoped: true },
  { href: '/chat', Icon: ChatBubbleLeftRightIcon, label: 'Chatrooms', orgScoped: true },
  { href: '/wiki', Icon: DocumentTextIcon, label: 'Wiki', orgScoped: true },
  { href: '/github', Icon: CodeBracketIcon, label: 'GitHub', orgScoped: true },
  { href: '/tickets', Icon: TicketIcon, label: 'Tickets', orgScoped: true },
  { href: '/boards', Icon: ViewColumnsIcon, label: 'Boards', orgScoped: true },
  { href: '/ticket-types', Icon: TagIcon, label: 'Ticket Types', orgScoped: true },
  { href: '/ticket-fields', Icon: AdjustmentsHorizontalIcon, label: 'Ticket Fields', orgScoped: true },
  { href: '/npl-conventions', Icon: BookOpenIcon, label: 'NPL Conventions', orgScoped: true },
  { href: '/mock-mcp', Icon: BeakerIcon, label: 'Mock MCP', orgScoped: true },

  // Admin section (role-gated): consolidated config surface.
  { href: '/app/admin', Icon: ShieldCheckIcon, label: 'Admin', admin: true },
  { href: '/app/admin/users', Icon: UsersIcon, label: 'Users', admin: true },
  { href: '/app/admin/orgs', Icon: BuildingOfficeIcon, label: 'Organizations', admin: true },
  { href: '/app/admin/github', Icon: CodeBracketIcon, label: 'GitHub Config', admin: true },
  { href: '/app/admin/llm-models', Icon: CpuChipIcon, label: 'LLM Catalog', admin: true },
  { href: '/app/admin/media-providers', Icon: FilmIcon, label: 'Media Providers', admin: true },
  { href: '/app/admin/authz', Icon: KeyIcon, label: 'API Keys', admin: true },
];

export function useAppNav(): ResolvedNavItem[] {
  const pathname = usePathname();
  const params = useParams();
  const { currentOrg, organizations } = useOrg();
  const { user } = useAuth();
  const isAdmin = user?.role === 'admin' || user?.role === 'owner';

  // Only trust the route's org segment if it resolves to a known org (by slug or,
  // defensively, by id). A stray/unknown param must never propagate into every
  // nav link — fall back to the already-active org's slug so the sidebar can't be
  // left pointing at a non-org segment.
  const routeOrg = resolveOrg(organizations, params?.orgId as string | undefined);
  const orgSlug = routeOrg?.slug ?? currentOrg?.slug;
  const orgBase = orgSlug ? `/app/${orgSlug}` : '/app';

  return NAV.filter((item) => !item.admin || isAdmin).map((item) => {
    const href = item.orgScoped ? `${orgBase}${item.href}` : item.href;
    // The admin landing page would match every /app/admin/* path via startsWith,
    // so only mark it active on an exact match.
    const active = item.href === '/app/admin' ? pathname === href : pathname === href || pathname.startsWith(`${href}/`);
    return { href, label: item.label, Icon: item.Icon, active, admin: item.admin };
  });
}
