"use client";
import * as React from "react";
import { Modal, Button, Select, TextInput, TextArea, FormField } from "@/components/ui";
import type { EdgeMatchMethod } from "@/lib/api";

export interface EdgeDraft {
  from: string;
  to: string;
  method: EdgeMatchMethod;
  configText: string;
  label: string;
}

export interface EdgeModalProps {
  open: boolean;
  draft: EdgeDraft | null;
  fromLabel?: string;
  toLabel?: string;
  matchMethods: readonly EdgeMatchMethod[];
  onChange: (next: EdgeDraft) => void;
  onCancel: () => void;
  onSubmit: () => void;
  submitting?: boolean;
  error?: string | null;
}

/**
 * Modal for drawing a new edge between two nodes.
 *
 * Uses the Forge `<Modal>` primitive — focus-trapped, Esc-closable.
 */
export function EdgeModal({
  open,
  draft,
  fromLabel,
  toLabel,
  matchMethods,
  onChange,
  onCancel,
  onSubmit,
  submitting,
  error,
}: EdgeModalProps) {
  if (!open || !draft) return null;

  return (
    <Modal
      open={open}
      onClose={onCancel}
      title="New edge"
      description={
        <span data-cy="edge-modal-description">
          <code style={{ color: "var(--copper)" }}>{fromLabel ?? draft.from}</code>
          {" → "}
          <code style={{ color: "var(--copper)" }}>{toLabel ?? draft.to}</code>
        </span>
      }
      cy="edge-modal"
      footer={
        <div style={{ display: "flex", gap: "var(--space-2)", justifyContent: "flex-end", width: "100%" }}>
          <Button variant="ghost" onClick={onCancel} cy="edge-modal-cancel">
            Cancel
          </Button>
          <Button
            variant="primary"
            onClick={onSubmit}
            loading={submitting}
            cy="edge-modal-submit"
          >
            Create edge
          </Button>
        </div>
      }
    >
      <FormField label="Match method" name="match_method">
        {(p) => (
          <Select
            {...p}
            value={draft.method}
            onChange={(e) =>
              onChange({ ...draft, method: e.target.value as EdgeMatchMethod })
            }
            options={matchMethods.map((m) => ({ value: m, label: m }))}
            cy="edge-match-method"
          />
        )}
      </FormField>

      <FormField label="Label (optional)" name="label">
        {(p) => (
          <TextInput
            {...p}
            type="text"
            value={draft.label}
            onChange={(e) => onChange({ ...draft, label: e.target.value })}
            cy="edge-label"
          />
        )}
      </FormField>

      <FormField
        label="Match config (JSON)"
        name="match_config"
        hint="Object passed verbatim to the edge matcher."
        error={error ?? undefined}
      >
        {(p) => (
          <TextArea
            {...p}
            rows={5}
            value={draft.configText}
            onChange={(e) => onChange({ ...draft, configText: e.target.value })}
            style={{ fontFamily: "var(--font-mono)", fontSize: "var(--text-code)" }}
            cy="edge-match-config"
          />
        )}
      </FormField>
    </Modal>
  );
}
