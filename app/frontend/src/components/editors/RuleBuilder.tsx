"use client";

import React, { useState } from "react";

/**
 * RuleBuilder — Visual query/rule builder with field/operator/value rows and boolean logic nesting.
 * Security-reviewed component (Kai #48).
 *
 * @example
 * ```tsx
 * <RuleBuilder
 *   fields={[{ id: "status", label: "Status", type: "select", options: ["open","closed"] }, { id: "priority", label: "Priority", type: "select", options: ["p0","p1","p2","p3"] }]}
 *   rules={rules}
 *   onChange={setRules}
 *   allowNesting
 * />
 * ```
 */

interface FieldDef { id: string; label: string; type: "text" | "number" | "select" | "date"; options?: string[]; }
interface RuleCondition { id: string; field: string; operator: string; value: string; }
interface RuleGroup { id: string; logic: "AND" | "OR"; conditions: (RuleCondition | RuleGroup)[]; }

interface RuleBuilderProps {
  fields: FieldDef[];
  rules: RuleGroup;
  onChange: (rules: RuleGroup) => void;
  allowNesting?: boolean;
}

const operators: Record<string, string[]> = {
  text: ["equals", "contains", "starts with", "is empty", "is not empty"],
  number: ["=", "!=", ">", "<", ">=", "<="],
  select: ["is", "is not", "is any of"],
  date: ["is", "before", "after", "between"],
};

let ruleCounter = 0;
function newId() { return `rule-${++ruleCounter}-${Date.now()}`; }

function isGroup(item: RuleCondition | RuleGroup): item is RuleGroup { return "logic" in item; }

function ConditionRow({ condition, fields, onUpdate, onRemove }: { condition: RuleCondition; fields: FieldDef[]; onUpdate: (c: RuleCondition) => void; onRemove: () => void }) {
  const fieldDef = fields.find((f) => f.id === condition.field);
  const ops = operators[fieldDef?.type ?? "text"] ?? operators.text;

  return (
    <div style={{ display: "flex", gap: "4px", alignItems: "center", flexWrap: "wrap" }}>
      <select value={condition.field} onChange={(e) => onUpdate({ ...condition, field: e.target.value, operator: "", value: "" })} style={{ padding: "3px 6px", borderRadius: 4, border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", minWidth: 90 }}>
        <option value="">Field...</option>
        {fields.map((f) => <option key={f.id} value={f.id}>{f.label}</option>)}
      </select>
      <select value={condition.operator} onChange={(e) => onUpdate({ ...condition, operator: e.target.value })} style={{ padding: "3px 6px", borderRadius: 4, border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", minWidth: 80 }}>
        <option value="">Op...</option>
        {ops.map((o) => <option key={o} value={o}>{o}</option>)}
      </select>
      {fieldDef?.type === "select" ? (
        <select value={condition.value} onChange={(e) => onUpdate({ ...condition, value: e.target.value })} style={{ padding: "3px 6px", borderRadius: 4, border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", minWidth: 80 }}>
          <option value="">Value...</option>
          {fieldDef.options?.map((o) => <option key={o} value={o}>{o}</option>)}
        </select>
      ) : (
        <input type={fieldDef?.type === "number" ? "number" : fieldDef?.type === "date" ? "date" : "text"} value={condition.value} onChange={(e) => onUpdate({ ...condition, value: e.target.value })} placeholder="Value..." style={{ padding: "3px 6px", borderRadius: 4, border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", minWidth: 80, flex: 1 }} />
      )}
      <button type="button" onClick={onRemove} title="Remove rule" style={{ background: "none", border: "none", color: "var(--error)", cursor: "pointer", fontSize: "var(--font-size-xs)", padding: "0 4px" }}>✕</button>
    </div>
  );
}

function GroupEditor({ group, fields, onChange, onRemove, allowNesting, depth = 0 }: { group: RuleGroup; fields: FieldDef[]; onChange: (g: RuleGroup) => void; onRemove?: () => void; allowNesting: boolean; depth?: number }) {
  const addCondition = () => onChange({ ...group, conditions: [...group.conditions, { id: newId(), field: "", operator: "", value: "" }] });
  const addGroup = () => onChange({ ...group, conditions: [...group.conditions, { id: newId(), logic: "AND", conditions: [] }] });
  const removeAt = (i: number) => onChange({ ...group, conditions: group.conditions.filter((_, j) => j !== i) });
  const updateAt = (i: number, item: RuleCondition | RuleGroup) => {
    const next = [...group.conditions];
    next[i] = item;
    onChange({ ...group, conditions: next });
  };

  return (
    <div style={{ padding: "var(--space-2)", borderRadius: "var(--radius, 6px)", border: "1px solid var(--border)", background: depth > 0 ? "color-mix(in srgb, var(--text-muted) 4%, transparent)" : "var(--surface)", display: "flex", flexDirection: "column", gap: "6px" }}>
      <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>Match</span>
        <button type="button" onClick={() => onChange({ ...group, logic: group.logic === "AND" ? "OR" : "AND" })} style={{ padding: "2px 8px", borderRadius: 4, border: "1px solid var(--border)", background: group.logic === "AND" ? "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)" : "color-mix(in srgb, var(--warning) 10%, transparent)", color: group.logic === "AND" ? "var(--info, var(--blue))" : "var(--warning)", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 700, cursor: "pointer" }}>
          {group.logic}
        </button>
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>of the following</span>
        {onRemove && <button type="button" onClick={onRemove} title="Remove group" style={{ marginLeft: "auto", background: "none", border: "none", color: "var(--error)", cursor: "pointer", fontSize: "var(--font-size-xs)" }}>✕</button>}
      </div>
      {group.conditions.map((item, i) =>
        isGroup(item) ? (
          <GroupEditor key={item.id} group={item} fields={fields} onChange={(g) => updateAt(i, g)} onRemove={() => removeAt(i)} allowNesting={allowNesting} depth={depth + 1} />
        ) : (
          <ConditionRow key={item.id} condition={item} fields={fields} onUpdate={(c) => updateAt(i, c)} onRemove={() => removeAt(i)} />
        )
      )}
      <div style={{ display: "flex", gap: "6px" }}>
        <button type="button" onClick={addCondition} style={{ padding: "2px 10px", borderRadius: "var(--radius, 6px)", border: "1px dashed var(--border)", background: "none", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>+ Rule</button>
        {allowNesting && depth < 2 && (
          <button type="button" onClick={addGroup} style={{ padding: "2px 10px", borderRadius: "var(--radius, 6px)", border: "1px dashed var(--border)", background: "none", color: "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", cursor: "pointer" }}>+ Group</button>
        )}
      </div>
    </div>
  );
}

export function RuleBuilder({ fields, rules, onChange, allowNesting = false }: RuleBuilderProps) {
  return <GroupEditor group={rules} fields={fields} onChange={onChange} allowNesting={allowNesting} />;
}

export default RuleBuilder;
