"use client";

import { use, useEffect, useState, useCallback } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import {
  api,
  type Rubric,
  type RubricVersion,
  type ScaleConfig,
  type ScaleMethod,
  type ScaleLadderRow,
  type RubricCriterion,
  type Prompt,
  type PreviewResult,
} from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  Button,
  Card,
  DataTable,
  FormField,
  LoadingSkeleton,
  PageHeader,
  Select,
  StatusPill,
  TextArea,
  TextInput,
  toast,
  type DataTableColumn,
} from "@/components/ui";

// ─── Sub-components ──────────────────────────────────────────────────────────

function ScaleEditor({
  scale,
  onChange,
}: {
  scale: ScaleConfig;
  onChange: (s: ScaleConfig) => void;
}) {
  const METHOD_OPTIONS: ScaleMethod[] = ["continuous", "discrete", "ladder", "enum"];

  function updateMethod(method: ScaleMethod) {
    if (method === "continuous" || method === "discrete") {
      onChange({ method, min: scale.min ?? 0, max: scale.max ?? 1, type: scale.type ?? "float" });
    } else {
      onChange({ method, ladder: scale.ladder ?? [{ label: "", score: 0 }] });
    }
  }

  function addRow() {
    const rows = scale.ladder ?? [];
    onChange({ ...scale, ladder: [...rows, { label: "", score: 0 }] });
  }

  function updateRow(idx: number, field: keyof ScaleLadderRow, value: string) {
    const rows = (scale.ladder ?? []).map((r, i) =>
      i === idx
        ? { ...r, [field]: field === "score" ? parseFloat(value) || 0 : value }
        : r,
    );
    onChange({ ...scale, ladder: rows });
  }

  function removeRow(idx: number) {
    const rows = (scale.ladder ?? []).filter((_, i) => i !== idx);
    onChange({ ...scale, ladder: rows });
  }

  return (
    <div
      data-cy="scale-editor"
      className="sg-stack-sm"
    >
      <FormField label="Scale Method" name="scale-method">
        {(p) => (
          <Select
            {...p}
            cy="scale-method-select"
            value={scale.method}
            onChange={(e) => updateMethod(e.target.value as ScaleMethod)}
            options={METHOD_OPTIONS.map((m) => ({ value: m, label: m }))}
          />
        )}
      </FormField>

      {(scale.method === "continuous" || scale.method === "discrete") && (
        <div className="sg-form-row">
          <FormField label="Min" name="scale-min">
            {(p) => (
              <TextInput
                {...p}
                cy="scale-min"
                type="number"
                step="any"
                value={scale.min ?? 0}
                onChange={(e) => onChange({ ...scale, min: parseFloat(e.target.value) })}
              />
            )}
          </FormField>
          <FormField label="Max" name="scale-max">
            {(p) => (
              <TextInput
                {...p}
                cy="scale-max"
                type="number"
                step="any"
                value={scale.max ?? 1}
                onChange={(e) => onChange({ ...scale, max: parseFloat(e.target.value) })}
              />
            )}
          </FormField>
          <FormField label="Type" name="scale-type">
            {(p) => (
              <Select
                {...p}
                cy="scale-type"
                value={scale.type ?? "float"}
                onChange={(e) => onChange({ ...scale, type: e.target.value })}
                options={[
                  { value: "float", label: "float" },
                  { value: "int", label: "int" },
                  { value: "percent", label: "percent" },
                ]}
              />
            )}
          </FormField>
        </div>
      )}

      {(scale.method === "ladder" || scale.method === "enum") && (
        <div data-cy="scale-rows">
          <label className="sg-field-label">
            {scale.method === "enum" ? "Options" : "Ladder Rungs"}
          </label>
          {(scale.ladder ?? []).map((row, idx) => (
            <div
              key={idx}
              data-cy="scale-row"
              style={{
                display: "flex",
                gap: "var(--space-2)",
                marginBottom: "var(--space-2)",
                alignItems: "center",
              }}
            >
              <TextInput
                cy="scale-row-label"
                type="text"
                placeholder="Label"
                value={row.label}
                onChange={(e) => updateRow(idx, "label", e.target.value)}
                style={{ flex: 2 }}
              />
              <TextInput
                cy="scale-row-score"
                type="number"
                step="any"
                placeholder="Score"
                value={row.score}
                onChange={(e) => updateRow(idx, "score", e.target.value)}
                style={{ flex: 1 }}
              />
              <Button
                type="button"
                variant="ghost"
                size="sm"
                cy="scale-row-remove"
                onClick={() => removeRow(idx)}
              >
                ×
              </Button>
            </div>
          ))}
          <Button
            type="button"
            variant="ghost"
            size="sm"
            cy="scale-row-add"
            onClick={addRow}
          >
            + Add row
          </Button>
        </div>
      )}
    </div>
  );
}

