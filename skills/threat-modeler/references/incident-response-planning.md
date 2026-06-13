# Incident Response Planning

Practical IR planning for engineering teams running web applications on Kubernetes. Based on NIST SP 800-61 Rev. 2 phases, adapted for modern cloud-native environments.

---

## IR Plan Structure (NIST SP 800-61 Phases)

### Phase 1: Preparation

The work you do before anything goes wrong. This phase determines whether your incident response is controlled or chaotic.

**Minimum requirements:**

| Preparation Item | Description | Owner |
|-----------------|-------------|-------|
| IR Plan document | This document -- roles, procedures, escalation paths | Security Lead |
| Communication channels | Dedicated Slack channel, bridge line, email DL | Ops Lead |
| Contact list | On-call rotation, management chain, legal, PR, vendors | Security Lead |
| Tooling access | Ensure responders have access to logging, cloud console, kubectl | Platform Team |
| Forensic toolkit | Log export scripts, snapshot procedures, chain-of-custody docs | Security Lead |
| Runbooks | Per-scenario playbooks (see Scenarios section below) | Engineering |
| Training | Annual tabletop exercises, new-hire IR orientation | Security Lead |
| Legal prep | Outside counsel identified, cyber insurance policy reviewed | Legal/Finance |
| Evidence storage | Isolated S3 bucket or storage volume for forensic artifacts | Platform Team |

**Key principle:** Every responder should be able to answer "what do I do in the first 15 minutes?" without reading a 40-page document.

### Phase 2: Detection and Analysis

Turning signals into confirmed incidents with severity classification.

**Detection sources:**

| Source | Examples | Typical Signal |
|--------|----------|---------------|
| Monitoring/Alerting | Prometheus, Datadog, CloudWatch | Anomalous metrics, threshold breaches |
| Log aggregation | Loki, ELK, Splunk | Auth failures, unusual API patterns |
| Security tooling | Falco, Trivy, GuardDuty | Runtime anomalies, CVE detections |
| External reports | Bug bounty, customer reports, vendor notifications | Vulnerability disclosures |
| Threat intelligence | CVE feeds, CISA alerts, vendor advisories | New exploits affecting your stack |

**Analysis checklist:**

1. Validate the alert -- is this a true positive?
2. Determine scope -- what systems, data, and users are affected?
3. Classify severity (see Escalation Matrix below)
4. Identify attack vector and indicators of compromise (IoCs)
5. Document timeline -- when did it start, what is the current state?
6. Preserve evidence before taking containment actions

### Phase 3: Containment, Eradication, and Recovery

**Containment strategies by environment:**

| Environment | Short-Term Containment | Long-Term Containment |
|-------------|----------------------|----------------------|
| Kubernetes | Network policy isolation, pod kill, namespace quarantine | New deployment with patched images, rotated secrets |
| Cloud (AWS/GCP) | Security group lockdown, IAM policy deny, instance isolation | New infrastructure from IaC, credential rotation |
| Application | Feature flag disable, rate limiting, WAF rule | Code fix deployment, dependency update |
| Data | Revoke access tokens, disable compromised accounts | Password reset enforcement, session invalidation |

**Eradication steps:**

1. Remove attacker access (credentials, backdoors, persistence mechanisms)
2. Patch the vulnerability that enabled initial access
3. Scan for lateral movement or additional compromise
4. Rebuild affected systems from known-good state (do not patch in place)
5. Verify eradication with detection tooling

**Recovery steps:**

1. Restore services from clean backups or redeploy from IaC
2. Monitor restored systems with heightened alerting thresholds
3. Gradually restore access and traffic
4. Confirm normal operation with stakeholders
5. Document recovery actions and timeline

### Phase 4: Post-Incident Activity

Covered in detail in the Post-Incident Review Template section below.

---

## Escalation Matrix

### Severity Levels

| Severity | Definition | Examples |
|----------|-----------|----------|
| SEV-1 Critical | Active exploitation, data breach confirmed, service fully down | Confirmed data exfiltration, ransomware, complete outage |
| SEV-2 High | Likely exploitation, significant risk, partial service degradation | Unauthorized access detected, critical CVE actively scanned |
| SEV-3 Medium | Suspicious activity, potential risk, no confirmed impact | Unusual auth patterns, failed exploitation attempts |
| SEV-4 Low | Informational, minor anomaly, no immediate risk | Policy violation, minor misconfiguration detected |

### Notification Matrix

