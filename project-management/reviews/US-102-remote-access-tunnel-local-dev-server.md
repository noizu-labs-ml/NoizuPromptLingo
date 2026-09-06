# Review: Open a Remote-Access Tunnel to a Local Dev Server

- **Story**: `project-management/user-stories/US-102-remote-access-tunnel-local-dev-server.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented on the Elixir backend. `NoizuPromptLingua.Domains.RemoteAccess` (`backend/lib/noizu_prompt_lingua/domains/remote_access/remote_access.ex`) implements named, token-authenticated reverse tunnels for `<name>.remote-access.noizu.com`: `claim_tunnel/4` (:23) issues a one-time 32-byte token stored only as a SHA-256 hash with a TTL (default 30 days) and rejects names held by another user (`{:error, :name_taken}`, :53-54, plus unique-index fallback :64-66); `revoke_tunnel/2` (:80) tombstones a claim to free the name; frps callbacks `authorize_login/1` (:104), `authorize_proxy/2` (:118, enforces the token's claim owns the requested subdomain), and `mark_disconnected/1` (:128) wire into the tunnel server via an HTTP auth endpoint. HTTP surface and tests exist: `backend/test/noizu_prompt_lingua_web/controllers/remote_access_tunnels_test.exs` and `remote_access_frp_auth_test.exs`. Residual caveats: the frps server binary/config itself is infra-side (not in this repo), name uniqueness is global rather than project-scoped (stronger than the story's requirement, so no cross-org collision risk), and automatic reconnection is native frpc/frps behavior that the backend supports by re-validating the same token on reconnect.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| frpc with valid project-scoped token connects and local port becomes reachable at `<name>.remote-access.noizu.com` within seconds | Met | `remote_access.ex:104-113` `authorize_login/1` validates token and marks connected; `authorize_proxy/2` (:118-123) gates the subdomain; frps performs the actual routing (infra) |
| Name already claimed by another active tunnel → clear conflict error, no hijack | Met | `remote_access.ex:53-54` returns `{:error, :name_taken}`; unique-index race path also maps to `:name_taken` (:64-66); verified in `remote_access_tunnels_test.exs` |
| Client disconnect stops routing; reconnects automatically when client returns | Met | `mark_disconnected/1` (:128-135) clears `last_connected_at` on CloseProxy; reconnect re-authenticates the same token via `authorize_login/1`; routing stop/start is frps-native behavior |
| Intentional stop releases the route for reuse within bounded time | Met | `revoke_tunnel/2` (:80-91) sets status "revoked" freeing the active-name slot immediately; `expires_at` TTL (:27-30) bounds stale claims |

## Gaps / Risks

- Names are globally unique across orgs, not project-scoped as the Notes suggest; functionally safe (prevents collisions) but a squatted name blocks other orgs until TTL/revoke.
- Only the SHA-256 hash of the token is stored (good), but there is no delivery-audit of who claimed/revoked beyond rows themselves.
- SSE/health-visibility of tunnel status exists only as `connected?/1` (:94); no push notification when a tunnel drops.
- The frps deployment and DNS wildcard are outside this repo — e2e reachability "within a few seconds" cannot be verified from code here alone.

## BDD Scenario

```gherkin
Feature: Expose a local dev server via a named reverse tunnel

  Scenario: Jordan claims a tunnel name and connects
    Given Jordan is authenticated in an organization
    When he claims the name "jordan-dev" and receives a one-time tunnel token
    And his local frpc presents that token to the frps server
    Then frps validates it via the platform's frp-auth callback
    And his local port is reachable at jordan-dev.remote-access.noizu.com

  Scenario: Name conflict
    Given "jordan-dev" is an active claim held by another user
    When Jordan attempts to claim the same name
    Then he receives a clear name-taken error and no claim is created

  Scenario: Disconnect and return
    Given an active tunnel for "jordan-dev"
    When Jordan's frpc disconnects
    Then the platform marks the claim disconnected and frps stops routing to the dead backend
    When his frpc reconnects with the same token
    Then the login is authorized again and the route is restored

  Scenario: Release the name
    When Jordan revokes "jordan-dev"
    Then the claim is tombstoned and the name becomes claimable by others immediately
```