function CriteriaEditor({
  criteria,
  onChange,
}: {
  criteria: RubricCriterion[];
  onChange: (c: RubricCriterion[]) => void;
}) {
  function addCriterion() {
    onChange([...criteria, { name: "", weight: 1, direction: "maximize" }]);
  }

  function update(idx: number, field: keyof RubricCriterion, value: string | number) {
    const next = criteria.map((c, i) => (i === idx ? { ...c, [field]: value } : c));
    onChange(next);
  }

  function remove(idx: number) {
    onChange(criteria.filter((_, i) => i !== idx));
  }

  return (
    <div data-cy="criteria-editor">
      <label className="sg-field-label">Criteria</label>
      {criteria.map((c, idx) => (
        <div
          key={idx}
          data-cy="criterion-row"
          style={{
            display: "flex",
            gap: "var(--space-2)",
            marginBottom: "var(--space-2)",
            alignItems: "center",
          }}
        >
          <TextInput
            cy="criterion-name"
            type="text"
            placeholder="Criterion name"
            value={c.name}
            onChange={(e) => update(idx, "name", e.target.value)}
            style={{ flex: 3 }}
          />
          <TextInput
            cy="criterion-weight"
            type="number"
            min="0"
            max="1"
            step="0.01"
            placeholder="Weight"
            value={c.weight}
            onChange={(e) => update(idx, "weight", parseFloat(e.target.value))}
            style={{ flex: 1 }}
          />
          <Select
            cy="criterion-direction"
            value={c.direction}
            onChange={(e) => update(idx, "direction", e.target.value as "maximize" | "minimize")}
            options={[
              { value: "maximize", label: "maximize" },
              { value: "minimize", label: "minimize" },
            ]}
            style={{ flex: 1 }}
          />
          <Button
            type="button"
            variant="ghost"
            size="sm"
            cy="criterion-remove"
            onClick={() => remove(idx)}
          >
            ×
          </Button>
        </div>
      ))}
      <Button
        type="button"
        variant="ghost"
        size="sm"
        cy="criterion-add"
        onClick={addCriterion}
      >
        + Add criterion
      </Button>
    </div>
  );
}

// ─── Main Page ────────────────────────────────────────────────────────────────

