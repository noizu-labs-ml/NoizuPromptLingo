import type { ReactNode } from "react";

export function PageHeader({
  title,
  primaryActionLabel,
  overflowItems,
  children,
}: {
  title: string;
  primaryActionLabel?: string;
  overflowItems?: string[];
  children?: ReactNode;
}) {
  return (
    <header>
      <div className="row" style={{ justifyContent: "space-between" }}>
        <h1>{title}</h1>
        <div className="row">
          {primaryActionLabel && <button type="button">{primaryActionLabel}</button>}
          {overflowItems && overflowItems.length > 0 && (
            <details>
              <summary>More</summary>
              <ul>
                {overflowItems.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            </details>
          )}
        </div>
      </div>
      {children}
    </header>
  );
}
