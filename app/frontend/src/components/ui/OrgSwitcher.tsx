"use client";
import * as React from "react";
import Link from "next/link";
import { api, type Organization } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";

export interface OrgSwitcherProps {
  currentOrgId: string;
  cy?: string;
}

/**
 * Popover org switcher — current org + caret, opens list of user's orgs.
 * Click-outside + Esc to close.
 */
export function OrgSwitcher({
  currentOrgId,
  cy = "org-switcher",
}: OrgSwitcherProps) {
  const [open, setOpen] = React.useState(false);
  const [orgs, setOrgs] = React.useState<Organization[] | null>(null);
  const [loading, setLoading] = React.useState(false);
  const [err, setErr] = React.useState<string | null>(null);
  const rootRef = React.useRef<HTMLDivElement>(null);

  const current = React.useMemo(
    () => orgs?.find((o) => o.id === currentOrgId || o.slug === currentOrgId),
    [orgs, currentOrgId],
  );

  React.useEffect(() => {
    if (!open || orgs !== null) return;
    let cancelled = false;
    setLoading(true);
    api
      .listOrganizations()
      .then((res) => {
        if (!cancelled) setOrgs(res.organizations);
      })
      .catch((e: unknown) => {
        if (!cancelled)
          setErr(e instanceof Error ? e.message : "Failed to load workspaces");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [open, orgs]);

  React.useEffect(() => {
    if (!open) return;
    const onDown = (e: MouseEvent) => {
      if (!rootRef.current) return;
      if (!rootRef.current.contains(e.target as Node)) setOpen(false);
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    document.addEventListener("mousedown", onDown);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onDown);
      document.removeEventListener("keydown", onKey);
    };
  }, [open]);

  const label = current?.name || currentOrgId;

  return (
    <div
      ref={rootRef}
      className="sg-org-switcher"
      style={{ position: "relative" }}
      {...cyAttrs({ cy })}
    >
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="sg-btn sg-btn--ghost sg-btn--sm"
        aria-haspopup="menu"
        aria-expanded={open}
        {...cyAttrs({ cy: "org-switcher-trigger" })}
        style={{ display: "inline-flex", alignItems: "center", gap: 6 }}
      >
        <span
          style={{
            maxWidth: 160,
            overflow: "hidden",
            textOverflow: "ellipsis",
            whiteSpace: "nowrap",
          }}
        >
          {label}
        </span>
        <span aria-hidden="true" style={{ fontSize: 10, opacity: 0.7 }}>
          ▾
        </span>
      </button>
      {open ? (
        <div
          role="menu"
          className="sg-popover"
          style={{
            position: "absolute",
            top: "calc(100% + 6px)",
            right: 0,
            minWidth: 240,
            background: "var(--bg-elevated)",
            border: "1px solid var(--border-default)",
            borderRadius: "var(--radius-md)",
            boxShadow: "var(--shadow-3)",
            padding: "var(--space-2)",
            zIndex: 70,
          }}
          {...cyAttrs({ cy: "org-switcher-popover" })}
        >
          <div
            style={{
              padding: "var(--space-2) var(--space-3)",
              fontSize: "var(--text-caption)",
              color: "var(--text-tertiary)",
              textTransform: "uppercase",
              letterSpacing: "0.05em",
            }}
          >
            Workspaces
          </div>
          {loading ? (
            <div
              style={{
                padding: "var(--space-3)",
                fontSize: "var(--text-small)",
                color: "var(--text-tertiary)",
              }}
            >
              Loading…
            </div>
          ) : err ? (
            <div
              style={{
                padding: "var(--space-3)",
                fontSize: "var(--text-small)",
                color: "var(--eval-fail)",
              }}
              {...cyAttrs({ cy: "org-switcher-error" })}
            >
              {err}
            </div>
          ) : orgs && orgs.length > 0 ? (
            <ul style={{ listStyle: "none", margin: 0, padding: 0 }}>
              {orgs.map((o) => {
                const isCurrent = o.id === currentOrgId || o.slug === currentOrgId;
                return (
                  <li key={o.id}>
                    <Link
                      href={`/app/${o.id}`}
                      onClick={() => setOpen(false)}
                      role="menuitem"
                      className="sg-popover__item"
                      style={{
                        display: "flex",
                        justifyContent: "space-between",
                        alignItems: "center",
                        padding: "var(--space-2) var(--space-3)",
                        borderRadius: "var(--radius-sm)",
                        fontSize: "var(--text-body)",
                        color: isCurrent ? "var(--copper)" : "var(--text-primary)",
                        textDecoration: "none",
                      }}
                      {...cyAttrs({ cy: "org-switcher-item", cyId: o.id })}
                    >
                      <span>{o.name}</span>
                      {isCurrent ? (
                        <span aria-hidden="true" style={{ fontSize: 12 }}>
                          ✓
                        </span>
                      ) : null}
                    </Link>
                  </li>
                );
              })}
            </ul>
          ) : (
            <div
              style={{
                padding: "var(--space-3)",
                fontSize: "var(--text-small)",
                color: "var(--text-tertiary)",
              }}
            >
              No workspaces
            </div>
          )}
          <div
            style={{
              marginTop: "var(--space-2)",
              paddingTop: "var(--space-2)",
              borderTop: "1px solid var(--border-subtle)",
              display: "flex",
              flexDirection: "column",
              gap: 2,
            }}
          >
            <Link
              href="/app"
              onClick={() => setOpen(false)}
              className="sg-popover__item"
              style={{
                padding: "var(--space-2) var(--space-3)",
                borderRadius: "var(--radius-sm)",
                fontSize: "var(--text-small)",
                color: "var(--text-secondary)",
                textDecoration: "none",
              }}
              {...cyAttrs({ cy: "org-switcher-manage" })}
            >
              Manage workspaces
            </Link>
            <Link
              href="/app?new=1"
              onClick={() => setOpen(false)}
              className="sg-popover__item"
              style={{
                padding: "var(--space-2) var(--space-3)",
                borderRadius: "var(--radius-sm)",
                fontSize: "var(--text-small)",
                color: "var(--copper)",
                textDecoration: "none",
              }}
              {...cyAttrs({ cy: "org-switcher-create" })}
            >
              + Create org
            </Link>
          </div>
        </div>
      ) : null}
    </div>
  );
}
