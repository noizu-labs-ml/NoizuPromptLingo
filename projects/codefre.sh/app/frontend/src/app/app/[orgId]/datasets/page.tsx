"use client";

import { use, useEffect, useState, useCallback } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api, type Dataset, type Capture, type CaptureStatus } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  PageHeader,
  Button,
  EmptyState,
  LoadingSkeleton,
  DataTable,
  type DataTableColumn,
  Modal,
  FormField,
  TextInput,
  Select,
} from "@/components/ui";

type ActiveTab = "datasets" | "captures";
const CAPTURE_STATUS_OPTS: CaptureStatus[] = ["pending", "reviewed", "promoted"];

export default function DatasetsPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [tab, setTab] = useState<ActiveTab>("datasets");

  // Datasets state
  const [datasets, setDatasets] = useState<Dataset[]>([]);
  const [dsLoading, setDsLoading] = useState(true);
  const [dsError, setDsError] = useState<string | null>(null);
  const [showCreate, setShowCreate] = useState(false);
  const [newName, setNewName] = useState("");
  const [newDesc, setNewDesc] = useState("");
  const [creating, setCreating] = useState(false);
  const [publishing, setPublishing] = useState<string | null>(null);

  // Captures state
  const [captures, setCaptures] = useState<Capture[]>([]);
  const [capLoading, setCapLoading] = useState(false);
  const [capError, setCapError] = useState<string | null>(null);
  const [capFilter, setCapFilter] = useState<CaptureStatus | "">("");
  const [promoting, setPromoting] = useState<string | null>(null);
  const [promoteTarget, setPromoteTarget] = useState<string>("");

  const loadDatasets = useCallback(() => {
    setDsLoading(true);
    api
      .listDatasets(orgId)
      .then((res) => setDatasets(res.datasets ?? []))
      .catch((e) => {
        const msg = e instanceof Error ? e.message : "failed to load";
        if (!msg.includes("404")) setDsError(msg);
      })
      .finally(() => setDsLoading(false));
  }, [orgId]);

  const loadCaptures = useCallback(() => {
    setCapLoading(true);
    api
      .listCaptures(orgId, capFilter ? { status: capFilter } : {})
      .then((res) => setCaptures(res.captures ?? []))
      .catch((e) => {
        const msg = e instanceof Error ? e.message : "failed to load";
        if (!msg.includes("404")) setCapError(msg);
      })
      .finally(() => setCapLoading(false));
  }, [orgId, capFilter]);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;
    loadDatasets();
  }, [user, authLoading, router, loadDatasets]);

  useEffect(() => {
    if (!user) return;
    if (tab === "captures") loadCaptures();
  }, [tab, user, loadCaptures]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!newName.trim()) return;
    setCreating(true);
    try {
      const res = await api.createDataset(orgId, newName.trim(), newDesc.trim() || undefined);
      setDatasets((prev) => [res.dataset, ...prev]);
      setNewName("");
      setNewDesc("");
      setShowCreate(false);
    } catch (e) {
      setDsError(e instanceof Error ? e.message : "create failed");
    } finally {
      setCreating(false);
    }
  }

  async function handlePublish(datasetId: string) {
    setPublishing(datasetId);
    try {
      await api.publishDatasetVersion(orgId, datasetId);
      loadDatasets();
    } catch (e) {
      setDsError(e instanceof Error ? e.message : "publish failed");
    } finally {
      setPublishing(null);
    }
  }

  async function handlePromote(captureId: string) {
    if (!promoteTarget) return;
    setPromoting(captureId);
    try {
      await api.promoteCapture(orgId, captureId, promoteTarget);
      loadCaptures();
    } catch (e) {
      setCapError(e instanceof Error ? e.message : "promote failed");
    } finally {
      setPromoting(null);
    }
  }

  if (authLoading) {
    return (
      <div data-cy="app-loading" className="sg-app-loading">
        Loading…
      </div>
    );
  }

  const datasetColumns: DataTableColumn<Dataset>[] = [
    {
      key: "name",
      label: "Name",
      render: (ds) => (
        <div>
          <strong data-cy="dataset-name">{ds.name}</strong>
          {ds.current_version_id && (
            <span
              className="sg-pill sg-pill--sm eval-pass"
              data-cy="dataset-has-version"
              style={{ marginLeft: "0.5rem" }}
            >
              published
            </span>
          )}
        </div>
      ),
    },
    {
      key: "description",
      label: "Description",
      render: (ds) => (
        <span
          data-cy="dataset-description"
          style={{ fontSize: "0.85rem", color: "var(--text-secondary)" }}
        >
          {ds.description ?? "—"}
        </span>
      ),
    },
    {
      key: "actions",
      label: "",
      width: 200,
      render: (ds) => (
        <div
          style={{ display: "flex", justifyContent: "flex-end" }}
          onClick={(e) => e.stopPropagation()}
        >
          <Button
            variant="ghost"
            size="sm"
            cy="dataset-publish-btn"
            cyId={ds.id}
            loading={publishing === ds.id}
            onClick={() => handlePublish(ds.id)}
          >
            Publish version
          </Button>
        </div>
      ),
    },
  ];

  const captureColumns: DataTableColumn<Capture>[] = [
    {
      key: "run_id",
      label: "Run",
      render: (cap) => (
        <span
          data-cy="capture-run-id"
          className="sg-mono"
          style={{ fontSize: "0.85rem" }}
        >
          {cap.run_id.slice(0, 8)}
        </span>
      ),
    },
    {
      key: "status",
      label: "Status",
      render: (cap) => (
        <span
          data-cy="capture-status"
          style={{ fontSize: "0.85rem", color: "var(--text-secondary)" }}
        >
          {cap.status}
        </span>
      ),
    },
    {
      key: "actions",
      label: "",
      width: 140,
      render: (cap) =>
        cap.status !== "promoted" ? (
          <div
            style={{ display: "flex", justifyContent: "flex-end" }}
            onClick={(e) => e.stopPropagation()}
          >
            <Button
              variant="ghost"
              size="sm"
              cy="capture-promote-btn"
              cyId={cap.id}
              disabled={!promoteTarget}
              loading={promoting === cap.id}
              onClick={() => handlePromote(cap.id)}
            >
              Promote
            </Button>
          </div>
        ) : null,
    },
  ];

  return (
    <div data-cy="datasets-page" {...cyAttrs({ cyScope: "datasets" })}>
      <PageHeader
        title="Datasets"
        subtitle="Curated evaluation sets. Promote captures from runs into versioned datasets."
        actions={
          tab === "datasets" ? (
            <Button variant="primary" cy="datasets-new-btn" onClick={() => setShowCreate(true)}>
              + New Dataset
            </Button>
          ) : undefined
        }
      />

      {/* Tabs */}
      <div
        data-cy="datasets-tabs"
        role="tablist"
        style={{
          display: "flex",
          borderBottom: "2px solid var(--border-default)",
          marginBottom: "1.5rem",
        }}
      >
        {(["datasets", "captures"] as ActiveTab[]).map((t) => (
          <button
            key={t}
            role="tab"
            aria-selected={tab === t}
            data-cy="datasets-tab"
            {...cyAttrs({ cyValue: t })}
            onClick={() => setTab(t)}
            style={{
              background: "none",
              border: "none",
              padding: "0.6rem 1.25rem",
              cursor: "pointer",
              fontWeight: tab === t ? 600 : 400,
              borderBottom: tab === t ? "2px solid var(--accent)" : "2px solid transparent",
              marginBottom: -2,
              color: tab === t ? "var(--accent)" : "inherit",
              textTransform: "capitalize",
            }}
          >
            {t}
          </button>
        ))}
      </div>

      {/* Datasets tab */}
      {tab === "datasets" && (
        <div data-cy="datasets-list-panel">
          {dsError && (
            <p className="sg-error" data-cy="datasets-error">
              {dsError}
            </p>
          )}
          {dsLoading ? (
            <LoadingSkeleton variant="row" count={5} />
          ) : datasets.length === 0 ? (
            <EmptyState
              glyph="datasets"
              headline="No datasets yet"
              body="Create a dataset to aggregate promoted captures into a versioned evaluation set."
              primaryAction={
                <Button
                  variant="primary"
                  cy="datasets-empty-create"
                  onClick={() => setShowCreate(true)}
                >
                  + Create Dataset
                </Button>
              }
            />
          ) : (
            <DataTable<Dataset>
              cy="datasets-list"
              columns={datasetColumns}
              rows={datasets}
              rowKey={(ds) => ds.id}
            />
          )}
        </div>
      )}

      {/* Captures tab */}
      {tab === "captures" && (
        <div data-cy="captures-panel">
          <div
            style={{
              display: "flex",
              gap: "0.5rem",
              flexWrap: "wrap",
              marginBottom: "1rem",
              alignItems: "center",
            }}
          >
            <Button
              variant={capFilter === "" ? "primary" : "ghost"}
              size="sm"
              cy="capture-filter-all"
              onClick={() => setCapFilter("")}
            >
              All
            </Button>
            {CAPTURE_STATUS_OPTS.map((s) => (
              <Button
                key={s}
                variant={capFilter === s ? "primary" : "ghost"}
                size="sm"
                cy="capture-filter-status"
                cyValue={s}
                onClick={() => setCapFilter(s)}
              >
                {s}
              </Button>
            ))}
          </div>

          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "0.5rem",
              marginBottom: "0.75rem",
            }}
          >
            <label
              htmlFor="promote-dataset"
              style={{ fontSize: "0.875rem", color: "var(--text-secondary)" }}
            >
              Promote to dataset:
            </label>
            <Select
              id="promote-dataset"
              cy="captures-dataset-select"
              value={promoteTarget}
              onChange={(e) => setPromoteTarget(e.target.value)}
              style={{ width: 240 }}
            >
              <option value="">— select dataset —</option>
              {datasets.map((ds) => (
                <option key={ds.id} value={ds.id}>
                  {ds.name}
                </option>
              ))}
            </Select>
          </div>

          {capError && (
            <p className="sg-error" data-cy="captures-error">
              {capError}
            </p>
          )}

          {capLoading ? (
            <LoadingSkeleton variant="row" count={5} />
          ) : captures.length === 0 ? (
            <EmptyState
              glyph="search"
              headline="No flagged captures"
              body="Captures from runs appear here for promotion into datasets."
            />
          ) : (
            <DataTable<Capture>
              cy="captures-list"
              columns={captureColumns}
              rows={captures}
              rowKey={(c) => c.id}
            />
          )}
        </div>
      )}

      {/* Create dataset modal */}
      <Modal
        open={showCreate}
        onClose={() => setShowCreate(false)}
        title="New Dataset"
        cy="datasets-create-modal"
        footer={
          <div style={{ display: "flex", gap: "0.5rem", justifyContent: "flex-end", width: "100%" }}>
            <Button variant="ghost" cy="datasets-create-cancel" onClick={() => setShowCreate(false)}>
              Cancel
            </Button>
            <Button
              variant="primary"
              cy="datasets-create-submit"
              loading={creating}
              disabled={!newName.trim()}
              onClick={(e) => handleCreate(e as unknown as React.FormEvent)}
            >
              Create
            </Button>
          </div>
        }
      >
        <form data-cy="datasets-create-form" onSubmit={handleCreate}>
          <FormField label="Name" name="name" required>
            {(p) => (
              <TextInput
                {...p}
                cy="datasets-name-input"
                placeholder="Dataset name"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                autoFocus
              />
            )}
          </FormField>
          <FormField label="Description" name="description">
            {(p) => (
              <TextInput
                {...p}
                cy="datasets-desc-input"
                placeholder="Optional description"
                value={newDesc}
                onChange={(e) => setNewDesc(e.target.value)}
              />
            )}
          </FormField>
        </form>
      </Modal>
    </div>
  );
}