export default function RubricDetailPage({
  params,
}: {
  params: Promise<{ orgId: string; rubricId: string }>;
}) {
  const { orgId, rubricId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [rubric, setRubric] = useState<Rubric | null>(null);
  const [versions, setVersions] = useState<
    Array<Pick<RubricVersion, "id" | "version_number" | "checksum" | "published_at">>
  >([]);
  const [loading, setLoading] = useState(true);

  // Editor state
  const [scale, setScale] = useState<ScaleConfig>({ method: "continuous", min: 0, max: 1, type: "float" });
  const [criteria, setCriteria] = useState<RubricCriterion[]>([]);
  const [judgeModel, setJudgeModel] = useState("");
  const [judgePromptVersionId, setJudgePromptVersionId] = useState("");
  const [nSamples, setNSamples] = useState(1);
  const [publishing, setPublishing] = useState(false);

  // Prompt selector
  const [prompts, setPrompts] = useState<Prompt[]>([]);

  // Preview state
  const [sampleInput, setSampleInput] = useState("");
  const [sampleResponse, setSampleResponse] = useState("");
  const [previewing, setPreviewing] = useState(false);
  const [previewResult, setPreviewResult] = useState<PreviewResult | null>(null);

  const loadRubric = useCallback(async () => {
    try {
      const res = await api.getRubric(orgId, rubricId);
      setRubric(res.rubric);
      setVersions(res.versions);
      if (res.current_version) {
        const v = res.current_version;
        setScale(v.scale);
        setCriteria(v.criteria);
        setJudgeModel(v.judge_model ?? "");
        setJudgePromptVersionId(v.judge_prompt_version_id ?? "");
        setNSamples(v.n_samples);
      }
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to load rubric");
    } finally {
      setLoading(false);
    }
  }, [orgId, rubricId]);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    loadRubric();
    api
      .listPrompts(orgId)
      .then((res) => setPrompts(res.prompts))
      .catch(() => {});
  }, [user, authLoading, router, orgId, rubricId, loadRubric]);

  async function handlePublish() {
    setPublishing(true);
    try {
      await api.publishRubricVersion(
        orgId,
        rubricId,
        scale,
        criteria,
        judgeModel || null,
        judgePromptVersionId || null,
        nSamples,
      );
      toast.success("Version published");
      await loadRubric();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to publish");
    } finally {
      setPublishing(false);
    }
  }

  async function handlePreview() {
    if (!sampleInput.trim() || !sampleResponse.trim()) {
      toast.warning("Provide sample input and response to preview");
      return;
    }
    setPreviewing(true);
    setPreviewResult(null);
    try {
      const res = await api.previewRubric(orgId, rubricId, sampleInput, sampleResponse);
      setPreviewResult(res);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Preview failed");
    } finally {
      setPreviewing(false);
    }
  }

  if (authLoading || loading) {
    return (
      <div data-cy="app-loading" style={{ padding: "2rem 0" }}>
        <LoadingSkeleton variant="row" count={4} />
      </div>
    );
  }

  if (!rubric) return null;

  const publishedPrompts = prompts.filter((p) => p.current_version_id);
  const promptOptions = [
    { value: "", label: "— none —" },
    ...publishedPrompts.map((p) => ({
      value: p.current_version_id!,
      label: `${p.name} (v${p.current_version_id?.slice(0, 6)}…)`,
    })),
  ];

  const versionColumns: DataTableColumn<
    Pick<RubricVersion, "id" | "version_number" | "checksum" | "published_at">
  >[] = [
    {
      key: "version_number",
      label: "Version",
      width: 80,
      render: (v) => (
        <span data-cy="version-row" {...cyAttrs({ cyId: v.version_number })}>
          <strong>v{v.version_number}</strong>
        </span>
      ),
    },
    {
      key: "checksum",
      label: "Checksum",
      render: (v) => (
        <code style={{ fontSize: "var(--text-caption)", color: "var(--text-tertiary)" }}>
          {v.checksum.slice(0, 8)}
        </code>
      ),
    },
    {
      key: "published_at",
      label: "Published",
      render: (v) =>
        v.published_at ? (
          <span
            data-cy="version-published-at"
            style={{ color: "var(--text-tertiary)", fontSize: "var(--text-small)" }}
          >
            {new Date(v.published_at).toLocaleDateString()}
          </span>
        ) : null,
    },
  ];

  return (
    <div data-cy="rubric-detail-page" {...cyAttrs({ cyScope: "rubric-detail" })}>
      <PageHeader
        title={<span data-cy="rubric-name">{rubric.name}</span>}
        subtitle={
          rubric.description ? (
            <span data-cy="rubric-description">{rubric.description}</span>
          ) : undefined
        }
        breadcrumbs={[
          { label: "library", href: `/app/${orgId}` },
          { label: "rubrics", href: `/app/${orgId}/rubrics` },
          { label: rubric.slug, current: true },
        ]}
        actions={
          <Button
            variant="primary"
            cy="rubric-publish-btn"
            loading={publishing}
            onClick={handlePublish}
          >
            Publish Version
          </Button>
        }
      />

      <div className="sg-detail-grid">
        {/* Metadata aside */}
        <aside className="sg-detail-aside">
          <Card>
            <h3 className="sg-meta-label">Slug</h3>
            <p className="sg-meta-value sg-meta-value--mono">{rubric.slug}</p>
          </Card>

          <Card>
            <h3 className="sg-meta-label">Status</h3>
            <div className="sg-chip-row">
              {rubric.current_version_id ? (
                <StatusPill
                  state="pass"
                  label="published"
                  size="sm"
                  cy="rubric-published-badge"
                />
              ) : (
                <StatusPill state="pending" label="draft" size="sm" />
              )}
              <span
                className="sg-pill sg-pill--sm"
                data-cy="rubric-version-count"
              >
                {versions.length} version{versions.length !== 1 ? "s" : ""}
              </span>
            </div>
          </Card>

          {versions.length > 0 && (
            <Card data-cy="rubric-versions-section">
              <h3 className="sg-meta-label">Version History</h3>
              <DataTable<Pick<RubricVersion, "id" | "version_number" | "checksum" | "published_at">>
                columns={versionColumns}
                rows={versions}
                rowKey={(v) => v.id}
                compact
                cy="rubric-versions-table"
              />
            </Card>
          )}
        </aside>

        {/* Main column */}
        <main className="sg-detail-main">
          <Card data-cy="rubric-editor" className="sg-form-section">
            <h2 className="sg-form-section__title">Scale</h2>
            <ScaleEditor scale={scale} onChange={setScale} />
          </Card>

          <Card data-cy="rubric-criteria-section" className="sg-form-section">
            <h2 className="sg-form-section__title">Criteria</h2>
            <CriteriaEditor criteria={criteria} onChange={setCriteria} />
          </Card>

          <Card data-cy="rubric-judge-section" className="sg-form-section">
            <h2 className="sg-form-section__title">Judge</h2>

            <FormField label="Judge Model" name="judge-model">
              {(p) => (
                <TextInput
                  {...p}
                  cy="judge-model-input"
                  type="text"
                  value={judgeModel}
                  onChange={(e) => setJudgeModel(e.target.value)}
                  placeholder="e.g. gpt-4o"
                />
              )}
            </FormField>

            <FormField
              label="Judge Prompt"
              name="judge-prompt"
              hint={
                publishedPrompts.length === 0
                  ? "No published prompts found. Publish a prompt first."
                  : undefined
              }
            >
              {(p) => (
                <Select
                  {...p}
                  cy="judge-prompt-select"
                  value={judgePromptVersionId}
                  onChange={(e) => setJudgePromptVersionId(e.target.value)}
                  options={promptOptions}
                />
              )}
            </FormField>

            <div>
              <label className="sg-field-label">
                Samples per run:{" "}
                <strong data-cy="n-samples-value">{nSamples}</strong>
                {nSamples > 3 && (
                  <span
                    data-cy="n-samples-cost-warning"
                    style={{
                      marginLeft: "var(--space-2)",
                      color: "var(--eval-warn)",
                      fontSize: "var(--text-small)",
                    }}
                  >
                    ⚠ High sample count increases cost
                  </span>
                )}
              </label>
              <input
                type="range"
                data-cy="n-samples-slider"
                min={1}
                max={10}
                step={1}
                value={nSamples}
                onChange={(e) => setNSamples(parseInt(e.target.value))}
                style={{ width: "100%" }}
              />
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  fontSize: "var(--text-caption)",
                  color: "var(--text-tertiary)",
                }}
              >
                <span>1</span>
                <span>10</span>
              </div>
            </div>
          </Card>

          <Card data-cy="rubric-preview-section" className="sg-form-section">
            <h2 className="sg-form-section__title">Preview Judge Prompt</h2>
            <FormField label="Sample Input" name="sample-input">
              {(p) => (
                <TextArea
                  {...p}
                  cy="preview-sample-input"
                  value={sampleInput}
                  onChange={(e) => setSampleInput(e.target.value)}
                  placeholder="Paste the user turn / scenario input…"
                  rows={3}
                />
              )}
            </FormField>
            <FormField label="Sample Response" name="sample-response">
              {(p) => (
                <TextArea
                  {...p}
                  cy="preview-sample-response"
                  value={sampleResponse}
                  onChange={(e) => setSampleResponse(e.target.value)}
                  placeholder="Paste the agent response to evaluate…"
                  rows={3}
                />
              )}
            </FormField>

            <div style={{ display: "flex", justifyContent: "flex-end" }}>
              <Button
                variant="ghost"
                cy="rubric-preview-btn"
                loading={previewing}
                onClick={handlePreview}
              >
                Preview
              </Button>
            </div>

            {previewResult && (
              <div data-cy="preview-result">
                <div
                  style={{
                    display: "flex",
                    gap: "var(--space-2)",
                    alignItems: "center",
                    marginBottom: "var(--space-2)",
                  }}
                >
                  <span
                    className="sg-pill sg-pill--sm"
                    data-cy="preview-mode-badge"
                  >
                    Mode: {previewResult.mode}
                  </span>
                  <span
                    style={{ fontSize: "var(--text-small)", color: "var(--text-tertiary)" }}
                    data-cy="preview-tokens"
                  >
                    ~{previewResult.estimated_tokens} tokens
                  </span>
                </div>
                <Card
                  data-cy="preview-rendered-prompt"
                  style={{
                    fontFamily: "var(--font-mono, monospace)",
                    fontSize: "var(--text-code)",
                    whiteSpace: "pre-wrap",
                    wordBreak: "break-word",
                    maxHeight: 360,
                    overflowY: "auto",
                  }}
                >
                  {previewResult.rendered_prompt}
                </Card>
              </div>
            )}
          </Card>
        </main>
      </div>
    </div>
  );
}
