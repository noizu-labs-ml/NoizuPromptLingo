"use client";
import * as React from "react";
import {
  Button,
  FormField,
  Select,
  TextInput,
  StatusPill,
} from "@/components/ui";
import type { Prompt, ScriptNode } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";

export interface InspectorExpectation {
  id: string;
  label: string;
  weight: number;
}

export interface NodeInspectorProps {
  node: ScriptNode;
  prompts: Prompt[];
  expectations: InspectorExpectation[];
  onAttachPrompt: (promptVersionId: string) => Promise<void>;
  onAddExpectation: (exp: {
    label: string;
    weight?: number;
    scoring_method?: string;
  }) => Promise<void>;
}

/**
 * Inspection panel body for a selected script node. Rendered inside a
 * `<ContextPanel>` by the parent. Handles prompt attachment + expectation add.
 */
export function NodeInspector({
  node,
  prompts,
  expectations,
  onAttachPrompt,
  onAddExpectation,
}: NodeInspectorProps) {
  const [promptId, setPromptId] = React.useState("");
  const [expLabel, setExpLabel] = React.useState("");
  const [expWeight, setExpWeight] = React.useState("1");
  const [expMethod, setExpMethod] = React.useState("contains");
  const [attaching, setAttaching] = React.useState(false);
  const [adding, setAdding] = React.useState(false);

  async function handleAttach() {
    const prompt = prompts.find((p) => p.id === promptId);
    if (!prompt?.current_version_id) return;
    setAttaching(true);
    try {
      await onAttachPrompt(prompt.current_version_id);
    } finally {
      setAttaching(false);
    }
  }

  async function handleAddExp(e: React.FormEvent) {
    e.preventDefault();
    if (!expLabel.trim()) return;
    setAdding(true);
    try {
      await onAddExpectation({
        label: expLabel.trim(),
        weight: Number(expWeight) || 1,
        scoring_method: expMethod,
      });
      setExpLabel("");
      setExpWeight("1");
    } finally {
      setAdding(false);
    }
  }

  const promptOptions = prompts
    .filter((p) => p.current_version_id)
    .map((p) => ({ value: p.id, label: `${p.name} (${p.slug})` }));

  return (
    <div data-cy="node-inspector" {...cyAttrs({ cyId: node.node_key })}>
      {/* Identity */}
      <dl style={{ display: "grid", gap: "var(--space-3)", margin: 0 }}>
        <InfoRow
          label="Node key"
          cy="inspector-node-key"
          value={
            <code style={{ fontFamily: "var(--font-mono)", fontSize: "var(--text-code)" }}>
              {node.node_key}
            </code>
          }
        />
        <InfoRow
          label="Kind"
          cy="inspector-node-kind"
          value={<span style={{ fontSize: "var(--text-small)" }}>{node.kind}</span>}
        />
        {node.tone ? (
          <InfoRow
            label="Tone"
            cy="inspector-node-tone"
            value={<span style={{ fontSize: "var(--text-small)" }}>{node.tone}</span>}
          />
        ) : null}
        {node.eval_tags && node.eval_tags.length > 0 ? (
          <InfoRow
            label="Eval tags"
            cy="inspector-node-eval-tags"
            value={
              <span style={{ display: "flex", gap: "var(--space-1)", flexWrap: "wrap" }}>
                {node.eval_tags.map((t) => (
                  <StatusPill key={t} state="pass" label={t} size="sm" showIcon={false} />
                ))}
              </span>
            }
          />
        ) : null}
      </dl>

      <Divider />

      {/* Prompt section */}
      <section aria-labelledby="inspector-prompt-heading">
        <h3
          id="inspector-prompt-heading"
          style={{
            fontSize: "var(--text-h3)",
            fontWeight: 600,
            margin: "0 0 var(--space-2)",
          }}
        >
          Prompt
        </h3>
        {node.prompt_version_id ? (
          <p
            data-cy="inspector-prompt-attached"
            style={{
              fontSize: "var(--text-small)",
              color: "var(--copper)",
              margin: "0 0 var(--space-2)",
            }}
          >
            Attached (version {node.prompt_version_id.slice(0, 8)}…)
          </p>
        ) : (
          <p
            style={{
              fontSize: "var(--text-small)",
              color: "var(--text-secondary)",
              margin: "0 0 var(--space-2)",
            }}
          >
            No prompt attached.
          </p>
        )}
        <FormField label="Attach prompt" name="prompt">
          {(p) => (
            <div style={{ display: "flex", gap: "var(--space-2)" }}>
              <Select
                {...p}
                value={promptId}
                onChange={(e) => setPromptId(e.target.value)}
                options={[{ value: "", label: "Choose a prompt…" }, ...promptOptions]}
                cy="inspector-prompt-select"
                style={{ flex: 1 }}
              />
              <Button
                variant="secondary"
                size="sm"
                disabled={!promptId}
                loading={attaching}
                onClick={handleAttach}
                cy="inspector-prompt-attach"
              >
                Attach
              </Button>
            </div>
          )}
        </FormField>
      </section>

      <Divider />

      {/* Expectations */}
      <section aria-labelledby="inspector-expectations-heading">
        <h3
          id="inspector-expectations-heading"
          style={{
            fontSize: "var(--text-h3)",
            fontWeight: 600,
            margin: "0 0 var(--space-2)",
          }}
        >
          Expectations
        </h3>
        {expectations.length === 0 ? (
          <p
            data-cy="inspector-expectations-empty"
            style={{
              fontSize: "var(--text-small)",
              color: "var(--text-secondary)",
              margin: "0 0 var(--space-2)",
            }}
          >
            None yet.
          </p>
        ) : (
          <ul
            data-cy="inspector-expectations"
            style={{
              listStyle: "none",
              padding: 0,
              margin: "0 0 var(--space-3)",
              display: "grid",
              gap: "var(--space-1)",
            }}
          >
            {expectations.map((e) => (
              <li
                key={e.id}
                data-cy="inspector-expectation"
                {...cyAttrs({ cyId: e.id })}
                style={{
                  fontSize: "var(--text-small)",
                  padding: "var(--space-2) var(--space-3)",
                  border: "1px solid var(--border-default)",
                  borderRadius: "var(--radius-sm)",
                  display: "flex",
                  justifyContent: "space-between",
                  gap: "var(--space-2)",
                }}
              >
                <strong style={{ color: "var(--text-primary)" }}>{e.label}</strong>
                <span style={{ color: "var(--text-secondary)" }}>× {e.weight}</span>
              </li>
            ))}
          </ul>
        )}

        <form
          data-cy="inspector-expectation-form"
          onSubmit={handleAddExp}
          style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)" }}
        >
          <FormField label="Expectation" name="expectation_label">
            {(p) => (
              <TextInput
                {...p}
                type="text"
                value={expLabel}
                onChange={(e) => setExpLabel(e.target.value)}
                placeholder="asks clarifying questions"
                cy="inspector-expectation-label"
              />
            )}
          </FormField>
          <div style={{ display: "flex", gap: "var(--space-2)" }}>
            <div style={{ flex: 1 }}>
              <FormField label="Method" name="expectation_method">
                {(p) => (
                  <Select
                    {...p}
                    value={expMethod}
                    onChange={(e) => setExpMethod(e.target.value)}
                    options={[
                      { value: "contains", label: "contains" },
                      { value: "exact", label: "exact" },
                      { value: "regex", label: "regex" },
                      { value: "rubric", label: "rubric" },
                      { value: "llm", label: "llm" },
                    ]}
                    cy="inspector-expectation-method"
                  />
                )}
              </FormField>
            </div>
            <div style={{ width: 96 }}>
              <FormField label="Weight" name="expectation_weight">
                {(p) => (
                  <TextInput
                    {...p}
                    type="number"
                    min={0}
                    step={0.1}
                    value={expWeight}
                    onChange={(e) => setExpWeight(e.target.value)}
                    cy="inspector-expectation-weight"
                  />
                )}
              </FormField>
            </div>
          </div>
          <Button
            variant="secondary"
            size="sm"
            disabled={!expLabel.trim()}
            loading={adding}
            onClick={(e) => handleAddExp(e as unknown as React.FormEvent)}
            cy="inspector-expectation-add"
          >
            Add expectation
          </Button>
        </form>
      </section>
    </div>
  );
}

function InfoRow({
  label,
  value,
  cy,
}: {
  label: string;
  value: React.ReactNode;
  cy?: string;
}) {
  return (
    <div>
      <dt
        style={{
          fontSize: "var(--text-caption)",
          textTransform: "uppercase",
          letterSpacing: "0.05em",
          color: "var(--text-secondary)",
          marginBottom: 2,
        }}
      >
        {label}
      </dt>
      <dd
        {...(cy ? { "data-cy": cy } : {})}
        style={{ margin: 0, color: "var(--text-primary)" }}
      >
        {value}
      </dd>
    </div>
  );
}

function Divider() {
  return (
    <hr
      style={{
        margin: "var(--space-5) 0",
        border: 0,
        borderTop: "1px solid var(--border-subtle)",
      }}
    />
  );
}
