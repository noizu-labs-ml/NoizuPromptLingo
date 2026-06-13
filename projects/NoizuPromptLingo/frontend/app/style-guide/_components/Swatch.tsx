"use client";

export interface SwatchProps {
  /** Semantic token name, e.g. "accent". */
  name: string;
  /** CSS variable the token maps to, e.g. "--accent". */
  token: string;
  /** Tailwind class that paints the color (e.g. "bg-accent"). */
  className: string;
  /** Optional short usage description. */
  description?: string;
}

/**
 * Single color-swatch card used by the Tokens section. Displays a color
 * tile, the token name, and the CSS variable it maps to.
 */
export function Swatch({ name, token, className, description }: SwatchProps) {
  return (
    <div className="rounded-md border border-border overflow-hidden bg-surface-0">
      <div className={`${className} h-12 w-full`} aria-hidden="true" />
      <div className="p-2 flex flex-col gap-0.5">
        <code className="text-xs font-mono text-foreground">{name}</code>
        <code className="text-[10px] font-mono text-subtle">{token}</code>
        {description && (
          <p className="text-[10px] text-subtle mt-0.5">{description}</p>
        )}
      </div>
    </div>
  );
}
