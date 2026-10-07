---
name: prompt-engineer
description: >
  Author, audit, compress, restyle, and evaluate prompts — including Noizu Prompt
  Lingua (NPL) syntax — while tuning for model nuance and defending against
  prompt injection and poisoning. Use this skill when the user wants to write or
  structure a prompt, define an NPL agent/persona/service (NPL@ version markers,
  intuition pumps, npl-declaration), configure reasoning pumps, audit an
  existing prompt containing ⌜NPL@…⌝ or <npl-* > blocks, fetch minimal NPL
  syntax preambles via NPLLoad/NPLSpec, compress a prompt to a token budget,
  generate or score prompt variants, set up a versioned prompt-store (.prompt
  specs, best-version symlinks), adapt a prompt for a specific model or sampling
  configuration (temperature, thinking budget), or threat-model and harden a
  prompt against poisoned inputs and injection — even if they don't say "NPL"
  or "prompt engineering". Also trigger on: prompt lingua, LLMLingua,
  compactness, loss ledger, prompt eval, meta-prompt, prompt poisoning,
  indirect prompt injection, instruction hierarchy.
ch-description: >
  编写、审计、压缩、重样式化与评估提示词（含 Noizu Prompt Lingua 语法），针对模型差异进行调优，
  并防御提示词注入与投毒。适用于令牌预算、提示词变体、版本化提示词库、NPL 语法前导、
  模型超参数适配及提示词威胁建模。
---

# Prompt Engineer

Single skill for the full prompt lifecycle: **author → audit → compress/restyle → evaluate → tune → harden**, with first-class Noizu Prompt Lingua (NPL) support and a vendored research corpus (arXiv-grade papers with page-anchored digests) backing its security and optimization guidance.

## Overview

- **Author** prompts from natural-language intent — freeform or formal NPL@1.0 syntax — assembling the minimal syntax preamble a target system needs (via the NPL MCP service: `NPLLoad`/`NPLSpec`).
- **Audit** existing prompts (freeform, `<npl-*>` blocks, `⌜NPL@…⌝` fenced) for structural and semantic correctness; fix in place.
- **Compress and restyle** prompts against explicit token budgets on a 0–5 compactness scale, ledgering every dropped fact, and transforming between equivalent-behavior formats (YAML meta-prompt, NPL element set, checklist, pointer-index, shorthand).
- **Evaluate** prompt variants against an eval corpus (rubric + dataset), promoting the best via the `.prompt` file-mode convention (spec file, variants dir, best-eval symlink/pin).
- **Tune for the target model** — prompt-shape preferences, sampling hyperparameters, and reasoning/thinking budgets differ per model family; adapt rather than assume.
- **Harden against adversarial input** — threat-model the prompt surface, recognize injection and poisoning patterns, and apply layered defenses drawn from the vendored research corpus.

## Core Philosophy

1. **Behavior is the invariant.** Compression, restyling, and tuning may change everything except required behavior; every transformation is checked against the declared requirements.
2. **Loss is ledgered, never silent.** Anything dropped or weakened during compression is recorded — what, why, and where it can be recovered.
3. **Variants are measured, not preferred.** Taste loses to the eval corpus; the best-eval variant is promoted, and the baseline is retained forever.
4. **Structure beats cleverness.** Deliberate syntax (NPL families, delimiters, instruction hierarchy) is the primary defense against ambiguity and injection alike.
5. **Claims cite the corpus.** Security and optimization recommendations point at the vendored papers with page anchors, not folklore.

## When to Use

- **Author an NPL prompt or agent/service definition** — persona, tools, reasoning pumps (`npl-intent`, `npl-cot`, `npl-ref`), placeholders, in-fill, directives, prefixes.
- **Audit or repair an existing prompt** — NPL blocks, malformed preambles, drifted conventions.
- **Hit a token budget** — compress a system prompt, CLAUDE.md, or agent definition with a loss ledger.
- **Restyle a prompt** — same behavior, different format (compact, YAML meta-prompt, NPL element set, …).
- **Build a prompt store** — `.prompt` spec, variants dir, eval scoring, best-version symlink/pin.
- **Adapt a prompt across models** — restructure for a different model family, set sampling hyperparameters, map thinking budgets.
- **Threat-model or harden** — prompt injection, indirect injection via retrieved content, poisoned inputs, jailbreak surface; pick defenses (delimiting/spotlighting, instruction hierarchy, filtering) with citations.

## Quick Start Guides

### Write an NPL prompt from scratch
1. Check NPL MCP availability (`NPLLoad`/`NPLSpec`); degrade to [references/npl/npl-syntax-reference.md](references/npl/npl-syntax-reference.md) if absent.
2. Load only the syntax families the prompt needs (preamble pattern in [references/npl/npl-mcp-loading.md](references/npl/npl-mcp-loading.md)).
3. Draft with [assets/npl-prompt-template.md](assets/npl-prompt-template.md); validate against [references/npl/prompt-construction-patterns.md](references/npl/prompt-construction-patterns.md).
4. Walkthrough: [references/npl/worked-example-support-triage.md](references/npl/worked-example-support-triage.md).

