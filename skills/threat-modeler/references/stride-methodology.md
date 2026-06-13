# STRIDE Methodology -- Deep Dive

A comprehensive reference for developers and architects applying STRIDE threat modeling to real systems. This document assumes familiarity with software architecture but not formal security training.

---

## Overview

STRIDE was developed at Microsoft in 1999 by Loren Kohnfelder and Praerit Garg as a mnemonic for categorizing security threats during software design. It became the backbone of Microsoft's Security Development Lifecycle (SDL) and remains the most widely adopted threat modeling framework in the industry.

**What STRIDE stands for:**

| Letter | Category                | Violated Property    |
|--------|-------------------------|----------------------|
| S      | Spoofing                | Authentication       |
| T      | Tampering               | Integrity            |
| R      | Repudiation             | Non-repudiation      |
| I      | Information Disclosure  | Confidentiality      |
| D      | Denial of Service       | Availability         |
| E      | Elevation of Privilege  | Authorization         |

**When to use STRIDE:**

- Early in design, before implementation begins
- When onboarding a new system component or third-party integration
- During architecture reviews for existing systems
- When compliance requires documented threat analysis (SOC2, ISO 27001)

**STRIDE vs other frameworks:**

| Framework | Best For                              | Complexity |
|-----------|---------------------------------------|------------|
| STRIDE    | Component-level design threats        | Low-Medium |
| PASTA     | Risk-centric, business-aligned analysis | High     |
| LINDDUN   | Privacy-specific threats              | Medium     |
| VAST      | Agile/DevOps continuous modeling      | Medium     |
| Attack Trees | Deep-dive on a single threat goal  | Variable   |

STRIDE is the recommended starting point for teams new to threat modeling. It is systematic without being heavyweight, and it maps cleanly onto architectural diagrams.

---

## Data Flow Diagram (DFD) Notation

Threat modeling with STRIDE begins with a Data Flow Diagram (DFD). The DFD is not a network diagram or a deployment diagram -- it models how data moves through your system across trust boundaries.

### DFD Elements

| Element           | Shape              | Represents                          |
|-------------------|--------------------|-------------------------------------|
| Process           | Circle / Rounded   | Code that transforms or routes data |
| Data Store        | Parallel lines     | Databases, caches, file systems     |
| Data Flow         | Arrow              | Data in transit between elements    |
| External Entity   | Rectangle          | Users, third-party APIs, anything outside your control |
| Trust Boundary    | Dashed line        | Separation between trust zones      |

### ASCII DFD Example

