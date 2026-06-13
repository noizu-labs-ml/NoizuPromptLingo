"use client";

import { useState, useEffect, useCallback } from "react";

interface OverrideState {
  overrides: Record<string, string | null>;
  variants: Record<string, string[]>;
}

export function OverrideManager() {
  const [state, setState] = useState<OverrideState | null>(null);
  const [saving, setSaving] = useState(false);

  const load = useCallback(async () => {
    const res = await fetch("/api/save-config", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action: "get-overrides" }),
    });
    if (res.ok) setState(await res.json());
  }, []);

  useEffect(() => { load(); }, [load]);

  const setOverride = useCallback(async (section: string, variant: string | null) => {
    setSaving(true);
    await fetch("/api/save-config", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action: "set-override", section, variant }),
    });
    await load();
    setSaving(false);
  }, [load]);

  if (!state) return <div className="sg-description">Loading overrides…</div>;

  const allSections = [
    ...new Set([
      ...Object.keys(state.overrides),
      ...Object.keys(state.variants),
    ]),
  ].sort();

  if (allSections.length === 0) {
    return (
      <div className="sg-description">
        No override variants found. Save a variant from the YAML editor to create one.
      </div>
    );
  }

  return (
    <div>
      <p className="sg-description">
        Each section can use the base file or a named variant. Changes take effect on reload.
      </p>
      <table>
        <thead>
          <tr>
            <th>Section</th>
            <th>Active</th>
            <th>Available</th>
          </tr>
        </thead>
        <tbody>
          {allSections.map((section) => {
            const active = state.overrides[section] || null;
            const variants = state.variants[section] || [];
            return (
              <tr key={section}>
                <td>
                  <code style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)" }}>
                    {section}
                  </code>
                </td>
                <td>
                  <select
                    value={active || ""}
                    onChange={(e) => setOverride(section, e.target.value || null)}
                    disabled={saving}
                    className="field-select"
                    style={{ fontSize: "var(--font-size-xs)", padding: "var(--space-half) var(--space-1)", minWidth: 120 }}
                  >
                    <option value="">base</option>
                    {variants.map((v) => (
                      <option key={v} value={v}>{v}</option>
                    ))}
                  </select>
                </td>
                <td>
                  <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>
                    {variants.length ? variants.join(", ") : "—"}
                  </span>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