### Compress to a token budget
1. Fix axes: `compactness` (0–5), `token_budget`, `protect`, `lossy_ok` — scale card: [assets/compactness-scale.md](assets/compactness-scale.md).
2. Pick methods from [references/optimize/compression-methods.md](references/optimize/compression-methods.md).
3. Produce variant + loss ledger per the file-mode convention: [references/optimize/file-mode-convention.md](references/optimize/file-mode-convention.md).
4. Walkthrough: [references/optimize/worked-example-claude-md.md](references/optimize/worked-example-claude-md.md).

### Score variants and promote the best
1. Write the spec: [assets/prompt-spec-template.md.prompt](assets/prompt-spec-template.md.prompt) (eval rules + dataset).
2. Generate variants; score per [references/optimize/eval-and-scoring.md](references/optimize/eval-and-scoring.md).
3. Record per-variant meta: [assets/variant-meta-template.md](assets/variant-meta-template.md); promote via symlink/pin.

### Adapt a prompt to a target model
1. Check family guidance in [references/model-nuance.md](references/model-nuance.md) (prompt shape, system-role placement, delimiters).
2. Set sampling hyperparameters and thinking budget from the same reference.
3. Re-run the eval corpus — model changes invalidate prior scores.

### Harden a prompt against injection/poisoning
1. Threat-model the prompt surface: direct/indirect injection, poisoned retrieved content, tool-result smuggling — corpus index: [references/security/index.md](references/security/index.md).
2. Apply layered defenses (instruction hierarchy, delimiting/spotlighting, output filtering) with page-anchored citations from the digest notes.
3. Add adversarial cases to the eval dataset so the hardening is regression-tested.

## Reference Guide

| Task | Read |
|------|------|
| NPL syntax (all eight families) | [references/npl/npl-syntax-reference.md](references/npl/npl-syntax-reference.md) |
| NPL preamble fetching, expression DSL | [references/npl/npl-mcp-loading.md](references/npl/npl-mcp-loading.md) |
| Intent → syntax mapping, sizing, anti-patterns | [references/npl/prompt-construction-patterns.md](references/npl/prompt-construction-patterns.md) |
| Compression method cards (LLMLingua family) | [references/optimize/compression-methods.md](references/optimize/compression-methods.md) |
| Restyle transforms (7 target styles) | [references/optimize/style-transforms.md](references/optimize/style-transforms.md) |
| `.prompt` spec / variants / symlink convention | [references/optimize/file-mode-convention.md](references/optimize/file-mode-convention.md) |
| Eval rubric + dataset design | [references/optimize/eval-and-scoring.md](references/optimize/eval-and-scoring.md) |
| NPL-specific compression integration | [references/optimize/npl-compression-integration.md](references/optimize/npl-compression-integration.md) |
| Prompt techniques catalog (31 techniques) | [references/prompt-engineering-patterns.md](references/prompt-engineering-patterns.md) |
| Per-model prompt shape + hyperparameters | [references/model-nuance.md](references/model-nuance.md) |
| Injection/poisoning/threat modeling papers | [references/security/index.md](references/security/index.md) |
| Optimization/ICL research papers | [references/research/index.md](references/research/index.md) |
| Execution workflows (agent role) | [references/agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) |

All reference paths are relative to this skill's root.

## Related Skills

- **skill-engineer** — builds and structures skills; hands prompt-variant tailoring here. If the deliverable is a skill module, go there.
- **skill-evaluator** — runs scenario/dialogue/exam evals *against skills*. This skill evaluates *prompts*.
- **agent-architect** — designs standalone agent definitions (.claude/agents). This skill authors the prompts/agent definitions in NPL or freeform; that skill handles harness-level agent design.
- **mcp-engineer** — builds MCP servers. This skill only *consumes* NPL MCP (`NPLLoad`/`NPLSpec`).
- **media-generator** — image/video generation prompts are out of scope except where the `.prompt` payload schema is shared.

## Bundled Resources

### Assets
- [npl-prompt-template.md](assets/npl-prompt-template.md) — fillable NPL prompt skeleton (preamble + body + thread example)
- [prompt-spec-template.md.prompt](assets/prompt-spec-template.md.prompt) — fillable `.prompt` spec (requirements, eval rules, dataset, axes)
- [variant-meta-template.md](assets/variant-meta-template.md) — per-variant loss ledger + eval scores
- [compactness-scale.md](assets/compactness-scale.md) — 0–5 compactness level card
- [project-tracker.md](assets/project-tracker.md) — run tracker

### Research corpus (vendored)
- `references/security/papers/` + digest notes + [index](references/security/index.md) — injection, poisoning, threat modeling, defenses
- `references/research/papers/` + digest notes + [index](references/research/index.md) — prompt engineering, compression, ICL sensitivity
- Every digest note cites claims by PDF page (`papers/<file>.pdf p.N`); cite digests at runtime, open PDFs for depth.
