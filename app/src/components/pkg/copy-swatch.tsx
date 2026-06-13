"use client";

import { useCallback, useState } from "react";

interface CopySwatchProps {
  value: string;
  children: React.ReactNode;
  className?: string;
}

export function CopySwatch({ value, children, className }: CopySwatchProps) {
  const [copied, setCopied] = useState(false);

  const handleClick = useCallback(() => {
    navigator.clipboard.writeText(value).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 1200);
    });
  }, [value]);

  return (
    <div onClick={handleClick} className={`sg-palette-swatch-copy ${className || ""}`}>
      {children}
      {copied && <div className="sg-palette-swatch-copied">Copied</div>}
    </div>
  );
}
