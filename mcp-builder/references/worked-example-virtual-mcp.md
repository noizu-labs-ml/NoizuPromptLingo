# Worked Example: Virtual MCP for Incident Response

End-to-end walkthrough building a Virtual MCP that composes GitHub MCP, Slack MCP, and PagerDuty API into a unified incident response tool set.

> For the theory behind Virtual MCPs, see [virtual-mcp-architecture.md](virtual-mcp-architecture.md). For real MCP server construction, see [worked-example-github-status.md](worked-example-github-status.md).

---

## Scenario

You are an on-call engineer. When an incident occurs, you need to:

1. Check GitHub Status for service health
2. Create a PagerDuty incident
3. Notify a Slack channel
4. Escalate if needed

These actions span three different systems. You already have MCP servers for GitHub and Slack. PagerDuty has a REST API but no MCP server. You want a unified interface so you can say "create an incident" and have it do the right things across all three systems.

---

## Step 1: Identify Available Tools

### Backing Tool Inventory

| Source | Type | Available Tools | Status |
|---|---|---|---|
| `github-status` MCP | Real MCP server (stdio) | `get_status`, `get_incidents`, `get_component_status` | Running |
| `slack` MCP | Real MCP server (stdio) | `post_message`, `list_channels`, `search_messages` | Running |
| PagerDuty API v2 | REST API (no MCP server) | `POST /incidents`, `PUT /incidents/{id}`, `POST /incidents/{id}/notes` | Available |

### Gap Analysis

| Desired Capability | Backing Available? | Notes |
|---|---|---|
| Check GitHub health | Yes (`github-status.get_status`) | Direct mapping |
| Create PagerDuty incident | Partial (API exists, no MCP) | Agent makes HTTP calls |
| Notify Slack channel | Yes (`slack.post_message`) | Direct mapping |
| Escalate incident | No | Future: PagerDuty escalation API |

---

## Step 2: Design the Published Interface

### Published Tool Catalog v1.0

| Tool | Version | Status | Description |
|---|---|---|---|
| `create_incident` | 1.0 | Draft | Create a new incident across PagerDuty and notify Slack |
| `get_status_page` | 1.0 | Draft | Get GitHub service health summary |
| `notify_channel` | 1.0 | Draft | Send a message to a Slack channel |
| `escalate` | 1.0 | Stub | Escalate an incident to the next tier |

### Tool Definitions

**create_incident v1.0:**

```yaml
name: create_incident
version: "1.0"
status: draft
description: |
  Create a new incident. Creates a PagerDuty incident and sends a
  notification to the designated Slack channel with incident details.
schema:
  title:
    type: string
    required: true
    description: Short incident title
  severity:
    type: string
    enum: [critical, high, medium, low]
    required: true
    description: Incident severity
  description:
    type: string
    required: false
    description: Detailed incident description
  slack_channel:
    type: string
    required: false
    default: "#incidents"
    description: Slack channel for notification
backing:
  - source: pagerduty-api
    action: POST /incidents
    mapping:
      title -> incident.title
      severity -> incident.urgency (critical/high -> high, medium/low -> low)
      description -> incident.body.details
  - source: slack-mcp
    tool: post_message
    mapping:
      slack_channel -> channel
      (formatted message with title, severity, PD link) -> text
```

**get_status_page v1.0:**

```yaml
name: get_status_page
version: "1.0"
status: draft
description: Get current GitHub service health status
schema: {}  # No parameters
backing:
  - source: github-status-mcp
    tool: get_status
    mapping: passthrough
```

**notify_channel v1.0:**

```yaml
name: notify_channel
version: "1.0"
status: draft
description: Send a notification message to a Slack channel
schema:
  channel:
    type: string
    required: true
    description: Slack channel name (e.g., #incidents)
  message:
    type: string
    required: true
    description: Message text
backing:
  - source: slack-mcp
    tool: post_message
    mapping:
      channel -> channel
      message -> text
```

**escalate v1.0:**

