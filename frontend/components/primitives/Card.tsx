"use client";

import clsx from "clsx";
import { ReactNode } from "react";

export interface CardProps {
  children: ReactNode;
  className?: string;
  padded?: boolean;
  hoverable?: boolean;
}

export function Card({
  children,
  className,
  padded = true,
  hoverable = false,
}: CardProps) {
  return (
    <div
      className={clsx(
        "bg-surface-raised border border-border rounded-lg",
        padded && "p-4",
        hoverable && "hover:border-border-strong transition-colors cursor-pointer",
        className
      )}
    >
      {children}
    </div>
  );
}
