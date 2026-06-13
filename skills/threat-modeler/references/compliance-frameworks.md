# Compliance Frameworks

Practical reference for engineering teams navigating SOC2, ISO 27001, NIST CSF, GDPR, and HIPAA. Focused on what you actually need to build and evidence, not policy theater.

---

## SOC2 Type II

SOC2 is an auditing standard developed by the AICPA that evaluates a service organization's controls over a 6-12 month observation period. Unlike Type I (point-in-time), Type II requires demonstrating that controls operated effectively over time. Required for any SaaS company selling to enterprises -- often the first compliance gate your sales team will hit.

### Trust Service Criteria

| Category | Key Controls | What It Means for Engineers |
|----------|-------------|----------------------------|
| Security (CC6) | Access controls, encryption, network security, vulnerability management | MFA, RBAC, TLS everywhere, patched dependencies, WAF |
| Availability (A1) | Uptime monitoring, capacity planning, disaster recovery | SLOs with evidence, health checks, failover testing |
| Processing Integrity (PI1) | Input validation, error handling, QA processes | Automated tests, data validation pipelines, change management |
| Confidentiality (C1) | Data classification, encryption at rest, access logging | Encrypted volumes, audit trails, least-privilege IAM |
| Privacy (P1-P8) | Consent, data retention, access requests, breach notification | Privacy policy enforcement, data deletion workflows, DSAR tooling |

### STRIDE Mapping

| STRIDE Category | Relevant Trust Criteria |
|----------------|------------------------|
| Spoofing | CC6.1 (logical access), CC6.6 (external threats) |
| Tampering | PI1.1 (processing integrity), CC6.1 (access controls) |
| Repudiation | CC7.2 (monitoring), CC7.3 (evaluation of events) |
| Information Disclosure | C1.1 (confidentiality), CC6.7 (data transmission) |
| Denial of Service | A1.1 (availability mechanisms), A1.2 (recovery) |
| Elevation of Privilege | CC6.1 (access controls), CC6.3 (role-based access) |

### Common Gaps for Small Teams

- No centralized audit logging (stdout to nowhere)
- Access reviews done never instead of quarterly
- Change management is "whoever pushes to main"
- No evidence of vulnerability scanning cadence
- Background checks skipped for contractors
- Incident response plan exists but was never tested

### Evidence Requirements

Auditors want: access review logs (quarterly), vulnerability scan reports, change management tickets, incident response test records, onboarding/offboarding checklists with timestamps, uptime dashboards, encryption configuration screenshots, and penetration test reports (annual).

---

## ISO 27001

ISO 27001 is an international standard for information security management systems (ISMS). Certification requires establishing a formal ISMS, conducting risk assessments, and implementing controls from Annex A. Common in European markets and government contracts. The 2022 revision reorganized controls from 14 domains to 4 themes.

### Control Themes (2022 Revision)

| Theme | Control Count | Key Areas |
|-------|--------------|-----------|
| Organizational | 37 | Policies, roles, asset management, supplier security, threat intelligence |
| People | 8 | Screening, terms of employment, awareness training, disciplinary process |
| Physical | 14 | Secure areas, equipment protection, clear desk, physical media |
| Technological | 34 | Access control, cryptography, endpoint security, secure development, logging |

### STRIDE Mapping

| STRIDE Category | Relevant Annex A Controls |
|----------------|--------------------------|
| Spoofing | A.8.5 (authentication), A.5.15 (access control) |
| Tampering | A.8.24 (cryptography), A.8.25 (secure development) |
| Repudiation | A.8.15 (logging), A.8.16 (monitoring) |
| Information Disclosure | A.8.10 (information deletion), A.8.11 (data masking), A.8.24 (cryptography) |
| Denial of Service | A.8.6 (capacity management), A.8.14 (redundancy) |
| Elevation of Privilege | A.8.2 (privileged access), A.8.3 (information access restriction) |

### Common Gaps for Small Teams

