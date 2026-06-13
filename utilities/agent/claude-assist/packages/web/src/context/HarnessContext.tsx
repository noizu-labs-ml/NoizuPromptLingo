import React, { createContext, useContext, useEffect, useState } from "react";

export type AgentHarness = "claude" | "codex" | "gemini" | "other";

interface HarnessContextValue {
  harness: AgentHarness;
  setHarness: (harness: AgentHarness) => void;
}

const HarnessContext = createContext<HarnessContextValue | null>(null);

export function HarnessProvider({ children }: { children: React.ReactNode }) {
  const [harness, setHarnessState] = useState<AgentHarness>(() => {
    const stored = readStoredHarness();
    return isAgentHarness(stored) ? stored : "claude";
  });

  const setHarness = (next: AgentHarness) => {
    setHarnessState(next);
    writeStoredHarness(next);
  };

  useEffect(() => {
    writeStoredHarness(harness);
  }, [harness]);

  return (
    <HarnessContext.Provider value={{ harness, setHarness }}>
      {children}
    </HarnessContext.Provider>
  );
}

export function useHarness(): HarnessContextValue {
  const context = useContext(HarnessContext);
  return context ?? { harness: "claude", setHarness: () => {} };
}

function isAgentHarness(value: string | null): value is AgentHarness {
  return value === "claude" || value === "codex" || value === "gemini" || value === "other";
}

function readStoredHarness(): string | null {
  if (typeof window === "undefined") return null;
  const storage = window.localStorage;
  if (!storage || typeof storage.getItem !== "function") return null;
  return storage.getItem("agent-watchdog:harness");
}

function writeStoredHarness(harness: AgentHarness): void {
  if (typeof window === "undefined") return;
  const storage = window.localStorage;
  if (!storage || typeof storage.setItem !== "function") return;
  storage.setItem("agent-watchdog:harness", harness);
}
