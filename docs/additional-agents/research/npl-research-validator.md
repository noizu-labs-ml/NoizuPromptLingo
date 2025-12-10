# npl-research-validator

Academic validation framework agent for NPL research. Validates experimental designs, executes statistical analysis, and prepares research for peer review and publication.

## Purpose

Ensures NPL research meets academic standards through:

- Controlled experiment design with power analysis
- Statistical analysis with appropriate test selection
- Methodology validation for reproducibility
- Manuscript preparation for academic venues
- Replication package generation

## Usage

```bash
# Validate research protocol
@npl-research-validator protocol validate study-design.yaml

# Calculate sample size
@npl-research-validator power-analysis --effect-size=0.3 --power=0.8

# Review manuscript
@npl-research-validator manuscript review draft.md --venue=JAIR

# Execute statistical analysis
@npl-research-validator analyze --data=results.csv --corrections=bonferroni
```

## Workflow Integration

```bash
# Research validation pipeline
@npl-research-validator protocol create --design=RCT && \
@npl-research-validator ethics-package --institution=university

# Analysis with validation
@npl-performance-monitor experiment analyze && \
@npl-research-validator verify --data=results

# Publication preparation
@npl-research-validator manuscript review draft.md && \
@npl-technical-writer refine --style=academic
```

## Detailed Reference

For complete documentation, see [npl-research-validator.detailed.md](./npl-research-validator.detailed.md):

- [Agent Configuration](./npl-research-validator.detailed.md#agent-configuration) - YAML config and pump integration
- [NPL Pump Integration](./npl-research-validator.detailed.md#npl-pump-integration) - Intent, critique, reflection, methodology pumps
- [Empirical Testing Protocols](./npl-research-validator.detailed.md#empirical-testing-protocols) - RCTs, cross-validation, comparative studies
- [Statistical Analysis Methods](./npl-research-validator.detailed.md#statistical-analysis-methods) - Hypothesis testing, effect sizes, power analysis
- [Academic Publication Framework](./npl-research-validator.detailed.md#academic-publication-framework) - Manuscript structure, venues, reporting guidelines
- [Research Protocol Development](./npl-research-validator.detailed.md#research-protocol-development) - Protocol templates and validation checklists
- [Command Reference](./npl-research-validator.detailed.md#command-reference) - Complete CLI documentation
- [Configuration Options](./npl-research-validator.detailed.md#configuration-options) - Parameters and defaults
- [Response Patterns](./npl-research-validator.detailed.md#response-patterns) - Output format examples
- [Success Metrics](./npl-research-validator.detailed.md#success-metrics) - Validation criteria

## See Also

- Core definition: `core/additional-agents/research/npl-research-validator.md`
- [Research Agents Overview](./README.md)
- [npl-performance-monitor](./npl-performance-monitor.md)
