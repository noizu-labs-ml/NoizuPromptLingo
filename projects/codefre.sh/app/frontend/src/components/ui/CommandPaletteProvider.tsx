"use client";
import * as React from "react";
import { usePathname, useRouter } from "next/navigation";
import { CommandPalette, type CommandItem } from "./CommandPalette";
import { useKeyboardShortcuts } from "@/hooks/useKeyboardShortcuts";

interface CommandPaletteContextValue {
  open: () => void;
  close: () => void;
  toggle: () => void;
  isOpen: boolean;
  /** Push additional commands from downstream components. */
  registerCommands: (commands: CommandItem[]) => () => void;
}

const CommandPaletteContext = React.createContext<CommandPaletteContextValue | null>(
  null,
);

/**
 * Global command palette provider. Wraps the app, mounts `<CommandPalette>`,
 * binds `⌘K` / `Ctrl+K`, and exposes `useCommandPalette()` to trigger it.
 *
 * Downstream routes can inject route-scoped commands via `registerCommands`,
 * which returns a cleanup function.
 */
export function CommandPaletteProvider({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const [isOpen, setIsOpen] = React.useState(false);
  const [extraCommands, setExtraCommands] = React.useState<CommandItem[]>([]);

  const open = React.useCallback(() => setIsOpen(true), []);
  const close = React.useCallback(() => setIsOpen(false), []);
  const toggle = React.useCallback(() => setIsOpen((v) => !v), []);

  const registerCommands = React.useCallback((commands: CommandItem[]) => {
    setExtraCommands((prev) => [...prev, ...commands]);
    return () => {
      setExtraCommands((prev) =>
        prev.filter((c) => !commands.some((nc) => nc.id === c.id)),
      );
    };
  }, []);

  useKeyboardShortcuts({
    "cmd+k": () => toggle(),
    "ctrl+k": () => toggle(),
  });

  // Derive orgId from pathname: /app/<orgId>/…
  const orgId = React.useMemo(() => {
    if (!pathname) return null;
    const parts = pathname.split("/").filter(Boolean);
    if (parts[0] === "app" && parts[1]) return parts[1];
    return null;
  }, [pathname]);

  const coreCommands = React.useMemo<CommandItem[]>(() => {
    if (!orgId) {
      return [
        {
          id: "nav-home",
          label: "Go home",
          group: "Navigate",
          onSelect: () => router.push("/"),
        },
        {
          id: "nav-app",
          label: "Open workspace picker",
          group: "Navigate",
          onSelect: () => router.push("/app"),
        },
      ];
    }
    const base = `/app/${orgId}`;
    return [
      {
        id: "nav-dashboard",
        label: "Dashboard",
        group: "Navigate",
        onSelect: () => router.push(base),
      },
      {
        id: "nav-prompts",
        label: "Prompts",
        group: "Library",
        shortcut: "g p",
        onSelect: () => router.push(`${base}/prompts`),
      },
      {
        id: "nav-rubrics",
        label: "Rubrics",
        group: "Library",
        onSelect: () => router.push(`${base}/rubrics`),
      },
      {
        id: "nav-personas",
        label: "Personas",
        group: "Library",
        onSelect: () => router.push(`${base}/personas`),
      },
      {
        id: "nav-agents",
        label: "Agents",
        group: "Library",
        shortcut: "g a",
        onSelect: () => router.push(`${base}/agents`),
      },
      {
        id: "nav-scripts",
        label: "Scripts",
        group: "Scripts",
        shortcut: "g s",
        onSelect: () => router.push(`${base}/scripts`),
      },
      {
        id: "nav-runs",
        label: "Runs",
        group: "Execution",
        shortcut: "g r",
        onSelect: () => router.push(`${base}/runs`),
      },
      {
        id: "nav-review",
        label: "Review queue",
        group: "Execution",
        shortcut: "g e",
        onSelect: () => router.push(`${base}/review`),
      },
      {
        id: "nav-datasets",
        label: "Datasets",
        group: "Execution",
        onSelect: () => router.push(`${base}/datasets`),
      },
      {
        id: "nav-otel",
        label: "OTel telemetry",
        group: "Observability",
        onSelect: () => router.push(`${base}/otel`),
      },
      {
        id: "nav-webhooks",
        label: "Webhooks",
        group: "Observability",
        onSelect: () => router.push(`${base}/webhooks`),
      },
      {
        id: "nav-settings",
        label: "Settings",
        group: "Navigate",
        onSelect: () => router.push(`${base}/settings`),
      },
      {
        id: "action-new-script",
        label: "New Script",
        group: "Create",
        shortcut: "c",
        onSelect: () => router.push(`${base}/scripts/new`),
      },
    ];
  }, [orgId, router]);

  const items = React.useMemo(
    () => [...coreCommands, ...extraCommands],
    [coreCommands, extraCommands],
  );

  const value = React.useMemo<CommandPaletteContextValue>(
    () => ({ open, close, toggle, isOpen, registerCommands }),
    [open, close, toggle, isOpen, registerCommands],
  );

  return (
    <CommandPaletteContext.Provider value={value}>
      {children}
      <CommandPalette open={isOpen} onClose={close} items={items} />
    </CommandPaletteContext.Provider>
  );
}

export function useCommandPalette(): CommandPaletteContextValue {
  const ctx = React.useContext(CommandPaletteContext);
  if (!ctx) {
    throw new Error(
      "useCommandPalette must be used within <CommandPaletteProvider>",
    );
  }
  return ctx;
}