```yaml
name: escalate
version: "1.0"
status: stub
description: Escalate an incident to the next response tier
schema:
  incident_id:
    type: string
    required: true
  reason:
    type: string
    required: true
backing: null  # Not yet implemented
```

---

## Step 3: User Approval

Present the catalog to the user for review:

```
Virtual MCP: incident-response v1.0

Published Tools:
  create_incident  v1.0  [DRAFT]  - Create incident (PagerDuty + Slack notification)
  get_status_page  v1.0  [DRAFT]  - Check GitHub service health
  notify_channel   v1.0  [DRAFT]  - Send Slack notification
  escalate         v1.0  [STUB]   - Escalate to next tier (not yet implemented)

Backing Sources:
  github-status MCP  - 1 tool used (get_status)
  slack MCP          - 1 tool used (post_message)
  PagerDuty API v2   - 1 endpoint used (POST /incidents)

Do you approve this interface? Any changes before I commit it?
```

User approves. All Draft tools move to Committed.

---

## Step 4: Implement the Composition

In practice, the "implementation" of a Virtual MCP is the agent's behavior when the user invokes a Published tool. Here is what happens for each tool:

### create_incident Execution Flow

When the user says "Create a critical incident for API outage":

```
1. Agent receives: create_incident(title="API Outage", severity="critical")

2. Agent calls PagerDuty API:
   POST https://api.pagerduty.com/incidents
   Headers: Authorization: Token token=$PAGERDUTY_TOKEN
   Body: {
     "incident": {
       "type": "incident",
       "title": "API Outage",
       "urgency": "high",
       "service": { "id": "$SERVICE_ID", "type": "service_reference" },
       "body": { "type": "incident_body", "details": "" }
     }
   }
   Response: { "incident": { "id": "P123ABC", "html_url": "https://..." } }

3. Agent calls slack.post_message:
   channel: "#incidents"
   text: "[CRITICAL] API Outage - PagerDuty incident P123ABC created. https://..."

4. Agent returns to user:
   "Created critical incident 'API Outage':
   - PagerDuty: P123ABC (https://app.pagerduty.com/incidents/P123ABC)
   - Slack: Notified #incidents"
```

### get_status_page Execution Flow

```
1. Agent receives: get_status_page()
2. Agent calls github-status.get_status()
3. Agent formats result and returns to user
```

### escalate Execution Flow

```
1. Agent receives: escalate(incident_id="P123ABC", reason="Not responding to page")
2. Agent returns: "Error: escalate is a stub tool (v1.0). This capability is planned
   but not yet implemented. To escalate manually, open PagerDuty and reassign the incident."
```

---

## Step 5: Run a Self-Audit

After a week of use, run the self-audit:

```markdown
## Virtual MCP Audit Report
Date: 2026-05-08
Catalog: incident-response v1.0

### Contract Check
| Published Tool    | Version | Backing                        | Status |
|-------------------|---------|--------------------------------|--------|
| create_incident   | 1.0     | pagerduty-api + slack.post_msg | PASS   |
| get_status_page   | 1.0     | github-status.get_status       | PASS   |
| notify_channel    | 1.0     | slack.post_message             | PASS   |
| escalate          | 1.0     | STUB                           | STUB   |

### Regression Check
| Published Tool    | Test Input                     | Result  |
|-------------------|--------------------------------|---------|
| create_incident   | title="test", severity="low"   | PASS    |
| get_status_page   | (none)                         | PASS    |
| notify_channel    | channel="#test", message="hi"  | PASS    |
| escalate          | (skipped - stub)               | SKIP    |

### Drift Detection
| Backing Tool               | Source            | Status |
|----------------------------|-------------------|--------|
| github-status.get_status   | github-status MCP | STABLE |
| slack.post_message         | slack MCP         | STABLE |
| PagerDuty POST /incidents  | PagerDuty API v2  | STABLE |

### Usage Summary (past 7 days)
| Published Tool    | Calls | Avg Latency |
|-------------------|-------|-------------|
| create_incident   | 3     | ~8s (LLM + 2 API calls) |
| get_status_page   | 12    | ~3s (LLM + 1 MCP call) |
| notify_channel    | 7     | ~4s (LLM + 1 MCP call) |
| escalate          | 1     | N/A (stub error returned) |

### Summary
- 3/4 Published tools operational
- 1 stub remaining (escalate) -- user attempted to use it once
- No drift detected in backing tools
- Action items:
  1. Implement escalate (user demand confirmed)
  2. Consider adding get_incidents tool (requested twice informally)
```

