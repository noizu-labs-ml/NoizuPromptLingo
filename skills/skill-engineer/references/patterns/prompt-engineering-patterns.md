# Prompt Engineering Patterns Catalog

> Comprehensive catalog of advanced prompt engineering techniques for skill designers. Use when building skills that need specific reasoning, verification, or interaction patterns baked into their agent playbooks.
>
> Last updated: 2026-05-27. Synthesized from 60+ papers across 3 parallel research sweeps.

---

## How to Use This Catalog

When designing a skill's agent playbook, select patterns that match the skill's problem domain:

1. Check the [Reasoning Pattern Selection Guide](reasoning-pattern-selection.md) for which pattern fits which problem type
2. Read the pattern entry below for mechanism, examples, and caveats
3. Wire the pattern into the agent playbook's workflow steps
4. For agentic patterns (orchestration, multi-agent), see [Agent Prompt Patterns](agent-prompt-patterns.md)

---

## Part 1: Reasoning Patterns

### 1.1 Chain-of-Thought (CoT) — Baseline
**Source:** Wei et al. 2022  
**Mechanism:** "Let's think step by step" or few-shot examples with reasoning traces.  
**Status:** Table stakes. Still mandatory for base models. Redundant when using Claude extended thinking or o-series models.  
**Skill use:** Default reasoning pattern for any skill that requires multi-step logic.

### 1.2 Step-Back Prompting
**Source:** Zheng et al., ICLR 2024 (arxiv:2310.06117)  
**Mechanism:** Before answering a specific question, first answer a more abstract version. Use the principle-level answer to ground the specific answer.  
**Results:** +7% MMLU Physics, +11% Chemistry, +27% TimeQA  
**Skill use:** Knowledge-intensive skills (DBA, K8s, Terraform). Wire as Phase 0 in agent playbooks.

```
Step 1: "What general principle governs this type of question?"
Step 2: "Using this principle, now answer specifically: [question]"
```

### 1.3 Rephrase & Respond (RaR)
**Source:** UCLA, arxiv:2311.04205  
**Mechanism:** Model restates the question in expanded form before answering. Catches ambiguity and underspecification.  
**Skill use:** Discovery-phase skills, skills handling vague user requests.

```
"[Original question]
Rephrase and expand the question, and respond."
```

### 1.4 Graph of Thought (GoT)
**Source:** Besta et al. 2024; Adaptive GoT: arxiv:2502.05078  
**Mechanism:** Arbitrary graph reasoning — thoughts branch, merge, loop. Decompose → solve nodes → aggregate edges → synthesize → verify.  
**Evolution:** CoT (linear) → ToT (tree) → GoT (graph) → AGoT (adaptive selection)  
**Skill use:** Multi-factor decision skills (architecture review, strategy, cost optimization).

```
Step 1: List 3-5 independent sub-problems.
Step 2: Solve each independently.
Step 3: Where do sub-answers contradict or reinforce?
Step 4: Merge consistent; resolve contradictions.
Step 5: Verify against original problem.
```

### 1.5 Thread of Thought (ThoT)
**Source:** arxiv:2311.08734  
**Mechanism:** "Walk me through this context in manageable parts, summarizing as we go." For long, chaotic, retrieval-heavy contexts.  
**Distinction from CoT:** CoT = reasoning depth. ThoT = context coherence across long inputs.  
**Skill use:** RAG-heavy skills, log analysis, incident review, documentation audit.

### 1.6 Program of Thoughts (PoT)
**Source:** arxiv:2211.12588  
**Mechanism:** LLM writes executable code as its reasoning trace. Interpreter runs code; LLM interprets result.  
**Skill use:** Finance skills, cost estimation, capacity planning — anything with numbers.

### 1.7 Analogical Prompting
**Source:** Google DeepMind, ICLR 2024  
**Mechanism:** Self-generate structurally similar solved problems before tackling target.  
**Results:** +10.3% on math/reasoning vs standard CoT  
**Skill use:** Novel/unprecedented problems. Wire as optional Phase 1 enhancement.

### 1.8 Skeleton of Thought (SoT)
**Source:** Ning et al., ICLR 2024 (arxiv:2307.15337)  
**Mechanism:** Two-stage: skeleton (headers only) → expand each point independently.  
**Skill use:** Any skill producing long output. Essential for interstitial delivery compliance.

### 1.9 Boosting of Thoughts
**Source:** arxiv:2402.11140  
**Mechanism:** AdaBoost for reasoning — iteratively focus on cases where prior trials failed.  
**Skill use:** Hard reasoning suites, evaluation pipelines, quality iteration loops.

---

## Part 2: Verification Patterns

