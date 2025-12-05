# PROJECT-LAYOUT.md Specification
Convention specification for documenting project directory structures to enable effective LLM navigation.

## NPL Dependencies

You must run the following command to proceed:

```bash
npl-load c "syntax,fences,directive,formatting.template" --skip {@npl.def.loaded}
```

### See Also
- `npl-load c "fences"` - Fence type reference
- `npl-load c "syntax"` - Core syntax elements

---

## Purpose
This specification defines how to structure PROJECT-LAYOUT.md files that help language models understand and navigate codebases efficiently. A well-structured layout document reduces context-building overhead and enables precise file location.

## Document Structure

### Required Sections
Every PROJECT-LAYOUT.md must include these sections in order:

1. Directory Structure Overview
2. Core Application Layer
3. Web/API Layer
4. Database Layer
5. Configuration
6. Testing
7. Assets/Frontend
8. Infrastructure
9. Key Files Reference
10. Naming Conventions
11. Quick Reference Guide

### Section Specifications

---

## 1. Directory Structure Overview

**purpose**
: Provide a visual tree diagram showing the project's top-level organization (2-3 levels deep)

**required-content**
: Tree diagram with brief inline annotations explaining each directory's role

**npl-syntax**
: Use `tree` fence type with inline comments

### Tree Diagram Conventions

**indentation**
: Use standard tree characters for visual hierarchy

**annotations**
: Add brief comments after directory names using `#` prefix

**depth**
: Show 2-3 levels; use `...` for deeper structures

**grouping**
: Group related directories together visually

```syntax
```tree
project-name/
|-- src/                    # Core application source
|   |-- domain/             # Business logic and entities
|   |-- services/           # Application services
|   `-- utils/              # Shared utilities
|-- config/                 # Configuration files
|-- tests/                  # Test suites
|   |-- unit/               # Unit tests
|   `-- integration/        # Integration tests
|-- docs/                   # Documentation
`-- scripts/                # Build and utility scripts
```
```

### Annotation Style Guide

**concise**
: Keep annotations to 3-5 words maximum

**functional**
: Describe what the directory contains, not how it works

**consistent**
: Use parallel grammatical structure across annotations

```example
# Good annotations
|-- src/                    # Core application source
|-- lib/                    # Third-party integrations
|-- config/                 # Environment configuration

# Poor annotations (too verbose or inconsistent)
|-- src/                    # This is where all the main code lives
|-- lib/                    # libraries
|-- config/                 # Contains YAML and JSON config files for different environments
```

---

## 2. Core Application Layer

**purpose**
: Detail the primary source code organization (`lib/`, `src/`, or `app/` depending on framework)

**required-content**
: - Subdirectory breakdown with file purposes
: - Key module descriptions
: - Dependency flow between components

**optional-content**
: - Architecture pattern explanation (MVC, hexagonal, etc.)
: - Module initialization order

**npl-syntax**
: Use definition lists for directory descriptions; nested tree diagrams for complex structures

```format
## Core Application

**location**
: `<primary-source-path>/`

**architecture**
: <pattern-name|brief description>

### Directory Breakdown

