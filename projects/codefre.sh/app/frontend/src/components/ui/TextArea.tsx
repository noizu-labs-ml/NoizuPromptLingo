"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface TextAreaProps
  extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  error?: boolean;
  cy?: string;
  cyId?: string | number;
  cyScope?: string;
}

/**
 * Forge multi-line text input.
 *
 * @example
 * <TextArea name="description" rows={4} />
 */
export const TextArea = React.forwardRef<HTMLTextAreaElement, TextAreaProps>(
  function TextArea({ className, error, cy, cyId, cyScope, ...rest }, ref) {
    const classes = [
      "sg-input",
      error ? "sg-input--error" : "",
      className || "",
    ]
      .filter(Boolean)
      .join(" ");

    return (
      <textarea
        ref={ref}
        className={classes}
        {...cyAttrs({ cy: cy ?? `textarea-${rest.name || "text"}`, cyId, cyScope })}
        {...rest}
      />
    );
  }
);
