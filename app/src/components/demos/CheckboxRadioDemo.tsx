"use client";

import { useState } from "react";
import { Checkbox, Switch, RadioGroup, Radio } from "@headlessui/react";

// ─── Checkbox ───

const CHECKBOXES = [
  { id: "email",  label: "Email digest",       default: true  },
  { id: "push",   label: "Push notifications", default: false },
  { id: "report", label: "Weekly report",       default: true  },
  { id: "news",   label: "Product updates",    default: false },
];

function StyledCheckbox({ checked, label }: { checked: boolean; label: string }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: "var(--space-1)", cursor: "pointer", userSelect: "none" }}>
      <div
        style={{
          width: 16, height: 16, flexShrink: 0, borderRadius: "var(--radius)",
          border: checked ? "none" : "1.5px solid var(--text-muted)",
          background: checked ? "var(--brand-blue)" : "var(--surface)",
          display: "flex", alignItems: "center", justifyContent: "center",
          transition: "background 0.12s, border 0.12s",
          boxShadow: checked ? "none" : "inset 0 1px 2px rgba(0,0,0,0.06)",
        }}
      >
        {checked && (
          <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
            <path d="M1 4l2.5 2.5L9 1" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        )}
      </div>
      <span style={{ fontSize: "var(--font-size-sm)", color: "var(--surface-alt)" }}>{label}</span>
    </div>
  );
}

function CheckboxGroup() {
  const [checked, setChecked] = useState<Record<string, boolean>>(
    Object.fromEntries(CHECKBOXES.map((c) => [c.id, c.default]))
  );

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)" }}>
      <div style={{ fontSize: "var(--font-size-xs)", fontWeight: 700, letterSpacing: "0.06em", textTransform: "uppercase", color: "var(--text-muted)", marginBottom: "var(--space-half)" }}>
        Notifications
      </div>
      {CHECKBOXES.map((item) => (
        <Checkbox
          key={item.id}
          checked={checked[item.id]}
          onChange={(val) => setChecked((prev) => ({ ...prev, [item.id]: val }))}
          as="div"
        >
          <StyledCheckbox checked={checked[item.id]} label={item.label} />
        </Checkbox>
      ))}
    </div>
  );
}

// ─── Switch / Toggle ───

const SWITCHES = [
  { id: "darkmode",   label: "Dark mode",        default: true  },
  { id: "analytics",  label: "Analytics",         default: false },
  { id: "beta",       label: "Beta features",     default: true  },
];

function StyledSwitch({ checked, label }: { checked: boolean; label: string }) {
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: "var(--space-4)", cursor: "pointer" }}>
      <span style={{ fontSize: "var(--font-size-sm)", color: "var(--surface-alt)", userSelect: "none" }}>{label}</span>
      <div
        style={{
          width: 36, height: 20, borderRadius: 10, flexShrink: 0,
          background: checked ? "var(--brand-blue)" : "var(--border)",
          position: "relative",
          transition: "background 0.15s",
        }}
      >
        <div
          style={{
            width: 14, height: 14, borderRadius: 7, background: "var(--white)",
            position: "absolute", top: 3,
            left: checked ? 19 : 3,
            transition: "left 0.15s",
            boxShadow: "0 1px 3px rgba(0,0,0,0.25)",
          }}
        />
      </div>
    </div>
  );
}

function SwitchGroup() {
  const [states, setStates] = useState<Record<string, boolean>>(
    Object.fromEntries(SWITCHES.map((s) => [s.id, s.default]))
  );

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)" }}>
      <div style={{ fontSize: "var(--font-size-xs)", fontWeight: 700, letterSpacing: "0.06em", textTransform: "uppercase", color: "var(--text-muted)", marginBottom: "var(--space-half)" }}>
        Feature Toggles
      </div>
      {SWITCHES.map((item) => (
        <Switch
          key={item.id}
          checked={states[item.id]}
          onChange={(val) => setStates((prev) => ({ ...prev, [item.id]: val }))}
          as="div"
        >
          <StyledSwitch checked={states[item.id]} label={item.label} />
        </Switch>
      ))}
    </div>
  );
}

// ─── RadioGroup ───

const PLANS = [
  { value: "free",   label: "Free",   desc: "Up to 3 projects" },
  { value: "pro",    label: "Pro",    desc: "$12 / month" },
  { value: "team",   label: "Team",   desc: "$40 / month" },
];

function StyledRadio({ checked, label, desc }: { checked: boolean; label: string; desc: string }) {
  return (
    <div
      style={{
        display: "flex", alignItems: "center", gap: "var(--space-1)", cursor: "pointer",
        padding: "var(--space-1) var(--space-1)",
        border: `1px solid ${checked ? "var(--brand-blue)" : "var(--border)"}`,
        background: checked ? "var(--blue-light)" : "var(--surface)",
        transition: "border-color 0.12s, background 0.12s",
        userSelect: "none",
      }}
    >
      {/* Radio circle */}
      <div
        style={{
          width: 16, height: 16, borderRadius: 8, flexShrink: 0,
          border: `1.5px solid ${checked ? "var(--brand-blue)" : "var(--text-muted)"}`,
          display: "flex", alignItems: "center", justifyContent: "center",
          background: "var(--white)",
          transition: "border-color 0.12s",
        }}
      >
        {checked && (
          <div style={{ width: 8, height: 8, borderRadius: 4, background: "var(--brand-blue)" }} />
        )}
      </div>
      <div>
        <div style={{ fontSize: "var(--font-size-sm)", fontWeight: 600, color: "var(--surface)" }}>{label}</div>
        <div style={{ fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>{desc}</div>
      </div>
    </div>
  );
}

function PlanRadioGroup() {
  const [selected, setSelected] = useState("pro");

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)" }}>
      <div style={{ fontSize: "var(--font-size-xs)", fontWeight: 700, letterSpacing: "0.06em", textTransform: "uppercase", color: "var(--text-muted)", marginBottom: "var(--space-half)" }}>
        Plan
      </div>
      <RadioGroup value={selected} onChange={setSelected}>
        <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-1)" }}>
          {PLANS.map((plan) => (
            <Radio key={plan.value} value={plan.value} as="div">
              <StyledRadio
                checked={selected === plan.value}
                label={plan.label}
                desc={plan.desc}
              />
            </Radio>
          ))}
        </div>
      </RadioGroup>
    </div>
  );
}

// ─── Export ───

export function CheckboxRadioDemo() {
  return (
    <div style={{ display: "flex", gap: "var(--space-5)", flexWrap: "wrap" }}>
      <CheckboxGroup />
      <SwitchGroup />
      <PlanRadioGroup />
    </div>
  );
}
