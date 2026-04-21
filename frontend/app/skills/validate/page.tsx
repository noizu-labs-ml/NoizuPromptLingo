"use client";

import { useState } from "react";
import clsx from "clsx";
import {
  ShieldCheckIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  XCircleIcon,
  SparklesIcon,
  LightBulbIcon,
} from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type {
  SkillValidationResult,
  SkillValidationError,
  SkillEvaluationResult,
  SkillQualityScore,
} from "@/lib/api/types";
import { PageHeader } from "@/components/primitives/PageHeader";
import { Card } from "@/components/primitives/Card";

// ── Example template ──────────────────────────────────────────────────────

const EXAMPLE_SKILL = `---
name: my-skill
description: A concise description of what this skill does and when to use it.
allowed-tools: []
---

# My Skill

**One-sentence tagline describing what the skill does.**

---

## Overview

This skill accomplishes [specific outcome] by [method].

Use this skill when you need to [situation].

**Core Purpose:**
- [Purpose 1 — specific outcome]
- [Purpose 2 — specific outcome]

## When to Use This Skill

Use this skill:
- When you [situation 1] → [outcome]
- When you [situation 2] → [outcome]

## Common Mistakes to Avoid

| Mistake | Why It Fails | Prevention |
|---------|---|---|
| [Mistake 1] | [Impact] | [How to avoid] |
`;

type Mode = "validate" | "evaluate";

// ── Severity badge ────────────────────────────────────────────────────────

function SeverityBadge({ severity }: { severity: "error" | "warning" }) {
  return (
    <span
      className={clsx(
        "inline-flex items-center rounded px-1.5 py-0.5 text-[10px] font-semibold uppercase tracking-wide",
        severity === "error"
          ? "bg-red-500/10 text-red-500 border border-red-500/20"
          : "bg-yellow-500/10 text-yellow-500 border border-yellow-500/20"
      )}
    >
      {severity}
    </span>
  );
}

function IssueRow({ issue }: { issue: SkillValidationError }) {
  return (
    <li className="flex flex-col gap-0.5 py-2 border-b border-border last:border-0">
      <div className="flex items-center gap-2">
        <SeverityBadge severity={issue.severity} />
        <code className="text-xs text-muted font-mono">{issue.field}</code>
      </div>
      <p className="text-sm text-foreground pl-1">{issue.message}</p>
    </li>
  );
}

function ValidationIssues({ result }: { result: SkillValidationResult }) {
  const allIssues = [...result.errors, ...result.warnings];
  if (allIssues.length === 0) return null;
  return (
    <div className="rounded-lg border border-border bg-surface overflow-hidden">
      <div className="px-3 py-2 border-b border-border bg-surface-raised">
        <p className="text-xs font-semibold text-muted uppercase tracking-wide">
          Validation issues ({allIssues.length})
        </p>
      </div>
      <ul className="px-3 divide-y divide-border">
        {result.errors.map((e, i)   => <IssueRow key={`err-${i}`}  issue={e} />)}
        {result.warnings.map((w, i) => <IssueRow key={`warn-${i}`} issue={w} />)}
      </ul>
    </div>
  );
}

// ── Validate result panel ─────────────────────────────────────────────────

