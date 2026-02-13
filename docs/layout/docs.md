# Documentation Layout

```
docs/
├── arch/                               # Architecture documentation
│   ├── agent-orchestration.md          #   Multi-agent TDD workflow design
│   ├── agent-orchestration.summary.md  #   Summary companion
│   ├── assumptions.md                  #   Tracked architectural assumptions
│   ├── assumptions.summary.md          #   Summary companion
│   └── meta-tools.md                   #   Meta-tool discovery pattern design
├── agents/                             # Agent-specific documentation
│   ├── control-agent.md                #   Control agent behavior
│   └── sub-agent.md                    #   Sub-agent patterns
├── claude/                             # Claude Code tooling docs
│   ├── tools.md                        #   Tool overview
│   ├── tools.summary.md                #   Summary companion
│   └── tools/                          #   Per-category tool docs
├── reference/                          # Reference documentation
│   ├── fastmcp/                        #   FastMCP 2.x framework guides (10 files)
│   ├── mcp.md                          #   MCP protocol reference
│   ├── agents-catalog.md               #   Agent catalog
│   ├── architecture-review.md          #   Architecture review
│   ├── SKILL-GUIDELINE.md              #   Skill authoring guidelines
│   └── SKILL-QUICKSTART.md             #   Skill quickstart guide
├── layout/                             # Extended layout docs (extracted sections)
│   ├── src.md                          #   Source code detail
│   ├── tests.md                        #   Test suite detail
│   ├── docs.md                         #   This file
│   ├── project-management.md           #   PM artifacts detail
│   └── user-stories.md                 #   User story index reference
├── pending/                            # Docs pending integration into take-2
│   ├── mcp-server/                     #   MCP server consolidation docs
│   ├── resources/                      #   Resource docs
│   └── *.md                            #   Various planning/tracking docs
├── prior-version/                      # Archived docs from pre-take-2
│   ├── additional-agents/              #   Old agent definitions
│   ├── agents/                         #   Old agent docs
│   ├── commands/                       #   Old command docs
│   ├── fastmcp/                        #   Old FastMCP docs
│   ├── orchestration/                  #   Old orchestration patterns
│   ├── PROJECT-ARCH/                   #   Old architecture docs
│   ├── prompts/                        #   Old prompt templates
│   ├── scripts/                        #   Old script docs
│   └── *.md                            #   Various summary/brief files
├── features-grid.md                    # Implementation status and gaps
├── PROJ-ARCH.md                        # High-level architecture
├── PROJ-ARCH.summary.md                # Architecture summary companion
├── PROJ-LAYOUT.md                      # Project layout (main file)
└── PROJ-LAYOUT.summary.md              # Layout summary companion
```