```
 Trust Boundary: Internet / DMZ
- - - - - - - - - - - - - - - - - - - - - - - - - - - -
:                                                       :
:  +-----------+      HTTPS       +-------------+      :
:  |  Browser  | ---------------> |  API Gateway |      :
:  | (External)|                  |  (Process)   |      :
:  +-----------+                  +------+------+      :
:                                        |              :
- - - - - - - - - - - - - - - - - - - - -|- - - - - - -
 Trust Boundary: DMZ / Internal Network  |
- - - - - - - - - - - - - - - - - - - - -|- - - - - - -
:                                        |              :
:                                        v              :
:                                 +------+------+      :
:                                 | App Server  |      :
:                                 | (Process)   |      :
:                                 +------+------+      :
:                                   |         |         :
:                          SQL      |         |  gRPC   :
:                                   v         v         :
:                            ======+=+    +---+----+   :
:                            | Users |    | Auth   |   :
:                            | (DB)  |    | Service|   :
:                            ========+    +--------+   :
:                                                       :
- - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

### DFD Leveling

- **Level 0 (Context):** System as a single process, showing external entities and major data flows.
- **Level 1 (Decomposed):** Breaks the system into major subsystems, shows internal data stores and trust boundaries.
- **Level 2+ (Detailed):** Decomposes individual processes further. Rarely needed unless analyzing a high-risk component.

Start at Level 1 for most threat models. Go deeper only for components that handle sensitive data or sit on trust boundaries.

---

## Per-Category Threat Libraries

### S -- Spoofing

**Definition:** Pretending to be something or someone other than yourself. Spoofing violates authentication -- the ability to verify that an entity is who it claims to be.

**Real-world examples:**
- Forging a JWT with a weak signing key
- DNS spoofing to redirect traffic to an attacker-controlled server
- Replaying a captured OAuth token from a stolen cookie

**Common attack patterns:**

| # | Pattern                              | Target Element        |
|---|--------------------------------------|-----------------------|
| 1 | Credential stuffing with leaked passwords | Login endpoints   |
| 2 | Session hijacking via XSS            | Browser sessions      |
| 3 | API key extraction from client bundles | Mobile/SPA clients  |
| 4 | Man-in-the-middle on unencrypted channels | Data flows        |
| 5 | Service impersonation in microservices | Internal processes   |

**Recommended controls:**

| # | Control                              | Implementation Notes              |
|---|--------------------------------------|-----------------------------------|
| 1 | Multi-factor authentication          | TOTP or WebAuthn, not SMS         |
| 2 | Mutual TLS for service-to-service    | Use a service mesh or cert manager |
| 3 | Short-lived, signed tokens (JWT/PASETO) | Rotate signing keys regularly  |
| 4 | Certificate pinning for mobile clients | Pin the CA, not the leaf cert   |
| 5 | IP/device fingerprint anomaly detection | Supplement, never replace auth  |

**Checklist questions:**

- [ ] Can an unauthenticated user reach any endpoint that assumes authentication?
- [ ] Are service-to-service calls authenticated, or do they rely on network isolation?
- [ ] Can tokens be replayed from a different device/IP?
- [ ] Are API keys rotatable without downtime?
- [ ] Is the authentication mechanism the same across all entry points (web, mobile, API)?

---

### T -- Tampering

**Definition:** Modifying data or code without authorization. Tampering violates integrity -- the assurance that data has not been altered in transit or at rest.

**Real-world examples:**
- SQL injection modifying database records
- Man-in-the-middle altering API responses
- Modifying a config file on disk to escalate permissions

**Common attack patterns:**

| # | Pattern                              | Target Element        |
|---|--------------------------------------|-----------------------|
| 1 | SQL/NoSQL injection                  | Data stores           |
| 2 | Parameter tampering (hidden form fields, query params) | Data flows |
| 3 | Binary patching of client applications | External entities   |
| 4 | Log injection to corrupt audit trails | Data stores          |
| 5 | Supply chain attacks on dependencies | Processes             |

**Recommended controls:**

| # | Control                              | Implementation Notes              |
|---|--------------------------------------|-----------------------------------|
| 1 | Input validation and parameterized queries | Never concatenate user input into queries |
| 2 | Integrity checks (HMAC, digital signatures) | Sign payloads at the producer, verify at consumer |
| 3 | Immutable audit logs                 | Append-only storage, separate write permissions |
| 4 | Dependency pinning with hash verification | Use lock files; verify checksums |
| 5 | File integrity monitoring            | AIDE, Tripwire, or OS-level equivalents |

**Checklist questions:**

- [ ] Can a user modify data they should only be able to read?
- [ ] Are request payloads validated server-side, not just client-side?
- [ ] Could an attacker modify data in transit between services?
- [ ] Are database migrations and schema changes audited?
- [ ] Is the CI/CD pipeline protected against unauthorized code injection?

---

### R -- Repudiation

**Definition:** Claiming that you did not perform an action when you did (or vice versa). Repudiation violates non-repudiation -- the ability to prove that an action occurred and who performed it.

**Real-world examples:**
- A user denying they placed a fraudulent order because no audit log exists
- An admin modifying a production database with no record of the change
- A service deleting records with no trace of who initiated the deletion

**Common attack patterns:**

| # | Pattern                              | Target Element        |
|---|--------------------------------------|-----------------------|
| 1 | Deleting or truncating log files     | Data stores           |
| 2 | Operating through shared/generic accounts | Processes          |
| 3 | Exploiting unsigned transactions     | Data flows            |
| 4 | Tampering with timestamps in logs    | Data stores           |

**Recommended controls:**

| # | Control                              | Implementation Notes              |
|---|--------------------------------------|-----------------------------------|
| 1 | Centralized, append-only logging     | Ship logs off-host immediately    |
| 2 | Unique identity per actor (no shared accounts) | Enforce individual credentials |
| 3 | Digitally signed audit records       | Chain signatures for tamper evidence |
| 4 | Timestamps from a trusted source (NTP) | Do not trust client-supplied timestamps |
| 5 | Retain logs beyond the dispute window | Align retention with legal/compliance needs |

**Checklist questions:**

- [ ] Can every state-changing action be attributed to a specific authenticated identity?
- [ ] Are logs stored in a location the application itself cannot modify or delete?
- [ ] Do shared service accounts exist? If so, can individual actions within them be distinguished?
- [ ] Is there a defined log retention policy aligned with business and legal requirements?
- [ ] Could an insider delete evidence of their own actions?

---

### I -- Information Disclosure

**Definition:** Exposing information to unauthorized parties. Violates confidentiality -- the protection of data from unauthorized access.

**Real-world examples:**
- Stack traces returned in production API error responses
- Database backups stored in a public S3 bucket
- Sensitive data logged in plaintext to stdout

**Common attack patterns:**

| # | Pattern                              | Target Element        |
|---|--------------------------------------|-----------------------|
| 1 | Directory traversal to read arbitrary files | Processes        |
| 2 | Verbose error messages leaking internals | Data flows          |
| 3 | Side-channel timing attacks on auth  | Processes             |
| 4 | Unencrypted data at rest             | Data stores           |
| 5 | Excessive data in API responses      | Data flows            |

**Recommended controls:**

| # | Control                              | Implementation Notes              |
|---|--------------------------------------|-----------------------------------|
| 1 | Encrypt data at rest (AES-256, full-disk encryption) | Manage keys separately from data |
| 2 | TLS 1.3 for all data in transit      | Disable TLS 1.0/1.1; enforce HSTS |
| 3 | Minimize API response payloads       | Return only requested fields; use field masks |
| 4 | Scrub sensitive data from logs       | PII, tokens, passwords -- redact before logging |
| 5 | Disable verbose errors in production | Return generic error codes; log details server-side |

**Checklist questions:**

- [ ] What is the most sensitive data this component handles? Where is it stored?
- [ ] Could a user enumerate resources they should not know exist (e.g., sequential IDs)?
- [ ] Are database connection strings, API keys, or secrets visible in config files, environment dumps, or error messages?
- [ ] Is PII ever logged, cached, or stored outside the primary data store?
- [ ] Are backups encrypted and access-controlled?

---

### D -- Denial of Service

**Definition:** Making a system unavailable to legitimate users. Violates availability -- the assurance that the system is accessible when needed.

**Real-world examples:**
- Volumetric DDoS flooding a public API
- A single expensive query locking a database table for minutes
- Resource exhaustion via file upload with no size limit

**Common attack patterns:**

| # | Pattern                              | Target Element        |
|---|--------------------------------------|-----------------------|
| 1 | Volumetric floods (SYN, UDP, HTTP)   | External-facing processes |
| 2 | Algorithmic complexity attacks (ReDoS, hash collisions) | Processes |
| 3 | Resource exhaustion (disk fill, memory, file descriptors) | Data stores, processes |
| 4 | Lock contention and deadlocks        | Data stores           |
| 5 | Dependency failure cascades          | Processes             |

**Recommended controls:**

| # | Control                              | Implementation Notes              |
|---|--------------------------------------|-----------------------------------|
| 1 | Rate limiting per identity and per IP | Use token bucket or sliding window |
| 2 | Request size and complexity limits   | Max body size, query depth, pagination limits |
| 3 | Circuit breakers on downstream calls | Fail fast; do not queue unbounded |
| 4 | Autoscaling with cost caps           | Scale horizontally but set budget alarms |
| 5 | CDN/WAF for volumetric protection    | Cloudflare, AWS Shield, etc.      |

**Checklist questions:**

- [ ] What happens if a single user sends 10,000 requests per second?
- [ ] Are there any endpoints that trigger expensive operations (reports, exports, search)?
- [ ] Can a user upload arbitrarily large files?
- [ ] What happens when a downstream dependency (database, cache, third-party API) goes down?
- [ ] Are resource limits (CPU, memory, connections) configured at the container/pod level?

---

### E -- Elevation of Privilege

**Definition:** Gaining capabilities beyond what was authorized. Violates authorization -- the enforcement of what an authenticated entity is allowed to do.

**Real-world examples:**
- A regular user accessing admin endpoints by guessing the URL
- Container escape from a pod to the host node
- IDOR (Insecure Direct Object Reference) allowing access to another user's data

**Common attack patterns:**

| # | Pattern                              | Target Element        |
|---|--------------------------------------|-----------------------|
| 1 | IDOR -- manipulating object IDs in requests | Data flows       |
| 2 | Missing function-level access control | Processes             |
| 3 | JWT claim manipulation (e.g., changing `role` field) | Data flows |
| 4 | Container/VM escape                  | Processes (infrastructure) |
| 5 | Privilege escalation via misconfigured RBAC | Data stores, processes |

**Recommended controls:**

| # | Control                              | Implementation Notes              |
|---|--------------------------------------|-----------------------------------|
| 1 | Server-side authorization on every request | Never rely on client-side hiding |
| 2 | Principle of least privilege for all service accounts | Review permissions quarterly |
| 3 | Use opaque/random identifiers, not sequential IDs | UUIDs or equivalent |
| 4 | Run containers as non-root with read-only filesystems | Drop all capabilities; add back only what is needed |
| 5 | RBAC with deny-by-default policies   | Explicit grants, no implicit inheritance |

**Checklist questions:**

- [ ] If a user changes the ID in a URL, can they access another user's data?
- [ ] Are admin functions protected by role checks, not just hidden UI elements?
- [ ] Do service accounts have more permissions than they need?
- [ ] Are containers running as root? With privileged mode?
- [ ] Is there a path from a compromised low-privilege component to a high-privilege one?

---

## Attack Tree Construction

Attack trees decompose a high-level threat goal into sub-goals and concrete attack steps. They are built top-down: start with the attacker's objective, then enumerate the ways to achieve it.

### Structure

- **Root node:** The attacker's goal (from a STRIDE finding)
- **Branch nodes:** Sub-goals (logical AND/OR decomposition)
- **Leaf nodes:** Concrete, actionable attack steps

### ASCII Attack Tree Example

```
Goal: Access another user's account (Elevation of Privilege)
|
+-- [OR] Steal credentials
|   |
|   +-- [OR] Phishing email with credential harvester
|   +-- [OR] Credential stuffing from breach database
|   +-- [OR] Keylogger on shared workstation
|
+-- [OR] Bypass authentication
|   |
|   +-- [OR] Exploit password reset flow
|   |   |
|   |   +-- [AND] Enumerate valid emails via timing difference
|   |   +-- [AND] Intercept reset token (unencrypted email)
|   |
|   +-- [OR] Forge session token
|       |
|       +-- [AND] Extract signing key from env variable leak
|       +-- [AND] Craft valid JWT with target user's ID
|
+-- [OR] Exploit authorization flaw
    |
    +-- [OR] IDOR on /api/users/{id}/profile
    +-- [OR] Mass assignment on user update endpoint