---

## Step 6: Version Bump to v2.0

Based on usage, the user requests two changes:

1. Implement `escalate`
2. Add `description` as a required field on `create_incident` (breaking change)

### Version Proposal

```
Proposed changes for incident-response v2.0:

1. create_incident v1.0 -> v2.0 (BREAKING)
   - `description` field changes from optional to required
   - Rationale: Every incident created without a description was followed by
     a manual edit to add one. Making it required improves data quality.
   - Impact: Callers must now include description parameter.

2. escalate v1.0 [STUB] -> v1.0 [COMMITTED]
   - Now backed by PagerDuty API PUT /incidents/{id}/escalation_policy
   - Notifies Slack channel when escalation occurs.

3. NEW: get_recent_incidents v1.0
   - Returns recent PagerDuty incidents (last 24h by default)
   - Backed by PagerDuty API GET /incidents

Deprecation:
   - create_incident v1.0 will be DEPRECATED for 2 weeks
   - During deprecation, both v1.0 (description optional) and v2.0 (description required)
     are available
   - After 2 weeks, v1.0 is REMOVED

Approve these changes?
```

User approves.

### Updated Catalog

```yaml
name: incident-response
version: "2.0"
description: Unified incident response tools

published_tools:
  - name: create_incident
    version: "2.0"
    status: committed
    description: Create a new incident with description, severity, and Slack notification
    schema:
      title: { type: string, required: true }
      severity: { type: string, enum: [critical, high, medium, low], required: true }
      description: { type: string, required: true }  # Changed from optional
      slack_channel: { type: string, required: false, default: "#incidents" }

  - name: create_incident
    version: "1.0"
    status: deprecated
    deprecation_deadline: "2026-05-22"
    replacement: "create_incident v2.0"

  - name: get_status_page
    version: "1.0"
    status: committed

  - name: notify_channel
    version: "1.0"
    status: committed

  - name: escalate
    version: "1.0"
    status: committed  # Promoted from stub
    description: Escalate an incident to the next response tier
    schema:
      incident_id: { type: string, required: true }
      reason: { type: string, required: true }
    backing:
      - source: pagerduty-api
        action: PUT /incidents/{incident_id}
        mapping:
          incident_id -> path parameter
          (escalation policy) -> escalation_policy.id
      - source: slack-mcp
        tool: post_message
        mapping:
          "#incidents" -> channel
          (formatted escalation message) -> text

  - name: get_recent_incidents
    version: "1.0"
    status: committed
    description: Get recent PagerDuty incidents
    schema:
      since: { type: string, required: false, default: "24h", description: "Time window" }
      status: { type: string, enum: [triggered, acknowledged, resolved, all], default: "all" }
    backing:
      - source: pagerduty-api
        action: GET /incidents
        mapping:
          since -> since (convert to ISO 8601)
          status -> statuses[] (unless "all")
```

---

## Key Takeaways

1. **Virtual MCPs are fast to build.** The v1.0 catalog took about 30 minutes to define and validate. No code, no deployment, no CI/CD.

2. **Self-audit caught real issues.** The audit revealed that `escalate` was actually needed (user tried to use it) and that descriptions should be required.

3. **Version contracts prevent silent breakage.** Making `description` required was a deliberate, approved change with a deprecation window -- not a surprise.

4. **The cost model matters.** Each `create_incident` call costs LLM tokens for reasoning plus API latency. At 3 calls per week, this is negligible. At 30 calls per day, consider promoting to a real MCP server.

5. **Promotion path is clear.** If `create_incident` becomes high-volume, extract its definition as the specification for a real MCP server and use **trl-mcp-forge** to build it. The Virtual MCP then routes to the real server as a Backing tool.
