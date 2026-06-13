# Worked Example: Debugging Production Kubernetes

> End-to-end walkthrough of creating a tutorial article — from topic selection through full outline, draft excerpt, SEO metadata, platform publishing checklist, and projected metrics.

---

## 1. Topic Selection Rationale

### Why This Topic

**Discovery source:** r/kubernetes — recurring pattern of posts asking "my pods keep crashing and I can't figure out why" combined with keyword research showing strong search volume.

**Topic selection criteria:**

| Criterion | Score | Evidence |
|-----------|-------|---------|
| Search demand | High | "kubernetes debugging" = 8,100/mo; "kubectl debug pod" = 2,400/mo |
| Competition quality | Medium | Top results are official K8s docs (thorough but dense) and 2-3 blog posts (outdated, generic) |
| Content gap | Clear | No article combines a systematic workflow with real examples and modern tooling (2025+) |
| Authority signal | Strong | Writing from production experience signals credibility |
| Evergreen potential | High | K8s debugging fundamentals don't change with versions |
| Cross-sell fit | Yes | Natural bridge to a "K8s Debugging Prompt Kit" template product |

**Competitive gap analysis:**

| Existing Article | Weakness | Our Advantage |
|---|---|---|
| Kubernetes.io debugging docs | Comprehensive but dry, no workflow | Systematic workflow with decision tree |
| "How to Debug K8s" (Datadog blog) | Focuses on their tooling, vendor-locked | Tool-agnostic, works with any setup |
| "K8s Troubleshooting Guide" (Medium, 2023) | Outdated, misses ephemeral containers, modern tools | Current (2026), includes latest features |
| DigitalOcean tutorial | Good but surface-level, happy-path only | Covers real-world failure modes, not just theory |

---

## 2. Full Outline

### Structure Pattern: Problem-Agitate-Solve (PAS)

```
Title: Debugging Production Kubernetes: A Systematic Approach

Target length: 2,500-3,000 words
Reading time: 12-15 minutes
Primary keyword: "debugging kubernetes production"
Secondary keywords: "kubectl debug", "kubernetes troubleshooting", "pod crash loop"

OUTLINE:

1. HOOK (Problem) — 150 words
   - Open with a specific incident: "It's 2 AM. PagerDuty is screaming..."
   - Establish the pain: ad-hoc debugging wastes time under pressure
   - Promise: a systematic approach you can follow half-awake

2. WHY AD-HOC DEBUGGING FAILS (Agitate) — 300 words
   - The typical approach: kubectl logs → Google → Stack Overflow → panic
   - Why this wastes time: no systematic narrowing, same mistakes repeated
   - Cost of slow debugging: downtime * revenue/minute = real money

3. THE 5-STEP DEBUGGING FRAMEWORK (Solve — main content) — 1,800 words

   3.1. Step 1: Triage — What Layer Is Broken? — 400 words
        - Decision tree: cluster → node → pod → container → application
        - Quick commands for each layer
        - How to determine scope (one pod vs many, one node vs many)
        - Example: "All pods on node-3 are failing" → node-level issue

   3.2. Step 2: Gather — Collect Without Interpreting — 300 words
        - The 3 data sources: events, logs, resource status
        - kubectl commands for each (with actual output examples)
        - Common mistake: jumping to conclusions before gathering

   3.3. Step 3: Hypothesize — Narrowing Down — 300 words
        - Pattern matching: CrashLoopBackOff, OOMKilled, ImagePullBackOff, etc.
        - Each pattern → most likely cause → verification command
        - Table: "If you see X, check Y first"

   3.4. Step 4: Verify — Test Your Hypothesis — 400 words
        - Using ephemeral debug containers (kubectl debug)
        - Port-forwarding for network issues
        - Resource inspection (requests vs limits vs actual usage)
        - Example: suspecting OOM → verifying with memory metrics

   3.5. Step 5: Fix and Prevent — 400 words
        - The fix vs the proper fix vs the prevention
        - Example: restart the pod (fix) → increase memory limit (proper fix) →
          add resource quotas and monitoring (prevention)
        - Creating a runbook from the incident

4. REAL-WORLD EXAMPLE: THE MYSTERY OF THE SLOW PODS — 400 words
   - Walkthrough of an actual debugging session using the 5 steps
   - Pods slow but not crashing → CPU throttling → misconfigured limits
   - Show the commands and output at each step

5. TOOLS I ACTUALLY USE — 200 words
   - k9s, kubectl debug, stern (multi-pod log tailing), kubectx
   - Brief mention, not a tools comparison article

6. CONCLUSION + CTA — 150 words
   - Summary of the 5-step approach
   - "Bookmark this for your next 2 AM incident"
   - CTA: "For weekly Kubernetes insights, subscribe to [newsletter]"
   - Cross-sell (footnote): "I packaged my most-used debugging workflows into
     a prompt kit: [link]"
```

