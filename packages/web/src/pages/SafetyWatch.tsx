import React from "react";
import { useHarness } from "../context/HarnessContext.js";

const profiles = [
  { name: "Stage Work", scope: "Staging charts and application overlays", state: "Draft" },
  { name: "Production Terraform", scope: "Terraform plans and apply surfaces", state: "Locked" },
  { name: "Secrets Management", scope: "Infisical topology and generated credentials", state: "Review" },
];

const folders = [
  { path: "kubernetes/helm", permission: "Read/write", sensitivity: "Medium" },
  { path: "terraform/production", permission: "Read only", sensitivity: "High" },
  { path: ".secrets", permission: "Disabled", sensitivity: "Critical" },
];

// ⟦𓐕𓃒𓌷𓅼⟧ SafetyWatch :: auto-generated pointer for public function SafetyWatch
export function SafetyWatch() {
  const { harness } = useHarness();

  return (
    <div className="mx-auto max-w-5xl space-y-5">
      <div>
        <p className="text-xs uppercase tracking-wider text-text-dim">Safety Watch</p>
        <h1 className="mt-1 text-2xl font-semibold text-white">Permission profiles for {harness}</h1>
      </div>

      <div className="rounded-lg border border-border-subtle bg-surface-raised p-4">
        <div className="flex items-start justify-between gap-4">
          <div>
            <h2 className="text-sm font-medium text-text-bright">Monitoring stub</h2>
            <p className="mt-1 text-sm text-text-muted">
              Policy enforcement is not active yet. This screen reserves the workflow for reviewing folder sensitivity,
              agent permissions, and context-specific enable/disable controls.
            </p>
          </div>
          <span className="rounded border border-border-subtle px-2 py-1 text-xs uppercase text-text-dim">Stub</span>
        </div>
      </div>

      <section className="grid gap-4 lg:grid-cols-3">
        {profiles.map((profile) => (
          <article key={profile.name} className="rounded-lg border border-border-subtle bg-surface-raised p-4">
            <div className="flex items-center justify-between gap-2">
              <h2 className="text-sm font-medium text-white">{profile.name}</h2>
              <span className="rounded border border-border-subtle px-2 py-0.5 text-xs text-text-dim">{profile.state}</span>
            </div>
            <p className="mt-2 text-sm text-text-muted">{profile.scope}</p>
          </article>
        ))}
      </section>

      <section className="rounded-lg border border-border-subtle bg-surface-raised">
        <div className="border-b border-border-subtle px-4 py-3">
          <h2 className="text-sm font-medium text-white">Folder permissions</h2>
        </div>
        <div className="divide-y divide-border-subtle">
          {folders.map((folder) => (
            <div key={folder.path} className="grid grid-cols-[1fr_120px_100px] items-center gap-3 px-4 py-3">
              <span className="font-mono text-sm text-text-primary">{folder.path}</span>
              <span className="text-sm text-text-muted">{folder.permission}</span>
              <span className="text-sm text-text-dim">{folder.sensitivity}</span>
            </div>
          ))}
        </div>
      </section>

      <section className="rounded-lg border border-border-subtle bg-surface-raised p-4">
        <h2 className="text-sm font-medium text-white">Audit queue</h2>
        <p className="mt-2 text-sm text-text-muted">
          Future entries will summarize permission changes, denied paths, approval windows, and active context profiles.
        </p>
      </section>
    </div>
  );
}