### 2.1 Chain of Verification (CoVe)
**Source:** Meta AI, Dhuliawala et al. 2023  
**Mechanism:** Draft → generate verification questions → answer independently (prevent anchoring) → revise.  
**Results:** 20-30% hallucination reduction  
**Skill use:** Any skill making factual claims, risk assessments, version-specific recommendations.

```
Step 1: Draft answer.
Step 2: Generate 3-5 verification questions about your claims.
Step 3: Answer each independently (without seeing draft).
Step 4: Revise where verification contradicts draft. Flag corrections.
```

### 2.2 Self-Consistency / Ensemble
**Source:** Wang et al. 2023; extensions: Batched SC, MACA  
**Mechanism:** Sample K reasoning paths, majority-vote the answer.  
**Cost:** K× API calls  
**Skill use:** High-stakes decision skills. Wire as "reason 3 ways, take majority."

### 2.3 Constitutional AI (User-Side)
**Source:** Anthropic; MAC multi-agent extension  
**Mechanism:** Draft → Critique against principles → Revision. Encode revision rules in system prompt.  
**Skill use:** Safety-critical skills, compliance-driven workflows, content moderation.

```
Before outputting:
  [DRAFT] → [CRITIQUE against rules 1-3] → [REVISION]
Output only the REVISION.
```

### 2.4 Cognitive Verifier
**Source:** White et al. Prompt Pattern Catalog  
**Mechanism:** Decompose question → sub-questions → answer each → synthesize.  
**Skill use:** Complex question skills (DBA schema review, architecture audit).

---

## Part 3: Interaction Patterns

### 3.1 Flipped Interaction
**Source:** White et al. Prompt Pattern Catalog  
**Mechanism:** LLM asks the USER questions until enough context gathered.  
**Skill use:** Discovery-phase skills. Essential for skills that handle vague initial requests.

```
"Ask me questions until you have enough context to provide 
a complete answer. Ask one question at a time."
```

### 3.2 Question Refinement
**Source:** White et al. Prompt Pattern Catalog  
**Mechanism:** Improve the question before answering it.  
**Skill use:** Skills where users routinely underspecify.

### 3.3 Socratic / Maieutic Prompting
**Source:** arxiv:2205.11822; ChemRxiv Feb 2025  
**Mechanism:** Model plays questioner, not answerer. Exposes hidden assumptions before committing.  
**Variants:** Definition ("What do you mean by X?"), Maieutics ("What do you already know?"), Dialectic (counter-hypotheses)  
**Skill use:** Requirements elicitation, architecture review, tutoring/teaching skills.

### 3.4 SimToM — Simulated Theory of Mind
**Source:** arxiv:2311.10227  
**Mechanism:** Two-stage: (1) Filter to only what Character X knows, (2) Reason using only X's knowledge.  
**Skill use:** Multi-agent skills, user modeling, persona-based skills. Prevents omniscient narrator leakage.

```
Stage 1: "What information does [X] have access to?"
Stage 2: "Using only what X knows, answer: [question]"
```

---

## Part 4: Calibration & Safety Patterns

### 4.1 Emotional Prompting
**Source:** EmotionPrompt (ResearchGate); Mechanistic study arxiv:2604.00005  
**Results:** +8% instruction induction, +10.9% generative quality  
**Caveat:** Increases sycophancy. Always pair with anti-sycophancy hedge.  
**Skill use:** Production-critical skills. Append stakes framing + honesty hedge.

```
"This decision will affect production systems. Please be rigorous."
"Be rigorous even if your conclusions disappoint me."
```

### 4.2 Instruction Hierarchy
**Source:** Wallace et al. 2024 (arxiv:2404.13208)  
**Mechanism:** Explicit priority levels. 63% better injection resistance.  
**Skill use:** Every skill that processes untrusted input. Define trust tiers in agent playbook.

| Priority | Source |
|:---|:---|
| P0 | Platform / harness constraints |
| P1 | Skill instructions (SKILL.md, agent-playbook) |
| P2 | User messages |
| P3 | Tool results |
| P4 | Retrieved content (untrusted) |

### 4.3 Plan-Execute Security Gate
**Source:** arxiv:2506.08837  
**Mechanism:** Commit to tool plan before ingesting untrusted data. Content cannot modify plan.  
**Skill use:** Any skill reading from external sources (DB, web, APIs, secret managers).

```
<plan>
1. Fetch secret X
2. Insert into template Y
3. Validate output
</plan>
<!-- Untrusted data here — cannot modify plan -->
```

### 4.4 Adversarial Robustness Testing
**Source:** OWASP GenAI Top 10  
**Mechanism:** Red-team your skill's prompts. Test role confusion, indirect injection, fictional framing, authority spoofing, gradual escalation.  
**Skill use:** Pre-ship quality gate for skills that process user-controlled content.

