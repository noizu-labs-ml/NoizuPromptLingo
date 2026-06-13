---
id: story-008
title: "Track mood drift over time"
persona: persona-the-monitor
priority: should-have
complexity: M
status: draft
---

# Track mood drift over time

**As** The Monitor,
**I want to** track the rolling average of emotional metadata across recent memories and detect significant mood drift from baseline,
**So that** system operators can observe whether the agent's memory landscape is skewing toward persistent negative or positive emotional states.

## Acceptance Criteria
- [ ] A rolling emotional baseline is maintained using an exponential moving average over the last N memories (configurable, default 100)
- [ ] Mood drift is computed as the delta between current rolling average and the long-term baseline (all-time or last 30 days)
- [ ] Drift alerts fire when any emotional dimension (valence, arousal, frustration, any hormone) deviates by more than 2 standard deviations from baseline
- [ ] Drift metrics are emitted as time-series data points for dashboard visualization
- [ ] Seasonal mood patterns are accounted for — drift is compared against the same season's historical baseline when available

## Scenario: Gradual negative drift detected
- **Given** the last 100 memories have an average valence of -0.4 while the long-term baseline is -0.05
- **When** The Monitor computes mood drift
- **Then** a `MoodDriftAlert` is raised with dimension: "valence", current: -0.4, baseline: -0.05, deviation: 3.2 sigma, and the alert is surfaced to the Human Operator dashboard

## Scenario: Seasonal adjustment prevents false alert
- **Given** memories formed in December historically show elevated cortisol (0.6 vs annual average 0.4) due to year-end workload patterns
- **When** December memories arrive with cortisol at 0.65
- **Then** The Monitor compares against the December seasonal baseline (0.6), finds only 0.5 sigma deviation, and does not raise an alert

## Technical Notes
- Mood drift is a leading indicator of problematic memory patterns — persistent negative drift may indicate the agent is accumulating frustration-heavy memories
- The exponential moving average window size should balance responsiveness vs. noise
- Seasonal baselines require at least one full year of data; fall back to all-time baseline when seasonal data is insufficient
- Consider separate drift tracking per domain/topic — a negative drift in "debugging" memories is expected; a drift in "onboarding" memories is concerning

## Related Stories
- story-001: Emotional metadata captured by The Archivist is the input to mood drift computation
- story-009: Anomaly detection uses mood drift as one of several health signals
- story-025: Human Operator dashboard displays mood drift visualizations
- story-014: Curator decay scheduling may be influenced by mood drift (deprioritize decaying positive memories during negative drift)
