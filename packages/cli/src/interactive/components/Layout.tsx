import React, { useState } from "react";
import { Box, useInput, useApp } from "ink";
import { Header } from "./Header.js";
import { Sidebar, getSidebarItemCount } from "./Sidebar.js";
import { StatusLine } from "./StatusLine.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";

type FocusZone = "sidebar" | "content";

interface LayoutProps {
  children: React.ReactNode;
  statusHints?: string;
  statusInfo?: string;
}

export function Layout({ children, statusHints, statusInfo }: LayoutProps) {
  const [focusZone, setFocusZone] = useState<FocusZone>("content");
  const [sidebarIndex, setSidebarIndex] = useState(0);
  const { rows } = useTerminalSize();
  const { exit } = useApp();

  useInput((input, key) => {
    if (key.tab) {
      setFocusZone((z) => z === "sidebar" ? "content" : "sidebar");
    }
    if (input === "q" && focusZone !== "content") {
      exit();
    }
  });

  const contentHeight = Math.max(1, rows - 3);

  return (
    <Box flexDirection="column" height={rows}>
      <Header />
      <Box height={contentHeight}>
        <Sidebar
          isActive={focusZone === "sidebar"}
          selectedIndex={sidebarIndex}
          onSelectedIndexChange={setSidebarIndex}
        />
        <Box flexDirection="column" flexGrow={1} paddingX={1} overflow="hidden">
          {children}
        </Box>
      </Box>
      <StatusLine hints={statusHints} info={statusInfo} />
    </Box>
  );
}

export { type FocusZone };
