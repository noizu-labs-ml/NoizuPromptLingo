# DITA (Darwin Information Typing Architecture)

## Description
DITA is an XML-based standard for authoring, managing, and publishing modular technical documentation.
- Official site: https://www.dita-ot.org
- OASIS Standard: https://docs.oasis-open.org/dita/
- DITA Open Toolkit: https://www.dita-ot.org/download

## Topic-Based Structure
DITA organizes content into typed topics:
- **Concept**: Explanatory information
- **Task**: Step-by-step procedures
- **Reference**: Lookup information
- **Glossary**: Term definitions
- Maps organize topics into deliverables

## DITA-OT Processing
The DITA Open Toolkit transforms source content:
```xml
<task id="install">
  <title>Installing Software</title>
  <taskbody>
    <steps>
      <step><cmd>Download installer</cmd></step>
      <step><cmd>Run setup</cmd></step>
    </steps>
  </taskbody>
</task>
```

Output formats: PDF, HTML5, EPUB, Markdown, Word

## Strengths
- **Reusability**: Single-source content across outputs
- **Modular architecture**: Component-based documentation
- **Content/format separation**: Pure semantic markup
- **Conditional processing**: Audience-specific outputs
- **Translation-friendly**: Structured for localization
- **Industry standard**: Wide enterprise adoption

## Limitations
- **Complexity**: Steep learning curve
- **XML verbosity**: Heavy markup overhead
- **Tooling requirements**: Specialized editors needed
- **Initial setup cost**: Significant infrastructure
- **Rigidity**: Strict typing can constrain creativity

## Best For
- Enterprise technical documentation
- Multi-product documentation suites
- Highly regulated industries (aerospace, medical)
- Documentation requiring extensive reuse
- Multi-channel publishing workflows
- Teams with dedicated documentation infrastructure

## NPL-FIM Integration
```yaml
npl_fim:
  solution: dita
  capabilities:
    - topic_typing: Structured content classification
    - content_refs: Conref/keyref mechanisms
    - ditamaps: Hierarchical organization
    - specialization: Custom topic types
  rendering:
    transform: dita-ot
    outputs: [pdf, html5, epub, markdown]
  complexity: high
  enterprise_ready: true
```

DITA excels at enterprise-scale documentation with strong reuse requirements but requires significant investment in tooling and training.