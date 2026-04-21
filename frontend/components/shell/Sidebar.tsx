"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import clsx from "clsx";
import { Badge } from "@/components/primitives/Badge";
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
    <nav className="flex flex-col h-full overflow-y-auto scrollbar-thin px-3 py-4 gap-3">
      {NAV_GROUPS.map((group, groupIdx) => (
        <div
          key={group.heading}
          className={clsx(
            groupIdx > 0 && "border-t border-border/50 pt-3 mt-2"
          )}
        >
          <p className="px-2 mb-1.5 text-[11px] font-semibold uppercase tracking-widest text-subtle select-none">
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
                      "group flex items-center gap-2.5 rounded-md pl-2.5 pr-2 py-1.5 text-sm transition-colors focus-ring",
                      // 2px left-bar active indicator; inactive keeps transparent to avoid layout shift.
                      "border-l-2",
                      isActive
                        ? "bg-accent/10 text-accent font-medium border-accent"
                        : "border-transparent text-muted hover:bg-surface-1 hover:text-foreground"
                    )}
                    aria-current={isActive ? "page" : undefined}
                  >
                    <Icon
                      className={clsx(
                        "h-4 w-4 shrink-0 transition-opacity",
                        isActive
                          ? "text-accent opacity-100"
                          : "text-muted opacity-80 group-hover:opacity-100 group-hover:text-foreground"
                      )}
                    />
                    <span className="flex-1 truncate">{item.label}</span>
                    {item.soon && (
                      <Badge variant="default" size="sm">
                        soon
                      </Badge>
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