```

**Reading the tree:**
- **OR nodes:** Any one child path is sufficient for the attacker.
- **AND nodes:** All child conditions must be met.
- **Leaf nodes** get scored for likelihood and impact (see Threat Prioritization below).

Build attack trees for your highest-risk STRIDE findings -- typically 3 to 5 per system. They are especially useful for communicating risk to non-security stakeholders.

---

## STRIDE-per-Element vs STRIDE-per-Interaction

There are two approaches to applying STRIDE to a DFD. The choice affects how many threats you generate and how granular your analysis is.

### STRIDE-per-Element

Apply all six STRIDE categories to every element in the DFD (processes, data stores, external entities). This is the original Microsoft approach.

**Applicability matrix:**

| STRIDE Category        | Process | Data Store | Data Flow | External Entity |
|------------------------|:-------:|:----------:|:---------:|:---------------:|
| Spoofing               |    Y    |            |           |        Y        |
| Tampering              |    Y    |     Y      |     Y     |                 |
| Repudiation            |    Y    |     Y      |           |        Y        |
| Information Disclosure |    Y    |     Y      |     Y     |                 |
| Denial of Service      |    Y    |     Y      |     Y     |                 |
| Elevation of Privilege |    Y    |            |           |                 |

### STRIDE-per-Interaction

Apply STRIDE to each data flow (interaction) between elements, considering the source and destination. Introduced by Michael Howard to reduce noise and focus on trust boundary crossings.

### Comparison

| Dimension              | Per-Element                     | Per-Interaction                  |
|------------------------|---------------------------------|----------------------------------|
| Scope                  | Every DFD element               | Every data flow across a trust boundary |
| Threat count           | Higher (may include duplicates) | Lower, more focused              |
| Best for               | Comprehensive initial analysis  | Iterative/agile threat modeling  |
| Risk of over-counting  | High                            | Low                              |
| Risk of missing threats | Low                            | Medium (intra-element threats)   |
| Recommended team size  | Larger teams with dedicated security | Dev teams doing self-service modeling |

**Recommendation:** Start with STRIDE-per-Interaction for agile teams. It produces fewer, more actionable findings. Escalate to STRIDE-per-Element for systems handling highly sensitive data (PII, financial, healthcare) or when preparing for a compliance audit.

---

## Threat Prioritization

Not all threats are equal. Use a risk matrix to prioritize remediation effort.

### Risk Score Formula

```
Risk = Likelihood (1-5) x Impact (1-5)
```

### Likelihood Calibration

| Score | Label       | Guidance                                                    |
|-------|-------------|-------------------------------------------------------------|
| 1     | Rare        | Requires insider access + specialized tools + unlikely conditions |
| 2     | Unlikely    | Requires significant effort or uncommon preconditions       |
| 3     | Possible    | Known attack pattern, moderate effort, publicly documented  |
| 4     | Likely      | Low-effort attack, tools freely available, common in the wild |
| 5     | Almost Certain | Automated/scripted, no authentication required, actively exploited |

### Impact Calibration

| Score | Label       | Guidance                                                    |
|-------|-------------|-------------------------------------------------------------|
| 1     | Negligible  | No data loss, no service disruption, cosmetic only          |
| 2     | Minor       | Limited data exposure, brief service degradation, single user affected |
| 3     | Moderate    | Partial data breach, extended outage, regulatory notification possible |
| 4     | Major       | Significant data breach, prolonged outage, regulatory penalty likely |
| 5     | Critical    | Full system compromise, mass data exfiltration, existential business risk |

### Risk Matrix

```
Impact
  5 |  5  | 10  | 15  | 20  | 25  |
  4 |  4  |  8  | 12  | 16  | 20  |
  3 |  3  |  6  |  9  | 12  | 15  |
  2 |  2  |  4  |  6  |  8  | 10  |
  1 |  1  |  2  |  3  |  4  |  5  |
    +-----+-----+-----+-----+-----+
      1     2     3     4     5     Likelihood
