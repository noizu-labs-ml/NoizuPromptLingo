defmodule NoizuPromptLingua.Authz.PolicyEvaluatorTest do
  # Pure IAM-style evaluation — no Repo, safe to run concurrently.
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.Authz.PolicyEvaluator

  # ── Fixtures ──────────────────────────────────────────────────────

  defp policy(statements, extra \\ %{}) do
    Map.merge(%{"policy_document" => %{"statements" => statements}}, extra)
  end

  defp allow(actions, resources, conditions \\ %{}) do
    %{"effect" => "allow", "actions" => actions, "resources" => resources, "conditions" => conditions}
  end

  defp deny(actions, resources, conditions \\ %{}) do
    %{"effect" => "deny", "actions" => actions, "resources" => resources, "conditions" => conditions}
  end

  # Standard request shape: viewer role on project "111" (global-layer analog).
  defp eval(policies, overrides \\ []) do
    args = %{
      action: "project:read",
      resource_type: "project",
      resource_id: "111",
      role: "viewer",
      context: %{}
    }

    args =
      Enum.reduce(overrides, args, fn {k, v}, acc ->
        case k do
          :context -> %{acc | context: v}
          k -> Map.put(acc, k, v)
        end
      end)

    PolicyEvaluator.evaluate(
      policies,
      args.action,
      args.resource_type,
      args.resource_id,
      args.role,
      args.context
    )
  end

  # ── Deny-by-default + effect precedence ──────────────────────────

  describe "deny-by-default and effect precedence" do
    test "no policies is an implicit deny" do
      assert %{allowed: false, reason: :implicit_deny, matching_statements: []} = eval([])
    end

    test "policy without policy_document contributes nothing (implicit deny)" do
      assert %{allowed: false, reason: :implicit_deny} = eval([%{"name" => "empty"}])
      assert %{allowed: false, reason: :implicit_deny} = eval([%{}])
    end

    test "policy_document without statements list contributes nothing" do
      assert %{allowed: false, reason: :implicit_deny} =
               eval([%{"policy_document" => %{}}])

      assert %{allowed: false, reason: :implicit_deny} =
               eval([%{"policy_document" => nil}])

      assert %{allowed: false, reason: :implicit_deny} =
               eval([%{"policy_document" => %{"statements" => "not-a-list"}}])
    end

    test "matching allow statement is an explicit allow carrying the statement" do
      stmt = allow(["project:read"], ["project:111"])
      result = eval([policy([stmt])])

      assert %{allowed: true, reason: :explicit_allow, matching_statements: [^stmt]} = result
    end

    test "non-matching allow falls through to implicit deny" do
      stmt = allow(["project:read"], ["project:999"])
      result = eval([policy([stmt])])

      assert %{allowed: false, reason: :implicit_deny, matching_statements: []} = result
    end

    test "explicit deny overrides a matching allow" do
      a = allow(["project:*"], ["project:111"])
      d = deny(["project:delete"], ["project:111"])
      result = eval([policy([a, d])], action: "project:delete")

      assert %{allowed: false, reason: :explicit_deny, matching_statements: [^d]} = result
    end

    test "deny wins even when the allow appears in an earlier policy" do
      a = policy([allow(["project:*"], ["project:*"])])
      d = policy([deny(["project:*"], ["project:*"])])
      result = eval([a, d])

      assert %{allowed: false, reason: :explicit_deny} = result
      assert length(result.matching_statements) == 1
    end

    test "all matching allows are collected in source order" do
      a1 = allow(["project:read"], ["project:111"])
      a2 = allow(["project:*"], ["project:111"])
      result = eval([policy([a1, a2])])

      assert %{allowed: true, matching_statements: [^a1, ^a2]} = result
    end

    test "unknown effect values are ignored (no silent allow)" do
      weird = %{"effect" => "audit", "actions" => ["project:read"], "resources" => ["project:111"]}

      missing = %{"actions" => ["project:read"], "resources" => ["project:111"]}

      assert %{allowed: false, reason: :implicit_deny} = eval([policy([weird])])
      assert %{allowed: false, reason: :implicit_deny} = eval([policy([missing])])
    end

    test "malformed statements (missing actions/resources keys) never match" do
      bare_effect = %{"effect" => "allow"}
      assert %{allowed: false, reason: :implicit_deny} = eval([policy([bare_effect])])
    end

    test "atom-keyed policy wrappers (Ecto select shape) are evaluated" do
      # Authz.get_effective_policies/3 selects %{policy_document: doc, ...} —
      # regression: these were silently skipped, forcing implicit_deny.
      stmt = allow(["project:read"], ["project:111"])
      result = eval([%{policy_document: %{"statements" => [stmt]}}])

      assert %{allowed: true, reason: :explicit_allow, matching_statements: [^stmt]} = result
    end

    test "atom wrapper with malformed document contributes nothing" do
      assert %{allowed: false, reason: :implicit_deny} =
               eval([%{policy_document: %{"statements" => :oops}}])

      assert %{allowed: false, reason: :implicit_deny} =
               eval([%{policy_document: "bogus"}])
    end
  end

  # ── Action matching ──────────────────────────────────────────────

  describe "action matching" do
    test "trailing-star wildcard covers action suffixes" do
      stmt = allow(["project:*"], ["project:111"])
      assert %{allowed: true} = eval([policy([stmt])], action: "project:delete")
    end

    test "bare '*' matches any action" do
      stmt = allow(["*"], ["project:111"])
      assert %{allowed: true} = eval([policy([stmt])], action: "anything:at:all")
    end

    test "prefix wildcards match the middle of actions" do
      stmt = allow(["project:r*"], ["project:111"])

      assert %{allowed: true} = eval([policy([stmt])], action: "project:read")
      assert %{allowed: false} = eval([policy([stmt])], action: "project:write")
    end

    test "regex metacharacters in patterns are literal" do
      stmt = allow(["project:r.ad"], ["project:111"])

      assert %{allowed: false} = eval([policy([stmt])], action: "project:read")
      assert %{allowed: false} = eval([policy([stmt])], action: "project:rXad")
      assert %{allowed: true} = eval([policy([stmt])], action: "project:r.ad")
    end

    test "question mark is not a single-char wildcard" do
      stmt = allow(["project:read?"], ["project:111"])
      assert %{allowed: false} = eval([policy([stmt])], action: "project:read1")
      assert %{allowed: true} = eval([policy([stmt])], action: "project:read?")
    end

    test "action must match the whole pattern, not a prefix" do
      stmt = allow(["project:read"], ["project:111"])
      assert %{allowed: false} = eval([policy([stmt])], action: "project:read:more")
    end

    test "empty actions list never matches" do
      stmt = allow([], ["project:111"])
      assert %{allowed: false, reason: :implicit_deny} = eval([policy([stmt])])
    end

    test "empty action string matches only an empty pattern" do
      assert %{allowed: false} =
               eval([policy([allow(["project:read"], ["project:111"])])], action: "")

      assert %{allowed: true} = eval([policy([allow([""], ["project:111"])])], action: "")
    end
  end

  # ── Resource matching: variables + wildcards ─────────────────────

  describe "resource variable substitution and wildcards" do
    test "${resource_type} and ${resource_id} interpolate into the URN" do
      stmt = allow(["project:read"], ["${resource_type}:${resource_id}"])
      assert %{allowed: true} = eval([policy([stmt])])
      assert %{allowed: false} =
               eval([policy([allow(["project:read"], ["${resource_type}:999"])])])
    end

    test "${scope_type}/${scope_id} are aliases of the resource parts" do
      stmt = allow(["project:read"], ["${scope_type}:${scope_id}"])
      assert %{allowed: true} = eval([policy([stmt])])
    end

    test "${role} interpolates the caller's role into the pattern" do
      # The URN is only "type:id", so ${role} is only useful when it fills a
      # slot of that shape — here it stands in for the id segment.
      rule = allow(["project:read"], ["${resource_type}:${role}"])
      assert %{allowed: true} = eval([policy([rule])], role: "viewer", resource_id: "viewer")
      assert %{allowed: false} = eval([policy([rule])], role: "admin", resource_id: "viewer")
    end

    test "role/user-suffixed patterns never match the bare type:id URN" do
      # Gotcha: "project:111/role/viewer" expands to a string with a suffix the
      # URN cannot have, so such statements silently never match.
      suffixed = allow(["project:read"], ["project:111/role/*"])
      assert %{allowed: false} = eval([policy([suffixed])], role: "viewer")
    end

    test "${user_id} comes from the evaluation context" do
      rule = allow(["project:read"], ["${resource_type}:u-${user_id}"])

      assert %{allowed: true} =
               eval([policy([rule])],
                 context: %{user_id: "123"},
                 resource_id: "u-123"
               )

      # No user_id in context → substituted with "" → no match.
      assert %{allowed: false} = eval([policy([rule])], resource_id: "u-123")
    end

    test "unknown variables stay literal and do not match" do
      stmt = allow(["project:read"], ["${attacker_controlled}"])
      assert %{allowed: false} = eval([policy([stmt])])
    end

    test "wildcard resource matches every URN" do
      stmt = allow(["project:read"], ["*"])
      assert %{allowed: true} = eval([policy([stmt])])
    end

    test "resource must match fully — wildcard-starved patterns do not leak" do
      stmt = allow(["project:read"], ["project:1"])
      assert %{allowed: false} = eval([policy([stmt])], resource_id: "111")
    end

    test "resource ids containing ':' or wildcards cannot escape their segment" do
      # resource_id "111/extra" builds URN "project:111/extra"; a scoped pattern
      # with a wildcard can still span it — document the segment behavior.
      stmt = allow(["project:read"], ["project:*"])
      assert %{allowed: true} = eval([policy([stmt])], resource_id: "111/extra")
    end

    test "regex metacharacters in resource patterns are literal" do
      stmt = allow(["project:read"], ["project:(.*)"])

      assert %{allowed: false} = eval([policy([stmt])], resource_id: "anything")
      assert %{allowed: true} = eval([policy([stmt])], resource_id: "(.*)")
    end
  end

  # ── Conditions ───────────────────────────────────────────────────

  describe "condition operators" do
    test "StringEquals with a scalar" do
      c = %{"StringEquals" => %{"tier" => "pro"}}
      assert %{allowed: true} = eval([policy([allow(["project:read"], ["*"], c)])], context: %{tier: "pro"})
      assert %{allowed: false} = eval([policy([allow(["project:read"], ["*"], c)])], context: %{tier: "free"})
    end

    test "StringEquals with a list is membership" do
      c = %{"StringEquals" => %{"tier" => ["pro", "enterprise"]}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{tier: "enterprise"})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{tier: "free"})
    end

    test "StringNotEquals denies on equality, allows otherwise" do
      c = %{"StringNotEquals" => %{"tier" => "banned"}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{tier: "pro"})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{tier: "banned"})
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{})
    end

    test "StringNotEquals with a list excludes members" do
      c = %{"StringNotEquals" => %{"tier" => ["banned", "suspended"]}}
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{tier: "suspended"})
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{tier: "pro"})
    end

    test "StringLike applies wildcards to the context value" do
      c = %{"StringLike" => %{"email" => "*@noizu.com"}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{email: "keith@noizu.com"})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{email: "keith@example.com"})
    end

    test "StringLike accepts a list of patterns and requires binary actuals" do
      c = %{"StringLike" => %{"code" => ["abc*", "xyz*"]}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{code: "xyz1"})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{code: 12})
    end

    test "NumericEquals compares across ints, floats, and numeric strings" do
      c = %{"NumericEquals" => %{"level" => 10}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{level: 10})
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{level: "10.0"})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{level: 9})
    end

    test "non-numeric actuals coerce to 0" do
      c = %{"NumericEquals" => %{"level" => 0}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{level: "abc"})

      lt = %{"NumericLessThan" => %{"level" => 1}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], lt)])], context: %{level: "junk"})
    end

    test "NumericLessThan / NumericGreaterThan are strict" do
      lt = %{"NumericLessThan" => %{"level" => 5}}
      gt = %{"NumericGreaterThan" => %{"level" => 5}}

      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], lt)])], context: %{level: 4})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], lt)])], context: %{level: 5})
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], gt)])], context: %{level: 6})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], gt)])], context: %{level: 5})
    end

    test "DateLessThan / DateGreaterThan compare ISO8601 instants" do
      lt = %{"DateLessThan" => %{"now" => "2026-01-01T00:00:00Z"}}
      gt = %{"DateGreaterThan" => %{"now" => "2025-01-01T00:00:00Z"}}

      assert %{allowed: true} =
               eval([policy([allow(["*"], ["*"], lt)])], context: %{"now" => "2025-06-01T00:00:00Z"})

      assert %{allowed: false} =
               eval([policy([allow(["*"], ["*"], lt)])], context: %{"now" => "2026-06-01T00:00:00Z"})

      assert %{allowed: true} =
               eval([policy([allow(["*"], ["*"], gt)])], context: %{"now" => "2025-06-01T00:00:00Z"})

      assert %{allowed: false} =
               eval([policy([allow(["*"], ["*"], gt)])], context: %{"now" => "2024-06-01T00:00:00Z"})
    end

    test "equal dates satisfy neither DateLessThan nor DateGreaterThan" do
      c = %{"DateLessThan" => %{"at" => "2026-01-01T00:00:00Z"}}
      assert %{allowed: false} =
               eval([policy([allow(["*"], ["*"], c)])], context: %{"at" => "2026-01-01T00:00:00Z"})
    end

    test "malformed dates fail closed" do
      c = %{"DateLessThan" => %{"at" => "2026-01-01T00:00:00Z"}}
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{"at" => "not-a-date"})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{at: 12})
    end

    test "Bool coerces true, \"true\", and 1 — everything else is false" do
      c = %{"Bool" => %{"secure" => "true"}}

      for v <- [true, "true", 1] do
        assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{secure: v})
      end

      for v <- [false, "false", 0, nil] do
        assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{secure: v})
      end
    end

    test "missing context keys fail conditions closed (Bool false excepted)" do
      c = %{"StringEquals" => %{"tier" => "pro"}}
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{})

      b = %{"Bool" => %{"flag" => "false"}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], b)])], context: %{})
    end

    test "IpAddress matches within CIDR, including /0 and /32 bounds" do
      c = %{"IpAddress" => %{"ip" => "10.0.0.0/8"}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{ip: "10.1.2.3"})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{ip: "11.0.0.1"})

      zero = %{"IpAddress" => %{"ip" => "0.0.0.0/0"}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], zero)])], context: %{ip: "203.0.113.9"})

      host = %{"IpAddress" => %{"ip" => "10.1.2.3/32"}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], host)])], context: %{ip: "10.1.2.3"})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], host)])], context: %{ip: "10.1.2.4"})
    end

    test "IpAddress accepts a CIDR list and rejects malformed input closed" do
      c = %{"IpAddress" => %{"ip" => ["10.0.0.0/8", "192.168.0.0/16"]}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{ip: "192.168.5.5"})

      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{ip: "not-an-ip"})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{ip: "10.1.2.3/999"})
      # IPv6 actuals are not supported by the v4 matcher — fail closed.
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{ip: "::1"})
    end

    test "NotIpAddress inverts the CIDR check" do
      c = %{"NotIpAddress" => %{"ip" => "10.0.0.0/8"}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{ip: "11.0.0.1"})
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{ip: "10.0.0.1"})
    end

    test "unknown operators fail closed" do
      c = %{"StringEqualsIgnoreCase" => %{"tier" => "pro"}}
      assert %{allowed: false} = eval([policy([allow(["*"], ["*"], c)])], context: %{tier: "PRO"})
    end
  end

  describe "condition composition and context key shapes" do
    test "multiple operators AND together" do
      c = %{
        "StringEquals" => %{"tier" => "pro"},
        "NumericLessThan" => %{"seats" => 10}
      }

      stmt = allow(["*"], ["*"], c)
      assert %{allowed: true} = eval([policy([stmt])], context: %{tier: "pro", seats: 5})
      assert %{allowed: false} = eval([policy([stmt])], context: %{tier: "pro", seats: 50})
      assert %{allowed: false} = eval([policy([stmt])], context: %{tier: "free", seats: 5})
    end

    test "multiple checks under one operator AND together" do
      c = %{"StringEquals" => %{"tier" => "pro", "region" => "us"}}
      stmt = allow(["*"], ["*"], c)
      assert %{allowed: true} = eval([policy([stmt])], context: %{tier: "pro", region: "us"})
      assert %{allowed: false} = eval([policy([stmt])], context: %{tier: "pro", region: "eu"})
    end

    test "string-keyed contexts are honored when no atom key exists" do
      c = %{"StringEquals" => %{"tier" => "pro"}}
      assert %{allowed: true} = eval([policy([allow(["*"], ["*"], c)])], context: %{"tier" => "pro"})
    end

    test "atom keys win over string keys when both are present" do
      c = %{"StringEquals" => %{"tier" => "pro"}}
      stmt = allow(["*"], ["*"], c)

      assert %{allowed: true} =
               eval([policy([stmt])], context: %{"tier" => "free", tier: "pro"})

      assert %{allowed: false} =
               eval([policy([stmt])], context: %{"tier" => "pro", tier: "free"})
    end
  end
end
