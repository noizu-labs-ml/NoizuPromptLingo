# US-258: Game Balance Dashboard

**Persona:** Dave — MUD veteran sysadmin who wants real-time operational visibility into game health
**Priority:** P1
**Epic:** Admin, GM & Infrastructure

## Story
As Dave, I want a real-time balance dashboard showing combat metrics, economic health, class distribution, and drop rates so that I can identify balance problems and economy exploits before they become community crises.

## Acceptance Criteria
- [ ] Dashboard is a web application (not in-game) accessible to GM Lead+ role; loads without login for authenticated sessions; fully keyboard-navigable and screen reader compatible per WCAG 2.1 AA (per US-264)
- [ ] Combat balance panel shows: average combat duration by class matchup (as a matrix: Warrior vs. Mage win rate, Warrior vs. Rogue win rate, etc.), kill/death ratios by class over configurable time window (24h/7d/30d), top 10 highest-damage abilities by frequency of use and average damage, PvP vs. PvE kill distribution
- [ ] Economy health panel shows: gold supply total and rate of change (minted vs. destroyed per hour), top 10 traded items by volume and price trend (7-day), active auction listings count, merchant sales volume by city, and inflation index (average price of a basket of standard goods vs. historical baseline)
- [ ] Class distribution panel shows: current active player count by class, level distribution histogram per class (bar chart with text data table equivalent), class representation at each tier of endgame content, class representation in PvP top 100
- [ ] Anomaly detection: system flags automatically when: any class shows win rate above 60% against more than 3 others (over-powered), any item's price changes more than 50% in 24 hours (manipulation), gold creation rate exceeds 3 standard deviations above 30-day mean (exploit), server tick latency exceeds threshold; flagged anomalies shown in dashboard header with timestamp and severity
- [ ] Drop rate monitoring: configurable expected drop rates per item per loot table; dashboard shows actual drop rates over rolling 7-day window vs. expected; deviations highlighted; GMs can query any item's drop history: "Void Dragon Scale: expected 5% from Void Dragon, actual 7.3% over last 1,000 kills"
- [ ] All dashboard data available as JSON API for external tooling; API endpoints authenticated with GM-scoped tokens; rate-limited to 60 requests/minute; data is read-only via API
- [ ] Historical data retained for 12 months; time-range selector on all panels; ability to export any panel's data as CSV for offline analysis

## Notes
Dave's instinct as a sysadmin is to reach for observability tooling. The game balance dashboard is the game's equivalent of a Grafana instance — a live view of the system's health that turns raw data into actionable insight.

The anomaly detection system is the highest-value feature. Without it, Dave is checking dashboards reactively after players report problems. With it, the system pages him (or sends a notification) before players notice. The anomaly thresholds should be tunable — each metric has a configurable threshold, and Dave can silence false positives while investigating.

The combat balance matrix (class A win rate vs. class B) is the key combat health metric. A perfectly balanced game would show 50% win rates across all matchups. Deviations indicate balance problems. The matrix should be presented as a text table for screen reader compatibility: "Warrior vs. Mage: Warrior wins 58% (based on 2,847 encounters in the last 7 days)." This is more useful than a color-coded heat map that a screen reader can't interpret.

Economy surveillance is where the game's fun goes to die if ignored. Gold inflation destroys the meaning of rewards; price manipulation by organized clans creates a two-tier economy. The inflation index (basket of goods approach) is the right long-term health metric — track the price of a Health Potion, an Iron Sword, and a basic room rental over time. If these are rising 5% per week, gold is being minted faster than it's being destroyed and the death tax or crafting costs need adjustment.

The JSON API is important for Dave's personal tooling habits. Sysadmins build their own dashboards. Giving Dave a machine-readable API means he can pipe game balance data into his existing monitoring infrastructure, set custom alerts, and correlate game events with server metrics (does combat latency spike during faction wars?).

Consider a "balance event" log: when a GM makes a balance change (adjusts drop rate, modifies ability damage), it's logged with a timestamp and visible in the dashboard as a vertical marker on time-series graphs. This allows correlating "we buffed Warriors on Tuesday" with "Warrior win rate spiked on Wednesday."
