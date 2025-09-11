```@npl-templater
This is a template for a npl enabled CLAUDE.md file. Your task is to analyze the current project you are in and based on its content and the formatting instructions in this file generate a CLAUDE.npl.md realization of this template.
---
```

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

[...2-3p| State the intended purpose, ownership and basic stack details of this project.]

## Support MCPs and scripts
[...|scan .claude/scripts and .claude/mcp to provide information on whats available. head the files -n 20 to see if there are readms if not read the whole file for context.]

## Architecture Overview

````@npl-templater
Architecture Overview Section: 1-2 paragraph description, list of key areas, maybe some small diagrams should be put here based on your analysis of this project.

For this section: Give a basic outline of how this project is architected. Key technologies, folder sections, etc.

Example a Django Project driving greatnonprofits.org might look like:

```example
This is a modular Django application using Django REST Framework with the following key characteristics:

- **Multi-layered API Design**: Both admin/backend APIs (`api/v1/`) and public front-end APIs (`front/v1/`)
- **Modular App Structure**: Feature-organized Django apps (organizations, reviews, authentication, etc.)
- **Database**: PostgreSQL with Sphinx search integration
- **Authentication**: Django Allauth with JWT token support
- **Storage**: AWS S3 integration via django-storages
- **Email**: SendGrid integration for transactional emails
```
````

[...| Provide architecture overview based on project analysis]

{{#if has_modules_or_apps}}
## Key {project_type|modules/apps/components}

````@npl-templater
List the main modules, apps, or key directories with brief descriptions.
For Django projects, this would be Django apps.
For Node projects, this might be major service modules.
For monorepo projects, list the main packages.

Format as bullet list with code formatting for names:
- `folder_name/` - Description of what this module handles
````

[...| List key project modules/apps with descriptions]
{{/if}}

## Development Commands

````@npl-templater
Analyze the project to determine common development commands.
Look for:
- package.json scripts (Node.js)
- manage.py commands (Django)
- Makefile targets
- requirements.txt/setup.py (Python)
- cargo commands (Rust)
- composer commands (PHP)

Group commands logically (e.g., Server Management, Testing, Database, etc.)

Example for Django:
```example
### Server Management
```bash
# Run development server
python manage.py runserver

# Run with specific port
python manage.py runserver 8000
```

### Database Operations
```bash
# Run migrations
python manage.py migrate

# Create migrations
python manage.py makemigrations
```
```
````

{development_commands|Generate based on project type and detected build tools}

{{#if has_api_structure}}
## API Structure

````@npl-templater
If this project has REST APIs, GraphQL, or other API endpoints, document them here.
Look for:
- API routing files (urls.py, routes.js, etc.)
- OpenAPI/Swagger documentation
- GraphQL schemas
- API versioning patterns

Include base paths, authentication requirements, and documentation links.
````

[...| Document API structure if present]
{{/if}}

{{#if has_configuration}}
## Key Configuration

````@npl-templater
Document important configuration files and settings.
Look for:
- settings.py, config.js, .env files
- Database configuration
- Third-party service integrations
- Environment-specific settings

Example format:
```example
### Settings Location
- Main config: `{config_file_path}`
- Environment vars: `.env` files

### Important Settings
- Database: {database_type}
- Authentication: {auth_system}
- Storage: {storage_system}
```
````

[...| Document key configuration files and important settings]
{{/if}}

## Using Claude Code Agents for {project_name} Development

````@npl-templater
Customize this section based on the detected project type and structure.
For each agent, provide:
1. What the agent does
2. When to use it for THIS specific project type
3. Example usage tailored to the project domain
4. Best use cases for this project

Adapt the examples to match the project's actual technology stack and domain.
````

### Available Agents and Their Uses

{agent_recommendations|Generate agent usage recommendations based on project analysis}

### Agent Usage Examples

````@npl-templater
Generate specific agent usage examples tailored to this project's domain and architecture.
Use actual component/feature names from the codebase when possible.

Format as code block with comments explaining the scenario.
````

```bash
{agent_examples|Generate project-specific agent usage examples}
```

### Running Agents in Parallel for {project_type} Development

````@npl-templater
Adapt parallel agent execution examples to this specific project.
Use actual module/component names from the codebase.
Focus on the most common parallel analysis patterns for this project type.
````

```bash
{parallel_examples|Generate project-specific parallel agent examples}
```

{{#if has_development_patterns}}
## Common Development Patterns

````@npl-templater
Analyze the project structure to identify common patterns developers should follow.
This might include:
- File/folder organization patterns
- Naming conventions
- Common development workflows
- Code organization principles

For different project types:
- Django: App structure, model patterns
- Node.js: Module organization, middleware patterns  
- React: Component organization, state management
- Microservices: Service boundaries, communication patterns
````

{development_patterns|Document project-specific development patterns and conventions}
{{/if}}

{{#if has_git_repo}}
## Branch Strategy

````@npl-templater
Analyze the git repository to determine:
- Main/default branch name
- Current branch being worked on
- Any branch naming patterns or workflow evident from git history

Just document what's detected, don't make assumptions about complex workflows unless evident.
````

[...| Document git branching strategy based on repository analysis]
{{/if}}

{{#if has_workflows}}
## Common Development Workflows

````@npl-templater
Based on project analysis, document common workflows developers will need.
This should be specific to the project type and tech stack.

Examples:
- Adding new features
- Debugging approaches
- Testing workflows
- Deployment steps

Make these actionable and specific to the detected technology stack.
````

{development_workflows|Generate workflows based on project type and structure}
{{/if}}
