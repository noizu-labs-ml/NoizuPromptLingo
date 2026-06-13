"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface SelectOption {
  value: string;
  label: string;
  disabled?: boolean;
}

export interface SelectProps
  extends React.SelectHTMLAttributes<HTMLSelectElement> {
  options?: SelectOption[];
  error?: boolean;
  cy?: string;
  cyId?: string | number;
  cyScope?: string;
}

/**
 * Native-select wrapper with Forge styling.
 *
 * @example
 * <Select name="role" options={[{value:"admin", label:"Admin"}, {value:"user", label:"User"}]} />
 */
export const Select = React.forwardRef<HTMLSelectElement, SelectProps>(
  function Select(
    { className, error, options, cy, cyId, cyScope, children, ...rest },
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
      <select
        ref={ref}
        className={classes}
        {...cyAttrs({ cy: cy ?? `select-${rest.name || "value"}`, cyId, cyScope })}
        {...rest}
      >
        {options
          ? options.map((o) => (
              <option key={o.value} value={o.value} disabled={o.disabled}>
                {o.label}
              </option>
            ))
          : children}
      </select>
    );
  }
);
