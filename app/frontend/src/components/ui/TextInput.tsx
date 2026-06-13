"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface TextInputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  error?: boolean;
  cy?: string;
  cyId?: string | number;
  cyScope?: string;
}

/**
 * Forge text input — pairs with <FormField>.
 *
 * @example
 * <TextInput name="email" type="email" placeholder="you@example.com" />
 */
export const TextInput = React.forwardRef<HTMLInputElement, TextInputProps>(
  function TextInput(
    { className, error, cy, cyId, cyScope, ...rest },
    ref
  ) {
    const classes = [
      "sg-input",
      error ? "sg-input--error" : "",
      className || "",
    ]
      .filter(Boolean)
      .join(" ");

    return (
      <input
        ref={ref}
        className={classes}
        {...cyAttrs({ cy: cy ?? `input-${rest.name || "text"}`, cyId, cyScope })}
        {...rest}
      />
    );
  }
);
