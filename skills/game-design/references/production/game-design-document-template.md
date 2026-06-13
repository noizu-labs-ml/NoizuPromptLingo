# Game Design Document Template

Canonical GDD structure for game projects from concept through production.

## Document Structure

```markdown
# [Game Title] — Game Design Document

## 1. Executive Summary
### 1.1 Vision Statement (1-2 sentences)
### 1.2 Genre & Platform
### 1.3 Target Audience
### 1.4 Unique Selling Points (3-5 bullets)
### 1.5 Comparable Titles

## 2. Gameplay Overview
### 2.1 Core Fantasy
### 2.2 Core Loop Diagram
### 2.3 Meta Loop Diagram
### 2.4 Session Flow (expected session length and pacing)
### 2.5 Minute-by-Minute Walkthrough (first 5 minutes)

## 3. Player Experience
### 3.1 Target Player Personas
### 3.2 Emotional Journey (what should the player feel?)
### 3.3 Difficulty Curve
### 3.4 Accessibility Considerations

## 4. Game Systems
### 4.1 Progression System
### 4.2 Economy System
### 4.3 Combat / Core Mechanic System
### 4.4 Crafting / Upgrade System
### 4.5 Social / Multiplayer Systems
### 4.6 Achievement / Collection Systems

## 5. Content Scope
### 5.1 Level / Area Count
### 5.2 Enemy / Boss Count
### 5.3 Item / Equipment Count
### 5.4 Quest / Mission Count
### 5.5 Story Chapter Breakdown

## 6. Monetization
### 6.1 Revenue Model
### 6.2 IAP Catalog
### 6.3 Battle Pass / Season Structure (if applicable)
### 6.4 Ad Strategy (if applicable)
### 6.5 Economy Balance Sheet
### 6.6 Pricing Strategy

## 7. Narrative
### 7.1 Story Summary (1 paragraph)
### 7.2 World Bible Reference
### 7.3 Character List with Arcs
### 7.4 Story Spine (8-point structure)
### 7.5 Dialogue Scope (line count estimate)

## 8. Art & Audio
### 8.1 Art Style Reference
### 8.2 Character Design Direction
### 8.3 Environment Design Direction
### 8.4 UI/UX Design Direction
### 8.5 Music & SFX Direction
### 8.6 VO Scope (if applicable)

## 9. Technology
### 9.1 Engine Selection (Unity/Unreal/Godot/Custom)
### 9.2 Platform Requirements
### 9.3 Minimum Specs
### 9.4 Backend Requirements (if multiplayer)
### 9.5 Third-Party Services (analytics, ads, IAP, auth)

## 10. Production Plan
### 10.1 Team Structure
### 10.2 Milestone Schedule
### 10.3 Budget Estimate
### 10.4 Risk Assessment
### 10.5 QA Plan

## 11. Launch Plan
### 11.1 Soft Launch Strategy
### 11.2 KPI Targets
### 11.3 Marketing Plan
### 11.4 Launch Checklist
### 11.5 Live Ops Roadmap (first 6 months)

## Appendices
### A. Concept Art
### B. Prototype Feedback
### C. Market Research
### D. Competitive Analysis
```

## Milestone Definitions

| Milestone | Definition | Gate Criteria |
|-----------|-----------|---------------|
| **Concept** | Vision documented, prototype approved | Stakeholder sign-off on GDD |
| **Prototype** | Core mechanic playable | Core loop is fun (validated by playtest) |
| **Alpha** | All systems implemented, placeholder content | All features in, game playable end-to-end |
| **Beta** | Content complete, polish pass | All content in, no crashes, feature complete |
| **Gold** | Submission-ready | All bugs P2+, certification passing |
| **Launch** | Public release | Live in stores, monitoring KPIs |
| **Post-Launch** | Live ops begin | First event scheduled, KPI dashboard active |

## Scope Estimation

### By Team Size

| Team Size | Game Scope | Timeline | Budget (Annual) |
|-----------|-----------|----------|-----------------|
| Solo (1) | Small mobile game, prototype | 3-6 months | $0-$20K (opportunity cost) |
| Small (2-5) | Mobile game, small PC game | 6-12 months | $50K-$200K |
| Medium (5-15) | Mid-core mobile, mid-size PC | 12-24 months | $200K-$1M |
| Large (15-50) | AAA mobile, AA PC/console | 18-36 months | $1M-$10M |
| Studio (50+) | AAA PC/console | 24-48 months | $10M-$100M+ |

### Content Production Rates

| Asset Type | Per Day | Per Week | Notes |
|-----------|---------|----------|-------|
| 3D character (rigged) | - | 1-2 | Senior 3D artist |
| 2D character (animated) | - | 2-4 | Senior 2D artist |
| Environment tileset | - | 1-2 | Modular approach |
| Level/mission design | 1-3 | 5-15 | Complexity dependent |
| UI screen | 2-4 | 10-20 | Design + implementation |
| Music track | - | 1-2 | Composer |
| SFX | 5-10 | 25-50 | Sound designer |
| Dialogue lines (written) | 50-100 | 250-500 | Writer |
| Dialogue lines (VO recorded) | 20-40 | 100-200 | Studio session |
