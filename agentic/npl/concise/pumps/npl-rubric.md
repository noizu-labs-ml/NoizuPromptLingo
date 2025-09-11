# NPL Rubric (npl-rubric)

**Purpose**: Define evaluation criteria and quality standards

**Syntax**:
```
<npl-rubric>
criteria:
  - dimension: "[evaluation aspect]"
    standards: "[quality levels/requirements]"
    indicators: "[observable measures]"
</npl-rubric>
```

**Usage**: Establish clear evaluation frameworks before beginning complex tasks.

**Example**:
```
<npl-rubric>
criteria:
  - dimension: "Code Quality"
    standards: "Clean, maintainable, well-documented"
    indicators: "Follows PEP 8, has docstrings, passes linting"
  - dimension: "Performance"
    standards: "Sub-100ms response time"
    indicators: "Load test results, profiling metrics"
</npl-rubric>
```