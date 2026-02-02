# US-076 - Create Security Dashboard for Access Violations

**ID**: US-076
**Persona**: P-004 - Project Manager
**PRD Group**: coordination
**Priority**: medium
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a project manager, I need a security dashboard showing recent access violations, failed authentication attempts, and secret detections so that I can monitor for security threats.

## Acceptance Criteria

- [ ] Dashboard displays last 50 access violations with timestamp, persona, resource, operation
- [ ] Shows failed permission checks grouped by persona
- [ ] Displays secret detection events with artifact name and pattern matched
- [ ] Allows filtering by date range, persona, violation type
- [ ] Export to CSV for compliance reporting
- [ ] Real-time updates when violations occur

## Technical Notes

This story creates a monitoring interface for security-related events. Implementation considerations:

1. **Data source**: Depends on audit logging infrastructure (US-070)
2. **UI implementation**: Could be web-based dashboard in the MCP server UI
3. **Real-time updates**: Consider WebSocket or SSE for live event streaming
4. **Query performance**: Index audit tables by timestamp, persona, violation type
5. **Retention policy**: Define how long to keep violation records
6. **Alerting**: Consider integration with external alerting systems (email, Slack)

Extends US-005 (session dashboard) with security-specific monitoring capabilities.

## Dependencies

- Related stories: US-005
- Related personas: P-004 (Project Manager)
