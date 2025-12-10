# PRD: NPL MCP Server Web UI and Session Management
Product Requirements Document for NPL MCP Server Web UI and Session Management, a web-accessible interface for managing collaborative sessions, chat rooms, and artifacts within the NPL MCP ecosystem.

**version**
: 1.0

**status**
: draft

**owner**
: NPL Development Team

**last-updated**
: 2025-12-10

**stakeholders**
: NPL Core Team, Claude Code Users, MCP Integration Developers

---

## Executive Summary

The NPL MCP Server Web UI and Session Management feature extends the existing NPL MCP server with browser-accessible interfaces for real-time collaboration. This enhancement addresses the fundamental limitation of MCP's stdio-based communication by providing shareable URLs that allow users to view and participate in chat rooms, review artifacts, and track collaborative sessions outside of the Claude Code environment.

The implementation introduces a session abstraction that groups related chat rooms and artifacts, enabling organized workflows and persistent context across interactions. By combining MCP protocol support with a FastAPI-based web interface, the server enables seamless transitions between AI-assisted development and human review workflows.

Key outcomes include: shareable session URLs for team collaboration, persistent chat history accessible via browser, and multiple deployment modes to accommodate different integration scenarios (stdio-only, combined, unified HTTP, and singleton launcher).

---

## Problem Statement

### Current State
The original NPL MCP server operates exclusively via stdio communication, which creates several limitations:
- Chat room interactions and artifact reviews are only accessible through Claude Code
- No way to share ongoing conversations with team members who are not in the same session
- Session context is ephemeral and not persisted across Claude Code restarts
- External stakeholders cannot view or participate in AI-assisted collaboration
- No mechanism to organize related activities into logical groupings

### Desired State
A unified server that:
- Provides browser-accessible interfaces for all MCP-managed content
- Groups related activities (chat rooms, artifacts) into shareable sessions
- Enables real-time participation via web forms alongside MCP tool calls
- Supports multiple deployment modes for different use cases
- Maintains backward compatibility with existing stdio MCP clients

### Gap Analysis
| Aspect | Current | Desired | Gap |
|:-------|:--------|:--------|:----|
| Access method | stdio only | stdio + web | Web server required |
| Session grouping | None | Sessions with URLs | Session abstraction layer |
| Shareability | Not possible | URL-based sharing | Web routes + session IDs |
| Deployment flexibility | Single mode | Multiple modes | Combined/unified entry points |
| Persistence | Database only | DB + web views | Web UI templates |

---

## Goals and Objectives

### Business Objectives
1. Enable team collaboration on MCP-managed content through shareable web URLs
2. Reduce friction for non-technical stakeholders to participate in AI-assisted workflows
3. Establish foundation for future multi-user concurrent collaboration features

### User Objectives
1. View and participate in chat rooms from any modern web browser
2. Share session URLs with team members for review and input
3. Track activity across multiple related chat rooms and artifacts
4. Choose deployment mode based on integration requirements

### Non-Goals
- Real-time WebSocket updates (current implementation uses page refresh)
- User authentication and authorization (all sessions currently public)
- Multi-tenant deployment with user isolation
- Mobile-native application
- Full artifact editing via web (view-only in current scope)

---

## Success Metrics

| Metric | Baseline | Target | Timeframe | Measurement |
|:-------|:---------|:-------|:----------|:------------|
| Session creation rate | N/A | 5+ sessions/day in active use | 30 days | Database queries |
| Web UI page loads | 0 | 100+ views/week | 30 days | Server logs |
| Message posting via web | N/A | 30% of messages | 60 days | Event source tracking |
| Deployment mode adoption | N/A | All modes tested | 14 days | User feedback |

### Key Performance Indicators (KPIs)

**Session Utilization**
: Definition: Percentage of created sessions with >1 chat room
: Target: 60%
: Frequency: Weekly

**Web Participation Rate**
: Definition: Ratio of web-posted messages to total messages
: Target: 30%
: Frequency: Weekly

---

## User Personas

### Claude Code Power User

**demographics**
: Developer, Advanced technical skill, Uses Claude Code daily

**goals**
: Share AI collaboration sessions with team, maintain context across sessions

**frustrations**
: Cannot easily share conversation context, loses session state on restart

**behaviors**
: Prefers keyboard-driven workflows, expects CLI tools