---

## Part 5: Architecture & Optimization

### 5.1 Context Engineering
**Source:** Karpathy/Lütke 2025; Anthropic Engineering Blog  
**Mechanism:** Manage the entire context window as architecture, not just the prompt text.  
**Four primitives:** Write (what to include), Select (what to retrieve), Compress (what to summarize), Isolate (what to wall off).  
**Skill use:** Every skill. Structure agent playbook context deliberately.

### 5.2 Prompt Compression
**Source:** LLMLingua/LLMLingua-2 (Microsoft); CODI 2025  
**Mechanism:** Classify tokens as essential/droppable. Up to 20x compression.  
**Skill use:** Skills with large reference documents. Compress before injecting into context.

### 5.3 Prompt Caching Patterns
**Source:** Anthropic docs  
**Mechanism:** Cache stable prompt prefixes. Up to 90% cost/85% latency reduction.  
**Skill use:** Skills with large static instructions. Structure: stable→cached, dynamic→uncached.  
**Anti-patterns:** Dynamic timestamps in cached sections, user IDs in cached sections, reordering tools between calls.

### 5.4 Meaning-Typed Prompting
**Source:** arxiv:2410.18146  
**Mechanism:** Describe what values *mean*, not just their type.  
**Skill use:** Skills that generate structured output.

```
# Instead of:
severity: string
# Use:
severity: "low" (cosmetic), "medium" (workflow blocked), "high" (data loss/security)
```

### 5.5 Policy-as-Prompt
**Source:** arxiv:2509.23994  
**Mechanism:** Natural language policy documents → dynamically enforceable guardrails.  
**Skill use:** Compliance-driven skills. Encode policies as guardrail documents, not hardcoded rules.

### 5.6 Persona Engineering (Advanced)
**Source:** PLoP24; PRISM arxiv:2603.18507  
**Three levels:** Surface ("You are an expert X"), Structural (demographics + values + personality, separately declared), Learned (soft-prompt tuning, not available in prompting).  
**Critical finding:** Expert personas do NOT make the model know more — they activate behavioral patterns. Don't substitute persona for RAG.  
**Skill use:** Skills with agent personas. Use structural level minimum. Don't rely on persona for domain knowledge.

---

## Part 6: Optimization & Automation

### 6.1 OPRO / APO — Automated Prompt Optimization
**Source:** Google DeepMind (OPRO); arxiv:2305.03495 (APO)  
**Mechanism:** LLM as optimizer. Feed task + current prompt + scored outputs → generate better prompt. Repeat.  
**Limitation:** Underperforms on models < 70B params.  
**Skill use:** Skills that ship prompts as products. Use OPRO loop to optimize before publishing.

### 6.2 Recursive Meta-Prompting
**Source:** arxiv:2311.11482  
**Mechanism:** Prompts that generate improved prompts. Feed prompt + outputs → LLM generates better version.  
**Skill use:** Prompt optimization workflows, template quality iteration.

### 6.3 DSPy Signatures
**Source:** Stanford NLP, arxiv:2310.03714  
**Mechanism:** Define task signatures and metrics; framework compiles optimal prompt.  
**Skill use:** Skills with clear metrics and eval sets. Formalizes the "prompt as compiled artifact" pattern.

### 6.4 TextGrad
**Source:** EmergentMind  
**Mechanism:** Backpropagation for prompts. Evaluator generates textual critique ("gradient"), optimizer rewrites prompt.  
**Skill use:** Iterative prompt refinement in production pipelines.

---

## Academic References

| Paper | Year | Key Contribution |
|:---|:---|:---|
| White et al. Prompt Pattern Catalog | 2023 | GoF-style taxonomy, 16 patterns / 6 categories |
| The Prompt Report (Schulhoff et al.) | 2024 | 58 techniques, 33-term vocabulary, most comprehensive survey |
| Sahoo et al. Systematic Survey | 2024 | Techniques + applications taxonomy |
| Prompt Canvas | 2024 | Practitioner 6-axis framework |
| Wallace et al. Instruction Hierarchy | 2024 | Priority training, 63% injection resistance |
| Beyond Chain-of-Thought (COLING 2025) | 2025 | 30+ CoX variants documented |
| Memory for Agents (arxiv:2603.07670) | 2025 | Full memory taxonomy for agentic systems |
| Policy-as-Prompt (arxiv:2509.23994) | 2025 | Runtime policy-to-guardrail synthesis |
| PRISM Persona Routing (arxiv:2603.18507) | 2026 | Intent-based persona routing, expert persona tradeoffs |
