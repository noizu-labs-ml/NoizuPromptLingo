import React, { createContext, useContext, useMemo, useState } from "react";

export type AgentHarness = "claude" | "codex" | "gemini" | "other";

export const HARNESS_OPTIONS: AgentHarness[] = ["claude", "codex", "gemini", "other"];

interface HarnessContextValue {
  harness: AgentHarness;
  setHarness: (harness: AgentHarness) => void;
}

const Context = createContext<HarnessContextValue | null>(null);

// ⟦𓏒𓁑𓅼𓁃⟧ HarnessProvider :: auto-generated pointer for public function HarnessProvider
export function HarnessProvider({ children }: { children: React.ReactNode }) {
  const [harness, setHarness] = useState<AgentHarness>("claude");
  const value = useMemo(() => ({ harness, setHarness }), [harness]);

  return <Context.Provider value={value}>{children}</Context.Provider>;
}

// ⟦𓀜𓀙𓅵𓁋⟧ useHarness :: auto-generated pointer for public function useHarness
export function useHarness(): HarnessContextValue {
  const context = useContext(Context);
  if (!context) return { harness: "claude", setHarness: () => {} };
  return context;
}
