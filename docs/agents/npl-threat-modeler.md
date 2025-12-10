# npl-threat-modeler

Defensive security specialist applying STRIDE methodology for threat modeling, vulnerability identification, and security control recommendations.

**Detailed reference**: [npl-threat-modeler.detailed.md](npl-threat-modeler.detailed.md)

## Purpose

Identifies security vulnerabilities and assesses risks without offensive testing. Generates threat models, risk assessments, and compliance documentation for established frameworks (SOC2, ISO27001, NIST, GDPR, HIPAA, PCI-DSS).

## Capabilities

| Capability | Description | Details |
|:-----------|:------------|:--------|
| STRIDE Analysis | Threat identification across 6 categories | [STRIDE Framework](npl-threat-modeler.detailed.md#stride-framework) |
| Risk Assessment | Quantified scoring by likelihood/impact | [Risk Scoring Matrix](npl-threat-modeler.detailed.md#risk-scoring-matrix) |
| Compliance Mapping | Gap analysis against regulatory frameworks | [Compliance Frameworks](npl-threat-modeler.detailed.md#compliance-frameworks) |
| Architecture Review | Security evaluation of system designs | [Architecture Review](npl-threat-modeler.detailed.md#architecture-review) |
| Documentation | Policies, IR plans, audit-ready reports | [Output Templates](npl-threat-modeler.detailed.md#output-templates) |

## Quick Start

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

See [Commands Reference](npl-threat-modeler.detailed.md#commands-reference) for all options.

## Configuration

| Option | Values |
|:-------|:-------|
| `--framework` | STRIDE, PASTA, OCTAVE |
| `--compliance` | SOC2, ISO27001, NIST, GDPR, HIPAA, PCI-DSS |
| `--risk-appetite` | conservative, balanced, aggressive |
| `--output-format` | executive, technical, audit |

See [Configuration Options](npl-threat-modeler.detailed.md#configuration-options) for complete list.

## Integration

```bash
# Security analysis then quality check
@threat-modeler analyze "web app" > threat-model.md && @grader evaluate threat-model.md

# Deep analysis feeding threat model
@thinker "security implications of microservices" | @threat-modeler review-architecture

# Compliance program with evaluation
@threat-modeler develop-program --framework=SOC2 && @grader evaluate --rubric=compliance
```

See [Integration Patterns](npl-threat-modeler.detailed.md#integration-patterns) for CI/CD examples.

## Boundaries

**Permitted**: Vulnerability identification, secure architecture design, compliance assessment, security documentation, defensive controls

**Prohibited**: Offensive techniques, exploitation, malicious code, penetration testing execution, security bypass methods

## See Also

- [Threat Modeling Methodologies](npl-threat-modeler.detailed.md#threat-modeling-methodologies) - STRIDE, PASTA, OCTAVE comparison
- [Best Practices](npl-threat-modeler.detailed.md#best-practices)
- [Limitations](npl-threat-modeler.detailed.md#limitations)
- Core definition: `core/agents/npl-threat-modeler.md`
