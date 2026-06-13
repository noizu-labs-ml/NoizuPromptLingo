"use client";

import React, { useState, useCallback, useEffect, useRef } from "react";

/**
 * ExportDialog — Format selection dialog for exporting content as PDF, Markdown, JSON,
 * CSV, or sending via email/Slack. Supports compact (quick pick) and expanded (full options).
 *
 * Used in: Weekly Review, Gantt View, Client Report Generator, Deploy Changelog, Agent Audit Log,
 * Prompt Comparison, Prompt Export.
 *
 * @example
 * ```tsx
 * <ExportDialog
 *   open={showExport}
 *   formats={["pdf", "markdown", "json"]}
 *   onExport={(opts) => exportReport(opts)}
 *   onCancel={() => setShowExport(false)}
 * />
 * <ExportDialog
 *   open={show}
 *   formats={["csv", "json"]}
 *   deliveryChannels={["download", "email", "slack"]}
 *   scope={{ options: ["current-sprint", "all-sprints", "date-range"], default: "current-sprint" }}
 *   variant="expanded"
 *   onExport={handleExport}
 *   onCancel={close}
 * />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

type ExportFormat = "pdf" | "markdown" | "json" | "csv" | "html";
type DeliveryChannel = "download" | "email" | "slack";
type DialogVariant = "compact" | "expanded";

interface ScopeConfig {
  options: string[];
  default: string;
}

interface ExportOptions {
  format: ExportFormat;
  delivery: DeliveryChannel;
  scope?: string;
}

interface ExportDialogProps {
  /** Whether the dialog is visible */
  open: boolean;
  /** Available export formats */
  formats: ExportFormat[];
  /** Available delivery channels */
  deliveryChannels?: DeliveryChannel[];
  /** Scope filter configuration */
  scope?: ScopeConfig;
  /** Display variant */
  variant?: DialogVariant;
  /** Whether an export is in progress */
  exporting?: boolean;
  /** Fires with the selected export configuration */
  onExport: (options: ExportOptions) => void;
  /** Fires on close */
  onCancel: () => void;
  /** Optional: preview callback — if provided, shows Preview button */
  onPreview?: (options: ExportOptions) => void;
}

// ── Helpers ─────────────────────────────────────────────────────

const formatMeta: Record<ExportFormat, { label: string; icon: string; description: string }> = {
  pdf: { label: "PDF", icon: "PDF", description: "Formatted document" },
  markdown: { label: "Markdown", icon: "MD", description: "Plain text with formatting" },
  json: { label: "JSON", icon: "{ }", description: "Structured data" },
  csv: { label: "CSV", icon: "CSV", description: "Spreadsheet-compatible" },
  html: { label: "HTML", icon: "< >", description: "Web page" },
};

const deliveryMeta: Record<DeliveryChannel, { label: string; icon: string }> = {
  download: { label: "Download", icon: "D" },
  email: { label: "Email", icon: "@" },
  slack: { label: "Slack", icon: "#" },
};

function humanizeScope(scope: string): string {
  return scope
    .replace(/-/g, " ")
    .replace(/\b\w/g, (c) => c.toUpperCase());
}

// ── Component ───────────────────────────────────────────────────

