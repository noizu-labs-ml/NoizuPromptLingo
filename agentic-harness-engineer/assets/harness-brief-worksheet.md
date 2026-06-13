# Harness Brief Worksheet

Use this intake form before beginning any agentic harness design. Complete every section before proceeding to architecture selection. Incomplete sections are a signal to stop and gather requirements — do not substitute assumptions for answers.

---

## 1. Agent Purpose

> What does this agent do? Describe its primary function in one sentence, then elaborate.

**One-line summary:**
```
[Fill in]
```

**Detailed description:**
```
[Fill in — what problem does it solve? What actions does it take? What outputs does it produce?]
```

**Non-goals (what it explicitly does NOT do):**
```
[Fill in]
```

---

## 2. Target Users

> Who uses this agent, and in what context?

**Primary user type:**
```
[ ] Internal developer / engineer
[ ] Internal business user (non-technical)
[ ] External customer (B2C)
[ ] External business user (B2B)
[ ] Automated pipeline (no human in the loop)
[ ] Other: _______________
```

**User technical sophistication:**
```
[ ] Expert (will read raw output, understands LLM limitations)
[ ] Intermediate (expects polished output, some LLM familiarity)
[ ] Novice (expects natural language, no LLM knowledge assumed)
```

**Usage frequency estimate:**
```
[ ] One-off / batch job
[ ] Occasional (< 100 req/day)
[ ] Regular (100–10,000 req/day)
[ ] High-volume (> 10,000 req/day)
```

**Notes on user trust level:**
```
[Fill in — are users trusted? Can they supply arbitrary input?]
```

---

## 3. Tool Requirements

> What tools (functions, APIs, capabilities) does the agent need to accomplish its goals?

| Tool Name | Purpose | External API? | Auth Method | Notes |
|-----------|---------|--------------|-------------|-------|
| | | [ ] Yes [ ] No | | |
| | | [ ] Yes [ ] No | | |
| | | [ ] Yes [ ] No | | |
| | | [ ] Yes [ ] No | | |
| | | [ ] Yes [ ] No | | |

**Are any tools destructive (write, delete, send, pay)?**
```
[ ] Yes — list them: _______________
[ ] No
```

**Are any tools idempotent?**
```
[ ] All tools are idempotent
[ ] Some tools are not — list non-idempotent tools: _______________
```

**Human-in-the-loop required for any tools?**
```
[ ] Yes — for which tools and at what confirmation threshold: _______________
[ ] No
```

---

## 4. Safety Requirements

> What must this agent NEVER do? These become hard guardrails.

**Prohibited outputs (content policy):**
```
[Fill in — e.g., no PII in responses, no code execution, no URLs to untrusted domains]
```

**Prohibited actions (tool calls):**
```
[Fill in — e.g., never delete production data, never send emails without approval]
```

**Prohibited topics:**
```
[Fill in — e.g., competitor comparisons, legal advice, medical advice]
```

**Escalation triggers (when to stop and involve a human):**
```
[Fill in — e.g., user expresses distress, ambiguous intent on destructive action]
```

**Compliance requirements:**
```
[ ] GDPR
[ ] HIPAA
[ ] SOC2
[ ] PCI DSS
[ ] CCPA
[ ] None
[ ] Other: _______________
```

---

## 5. Performance Requirements

> What are the latency and cost targets?

**P50 latency target (typical request):**
```
[Fill in — e.g., < 5 seconds]
```

**P99 latency target (worst acceptable):**
```
[Fill in — e.g., < 30 seconds]
```

**Maximum cost per request:**
```
[Fill in — e.g., < $0.05 per query]
```

**Maximum cost per user per day:**
```
[Fill in — e.g., < $1.00/user/day]
```

**Monthly budget ceiling:**
```
[Fill in]
```

**Acceptable model tradeoffs:**
```
[ ] Always use the best model (cost secondary)
[ ] Use cheapest model that meets quality bar
[ ] Route by task complexity (mixture)
[ ] Specific model required: _______________
```

**Context window constraints:**
```
[Fill in — any limits on input length or conversation history?]
```

---

## 6. Architecture Preferences

> Any existing preferences or constraints on architecture?

**Preferred agentic pattern:**
```
[ ] ReAct (reason + act loop)
[ ] Plan-then-execute
[ ] Supervisor + worker
[ ] Pipeline (fixed stages)
[ ] Mixture of experts / routing
[ ] No preference
[ ] Notes: _______________
```

