import React, { useEffect, useState } from "react";
import { Outlet, NavLink, useNavigate } from "react-router-dom";
import { HarnessProvider, useHarness, type AgentHarness } from "../context/HarnessContext.js";
import { getHostWindow, isNativeMacHost } from "../hostBridge.js";

const navGroups = [
  {
    label: null,
    items: [
      { to: "/", label: "Explore", icon: "⊘" },
      { to: "/safety-watch", label: "Safety Watch", icon: "◇" },
    ],
  },
  {
    label: "Library",
    items: [
      { to: "/datasets", label: "Datasets", icon: "◈" },
      { to: "/prompts", label: "Prompts", icon: "✦" },
      { to: "/tags", label: "Tags", icon: "⊟" },
      { to: "/projects", label: "Projects", icon: "◉" },
    ],
  },
];

// ⟦𓀅𓉾𓉖𓈔⟧ Layout :: auto-generated pointer for public function Layout
export function Layout() {
  return (
    <HarnessProvider>
      <LayoutShell />
    </HarnessProvider>
  );
}

function LayoutShell() {
  const { harness, setHarness } = useHarness();
  const navigate = useNavigate();
  const [nativeChrome, setNativeChrome] = useState(isNativeMacHost);

  useEffect(() => {
    const host = getHostWindow();
    if (!host) return;

    const onNavigate = (event: Event) => {
      const path = (event as CustomEvent<string>).detail;
      if (typeof path === "string" && path.length > 0) {
        navigate(path);
      }
    };
    const onChrome = (event: Event) => {
      setNativeChrome(Boolean((event as CustomEvent<boolean>).detail));
    };

    host.__LLM_TOOLKIT_NAVIGATE__ = (path: string) => navigate(path);
    host.addEventListener("llm-toolkit-navigate", onNavigate);
    host.addEventListener("llm-toolkit-native-chrome", onChrome);
    return () => {
      delete host.__LLM_TOOLKIT_NAVIGATE__;
      host.removeEventListener("llm-toolkit-navigate", onNavigate);
      host.removeEventListener("llm-toolkit-native-chrome", onChrome);
    };
  }, [navigate]);

  return (
    <div className={`flex h-screen flex-col bg-void${nativeChrome ? " llm-toolkit-native-host" : ""}`}>
      {!nativeChrome && (
      <header className="flex h-14 shrink-0 items-center border-b border-border-subtle bg-canvas px-5">
        <span className="font-mono text-sm font-medium text-glow tracking-wide">agent-watch-dog</span>
        <div className="ml-6 flex h-8 items-center rounded-md border border-border-subtle bg-void p-0.5">
          {(["claude", "codex", "gemini", "other"] as AgentHarness[]).map((item) => (
            <button
              key={item}
              type="button"
              onClick={() => setHarness(item)}
              className={`h-7 px-3 text-xs font-medium capitalize transition-colors ${
                harness === item
                  ? "rounded bg-glow text-void"
                  : "text-text-muted hover:text-text-bright"
              }`}
              title={`Show ${item} sessions`}
            >
              {item}
            </button>
          ))}
        </div>
        <div className="ml-auto flex items-center gap-3">
          <div className="flex h-8 w-64 items-center rounded-md border border-border-subtle bg-void px-3">
            <span className="text-sm text-text-muted">Search conversations...</span>
          </div>
          <span className="flex items-center gap-1.5 text-xs text-text-muted">
            <span className="h-2 w-2 rounded-full bg-emerald-400" />
            Indexed
          </span>
        </div>
      </header>
      )}

      <div className="flex flex-1 overflow-hidden">
        {!nativeChrome && (
        <nav className="flex w-[220px] shrink-0 flex-col border-r border-border-subtle bg-canvas py-4">
          {navGroups.map((group, gi) => (
            <div key={group.label ?? gi}>
              {group.label && <p className="px-5 pt-4 pb-1 text-xs font-medium uppercase tracking-wider text-text-dim">{group.label}</p>}
              {group.items.map((item) => (
                <NavLink
                  key={item.to}
                  to={item.to}
                  end={item.to === "/"}
                  className={({ isActive }) =>
                    `flex items-center gap-2.5 px-5 py-2.5 text-sm transition-colors ${
                      isActive
                        ? "border-l-[3px] border-glow bg-glow-bg text-text-bright font-medium"
                        : "border-l-[3px] border-transparent text-text-primary hover:text-text-bright hover:bg-surface/60"
                    }`
                  }
                >
                  <span className="w-4 text-center text-xs">{item.icon}</span>
                  {item.label}
                </NavLink>
              ))}
            </div>
          ))}
          <div className="my-3 mx-4 border-t border-border-subtle" />
          <NavLink
            to="/settings"
            className={({ isActive }) =>
              `flex items-center gap-2.5 px-5 py-2.5 text-sm transition-colors ${
                isActive
                  ? "border-l-[3px] border-glow bg-glow-bg text-text-bright font-medium"
                  : "border-l-[3px] border-transparent text-text-primary hover:text-text-bright hover:bg-surface/60"
              }`
            }
          >
            <span className="w-4 text-center text-xs">{"⚙"}</span>
            Settings
          </NavLink>
        </nav>
        )}

        <main className="flex-1 overflow-y-auto bg-surface">
          <div className="p-8">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}
