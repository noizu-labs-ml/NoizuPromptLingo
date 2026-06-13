---
id: P-004
name: "Dr. Kenji Tanaka"
slug: "dr-kenji-tanaka"
archetype: "Adversarial ML Researcher"
segment: "emerging"
tags: [academia, research, adversarial-ml, publication, catalog, community, disclosure]
---

# Dr. Kenji Tanaka — Adversarial ML Researcher

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 33–42 |
| **Role** | Assistant Professor / Research Scientist |
| **Technical Level** | Expert |
| **Industry** | Academia / AI Safety Research |
| **Location** | Tokyo, Boston, or London |

## Bio

Kenji is an assistant professor at a research university whose work sits at the intersection of adversarial machine learning and AI safety. He published some of the early foundational work on adversarial examples in vision models and has pivoted toward LLM robustness over the past three years. He runs a lab with five PhD students, collaborates with two AI labs under NDA, and is under constant pressure to publish at NeurIPS and ICML while also maintaining a responsible disclosure posture that doesn't get him in trouble with university counsel or model vendors. He cares deeply about rigor and reproducibility.

## Goals

1. Access a canonical, peer-reviewed-quality taxonomy of jailbreak techniques that he can reference and build on in published work without having to justify the classification system from scratch.
2. Contribute his lab's findings to a community knowledge base under a responsible disclosure framework that gives him publication credit while protecting against misuse.
3. Use structured technique data to run reproducible experiments across multiple model families and track how mitigations evolve over time.

## Frustrations

1. There is no authoritative, citable taxonomy for LLM jailbreaks — every paper defines its own categories, making systematic literature reviews and meta-analyses nearly impossible.
2. Responsible disclosure is a minefield: disclosure timelines, vendor communication, and embargo periods are all ad hoc and inconsistent across the industry.
3. Industry practitioners are finding techniques his lab hasn't published yet and he has no visibility into what's already known, leading to wasted research effort on already-catalogued vulnerabilities.

## Behaviors

- Reads arXiv daily (cs.CR, cs.LG), tracks the Anthropic/OpenAI/DeepMind research blogs, and monitors LLM security Twitter closely.
- Runs systematic experiments using HuggingFace models and maintains a structured dataset of attack/defense pairs for reproducibility.
- Cites MITRE ATT&CK in grant proposals as the gold-standard example of community-maintained adversarial knowledge; would love an equivalent for LLMs.
- Engages in academic peer review and serves on program committees at ML and security venues.

## Job to Be Done

> "When I'm designing an experiment to evaluate jailbreak mitigations across model families, I want to pull a structured, versioned dataset of known techniques with behavioral classifications, so I can run reproducible benchmarks and publish results that the community can build on."

## Relationship to Product

Kenji discovers the platform via a citation in a paper or a mention at NeurIPS. He engages primarily with the Catalog as a research artifact and the Community for responsible disclosure. He's not a paying customer in the traditional sense — his value is credibility and contributions. He's the kind of user who, if he cites the Catalog in a paper, drives 50 signups. Churn risk is high if the taxonomy is perceived as unscientific or if the disclosure process is poorly defined.

## Scenarios

1. **Reproducible benchmarking** — Kenji downloads a versioned snapshot of the Catalog via API, filters for techniques with empirical reproduction evidence, and uses the structured data to run a benchmark across GPT-4o, Claude 3, and Llama 3 for a NeurIPS submission.
2. **Responsible disclosure** — His PhD student discovers a novel multi-modal jailbreak. Kenji uses the Community disclosure portal to file a structured report with the affected vendors under a 90-day embargo, receives a confirmation with a CVE-equivalent ID, and coordinates publication timing with vendor patch deployment.