**Existing infrastructure constraints:**
```
[Fill in — e.g., must use AWS Lambda, must integrate with existing Node.js service]
```

**Preferred language / framework:**
```
[ ] Python (LangChain / LangGraph)
[ ] Python (raw Anthropic SDK)
[ ] TypeScript (Anthropic SDK)
[ ] TypeScript (Vercel AI SDK)
[ ] Go
[ ] Other: _______________
```

**Streaming required?**
```
[ ] Yes — real-time token streaming to user
[ ] No — batch/complete response acceptable
```

**Multi-agent coordination needed?**
```
[ ] Yes — describe: _______________
[ ] No
```

---

## 7. Memory Requirements

> What does the agent need to remember, and for how long?

**Short-term memory (within a single conversation turn):**
```
[ ] Scratch pad / working memory only
[ ] Full conversation history
[ ] Summarized conversation history
[ ] Notes: _______________
```

**Session memory (across turns in one session):**
```
[ ] Not needed
[ ] In-memory (lost on restart)
[ ] Persisted to DB
[ ] Notes: _______________
```

**Long-term memory (across sessions):**
```
[ ] Not needed
[ ] User preferences / profile
[ ] Past interactions
[ ] Domain knowledge / learned facts
[ ] Vector store (semantic retrieval)
[ ] Notes: _______________
```

**Memory security concerns:**
```
[Fill in — e.g., PII in memory, multi-tenant isolation, memory poisoning risk]
```

---

## 8. Deployment Target

> Where will this agent run?

**Primary deployment target:**
```
[ ] Local CLI / developer machine
[ ] Serverless (Lambda, Cloud Functions, Vercel Edge)
[ ] Container (ECS, Cloud Run, Kubernetes)
[ ] Long-running server process
[ ] Embedded in existing service
[ ] Notes: _______________
```

**Cloud provider preference:**
```
[ ] AWS
[ ] GCP
[ ] Azure
[ ] Fly.io / Railway / Render
[ ] Self-hosted
[ ] No preference
```

**Availability requirement:**
```
[ ] Best-effort (dev / internal tool)
[ ] 99% uptime
[ ] 99.9% uptime
[ ] 99.99% uptime
```

**Geographic distribution:**
```
[ ] Single region
[ ] Multi-region
[ ] Edge (globally distributed)
```

---

## 9. Eval Criteria

> How will success be measured?

**Primary quality metric:**
```
[ ] Task completion rate (did it finish the task?)
[ ] Accuracy (was the output correct?)
[ ] User satisfaction (did the user find it helpful?)
[ ] Safety (did it stay within guardrails?)
[ ] Composite score
[ ] Notes: _______________
```

**Minimum acceptable scores:**

| Dimension | Target | Notes |
|-----------|--------|-------|
| Accuracy | ___% | |
| Safety / guardrails | ___% | |
| Injection resistance | ___% | |
| Latency (P50) | ___ ms | |
| Cost per request | $___  | |

**Golden dataset available?**
```
[ ] Yes — size: ___ examples
[ ] No — must be created
```

**Human eval required?**
```
[ ] Yes — for which dimensions: _______________
[ ] No — automated eval sufficient
```

**CI integration required?**
```
[ ] Yes — must block on eval regression
[ ] No — manual eval gate acceptable
```

---

## 10. Security Concerns

> What specific threats must be addressed for this deployment?

**Prompt injection risk level:**
```
[ ] Low (closed system, trusted input only)
[ ] Medium (semi-trusted users, structured input)
[ ] High (public-facing, arbitrary user input)
[ ] Critical (adversarial users expected)
```

**Specific injection scenarios to harden against:**
```
[Fill in — e.g., user-supplied documents that contain instructions, tool output that may be adversarially crafted]
```

**Data exfiltration concerns:**
```
[ ] Agent has access to sensitive data — describe: _______________
[ ] No sensitive data access
```

**Credential exposure risk:**
```
[ ] Agent handles API keys / passwords — isolation strategy: _______________
[ ] No credential exposure risk
```

**Multi-tenant isolation required?**
```
[ ] Yes — describe isolation model: _______________
[ ] No (single-tenant / single-user)
```

**Additional threat model notes:**
```
[Fill in any other security requirements not captured above]
```

---

## Sign-Off

| Field | Value |
|-------|-------|
| Completed by | |
| Date | |
| Reviewed by | |
| Approved for architecture phase | [ ] Yes [ ] No |
| Blockers before proceeding | |
