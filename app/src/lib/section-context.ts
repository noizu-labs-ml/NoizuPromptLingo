"use client";

import { createContext, useContext } from "react";

const SectionIdContext = createContext<string | null>(null);

export const SectionIdProvider = SectionIdContext.Provider;

export function useSectionId(): string | null {
  return useContext(SectionIdContext);
}
