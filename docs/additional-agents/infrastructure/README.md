# Infrastructure Agents

Infrastructure agents provide essential development lifecycle support, handling code quality, build processes, and rapid prototyping. These agents integrate seamlessly into CI/CD pipelines and development workflows.

## Agent Overview

### npl-code-reviewer
**Purpose**: Automated code review with multi-perspective analysis

The code reviewer agent performs comprehensive code analysis across multiple dimensions including security, performance, maintainability, and correctness. It generates structured feedback using NPL critique and rubric systems, supporting both inline annotations and summary reports.

**Key Capabilities**:
- Multi-lens review (security, performance, style, architecture)
- Inline annotation support
- PR-ready feedback generation
- Customizable review criteria via templates

### npl-build-manager
**Purpose**: Build orchestration and dependency management

The build manager agent handles complex build processes, dependency resolution, and deployment workflows. It understands multiple build systems and can orchestrate multi-stage builds across different environments.

**Key Capabilities**:
- Multi-language build system support
- Dependency conflict resolution
- Build optimization recommendations
- Deployment pipeline configuration

### npl-prototyper
**Purpose**: Rapid prototype generation from specifications

The prototyper agent transforms high-level requirements into working code prototypes. It generates boilerplate, scaffolding, and initial implementations that follow project conventions and best practices.

**Key Capabilities**:
- Specification-to-code generation
- Framework-aware scaffolding
- API stub generation
- Interactive refinement support

## Infrastructure Support Features

### Development Workflow Integration
All infrastructure agents integrate into standard development workflows:

- **Pre-commit hooks**: Code review before commits
- **PR automation**: Automated review comments and build checks
- **IDE integration**: Real-time feedback during development
- **CLI tools**: Standalone operation for scripts and automation

### Quality Gates
Infrastructure agents enforce quality standards:

```yaml
quality_gates:
  code_review:
    - security_score: ">= 8"
    - test_coverage: ">= 80%"
    - complexity: "< 10"
  build:
    - tests: "all_passing"
    - linting: "no_errors"
    - dependencies: "no_conflicts"
```

## Templaterized Customization

All infrastructure agents support dynamic customization through NPL templates:

### Review Criteria Templates
```npl
{{#if project.type == "security-critical"}}
  - emphasis: security_vulnerabilities
  - require: threat_modeling
{{/if}}

{{#if project.language == "rust"}}
  - check: memory_safety
  - check: ownership_patterns
{{/if}}
```

### Build Configuration Templates
```npl
{{#each environments}}
  stage: {{name}}
  steps:
    {{#if needs_testing}}
    - run: test_suite
    {{/if}}
    - run: build_{{target}}
{{/each}}
```

### Prototype Generation Templates
```npl
{{#if framework == "fastapi"}}
  generate:
    - api_routes: {{endpoints}}
    - models: {{data_models}}
    - middleware: {{security_requirements}}
{{/if}}
```

## CI/CD Integration Examples

### GitHub Actions Integration
```yaml
name: NPL Infrastructure Pipeline

on: [push, pull_request]

jobs:
  code-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: NPL Code Review
        run: |
          npl-code-reviewer analyze \
            --mode=pr \
            --output=github-comments \
            --criteria=.npl/review-criteria.yaml

  build-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: NPL Build Manager
        run: |
          npl-build-manager validate \
            --config=.npl/build-config.yaml \
            --environment=ci \
            --fail-on-warning

  prototype-validation:
    runs-on: ubuntu-latest
    if: contains(github.event.pull_request.labels.*.name, 'prototype')
    steps:
      - uses: actions/checkout@v3
      - name: Validate Prototype
        run: |
          npl-prototyper validate \
            --spec=specs/prototype.yaml \
            --check-completeness
```

### GitLab CI Integration
```yaml
stages:
  - review
  - build
  - prototype

npl-code-review:
  stage: review
  script:
    - npl-code-reviewer analyze --mode=gitlab-mr
  artifacts:
    reports:
      codequality: code-review-report.json

npl-build:
  stage: build
  script:
    - npl-build-manager execute --stage=ci
  artifacts:
    paths:
      - dist/

npl-prototype:
  stage: prototype
  when: manual
  script:
    - npl-prototyper generate --from=requirements.md
```

### Jenkins Pipeline Integration
```groovy
pipeline {
    agent any
    
    stages {
        stage('Code Review') {
            steps {
                sh 'npl-code-reviewer analyze --jenkins-format'
                recordIssues(
                    enabledForFailure: true,
                    tools: [nplCodeReview()]
                )
            }
        }
        
        stage('Build Management') {
            steps {
                sh 'npl-build-manager orchestrate --parallel'
                archiveArtifacts artifacts: 'build/**/*'
            }
        }
        
        stage('Prototype Generation') {
            when {
                branch 'feature/prototype-*'
            }
            steps {
                sh 'npl-prototyper generate --interactive=false'
            }
        }
    }
}
```

## Usage Examples

### Code Review with Custom Criteria
```bash
# Review with security focus
npl-code-reviewer analyze src/ \
  --lens=security \
  --output=markdown \
  --severity=high

# Multi-perspective review
npl-code-reviewer analyze \
  --lenses=security,performance,maintainability \
  --aggregate=weighted
```

### Build Orchestration
```bash
# Orchestrate multi-stage build
npl-build-manager orchestrate \
  --stages=test,build,package \
  --parallel=true \
  --cache=aggressive

# Dependency resolution
npl-build-manager resolve-deps \
  --strategy=minimal \
  --security-check=true
```

### Rapid Prototyping
```bash
# Generate from specification
npl-prototyper generate \
  --spec=api-spec.yaml \
  --framework=fastapi \
  --include-tests

# Interactive refinement
npl-prototyper refine \
  --prototype=./generated \
  --requirements=additional-reqs.md
```

## Configuration

### Global Infrastructure Config
```yaml
# .npl/infrastructure.yaml
agents:
  code-reviewer:
    default_lenses: [security, performance]
    output_format: github
    severity_threshold: medium
    
  build-manager:
    build_system: gradle
    environments:
      - dev
      - staging
      - prod
    optimization: aggressive
    
  prototyper:
    framework: spring-boot
    conventions: company-standard
    test_generation: true
```

## Integration with Other NPL Agents

Infrastructure agents work seamlessly with other NPL agents:

- **With npl-technical-writer**: Generate documentation from code reviews
- **With npl-grader**: Evaluate code quality against rubrics
- **With npl-persona**: Multiple reviewer perspectives
- **With npl-thinker**: Complex build optimization strategies

## Best Practices

1. **Version Control Integration**: Always integrate with VCS hooks
2. **Incremental Reviews**: Review changes, not entire codebases
3. **Build Caching**: Leverage build caches for efficiency
4. **Prototype Iteration**: Use prototypes as starting points, not final code
5. **Custom Templates**: Create project-specific review and build templates
6. **Pipeline Integration**: Embed agents in CI/CD pipelines
7. **Feedback Loops**: Use agent output to improve development practices

## Individual Agent Documentation

For detailed information about each agent:

- [npl-code-reviewer Documentation](./npl-code-reviewer.md)
- [npl-build-manager Documentation](./npl-build-manager.md)
- [npl-prototyper Documentation](./npl-prototyper.md)

## Support and Contribution

Infrastructure agents are part of the NPL ecosystem. For support, feature requests, or contributions, refer to the main NPL documentation and contribution guidelines.