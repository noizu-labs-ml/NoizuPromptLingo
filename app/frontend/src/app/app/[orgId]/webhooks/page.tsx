"use client";

import { use, useEffect, useState, useCallback } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import {
  api,
  type Webhook,
  type WebhookDelivery,
  type WebhookEvent,
  WEBHOOK_EVENTS,
} from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  PageHeader,
  Button,
  Card,
  EmptyState,
  LoadingSkeleton,
  Modal,
  FormField,
  TextInput,
} from "@/components/ui";

const DELIVERY_COLOR: Record<WebhookDelivery["status"], string> = {
  delivered: "var(--eval-pass)",
  failed: "var(--eval-warn)",
  dead: "var(--eval-fail)",
};

function DeliveryTable({
  deliveries,
  retrying,
  onRetry,
}: {
  deliveries: WebhookDelivery[];
  retrying: string | null;
  onRetry: (deliveryId: string) => void;
}) {
  return (
    <table
      data-cy="webhook-deliveries-table"
      className="sg-table sg-table--compact"
      style={{ width: "100%", borderCollapse: "collapse", fontSize: "0.82rem" }}
    >
      <thead>
        <tr>
          <th>Event</th>
          <th>Status</th>
          <th>HTTP</th>
          <th>Attempted</th>
          <th>Next retry</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {deliveries.map((d) => (
          <tr
            key={d.id}
            data-cy="webhook-delivery-row"
            {...cyAttrs({ cyId: d.id })}
          >
            <td>{d.event}</td>
            <td>
              <span
                data-cy="webhook-delivery-status"
                style={{ color: DELIVERY_COLOR[d.status] }}
              >
                {d.status}
              </span>
            </td>
            <td>{d.response_status ?? "—"}</td>
            <td>{new Date(d.attempted_at).toLocaleString()}</td>
            <td>{d.next_retry_at ? new Date(d.next_retry_at).toLocaleString() : "—"}</td>
            <td>
              {(d.status === "failed" || d.status === "dead") && (
                <Button
                  variant="ghost"
                  size="sm"
                  cy="webhook-delivery-retry-btn"
                  loading={retrying === d.id}
                  onClick={() => onRetry(d.id)}
                >
                  Retry
                </Button>
              )}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

export default function WebhooksPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [webhooks, setWebhooks] = useState<Webhook[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Create form
  const [showCreate, setShowCreate] = useState(false);
  const [newUrl, setNewUrl] = useState("");
  const [newEvents, setNewEvents] = useState<Set<WebhookEvent>>(new Set());
  const [newEnabled, setNewEnabled] = useState(true);
  const [creating, setCreating] = useState(false);

  // Delivery history
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [deliveries, setDeliveries] = useState<Record<string, WebhookDelivery[]>>({});
  const [deliveryLoading, setDeliveryLoading] = useState<string | null>(null);
  const [retrying, setRetrying] = useState<string | null>(null);

  const load = useCallback(() => {
    setLoading(true);
    api
      .listWebhooks(orgId)
      .then((res) => setWebhooks(res.webhooks ?? []))
      .catch((e) => {
        const msg = e instanceof Error ? e.message : "failed to load";
        if (!msg.includes("404")) setError(msg);
      })
      .finally(() => setLoading(false));
  }, [orgId]);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;
    load();
  }, [user, authLoading, router, load]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!newUrl.trim() || newEvents.size === 0) return;
    setCreating(true);
    try {
      const res = await api.createWebhook(orgId, {
        url: newUrl.trim(),
        events: Array.from(newEvents) as WebhookEvent[],
        enabled: newEnabled,
      });
      setWebhooks((prev) => [res.webhook, ...prev]);
      setNewUrl("");
      setNewEvents(new Set());
      setNewEnabled(true);
      setShowCreate(false);
    } catch (e) {
      setError(e instanceof Error ? e.message : "create failed");
    } finally {
      setCreating(false);
    }
  }

  async function toggleEnabled(hook: Webhook) {
    try {
      const res = await api.updateWebhook(orgId, hook.id, { enabled: !hook.enabled });
      setWebhooks((prev) => prev.map((h) => (h.id === hook.id ? res.webhook : h)));
    } catch (e) {
      setError(e instanceof Error ? e.message : "update failed");
    }
  }

  async function handleDelete(hookId: string) {
    try {
      await api.deleteWebhook(orgId, hookId);
      setWebhooks((prev) => prev.filter((h) => h.id !== hookId));
    } catch (e) {
      setError(e instanceof Error ? e.message : "delete failed");
    }
  }

  async function loadDeliveries(hookId: string) {
    if (expandedId === hookId) {
      setExpandedId(null);
      return;
    }
    setExpandedId(hookId);
    if (deliveries[hookId]) return;
    setDeliveryLoading(hookId);
    try {
      const res = await api.listWebhookDeliveries(orgId, hookId);
      setDeliveries((prev) => ({ ...prev, [hookId]: res.deliveries ?? [] }));
    } catch (e) {
      setError(e instanceof Error ? e.message : "failed to load deliveries");
    } finally {
      setDeliveryLoading(null);
    }
  }

  async function retryDelivery(hookId: string, deliveryId: string) {
    setRetrying(deliveryId);
    try {
      const res = await api.retryWebhookDelivery(orgId, hookId, deliveryId);
      setDeliveries((prev) => ({
        ...prev,
        [hookId]: (prev[hookId] ?? []).map((d) =>
          d.id === deliveryId ? res.delivery : d,
        ),
      }));
    } catch (e) {
      setError(e instanceof Error ? e.message : "retry failed");
    } finally {
      setRetrying(null);
    }
  }

  function toggleEvent(ev: WebhookEvent) {
    setNewEvents((prev) => {
      const next = new Set(prev);
      if (next.has(ev)) next.delete(ev);
      else next.add(ev);
      return next;
    });
  }

  if (authLoading) {
    return (
      <div data-cy="app-loading" className="sg-app-loading">
        Loading…
      </div>
    );
  }

  return (
    <div data-cy="webhooks-page" {...cyAttrs({ cyScope: "webhooks" })}>
      <PageHeader
        title="Webhooks"
        subtitle="Receive HTTP callbacks when runs complete, reviews change, or datasets publish."
        actions={
          <Button variant="primary" cy="webhooks-new-btn" onClick={() => setShowCreate(true)}>
            + New Webhook
          </Button>
        }
      />

      {error && (
        <p className="sg-error" data-cy="webhooks-error">
          {error}
        </p>
      )}

      {loading ? (
        <LoadingSkeleton variant="card" count={3} />
      ) : webhooks.length === 0 ? (
        <EmptyState
          glyph="none"
          headline="No webhooks configured"
          body="Configure a webhook URL to receive event notifications."
          primaryAction={
            <Button variant="primary" cy="webhooks-empty-create" onClick={() => setShowCreate(true)}>
              + Create Webhook
            </Button>
          }
        />
      ) : (
        <ul
          data-cy="webhooks-list"
          style={{
            listStyle: "none",
            padding: 0,
            margin: 0,
            display: "flex",
            flexDirection: "column",
            gap: "0.75rem",
          }}
        >
          {webhooks.map((hook) => (
            <li key={hook.id}>
              <Card cy="webhook-row" cyId={hook.id}>
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "flex-start",
                    flexWrap: "wrap",
                    gap: "0.75rem",
                  }}
                >
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div
                      data-cy="webhook-url"
                      style={{
                        fontFamily: "var(--font-mono, monospace)",
                        fontSize: "0.875rem",
                        wordBreak: "break-all",
                        marginBottom: "0.5rem",
                      }}
                    >
                      {hook.url}
                    </div>
                    <div style={{ display: "flex", gap: "0.35rem", flexWrap: "wrap" }}>
                      {hook.events.map((ev) => (
                        <span
                          key={ev}
                          data-cy="webhook-event-badge"
                          className="sg-pill sg-pill--sm"
                        >
                          {ev}
                        </span>
                      ))}
                    </div>
                  </div>
                  <div
                    style={{
                      display: "flex",
                      gap: "0.5rem",
                      alignItems: "center",
                      flexShrink: 0,
                      flexWrap: "wrap",
                    }}
                  >
                    <span
                      data-cy="webhook-enabled-status"
                      className={`sg-pill sg-pill--sm ${hook.enabled ? "eval-pass" : ""}`}
                    >
                      {hook.enabled ? "enabled" : "disabled"}
                    </span>
                    <Button
                      variant="ghost"
                      size="sm"
                      cy="webhook-toggle-btn"
                      onClick={() => toggleEnabled(hook)}
                    >
                      {hook.enabled ? "Disable" : "Enable"}
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      cy="webhook-history-btn"
                      onClick={() => loadDeliveries(hook.id)}
                    >
                      {expandedId === hook.id ? "Hide history" : "History"}
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      cy="webhook-delete-btn"
                      onClick={() => handleDelete(hook.id)}
                    >
                      Delete
                    </Button>
                  </div>
                </div>

                {expandedId === hook.id && (
                  <div
                    data-cy="webhook-deliveries"
                    style={{
                      borderTop: "1px solid var(--border-default)",
                      paddingTop: "0.75rem",
                      marginTop: "0.75rem",
                    }}
                  >
                    {deliveryLoading === hook.id ? (
                      <LoadingSkeleton variant="row" count={3} />
                    ) : (deliveries[hook.id] ?? []).length === 0 ? (
                      <span data-cy="webhook-deliveries-empty" className="sg-muted-small">
                        No deliveries yet.
                      </span>
                    ) : (
                      <DeliveryTable
                        deliveries={deliveries[hook.id] ?? []}
                        retrying={retrying}
                        onRetry={(deliveryId) => retryDelivery(hook.id, deliveryId)}
                      />
                    )}
                  </div>
                )}
              </Card>
            </li>
          ))}
        </ul>
      )}

      {/* Create modal */}
      <Modal
        open={showCreate}
        onClose={() => setShowCreate(false)}
        title="New Webhook"
        cy="webhooks-create-modal"
        footer={
          <div style={{ display: "flex", gap: "0.5rem", justifyContent: "flex-end", width: "100%" }}>
            <Button variant="ghost" cy="webhooks-create-cancel" onClick={() => setShowCreate(false)}>
              Cancel
            </Button>
            <Button
              variant="primary"
              cy="webhooks-create-submit"
              loading={creating}
              disabled={!newUrl.trim() || newEvents.size === 0}
              onClick={(e) => handleCreate(e as unknown as React.FormEvent)}
            >
              Create
            </Button>
          </div>
        }
      >
        <form data-cy="webhooks-create-form" onSubmit={handleCreate}>
          <FormField label="URL" name="url" required>
            {(p) => (
              <TextInput
                {...p}
                cy="webhooks-url-input"
                type="url"
                placeholder="https://example.com/hook"
                value={newUrl}
                onChange={(e) => setNewUrl(e.target.value)}
                autoFocus
              />
            )}
          </FormField>

          <div className="sg-field" data-cy="field-events">
            <label className="sg-field-label">
              Events
              <span aria-hidden="true" style={{ color: "var(--eval-fail)", marginLeft: 4 }}>
                *
              </span>
            </label>
            <div
              data-cy="webhooks-events-checkboxes"
              style={{ display: "flex", flexWrap: "wrap", gap: "0.5rem" }}
            >
              {WEBHOOK_EVENTS.map((ev) => (
                <label
                  key={ev}
                  data-cy="webhooks-event-label"
                  {...cyAttrs({ cyValue: ev })}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: "0.35rem",
                    fontSize: "0.875rem",
                    cursor: "pointer",
                  }}
                >
                  <input
                    type="checkbox"
                    data-cy="webhooks-event-checkbox"
                    checked={newEvents.has(ev)}
                    onChange={() => toggleEvent(ev)}
                  />
                  {ev}
                </label>
              ))}
            </div>
          </div>

          <div
            className="sg-field"
            style={{ display: "flex", alignItems: "center", gap: "0.5rem" }}
          >
            <input
              id="wh-enabled"
              type="checkbox"
              data-cy="webhooks-enabled-toggle"
              checked={newEnabled}
              onChange={(e) => setNewEnabled(e.target.checked)}
            />
            <label htmlFor="wh-enabled" style={{ fontSize: "0.875rem" }}>
              Enabled
            </label>
          </div>
        </form>
      </Modal>
    </div>
  );
}
