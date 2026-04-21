"use client";

import clsx from "clsx";
import { ReactNode } from "react";
import {
  Tab,
  TabGroup,
  TabList,
  TabPanel,
  TabPanels,
} from "@headlessui/react";

export interface TabItem {
  id: string;
  label: ReactNode;
  /** Rendered before the label. */
  icon?: ReactNode;
  /** Count badge rendered after the label. */
  badge?: ReactNode;
}

export interface TabBarProps {
  tabs: TabItem[];
  /** Controlled selected tab id. */
  value?: string;
  onChange?: (id: string) => void;
  /** Initial index when uncontrolled. */
  defaultIndex?: number;
  /**
   * Panels — should be `<TabPanel>` elements from `@headlessui/react` in
   * the same order as `tabs`.
   */
  children: ReactNode;
  className?: string;
}

const selectedClass =
  "rounded px-3 py-1.5 text-xs font-medium bg-accent text-accent-on shadow-ambient focus-ring inline-flex items-center gap-1.5";

const unselectedClass =
  "rounded px-3 py-1.5 text-xs font-medium text-muted hover:text-foreground hover:bg-surface-1 transition-colors focus-ring inline-flex items-center gap-1.5";

/**
 * TabBar is a visual wrapper around Headless UI `TabGroup` that matches
 * the NPL Studio style. Consumers render their own `<TabPanel>` children
 * in the same order as `tabs`.
 *
 * @example
 * ```tsx
 * <TabBar tabs={[{ id: "a", label: "Alpha" }, { id: "b", label: "Beta" }]}>
 *   <TabPanel>Panel A</TabPanel>
 *   <TabPanel>Panel B</TabPanel>
 * </TabBar>
 * ```
 */
export function TabBar({
  tabs,
  value,
  onChange,
  defaultIndex,
  children,
  className,
}: TabBarProps) {
  const controlled = value !== undefined;
  const selectedIndex = controlled
    ? Math.max(
        0,
        tabs.findIndex((t) => t.id === value),
      )
    : undefined;

  const handleChange = (index: number) => {
    const next = tabs[index];
    if (next && onChange) onChange(next.id);
  };

  return (
    <TabGroup
      selectedIndex={selectedIndex}
      defaultIndex={controlled ? undefined : defaultIndex}
      onChange={handleChange}
      className={className}
    >
      <TabList className="flex items-center gap-1 rounded-md border border-border bg-surface-0 p-0.5 w-fit">
        {tabs.map((tab) => (
          <Tab
            key={tab.id}
            className={({ selected }) =>
              clsx(selected ? selectedClass : unselectedClass)
            }
          >
            {tab.icon}
            <span>{tab.label}</span>
            {tab.badge !== undefined && tab.badge !== null && (
              <span className="ml-1 text-[10px] text-subtle">{tab.badge}</span>
            )}
          </Tab>
        ))}
      </TabList>
      <TabPanels className="mt-4">{children}</TabPanels>
    </TabGroup>
  );
}

export { TabPanel };
