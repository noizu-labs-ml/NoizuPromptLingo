"use client";

import React from "react";

/**
 * PermissionMatrix — Grid of resource types × actions with toggle cells for configuring access.
 * Security-reviewed component (Kai #48).
 *
 * @example
 * ```tsx
 * <PermissionMatrix
 *   resources={["Tasks","Projects","Agents","Settings"]}
 *   actions={["read","create","update","delete"]}
 *   permissions={{ "Tasks:read": true, "Tasks:create": true, "Projects:read": true }}
 *   onChange={setPerms}
 * />
 * ```
 */

type Scope = "workspace" | "project" | "item";

interface PermissionMatrixProps {
  resources: string[];
  actions: string[];
  permissions: Record<string, boolean>;
  onChange: (permissions: Record<string, boolean>) => void;
  scope?: Scope;
  onScopeChange?: (scope: Scope) => void;
}

function permKey(resource: string, action: string) { return `${resource}:${action}`; }

export function PermissionMatrix({ resources, actions, permissions, onChange, scope, onScopeChange }: PermissionMatrixProps) {
  const toggle = (resource: string, action: string) => {
    const key = permKey(resource, action);
    onChange({ ...permissions, [key]: !permissions[key] });
  };

  const toggleRow = (resource: string) => {
    const allOn = actions.every((a) => permissions[permKey(resource, a)]);
    const next = { ...permissions };
    actions.forEach((a) => { next[permKey(resource, a)] = !allOn; });
    onChange(next);
  };

  const toggleCol = (action: string) => {
    const allOn = resources.every((r) => permissions[permKey(r, action)]);
    const next = { ...permissions };
    resources.forEach((r) => { next[permKey(r, action)] = !allOn; });
    onChange(next);
  };

  const enabledCount = Object.values(permissions).filter(Boolean).length;
  const totalCells = resources.length * actions.length;

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
      {/* Scope selector */}
      {scope && onScopeChange && (
        <div style={{ display: "flex", gap: "4px", alignItems: "center" }}>
          <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)", textTransform: "uppercase", letterSpacing: "0.06em" }}>Scope:</span>
          {(["workspace", "project", "item"] as Scope[]).map((s) => (
            <button key={s} type="button" onClick={() => onScopeChange(s)} style={{ padding: "2px 8px", borderRadius: "999px", border: `1px solid ${s === scope ? "var(--info, var(--blue))" : "var(--border)"}`, background: s === scope ? "color-mix(in srgb, var(--info, var(--blue)) 10%, transparent)" : "var(--surface)", color: s === scope ? "var(--info, var(--blue))" : "var(--text-muted)", fontFamily: "var(--font-body)", fontSize: "var(--font-size-2xs, 10px)", cursor: "pointer", textTransform: "capitalize" }}>{s}</button>
          ))}
        </div>
      )}

      {/* Matrix table */}
      <div style={{ overflowX: "auto", border: "1px solid var(--border)", borderRadius: "var(--radius, 6px)", background: "var(--surface)" }}>
        <table style={{ width: "100%", borderCollapse: "collapse" }}>
          <thead>
            <tr style={{ borderBottom: "1px solid var(--border)" }}>
              <th style={{ padding: "6px 10px", textAlign: "left", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.06em", color: "var(--text-muted)" }}>Resource</th>
              {actions.map((action) => (
                <th key={action} style={{ padding: "6px 8px", textAlign: "center", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.06em", color: "var(--text-muted)", cursor: "pointer" }} onClick={() => toggleCol(action)} title={`Toggle all ${action}`}>
                  {action}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {resources.map((resource) => {
              const rowAll = actions.every((a) => permissions[permKey(resource, a)]);
              return (
                <tr key={resource} style={{ borderBottom: "1px solid var(--border)" }}>
                  <td style={{ padding: "6px 10px", fontFamily: "var(--font-body)", fontSize: "var(--font-size-xs)", fontWeight: 500, color: "var(--text)", cursor: "pointer" }} onClick={() => toggleRow(resource)} title={`Toggle all for ${resource}`}>
                    <span style={{ display: "flex", alignItems: "center", gap: "4px" }}>
                      {resource}
                      {rowAll && <span style={{ color: "var(--success)", fontSize: "var(--font-size-2xs, 10px)" }}>✓</span>}
                    </span>
                  </td>
                  {actions.map((action) => {
                    const key = permKey(resource, action);
                    const on = !!permissions[key];
                    return (
                      <td key={action} style={{ padding: "6px 8px", textAlign: "center" }}>
                        <button type="button" onClick={() => toggle(resource, action)} aria-label={`${resource} ${action}: ${on ? "enabled" : "disabled"}`} aria-pressed={on} style={{ width: 24, height: 24, borderRadius: 4, border: `1px solid ${on ? "var(--success)" : "var(--border)"}`, background: on ? "var(--success)" : "transparent", color: on ? "#fff" : "var(--text-muted)", fontSize: "10px", fontWeight: 700, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto" }}>
                          {on ? "✓" : ""}
                        </button>
                      </td>
                    );
                  })}
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Summary */}
      <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>
        {enabledCount}/{totalCells} permissions enabled
      </span>
    </div>
  );
}

export default PermissionMatrix;
