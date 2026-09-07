'use client';

import { useCallback, useEffect, useRef, useState, type CSSProperties, type ReactNode } from 'react';
import { copyTextToClipboard } from '@/lib/clipboard';

/**
 * Shared copied-flash state for the clipboard kit. `copy(text, id)` writes
 * the text and flashes `copied === id` for `resetMs`; consumers key flash
 * state per control by passing distinct ids.
 */
export function useCopied(resetMs = 2000) {
  const [copied, setCopied] = useState<string | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    return () => {
      if (timer.current) clearTimeout(timer.current);
    };
  }, []);

  const copy = useCallback(
    async (text: string, id = 'default') => {
      const ok = await copyTextToClipboard(text);
      if (!ok) return false;
      setCopied(id);
      if (timer.current) clearTimeout(timer.current);
      timer.current = setTimeout(() => setCopied(null), resetMs);
      return true;
    },
    [resetMs],
  );

  return { copied, copy };
}

export interface ClipboardButtonProps {
  /** Text placed on the clipboard. */
  text: string;
  /** Button text while idle (default "Copy"). */
  label?: string;
  /** Button text after a successful copy (default "Copied!"). */
  copiedLabel?: string;
  /** Accessible name; defaults to the idle label. Pass a specific one when
   * several copy buttons share a page. */
  ariaLabel?: string;
  className?: string;
  style?: CSSProperties;
  /** Extra style applied while showing the copied state (e.g. green flash). */
  copiedStyle?: CSSProperties;
}

/** Self-contained copy button with a copied-flash label. */
export function ClipboardButton({
  text,
  label = 'Copy',
  copiedLabel = 'Copied!',
  ariaLabel,
  className,
  style,
  copiedStyle,
}: ClipboardButtonProps) {
  const { copied, copy } = useCopied();
  const isCopied = copied === 'default';
  return (
    <button
      type="button"
      className={className}
      style={isCopied ? { ...style, ...copiedStyle } : style}
      aria-label={ariaLabel ?? label}
      onClick={() => void copy(text)}
    >
      {isCopied ? copiedLabel : label}
    </button>
  );
}

export interface CopyFieldProps {
  /** Label rendered on the reveal's label row (e.g. "MCP server URL"). */
  label: ReactNode;
  /** Value shown in the mono code row and placed on the clipboard. */
  value: string;
  /** Extra muted hint after the label (e.g. "handle <slug>"). */
  hint?: ReactNode;
  /** Accessible name for the copy button; defaults to `Copy <label>` when
   * label is a string. */
  copyLabel?: string;
  /** Preserve newlines in the code row (multi-line snippets). */
  preWrap?: boolean;
}

/**
 * Labeled reveal row: label + mono value + copy button. Mirrors the
 * `authz-reveal` markup used across the authz/MCP pages.
 */
export function CopyField({ label, value, hint, copyLabel, preWrap }: CopyFieldProps) {
  const { copied, copy } = useCopied();
  const name = typeof label === 'string' ? label : 'value';
  return (
    <div className="authz-reveal">
      <div className="authz-reveal__label">
        {label}
        {hint ? <span style={{ marginLeft: 8, fontWeight: 400 }}>{hint}</span> : null}
      </div>
      <div className="authz-reveal__row">
        <code
          className="authz-reveal__key font-mono"
          style={preWrap ? { whiteSpace: 'pre-wrap' } : undefined}
        >
          {value}
        </code>
        <button
          type="button"
          className="sg-btn sg-btn--outline sg-btn--sm"
          aria-label={copyLabel ?? `Copy ${name}`}
          onClick={() => void copy(value)}
        >
          {copied ? 'Copied!' : 'Copy'}
        </button>
      </div>
    </div>
  );
}
