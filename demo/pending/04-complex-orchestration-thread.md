# Complex Orchestration Thread Demo

## Prompt

Create a demonstration of Complex Multi-Agent Orchestration for the NPL project. Generate the following in demo/threads/multi-agent-orchestration.md:

Create a complete conversation thread showing:
1. User provides a flawed authentication module (with SQL injection, weak crypto, no rate limiting)
2. @npl-grader evaluates it (score: 68/100) with specific issues
3. @npl-threat-modeler performs STRIDE analysis finding critical vulnerabilities
4. @npl-technical-writer documents the security issues clearly
5. @npl-templater generates a secure authentication template
6. @npl-grader re-evaluates the new implementation (score: 94/100)

Format as a realistic Claude Code conversation with timestamps and clear agent handoffs. Show how each agent's output influences the next step.

## Expected Output Structure

```markdown
# Multi-Agent Orchestration Thread

## Session: Authentication Module Security Review
**Date:** 2024-01-15
**User:** Developer seeking security review

### Initial Request
**[09:15:23] User:**
I need help reviewing this authentication module. Can you check for security issues?

```python
# [flawed auth code here]
```

### Agent 1: Code Quality Assessment
**[09:15:45] @npl-grader:**
[Evaluation with 68/100 score, listing issues]

### Agent 2: Security Analysis
**[09:16:12] @npl-threat-modeler:**
[STRIDE analysis with critical findings]

### Agent 3: Documentation
**[09:16:38] @npl-technical-writer:**
[Clear security issue documentation]

### Agent 4: Secure Template Generation
**[09:17:05] @npl-templater:**
[Generated secure authentication template]

### Agent 5: Re-evaluation
**[09:17:32] @npl-grader:**
[New evaluation with 94/100 score]

### Summary
[Final recommendations and improvements achieved]
```

## Agent Sequence

1. @npl-grader (initial evaluation)
2. @npl-threat-modeler (STRIDE analysis)
3. @npl-technical-writer (document issues)
4. @npl-templater (secure template)
5. @npl-grader (re-evaluation)