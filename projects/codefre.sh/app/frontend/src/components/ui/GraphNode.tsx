"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";
import type { EvalState } from "./Button";

export interface GraphNodeProps {
  title?: React.ReactNode;
  subtitle?: React.ReactNode;
  state?: EvalState | "default" | "selected";
  active?: boolean;
  children?: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
  onClick?: () => void;
  cy?: string;
  cyId?: string | number;
}

/**
 * Forge graph node — the design atom. 6px radius, 1.5px border, 20px padding.
 * Eval-state variants drive color + border treatment.
 *
 * @example
 * <GraphNode title="ask-audience" state="pass" />
 * <GraphNode title="deviation" state="freeball" active />
 */
export function GraphNode({
  title,
  subtitle,
  state = "default",
  active,
  children,
  className,
  style,
  onClick,
  cy = "graph-node",
  cyId,
}: GraphNodeProps) {
  const classes = [
    "sg-graph-node",
    state === "selected" ? "sg-graph-node--selected" : "",
    ["pass", "warn", "fail", "freeball"].includes(state)
      ? `eval-${state}`
      : "",
    className || "",
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <div
      className={classes}
      style={style}
      role={onClick ? "button" : undefined}
      tabIndex={onClick ? 0 : undefined}
      onClick={onClick}
      onKeyDown={
        onClick
          ? (e) => {
              if (e.key === "Enter" || e.key === " ") {
                e.preventDefault();
                onClick();
              }
            }
          : undefined
      }
      data-active={active ? "true" : undefined}
      {...cyAttrs({ cy, cyId, cyValue: state })}
    >
      {title ? (
        <div style={{ fontSize: "var(--text-h3)", fontWeight: 600 }}>
          {title}
        </div>
      ) : null}
      {subtitle ? (
        <div
          style={{
            fontSize: "var(--text-small)",
            color: "var(--text-secondary)",
            marginTop: 4,
          }}
        >
          {subtitle}
        </div>
      ) : null}
      {children}
    </div>
  );
}