function ValidateResultPanel({ result }: { result: SkillValidationResult }) {
  return (
    <div className="flex flex-col gap-4">
      <div
        className={clsx(
          "flex items-center gap-3 rounded-lg p-4 border",
          result.valid
            ? "bg-green-500/10 border-green-500/20"
            : "bg-red-500/10 border-red-500/20"
        )}
      >
        {result.valid ? (
          <CheckCircleIcon className="h-6 w-6 text-green-500 shrink-0" />
        ) : (
          <XCircleIcon className="h-6 w-6 text-red-500 shrink-0" />
        )}
        <div>
          <p className={clsx("font-semibold", result.valid ? "text-green-500" : "text-red-500")}>
            {result.valid ? "Valid skill" : "Validation failed"}
          </p>
          <p className="text-xs text-muted">
            {result.errors.length} error{result.errors.length !== 1 ? "s" : ""},{" "}
            {result.warnings.length} warning{result.warnings.length !== 1 ? "s" : ""}
          </p>
        </div>
      </div>

      {result.valid && Object.keys(result.summary).length > 0 && (
        <div className="grid grid-cols-3 gap-2">
          {Object.entries(result.summary).map(([key, val]) => (
            <div
              key={key}
              className="rounded-md border border-border bg-surface-raised p-2 text-center"
            >
              <p className="text-xs text-muted truncate">{key.replace(/_/g, " ")}</p>
              <p className="text-sm font-semibold text-foreground mt-0.5">
                {String(val)}
              </p>
            </div>
          ))}
        </div>
      )}

      <ValidationIssues result={result} />
    </div>
  );
}

// ── Evaluate result panel ─────────────────────────────────────────────────

function scoreColor(score: number): { text: string; stroke: string; bg: string; border: string } {
  if (score >= 0.8) return { text: "text-green-500",  stroke: "stroke-green-500",  bg: "bg-green-500/10",  border: "border-green-500/20"  };
  if (score >= 0.5) return { text: "text-yellow-500", stroke: "stroke-yellow-500", bg: "bg-yellow-500/10", border: "border-yellow-500/20" };
  return              { text: "text-red-500",    stroke: "stroke-red-500",    bg: "bg-red-500/10",    border: "border-red-500/20"    };
}

function ScoreRing({ score, size = 96 }: { score: number; size?: number }) {
  const pct = Math.max(0, Math.min(1, score));
  const r = (size - 8) / 2;
  const c = 2 * Math.PI * r;
  const offset = c - pct * c;
  const colors = scoreColor(pct);
  return (
    <div className="relative shrink-0" style={{ width: size, height: size }}>
      <svg width={size} height={size} className="-rotate-90">
        <circle
          cx={size / 2} cy={size / 2} r={r}
          className="stroke-border fill-transparent"
          strokeWidth={6}
        />
        <circle
          cx={size / 2} cy={size / 2} r={r}
          className={clsx("fill-transparent transition-all duration-500", colors.stroke)}
          strokeWidth={6}
          strokeDasharray={c}
          strokeDashoffset={offset}
          strokeLinecap="round"
        />
      </svg>
      <div className="absolute inset-0 flex items-center justify-center">
        <span className={clsx("text-lg font-semibold", colors.text)}>
          {Math.round(pct * 100)}
          <span className="text-xs text-muted font-normal">%</span>
        </span>
      </div>
    </div>
  );
}

function DimensionCard({ dim }: { dim: SkillQualityScore }) {
  const colors = scoreColor(dim.score);
  return (
    <Card className={clsx("flex flex-col gap-2", colors.border)}>
      <div className="flex items-center justify-between gap-3">
        <h4 className="text-sm font-semibold text-foreground capitalize">{dim.dimension}</h4>
        <div className="flex items-center gap-2">
          <div className={clsx("text-sm font-semibold font-mono", colors.text)}>
            {Math.round(dim.score * 100)}%
          </div>
        </div>
      </div>
      <div className="h-1.5 rounded-full bg-surface-sunken overflow-hidden">
        <div
          className={clsx("h-full transition-all", colors.bg, "bg-current", colors.text)}
          style={{ width: `${Math.round(dim.score * 100)}%` }}
        />
      </div>
      {dim.notes.length > 0 ? (
        <ul className="mt-1 list-disc list-inside space-y-0.5 text-xs text-muted marker:text-subtle">
          {dim.notes.map((n, i) => <li key={i}>{n}</li>)}
        </ul>
      ) : (
        <p className="text-xs text-subtle italic">No notes.</p>
      )}
    </Card>
  );
}

