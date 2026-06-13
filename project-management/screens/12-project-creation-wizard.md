# Project Creation Wizard

| Field | Value |
|-------|-------|
| **ID** | `project-creation-wizard` |
| **Type** | Storyboard |
| **Category** | Project Management |
| **User Stories** | US-021, US-030 |

## Description

Multi-step wizard for creating a new project. Guides through methodology selection (Scrum, Kanban, Waterfall, hybrid), template application, team member assignment, and agent configuration.

## Key Components

- **Methodology selector** — Card-based picker with descriptions of each methodology
- **Methodology preview** — Visual preview of what the board/workflow will look like
- **Template picker** — Apply a pre-built project template (from Template Library)
- **Parameter fill form** — Fill template variables (project name, key dates, etc.)
- **Team member assignment** — Add humans and assign roles
- **Agent config** — Select which AI agents to activate for this project

## Flow Steps

1. **Name & description** — Basic project identity
2. **Methodology** — Choose workflow methodology
3. **Template** — Optionally apply a project template
4. **Team** — Assign members and roles
5. **Agents** — Configure AI agents
6. **Review & Create** — Confirm and create project

## Navigation

- Triggered from: Portfolio Dashboard "New Project", Main nav
- Outputs to: Project Kanban Board (new project)