**quote**
: "I need to show my colleague what Claude and I discussed, but there's no way to share the chat."

### Team Lead Reviewer

**demographics**
: Engineering Manager, Intermediate technical skill, Reviews team output

**goals**
: Review AI-assisted work products, provide feedback, track progress

**frustrations**
: No visibility into AI collaboration, must ask for screenshots or copy-paste

**behaviors**
: Browser-based workflows, expects web interfaces

**quote**
: "I want to see what the team built with Claude without having to install specialized tools."

### External Stakeholder

**demographics**
: Product Manager or Designer, Basic technical skill

**goals**
: View artifacts and discussions, understand project progress

**frustrations**
: Technical barriers to access, unfamiliar tools

**behaviors**
: Reads content more than creates, needs simple access

**quote**
: "Just send me a link I can click."

---

## User Stories and Use Cases

### Epic: Session Management

**US-001**: As a Claude Code user, I want to create a named session so that I can organize related activities together

**acceptance-criteria**
: - [x] Session created via `create_session` MCP tool
: - [x] Session ID returned for reference
: - [x] Optional title for human-readable naming
: - [x] Session timestamp recorded

**priority**
: P0

---

**US-002**: As a Claude Code user, I want to associate chat rooms with sessions so that related conversations are grouped

**acceptance-criteria**
: - [x] `create_chat_room` accepts `session_id` parameter
: - [x] `create_chat_room` accepts `session_title` for auto-creation
: - [x] Response includes `web_url` for the chat room
: - [x] Session `updated_at` timestamp refreshed on activity

**priority**
: P0

---

**US-003**: As a team member, I want to view a session via web browser so that I can see all related content

**acceptance-criteria**
: - [x] Session detail page at `/session/{session_id}`
: - [x] Page displays session title and status
: - [x] Page lists all chat rooms in session
: - [x] Page lists all artifacts in session

**priority**
: P0

---

**US-004**: As a team member, I want to view chat history in a browser so that I can read past conversations

**acceptance-criteria**
: - [x] Chat room page at `/session/{session_id}/room/{room_id}`
: - [x] Messages displayed in chronological order
: - [x] Different event types visually distinguished
: - [x] Member list visible

**priority**
: P0

---

**US-005**: As a team member, I want to post messages via web form so that I can participate in conversations

**acceptance-criteria**
: - [x] Message form with persona selection
: - [x] POST endpoint handles form submission
: - [x] Page redirects back to chat room after posting
: - [x] Message appears in feed

**priority**
: P1

---

### Epic: Multi-Mode Deployment

**US-006**: As a developer, I want to run MCP-only server for Claude Code so that I have minimal resource usage

**acceptance-criteria**
: - [x] `npl-mcp` entry point runs stdio MCP only
: - [x] No web server started
: - [x] Full MCP tool functionality available

**priority**
: P0

---

**US-007**: As a developer, I want to run combined MCP+Web server so that both Claude Code and browsers work

**acceptance-criteria**
: - [x] `npl-mcp-web` entry point starts both servers
: - [x] MCP on stdio for Claude Code
: - [x] Web server on configurable port
: - [x] Shared database connection

**priority**
: P0

---

**US-008**: As a developer, I want to run unified HTTP server so that I can access MCP over HTTP

**acceptance-criteria**
: - [x] `npl-mcp-unified` entry point starts single HTTP server
: - [x] MCP protocol available at `/mcp` endpoint
: - [x] Web UI available at `/` and other routes
: - [x] Singleton mode via `NPL_MCP_SINGLETON=true`

**priority**
: P1

---

## Functional Requirements

### Session Management

#### FR-001: Session Creation

**description**
: System shall create sessions with unique IDs, optional titles, and status tracking

**rationale**
: Sessions provide organizational structure for related activities

**acceptance-criteria**
: - [x] Generate 8-character URL-safe session IDs
: - [x] Accept optional custom session IDs
: - [x] Record created_at and updated_at timestamps
: - [x] Default status to "active"

**dependencies**
: Database schema migration

**status**
: Implemented

---

#### FR-002: Session Listing

**description**
: System shall list sessions ordered by most recent activity with summary statistics

**rationale**
: Users need to find and navigate to relevant sessions

