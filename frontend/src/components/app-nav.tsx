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
} from '@heroicons/react/24/outline';
import { useOrg } from '@/context/org';

export type HeroIcon = ComponentType<SVGProps<SVGSVGElement>>;

interface NavDef {
  href: string;
  Icon: HeroIcon;
  label: string;
  orgScoped?: boolean;
}

export interface ResolvedNavItem {
  href: string;
  label: string;
  Icon: HeroIcon;
  active: boolean;
}

const NAV: NavDef[] = [
  { href: '/app/organizations', Icon: BuildingOffice2Icon, label: 'Organizations' },
  { href: '/projects', Icon: Squares2X2Icon, label: 'Projects', orgScoped: true },
  { href: '/sessions', Icon: ClockIcon, label: 'Sessions', orgScoped: true },
  { href: '/artifacts', Icon: CubeIcon, label: 'Artifacts', orgScoped: true },
  { href: '/assets', Icon: PhotoIcon, label: 'Assets', orgScoped: true },
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
  { href: '/app/admin/authz', Icon: KeyIcon, label: 'Authz' },
];

export function useAppNav(): ResolvedNavItem[] {
  const pathname = usePathname();
  const params = useParams();
  const { currentOrg } = useOrg();

  const orgId = (params?.orgId as string | undefined) || currentOrg?.slug;
  const orgBase = orgId ? `/app/${orgId}` : '/app';

  return NAV.map((item) => {
    const href = item.orgScoped ? `${orgBase}${item.href}` : item.href;
    const active = pathname === href || pathname.startsWith(`${href}/`);
    return { href, label: item.label, Icon: item.Icon, active };
  });
}
