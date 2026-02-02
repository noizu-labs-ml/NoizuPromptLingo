# Persona: Vibe Coder

**ID**: P-003
**Type**: User Persona
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

**Role**: Creative Developer / Software Engineer
**Experience Level**: Mid to Senior
**Tech Comfort**: High technical skills, prefers intuitive workflows
**Primary Tools**: CLI, chat interface, web UI, AI pair programming

## Background

A developer who thrives on rapid prototyping and iterative creation. Prefers natural language interactions over rigid methodologies, treating AI agents as collaborative partners rather than just tools. Uses the NPL MCP server as an integrated workspace to capture progress, share artifacts, and maintain flow state. Values speed and flexibility while still producing quality work—just without the ceremony.

## Goals & Motivations

1. **Rapid Iteration**: Move from idea to working prototype in hours, not days
2. **Frictionless Capture**: Save work-in-progress naturally without ceremony or context switching
3. **AI Augmentation**: Delegate tedious tasks (form filling, screenshot captures, web research) to AI agents
4. **Casual Collaboration**: Share progress through chat and artifacts rather than formal documentation
5. **Sustained Flow**: Maintain creative momentum by minimizing tool switching and administrative overhead
6. **Visual Communication**: Show rather than tell—use screenshots and artifacts to convey progress

## Pain Points & Frustrations

1. **Process Overhead**: Heavy methodologies that prioritize documentation over building
2. **Manual Documentation**: Being forced to write detailed specs before trying something
3. **Tool Fragmentation**: Juggling multiple disconnected tools to accomplish one task
4. **Lost Context**: Work disappearing because it wasn't formally saved or versioned
5. **Cold Start Delays**: AI agents requiring extensive context before becoming helpful
6. **Interruption Penalty**: Losing flow state due to meetings, status updates, or administrative tasks
7. **Repetitive Work**: Manually repeating the same browser actions or form fills

## Typical Workflows & Behaviors

### Daily Work Patterns
- **Morning**: Check overnight AI agent work, review task queue, prioritize interesting problems
- **Deep Work**: Long coding sessions with minimal interruptions, frequent artifact saves
- **Context Sharing**: Drop screenshots and code snippets in chat as work progresses
- **Evening**: Quick status updates via chat, queue tasks for overnight AI agents

### Tool Usage
- Chat rooms as both scratch pad and async communication channel
- Screenshot captures to show visual progress (before/after comparisons)
- Artifacts created organically as work evolves, minimal upfront planning
- Browser automation for repetitive tasks (testing forms, data entry, navigation)
- Notifications checked sporadically, relies on @mentions for urgency
- Task queue as a backlog, not a strict schedule

### Collaboration Style
- Prefers showing work-in-progress over status meetings
- Comments directly on artifacts and screenshots
- Uses emoji reactions for quick feedback
- Asks questions in chat expecting AI or human response
- Shares context through links rather than lengthy explanations

## Characteristic Quotes

> "Let me just grab a screenshot—easier than explaining what I changed."

> "Can the AI handle this form? I've filled it out a hundred times already."

> "I'll write proper docs later. Right now I need to capture this before I lose the idea."

> "Why isn't the agent already loaded with our project context? I shouldn't have to explain this every time."

> "Just @me when it's ready. I'll be heads down for the next few hours."

> "Check out this artifact—does this feel right to you?"

## NPL MCP Feature Usage

### High-Frequency Tools
| Tool Category | Primary Commands | Usage Pattern |
|--------------|------------------|---------------|
| **Context Loading** | `npl_load` | Session start, after breaks |
| **Web Research** | `web_to_md` | Convert docs/references to markdown |
| **Chat** | `send_message`, `share_artifact` | Continuous throughout day |
| **Artifacts** | `create_artifact`, `add_revision` | Save work every 15-30 min |
| **Screenshots** | `screenshot_capture`, `screenshot_diff` | Visual progress tracking |

### Medium-Frequency Tools
| Tool Category | Primary Commands | Usage Pattern |
|--------------|------------------|---------------|
| **Browser Automation** | `browser_navigate`, `browser_fill`, `browser_click` | Testing, form work |
| **Tasks** | `create_task`, `add_task_message` | Planning, delegation to AI |
| **Quick TODOs** | `create_todo` (in chat) | Capture action items |

### Occasional Tools
| Tool Category | Primary Commands | Usage Pattern |
|--------------|------------------|---------------|
| **Reviews** | `create_review`, `add_inline_comment` | Code review, feedback |
| **Session Management** | `create_session`, `list_sessions` | Project switches |
| **Notifications** | Check notifications | Sporadic, reactive |

## Success Metrics

**This persona is well-served when:**
- Can start working on a new idea within 5 minutes of having it
- AI agents already understand project context without re-explanation
- Work is automatically captured and versioned without explicit saves
- Can delegate repetitive tasks to AI with minimal instruction
- Team sees progress through artifacts and screenshots, not status reports
- Context switching between tools drops to near-zero

**Warning signs of poor support:**
- Spending more time documenting than building
- Repeatedly explaining project context to AI agents
- Losing work due to lack of auto-save or versioning
- Manually repeating the same browser actions
- Needing multiple tools to accomplish one task

## Example Day in the Life

**9:00 AM** - Coffee, check overnight agent work in task queue
**9:15 AM** - Load context with `npl_load`, review yesterday's artifacts
**9:30 AM** - Start new feature, create artifact for design ideas
**10:00 AM** - Deep coding session, save artifact revisions every 20 min
**12:00 PM** - Share progress screenshot in team chat
**1:00 PM** - Ask AI to fill out test data forms while at lunch
**2:00 PM** - Back to coding, use `web_to_md` for API documentation
**4:00 PM** - Screenshot comparison showing before/after UI changes
**4:30 PM** - Create tasks for AI agents to handle overnight
**5:00 PM** - Drop final artifact in chat, done for the day

**Total tool switches**: ~3 (editor, browser, chat)
**Total interruptions**: 1 (quick question in chat)
**Artifacts created**: 4 (1 design, 3 code revisions)
**Screenshots captured**: 3
**Status meetings**: 0
**Flow state hours**: ~6