**acceptance-criteria**
: - [x] Order by updated_at descending
: - [x] Include room_count and artifact_count
: - [x] Support status filter parameter
: - [x] Configurable limit parameter

**dependencies**
: FR-001

**status**
: Implemented

---

#### FR-003: Session-Room Association

**description**
: System shall associate chat rooms with sessions via foreign key relationship

**rationale**
: Enables grouping of related conversations

**acceptance-criteria**
: - [x] chat_rooms table has session_id column
: - [x] create_chat_room accepts session_id parameter
: - [x] Auto-create session when session_title provided without session_id
: - [x] Touch session updated_at on room activity

**dependencies**
: FR-001, Database migration

**status**
: Implemented

---

#### FR-004: Session Content Retrieval

**description**
: System shall retrieve complete session contents including rooms and artifacts

**rationale**
: Supports session detail view and API responses

**acceptance-criteria**
: - [x] Return session metadata
: - [x] Return associated chat rooms with event counts
: - [x] Return associated artifacts with revision counts
: - [x] Handle session not found gracefully

**dependencies**
: FR-001, FR-003

**status**
: Implemented

---

### Web Interface

#### FR-005: Landing Page

**description**
: System shall display landing page listing all sessions with navigation links

**rationale**
: Entry point for web users to discover and access sessions

**acceptance-criteria**
: - [x] Table with session ID, title, counts, last activity, status
: - [x] Session ID links to detail page
: - [x] Empty state message when no sessions exist
: - [x] Dark theme styling

**dependencies**
: FR-002

**status**
: Implemented

---

#### FR-006: Session Detail Page

**description**
: System shall display session detail page with rooms and artifacts in card grid layout

**rationale**
: Provides session overview and navigation to contained resources

**acceptance-criteria**
: - [x] Breadcrumb navigation
: - [x] Session metadata display
: - [x] Chat room cards with member/event counts
: - [x] Artifact cards with revision counts
: - [x] 404 for invalid session IDs

**dependencies**
: FR-004

**status**
: Implemented

---

#### FR-007: Chat Room View

**description**
: System shall display chat room with message history and posting form

**rationale**
: Enables web-based participation in conversations

**acceptance-criteria**
: - [x] Message feed with sender, timestamp, content
: - [x] Visual distinction for event types (message, join, todo, artifact share)
: - [x] Message posting form with persona dropdown
: - [x] Auto-scroll to most recent messages
: - [x] HTML escaping for security

**dependencies**
: Existing chat_events table

**status**
: Implemented

---

#### FR-008: Message Posting

**description**
: System shall accept message posts via HTML form and create chat events

**rationale**
: Enables web-based participation without MCP tools

**acceptance-criteria**
: - [x] POST endpoint at `/session/{sid}/room/{rid}/message`
: - [x] Persona and message form fields
: - [x] Redirect to chat room after successful post
: - [x] Error handling for invalid room/persona

**dependencies**
: FR-007

**status**
: Implemented

---

#### FR-009: Todo Creation via Web

**description**
: System shall accept todo creation via HTML form

**rationale**
: Enables full web participation in collaborative workflows

**acceptance-criteria**
: - [x] POST endpoint at `/session/{sid}/room/{rid}/todo`
: - [x] Collapsible form with description and assignment fields
: - [x] Optional assignee selection from room members
: - [x] Redirect after successful creation

**dependencies**
: FR-007

**status**
: Implemented

---

### Server Modes

#### FR-010: stdio MCP Entry Point

**description**
: System shall provide stdio-only MCP server as default entry point

**rationale**
: Maintains backward compatibility with existing Claude Code setup

**acceptance-criteria**
: - [x] `npl-mcp` command runs stdio server
: - [x] All MCP tools available
: - [x] No web server started
: - [x] Database connection managed via lifespan

**dependencies**
: None (existing functionality)

**status**
: Implemented

---

#### FR-011: Combined MCP+Web Entry Point

**description**
: System shall provide combined server running MCP on stdio and web on HTTP

**rationale**
: Enables simultaneous Claude Code and browser access

**acceptance-criteria**
: - [x] `npl-mcp-web` command runs combined server
: - [x] Web server runs in background thread
: - [x] Shared database connection
: - [x] Configurable via `NPL_MCP_WEB_HOST` and `NPL_MCP_WEB_PORT`