function EvaluateResultPanel({ result }: { result: SkillEvaluationResult }) {
  return (
    <div className="flex flex-col gap-4">
      {/* Overall score banner */}
      <div className="flex items-center gap-4 rounded-lg border border-border bg-surface-raised p-4">
        <ScoreRing score={result.overall_score} />
        <div className="flex flex-col gap-0.5 min-w-0">
          <p className="text-xs font-semibold uppercase tracking-wide text-subtle">
            Overall quality
          </p>
          <p className={clsx("text-xl font-semibold", scoreColor(result.overall_score).text)}>
            {Math.round(result.overall_score * 100)} / 100
          </p>
          <p className="text-xs text-muted">
            {result.validation.valid
              ? "Schema is valid. Quality evaluated across heuristic dimensions."
              : `${result.validation.errors.length} validation error${result.validation.errors.length === 1 ? "" : "s"} detected — see below.`}
          </p>
        </div>
      </div>

      {/* Dimension grid */}
      {result.dimensions.length > 0 && (
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {result.dimensions.map((d) => (
            <DimensionCard key={d.dimension} dim={d} />
          ))}
        </div>
      )}

      {/* Suggestions */}
      {result.suggestions.length > 0 && (
        <div className="rounded-lg border border-border bg-surface overflow-hidden">
          <div className="px-3 py-2 border-b border-border bg-surface-raised flex items-center gap-2">
            <LightBulbIcon className="h-4 w-4 text-accent" />
            <p className="text-xs font-semibold text-muted uppercase tracking-wide">
              Suggestions ({result.suggestions.length})
            </p>
          </div>
          <ul className="px-4 py-2 divide-y divide-border">
            {result.suggestions.map((s, i) => (
              <li key={i} className="py-2 text-sm text-foreground">{s}</li>
            ))}
          </ul>
        </div>
      )}

      {/* Validation issues surface below */}
      <ValidationIssues result={result.validation} />
    </div>
  );
}

// ── Mode toggle ───────────────────────────────────────────────────────────

function ModeToggle({
  mode, onChange,
}: {
  mode: Mode;
  onChange: (m: Mode) => void;
}) {
  return (
    <div className="inline-flex rounded-md border border-border bg-surface p-0.5 text-xs">
      {(["validate", "evaluate"] as Mode[]).map((m) => {
        const active = m === mode;
        return (
          <button
            key={m}
            onClick={() => onChange(m)}
            className={clsx(
              "flex items-center gap-1.5 rounded px-3 py-1.5 font-medium transition-colors capitalize",
              active
                ? "bg-accent text-white"
                : "text-muted hover:text-foreground hover:bg-surface-raised"
            )}
          >
            {m === "validate"
              ? <ShieldCheckIcon className="h-3.5 w-3.5" />
              : <SparklesIcon className="h-3.5 w-3.5" />}
            {m}
          </button>
        );
      })}
    </div>
  );
}

// ── Page ──────────────────────────────────────────────────────────────────

