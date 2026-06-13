"use client";

import { createContext, useContext, useState } from "react";

interface SemanticSelectionCtx {
  selected: string;
  setSelected: (name: string) => void;
}

const SemanticSelectionContext = createContext<SemanticSelectionCtx>({
  selected: "",
  setSelected: () => {},
});

export function SemanticSelectionProvider({
  defaultSelected,
  children,
}: {
  defaultSelected: string;
  children: React.ReactNode;
}) {
  const [selected, setSelected] = useState(defaultSelected);
  return (
    <SemanticSelectionContext.Provider value={{ selected, setSelected }}>
      {children}
    </SemanticSelectionContext.Provider>
  );
}

export function useSemanticSelection() {
  return useContext(SemanticSelectionContext);
}
