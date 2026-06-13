"use client";
import * as React from "react";
import {
  Button,
  PageHeader,
  StatusPill,
} from "@/components/ui";
import type { Script, ScriptVersion } from "@/lib/api";

export interface ScriptEditorHeaderProps {
  orgId: string;
  script: Script;
  draftVersion: ScriptVersion | null;
  onAutoLayout: () => void;
  onFork: () => void;
  onExport: () => void;
  onPublish: () => void;
}

/**
 * Page header for the scripts editor — breadcrumbs, title, subtitle, and
 * the action cluster (publish status, auto-layout, fork, export, publish).
 */
export function ScriptEditorHeader({
  orgId,
  script,
  draftVersion,
  onAutoLayout,
  onFork,
  onExport,
  onPublish,
}: ScriptEditorHeaderProps) {
  const published = Boolean(script.current_version_id);

  return (
    <PageHeader
      title={<span data-cy="script-name">{script.name}</span>}
      subtitle={
        <span>
          <span
            data-cy="script-slug"
            style={{
              fontFamily: "var(--font-mono)",
              color: "var(--text-secondary)",
            }}
          >
            {script.slug}
          </span>
          {draftVersion ? (
            <>
              <span style={{ color: "var(--text-ghost)" }}> · </span>
              <span style={{ color: "var(--text-secondary)" }}>
                draft v{draftVersion.version_number}
              </span>
            </>
          ) : null}
        </span>
      }
      breadcrumbs={[
        { label: "scripts", href: `/app/${orgId}/scripts` },
        { label: script.slug, current: true },
      ]}
      actions={
        <>
          <StatusPill
            state={published ? "pass" : "pending"}
            size="sm"
            label={published ? "published" : "draft"}
            cy="script-publish-status"
            cyId={published ? "published" : "draft"}
          />
          <Button variant="ghost" onClick={onAutoLayout} cy="script-auto-layout">
            Auto-layout
          </Button>
          <Button
            variant="ghost"
            onClick={onFork}
            disabled={!published}
            title={
              published
                ? "Fork this published script"
                : "Publish before forking"
            }
            cy="script-fork"
          >
            Fork
          </Button>
          <Button
            variant="ghost"
            onClick={onExport}
            disabled={!published}
            title={
              published
                ? "Export latest published YAML"
                : "Publish before exporting"
            }
            cy="script-export"
          >
            Export YAML
          </Button>
          <Button variant="primary" onClick={onPublish} cy="script-publish">
            Publish
          </Button>
        </>
      }
    />
  );
}
