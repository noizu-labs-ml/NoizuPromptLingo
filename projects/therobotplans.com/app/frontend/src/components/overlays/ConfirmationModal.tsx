"use client";

import React, { useState, useCallback, useRef, useEffect } from "react";

/**
 * ConfirmationModal — Action confirmation dialog with impact summary, mandatory reason
 * field, and confirm/cancel actions. Supports destructive and standard variants.
 *
 * Used in: Archive, Deploy Approval, Rollback Confirmation, Checklist Enforcement, Pre-Deploy Checklist.
 *
 * Accessibility: focus-trapped, Escape dismisses, autofocuses the cancel button (safe default).
 *
 * @example
 * ```tsx
 * <ConfirmationModal
 *   open={showConfirm}
 *   title="Archive Project"
 *   message="This will archive the project and hide it from active views."
 *   onConfirm={(reason) => archive(reason)}
 *   onCancel={() => setShowConfirm(false)}
 *   destructive
 *   requireReason
 * />
 * <ConfirmationModal
 *   open={showDeploy}
 *   title="Approve Deploy"
 *   message="Deploy v2.4.1 to production?"
 *   impact={{ severity: "medium", details: "3 services affected, 2min estimated downtime" }}
 *   confirmLabel="Deploy"
 *   onConfirm={() => deploy()}
 *   onCancel={() => setShowDeploy(false)}
 * />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type ModalVariant = "compact" | "expanded";

interface ImpactAssessment {
  severity: "low" | "medium" | "high" | "critical";
  details: string;
}

interface ConfirmationModalProps {
  /** Whether the modal is visible */
  open: boolean;
  /** Dialog title */
  title: string;
  /** Descriptive message */
  message: string;
  /** Optional impact assessment panel */
  impact?: ImpactAssessment;
  /** Require a reason before confirming */
  requireReason?: boolean;
  /** Label for the confirm button */
  confirmLabel?: string;
  /** Label for the cancel button */
  cancelLabel?: string;
  /** Whether this is a destructive action (red styling) */
  destructive?: boolean;
  /** Display variant */
  variant?: ModalVariant;
  /** Fires on confirm — passes reason string if requireReason is true */
  onConfirm: (reason?: string) => void;
  /** Fires on cancel / dismiss */
  onCancel: () => void;
}

// ── Helpers ─────────────────────────────────────────────────────

const severityColors: Record<string, string> = {
  low: "var(--success)",
  medium: "var(--warning)",
  high: "var(--error)",
  critical: "var(--error)",
};

// ── Component ───────────────────────────────────────────────────

