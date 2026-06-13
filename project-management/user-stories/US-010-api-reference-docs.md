---
id: US-010
title: "Access API reference documentation"
slug: "api-reference-docs"
personas: [P-001, P-003, P-007]
epic: "Installation & Onboarding"
priority: "should-have"
complexity: "M"
tags: [documentation, api-reference, developer, autodoc]
---

# US-010: Access API Reference Documentation

## User Story

**As an** indie developer, AI researcher, or community contributor (P-001, P-003, P-007),
**I want to** browse a complete, auto-generated API reference for all NoizuRPG public classes and methods,
**So that** I can quickly look up method signatures, parameters, return types, and usage examples without reading source code.

## Acceptance Criteria

- [ ] Given I navigate to noizurpg.com/docs/api, when the page loads, then I see a navigable reference organized by module: `character`, `world`, `narrative`, `quest`, `dialogue`, `memory`.
- [ ] Given any public class in the API reference, when I view its entry, then I see: class description, constructor signature with typed parameters, all public methods with parameter types and return types, and at least one usage example per method.
- [ ] Given a method entry in the API reference, when I click the "Source" link, then I am taken to the corresponding line in the GitHub repository.
- [ ] Given a new PyPI release is published, when the docs CI pipeline runs, then the API reference at noizurpg.com/docs/api is automatically regenerated from the new source docstrings within 30 minutes of the release.
- [ ] Given a contributor (P-007) adding a new public method with a docstring following the project's docstring standard, when the API reference is regenerated, then the new method appears in the reference without manual intervention.
- [ ] Given the API reference, when I search for a class or method name using the page search (Ctrl+F or site search), then the matching entry is highlighted and scrolled into view.

## Notes

The API reference should be generated from source docstrings using a tool such as Sphinx or MkDocs with autodoc. James (P-003) needs the type annotations to be complete and accurate to use NoizuRPG in research code confidently. Ryan (P-007) needs the contributor workflow for docstrings to be documented in CONTRIBUTING.md. See US-007 for the broader documentation architecture.
