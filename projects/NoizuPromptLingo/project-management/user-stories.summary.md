# User Stories Summary

Quick reference for 37 user stories organized by PRD priority groups.

## NPL Load (4 stories)

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-001 | Load NPL Core Components | AI Agent (P-001) | Critical |
| US-002 | Load Project-Specific Context | AI Agent (P-001) | Critical |
| US-003 | Fetch Web Content as Markdown | Vibe Coder (P-003) | High |
| US-025 | Explore Project File Structure | AI Agent (P-001) | Medium |

## Chat/Collaboration (7 stories)

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-004 | Share Artifact in Chat Room | Vibe Coder (P-003) | High |
| US-005 | View Session Dashboard | Product Manager (P-002) | High |
| US-006 | Send Message to Chat Room | Vibe Coder (P-003) | High |
| US-007 | Create Chat Room for Collaboration | AI Agent (P-001) | High |
| US-022 | Receive and Manage Notifications | Product Manager (P-002) | Medium |
| US-027 | React to Chat Messages | Vibe Coder (P-003) | Low |
| US-028 | Create Todo from Chat | Vibe Coder (P-003) | Low |

## Artifacts/Reviews (5 stories)

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-008 | Create Versioned Artifact | AI Agent (P-001) | High |
| US-009 | Review Artifact Revision History | Product Manager (P-002) | Medium |
| US-010 | Add Inline Review Comment | Product Manager (P-002) | Medium |
| US-011 | Annotate Screenshot with Overlay | Product Manager (P-002) | Medium |
| US-023 | Complete Review with Summary | Product Manager (P-002) | Medium |

## Task Queue (7 stories)

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-014 | Pick Up Task from Queue | AI Agent (P-001) | High |
| US-015 | View Task Queue Progress | Product Manager (P-002) | High |
| US-016 | Create Task in Queue | Vibe Coder (P-003) | High |
| US-017 | Link Artifact to Task | AI Agent (P-001) | High |
| US-018 | Update Task Status | AI Agent (P-001) | High |
| US-026 | Ask Question on Task | AI Agent (P-001) | Medium |
| US-030 | Assign Task Complexity | AI Agent (P-001) | Low |

## Browser/Screenshots (7 stories)

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-012 | Capture Screenshot of Current Work | Vibe Coder (P-003) | Medium |
| US-013 | Compare Screenshots for Visual Regression | AI Agent (P-001) | Medium |
| US-019 | Automate Form Submission | AI Agent (P-001) | Medium |
| US-020 | Quick Form Fill for Developers | Vibe Coder (P-003) | Medium |
| US-021 | Navigate and Interact with Web Pages | AI Agent (P-001) | Medium |
| US-024 | Manage Browser Session State | AI Agent (P-001) | Low |
| US-029 | Inject Scripts and Styles | AI Agent (P-001) | Low |

## Agent Coordination (3 stories)

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-031 | View Agent Work Logs | Project Manager (P-004) | High |
| US-032 | Assign Tasks to Specific Agents | Project Manager (P-004) | High |
| US-033 | Monitor Sprint Progress with Agent Metrics | Project Manager (P-004) | Medium |

## Human-Agent Collaboration (4 stories)

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-034 | Review Agent-Generated Code | Dave (P-005) | High |
| US-035 | Share Architectural Context with Agents | Dave (P-005) | High |
| US-036 | Pair Program via Chat Room | Dave (P-005) | Medium |
| US-037 | Track Code Quality Metrics for Agent Output | Dave (P-005) | Low |

## Quick Persona Reference

| ID | Name | Role | Stories |
|----|------|------|---------|
| P-001 | AI Agent | Core automation | 11 |
| P-002 | Product Manager | Review, dashboard | 9 |
| P-003 | Vibe Coder | Developer, rapid prototyping | 8 |
| P-004 | Project Manager | Agent coordination | 3 |
| P-005 | Dave | Senior dev, code review | 4 |

## Priority Distribution

| Priority | Count |
|----------|-------|
| Critical | 2 |
| High | 16 |
| Medium | 15 |
| Low | 4 |

## Related Files

- [docs/user-stories.md](user-stories.md) - Detailed overview
- [docs/user-stories/index.yaml](user-stories/index.yaml) - Machine-readable index
- [docs/layout/user-stories.md](layout/user-stories.md) - Detailed directory structure
- [docs/personas/index.yaml](personas/index.yaml) - Persona definitions