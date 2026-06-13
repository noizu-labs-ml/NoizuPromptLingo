"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { api, type Organization } from "@/lib/api";
import {
  PageHeader,
  Card,
  EmptyState,
  Button,
  LoadingSkeleton,
} from "@/components/ui";
import { cyAttrs } from "@/utils/cypress";

export default function AppHome() {
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();
  const [orgs, setOrgs] = useState<Organization[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }

    if (!user) return;

    api
      .listOrganizations()
      .then((res) => setOrgs(res.organizations))
      .catch((err) =>
        setError(err instanceof Error ? err.message : "Failed to load")
      )
      .finally(() => setLoading(false));
  }, [user, authLoading, router]);

  if (authLoading || loading) {
    return (
      <div
        className="app-loading"
        data-cy="app-loading"
        style={{ padding: "3rem 1rem" }}
      >
        <LoadingSkeleton variant="card" count={3} />
      </div>
    );
  }

  return (
    <div
      className="app-shell"
      data-cy="app-shell"
      data-cy-scope="app"
      style={{ maxWidth: 960, margin: "0 auto", padding: "2rem 1rem" }}
    >
      <PageHeader
        title="Workspaces"
        subtitle="Choose an organization"
        actions={
          <span data-cy="app-user-email" style={{ color: "var(--text-secondary)", fontSize: 13 }}>
            {user?.email}
          </span>
        }
        cy="app-header"
      />

      {error && (
        <p className="sg-error" data-cy="app-error">
          {error}
        </p>
      )}

      <section data-cy="orgs-list" data-cy-id="orgs" style={{ marginTop: "1.5rem" }}>
        {orgs.length === 0 ? (
          <EmptyState
            glyph="agents"
            headline="You don't belong to any workspace yet"
            primaryAction={
              <Button
                variant="primary"
                href="/app/organizations/new"
                cy="orgs-create-link"
              >
                Create workspace
              </Button>
            }
          />
        ) : (
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))",
              gap: "1rem",
            }}
            data-cy="orgs-ul"
          >
            {orgs.map((org) => (
              <Link
                key={org.id}
                href={`/app/${org.id}`}
                data-cy="org-link"
                style={{ textDecoration: "none", color: "inherit", display: "block" }}
              >
                <Card
                  interactive
                  data-cy="org-card"
                  {...cyAttrs({ cyId: org.slug })}
                  style={{ height: "100%" }}
                >
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "flex-start",
                      marginBottom: "0.5rem",
                    }}
                  >
                    <h3
                      data-cy="org-name"
                      style={{ margin: 0, fontSize: 16, fontWeight: 600 }}
                    >
                      {org.name}
                    </h3>
                    <span
                      data-cy="org-role"
                      data-cy-value={org.role}
                      className="sg-chip"
                      style={{ fontSize: 11, flexShrink: 0, marginLeft: "0.5rem" }}
                    >
                      {org.role || "member"}
                    </span>
                  </div>
                  <span
                    data-cy="org-slug"
                    data-cy-value={org.slug}
                    style={{
                      fontFamily: "var(--font-mono, monospace)",
                      fontSize: 12,
                      color: "var(--text-tertiary)",
                    }}
                  >
                    {org.slug}
                  </span>
                </Card>
              </Link>
            ))}

            {/* Ghost "new workspace" tile */}
            <Link
              href="/app/organizations/new"
              style={{ textDecoration: "none", color: "inherit", display: "block" }}
            >
              <Card
                interactive
                style={{
                  height: "100%",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  border: "1.5px dashed var(--border-default)",
                  background: "transparent",
                  minHeight: 80,
                }}
              >
                <span style={{ color: "var(--copper)", fontWeight: 600, fontSize: 14 }}>
                  + New workspace
                </span>
              </Card>
            </Link>
          </div>
        )}
      </section>
    </div>
  );
}