**<subdirectory>/**
: <purpose description>
: Key files: `<file1>`, `<file2>`, ...

[...|additional subdirectories following same pattern]

### Component Dependencies

```diagram
[Component A] --> [Component B] --> [Component C]
                       |
                       v
                 [Component D]
```
```

```example
## Core Application

**location**
: `lib/my_app/`

**architecture**
: Domain-Driven Design with bounded contexts

### Directory Breakdown

**accounts/**
: User authentication and authorization logic
: Key files: `user.ex`, `auth.ex`, `permissions.ex`

**catalog/**
: Product management and inventory
: Key files: `product.ex`, `category.ex`, `inventory.ex`

**orders/**
: Order processing and fulfillment
: Key files: `order.ex`, `line_item.ex`, `checkout.ex`

### Component Dependencies

```diagram
[Accounts] --> [Orders] --> [Catalog]
                  |
                  v
            [Notifications]
```
```

---

## 3. Web/API Layer

**purpose**
: Document HTTP interface structure including controllers, views, routes, and middleware

**required-content**
: - Controller organization and naming
: - Route file locations
: - View/template structure
: - API versioning scheme (if applicable)

**optional-content**
: - Middleware pipeline order
: - Authentication/authorization flow
: - Request/response transformation

**npl-syntax**
: Use tables for route mappings; definition lists for component descriptions

```format
## Web/API Layer

**location**
: `<web-layer-path>/`

### Controllers

**<controller-group>/**
: <responsibility description>
: Routes: `<route-pattern>`

[...|additional controller groups]

### Route Organization

| File | Purpose | Prefix |
|:-----|:--------|:-------|
| `<route-file>` | <description> | `<url-prefix>` |
[...|additional routes]

### Views/Templates

**<template-group>/**
: <purpose and rendering context>
```

```example
## Web/API Layer

**location**
: `lib/my_app_web/`

### Controllers

**api/v1/**
: REST API endpoints for mobile and third-party clients
: Routes: `/api/v1/*`

**admin/**
: Internal administration interface
: Routes: `/admin/*`

**public/**
: Customer-facing web pages
: Routes: `/*`

### Route Organization

| File | Purpose | Prefix |
|:-----|:--------|:-------|
| `router.ex` | Main routing table | `/` |
| `api_router.ex` | API-specific routes | `/api` |
| `admin_router.ex` | Admin panel routes | `/admin` |

### Views/Templates

**layouts/**
: Base HTML layouts (app, admin, email)

**components/**
: Reusable UI components (buttons, forms, cards)

**pages/**
: Full page templates organized by feature
```

---

## 4. Database Layer

**purpose**
: Document database-related files including migrations, seeds, schemas, and queries

**required-content**
: - Migration file location and naming convention
: - Schema/model definitions location
: - Seed data organization

**optional-content**
: - Query organization (repositories, queries directory)
: - Database-specific adapters
: - Migration versioning strategy

**npl-syntax**
: Use definition lists; include migration naming pattern examples

```format
## Database Layer

### Migrations

**location**
: `<migrations-path>/`

**naming-convention**
: `<pattern-description>`

**example**
: `<sample-migration-filename>`

### Schemas/Models

**location**
: `<schemas-path>/`

**organization**
: <how schemas are organized - by domain, alphabetically, etc.>

### Seeds

**location**
: `<seeds-path>/`

**execution**
: `<command to run seeds>`

[...|additional database components as needed]
```

```example
## Database Layer

### Migrations

**location**
: `priv/repo/migrations/`

**naming-convention**
: `YYYYMMDDHHMMSS_description_of_change.exs`

**example**
: `20240115143022_create_users_table.exs`

### Schemas/Models

**location**
: `lib/my_app/` (co-located with domain contexts)

**organization**
: Schemas live within their bounded context directories

### Seeds

**location**
: `priv/repo/seeds.exs`

**execution**
: `mix run priv/repo/seeds.exs`

### Queries

**location**
: `lib/my_app/queries/`

**organization**
: One query module per aggregate root
```

---

## 5. Configuration

**purpose**
: Document configuration file purposes, hierarchy, and environment handling

**required-content**
: - Configuration file inventory with purposes
: - Environment-specific override mechanism
: - Secrets management approach

**optional-content**
: - Configuration loading order
: - Runtime vs compile-time configuration
: - Feature flag locations

**npl-syntax**
: Use tables for file inventory; definition lists for detailed explanations

```format
## Configuration

### Configuration Files

| File | Purpose | Environment |
|:-----|:--------|:------------|
| `<filename>` | <purpose> | <all/dev/prod/test> |
[...|additional config files]

### Environment Handling

**mechanism**
: <how environment-specific config is loaded>

**hierarchy**
: <config precedence order>

### Secrets Management

**approach**
: <how secrets are handled - env vars, vault, etc.>

**location**
: <where secret references are defined>
```

```example
## Configuration

### Configuration Files

| File | Purpose | Environment |
|:-----|:--------|:------------|
| `config/config.exs` | Base configuration | All |
| `config/dev.exs` | Development overrides | Dev |
| `config/prod.exs` | Production settings | Prod |
| `config/test.exs` | Test configuration | Test |
| `config/runtime.exs` | Runtime configuration | All |

### Environment Handling

**mechanism**
: Import chain with environment-specific files loaded after base config

**hierarchy**
: `config.exs` -> `{env}.exs` -> `runtime.exs`

### Secrets Management

**approach**
: Environment variables with fallback defaults for development

**location**
: Secret references in `config/runtime.exs`
```

---

## 6. Testing

**purpose**
: Document test organization, patterns, and execution

**required-content**
: - Test directory structure
: - Test type locations (unit, integration, e2e)
: - Test file naming conventions

**optional-content**
: - Fixture/factory locations
: - Test helper modules
: - Coverage configuration

**npl-syntax**
: Use tree diagrams for structure; definition lists for conventions

```format
## Testing

### Test Structure

```tree
tests/
|-- unit/                   # <description>
|-- integration/            # <description>
|-- e2e/                    # <description>
|-- fixtures/               # <description>
`-- support/                # <description>
```

### Conventions

**file-naming**
: `<pattern-description>`

**test-naming**
: `<pattern-description>`

### Test Helpers

**location**
: `<helpers-path>/`

**purpose**
: <what helpers provide>

### Running Tests

| Command | Purpose |
|:--------|:--------|
| `<command>` | <description> |
[...|additional commands]
```

```example
## Testing

### Test Structure

```tree
test/
|-- my_app/                 # Unit tests mirroring lib/my_app
|-- my_app_web/             # Controller and view tests
|-- integration/            # Cross-module integration tests
|-- support/                # Test helpers and fixtures
`-- test_helper.exs         # Test configuration
```

### Conventions

**file-naming**
: `<module_name>_test.exs` mirroring source file path

**test-naming**
: `describe` blocks for function names, `test` for specific behaviors

### Test Helpers

**location**
: `test/support/`

**purpose**
: Factory functions, connection setup, authentication helpers

### Running Tests

| Command | Purpose |
|:--------|:--------|
| `mix test` | Run all tests |
| `mix test test/my_app/` | Run unit tests only |
| `mix test --cover` | Run with coverage report |
```

---

## 7. Assets/Frontend

**purpose**
: Document frontend asset organization, build pipeline, and static file handling

**required-content**
: - Asset directory structure
: - Build tool configuration location
: - Output directory for compiled assets

**optional-content**
: - JavaScript module organization
: - CSS/styling architecture
: - Image and font handling
: - Third-party asset management

**npl-syntax**
: Use tree diagrams; definition lists for build configuration

```format
## Assets/Frontend

### Asset Structure

```tree
assets/
|-- js/                     # <description>
|-- css/                    # <description>
|-- static/                 # <description>
`-- vendor/                 # <description>
```

### Build Pipeline

**tool**
: <build tool name>

**config**
: `<config-file-path>`

**output**
: `<compiled-assets-path>/`

### Static Files

**location**
: `<static-files-path>/`

**served-at**
: `<url-path>`

[...|additional frontend details as needed]
```

```example
## Assets/Frontend

### Asset Structure

```tree
assets/
|-- js/
|   |-- app.js              # Main entry point
|   |-- hooks/              # LiveView hooks
|   `-- vendor/             # Third-party JS
|-- css/
|   |-- app.css             # Main stylesheet
|   `-- components/         # Component styles
`-- static/
    |-- images/             # Image assets
    `-- fonts/              # Custom fonts
```

### Build Pipeline

**tool**
: esbuild + tailwind

**config**
: `config/config.exs` (esbuild/tailwind sections)

**output**
: `priv/static/assets/`

### Static Files

**location**
: `priv/static/`

**served-at**
: `/` (root path)
```

---

## 8. Infrastructure

**purpose**
: Document deployment, containerization, and CI/CD configuration

**required-content**
: - Docker/container file locations
: - CI/CD configuration files
: - Deployment script locations

**optional-content**
: - Infrastructure as code (Terraform, Pulumi)
: - Kubernetes manifests
: - Environment provisioning scripts
: - Monitoring/observability configuration

**npl-syntax**
: Use tables for file inventory; definition lists for detailed explanations

```format
## Infrastructure

### Container Configuration

| File | Purpose |
|:-----|:--------|
| `<filename>` | <purpose> |
[...|additional container files]

### CI/CD

**platform**
: <CI/CD platform name>

**config**
: `<config-file-path>`

**pipelines**
: <brief description of pipeline stages>

### Deployment

**method**
: <deployment approach>

**scripts**
: `<scripts-location>/`

[...|additional infrastructure components]
```

```example
## Infrastructure

### Container Configuration

| File | Purpose |
|:-----|:--------|
| `Dockerfile` | Production container image |
| `Dockerfile.dev` | Development container with hot reload |
| `docker-compose.yml` | Local development stack |
| `docker-compose.test.yml` | Test environment stack |

### CI/CD

**platform**
: GitHub Actions

**config**
: `.github/workflows/`

**pipelines**
: `ci.yml` (test/lint), `deploy.yml` (staging/production)

### Deployment

**method**
: Container deployment to Kubernetes

**scripts**
: `scripts/deploy/`

### Infrastructure as Code

**location**
: `infrastructure/`

**tool**
: Terraform

**environments**
: `infrastructure/environments/{staging,production}/`
```

---

## 9. Key Files Reference

**purpose**
: Provide a quick-reference table of critical entry points and configuration files

**required-content**
: - Application entry points
: - Main configuration files
: - Critical startup/bootstrap files

**npl-syntax**
: Use table with file path, purpose, and when-to-edit columns

```format
## Key Files Reference

| File | Purpose | Edit When |
|:-----|:--------|:----------|
| `<file-path>` | <purpose> | <trigger for editing> |
[...|10-20 key files]
```

```example
## Key Files Reference

| File | Purpose | Edit When |
|:-----|:--------|:----------|
| `mix.exs` | Project definition and dependencies | Adding dependencies, changing versions |
| `lib/my_app/application.ex` | Application supervision tree | Adding supervised processes |
| `lib/my_app_web/router.ex` | HTTP route definitions | Adding new routes or pipelines |
| `lib/my_app_web/endpoint.ex` | HTTP endpoint configuration | Changing middleware or plugs |
| `config/runtime.exs` | Runtime configuration | Adding environment variables |
| `priv/repo/migrations/` | Database migrations | Changing database schema |
| `.github/workflows/ci.yml` | CI pipeline definition | Modifying build/test steps |
| `Dockerfile` | Container image definition | Changing build or runtime setup |
| `assets/js/app.js` | JavaScript entry point | Adding JS dependencies or hooks |
| `assets/css/app.css` | Main stylesheet | Global style changes |
```

---

## 10. Naming Conventions

**purpose**
: Document file and directory naming patterns used throughout the project

**required-content**
: - File naming patterns by type (controllers, models, tests, etc.)
: - Directory naming conventions
: - Case conventions (snake_case, PascalCase, kebab-case)

**optional-content**
: - Abbreviation standards
: - Prefix/suffix conventions
: - Prohibited patterns

**npl-syntax**
: Use definition lists grouped by file type; include pattern examples

```format
## Naming Conventions

### File Naming

**<file-type>**
: Pattern: `<naming-pattern>`
: Example: `<concrete-example>`

[...|additional file types]

### Directory Naming

**convention**
: <case-style and rules>

**examples**
: `<example1>`, `<example2>`, ...

### Case Conventions

| Context | Convention | Example |
|:--------|:-----------|:--------|
| <context> | <case-style> | `<example>` |
[...|additional contexts]
```

```example
## Naming Conventions

### File Naming

**schemas**
: Pattern: `<singular_noun>.ex`
: Example: `user.ex`, `order.ex`, `product_variant.ex`

**controllers**
: Pattern: `<resource>_controller.ex`
: Example: `user_controller.ex`, `session_controller.ex`

**views**
: Pattern: `<resource>_view.ex` or `<resource>_html.ex`
: Example: `user_html.ex`, `page_html.ex`

**tests**
: Pattern: `<source_file>_test.exs`
: Example: `user_test.exs`, `user_controller_test.exs`

**migrations**
: Pattern: `YYYYMMDDHHMMSS_<action>_<table>.exs`
: Example: `20240115143022_create_users.exs`

### Directory Naming

**convention**
: snake_case for all directories

**examples**
: `user_management/`, `order_processing/`, `admin_panel/`

### Case Conventions

| Context | Convention | Example |
|:--------|:-----------|:--------|
| Modules | PascalCase | `UserController` |
| Functions | snake_case | `get_user_by_id` |
| Files | snake_case | `user_controller.ex` |
| Database tables | snake_case plural | `users`, `order_items` |
| URLs | kebab-case | `/user-settings` |
```

---

## 11. Quick Reference Guide

**purpose**
: Provide a "Finding Files" guide for common development tasks

**required-content**
: - Task-to-location mapping
: - Common modification scenarios
: - Search patterns for finding related files

**npl-syntax**
: Use definition lists organized by task category

```format
## Quick Reference

### Finding Files by Task

**<common-task>**
: Look in: `<location(s)>`
: Related: `<related-locations>`

[...|additional tasks]

### Common Modifications

**to <modification-goal>**
: Primary: `<primary-file-to-edit>`
: Also update: `<related-files>`

[...|additional modifications]

### Search Patterns

| To Find | Search For |
|:--------|:-----------|
| <target> | `<search-pattern>` |
[...|additional patterns]
```

```example
## Quick Reference

### Finding Files by Task

**add a new API endpoint**
: Look in: `lib/my_app_web/controllers/api/`, `lib/my_app_web/router.ex`
: Related: `test/my_app_web/controllers/api/`

**create a new database table**
: Look in: `priv/repo/migrations/`
: Related: `lib/my_app/<context>/`, schema files

**add a background job**
: Look in: `lib/my_app/workers/`
: Related: `lib/my_app/application.ex` (supervision tree)

**modify authentication**
: Look in: `lib/my_app/accounts/`, `lib/my_app_web/plugs/`
: Related: `lib/my_app_web/router.ex` (pipelines)

**add frontend interactivity**
: Look in: `assets/js/hooks/`, `assets/js/app.js`
: Related: LiveView files in `lib/my_app_web/live/`

**change email templates**
: Look in: `lib/my_app_web/templates/email/`
: Related: `lib/my_app/mailer.ex`

### Common Modifications

**to add a new dependency**
: Primary: `mix.exs`
: Also update: Run `mix deps.get`

**to add environment configuration**
: Primary: `config/runtime.exs`
: Also update: `.env.example`, deployment configs

**to add a new route**
: Primary: `lib/my_app_web/router.ex`
: Also update: Create controller, add tests

### Search Patterns

| To Find | Search For |
|:--------|:-----------|
| All controllers | `*_controller.ex` |
| All migrations | `priv/repo/migrations/*.exs` |
| Tests for a module | `test/**/<module_name>_test.exs` |
| Schema definitions | `schema "` in `lib/` |
| Route definitions | `scope\|pipe_through\|get\|post` in router |
```

---

## Document Metadata

### Header Format

Every PROJECT-LAYOUT.md should begin with:

```format
# Project Layout: <project-name>

