# Infrastructure Agents

Agents responsible for build systems, code quality, and rapid prototyping capabilities.

## Agents

### npl-build-manager
Orchestrates CI/CD pipelines, deployment automation, and build system configuration. Ensures reliable, repeatable deployments across environments.

### npl-code-reviewer
Enforces code quality standards, design patterns, and best practices. Conducts static analysis, security reviews, and architectural validation.

### npl-prototyper
Enables rapid development and experimental feature validation. Fast-tracks proof-of-concept development and quick iterations on ideas.

## Workflows

**Build Optimization Pipeline**
1. npl-prototyper: Create experimental branch
2. npl-code-reviewer: Validate design patterns
3. npl-build-manager: Configure CI/CD, run tests
4. Feedback loop: Iterate or promote to main

**Quality Gate Enforcement**
1. npl-code-reviewer: Pre-commit validation
2. npl-build-manager: Run comprehensive test suite
3. npl-prototyper: Handle edge cases (if prototype)

## Integration Points

- **Upstream**: tdd-coder (implementation), idea-to-spec (requirements)
- **Downstream**: npl-qa agents (testing), npl-validator (acceptance)
- **Peer collaboration**: npl-benchmarker (performance gates)

## Key Responsibilities

| Agent | Primary | Secondary |
|-------|---------|-----------|
| **build-manager** | CI/CD orchestration, deployment | Artifact management, rollback |
| **code-reviewer** | Design/pattern review, static analysis | Security scanning, complexity metrics |
| **prototyper** | Rapid iteration, PoC development | Experimental feature branches, spike resolution |
