# UI-UX-1 Layout

## Root Level Files
- **INDEX.md** - System overview, revenue projections, and quick start guide for passive income agents
- **ai-templates.md** - AI Template Product Developer agent with prompts for ideation, scoping, creation, and iteration
- **content-marketing.md** - Technical Content Strategist agent for generating article ideas, keyword research, and abstracts
- **print-on-demand.md** - POD Product Designer agent for niche identification, design concepts, and AI image prompts
- **ai-templates-tracker.md** - Performance tracking dashboard for AI template products (ideas → launch → metrics)
- **content-tracker.md** - Article idea backlog, publication calendar, and performance metrics across platforms
- **pod-tracker.md** - Design catalog, niche tracking, and sales performance across POD platforms

## Subdirectory: passive-income-agent/
```
passive-income-agent/
├── INDEX.md - System overview and agent invocation patterns
├── ai-templates.md - AI Template agent prompts and workflows
├── content-marketing.md - Content marketing agent prompts and workflows
├── print-on-demand.md - POD agent prompts and workflows
└── tracking/
    ├── ai-templates-tracker.md - AI template performance tracker
    ├── content-tracker.md - Content marketing tracker
    └── pod-tracker.md - POD performance tracker
```

## Organization Notes
- All root-level files are duplicates of their nested counterparts under `passive-income-agent/`
- This appears to be an early organizational iteration with files present at both levels
- Recommend consolidating to single source of truth during refactoring
