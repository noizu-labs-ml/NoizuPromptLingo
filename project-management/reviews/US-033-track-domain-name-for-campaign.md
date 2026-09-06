# Review: Track a Domain Name Against a Campaign

- **Story**: `project-management/user-stories/US-033-track-domain-name-for-campaign.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented as MCP tools on the Elixir backend. `DomainName.Create` persists a domain record org-scoped with optional `campaign_id` (`backend/lib/noizu_prompt_lingua/domains/campaigns/tools/domain_name_create.ex:31-52`), `DomainName.Update` changes status with statuses `candidate/available/registered/in_use/expired` (`backend/lib/noizu_prompt_lingua/domains/campaigns/tools/domain_name_update.ex:24-44`), and the schema enforces org-level uniqueness on slug and FQDN (`backend/lib/noizu_prompt_lingua/schema/domain_name.ex:42-43`). One gap: the list tool filters by project/status/tag but not by campaign, so "listed under that campaign" is only achievable by reading `campaign_id` from records rather than a campaign-filtered query.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Add a domain name to an open campaign; saved and listed under that campaign | Partially Met | create accepts `campaign_id`: `domain_name_create.ex:27,50`; but `DomainName.List` has no campaign filter (`domain_name_list.ex:11-38`) |
| Update status (reserved/pointed/live equivalents); persisted and reflected | Met | `DomainName.Update` persists status via `Campaigns.update_domain_name` (`domain_name_update.ex:42-44`; `campaigns.ex:183`), schema validates inclusion (`schema/domain_name.ex:38`) |
| Warn when same domain added to a second campaign instead of silent duplicate | Not Met | unique constraints are org-scoped only (`schema/domain_name.ex:42-43`); nothing checks existing campaign associations or warns |

## Gaps / Risks

- No duplicate-association warning: the same FQDN under a second campaign_id fails only if it violates org-level uniqueness — otherwise the update silently re-points the domain. The status vocabulary also differs from the story's examples (reserved/pointed/live → candidate/available/registered/in_use/expired), which is fine in substance but worth aligning.
- Tools are `hidden: true` in the MCP catalog — confirm that is intended for the Growth Operator surface.

## BDD Scenario

```gherkin
Feature: Track a Domain Name Against a Campaign

  Scenario: Add and update a tracked domain
    Given a growth operator has an organization and a campaign
    When they call DomainName.Create with name "example.com" and the campaign UUID
    Then the domain is stored org-scoped with status "candidate"
    When they call DomainName.Update with status "registered"
    Then the persisted status changes and DomainName.List reflects it

  Scenario: Duplicate campaign association
    Given the domain "example.com" is already tracked with campaign A
    When the operator adds the same FQDN under campaign B
    Then no warning about the existing association is produced
    And the duplicate-association check remains unimplemented
```
