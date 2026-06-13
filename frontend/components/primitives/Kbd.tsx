import clsx from "clsx";
import { ReactNode } from "react";

export interface KbdProps {
  children: ReactNode;
  className?: string;
}

/**
 * Keyboard shortcut glyph, styled as a tactile chip.
 *
 *   <Kbd>⌘</Kbd><Kbd>K</Kbd>
 *   <Kbd>⌘K</Kbd>
 */
export function Kbd({ children, className }: KbdProps) {
  return (
    <kbd
      className={clsx(
        "inline-flex items-center gap-0.5 font-mono text-[11px] leading-none",
        "px-1.5 py-0.5 rounded-sm border border-border-strong bg-surface-1 text-muted shadow-ambient",
        className
      )}
    >
      {children}
    </kbd>
  );
}
