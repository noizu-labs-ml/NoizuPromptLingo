# Reasoning Pattern Selection Guide

> Decision matrix for choosing which prompt engineering pattern to wire into a skill's agent playbook. Match the problem type to the pattern.

---

## The Selection Matrix

| Problem Type | Pattern | When to Use | Cost | Source |
|:---|:---|:---|:---|:---|
| **Ambiguous request** | Rephrase & Respond | User underspecified; restate before answering | Low | arxiv:2311.04205 |
| **Novel / no precedent** | Analogical Prompting | Self-generate similar solved problems first | Medium | DeepMind ICLR 2024 |
| **Long chaotic context** | Thread of Thought | Walk through context in parts, summarize as you go | Low | arxiv:2311.08734 |
| **Math / computation** | Program of Thoughts | Write code to compute, don't do arithmetic in prose | Medium | arxiv:2211.12588 |
| **Multi-factor decision** | Graph of Thought | Branch, solve independently, merge, resolve contradictions | High | arxiv:2502.05078 |
| **Factual claims** | Chain of Verification | Draft → verify → revise | High | Meta AI 2023 |
| **Knowledge-intensive** | Step-Back Prompting | Abstract to principle first, then answer specifically | Low | ICLR 2024 |
| **Requirements unclear** | Flipped Interaction | Ask the USER questions until enough context | Low | White et al. 2023 |
| **Critical decision** | Self-Consistency | Reason 3 ways, take the majority answer | K× calls | Wang et al. 2023 |
| **Multi-agent perspective** | SimToM | Filter to only what each agent/user *knows*, reason from their POV | Medium | arxiv:2311.10227 |
| **Long output needed** | Skeleton of Thought | Outline first, expand incrementally | Low | ICLR 2024 |
| **Safety-critical** | Constitutional AI (user-side) | Draft → Critique → Revision against principles | 2-3× tokens | Anthropic |
| **Untrusted data** | Plan-Execute Security | Commit to tool plan before ingesting data | Low | arxiv:2506.08837 |
| **Teaching / elicitation** | Socratic / Maieutic | Ask clarifying questions to expose assumptions | Medium | arxiv:2205.11822 |

---

## Composability Rules

Patterns are composable. Common stacks:

### For Infrastructure Skills (K8s, Terraform, Helm)
```
Step-Back Prompting (Phase 0)
  → Assumption Table (Phase 1)
  → CoVe for factual claims (Phase 2.5)
  → GoT for multi-factor decisions (Phase 3)
```

### For Discovery/Requirements Skills
```
Flipped Interaction (gather context)
  → RaR (clarify the question)
  → Cognitive Verifier (decompose into sub-questions)
  → SoT for long output
```

### For Safety-Critical Skills
```
Plan-Execute Security Gate (before untrusted data)
  → Constitutional AI (Draft → Critique → Revise)
  → CoVe (verify factual claims)
  → Instruction Hierarchy (trust tiers)
```

### For Analytical/Strategy Skills
```
Step-Back (abstract to principle)
  → Analogical Prompting (find parallel cases)
  → GoT (multi-factor analysis)
  → Self-Consistency (reason 3 ways, take majority)
```

### For RAG-Heavy Skills
```
Thread of Thought (coherence across long context)
  → CoVe (verify against sources)
  → Meaning-Typed Prompting (structured extraction)
```

---

## Anti-Patterns

| Don't Do This | Why | Instead |
|:---|:---|:---|
| Stack all patterns on every request | Token bloat, latency, diminishing returns | Match pattern to problem type |
| Use CoT with extended thinking models | Redundant — model already reasons internally | Skip explicit CoT prompting |
| Self-Consistency on simple lookups | K× cost for marginal gain | Reserve for high-stakes decisions |
| Persona for domain knowledge | Personas activate behavior, not knowledge | Use RAG or retrieval |
| GoT on linear problems | Unnecessary complexity | Use standard CoT |
| Emotional prompting without anti-sycophancy hedge | Increases thoroughness but also sycophancy | Always pair with honesty hedge |

---

## Pattern Discovery for New Skills

When designing a new skill, walk this checklist:

1. **What does the user typically provide?** → If vague: RaR or Flipped Interaction
2. **What does the skill need to reason about?** → If multi-factor: GoT. If sequential: CoT. If numerical: PoT.
3. **What could go wrong if the output is wrong?** → If high stakes: CoVe + Self-Consistency. If safety-critical: Constitutional + Plan-Execute.
4. **How long is the typical output?** → If long: SoT for interstitial delivery.
5. **Does the skill process untrusted input?** → If yes: Plan-Execute Security + Instruction Hierarchy.
6. **Does the skill involve multiple perspectives?** → If yes: SimToM or Socratic.
