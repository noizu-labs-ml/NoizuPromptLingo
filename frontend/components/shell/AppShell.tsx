"use client";

import { useState, Fragment, useEffect } from "react";
import { Dialog, DialogPanel, Transition, TransitionChild } from "@headlessui/react";
import clsx from "clsx";
import { Sidebar } from "./Sidebar";
import { TopBar } from "./TopBar";
import { CommandPalette } from "./CommandPalette";

interface AppShellProps {
  children: React.ReactNode;
}

const SIDEBAR_WIDTH = "w-56";

export function AppShell({ children }: AppShellProps) {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [paletteOpen, setPaletteOpen] = useState(false);

  useEffect(() => {
    function handleKeyDown(e: KeyboardEvent) {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault();
        setPaletteOpen((v) => !v);
      }
    }
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  return (
    <div className="flex h-full bg-canvas text-foreground">
      {/* Skip link — visually hidden until focused */}
      <a href="#main-content" className="skip-link">
        Skip to content
      </a>
      {/* ── Desktop sidebar ─────────────────────────────────────────── */}
      <aside
        className={clsx(
          "hidden lg:flex flex-col shrink-0",
          SIDEBAR_WIDTH,
          "border-r border-border bg-surface-0"
        )}
      >
        {/* Brand in sidebar on desktop */}
        <div className="flex h-12 shrink-0 items-center gap-2 border-b border-border px-4">
          <span className="text-accent font-bold tracking-tight text-sm">NPL</span>
          <span className="text-muted font-normal text-sm">MCP</span>
          <span className="ml-auto text-[10px] font-mono text-subtle">v0</span>
        </div>
        <Sidebar />
      </aside>

      {/* ── Mobile sidebar (Headless Dialog) ────────────────────────── */}
      <Transition show={mobileOpen} as={Fragment}>
        <Dialog onClose={setMobileOpen} className="relative z-40 lg:hidden">
          {/* Backdrop */}
          <TransitionChild
            as={Fragment}
            enter="ease-out duration-200"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="ease-in duration-150"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <div className="fixed inset-0 bg-black/50 backdrop-blur-sm" aria-hidden="true" />
          </TransitionChild>

          {/* Panel */}
          <div className="fixed inset-y-0 left-0 flex">
            <TransitionChild
              as={Fragment}
              enter="ease-out duration-200"
              enterFrom="-translate-x-full"
              enterTo="translate-x-0"
              leave="ease-in duration-150"
              leaveFrom="translate-x-0"
              leaveTo="-translate-x-full"
            >
              <DialogPanel
                className={clsx(
                  "flex flex-col",
                  SIDEBAR_WIDTH,
                  "border-r border-border bg-surface-0"
                )}
              >
                <div className="flex h-12 shrink-0 items-center gap-2 border-b border-border px-4">
                  <span className="text-accent font-bold tracking-tight text-sm">NPL</span>
                  <span className="text-muted font-normal text-sm">MCP</span>
                </div>
                <Sidebar />
              </DialogPanel>
            </TransitionChild>
          </div>
        </Dialog>
      </Transition>

      {/* ── Main area ───────────────────────────────────────────────── */}
      <div className="flex flex-1 flex-col overflow-hidden">
        <div className="aurora-bg">
          <TopBar
            onMobileMenuOpen={() => setMobileOpen((v) => !v)}
            mobileMenuOpen={mobileOpen}
            onOpenPalette={() => setPaletteOpen(true)}
          />
        </div>

        <main
          id="main-content"
          className="flex-1 overflow-y-auto scrollbar-thin bg-canvas"
        >
          <div className="mx-auto max-w-6xl px-4 py-6 sm:px-6 lg:px-8">
            {children}
          </div>
        </main>
      </div>

      <CommandPalette open={paletteOpen} onClose={() => setPaletteOpen(false)} />
    </div>
  );
}
