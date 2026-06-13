"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface FormFieldProps {
  label: React.ReactNode;
  name: string;
  hint?: React.ReactNode;
  error?: React.ReactNode;
  required?: boolean;
  children: (props: {
    id: string;
    name: string;
    "aria-describedby": string | undefined;
    "aria-invalid": boolean | undefined;
    "aria-required": boolean | undefined;
  }) => React.ReactNode;
  className?: string;
  cy?: string;
}

/**
 * Wraps a form control with label, hint, and error — wiring aria-describedby.
 *
 * @example
 * <FormField label="Name" name="name" hint="Slug for URLs" required>
 *   {(p) => <TextInput {...p} />}
 * </FormField>
 */
export function FormField({
  label,
  name,
  hint,
  error,
  required,
  children,
  className,
  cy,
}: FormFieldProps) {
  const id = React.useId();
  const hintId = hint ? `${id}-hint` : undefined;
  const errorId = error ? `${id}-error` : undefined;
  const describedBy = [hintId, errorId].filter(Boolean).join(" ") || undefined;

  return (
    <div
      className={["sg-field", className || ""].filter(Boolean).join(" ")}
      {...cyAttrs({ cy: cy ?? `field-${name}` })}
    >
      <label className="sg-field-label" htmlFor={id}>
        {label}
        {required ? (
          <span aria-hidden="true" style={{ color: "var(--eval-fail)", marginLeft: 4 }}>
            *
          </span>
        ) : null}
      </label>
      {children({
        id,
        name,
        "aria-describedby": describedBy,
        "aria-invalid": error ? true : undefined,
        "aria-required": required || undefined,
      })}
      {hint && !error ? (
        <p id={hintId} className="sg-field-hint">
          {hint}
        </p>
      ) : null}
      {error ? (
        <p id={errorId} className="sg-field-error" role="alert">
          {error}
        </p>
      ) : null}
    </div>
  );
}
