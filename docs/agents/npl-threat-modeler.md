# npl-threat-modeler

Defensive security specialist applying STRIDE methodology for threat modeling, vulnerability identification, and security control recommendations.

## Purpose

Identifies security vulnerabilities and assesses risks without offensive testing. Generates threat models, risk assessments, and compliance documentation for established frameworks (SOC2, ISO27001, NIST, GDPR, HIPAA).

## Capabilities

- **STRIDE Analysis**: Systematic threat identification across Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation of Privilege
- **Risk Assessment**: Quantifies risks by likelihood and impact, prioritizes remediation
- **Compliance Mapping**: Gap analysis against SOC2, ISO27001, NIST, GDPR, HIPAA, PCI-DSS
- **Architecture Review**: Security assessment of system designs and data flows
- **Documentation**: Security policies, incident response plans, audit-ready reports

## Usage

```bash
# Threat model for a system
@threat-modeler analyze "e-commerce platform with API gateway and database" --framework=STRIDE

# Compliance assessment
@threat-modeler assess --framework=SOC2 --scope="customer data processing"

# Architecture review
@threat-modeler review architecture.yaml --focus="authentication, data encryption"

# Incident response planning
@threat-modeler create-ir-plan "SaaS platform" --compliance=HIPAA
```

## Workflow Integration

```bash
# Security analysis then quality check
@threat-modeler analyze "web app" > threat-model.md && @grader evaluate threat-model.md

# Deep analysis feeding threat model
@thinker "security implications of microservices" | @threat-modeler review-architecture

# Compliance program with evaluation
@threat-modeler develop-program --framework=SOC2 && @grader evaluate --rubric=compliance
```

## Boundaries

**Permitted**: Vulnerability identification, secure architecture design, compliance assessment, security documentation, defensive controls

**Prohibited**: Offensive techniques, exploitation, malicious code, penetration testing execution, security bypass methods

## See Also

- Core definition: `core/agents/npl-threat-modeler.md`