export default function SkillValidatePage() {
  const [mode, setMode] = useState<Mode>("validate");
  const [content, setContent] = useState("");
  const [filename, setFilename] = useState("");
  const [loading, setLoading] = useState(false);
  const [validateResult, setValidateResult] = useState<SkillValidationResult | null>(null);
  const [evaluateResult, setEvaluateResult] = useState<SkillEvaluationResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit() {
    if (!content.trim()) return;
    setLoading(true);
    setError(null);
    try {
      if (mode === "validate") {
        setValidateResult(null);
        const res = await api.skills.validate(content, filename || undefined);
        setValidateResult(res);
      } else {
        setEvaluateResult(null);
        const res = await api.skills.evaluate(content, filename || undefined);
        setEvaluateResult(res);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : `${mode} request failed.`);
    } finally {
      setLoading(false);
    }
  }

  function handleLoadExample() {
    setContent(EXAMPLE_SKILL);
    setFilename("my-skill.md");
    setValidateResult(null);
    setEvaluateResult(null);
    setError(null);
  }

  const activeResult = mode === "validate" ? validateResult : evaluateResult;
  const submitLabel =
    loading
      ? (mode === "validate" ? "Validating…" : "Evaluating…")
      : (mode === "validate" ? "Validate" : "Evaluate");

  return (
    <div className="flex flex-col gap-6 p-6 max-w-6xl mx-auto">
      <PageHeader
        title="Skill Validator"
        description="Check schema validity or evaluate overall quality of a skill file."
        actions={
          <div className="flex items-center gap-2">
            <ModeToggle mode={mode} onChange={setMode} />
            <button
              onClick={handleLoadExample}
              className="text-xs rounded-md border border-border px-3 py-1.5 text-muted hover:text-foreground hover:bg-surface-raised transition-colors"
            >
              Load example
            </button>
          </div>
        }
      />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Left: input */}
        <div className="flex flex-col gap-3">
          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium text-muted uppercase tracking-wide">
              Filename <span className="normal-case font-normal">(optional, for name cross-check)</span>
            </label>
            <input
              type="text"
              value={filename}
              onChange={(e) => setFilename(e.target.value)}
              placeholder="e.g. my-skill.md"
              className="rounded-md border border-border bg-surface px-3 py-1.5 text-sm text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/40"
            />
          </div>

          <div className="flex flex-col gap-1 flex-1">
            <label className="text-xs font-medium text-muted uppercase tracking-wide">
              Skill content
            </label>
            <textarea
              rows={24}
              value={content}
              onChange={(e) => setContent(e.target.value)}
              placeholder={"---\nname: my-skill\ndescription: ...\n---\n\n# My Skill\n\n..."}
              className="font-mono text-xs rounded-md border border-border bg-surface px-3 py-2 text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/40 resize-y w-full"
            />
          </div>

          <button
            onClick={handleSubmit}
            disabled={loading || !content.trim()}
            className={clsx(
              "flex items-center justify-center gap-2 rounded-md px-4 py-2 text-sm font-medium transition-colors",
              loading || !content.trim()
                ? "bg-surface-raised text-subtle cursor-not-allowed"
                : "bg-accent text-white hover:bg-accent/90"
            )}
          >
            {mode === "validate"
              ? <ShieldCheckIcon className="h-4 w-4" />
              : <SparklesIcon className="h-4 w-4" />}
            {submitLabel}
          </button>
        </div>

        {/* Right: result */}
        <div className="flex flex-col gap-3">
          <p className="text-xs font-medium text-muted uppercase tracking-wide">
            {mode === "validate" ? "Validation Result" : "Evaluation Result"}
          </p>

          {!activeResult && !error && !loading && (
            <div className="flex flex-col items-center justify-center rounded-lg border border-dashed border-border p-12 text-center">
              {mode === "validate"
                ? <ShieldCheckIcon className="h-8 w-8 text-subtle mb-2" />
                : <SparklesIcon    className="h-8 w-8 text-subtle mb-2" />}
              <p className="text-sm text-muted">
                Paste a skill file on the left and click {mode === "validate" ? "Validate" : "Evaluate"}.
              </p>
              <p className="text-xs text-subtle mt-1">Or use &ldquo;Load example&rdquo; to try a sample.</p>
            </div>
          )}

          {loading && (
            <div className="flex items-center justify-center p-12">
              <div className="h-6 w-6 rounded-full border-2 border-accent border-t-transparent animate-spin" />
            </div>
          )}

          {error && (
            <div className="flex items-start gap-2 rounded-lg border border-red-500/20 bg-red-500/10 p-4">
              <ExclamationTriangleIcon className="h-4 w-4 text-red-500 shrink-0 mt-0.5" />
              <p className="text-sm text-red-500">{error}</p>
            </div>
          )}

          {mode === "validate" && validateResult && <ValidateResultPanel result={validateResult} />}
          {mode === "evaluate" && evaluateResult && <EvaluateResultPanel result={evaluateResult} />}
        </div>
      </div>
    </div>
  );
}
