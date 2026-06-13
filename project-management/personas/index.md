# Personas Index — therobotbrowses

## Human Personas

| ID | Name | Archetype | Segment | Phase Entry |
|----|------|-----------|---------|-------------|
| P-001 | [Kai Nakamura](P-001-kai-the-hacker.md) | Tool-Building Developer | Primary | Phase 0 |
| P-002 | [Dr. Amara Osei](P-002-dr-amara-the-researcher.md) | Systematic Researcher | Primary | Phase 1 |
| P-003 | [Maya Johansson](P-003-maya-the-power-user.md) | Keyboard-Driven Power User | Secondary | Phase 0 |
| P-004 | [Jordan Rivera](P-004-jordan-the-a11y-advocate.md) | Accessibility-First User | Secondary | Phase 4 |
| P-005 | [Suki Tanaka](P-005-suki-the-security-analyst.md) | Security-Minded Analyst | Secondary | Phase 3 |

## Agent Personas

| ID | Name | Archetype | Type | Phase Entry |
|----|------|-----------|------|-------------|
| A-001 | [Claude](A-001-claude-the-copilot.md) | Browsing Copilot | Conversational LLM | Phase 4 |
| A-002 | [Crawler](A-002-crawler-the-harvester.md) | Autonomous Data Harvester | Headless Worker | Phase 4 |
| A-003 | [Sentinel](A-003-sentinel-the-guardian.md) | Security & Privacy Guardian | Background Monitor | Phase 4 |
| A-004 | [Weaver](A-004-weaver-the-automator.md) | Workflow Automator | Task Orchestrator | Phase 5 |

## Persona–Phase Matrix

Shows which personas are active stakeholders at each phase:

| Phase | P-001 Kai | P-002 Amara | P-003 Maya | P-004 Jordan | P-005 Suki | A-001 Claude | A-002 Crawler | A-003 Sentinel | A-004 Weaver |
|-------|-----------|-------------|------------|--------------|------------|--------------|---------------|----------------|--------------|
| 0 Shell | **Primary** | — | **Primary** | — | — | — | — | — | — |
| 1 Render | **Primary** | Observer | **Primary** | Observer | — | — | — | — | — |
| 2 Paint | **Primary** | Observer | **Primary** | Observer | — | — | — | — | — |
| 3 Interact | **Primary** | **Primary** | **Primary** | Observer | **Primary** | — | — | — | — |
| 4 Connect | **Primary** | **Primary** | Secondary | **Primary** | **Primary** | **Primary** | **Primary** | **Primary** | — |
| 5 Extend | **Primary** | Secondary | **Primary** | **Primary** | Secondary | Secondary | Secondary | Secondary | **Primary** |
| 6 Comply | **Primary** | Secondary | Secondary | **Primary** | Secondary | Secondary | Secondary | — | Secondary |
| 7 Ship | Secondary | Secondary | **Primary** | **Primary** | Secondary | Secondary | Secondary | Secondary | Secondary |

## Persona Relationships

```
Kai (P-001) ──builds tools for──→ Dr. Amara (P-002)
Kai (P-001) ──shares configs with──→ Maya (P-003)
Jordan (P-004) ──files bugs found by──→ Claude (A-001)
Suki (P-005) ──audits findings from──→ Sentinel (A-003)
Dr. Amara (P-002) ──writes pipelines for──→ Crawler (A-002)
Maya (P-003) ──defines workflows for──→ Weaver (A-004)
Claude (A-001) ──queries findings from──→ Sentinel (A-003)
Weaver (A-004) ──orchestrates──→ Crawler (A-002)
```