**dependencies**
: FR-010, FR-005

**status**
: Implemented

---

#### FR-012: Unified HTTP Entry Point

**description**
: System shall provide single HTTP server with MCP and web UI routes

**rationale**
: Enables HTTP-based MCP clients and web browsers on same port

**acceptance-criteria**
: - [x] `npl-mcp-unified` command runs unified server
: - [x] MCP protocol at `/mcp` endpoint
: - [x] Web UI at `/` and session routes
: - [x] Singleton mode with `NPL_MCP_SINGLETON=true`
: - [x] PID file tracking

**dependencies**
: FR-011

**status**
: Implemented

---

#### FR-013: Singleton Launcher

**description**
: System shall provide launcher that ensures single server instance

**rationale**
: Prevents port conflicts and resource duplication

**acceptance-criteria**
: - [x] Check if server already running via HTTP probe
: - [x] Start background server if not running
: - [x] Connect to existing server if running
: - [x] Environment variable override (`NPL_MCP_FORCE`)

**dependencies**
: FR-012

**status**
: Partial (launcher exists, stdio proxy incomplete)

---

### Database

#### FR-014: Schema Migration System

**description**
: System shall automatically migrate database schema on startup

**rationale**
: Enables seamless upgrades without manual intervention

**acceptance-criteria**
: - [x] schema_version table tracks applied migrations
: - [x] Migrations run in order on connect
: - [x] Column existence checked before ALTER TABLE
: - [x] Applied migrations logged to console

**dependencies**
: None

**status**
: Implemented

---

#### FR-015: Sessions Table Migration

**description**
: System shall add sessions table and foreign keys via migration

**rationale**
: Required for session management features

**acceptance-criteria**
: - [x] sessions table with id, title, created_at, updated_at, status
: - [x] session_id column added to chat_rooms
: - [x] session_id column added to artifacts
: - [x] Indexes created for query optimization

**dependencies**
: FR-014

**status**
: Implemented

---

### API Endpoints

#### FR-016: REST API for Sessions

**description**
: System shall provide JSON API endpoints for programmatic session access

**rationale**
: Enables AJAX calls and third-party integrations

**acceptance-criteria**
: - [x] GET `/api/sessions` returns session list
: - [x] GET `/api/session/{id}` returns session contents
: - [x] Status filter parameter support
: - [x] Consistent JSON response format

**dependencies**
: FR-001, FR-004

**status**
: Implemented

---

#### FR-017: REST API for Chat

**description**
: System shall provide JSON API endpoints for chat operations

**rationale**
: Enables programmatic chat access beyond MCP

**acceptance-criteria**
: - [x] GET `/api/room/{id}/feed` returns chat events
: - [x] POST `/api/room/{id}/message` creates message
: - [x] since and limit query parameters
: - [x] Error responses with appropriate status codes

**dependencies**
: Existing chat functionality

**status**
: Implemented

---

## Non-Functional Requirements

### Performance

| Metric | Requirement | Measurement |
|:-------|:------------|:------------|
| Page load time | <500ms | Server response time |
| Database queries | <50ms avg | SQLite timing |
| Memory usage | <100MB baseline | Process monitoring |

### Security

**authentication**
: None (local development focus)

**authorization**
: None (all sessions publicly accessible)

**data-protection**
: Local SQLite database, no encryption at rest

**future-consideration**
: Token-based auth, session ownership, access controls

### Scalability

**expected-load**
: Single user, development/prototyping scenarios

**growth-projection**
: Multi-user support planned for future phases

### Reliability

**availability**
: Best effort, development tool

**data-persistence**
: SQLite database with standard durability guarantees

---

## Constraints and Assumptions

### Constraints

**technical**
: - Python 3.10+ required
: - FastMCP dependency for MCP protocol
: - SQLite for data storage (single-file database)

**business**
: - Local development use case primary focus
: - No commercial deployment requirements

**timeline**
: - Initial implementation complete
: - Future enhancements as user feedback received

### Assumptions

| Assumption | Impact if False | Validation Plan |
|:-----------|:----------------|:----------------|
| Users have local Python environment | Cannot run server | Document setup requirements |
| Single user per server instance | Race conditions possible | Add locking if needed |
| Local network access sufficient | External access fails | Document port forwarding |
| Browser supports ES6+ | JavaScript features fail | Document browser requirements |

