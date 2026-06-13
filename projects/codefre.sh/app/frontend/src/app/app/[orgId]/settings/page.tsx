"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  PageHeader,
  Card,
  Button,
  EmptyState,
  LoadingSkeleton,
} from "@/components/ui";

type Category = {
  slug: string;
  label: string;
  description: string;
  href?: string;
  onClick?: () => void;
  action?: string;
};

export default function SettingsPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [isAdmin, setIsAdmin] = useState<boolean | null>(null);
  const [orgLoading, setOrgLoading] = useState(true);
  const [exporting, setExporting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    api
      .getOrganization(orgId)
      .then((res) => {
        setIsAdmin(res.organization.role === "admin");
      })
      .catch(() => setIsAdmin(false))
      .finally(() => setOrgLoading(false));
  }, [user, authLoading, router, orgId]);

  function handleExportAuditLog() {
    setExporting(true);
    setError(null);
    const url = api.getAuditLogCsvUrl(orgId);
    const a = document.createElement("a");
    const token =
      typeof window !== "undefined" ? localStorage.getItem("access_token") : null;

    if (token) {
      fetch(url, { headers: { Authorization: `Bearer ${token}` } })
        .then((res) => {
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          return res.blob();
        })
        .then((blob) => {
          const blobUrl = URL.createObjectURL(blob);
          a.href = blobUrl;
          a.download = `audit-log-${orgId}.csv`;
          a.click();
          URL.revokeObjectURL(blobUrl);
        })
        .catch((e) => {
          setError(e instanceof Error ? e.message : "export failed");
          a.href = url;
          a.download = `audit-log-${orgId}.csv`;
          a.click();
        })
        .finally(() => setExporting(false));
    } else {
      a.href = url;
      a.download = `audit-log-${orgId}.csv`;
      a.click();
      setExporting(false);
    }
  }

  if (authLoading || orgLoading) {
    return (
      <div data-cy="app-loading" className="sg-app-loading">
        <LoadingSkeleton variant="card" count={3} />
      </div>
    );
  }

  if (isAdmin === false) {
    return (
      <div data-cy="settings-admin-required">
        <PageHeader title="Settings" />
        <EmptyState
          glyph="none"
          headline="Admin access required"
          body="This page is restricted to organization administrators."
        />
      </div>
    );
  }

  const categories: Category[] = [
    {
      slug: "workspace",
      label: "Workspace",
      description: "Organization name, slug, and member management.",
      href: `/app/${orgId}`,
    },
    {
      slug: "sso",
      label: "SSO",
      description: "SAML identity provider metadata, entity ID, and certificate.",
      href: `/app/${orgId}/settings/sso`,
      action: "Configure SSO",
    },
    {
      slug: "webhooks",
      label: "Webhooks",
      description: "Outbound HTTP callbacks for run, review, and dataset events.",
      href: `/app/${orgId}/webhooks`,
      action: "Manage webhooks",
    },
    {
      slug: "audit",
      label: "Audit log export",
      description: "Download a CSV of all organization audit events.",
      onClick: handleExportAuditLog,
      action: exporting ? "Exporting…" : "Export audit log (CSV)",
    },
  ];

  return (
    <div data-cy="settings-page" {...cyAttrs({ cyScope: "settings" })}>
      <PageHeader
        title="Enterprise Settings"
        subtitle="Workspace, SSO, webhooks, and audit log exports."
      />

      {error && (
        <p className="sg-error" data-cy="settings-error">
          {error}
        </p>
      )}

      <div
        data-cy="settings-categories"
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
          gap: "1rem",
        }}
      >
        {categories.map((cat) => (
          <Card
            key={cat.slug}
            cy="settings-category"
            cyId={cat.slug}
            interactive={!!cat.href || !!cat.onClick}
            onClick={() => {
              if (cat.onClick) cat.onClick();
              else if (cat.href) router.push(cat.href);
            }}
          >
            <strong style={{ fontSize: "1.05rem", display: "block", marginBottom: "0.5rem" }}>
              {cat.label}
            </strong>
            <p
              style={{
                margin: "0 0 0.875rem",
                fontSize: "0.875rem",
                color: "var(--text-secondary)",
                lineHeight: 1.5,
              }}
            >
              {cat.description}
            </p>
            {cat.action && (
              <div style={{ display: "flex", justifyContent: "flex-end" }}>
                {cat.onClick ? (
                  <Button
                    variant="ghost"
                    size="sm"
                    cy={
                      cat.slug === "audit"
                        ? "settings-audit-export-btn"
                        : `settings-${cat.slug}-action`
                    }
                    loading={cat.slug === "audit" && exporting}
                    onClick={(e) => {
                      e.stopPropagation();
                      cat.onClick?.();
                    }}
                  >
                    {cat.action}
                  </Button>
                ) : cat.href ? (
                  <Button
                    variant="ghost"
                    size="sm"
                    cy={`settings-${cat.slug}-link`}
                    href={cat.href}
                    onClick={(e) => e.stopPropagation()}
                  >
                    {cat.action}
                  </Button>
                ) : null}
              </div>
            )}
          </Card>
        ))}
      </div>
    </div>
  );
}
