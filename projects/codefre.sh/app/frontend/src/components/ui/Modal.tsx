"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface ModalProps {
  open: boolean;
  onClose: () => void;
  title?: React.ReactNode;
  description?: React.ReactNode;
  children?: React.ReactNode;
  footer?: React.ReactNode;
  className?: string;
  cy?: string;
  /** When true, clicking overlay closes. Default true. */
  dismissOnOverlay?: boolean;
}

/**
 * Centered modal overlay with focus trap + Esc-to-close.
 *
 * @example
 * <Modal open={open} onClose={close} title="Delete script?" description="This cannot be undone.">
 *   <Button variant="primary" onClick={confirm}>Delete</Button>
 * </Modal>
 */
export function Modal({
  open,
  onClose,
  title,
  description,
  children,
  footer,
  className,
  cy = "modal",
  dismissOnOverlay = true,
}: ModalProps) {
  const containerRef = React.useRef<HTMLDivElement | null>(null);
  const previousFocusRef = React.useRef<HTMLElement | null>(null);

  React.useEffect(() => {
    if (!open) return;
    previousFocusRef.current =
      typeof document !== "undefined"
        ? (document.activeElement as HTMLElement | null)
        : null;

    // Move focus into modal
    const t = window.setTimeout(() => {
      const el = containerRef.current;
      if (!el) return;
      const first = el.querySelector<HTMLElement>(
        "button,[href],input,select,textarea,[tabindex]:not([tabindex='-1'])"
      );
      (first || el).focus();
    }, 0);

    const handleKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        e.preventDefault();
        onClose();
      } else if (e.key === "Tab" && containerRef.current) {
        // Simple focus trap
        const focusables = containerRef.current.querySelectorAll<HTMLElement>(
          "button,[href],input,select,textarea,[tabindex]:not([tabindex='-1'])"
        );
        if (focusables.length === 0) return;
        const first = focusables[0];
        const last = focusables[focusables.length - 1];
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault();
          last.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
    };
    document.addEventListener("keydown", handleKey);
    return () => {
      document.removeEventListener("keydown", handleKey);
      window.clearTimeout(t);
      previousFocusRef.current?.focus?.();
    };
  }, [open, onClose]);

  if (!open) return null;

  return (
    <>
      <div
        className="sg-overlay"
        onClick={dismissOnOverlay ? onClose : undefined}
        aria-hidden="true"
      />
      <div
        ref={containerRef}
        role="dialog"
        aria-modal="true"
        aria-label={typeof title === "string" ? title : undefined}
        tabIndex={-1}
        className={["sg-modal", className || ""].filter(Boolean).join(" ")}
        {...cyAttrs({ cy })}
      >
        {(title || description) && (
          <div className="sg-modal__header">
            {title ? <h2 className="sg-modal__title">{title}</h2> : null}
            {description ? (
              <p className="sg-modal__description">{description}</p>
            ) : null}
          </div>
        )}
        <div className="sg-modal__body">{children}</div>
        {footer ? (
          <div
            className="sg-modal__header"
            style={{ borderTop: "1px solid var(--border-default)", borderBottom: "none" }}
          >
            {footer}
          </div>
        ) : null}
      </div>
    </>
  );
}