---

## Dependencies

### Internal Dependencies

| Dependency | Owner | Status | Impact |
|:-----------|:------|:-------|:-------|
| NPL MCP core server | NPL Team | Complete | Foundation for all features |
| Chat system | NPL Team | Complete | Required for chat web views |
| Artifact system | NPL Team | Complete | Required for artifact display |

### External Dependencies

| Dependency | Provider | Version | Fallback |
|:-----------|:---------|:--------|:---------|
| FastMCP | PyPI | >=0.1.0 | None (required) |
| FastAPI | PyPI | >=0.104.0 | None (required) |
| uvicorn | PyPI | >=0.24.0 | None (required) |
| aiosqlite | PyPI | >=0.19.0 | None (required) |

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation | Owner |
|:-----|:-----------|:-------|:-----------|:------|
| Concurrent writes to SQLite | M | M | WAL mode, proper connection handling | Dev Team |
| Port conflicts with other services | M | L | Configurable port, singleton mode | Dev Team |
| Session data loss | L | H | Regular backups recommended | User |
| Browser compatibility issues | L | L | Target modern browsers only | Dev Team |
| MCP protocol changes | M | H | Pin FastMCP version, monitor updates | Dev Team |

---

## Timeline and Milestones

### Phases

**Phase 1: Core Session Management**
: Scope: Session CRUD, database migrations, MCP tool integration
: Status: Complete

**Phase 2: Web Interface**
: Scope: Landing page, session detail, chat room views, message posting
: Status: Complete

**Phase 3: Multi-Mode Deployment**
: Scope: Combined server, unified HTTP, singleton launcher
: Status: Complete (launcher partial)

**Phase 4: Future Enhancements**
: Scope: Real-time updates, authentication, multi-user support
: Status: Planned

### Milestones

| Milestone | Description | Status |
|:----------|:------------|:-------|
| Session Schema | Database migrations for sessions | Complete |
| Web Landing Page | Browser-accessible session list | Complete |
| Chat Room View | View and post messages via web | Complete |
| Unified Server | Single HTTP server with MCP+Web | Complete |
| Full Launcher | Singleton launcher with stdio proxy | In Progress |

---

## Open Questions

| Question | Impact | Owner | Due |
|:---------|:-------|:------|:-----|
| Should we add WebSocket for real-time updates? | UX improvement | Dev Team | TBD |
| What authentication model for multi-user? | Security | Dev Team | TBD |
| Should artifacts be viewable/editable via web? | Feature scope | Dev Team | TBD |
| How to handle session archival and cleanup? | Data management | Dev Team | TBD |

---

## Appendix

### Glossary

**Session**
: A logical grouping of related chat rooms and artifacts, identified by a unique ID

**MCP (Model Context Protocol)**
: Protocol for AI model tools and context management

**stdio**
: Standard input/output communication method used by default MCP

**Unified Server**
: Single HTTP server serving both MCP protocol and web interface

**Singleton Mode**
: Server mode ensuring only one instance runs on a given port

### Environment Variables

| Variable | Default | Description |
|:---------|:--------|:------------|
| NPL_MCP_HOST | 127.0.0.1 | Server bind address |
| NPL_MCP_PORT | 8765 | Server port |
| NPL_MCP_DATA_DIR | ./data | Data directory path |
| NPL_MCP_SINGLETON | false | Enable singleton mode |
| NPL_MCP_WEB_HOST | 127.0.0.1 | Web server host (combined mode) |
| NPL_MCP_WEB_PORT | 8765 | Web server port (combined mode) |

### Entry Points

| Command | Description |
|:--------|:------------|
| `npl-mcp` | stdio MCP server only |
| `npl-mcp-web` | Combined MCP (stdio) + Web (HTTP) |
| `npl-mcp-unified` | Single HTTP server with MCP at /mcp |

### References

- FastMCP Documentation: https://github.com/jlowin/fastmcp
- FastAPI Documentation: https://fastapi.tiangolo.com/
- MCP Specification: Model Context Protocol documentation

### Revision History

| Version | Date | Author | Changes |
|:--------|:-----|:-------|:--------|
| 1.0 | 2025-12-10 | NPL Team | Initial PRD based on implemented features |
