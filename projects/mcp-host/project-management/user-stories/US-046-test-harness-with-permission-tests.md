---
id: US-046
title: "Generated project includes test harness with permission boundary tests"
slug: "test-harness-permission-tests"
personas: [P-001, P-003]
epic: "MCP Jumpstart"
priority: "should-have"
complexity: "M"
tags: [mcp-jumpstart, scaffolding, testing, security]
---

# US-046: Generated Project Includes Test Harness with Permission Boundary Tests

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** the generated project to include a test harness with permission boundary tests,
**So that** I can verify that my tools enforce the dual-principal authorization model and catch privilege escalation vulnerabilities early.

## Acceptance Criteria

- [ ] Given a project is generated (US-041), when the user examines the test directory, then it includes a test framework setup with the language-appropriate runner (Vitest/Jest for TypeScript, pytest for Python, etc.).
- [ ] Given the test harness is included, when the user runs the test suite, then it executes unit tests for each generated tool handler stub (verifying they return the expected placeholder response).
- [ ] Given the test harness is included, when the user examines the permission boundary tests, then there are test cases for: unauthenticated access denial, caller-only access (no user principal), user-only access (no caller principal), and full dual-principal access granted.
- [ ] Given a permission boundary test runs, when it simulates a caller exceeding their scope, then the test verifies that the middleware rejects the invocation with the appropriate MCP error code.
- [ ] Given the test harness is included, when the user adds a new tool, then the test structure makes it straightforward to add corresponding unit and permission tests by following the existing patterns.
- [ ] Given the generated project README, when the user reads the testing section, then it explains how to run tests, how the permission boundary tests work, and how to add new test cases.

## Notes

Permission boundary tests encode the dual-principal model into the test suite, ensuring that security is tested by default not as an afterthought. The test helper utilities should make it easy to mock caller/user contexts. Related: US-043 (auth middleware), US-045 (CI pipeline runs these tests).