---

## 3. Draft Excerpt

### Introduction + Step 1 (First ~600 words)

---

**Debugging Production Kubernetes: A Systematic Approach**

It's 2 AM. PagerDuty is screaming. Three pods in your payment service are in CrashLoopBackOff, and the on-call Slack channel is filling up with "is payments down?" messages.

You open your terminal and type `kubectl logs payment-service-7f9d8c-x4k2n`. Nothing obvious. You Google the error. Stack Overflow has a 4-year-old answer about a different version. You try random things. Twenty minutes pass. The CEO posts in Slack.

This is ad-hoc debugging, and it fails for the same reason ad-hoc anything fails: under pressure, your brain takes shortcuts, skips steps, and circles back to the same dead ends.

Here's the systematic approach I use instead. It works at 2 AM. It works when you're calm. It works whether you've managed Kubernetes for a week or a decade.

### Why Ad-Hoc Debugging Costs You

The typical debugging session looks like this:

1. See alert → `kubectl logs` → nothing useful
2. Google the error message → outdated answers
3. Try 3-4 random things → maybe one works
4. Not sure what fixed it → can't prevent recurrence

Average time to resolution: 45 minutes.

With a systematic approach, average time to resolution: 15 minutes. On a service processing $1,000/minute, that's a $30,000 difference per incident.

More importantly, systematic debugging produces understanding. You know *what* broke, *why* it broke, and *how to prevent it*. Ad-hoc debugging produces relief and a lingering anxiety that it'll happen again.

### The 5-Step Framework

```
TRIAGE → GATHER → HYPOTHESIZE → VERIFY → FIX
```

Every debugging session follows these five steps. Even when you think you know the answer, run through them in order. The step you skip is the one that would have revealed the actual problem.

### Step 1: Triage — What Layer Is Broken?

Before touching anything, determine the scope. Kubernetes has layers, and each layer has different failure modes:

```
CLUSTER (control plane, etcd, API server)
  └── NODE (kubelet, container runtime, OS)
       └── POD (scheduling, networking, volumes)
            └── CONTAINER (image, runtime, resources)
                 └── APPLICATION (code, config, dependencies)
```

**Quick triage:**

```bash
# Cluster health — is the control plane responsive?
kubectl cluster-info
kubectl get nodes

# Node health — are all nodes Ready?
kubectl get nodes -o wide
# Look for NotReady, MemoryPressure, DiskPressure

# Pod scope — is it one pod or many?
kubectl get pods -n <namespace> | grep -v Running
# If ALL pods on one node are failing → node issue
# If all replicas of one service → pod/container/app issue
# If one random pod → likely application issue
```

**The 30-second decision tree:**

| Observation | Layer | Next Step |
|---|---|---|
| `kubectl cluster-info` times out | Cluster | Check API server, etcd |
| Multiple nodes NotReady | Cluster/Node | Check cloud provider, network |
| One node NotReady | Node | SSH to node, check kubelet |
| All pods of service failing | Pod/Container | `kubectl describe pod` |
| One pod failing, replicas healthy | Application | `kubectl logs` the failing pod |
| Pods running but slow/erroring | Application | Exec into pod, check resources |

**Example:** You see that 3 out of 5 `payment-service` pods are in CrashLoopBackOff, but the other 2 are Running. The 3 failing pods are all on `node-3`, which shows `MemoryPressure`. Diagnosis: this is a **node-level** issue (node-3 is running out of memory), not an application issue. Don't waste time reading application logs — evict other pods from node-3 or add capacity.

*[Article continues with Steps 2-5, real-world example, and tools section...]*

---

## 4. SEO Metadata

### Primary Target

| Element | Value |
|---------|-------|
| **Primary keyword** | "debugging kubernetes production" |
| **Secondary keywords** | "kubectl debug", "kubernetes troubleshooting", "pod crashloopbackoff" |
| **Title tag** | Debugging Production Kubernetes: A Systematic 5-Step Approach |
| **Meta description** | A systematic 5-step framework for debugging Kubernetes in production. From triage to prevention, with real commands and real examples. Stop guessing at 2 AM. |
| **URL slug** | `/debugging-production-kubernetes` |
| **Canonical URL** | Your Substack/blog (primary), cross-post to Dev.to/Medium |

