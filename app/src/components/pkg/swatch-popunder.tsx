"use client";

import { useCallback, useState } from "react";

const COPY_ICON = (
  <svg className="sg-swatch-popunder-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5">
    <rect x="5" y="5" width="8" height="8" rx="1" />
    <path d="M3 11V3a1 1 0 011-1h8" />
  </svg>
);

const VARIANTS = [
  { prefix: "bg" },
  { prefix: "color" },
] as const;

interface Props {
  name: string;
}

export function SwatchPopunder({ name }: Props) {
  const [copiedIdx, setCopiedIdx] = useState<number | null>(null);

  const copy = useCallback((value: string, idx: number) => {
    navigator.clipboard.writeText(value).then(() => {
      setCopiedIdx(idx);
      setTimeout(() => setCopiedIdx(null), 1000);
    });
  }, []);

  return (
    <div className="sg-swatch-popunder">
      {VARIANTS.map((v, i) => (
        <div
          key={v.prefix}
          className={`sg-swatch-popunder-row${copiedIdx === i ? " copied" : ""}`}
          onClick={(e) => { e.stopPropagation(); copy(`${v.prefix}-${name}`, i); }}
        >
          {COPY_ICON}
          <span>{v.prefix}-{name}</span>
        </div>
      ))}
    </div>
  );
}