**framework**
: <primary-framework>

**language**
: <primary-language>

**last-updated**
: <YYYY-MM-DD>

**architecture**
: <architectural-pattern>

---
```

### Maintenance Notes

**update-triggers**
: - Major structural changes
: - New top-level directories added
: - Framework version upgrades
: - Architecture pattern changes

**review-frequency**
: Quarterly or with major releases

---

## Validation Checklist

Use this checklist to validate PROJECT-LAYOUT.md completeness:

- [ ] Tree diagram shows 2-3 levels with annotations
- [ ] All 11 required sections present
- [ ] Definition lists use correct NPL syntax
- [ ] Tables have consistent column alignment
- [ ] File paths are accurate and up-to-date
- [ ] Naming conventions match actual project patterns
- [ ] Quick reference covers common development tasks
- [ ] Examples are concrete and project-specific
- [ ] No placeholder content remains (`<...>` replaced with actuals)
- [ ] Document header includes framework and last-updated date

---

## Framework-Specific Adaptations

### Web Frameworks

**Rails**
: Core Application in `app/`, Web Layer includes `app/controllers/`, `app/views/`

**Django**
: Core Application in `<project>/`, each app is a subdirectory

**Phoenix**
: Core Application in `lib/<app>/`, Web Layer in `lib/<app>_web/`

**Next.js**
: Core Application in `src/` or root, Web Layer in `pages/` or `app/`

**Express**
: Core Application in `src/`, Web Layer in `src/routes/`, `src/controllers/`

### Adapt Section Names

When framework conventions differ significantly:
- Rename sections to match framework terminology
- Add framework-specific sections as needed
- Remove irrelevant sections (e.g., no Database Layer for static sites)
- Note framework version in header metadata

---

## See Also

- `${NPL_HOME}/npl/formatting.md` - Output formatting patterns
- `${NPL_HOME}/npl/fences.md` - Fence type reference
- `${NPL_HOME}/npl/syntax.md` - Core NPL syntax elements
