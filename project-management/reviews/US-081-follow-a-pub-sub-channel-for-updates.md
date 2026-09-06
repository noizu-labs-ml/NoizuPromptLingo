# Review: Follow a Pub/Sub Channel for Updates

- **Story**: `project-management/user-stories/US-081-follow-a-pub-sub-channel-for-updates.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented on the Elixir backend (`/Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend`). `PubSub.Follow` / `PubSub.Unfollow` MCP tools (`backend/lib/noizu_prompt_lingua/domains/pubsub/tools/follow.ex`, `tools/unfollow.ex`) wrap `Domains.PubSub.follow/unfollow` (`backend/lib/noizu_prompt_lingua/domains/pubsub/pubsub.ex:114-133`). Delivery is a deliberate two-part model (documented at `pubsub.ex:2-17`): a coalesced `pubsub_available` availability pointer in each follower's notification inbox on publish (`notify_followers`, `pubsub.ex:85-102`) plus a real-time Phoenix.PubSub wake broadcast on topic `pubsub:<channel_id>` (`pubsub.ex:104-110`); messages are pulled via `fetch_channel`/`fetch_all`. The scope story: channel resolution is org-scoped — `get_channel(org_id, ref)` filters by `organization_id` (`pubsub.ex:39-49`) — so a channel from another org resolves to nil and yields "Channel not found". However, the follow tool itself verifies no caller→organization membership/authorization (`Resolve.organization_id/1` just resolves the ref); enforcement is deferred to the MCP auth layer rather than the tool. Confidence: high on mechanics, medium on the authorization criterion.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Follow → subsequent events delivered to the agent's active session | Met | `pubsub.ex:69-110` — publish appends message, notifies every follower (`notify_followers`) and broadcasts `{:pubsub_message, msg}` on `pubsub:<channel_id>`; follow is an idempotent upsert (`pubsub.ex:114-122`) |
| Explicit unfollow → no further delivery | Met | `pubsub.ex:124-133` deletes the follow row; `notify_followers` (`pubsub.ex:85-102`) queries current followers live, so deleted follows stop receiving; `tools/unfollow.ex` exposes it |
| Follow outside authorized org/project scope rejected with authorization error | Partially Met | cross-org channel lookup fails closed (`get_channel` filters by `organization_id`, `pubsub.ex:39-49` → "Channel 'x' not found"); but the tool performs no caller-membership authz check itself (`tools/follow.ex:28-46` resolves org without `Authz.authorize`), unlike the review controller pattern (`review_controller.ex:114`) |

## Gaps / Risks

- The failure mode for an out-of-scope channel is "not found" (correct, information-minimizing) but the story asks for an *authorization* error path tied to the caller's scope; tool-level caller-to-org validation is absent and depends entirely on MCP-layer auth (`mcp_auth.ex`, `mcp_custom_scopes.ex`).
- No pagination/cursor on `fetch_all` beyond a limit (`pubsub.ex:215-226`) — high-volume followers re-fetch coarse windows.
- "Delivered to the agent's active session" is pointer+pull, not push-into-session; acceptable design, but agents must poll notifications/fetch — worth stating in the story.

## BDD Scenario

```gherkin
Feature: Follow a pub/sub channel for updates
  Scenario: Agent follows a channel and receives events
    Given an org-scoped channel "deploy-events" exists
    When the agent calls PubSub.Follow with organization, channel, and persona
    Then the follow is stored (idempotent on re-follow)
    And when a message is published, the agent's notification inbox gains a coalesced pubsub_available pointer
    And a wake broadcast fires on pubsub:<channel_id> for live sessions
  Scenario: Agent unfollows
    When the agent calls PubSub.Unfollow
    Then subsequent publishes produce no pointer or wake for that persona
  Scenario: Out-of-scope channel
    When the agent attempts to follow a channel belonging to a different organization
    Then the lookup fails closed with "Channel not found" (no cross-org leak) — though no explicit caller-vs-org authorization check runs in the tool today (gap)
```
