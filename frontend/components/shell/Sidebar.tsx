"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import clsx from "clsx";
import {
  HomeIcon,
  WrenchScrewdriverIcon,
  BeakerIcon,
  ClockIcon,
  BookOpenIcon,
  BuildingOffice2Icon,
  DocumentArrowDownIcon,
  DocumentTextIcon,
  FolderIcon,
  FolderOpenIcon,
  ChatBubbleLeftRightIcon,
  DocumentIcon,
  CpuChipIcon,
  ChartBarIcon,
  Squares2X2Icon,
  ShieldCheckIcon,
  UserGroupIcon,
  HeartIcon,
  QueueListIcon,
} from "@heroicons/react/24/outline";

interface NavItem {
  label: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  soon?: boolean;
}

interface NavGroup {
  heading: string;
  items: NavItem[];
}

const NAV_GROUPS: NavGroup[] = [
  {
    heading: "Overview",
    items: [
      { label: "Home", href: "/", icon: HomeIcon },
    ],
  },
  {
    heading: "Catalog",
    items: [
      { label: "Tools", href: "/tools", icon: WrenchScrewdriverIcon },
      { label: "NPL", href: "/npl", icon: BeakerIcon },
      { label: "Markdown", href: "/markdown", icon: DocumentArrowDownIcon },
    ],
  },
  {
    heading: "Skills",
    items: [
      { label: "Validator", href: "/skills/validate", icon: ShieldCheckIcon },
    ],
  },
  {
    heading: "Work",
    items: [
      { label: "Sessions", href: "/sessions", icon: ClockIcon },
      { label: "Tasks", href: "/tasks", icon: QueueListIcon },
      { label: "Instructions", href: "/instructions", icon: BookOpenIcon },
      { label: "Projects", href: "/projects", icon: FolderIcon },
      { label: "PRDs", href: "/prds", icon: DocumentTextIcon },
    ],
  },
  {
    heading: "Repo",
    items: [
      { label: "Explorer", href: "/explorer", icon: FolderOpenIcon },
    ],
  },
  {
    heading: "Docs",
    items: [
      { label: "Schema", href: "/docs/schema", icon: BookOpenIcon },
      { label: "Architecture", href: "/docs/arch", icon: BuildingOffice2Icon },
      { label: "Layout", href: "/docs/layout", icon: Squares2X2Icon },
    ],
  },
  {
    heading: "Collab",
    items: [
      { label: "Agents", href: "/agents", icon: UserGroupIcon },
      { label: "Chat", href: "/chat", icon: ChatBubbleLeftRightIcon, soon: true },
      { label: "Artifacts", href: "/artifacts", icon: DocumentIcon, soon: true },
    ],
  },
  {
    heading: "Ops",
    items: [
      { label: "Health", href: "/health", icon: HeartIcon },
      { label: "Orchestration", href: "/orchestration", icon: CpuChipIcon, soon: true },
      { label: "Metrics", href: "/metrics", icon: ChartBarIcon, soon: true },
    ],
  },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <nav className="flex flex-col h-full overflow-y-auto scrollbar-thin px-3 py-4 gap-6">
      {NAV_GROUPS.map((group) => (
        <div key={group.heading}>
          <p className="px-2 mb-1 text-[10px] font-semibold uppercase tracking-widest text-subtle select-none">
            {group.heading}
          </p>
          <ul className="space-y-0.5">
            {group.items.map((item) => {
              const Icon = item.icon;
              const isActive =
                item.href === "/"
                  ? pathname === "/"
                  : pathname === item.href || pathname.startsWith(item.href + "/");

              return (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    className={clsx(
                      "group flex items-center gap-2.5 rounded-md px-2 py-1.5 text-sm transition-colors",
                      isActive
                        ? "bg-accent/10 text-accent font-medium"
                        : "text-muted hover:bg-surface-raised hover:text-foreground"
                    )}
                  >
                    <Icon
                      className={clsx(
                        "h-4 w-4 shrink-0",
                        isActive ? "text-accent" : "text-subtle group-hover:text-foreground"
                      )}
                    />
                    <span className="flex-1 truncate">{item.label}</span>
                    {item.soon && (
                      <span className="shrink-0 rounded px-1 py-0.5 text-[9px] font-semibold uppercase tracking-wide bg-surface-raised text-subtle border border-border">
                        soon
                      </span>
                    )}
                  </Link>
                </li>
              );
            })}
          </ul>
        </div>
      ))}
    </nav>
  );
}
