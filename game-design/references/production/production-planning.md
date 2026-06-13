# Production Planning

Team structure, milestone scheduling, and budget estimation for game projects.

## Team Structure

### Mobile Game Team (F2P, Mid-Core)

| Role | Count | Responsibility | Hire Priority |
|------|-------|---------------|--------------|
| Game Designer | 1-2 | Systems, economy, levels | Phase 1 |
| Unity Developer | 2-3 | Client implementation | Phase 1 |
| Backend Developer | 1-2 | Server, APIs, live ops | Phase 1 |
| 2D Artist | 1-2 | Characters, environments, UI | Phase 1 |
| 3D Artist | 0-1 | 3D assets (if 3D game) | Phase 2 |
| UI/UX Designer | 1 | Screens, flows, store | Phase 1 |
| Producer | 1 | Schedule, milestones, budget | Phase 1 |
| QA | 1-2 | Testing, regression, balance | Phase 2 |
| Community Manager | 1 | Social, Discord, support | Phase 3 |
| Data Analyst | 1 | KPIs, A/B tests, economy | Phase 3 |
| Live Ops Designer | 1 | Events, seasons, content | Phase 3 |

### Indie PC/Console Team

| Role | Count | Responsibility | Hire Priority |
|------|-------|---------------|--------------|
| Game Designer / Director | 1 | Vision, design, direction | Phase 1 |
| Programmer | 1-3 | All technical implementation | Phase 1 |
| Artist | 1-2 | All visual assets | Phase 1 |
| Writer | 0-1 | Narrative, dialogue | Phase 2 |
| Sound / Music | 0-1 (contract) | Audio assets | Phase 2 |
| Producer | 0-1 (part-time) | Schedule, publishing | Phase 1 |

## Budget Estimation

### Cost Categories

| Category | % of Budget | Notes |
|----------|------------|-------|
| Personnel (salaries) | 50-70% | Largest cost by far |
| Software & tools | 3-5% | Engine licenses, IDE, design tools |
| Hardware | 3-5% | Dev machines, test devices |
| Art outsourcing | 5-15% | If team lacks art capacity |
| Audio outsourcing | 2-5% | Music, SFX, VO |
| Backend infrastructure | 2-5% | Servers, databases, CDN |
| Marketing | 10-20% | CPI, influencer, PR |
| QA & testing | 3-5% | Devices, certification |
| Contingency | 10-15% | Always budget for surprises |

### Salary Ranges (US, 2025-2026)

| Role | Junior | Mid | Senior |
|------|--------|-----|--------|
| Game Designer | $50K | $75K | $100K+ |
| Unity Developer | $60K | $90K | $120K+ |
| Backend Developer | $65K | $95K | $130K+ |
| 2D Artist | $45K | $65K | $90K+ |
| 3D Artist | $50K | $75K | $100K+ |
| Producer | $55K | $80K | $110K+ |
| QA Tester | $35K | $50K | $70K+ |

## Milestone Scheduling

### Typical Mobile F2P Schedule

```
Month 1-2: PRE-PRODUCTION
├── GDD complete
├── Core prototype playable
├── Art style guide established
├── Tech stack validated
└── Team fully staffed

Month 3-5: PRODUCTION ALPHA
├── Core loop fully implemented
├── Basic progression working
├── Placeholder art in
├── Backend APIs operational
└── First playtest sessions

Month 6-8: PRODUCTION BETA
├── All features implemented
├── Final art replacing placeholders
├── Economy first-pass balanced
├── Store listing prepared
└── QA regression testing

Month 9-10: CONTENT COMPLETE
├── All content in
├── Economy fully balanced
├── Monetization integrated
├── Tutorial finalized
└── Performance optimized

Month 11-12: SOFT LAUNCH
├── Launch in 1-3 test markets
├── KPI monitoring and iteration
├── A/B testing monetization
├── Bug fixes and polish
└── Worldwide launch preparation

Month 13+: LIVE OPS
├── Worldwide launch
├── Live event calendar
├── Content update pipeline
├── Community management
└── Expansion planning
```

## Risk Assessment

### Common Game Project Risks

| Risk | Probability | Impact | Mitigation |
|------|-----------|--------|-----------|
| Scope creep | High | High | Strict MoSCoW, feature freeze at beta |
| Core loop not fun | Medium | Critical | Prototype early, playtest often |
| Performance issues | Medium | High | Profile weekly, target min-spec early |
| Team burnout | Medium | High | Sustainable pace, milestone buffer |
| Economy imbalance | High | Medium | Economist/analyst, simulation tools |
| App store rejection | Low | High | Pre-submission checklist, guidelines review |
| Market shift | Medium | Medium | Trend monitoring, pivot capability |
| Key person dependency | Medium | High | Documentation, cross-training |

### Risk Matrix

```
                    IMPACT
             Low    Medium    High    Critical
          ┌────────┬─────────┬───────┬──────────┐
   High   │ Monitor│ Mitigate│ Avoid │ Terminate│
   Medium │ Accept │ Monitor │Mitigate│ Avoid    │
   Low    │ Ignore │ Accept  │Monitor│ Mitigate │
          └────────┴─────────┴───────┴──────────┘
                          PROBABILITY
```
