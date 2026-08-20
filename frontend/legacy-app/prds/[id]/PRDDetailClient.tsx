"use client";

import { useParams } from "next/navigation";
import useSWR from "swr";
import {
  Disclosure,
  DisclosureButton,
  DisclosurePanel,
} from "@headlessui/react";
import { ChevronDownIcon, DocumentTextIcon } from "@heroicons/react/24/outline";
import clsx from "clsx";

import { api } from "@/lib/api/client";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import type { BadgeProps } from "@/components/primitives/Badge";
import { EmptyState } from "@/components/primitives/EmptyState";
import { DetailHeader } from "@/components/composites/DetailHeader";
import { TabBar, TabPanel } from "@/components/composites/TabBar";
import type { FRDocument, ATDocument } from "@/lib/api/types";

// ── Helpers ────────────────────────────────────────────────────────────────

function statusVariant(status: string | null | undefined): BadgeProps["variant"] {
  if (!status) return "default";
  const s = status.toLowerCase();
  if (s === "implemented" || s === "complete" || s === "documented") return "success";
  if (s === "draft") return "info";
  if (s === "in progress" || s === "in_progress") return "warning";
  return "default";
}

// ── Document Disclosure ───────────────────────────────────────────────────

function DocDisclosure({ doc }: { doc: FRDocument | ATDocument }) {
  return (
    <Disclosure>
      {({ open }) => (
        <Card className="p-0 overflow-hidden">
          <DisclosureButton className="w-full flex items-center justify-between gap-2 px-4 py-3 text-left hover:bg-surface-1 transition-colors">
            <div className="flex items-center gap-3 min-w-0">
              <span className="font-mono text-xs text-muted shrink-0">{doc.id}</span>
              <span className="text-sm font-medium text-foreground truncate">{doc.title}</span>
            </div>
            <ChevronDownIcon
              className={clsx("h-4 w-4 text-muted shrink-0 transition-transform", open && "rotate-180")}
            />
          </DisclosureButton>
          <DisclosurePanel className="border-t border-border">
            <pre className="px-4 py-3 text-xs text-foreground whitespace-pre-wrap font-mono leading-relaxed overflow-x-auto max-h-[60vh]">
              {doc.body}
            </pre>
          </DisclosurePanel>
        </Card>
      )}
    </Disclosure>
  );
}

// ── Main Component ─────────────────────────────────────────────────────────

export function PRDDetailClient() {
  const params = useParams();
  const id = typeof params.id === "string" ? params.id : Array.isArray(params.id) ? params.id[0] : "";

  const { data: prd, isLoading } = useSWR(
    id ? `prd.${id}` : null,
    () => api.prds.get(id)
  );
  const { data: frs } = useSWR(
    id && prd?.has_frs ? `prd.${id}.frs` : null,
    () => api.prds.functionalRequirements(id)
  );
  const { data: ats } = useSWR(
    id && prd?.has_ats ? `prd.${id}.ats` : null,
    () => api.prds.acceptanceTests(id)
  );

  if (isLoading) {
    return (
      <div className="space-y-6 animate-pulse">
        <div className="h-8 bg-surface-1 rounded w-1/3" />
        <div className="h-4 bg-surface-1 rounded w-1/2" />
        <div className="h-64 bg-surface-1 rounded" />
      </div>
    );
  }

  if (!prd) {
    return (
      <EmptyState
        icon={<DocumentTextIcon />}
        title="PRD not found"
        description={`No PRD with id "${id}" was found.`}
      />
    );
  }

  const tabs = [
    { id: "overview", label: "Overview" },
    {
      id: "frs",
      label: "Functional Requirements",
      badge:
        prd.functional_requirements.length > 0
          ? `(${prd.functional_requirements.length})`
          : undefined,
    },
    {
      id: "ats",
      label: "Acceptance Tests",
      badge:
        prd.acceptance_tests.length > 0
          ? `(${prd.acceptance_tests.length})`
          : undefined,
    },
  ];

  return (
    <div className="space-y-6">
      <DetailHeader
        breadcrumbs={[
          { label: "PRDs", href: "/prds" },
          { label: prd.title },
        ]}
        backHref="/prds"
        backLabel="Back to PRDs"
        title={prd.title}
        description={prd.path}
        actions={
          <div className="flex items-center gap-2">
            {prd.status && (
              <Badge variant={statusVariant(prd.status)}>{prd.status}</Badge>
            )}
            <span className="font-mono text-xs text-muted">PRD-{String(prd.number).padStart(3, "0")}</span>
          </div>
        }
      />

      <TabBar tabs={tabs}>
          {/* Overview */}
          <TabPanel>
            <Card>
              <pre className="text-xs text-foreground whitespace-pre-wrap font-mono leading-relaxed overflow-x-auto max-h-[70vh]">
                {prd.body}
              </pre>
            </Card>
          </TabPanel>

          {/* Functional Requirements */}
          <TabPanel>
            {(!frs || frs.length === 0) ? (
              <EmptyState
                title="No functional requirements"
                description="This PRD has no functional requirements documents."
              />
            ) : (
              <div className="space-y-2">
                {frs.map((fr) => (
                  <DocDisclosure key={fr.id} doc={fr} />
                ))}
              </div>
            )}
          </TabPanel>

          {/* Acceptance Tests */}
          <TabPanel>
            {(!ats || ats.length === 0) ? (
              <EmptyState
                title="No acceptance tests"
                description="This PRD has no acceptance test documents."
              />
            ) : (
              <div className="space-y-2">
                {ats.map((at) => (
                  <DocDisclosure key={at.id} doc={at} />
                ))}
              </div>
            )}
          </TabPanel>
      </TabBar>
    </div>
  );
}
