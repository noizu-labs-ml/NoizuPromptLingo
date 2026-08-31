# .claude/ — Claude Code Configuration

Agent definitions, slash commands, and local settings for Claude Code.

```
.claude/
├── agents/                          # Agent definitions
│   ├── npl-idea-to-spec.md          #   Idea → persona/story generator
│   ├── npl-prd-editor.md            #   PRD authoring agent
│   ├── npl-tasker-haiku.md          #   Fast/cheap task executor
│   ├── npl-tasker-opus.md           #   High-intelligence task executor
│   ├── npl-tasker-sonnet.md         #   Balanced task executor
│   ├── npl-tdd-coder.md            #   Autonomous TDD implementer
│   ├── npl-tdd-debugger.md         #   Test failure debugger
│   └── npl-tdd-tester.md           #   Test suite generator
├── commands/                        # Slash commands (skills)
│   ├── extended-manners.md          #   Full Trinity Protocol activation
│   ├── manners.md                   #   Output conventions reminder
│   ├── npl-annotate.md             #   Footnote annotation system
│   ├── npl-guest.md                #   Welcome/onboarding
│   ├── npl-reflect.md              #   Self-review reflection block
│   ├── npl-task-wizard.md          #   Task CLI wizard
│   ├── npl-track-assumptions.md    #   Assumption tracking
│   ├── npl-update-arch-doc.md      #   PROJ-ARCH.md maintenance
│   ├── npl-update-layout-doc.md    #   PROJ-LAYOUT.md maintenance
│   └── npl-update-schema-doc.md    #   PROJ-SCHEMA.md maintenance
└── settings.local.json              # Local Claude Code settings (gitignored)
```
