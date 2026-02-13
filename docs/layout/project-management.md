# Project Management Layout

```
project-management/
├── personas/                           # Persona definitions
│   ├── index.yaml                      #   Master persona index
│   ├── README.md                       #   Persona guide
│   ├── ai-agent.md                     #   AI agent persona
│   ├── control-agent.md                #   Control agent persona
│   ├── dave-fellow-developer.md        #   Developer persona
│   ├── product-manager.md              #   Product manager persona
│   ├── project-manager.md              #   Project manager persona
│   ├── sub-agent.md                    #   Sub-agent persona
│   ├── tdd-workflow-agent.md           #   TDD workflow persona
│   ├── vibe-coder.md                   #   Vibe coder persona
│   ├── additional-agents/              #   Extended agent personas
│   ├── agents/                         #   Agent-specific personas
│   ├── commands/                       #   Command-related personas
│   ├── prompts/                        #   Prompt-related personas
│   └── scripts/                        #   Script-related personas
├── user-stories/                       # User story definitions
│   ├── index.yaml                      #   Master story index (single source of truth)
│   ├── README.md                       #   User story conventions
│   ├── advanced-loading-extension.yaml #   Extended loading stories
│   ├── US-001-*.md through US-232-*.md #   150+ individual stories
│   └── index.yaml.backup              #   Index backup
├── PRDs/                               # Product requirement documents
│   ├── index.yaml                      #   PRD index
│   ├── PRD-001-database-infrastructure/#   Database infrastructure
│   ├── PRD-002-artifact-management/    #   Artifact management
│   ├── PRD-003-review-system/          #   Review system
│   ├── PRD-004-chat-and-sessions/      #   Chat and sessions
│   ├── PRD-005-task-queue-system/      #   Task queue system
│   ├── PRD-006-browser-automation/     #   Browser automation
│   ├── PRD-007-web-interface/          #   Web interface
│   ├── PRD-008-script-wrappers/        #   Script wrappers
│   ├── PRD-009-external-executors/     #   External executors
│   ├── PRD-010-mcp-tools-implementation/#  MCP tools
│   ├── PRD-011-agent-ecosystem/        #   Agent ecosystem
│   ├── PRD-012-multi-agent-orchestration/#Multi-agent orchestration
│   ├── PRD-013-npl-syntax-parser/      #   NPL syntax parser
│   ├── PRD-014-cli-utilities/          #   CLI utilities
│   ├── PRD-015-npl-loading-extension/  #   NPL loading extension
│   ├── PRD-016-skill-validator-tool/   #   Skill validator
│   └── archive/                        #   Archived/superseded PRDs
├── TODO/                               # Backlog items
│   └── jina.md
├── personas.md                         # Persona overview
├── personas.summary.md                 # Persona summary
├── prd.md                              # PRD overview
├── prd.summary.md                      # PRD summary
├── user-stories.md                     # User stories overview
└── user-stories.summary.md             # User stories summary
```

## Index Files (Single Source of Truth)

Relationship metadata lives in YAML index files, not in markdown:
- `personas/index.yaml` — Persona IDs, relationships via `related_stories`
- `user-stories/index.yaml` — Story IDs, status, relationships via `related_personas`
- `PRDs/index.yaml` — PRD IDs and associated stories