| Severity | First Responder | Notify Within | Escalate To | Brief Leadership | Customer Notify |
|----------|----------------|---------------|-------------|-----------------|----------------|
| SEV-1 | On-call engineer | Immediately | CTO + Security Lead + Legal | 30 min | As required by regulation/contract |
| SEV-2 | On-call engineer | 15 min | Security Lead + Eng Manager | 2 hours | If customer data affected |
| SEV-3 | On-call engineer | 1 hour | Security Lead | Next standup | No |
| SEV-4 | On-call engineer | Next business day | Team lead | No | No |

### SLA Timelines

| Severity | Acknowledge | First Update | Resolution Target | Post-Incident Review |
|----------|------------|-------------|-------------------|---------------------|
| SEV-1 | 15 min | 30 min | 4 hours | Within 48 hours |
| SEV-2 | 30 min | 2 hours | 24 hours | Within 1 week |
| SEV-3 | 4 hours | 8 hours | 1 week | Within 2 weeks |
| SEV-4 | 1 business day | 2 business days | 30 days | Monthly batch review |

---

## Communication Templates

### Internal Notification (Initial)

```
Subject: [SEV-{___}] Security Incident - {Brief Description}

CLASSIFICATION: {CONFIDENTIAL / INTERNAL ONLY}

Incident ID: INC-{YYYY-MM-DD}-{NNN}
Severity: SEV-{___}
Detected: {YYYY-MM-DD HH:MM UTC}
Reported by: {Name / System}
Incident Commander: {Name}

SUMMARY
{2-3 sentence description of what was detected and current understanding.}

AFFECTED SYSTEMS
- {System/service 1}
- {System/service 2}

AFFECTED DATA
- {Data type and estimated scope, or "Under investigation"}

CURRENT STATUS
- [ ] Confirmed / Suspected
- [ ] Contained / Uncontained
- [ ] Investigation in progress

IMMEDIATE ACTIONS TAKEN
1. {Action 1}
2. {Action 2}

NEXT STEPS
1. {Planned action 1}
2. {Planned action 2}

BRIDGE / WAR ROOM
- Slack: #incident-{id}
- Video: {link}

Next update: {time}
```

### Customer Notification

```
Subject: Security Notice - {Service Name}

Dear {Customer Name},

We are writing to inform you of a security incident affecting
{Service Name} that we detected on {date}.

WHAT HAPPENED
{Plain-language description of the incident. No jargon. Be specific
about what occurred without revealing exploitable details.}

WHAT INFORMATION WAS INVOLVED
{Specific data types affected: names, email addresses, API keys, etc.
If unknown, state that investigation is ongoing.}

WHAT WE ARE DOING
{Actions taken to contain, remediate, and prevent recurrence.}

WHAT YOU CAN DO
{Specific, actionable steps: rotate API keys, change passwords,
review access logs, etc.}

TIMELINE
- {Date}: Incident detected
- {Date}: Containment achieved
- {Date}: Investigation completed
- {Date}: Remediation deployed

FOR MORE INFORMATION
Contact: {security email}
Status page: {URL}
Reference: {Incident ID}

We take the security of your data seriously and are committed to
transparency throughout this process.

{Name}
{Title}
```

### Regulatory Notification (GDPR Template -- 72 Hour)

```
To: {Supervisory Authority / DPA}
From: {Organization Name}, {DPO Name and Contact}
Date: {Date}
Reference: {Incident ID}

NOTIFICATION UNDER ARTICLE 33 GDPR

1. NATURE OF THE BREACH
   Type: {Confidentiality / Integrity / Availability}
   Description: {What happened}
   Date/time of breach: {When it occurred}
   Date/time of detection: {When you found out}

2. DATA SUBJECTS AFFECTED
   Categories: {Customers, employees, etc.}
   Approximate number: {N individuals}
   Regions: {EU member states affected}

3. PERSONAL DATA AFFECTED
   Categories: {Names, emails, financial data, health data, etc.}
   Approximate number of records: {N}

4. LIKELY CONSEQUENCES
   {Assessment of risk to data subjects: identity theft, financial
   loss, discrimination, etc.}

5. MEASURES TAKEN / PROPOSED
   Containment: {Actions taken}
   Remediation: {Actions planned}
   Prevention: {Changes to prevent recurrence}

6. DATA SUBJECT NOTIFICATION
   {Have data subjects been notified? If not, justification per
   Art. 34(3).}

7. DPO CONTACT
   Name: {___}
   Email: {___}
   Phone: {___}

This is a {preliminary / final} notification. Further details will
be provided by {date} if applicable.
```

---

## Tabletop Exercise Design

### How to Run a Tabletop

**Duration:** 60-90 minutes
**Participants:** On-call engineers, security lead, eng manager, optionally legal/PR
**Facilitator:** Someone not in the normal IR rotation (prevents groupthink)

**Structure:**

