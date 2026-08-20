"use client";

import clsx from "clsx";
import { ReactNode } from "react";

export interface PreviewProps {
  /** Short descriptor rendered above the demo area (e.g. "primary"). */
  label: string;
  /** Optional code snippet rendered below the demo. */
  code?: string;
  /** Outer card className override. */
  className?: string;
  /** The rendered component(s). */
  children: ReactNode;
}

/**
 * Shared wrapper for style-guide demos. Renders a bordered card with a
 * small uppercase label, the demo on a surface-1 background, and an
 * optional code snippet underneath.
 */
export function Preview({ label, code, className, children }: PreviewProps) {
  return (
    <div
      className={clsx(
        "rounded-lg border border-border bg-surface-0 p-3 flex flex-col gap-3",
        className,
      )}
    >
      <div className="text-label uppercase text-subtle">{label}</div>
      <div className="bg-surface-1 p-6 rounded-md flex items-center justify-center flex-wrap gap-3 min-h-[4rem]">
        {children}
      </div>
      {code && (
        <pre className="text-[11px] font-mono text-muted whitespace-pre-wrap break-words mt-1">
          {code}
        </pre>
      )}
    </div>
  );
}