### Internal Linking Plan

- Link TO this article from: any future K8s article, DevOps content
- Link FROM this article to: tools I use (if separate article exists), related K8s articles
- Cross-reference: "K8s Debugging Prompt Kit" product (footnote CTA)

---

## 5. Platform Publishing Checklist

### Dev.to (Primary Discovery)

- [ ] Title: "Debugging Production Kubernetes: A Systematic Approach"
- [ ] Tags (max 4): `kubernetes`, `devops`, `debugging`, `tutorial`
- [ ] Cover image: Dark background with terminal-style text (Canva template)
- [ ] Canonical URL: Set to your blog/Substack
- [ ] Series: Consider "Kubernetes in Production" series
- [ ] Publishing time: Tuesday or Wednesday, 8-10 AM EST
- [ ] Add "Discuss" section at the end to encourage comments

### Substack (Primary Home)

- [ ] Send as newsletter issue to all subscribers
- [ ] Subject line: "The 5-step framework I use to debug K8s at 2 AM"
- [ ] Preview text: "Stop guessing. Start diagnosing."
- [ ] Newsletter CTA: "Share with your on-call team"
- [ ] Cross-sell footnote: K8s Debugging Prompt Kit

### Medium (Cross-post)

- [ ] Canonical URL set to primary
- [ ] Tags: Kubernetes, DevOps, Debugging, Software Engineering, Docker
- [ ] Subtitle: "A systematic framework for diagnosing production issues"
- [ ] Add to relevant publications (Better Programming, ITNEXT, etc.)

### Reddit (Promotion — NOT self-promotion)

- [ ] r/kubernetes: Share as a genuine helpful post (not a link to your site — post the content directly, link in comments if asked)
- [ ] r/devops: Same approach
- [ ] Timing: Thursday or Friday (active discussion days on tech subreddits)
- [ ] **CRITICAL:** Do NOT post "I wrote a blog post." Post "Here's a debugging framework I use" with the content inline. Link if asked.

### LinkedIn

- [ ] Reformat key points as a LinkedIn post (not just a link)
- [ ] First line hook: "I've debugged Kubernetes at 2 AM more times than I can count. Here's the 5-step framework that keeps me sane."
- [ ] Include the decision tree table
- [ ] Link to full article at the end
- [ ] Tag relevant DevOps connections

---

## 6. Projected Metrics

### Week 1

| Metric | Projection | Basis |
|--------|-----------|-------|
| Dev.to views | 500-2,000 | Average for well-tagged K8s article |
| Dev.to reactions | 20-80 | ~4% of views |
| Substack opens | 40-50% of list | Technical newsletter benchmark |
| Medium views | 100-500 | Cross-post, lower priority |
| Reddit upvotes | 10-100 | Highly variable, depends on subreddit mood |
| Newsletter signups | 5-20 | From Dev.to + Reddit readers |

### Month 1

| Metric | Projection | Basis |
|--------|-----------|-------|
| Total views (all platforms) | 2,000-8,000 | Compounding from SEO + social |
| Newsletter signups from this article | 20-80 | 1-2% of readers |
| Template product click-throughs | 10-40 | From footnote CTA |
| Template purchases from this article | 1-5 | 10-15% of click-throughs |

### Month 6 (SEO Compounding)

| Metric | Projection | Basis |
|--------|-----------|-------|
| Monthly organic views | 500-2,000 | Ranking for long-tail K8s debugging queries |
| Monthly newsletter signups | 5-15 (passive) | From organic traffic |
| Monthly template purchases | 2-5 (passive) | Ongoing footnote conversions |

### Evergreen ROI

Time invested: ~8 hours (writing, editing, publishing, promoting)
Expected Year 1 total views: 10,000-30,000
Expected Year 1 newsletter signups: 100-300
Expected Year 1 template revenue from this article: $100-500

**ROI:** This single article produces value for 12+ months. The SEO authority compounds. The newsletter signups feed future product launches. The template cross-sell generates passive revenue.

---

*For headline formulas and writing structure, see [writing-craft.md](writing-craft.md). For content calendaring, see [content-calendar.md](content-calendar.md). For SEO keyword research, see trl-market-intelligence [references/keyword-research.md](../../market-intelligence/references/keyword-research.md).*

---

*Version: 0.1.0*
