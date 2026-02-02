# User Story: Monitor Sprint Progress with Agent Metrics

**ID**: US-033
**Persona**: P-004 (Project Manager)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:20:00Z

## Story

As a **project manager**,
I want to **see sprint progress that includes both human and agent contributions**,
So that **I can forecast completion and balance workload effectively**.

## Context

This user story extends the **NPL MCP Task Queue system** (US-015) with advanced sprint-level metrics and forecasting capabilities. While US-015 provides real-time task queue visibility, this story focuses on historical trend analysis, velocity tracking, burndown charts, and workload balancing across agents and human team members. The sprint metrics dashboard aggregates data from task queues, work logs, and artifact history to provide predictive insights for project managers.

## Acceptance Criteria

### Sprint Metrics Dashboard
- [ ] Can retrieve sprint metrics using `get_sprint_metrics` with sprint_id or date range
- [ ] Sprint summary includes: total tasks, completed tasks, completion percentage, days remaining, projected completion date
- [ ] Metrics distinguish between agent-completed and human-completed tasks with separate counts and percentages
- [ ] Dashboard displays task breakdown by status (pending, in_progress, blocked, review, done) with agent vs. human split
- [ ] Can filter metrics by task priority (high, medium, low) to assess critical path progress
- [ ] Metrics include average task completion time separately for agents and humans

### Burndown Chart with Agent Throughput
- [ ] Web UI displays burndown chart showing planned vs. actual task completion over time
- [ ] Burndown chart uses separate lines for agent throughput and human throughput
- [ ] Chart highlights periods where agent velocity exceeded or fell below historical average
- [ ] Ideal burndown line adjusts based on weighted average of recent agent and human velocity
- [ ] Chart shows blocked tasks as a separate metric to identify bottleneck patterns
- [ ] Can toggle between task count burndown and story point burndown (if complexity estimates exist)

### Velocity Metrics and Forecasting
- [ ] Dashboard displays sprint velocity (tasks/day or points/day) for last 3 sprints with agent/human breakdown
- [ ] Velocity calculation uses rolling average to smooth out daily fluctuations
- [ ] Forecast completion date updates based on current sprint velocity and remaining work
- [ ] Dashboard shows confidence interval for forecast (optimistic/realistic/pessimistic scenarios)
- [ ] Can compare current sprint velocity to historical team baseline
- [ ] Alerts shown when velocity drops below 80% of historical average

### Blocked Tasks and Bottleneck Analysis
- [ ] Blocked tasks section highlights tasks blocked for >24 hours
- [ ] Each blocked task shows blocker source (dependency on specific task, waiting on review, external dependency)
- [ ] Dashboard displays most common blocker types to identify systemic issues
- [ ] Can drill down to dependency chain visualization showing what blocks what
- [ ] Metrics include "average time to unblock" for different blocker categories

### Individual Contributor Drill-Down
- [ ] Can filter dashboard to view specific agent or human contributions
- [ ] Individual view shows: tasks completed, average completion time, success rate, current assignments
- [ ] Agent-specific metrics include: retry attempts, escalation frequency, artifact quality scores (if reviews exist)
- [ ] Human-specific metrics include: review turnaround time, pairing sessions with agents
- [ ] Can compare individual performance to team average for workload balancing decisions

### Quality and Risk Indicators
- [ ] Dashboard flags when >70% of sprint work is agent-completed (potential quality risk)
- [ ] Shows ratio of tasks requiring rework or returning from review status
- [ ] Displays test failure rate for agent-completed vs. human-completed tasks (if test data available)
- [ ] Alerts when agent task complexity estimates significantly exceed actual completion time (calibration issue)

## Notes

- **Agent velocity variability**: Agent throughput may fluctuate more than human velocity due to API rate limits, service outages, or complexity mismatches. Forecast models should account for higher variance in agent estimates.
- **Normalization challenge**: "Agent hours" vs. "human hours" are not directly comparable. Consider using task completion count or story points as primary velocity metrics rather than time-based estimates.
- **Quality vs. speed trade-off**: Agent-heavy sprints may achieve higher throughput but risk accumulating technical debt if review cycles are insufficient. Dashboard should surface this risk proactively.
- **Real-time vs. historical**: Sprint metrics are primarily historical/analytical (calculated on demand), while US-015 provides real-time task status. Consider caching sprint metrics and recalculating hourly rather than on every request.
- **Sprint boundary definition**: If tasks don't have explicit `sprint_id` field, metrics may need to filter by creation date range. Recommend adding sprint metadata to task schema.

## Dependencies

- Task Queue system with status tracking (US-015)
- Agent Work Logs for throughput calculation (US-031)
- Task complexity estimates for story point burndown (US-030, optional)
- Historical task data for velocity baselines (minimum 3 completed sprints recommended)

## Open Questions

- [ ] **Story point normalization**: How to normalize agent vs. human story points? (Options: 1) Don't normalize, track separately; 2) Apply calibration factor based on historical completion times; 3) Use task count instead of points)
- [ ] **Team velocity composition**: Should agent work count toward official team velocity for stakeholder reporting? (Recommendation: Yes, but break out composition in reports to show automation percentage)
- [ ] **Sprint scope changes**: How to handle mid-sprint scope changes in burndown chart? (Options: 1) Show scope line that can increase; 2) Mark scope changes with annotations; 3) Recalculate ideal line from scope change point)
- [ ] **Cross-sprint metrics**: Should dashboard support multi-sprint trend analysis (release-level planning)? (Consider: Add separate release dashboard view)
- [ ] **Agent downtime tracking**: Should dashboard account for planned agent downtime (maintenance, rate limit cooldowns) in forecasts? (May improve forecast accuracy but adds complexity)
- [ ] **Workload balancing automation**: Should system automatically suggest task reassignments to balance agent/human workload? (Defer to future story - needs workload optimization algorithm)

## Related Commands

**Primary Commands** (to be implemented):
- `get_sprint_metrics` (Task Queue Tools) - Retrieve sprint-level metrics with agent/human breakdown
- `get_sprint_burndown` (Task Queue Tools) - Get burndown chart data points
- `get_velocity_trends` (Task Queue Tools) - Historical velocity analysis
- `get_blocked_task_summary` (Task Queue Tools) - Aggregated blocker analysis

**Supporting Commands** (existing):
- `get_task_queue` (Task Queue Tools) - Real-time task counts by status (US-015)
- `list_tasks` (Task Queue Tools) - Task list with filtering for metric calculation
- `get_task_queue_feed` (Task Queue Tools) - Activity history for velocity calculation
- `get_agent_work_logs` (Work Log Tools) - Agent throughput data (US-031)

**Web UI Routes** (to be implemented):
- `/dashboard/sprint/{sprint_id}` - Sprint metrics dashboard
- `/dashboard/sprint/{sprint_id}/burndown` - Interactive burndown chart
- `/dashboard/velocity` - Velocity trends across sprints
- `/dashboard/contributors/{agent_or_user_id}` - Individual drill-down