1. **Setup (5 min)** -- Facilitator presents the scenario premise
2. **Phase injection (10 min each)** -- Facilitator reveals new information in stages, team discusses response
3. **Decision points (throughout)** -- Facilitator asks "what do you do now?" at critical junctures
4. **Curveballs (2-3 per exercise)** -- Unexpected complications (media inquiry, second incident, key person unavailable)
5. **Debrief (15 min)** -- What went well, what was unclear, what needs updating in the IR plan

**Rules:**
- No wrong answers -- this is practice, not evaluation
- Stay in character for your role
- Document decisions and reasoning
- Note every point where someone said "I don't know who handles that"

### Scenario 1: Credential Compromise

**Premise:** Your CI/CD pipeline's cloud credentials appear in a public GitHub repository. A security researcher notified you via your security@ email 2 hours ago.

**Phase 1:** Initial notification received. The exposed credentials have admin-level access to your production cloud account.

**Phase 2:** CloudTrail/audit logs show the credentials were used from an unknown IP address 45 minutes after the commit was pushed. Several API calls were made to list S3 buckets and IAM users.

**Phase 3:** A new IAM user was created with admin privileges. An EC2 instance was launched in a region you don't normally use. Your database snapshots were copied to an external account.

**Curveball:** Your primary cloud admin is on vacation with limited connectivity.

**Discussion questions:**
- How quickly can you rotate the compromised credentials?
- Can you determine what data was in the copied snapshots?
- When do you notify customers? What do you tell them?
- Does this trigger regulatory notification requirements?

### Scenario 2: Container Escape in Production

**Premise:** Falco alerts fire indicating a container in your production Kubernetes cluster executed an unexpected binary and attempted to mount the host filesystem.

**Phase 1:** The affected pod is running a third-party image that was updated 6 hours ago via automated dependency updates. The image contains a known CVE published 2 days ago.

**Phase 2:** Network monitoring shows the compromised pod made outbound connections to an unfamiliar IP. DNS logs show lookups for a domain associated with a known C2 framework.

**Phase 3:** Similar exploitation attempts are detected on 3 other pods using the same base image across two namespaces. Kubernetes API audit logs show the compromised pod's service account was used to list secrets in the namespace.

**Curveball:** A journalist emails asking about "reports of a breach at your company."

**Discussion questions:**
- How do you isolate the affected pods without causing a full outage?
- Can you determine if the attacker accessed secrets or moved laterally?
- How do you handle the media inquiry while investigation is ongoing?
- What changes to your image update pipeline would prevent this?

### Scenario 3: Data Exfiltration via Application Vulnerability

**Premise:** Your application WAF logs show a series of SQL injection attempts against your API. Most were blocked, but error rates on your database have spiked.

**Phase 1:** Database slow query logs show unusual SELECT queries against your users table that don't match any application code. The queries are extracting email addresses, hashed passwords, and billing addresses.

**Phase 2:** Network monitoring shows a sustained data transfer from your database server to a cloud storage endpoint you don't control. Approximately 50,000 records were transferred over 4 hours before detection.

**Phase 3:** The attack vector is identified as a parameterized query that was incorrectly constructed in a recently deployed API endpoint. The endpoint bypassed the ORM and used raw SQL.

**Curveball:** A customer contacts support saying they received a phishing email referencing data only your platform would have.

**Discussion questions:**
- At what point does this become a reportable breach under GDPR/CCPA?
- How do you determine the exact scope of exfiltrated data?
- What is your communication plan for 50,000 affected users?
- How do you prevent similar vulnerabilities in future deployments?

---

## Post-Incident Review Template

Blameless postmortem format. Schedule within the SLA window for the incident severity.

