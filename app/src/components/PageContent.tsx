"use client";

import { useEffect } from "react";
import { SemanticSelectionProvider } from "./SemanticSelectionContext";
import { readLayout } from "@styleguide-engine/lib/section-cookie";

interface Props {
  defaultSelected: string;
  children: React.ReactNode;
}

export function PageContent({ defaultSelected, children }: Props) {
  useEffect(() => {
    const stored = readLayout();
    if (!stored) return;
    const el = document.querySelector(".content");
    if (el && !el.classList.contains(stored)) {
      el.classList.add(stored);
    }
  }, []);

  return (
    <SemanticSelectionProvider defaultSelected={defaultSelected}>
      {children}
    </SemanticSelectionProvider>
  );
}
