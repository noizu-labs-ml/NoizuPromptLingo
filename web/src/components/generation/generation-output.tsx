"use client";

import * as React from "react";
import { Check, Pencil, Trash2 } from "lucide-react";
import { cn } from "@/lib/cn";
import { Button } from "@/components/ui/button";

interface GenerationOutputProps {
  title: string;
  body: string;
  onPromoteToCanon?: () => void;
  onEdit?: () => void;
  onDiscard?: () => void;
  isPromoted?: boolean;
}

/**
 * Typewriter reveal: we split the body into words and reveal them one-by-one
 * via a CSS animation that uncovers the text incrementally.
 * When promoted, the dashed sepia border solidifies to ink-black and the
 * text color transitions from text-generated to text-ink.
 */
export function GenerationOutput({
  title,
  body,
  onPromoteToCanon,
  onEdit,
  onDiscard,
  isPromoted = false,
}: GenerationOutputProps) {
  const [revealed, setRevealed] = React.useState(0);
  const [animating, setAnimating] = React.useState(true);

  const words = React.useMemo(() => body.split(/(\s+)/), [body]);

  // Reveal words on mount / body change
  React.useEffect(() => {
    setRevealed(0);
    setAnimating(true);

    const wordTokens = words.filter((w) => w.trim().length > 0);
    let i = 0;

    const interval = setInterval(() => {
      i++;
      setRevealed(i);
      if (i >= wordTokens.length) {
        clearInterval(interval);
        setAnimating(false);
      }
    }, 28); // ~28ms per word

    return () => clearInterval(interval);
  }, [body, words]);

  // Count revealed "real" (non-whitespace) words
  let wordCount = 0;
  const renderedParts = words.map((token, idx) => {
    const isWord = token.trim().length > 0;
    if (isWord) wordCount++;
    const visible = wordCount <= revealed;
    return (
      <span
        key={idx}
        style={{
          opacity: visible ? 1 : 0,
          transition: visible ? "opacity 80ms ease" : "none",
        }}
      >
        {token}
      </span>
    );
  });

  return (
    <div
      className={cn(
        "rounded-md border bg-surface overflow-hidden",
        "transition-all duration-300 ease-in-out",
        isPromoted
          ? "border-l-[3px] border-l-canon border-rule"
          : "border-l-[3px] border-rule"
      )}
      style={
        !isPromoted
          ? {
              borderLeftWidth: "3px",
              borderLeftStyle: "dashed",
              borderLeftColor: "#8B7355",
            }
          : undefined
      }
    >
      {/* Header */}
      <div className="px-4 pt-4 pb-3 border-b border-rule-subtle">
        <div className="flex items-start justify-between gap-3">
          <div>
            {isPromoted ? (
              <span className="inline-flex items-center gap-1 font-mono text-[10px] uppercase tracking-[0.06em] text-success mb-1">
                <Check size={11} strokeWidth={2} />
                Promoted to canon
              </span>
            ) : (
              <span className="font-mono text-[10px] uppercase tracking-[0.06em] text-generated mb-1 block">
                Generated
              </span>
            )}
            <h3
              className={cn(
                "font-serif text-lg font-semibold leading-snug transition-colors duration-300",
                isPromoted ? "text-ink" : "text-generated"
              )}
            >
              {title}
            </h3>
          </div>
          {animating && (
            <span className="font-mono text-[11px] text-ink-tertiary shrink-0 mt-1 animate-pulse">
              Writing…
            </span>
          )}
        </div>
      </div>

      {/* Body */}
      <div className="px-4 py-4">
        <p
          className={cn(
            "font-body text-[15px] leading-[1.7] transition-colors duration-300",
            isPromoted ? "text-ink" : "text-generated"
          )}
        >
          {renderedParts}
        </p>
      </div>

      {/* Actions */}
      {!isPromoted && (
        <div className="px-4 pb-4 flex items-center gap-2">
          <Button
            variant="primary"
            size="sm"
            onClick={onPromoteToCanon}
            className="gap-1.5"
          >
            <span className="text-[11px]">■</span>
            Promote to Canon
          </Button>
          <Button
            variant="secondary"
            size="sm"
            onClick={onEdit}
            className="gap-1.5"
          >
            <Pencil size={12} strokeWidth={1.5} />
            Edit
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={onDiscard}
            className="gap-1.5 text-flag-error hover:text-flag-error"
          >
            <Trash2 size={12} strokeWidth={1.5} />
            Discard
          </Button>
        </div>
      )}
    </div>
  );
}