```markdown
# Post-Incident Review: INC-{ID}

**Date of review:** {Date}
**Incident Commander:** {Name}
**Attendees:** {Names}
**Author:** {Name}

## Incident Summary

| Field | Value |
|-------|-------|
| Severity | SEV-{N} |
| Duration | {Start} to {End} ({total time}) |
| Time to detect | {minutes/hours from start to detection} |
| Time to contain | {minutes/hours from detection to containment} |
| Time to resolve | {minutes/hours from containment to resolution} |
| Customer impact | {Description of user-facing impact} |
| Data impact | {Data types affected, records count, or "None"} |

## Timeline

| Time (UTC) | Event |
|-----------|-------|
| {HH:MM} | {First indicator / attack begins} |
| {HH:MM} | {Alert fires / report received} |
| {HH:MM} | {Incident declared, IC assigned} |
| {HH:MM} | {Key investigation finding} |
| {HH:MM} | {Containment action taken} |
| {HH:MM} | {Eradication completed} |
| {HH:MM} | {Service restored} |
| {HH:MM} | {Monitoring confirmed stable} |

## Root Cause

{Technical description of what went wrong and why. Be specific.
Reference commits, configs, or architectural decisions.}

## Contributing Factors

- {Factor 1: e.g., "No input validation on the /api/export endpoint"}
- {Factor 2: e.g., "Automated image updates without vulnerability gate"}
- {Factor 3: e.g., "Overly permissive service account RBAC"}

## What Went Well

- {Thing 1}
- {Thing 2}

## What Could Be Improved

- {Thing 1}
- {Thing 2}

## Action Items

| Action | Owner | Priority | Due Date | Status |
|--------|-------|----------|----------|--------|
| {Remediation action} | {Name} | P0/P1/P2 | {Date} | Open |
| {Detection improvement} | {Name} | P0/P1/P2 | {Date} | Open |
| {Process improvement} | {Name} | P0/P1/P2 | {Date} | Open |
| {Documentation update} | {Name} | P0/P1/P2 | {Date} | Open |

## Metrics

- **MTTD (Mean Time to Detect):** {N minutes/hours}
- **MTTC (Mean Time to Contain):** {N minutes/hours}
- **MTTR (Mean Time to Resolve):** {N minutes/hours}
- **Customer notifications sent:** {N or N/A}
- **Regulatory notifications filed:** {Yes/No, which authorities}
```

---

## Common IR Scenarios for Web/K8s Environments

Quick-reference response priorities for the most likely incidents.

### Credential Compromise

| Step | Action | Tool/Command |
|------|--------|-------------|
| 1 | Identify scope of compromised credential | Cloud audit logs, `kubectl get secrets` |
| 2 | Revoke/rotate immediately | Cloud IAM console, `kubectl delete secret` + recreate |
| 3 | Audit usage during exposure window | CloudTrail, GCP Audit Logs, K8s audit logs |
| 4 | Check for persistence (new users, keys, roles) | `aws iam list-users`, `kubectl get clusterrolebindings` |
| 5 | Scan for lateral movement | Network flow logs, service mesh telemetry |
| 6 | Force session invalidation | Restart pods, invalidate JWTs, clear session stores |

### Container Escape

| Step | Action | Tool/Command |
|------|--------|-------------|
| 1 | Isolate the node | `kubectl cordon`, network policy deny-all |
| 2 | Capture forensic state | `kubectl logs`, container runtime snapshots |
| 3 | Kill compromised pods | `kubectl delete pod --grace-period=0` |
| 4 | Audit node-level access | Host process list, file integrity, mounted volumes |
| 5 | Check other pods on same node | Review all workloads on the affected node |
| 6 | Rebuild node from clean image | Drain, delete, let autoscaler replace |

### Data Exfiltration

| Step | Action | Tool/Command |
|------|--------|-------------|
| 1 | Block exfiltration channel | Network policy, WAF rule, revoke access |
| 2 | Determine data scope | Query logs for accessed records, DB audit trail |
| 3 | Preserve evidence | Export logs, snapshot affected systems |
| 4 | Assess regulatory obligations | Check if PII/PHI/financial data involved |
| 5 | Notify affected parties | Use communication templates above |
| 6 | Patch the vulnerability | Code fix, deploy, verify |

### DDoS

| Step | Action | Tool/Command |
|------|--------|-------------|
| 1 | Confirm DDoS vs legitimate traffic spike | Traffic analysis, geographic distribution |
| 2 | Enable upstream mitigation | Cloudflare Under Attack Mode, AWS Shield |
| 3 | Scale horizontally if possible | HPA adjustments, node autoscaling |
| 4 | Rate limit at ingress | NGINX rate limiting, WAF rules |
| 5 | Identify and block attack patterns | IP blocks, request signature filtering |
| 6 | Monitor for secondary attack | DDoS often used as cover for other activity |

### Supply Chain Compromise

| Step | Action | Tool/Command |
|------|--------|-------------|
| 1 | Identify affected dependency | `npm audit`, `trivy image`, advisory databases |
| 2 | Determine exposure window | When was the compromised version introduced? |
| 3 | Pin/rollback to known-good version | Lock file update, image tag rollback |
| 4 | Scan for IOCs from the advisory | File hashes, network indicators, behavior patterns |
| 5 | Audit build pipeline | Check CI/CD logs for unexpected behavior during exposure |
| 6 | Review all transitive dependencies | Full dependency tree analysis, SBOM generation |

---

## Maintenance

Review and update this IR plan:
- **Quarterly:** Contact list, communication channels, tool access
- **Semi-annually:** Tabletop exercise with a new scenario
- **Annually:** Full plan review, update for new infrastructure/services
- **After every incident:** Incorporate lessons learned from post-incident review
