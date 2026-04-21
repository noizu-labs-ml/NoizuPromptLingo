"use client";

import clsx from "clsx";
import { ReactNode } from "react";

export interface FormFieldProps {
  /** Visible label above the control. */
  label?: ReactNode;
  /** Secondary descriptive text below the control. Hidden when `error` is present. */
  helper?: ReactNode;
  /** Error message rendered below the control. Takes precedence over `helper`. */
  error?: string;
  /** Appends a red asterisk to the label. */
  required?: boolean;
  /** Forwarded to the `<label htmlFor>` attribute. */
  htmlFor?: string;
  /** The control (Input / Textarea / Select / custom). */
  children: ReactNode;
  className?: string;
}

/**
 * Label + control + helper/error composition primitive.
 *
 * Pairs with `Input`, `Textarea`, and `Select` — pass the control as `children`
 * and the wrapper handles label, helper text, and error messaging.
 */
export function FormField({
  label,
  helper,
  error,
  required = false,
  htmlFor,
  children,
  className,
}: FormFieldProps) {
  const showError = Boolean(error);

  return (
    <div className={clsx("flex flex-col gap-1", className)}>
      {label && (
        <label
          htmlFor={htmlFor}
          className="text-label text-subtle uppercase"
        >
          {label}
          {required && (
            <span className="text-danger ml-0.5" aria-hidden="true">
              *
            </span>
          )}
        </label>
      )}
      {children}
      {showError ? (
        <p className="text-xs text-danger" role="alert">
          {error}
        </p>
      ) : (
        helper && <p className="text-xs text-subtle">{helper}</p>
      )}
    </div>
  );
}
