import React from "react";
import { Box, Text } from "ink";
import { useInput } from "ink";
import { useRouter, type PageName } from "../context/RouterContext.js";

interface NavItem {
  page: PageName;
  label: string;
  icon: string;
}

interface NavGroup {
  label: string | null;
  items: NavItem[];
}

const navGroups: NavGroup[] = [
  {
    label: null,
    items: [
      { page: "explore", label: "Explore", icon: "⊘" },
    ],
  },
  {
    label: "Library",
    items: [
      { page: "datasets", label: "Datasets", icon: "◈" },
      { page: "prompts", label: "Prompts", icon: "✦" },
      { page: "tags", label: "Tags", icon: "⊟" },
      { page: "projects", label: "Projects", icon: "◉" },
    ],
  },
];

const settingsItem: NavItem = { page: "settings", label: "Settings", icon: "⚙" };

function getAllItems(): NavItem[] {
  const items: NavItem[] = [];
  for (const group of navGroups) {
    items.push(...group.items);
  }
  items.push(settingsItem);
  return items;
}

interface SidebarProps {
  isActive: boolean;
  selectedIndex: number;
  onSelectedIndexChange: (idx: number) => void;
}

export function Sidebar({ isActive, selectedIndex, onSelectedIndexChange }: SidebarProps) {
  const { current, navigate } = useRouter();
  const allItems = getAllItems();

  useInput((input, key) => {
    if (key.upArrow || input === "k") {
      onSelectedIndexChange(Math.max(0, selectedIndex - 1));
    } else if (key.downArrow || input === "j") {
      onSelectedIndexChange(Math.min(allItems.length - 1, selectedIndex + 1));
    } else if (key.return) {
      const item = allItems[selectedIndex];
      if (item) navigate(item.page);
    }
  }, { isActive });

  let itemIndex = 0;

  return (
    <Box flexDirection="column" width={20} borderStyle="single" borderRight borderColor={isActive ? "cyan" : "gray"} paddingY={1}>
      {navGroups.map((group, gi) => (
        <Box key={gi} flexDirection="column">
          {group.label && (
            <Text dimColor bold>
              {"  "}{group.label.toUpperCase()}
            </Text>
          )}
          {group.items.map((item) => {
            const idx = itemIndex++;
            const isSelected = isActive && selectedIndex === idx;
            const isCurrentPage = current.page === item.page;
            return (
              <Box key={item.page} paddingX={1}>
                <Text
                  color={isSelected ? "cyan" : isCurrentPage ? "cyan" : undefined}
                  bold={isSelected || isCurrentPage}
                  inverse={isSelected}
                  dimColor={!isSelected && !isCurrentPage}
                >
                  {isCurrentPage && !isSelected ? "│" : " "} {item.icon} {item.label}
                </Text>
              </Box>
            );
          })}
        </Box>
      ))}
      <Box paddingX={1} marginTop={1} borderStyle="single" borderTop borderBottom={false} borderLeft={false} borderRight={false} borderColor="gray">
        {(() => {
          const idx = itemIndex;
          const isSelected = isActive && selectedIndex === idx;
          const isCurrentPage = current.page === settingsItem.page;
          return (
            <Text
              color={isSelected ? "cyan" : isCurrentPage ? "cyan" : undefined}
              bold={isSelected || isCurrentPage}
              inverse={isSelected}
              dimColor={!isSelected && !isCurrentPage}
            >
              {isCurrentPage && !isSelected ? "│" : " "} {settingsItem.icon} {settingsItem.label}
            </Text>
          );
        })()}
      </Box>
    </Box>
  );
}

export function getSidebarItemCount(): number {
  return getAllItems().length;
}