```

### Risk Tiers

| Score Range | Tier     | Response                                   |
|-------------|----------|--------------------------------------------|
| 1-4         | Low      | Accept or address in backlog               |
| 5-9         | Medium   | Address within current quarter             |
| 10-15       | High     | Address within current sprint              |
| 16-25       | Critical | Stop and fix before shipping               |

### Calibration Tips

- **Internet-facing services:** Shift likelihood up by 1 for any unauthenticated endpoint.
- **Internal tools:** Shift likelihood down by 1, but do not assume network isolation is sufficient.
- **Multi-tenant systems:** Shift impact up by 1 for any cross-tenant data exposure.
- **Stateless services:** Shift DoS impact down by 1 (easier to recover via restart/scaling).

---

## Integration with Other Frameworks

STRIDE does not exist in isolation. It feeds into and overlaps with several other security frameworks.

### STRIDE to PASTA (Process for Attack Simulation and Threat Analysis)

PASTA is a 7-stage risk-centric methodology. STRIDE maps into Stage 4 (Threat Analysis):

| PASTA Stage | Activity                        | STRIDE Role                          |
|-------------|---------------------------------|--------------------------------------|
| 1           | Define business objectives      | --                                   |
| 2           | Define technical scope          | DFD creation feeds directly into this |
| 3           | Application decomposition       | DFD leveling                         |
| 4           | **Threat analysis**             | **STRIDE categories applied here**   |
| 5           | Vulnerability analysis          | Map STRIDE findings to known CVEs    |
| 6           | Attack modeling                 | Attack trees from STRIDE findings    |
| 7           | Risk and impact analysis        | Risk matrix scoring                  |

Use STRIDE as the threat enumeration engine within a broader PASTA process when the organization requires business-risk alignment.

### STRIDE to OWASP Top 10

| STRIDE Category        | OWASP Top 10 (2021)                                      |
|------------------------|-----------------------------------------------------------|
| Spoofing               | A07: Identification and Authentication Failures           |
| Tampering              | A03: Injection; A08: Software and Data Integrity Failures |
| Repudiation            | A09: Security Logging and Monitoring Failures             |
| Information Disclosure | A01: Broken Access Control; A02: Cryptographic Failures   |
| Denial of Service      | (Not directly in Top 10; covered by A05: Security Misconfiguration) |
| Elevation of Privilege | A01: Broken Access Control                                |

This mapping is useful for translating STRIDE findings into OWASP remediation guidance, which has richer implementation detail.

### STRIDE to Compliance Frameworks

| Compliance Framework | Relevant STRIDE Categories                                |
|----------------------|-----------------------------------------------------------|
| SOC 2 (CC6, CC7)     | All -- maps to Common Criteria for logical access and system operations |
| ISO 27001 (A.9, A.12, A.14) | S (access control), T (integrity), I (cryptography) |
| NIST 800-53          | All -- STRIDE categories map to AC, AU, SC, SI, CP families |
| GDPR (Art. 32)       | T (integrity), I (confidentiality), D (availability)      |
| HIPAA Security Rule  | S (access control), I (transmission security), R (audit)  |

---

## Common Pitfalls

### 1. Threat Modeling Too Late

**Mistake:** Running STRIDE after implementation is complete. Findings become expensive change requests instead of design inputs.

**Fix:** Model during design, before code is written. Even a 30-minute whiteboard DFD session with 2-3 engineers catches critical issues early.

### 2. Boiling the Ocean

**Mistake:** Attempting to STRIDE every element in a complex system in a single session. The team burns out and the model is never finished.

**Fix:** Scope to a single trust boundary crossing or a single critical data flow per session. Iterate over multiple sessions.

### 3. Confusing Threats with Vulnerabilities

**Mistake:** Listing "SQL injection" as a threat. SQL injection is a vulnerability (a specific weakness). The threat is "Tampering with database records via untrusted input."

**Fix:** Frame threats as attacker goals ("An attacker could..."), not as specific CVEs or techniques. Map techniques to threats in attack trees.

### 4. Ignoring the Human Element

**Mistake:** Modeling only technical components. Ignoring support staff, contractors, or social engineering vectors.

**Fix:** Include human actors as external entities in the DFD. Apply Spoofing and Repudiation analysis to human processes (e.g., password reset via support ticket).

### 5. No Prioritization

**Mistake:** Generating 50+ threats and treating them all as equally urgent. The team is paralyzed and nothing gets fixed.

**Fix:** Score every threat with the risk matrix. Work the Critical and High tiers first. Accept Low-tier risks explicitly and document the rationale.

### 6. One-and-Done Modeling

**Mistake:** Treating the threat model as a point-in-time document that is never updated.

**Fix:** Re-run STRIDE when the architecture changes: new integrations, new data flows, new trust boundaries. Tie threat model reviews to architecture decision records (ADRs).

### 7. Skipping Trust Boundaries

**Mistake:** Drawing a DFD with no trust boundaries. Without them, every data flow looks equivalent and there is no basis for prioritizing which interactions to analyze.

**Fix:** Identify trust boundaries first, before adding processes or data flows. Common boundaries: internet/DMZ, DMZ/internal, service/database, user-space/kernel, your-code/third-party-code.

---

## References

- Shostack, Adam. *Threat Modeling: Designing for Security.* Wiley, 2014.
- Howard, Michael, and Steve Lipner. *The Security Development Lifecycle.* Microsoft Press, 2006.
- OWASP Threat Modeling Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html
- Microsoft Threat Modeling Tool: https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool
