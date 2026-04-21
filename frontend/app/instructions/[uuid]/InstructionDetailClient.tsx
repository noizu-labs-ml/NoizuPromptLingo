"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import useSWR from "swr";
import clsx from "clsx";
import { BookOpenIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { InstructionVersion } from "@/lib/api/types";

import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";

import { relativeTime } from "@/lib/utils/format";

// ── Version timeline item ─────────────────────────────────────────────────

function VersionItem({
  version,
  isActive,
  isSelected,
  onClick,
}: {
  version: InstructionVersion;
  isActive: boolean;
  isSelected: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={clsx(
        "w-full text-left px-3 py-2.5 rounded-md transition-colors",
        "border-l-2",
        isSelected
          ? "border-l-brand-500 bg-surface-raised"
          : "border-l-transparent hover:bg-surface-raised"
      )}
    >
      <div className="flex items-center gap-2">
        <Badge variant={isActive ? "success" : "default"} size="sm">
          v{version.version}
        </Badge>
        {isActive && (
          <Badge variant="info" size="sm">
            active
          </Badge>
        )}
      </div>
      <p className="mt-1 text-xs text-muted line-clamp-2">{version.change_note}</p>
      <p className="mt-0.5 text-xs text-subtle">{relativeTime(version.created_at)}</p>
    </button>
  );
}

// ── Body viewer ────────────────────────────────────────────────────────────

function BodyViewer({ body }: { body: string }) {
  return (
    <Card className="flex-1">
      <pre className="whitespace-pre-wrap font-mono text-sm text-foreground leading-relaxed overflow-auto">
        {body}
      </pre>
    </Card>
  );
}

// ── Main client component ─────────────────────────────────────────────────

export function InstructionDetailClient() {
  const params = useParams();
  const rawUuid = params?.uuid;
  const uuid = Array.isArray(rawUuid) ? rawUuid[0] : rawUuid ?? null;

  const { data: instruction, isLoading } = useSWR(
    uuid ? `instructions.get.${uuid}` : null,
    () => api.instructions.get(uuid!)
  );

  const [selectedVersion, setSelectedVersion] = useState<number | null>(null);

  // Resolve the currently displayed version number (default: active_version)
  const displayVersion =
    selectedVersion ?? instruction?.active_version ?? null;

  const versionBody =
    instruction?.versions.find((v) => v.version === displayVersion)?.body ?? "";

  if (!uuid) {
    return (
      <EmptyState
        icon={<BookOpenIcon />}
        title="No instruction specified"
        description="Navigate to an instruction from the list."
      />
    );
  }

  if (isLoading) {
    return (
      <div className="flex flex-col gap-6">
        <div className="h-16 rounded-lg bg-surface-raised border border-border animate-pulse" />
        <div className="h-64 rounded-lg bg-surface-raised border border-border animate-pulse" />
      </div>
    );
  }

  if (!instruction) {
    return (
      <EmptyState
        icon={<BookOpenIcon />}
        title="Instruction not found"
        description="This instruction does not exist or has been removed."
      />
    );
  }

  // Versions newest-first for timeline display
  const versionsDesc = [...instruction.versions].sort(
    (a, b) => b.version - a.version
  );

  return (
    <div className="flex flex-col gap-6">
      {/* Header */}
      <PageHeader
        title={instruction.title}
        description={instruction.description}
        actions={
          <div className="flex flex-wrap items-center gap-2">
            <Badge variant="success" size="sm">
              v{instruction.active_version}
            </Badge>
            {instruction.tags.map((tag) => (
              <Badge key={tag} variant="default" size="sm">
                {tag}
              </Badge>
            ))}
          </div>
        }
      />

      {/* Two-column layout */}
      <div className="flex gap-6 items-start">
        {/* Left: Version timeline */}
        <aside className="w-64 shrink-0 flex flex-col gap-1">
          <p className="px-3 text-xs font-semibold text-subtle uppercase tracking-wider mb-1">
            Versions
          </p>
          <div className="flex flex-col gap-0.5">
            {versionsDesc.map((v) => (
              <VersionItem
                key={v.version}
                version={v}
                isActive={v.version === instruction.active_version}
                isSelected={v.version === displayVersion}
                onClick={() => setSelectedVersion(v.version)}
              />
            ))}
          </div>
        </aside>

        {/* Right: Body viewer */}
        <div className="flex-1 min-w-0 flex flex-col gap-3">
          <div className="flex items-center gap-2">
            <span className="text-sm font-medium text-foreground">Body</span>
            {displayVersion !== null && (
              <Badge variant="default" size="sm">
                v{displayVersion}
              </Badge>
            )}
          </div>
          {versionBody ? (
            <BodyViewer body={versionBody} />
          ) : (
            <EmptyState title="No content" description="This version has no body." />
          )}
        </div>
      </div>
    </div>
  );
}