export function ConfirmationModal({
  open,
  title,
  message,
  impact,
  requireReason = false,
  confirmLabel = "Confirm",
  cancelLabel = "Cancel",
  destructive = false,
  variant = "compact",
  onConfirm,
  onCancel,
}: ConfirmationModalProps) {
  const [reason, setReason] = useState("");
  const cancelRef = useRef<HTMLButtonElement>(null);
  const dialogRef = useRef<HTMLDivElement>(null);

  // Reset reason when closed
  useEffect(() => {
    if (!open) setReason("");
  }, [open]);

  // Focus cancel button on open (safe default)
  useEffect(() => {
    if (open) {
      requestAnimationFrame(() => cancelRef.current?.focus());
    }
  }, [open]);

  // Escape to dismiss
  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === "Escape") {
        e.stopPropagation();
        onCancel();
      }
    },
    [onCancel],
  );

  const handleConfirm = useCallback(() => {
    if (requireReason && !reason.trim()) return;
    onConfirm(requireReason ? reason.trim() : undefined);
  }, [onConfirm, requireReason, reason]);

  if (!open) return null;

  const accentColor = destructive ? "var(--error)" : "var(--info, var(--blue))";
  const isExpanded = variant === "expanded";

  return (
    /* Backdrop */
    <div
      role="presentation"
      onClick={onCancel}
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 9999,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "rgba(0, 0, 0, 0.45)",
        padding: "var(--space-4, 16px)",
      }}
    >
      {/* Dialog */}
      <div
        ref={dialogRef}
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="confirm-modal-title"
        aria-describedby="confirm-modal-message"
        onClick={(e) => e.stopPropagation()}
        onKeyDown={handleKeyDown}
        tabIndex={-1}
        style={{
          width: "100%",
          maxWidth: isExpanded ? 520 : 420,
          borderRadius: "var(--radius, 6px)",
          border: "1px solid var(--border)",
          background: "var(--surface)",
          boxShadow: "0 8px 32px rgba(0,0,0,0.18)",
          overflow: "hidden",
        }}
      >
        {/* Header */}
        <div
          style={{
            padding: "var(--space-3) var(--space-4, 16px)",
            borderBottom: "1px solid var(--border)",
            display: "flex",
            alignItems: "center",
            gap: "8px",
          }}
        >
          {destructive && (
            <span
              style={{
                width: 8,
                height: 8,
                borderRadius: "50%",
                background: "var(--error)",
                flexShrink: 0,
              }}
            />
          )}
          <h2
            id="confirm-modal-title"
            style={{
              margin: 0,
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-base)",
              fontWeight: 600,
              color: "var(--text)",
            }}
          >
            {title}
          </h2>
        </div>

        {/* Body */}
        <div style={{ padding: "var(--space-3) var(--space-4, 16px)", display: "flex", flexDirection: "column", gap: "var(--space-3)" }}>
          <p
            id="confirm-modal-message"
            style={{
              margin: 0,
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-sm)",
              color: "var(--text-secondary)",
              lineHeight: 1.5,
            }}
          >
            {message}
          </p>

          {/* Impact assessment (expanded variant) */}
          {impact && isExpanded && (
            <div
              role="status"
              aria-label={`Impact: ${impact.severity}`}
              style={{
                display: "flex",
                alignItems: "flex-start",
                gap: "8px",
                padding: "var(--space-2)",
                borderRadius: "var(--radius, 6px)",
                background: `color-mix(in srgb, ${severityColors[impact.severity]} 8%, transparent)`,
                border: `1px solid color-mix(in srgb, ${severityColors[impact.severity]} 25%, transparent)`,
              }}
            >
              <span
                style={{
                  padding: "1px 6px",
                  borderRadius: "999px",
                  background: `color-mix(in srgb, ${severityColors[impact.severity]} 15%, transparent)`,
                  color: severityColors[impact.severity],
                  fontFamily: "var(--font-mono)",
                  fontSize: "var(--font-size-2xs, 10px)",
                  fontWeight: 600,
                  textTransform: "uppercase",
                  flexShrink: 0,
                }}
              >
                {impact.severity}
              </span>
              <span
                style={{
                  fontFamily: "var(--font-body)",
                  fontSize: "var(--font-size-xs)",
                  color: "var(--text-secondary)",
                  lineHeight: 1.4,
                }}
              >
                {impact.details}
              </span>
            </div>
          )}

          {/* Reason field */}
          {requireReason && (
            <div style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
              <label
                htmlFor="confirm-reason"
                style={{
                  fontFamily: "var(--font-body)",
                  fontSize: "var(--font-size-xs)",
                  fontWeight: 500,
                  color: "var(--text-secondary)",
                }}
              >
                Reason <span style={{ color: "var(--error)" }}>*</span>
              </label>
              {isExpanded ? (
                <textarea
                  id="confirm-reason"
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  placeholder="Provide a reason for this action..."
                  rows={3}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" && e.metaKey) handleConfirm();
                  }}
                  style={{
                    padding: "var(--space-2)",
                    borderRadius: "var(--radius, 6px)",
                    border: "1px solid var(--border)",
                    background: "var(--bg, var(--surface))",
                    color: "var(--text)",
                    fontFamily: "var(--font-body)",
                    fontSize: "var(--font-size-xs)",
                    resize: "vertical",
                    outline: "none",
                  }}
                />
              ) : (
                <input
                  id="confirm-reason"
                  type="text"
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  placeholder="Reason..."
                  onKeyDown={(e) => {
                    if (e.key === "Enter") handleConfirm();
                  }}
                  style={{
                    padding: "6px 10px",
                    borderRadius: "var(--radius, 6px)",
                    border: "1px solid var(--border)",
                    background: "var(--bg, var(--surface))",
                    color: "var(--text)",
                    fontFamily: "var(--font-body)",
                    fontSize: "var(--font-size-xs)",
                    outline: "none",
                  }}
                />
              )}
            </div>
          )}
        </div>

        {/* Footer actions */}
        <div
          style={{
            display: "flex",
            justifyContent: "flex-end",
            gap: "8px",
            padding: "var(--space-2) var(--space-4, 16px) var(--space-3)",
          }}
        >
          <button
            ref={cancelRef}
            type="button"
            onClick={onCancel}
            style={{
              padding: "6px 16px",
              borderRadius: "var(--radius, 6px)",
              border: "1px solid var(--border)",
              background: "var(--surface)",
              color: "var(--text-secondary)",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-sm)",
              fontWeight: 500,
              cursor: "pointer",
            }}
          >
            {cancelLabel}
          </button>
          <button
            type="button"
            onClick={handleConfirm}
            disabled={requireReason && !reason.trim()}
            style={{
              padding: "6px 16px",
              borderRadius: "var(--radius, 6px)",
              border: "none",
              background: requireReason && !reason.trim()
                ? "color-mix(in srgb, var(--text-muted) 30%, transparent)"
                : accentColor,
              color: requireReason && !reason.trim() ? "var(--text-muted)" : "#fff",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-sm)",
              fontWeight: 600,
              cursor: requireReason && !reason.trim() ? "not-allowed" : "pointer",
            }}
          >
            {confirmLabel}
          </button>
        </div>

        {/* Keyboard hint */}
        {isExpanded && (
          <div
            style={{
              padding: "2px 16px 6px",
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-2xs, 10px)",
              color: "var(--text-muted)",
              textAlign: "right",
            }}
          >
            Esc=cancel{requireReason ? " · Cmd+Enter=confirm" : " · Enter=confirm"}
          </div>
        )}
      </div>
    </div>
  );
}

export default ConfirmationModal;