export function ExportDialog({
  open,
  formats,
  deliveryChannels = ["download"],
  scope,
  variant = "compact",
  exporting = false,
  onExport,
  onCancel,
  onPreview,
}: ExportDialogProps) {
  const [selectedFormat, setSelectedFormat] = useState<ExportFormat>(formats[0]);
  const [selectedDelivery, setSelectedDelivery] = useState<DeliveryChannel>(deliveryChannels[0]);
  const [selectedScope, setSelectedScope] = useState<string>(scope?.default ?? "");
  const cancelRef = useRef<HTMLButtonElement>(null);

  // Reset state on open
  useEffect(() => {
    if (open) {
      setSelectedFormat(formats[0]);
      setSelectedDelivery(deliveryChannels[0]);
      setSelectedScope(scope?.default ?? "");
      requestAnimationFrame(() => cancelRef.current?.focus());
    }
  }, [open, formats, deliveryChannels, scope]);

  const currentOptions = useCallback(
    (): ExportOptions => ({
      format: selectedFormat,
      delivery: selectedDelivery,
      scope: selectedScope || undefined,
    }),
    [selectedFormat, selectedDelivery, selectedScope],
  );

  const handleExport = useCallback(() => {
    onExport(currentOptions());
  }, [onExport, currentOptions]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === "Escape") {
        e.stopPropagation();
        onCancel();
      }
      if (e.key === "Enter" && (e.metaKey || e.ctrlKey)) {
        handleExport();
      }
    },
    [onCancel, handleExport],
  );

  if (!open) return null;

  const isExpanded = variant === "expanded";

  // ── Shared option pill style ──
  const pillStyle = (selected: boolean): React.CSSProperties => ({
    padding: "4px 12px",
    borderRadius: "var(--radius, 6px)",
    border: selected ? "1px solid var(--info, var(--blue))" : "1px solid var(--border)",
    background: selected
      ? "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)"
      : "var(--surface)",
    color: selected ? "var(--info, var(--blue))" : "var(--text-secondary)",
    fontFamily: "var(--font-body)",
    fontSize: "var(--font-size-xs)",
    fontWeight: selected ? 600 : 400,
    cursor: "pointer",
    transition: "all 0.1s",
  });

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
        role="dialog"
        aria-modal="true"
        aria-labelledby="export-dialog-title"
        onClick={(e) => e.stopPropagation()}
        onKeyDown={handleKeyDown}
        tabIndex={-1}
        style={{
          width: "100%",
          maxWidth: isExpanded ? 520 : 400,
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
          }}
        >
          <h2
            id="export-dialog-title"
            style={{
              margin: 0,
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-base)",
              fontWeight: 600,
              color: "var(--text)",
            }}
          >
            Export
          </h2>
        </div>

        {/* Body */}
        <div
          style={{
            padding: "var(--space-3) var(--space-4, 16px)",
            display: "flex",
            flexDirection: "column",
            gap: "var(--space-3)",
          }}
        >
          {/* Format selection */}
          <fieldset style={{ border: "none", margin: 0, padding: 0 }}>
            <legend
              style={{
                fontFamily: "var(--font-body)",
                fontSize: "var(--font-size-xs)",
                fontWeight: 600,
                color: "var(--text-secondary)",
                marginBottom: "6px",
              }}
            >
              Format
            </legend>
            <div style={{ display: "flex", flexWrap: "wrap", gap: "6px" }}>
              {formats.map((fmt) => (
                <button
                  key={fmt}
                  type="button"
                  onClick={() => setSelectedFormat(fmt)}
                  aria-pressed={selectedFormat === fmt}
                  style={pillStyle(selectedFormat === fmt)}
                >
                  <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", marginRight: 4 }}>
                    {formatMeta[fmt].icon}
                  </span>
                  {formatMeta[fmt].label}
                </button>
              ))}
            </div>
            {isExpanded && (
              <p
                style={{
                  margin: "4px 0 0",
                  fontFamily: "var(--font-body)",
                  fontSize: "var(--font-size-2xs, 10px)",
                  color: "var(--text-muted)",
                }}
              >
                {formatMeta[selectedFormat].description}
              </p>
            )}
          </fieldset>

          {/* Delivery channel (if multiple) */}
          {deliveryChannels.length > 1 && (
            <fieldset style={{ border: "none", margin: 0, padding: 0 }}>
              <legend
                style={{
                  fontFamily: "var(--font-body)",
                  fontSize: "var(--font-size-xs)",
                  fontWeight: 600,
                  color: "var(--text-secondary)",
                  marginBottom: "6px",
                }}
              >
                Delivery
              </legend>
              <div style={{ display: "flex", flexWrap: "wrap", gap: "6px" }}>
                {deliveryChannels.map((ch) => (
                  <button
                    key={ch}
                    type="button"
                    onClick={() => setSelectedDelivery(ch)}
                    aria-pressed={selectedDelivery === ch}
                    style={pillStyle(selectedDelivery === ch)}
                  >
                    <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", marginRight: 4 }}>
                      {deliveryMeta[ch].icon}
                    </span>
                    {deliveryMeta[ch].label}
                  </button>
                ))}
              </div>
            </fieldset>
          )}

          {/* Scope (expanded only) */}
          {scope && isExpanded && (
            <fieldset style={{ border: "none", margin: 0, padding: 0 }}>
              <legend
                style={{
                  fontFamily: "var(--font-body)",
                  fontSize: "var(--font-size-xs)",
                  fontWeight: 600,
                  color: "var(--text-secondary)",
                  marginBottom: "6px",
                }}
              >
                Scope
              </legend>
              <div style={{ display: "flex", flexWrap: "wrap", gap: "6px" }}>
                {scope.options.map((opt) => (
                  <button
                    key={opt}
                    type="button"
                    onClick={() => setSelectedScope(opt)}
                    aria-pressed={selectedScope === opt}
                    style={pillStyle(selectedScope === opt)}
                  >
                    {humanizeScope(opt)}
                  </button>
                ))}
              </div>
            </fieldset>
          )}
        </div>

        {/* Footer */}
        <div
          style={{
            display: "flex",
            justifyContent: "flex-end",
            gap: "8px",
            padding: "var(--space-2) var(--space-4, 16px) var(--space-3)",
            borderTop: "1px solid var(--border)",
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
            Cancel
          </button>

          {onPreview && isExpanded && (
            <button
              type="button"
              onClick={() => onPreview(currentOptions())}
              style={{
                padding: "6px 16px",
                borderRadius: "var(--radius, 6px)",
                border: "1px solid var(--border)",
                background: "none",
                color: "var(--text-secondary)",
                fontFamily: "var(--font-body)",
                fontSize: "var(--font-size-sm)",
                fontWeight: 500,
                cursor: "pointer",
              }}
            >
              Preview
            </button>
          )}

          <button
            type="button"
            onClick={handleExport}
            disabled={exporting}
            style={{
              padding: "6px 16px",
              borderRadius: "var(--radius, 6px)",
              border: "none",
              background: exporting
                ? "color-mix(in srgb, var(--text-muted) 30%, transparent)"
                : "var(--info, var(--blue))",
              color: exporting ? "var(--text-muted)" : "#fff",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-sm)",
              fontWeight: 600,
              cursor: exporting ? "not-allowed" : "pointer",
            }}
          >
            {exporting ? "Exporting..." : `Export ${formatMeta[selectedFormat].label}`}
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
            Esc=cancel · Cmd+Enter=export
          </div>
        )}
      </div>
    </div>
  );
}

export default ExportDialog;