- No formal risk register (risks live in someone's head)
- ISMS documentation is a skeleton that nobody reads
- Management reviews never happen
- Internal audits skipped or done by the person who built the controls
- No supplier security assessments
- Corrective actions tracked informally or not at all

### Evidence Requirements

Auditors want: ISMS scope document, risk assessment methodology and register, Statement of Applicability (SoA), management review minutes, internal audit reports, corrective action records, training completion records, and control effectiveness measurements.

---

## NIST Cybersecurity Framework (CSF)

NIST CSF is a voluntary framework providing a common language for managing cybersecurity risk. Version 2.0 (2024) added a sixth function: Govern. Not a certification -- it is a risk management tool. Required for US federal contractors (via NIST 800-171/CMMC), widely adopted as a baseline across industries.

### Core Functions

| Function | Category Examples | What You Build |
|----------|------------------|----------------|
| Govern (GV) | Risk strategy, supply chain risk, roles | Risk appetite statement, RACI matrix, vendor review process |
| Identify (ID) | Asset management, risk assessment, business environment | Asset inventory, data flow diagrams, risk register |
| Protect (PR) | Access control, awareness training, data security | RBAC, security training, encryption, secure SDLC |
| Detect (DE) | Anomaly detection, continuous monitoring, detection processes | SIEM/alerting, log aggregation, IDS/IPS |
| Respond (RS) | Response planning, communications, analysis, mitigation | IR plan, communication templates, forensics capability |
| Recover (RC) | Recovery planning, improvements, communications | DR plan, backup verification, lessons learned process |

### STRIDE Mapping

| STRIDE Category | Relevant Functions/Categories |
|----------------|------------------------------|
| Spoofing | PR.AC (access control), PR.DS (data security) |
| Tampering | PR.DS (data security), DE.CM (continuous monitoring) |
| Repudiation | DE.AE (anomaly/event analysis), PR.DS (data security) |
| Information Disclosure | PR.AC (access control), PR.DS (data security) |
| Denial of Service | PR.PT (protective technology), DE.CM (continuous monitoring) |
| Elevation of Privilege | PR.AC (access control), DE.AE (anomaly detection) |

### Common Gaps for Small Teams

- Asset inventory is incomplete or nonexistent
- Risk assessments are one-time events, not ongoing
- Detection capabilities limited to application-level logging
- No formalized recovery testing (backups exist but untested)
- Govern function entirely absent -- no documented risk appetite

### Evidence Requirements

Not a certification, but when used as a baseline: current profile vs target profile gap analysis, asset inventory, risk assessment documentation, security architecture diagrams, detection rule inventory, IR plan, recovery test results, and training records.

---

## GDPR

The General Data Protection Regulation is EU law governing processing of personal data of EU residents. Applies to any organization processing EU personal data regardless of where the organization is based. Maximum fine: 4% of global annual turnover or 20M EUR, whichever is higher. Not optional if you have EU users.

### Key Requirement Areas

| Article/Area | Requirements | Engineering Impact |
|-------------|-------------|-------------------|
| Art. 5 - Processing Principles | Lawfulness, purpose limitation, data minimization, accuracy, storage limitation | Only collect what you need, document why, set retention policies |
| Art. 6 - Lawful Basis | Consent, contract, legal obligation, vital interest, public task, legitimate interest | Consent management system, legal basis documentation per data type |
| Art. 13-14 - Transparency | Privacy notices, data source disclosure | Privacy policy updates, in-app disclosures |
| Art. 15-22 - Data Subject Rights | Access, rectification, erasure, portability, objection, automated decision-making | DSAR API endpoints, data export tooling, deletion pipelines |
| Art. 25 - Privacy by Design | Data protection by design and default | Encryption defaults, minimal data collection, pseudonymization |
| Art. 32 - Security | Appropriate technical and organizational measures | Encryption, access controls, incident detection, resilience testing |
| Art. 33-34 - Breach Notification | 72-hour DPA notification, individual notification for high risk | Incident detection pipeline, breach assessment process, notification templates |
| Art. 35 - DPIA | Data Protection Impact Assessments for high-risk processing | DPIA template and process for new features |
| Art. 44-49 - International Transfers | Adequate safeguards for cross-border data transfers | SCCs, adequacy decisions, data residency controls |

### STRIDE Mapping

| STRIDE Category | Relevant GDPR Requirements |
|----------------|---------------------------|
| Spoofing | Art. 32 (security measures), Art. 5(1)(f) (integrity/confidentiality) |
| Tampering | Art. 5(1)(d) (accuracy), Art. 32 (integrity) |
| Repudiation | Art. 5(2) (accountability), Art. 30 (records of processing) |
| Information Disclosure | Art. 5(1)(f) (confidentiality), Art. 32 (encryption), Art. 33 (breach notification) |
| Denial of Service | Art. 32(1)(b) (availability and resilience) |
| Elevation of Privilege | Art. 32 (access controls), Art. 25 (privacy by design) |

### Common Gaps for Small Teams

- No Records of Processing Activities (Art. 30) documented
- Consent mechanism is a checkbox with no audit trail
- No DSAR fulfillment process -- requests handled ad hoc
- Data retention policy exists on paper but nothing auto-deletes
- Cross-border transfer mechanisms not evaluated after Schrems II
- No DPO appointed when one is required

### Evidence Requirements

Regulators want: Records of Processing Activities, consent logs with timestamps, DSAR fulfillment records with response times, DPIA documentation, data breach register, processor agreements (Art. 28), privacy notices, international transfer mechanisms, and DPO appointment records (if applicable).

---

## HIPAA

The Health Insurance Portability and Accountability Act governs protected health information (PHI) in the US healthcare system. Applies to covered entities (providers, insurers, clearinghouses) and their business associates. If your SaaS touches PHI -- even as a subprocessor -- you need a Business Associate Agreement and must comply with the Security Rule.

### Security Rule Safeguards

| Safeguard Type | Key Requirements | Engineering Impact |
|---------------|-----------------|-------------------|
| Administrative | Risk analysis, workforce training, contingency planning, BAAs | Annual risk assessment, security training, DR plan, vendor agreements |
| Physical | Facility access controls, workstation security, device controls | Badge access logs, disk encryption, mobile device management |
| Technical | Access control, audit controls, integrity controls, transmission security | Unique user IDs, audit logging, hashing, TLS for PHI in transit |

### STRIDE Mapping

| STRIDE Category | Relevant HIPAA Requirements |
|----------------|----------------------------|
| Spoofing | 164.312(d) (person/entity authentication), 164.312(a) (access control) |
| Tampering | 164.312(c) (integrity controls), 164.312(e) (transmission security) |
| Repudiation | 164.312(b) (audit controls), 164.316 (documentation) |
| Information Disclosure | 164.312(a) (access control), 164.312(e) (encryption), 164.502 (minimum necessary) |
| Denial of Service | 164.308(a)(7) (contingency plan), 164.310(a)(2)(ii) (facility security) |
| Elevation of Privilege | 164.312(a) (access control), 164.308(a)(4) (information access management) |

### Common Gaps for Small Teams

- No formal risk analysis (the single most cited HIPAA violation)
- Audit logs exist but nobody reviews them
- BAAs missing for cloud subprocessors (your database host, log aggregator, etc.)
- Encryption at rest not enabled on all PHI datastores
- No contingency plan or backup testing
- Workforce training is a one-time onboarding slide deck

### Evidence Requirements

Auditors/OCR want: documented risk analysis (annual), risk management plan, BAAs with all vendors touching PHI, workforce training records, audit log review evidence, contingency/DR test results, encryption documentation, access authorization records, and incident/breach documentation.

---

## Cross-Framework Comparison

Control areas that overlap across frameworks. Implementing once can satisfy multiple frameworks.

| Control Area | SOC2 | ISO 27001 | NIST CSF | GDPR | HIPAA |
|-------------|------|-----------|----------|------|-------|
| Access Control / RBAC | CC6.1-6.3 | A.5.15, A.8.2-3 | PR.AC | Art. 32 | 164.312(a) |
| Encryption (transit) | CC6.7 | A.8.24 | PR.DS | Art. 32 | 164.312(e) |
| Encryption (rest) | C1.1 | A.8.24 | PR.DS | Art. 32 | 164.312(a)(2)(iv) |
| Audit Logging | CC7.2 | A.8.15 | DE.AE | Art. 5(2) | 164.312(b) |
| Vulnerability Mgmt | CC7.1 | A.8.8 | DE.CM | Art. 32 | 164.308(a)(5)(ii)(B) |
| Incident Response | CC7.3-7.5 | A.5.24-5.28 | RS.RP | Art. 33-34 | 164.308(a)(6) |
| Change Management | CC8.1 | A.8.32 | PR.IP | Art. 25 | 164.308(a)(5)(ii)(C) |
| Risk Assessment | CC3.1-3.4 | 6.1, A.5.2 | ID.RA | Art. 35 | 164.308(a)(1)(ii)(A) |
| Backup/Recovery | A1.2 | A.8.13 | RC.RP | Art. 32(1)(c) | 164.308(a)(7) |
| Vendor Management | CC9.2 | A.5.19-5.22 | GV.SC | Art. 28 | 164.308(b) |
| Security Training | CC1.4 | A.6.3 | PR.AT | Art. 39 | 164.308(a)(5) |
| Data Retention | C1.2 | A.8.10 | PR.DS | Art. 5(1)(e) | 164.530(j) |

---

## Compliance for Startups

Minimum viable compliance for each framework -- what to implement first when you have 3 engineers and no compliance team.

### SOC2 -- Minimum Viable

1. **Use a compliance platform** (Vanta, Drata, Secureframe) -- automates 60-70% of evidence collection
2. **Enable SSO/MFA** on all SaaS tools and cloud accounts
3. **Centralize logging** -- ship everything to one place (Datadog, CloudWatch, Loki)
4. **Automated vulnerability scanning** -- Dependabot/Snyk on all repos, cloud config scanning
5. **Write 5 policies** -- InfoSec, Access Control, Incident Response, Change Management, Risk Assessment
6. **Quarterly access reviews** -- calendar reminder, screenshot evidence, 30 minutes
7. **Annual pen test** -- hire a firm, budget $5-15K

Timeline: 3-6 months to audit-ready. Cost: $15-40K (platform + auditor + pen test).

### ISO 27001 -- Minimum Viable

1. **Define ISMS scope** -- usually "the SaaS product and supporting infrastructure"
2. **Risk assessment** -- use a simple matrix (likelihood x impact), identify top 15 risks
3. **Statement of Applicability** -- list all Annex A controls, justify included/excluded
4. **Implement high-priority controls** -- access control, encryption, logging, vulnerability management
5. **Management review** -- quarterly 30-minute meeting with leadership, documented minutes
6. **Internal audit** -- can be done by someone not responsible for the controls (cross-team)

Timeline: 6-12 months. Cost: $20-50K (consulting + certification body audit).

### NIST CSF -- Minimum Viable

1. **Asset inventory** -- know what you have (services, data stores, APIs, third parties)
2. **Current profile** -- honestly assess your current state against the framework
3. **Target profile** -- pick the gaps that matter most for your risk context
4. **Action plan** -- prioritize by risk reduction per engineering hour
5. **Basic detection** -- alerting on auth failures, config changes, anomalous access patterns

Timeline: No certification. Ongoing risk management activity. Cost: Engineering time only.

### GDPR -- Minimum Viable

1. **Records of Processing Activities** -- spreadsheet listing what data, why, how long, who accesses
2. **Privacy policy** -- clear, specific, lists legal bases per processing purpose
3. **Consent mechanism** -- granular, logged, revocable
4. **DSAR process** -- documented procedure, can fulfill within 30 days
5. **Data Processing Agreements** -- signed with every processor (cloud, analytics, email, etc.)
6. **Breach notification process** -- know who your DPA is, have a 72-hour notification template ready

Timeline: 1-3 months for basics. Cost: $5-15K (legal review of policies + DPAs).

### HIPAA -- Minimum Viable

1. **Risk analysis** -- document all PHI flows, threats, and current controls (use NIST SP 800-30)
2. **BAAs** -- signed with every vendor that touches PHI (cloud provider, database host, logging)
3. **Encryption everywhere** -- at rest and in transit, no exceptions for PHI
4. **Access controls** -- unique user IDs, role-based access, automatic session timeout
5. **Audit logging** -- log all access to PHI, review logs periodically
6. **Workforce training** -- annual, documented, covers PHI handling and incident reporting
7. **Contingency plan** -- backup strategy, tested recovery procedure

Timeline: 3-6 months. Cost: $10-30K (risk analysis consulting + legal for BAAs).

---

## Key Takeaway

Start with the cross-framework overlap table. Implementing access control, encryption, logging, vulnerability management, and incident response gives you 60-70% coverage across all five frameworks. Build the framework-specific controls on top of that shared foundation.
