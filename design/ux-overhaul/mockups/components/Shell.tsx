import type { ReactNode } from "react";

export function Shell({ children, withInspector = false }: { children: ReactNode; withInspector?: boolean }) {
  return <div className={`shell${withInspector ? " with-inspector" : ""}`}>{children}</div>;
}
