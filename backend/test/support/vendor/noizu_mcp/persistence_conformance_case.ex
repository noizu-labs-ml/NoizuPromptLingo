defmodule Noizu.MCP.Persistence.ConformanceCase do
  @moduledoc """
  The shared `Noizu.MCP.Persistence` test battery (PRD-4 AC-4.1). Run against
  every provider — the built-ins that ship, and any a host writes:

      defmodule MyApp.MCPPersistenceTest do
        use ExUnit.Case, async: false

        setup do
          %{adapter: MyApp.MCPPersistence, store_opts: [repo: MyApp.Repo]}
        end

        use Noizu.MCP.Persistence.ConformanceCase
      end

  The context must carry `:adapter` and `:store_opts`, and the store must
  start EMPTY for each test (the host module's `setup` clears it).

  This battery is the single source of provider truth (AP-8): a provider
  claims support by passing it, not by implementing the callbacks. Storage
  mechanics are free to differ; observable semantics are not — every test
  here asserts behavior both built-in providers must share, which is what
  keeps the "multi-layer persistence combinatorics" anti-pattern dead.
  """

  defmacro __using__(_opts) do
    quote do
      alias Noizu.MCP.Persistence
      alias Noizu.MCP.Permission.Grant
      alias Noizu.MCP.Permission.Negotiation
      alias Noizu.MCP.Toolset.Custom
      alias Noizu.MCP.Toolset.Override

      # ── helpers ─────────────────────────────────────────────────────────

      defp put(ctx, store_key, id, record),
        do: ctx.adapter.put(store_key, id, record, ctx.store_opts)

      defp get(ctx, store_key, id), do: ctx.adapter.get(store_key, id, ctx.store_opts)

      defp list(ctx, store_key, filter \\ nil),
        do: ctx.adapter.list(store_key, filter, ctx.store_opts)

      defp delete(ctx, store_key, id), do: ctx.adapter.delete(store_key, id, ctx.store_opts)

      defp version(ctx, store_key), do: ctx.adapter.version(store_key, ctx.store_opts)

      defp grant(overrides \\ []) do
        struct(
          %Grant{
            id: "grant-" <> Base.encode16(:crypto.strong_rand_bytes(4), case: :lower),
            toolset_slug: "team-tools",
            authenticator: "authentik",
            subject: "user-1",
            effect: :allow,
            scopes: ["pm:read"],
            tool_overrides: %{
              "echo" => [%Override{op: :set_name, value: "echo_pro"}]
            },
            metadata: %{"origin" => "conformance"}
          },
          overrides
        )
      end

      defp negotiation(overrides \\ []) do
        struct(
          %Negotiation{
            id: "neg-" <> Base.encode16(:crypto.strong_rand_bytes(4), case: :lower),
            toolset_slug: "team-tools",
            authenticator: "authentik",
            tool: "deploy",
            required_scopes: ["pm:write"],
            granted: false,
            metadata_overrides: %{"elevation_uri" => "https://idp.example/consent"},
            metadata: %{"origin" => "conformance"}
          },
          overrides
        )
      end

      # ── put / get / round-trip ──────────────────────────────────────────

      describe "conformance: put/get" do
        test "round-trips a grant struct", ctx do
          record = grant()
          assert :ok = put(ctx, "toolset_grants", record.id, record)

          assert {:ok, %Grant{} = loaded} = get(ctx, "toolset_grants", record.id)
          assert loaded.id == record.id
          assert loaded.toolset_slug == "team-tools"
          assert loaded.authenticator == "authentik"
          assert loaded.subject == "user-1"
          assert loaded.effect == :allow
          assert loaded.scopes == ["pm:read"]
          assert loaded.metadata == %{"origin" => "conformance"}
          # Provider-stamped on put (§4.4) and survives the round trip.
          refute is_nil(loaded.inserted_at)
          assert [%Override{op: :set_name, value: "echo_pro"}] = loaded.tool_overrides["echo"]
        end

        test "round-trips a negotiation struct", ctx do
          record = negotiation(granted: true, required_scopes: ["pm:write", "deploy:*"])
          assert :ok = put(ctx, "toolset_negotiations", record.id, record)

          assert {:ok, %Negotiation{} = loaded} = get(ctx, "toolset_negotiations", record.id)
          assert loaded.tool == "deploy"
          assert loaded.required_scopes == ["pm:write", "deploy:*"]
          assert loaded.granted == true
          assert loaded.metadata_overrides == %{"elevation_uri" => "https://idp.example/consent"}
        end

        test "round-trips a toolset record to %Custom{} with the atom base restored", ctx do
          record =
            struct(
              %Custom{
                slug: "team-tools",
                base: Noizu.MCP.Fixtures.Server,
                title: "Team Tools",
                exclude: ["secret_tool"],
                tools: %{
                  "echo" => [%Override{op: :set_description, value: "renamed description"}]
                }
              },
              []
            )

          assert :ok = put(ctx, "toolsets", record.slug, record)

          assert {:ok, %Custom{} = loaded} = get(ctx, "toolsets", "team-tools")
          assert loaded.base == Noizu.MCP.Fixtures.Server
          assert loaded.title == "Team Tools"
          assert loaded.exclude == ["secret_tool"]

          assert [%Override{op: :set_description, value: "renamed description"}] =
                   loaded.tools["echo"]
        end

        test "an unknown id is :error, not an error tuple", ctx do
          assert :error = get(ctx, "toolset_grants", "nope")
        end

        test "put upserts by id", ctx do
          record = grant()
          :ok = put(ctx, "toolset_grants", record.id, record)

          updated = %{record | scopes: ["pm:read", "pm:write"]}
          :ok = put(ctx, "toolset_grants", record.id, updated)

          assert {:ok, loaded} = get(ctx, "toolset_grants", record.id)
          assert loaded.scopes == ["pm:read", "pm:write"]
        end

        test "integer subjects normalize to the string form (store columns are text)", ctx do
          record = grant(subject: 42)
          assert :ok = put(ctx, "toolset_grants", record.id, record)

          assert {:ok, loaded} = get(ctx, "toolset_grants", record.id)
          assert loaded.subject == "42"

          # ...and filters compare normalized both ways.
          assert {:ok, [_]} = list(ctx, "toolset_grants", %{subject: 42})
          assert {:ok, [_]} = list(ctx, "toolset_grants", %{subject: "42"})
        end

        test "atom authenticators normalize for filters", ctx do
          record = grant(authenticator: :sso)
          :ok = put(ctx, "toolset_grants", record.id, record)

          assert {:ok, [_]} = list(ctx, "toolset_grants", %{authenticator: :sso})
          assert {:ok, [_]} = list(ctx, "toolset_grants", %{authenticator: "sso"})
        end
      end

      # ── delete ──────────────────────────────────────────────────────────

      describe "conformance: delete" do
        test "removes the record and is idempotent", ctx do
          record = grant()
          :ok = put(ctx, "toolset_grants", record.id, record)

          assert :ok = delete(ctx, "toolset_grants", record.id)
          assert :error = get(ctx, "toolset_grants", record.id)
          assert :ok = delete(ctx, "toolset_grants", record.id)
        end
      end

      # ── version ─────────────────────────────────────────────────────────

      describe "conformance: version" do
        test "bumps on put and on delete, monotonic per store", ctx do
          {:ok, v0} = version(ctx, "toolset_grants")
          record = grant()
          :ok = put(ctx, "toolset_grants", record.id, record)
          {:ok, v1} = version(ctx, "toolset_grants")

          :ok = delete(ctx, "toolset_grants", record.id)
          {:ok, v2} = version(ctx, "toolset_grants")

          assert String.to_integer(v1) > String.to_integer(v0)
          assert String.to_integer(v2) > String.to_integer(v1)
        end

        test "version counters are independent per store", ctx do
          {:ok, before} = version(ctx, "toolsets")
          record = grant()
          :ok = put(ctx, "toolset_grants", record.id, record)

          assert {:ok, unchanged} = version(ctx, "toolsets")
          assert String.to_integer(unchanged) == String.to_integer(before)
        end
      end

      # ── expiry (the store invariant — every provider, no caller logic) ──

      describe "conformance: expiry" do
        test "an expired record is excluded from get AND list", ctx do
          past = DateTime.add(DateTime.utc_now(), -60, :second)
          expired = grant(expires_at: past)
          live = grant()
          :ok = put(ctx, "toolset_grants", expired.id, expired)
          :ok = put(ctx, "toolset_grants", live.id, live)

          assert :error = get(ctx, "toolset_grants", expired.id)
          assert {:ok, listed} = list(ctx, "toolset_grants")
          assert [%{id: id}] = listed
          assert id == live.id
        end

        test "list honors :at as the expiry anchor", ctx do
          soon = DateTime.add(DateTime.utc_now(), 3_600, :second)
          record = grant(expires_at: soon)
          :ok = put(ctx, "toolset_grants", record.id, record)

          assert {:ok, [_]} = list(ctx, "toolset_grants", %{at: DateTime.utc_now()})

          after_expiry = DateTime.add(soon, 1, :second)
          assert {:ok, []} = list(ctx, "toolset_grants", %{at: after_expiry})
        end
      end

      # ── filters (exact-match terms per store) ───────────────────────────

      describe "conformance: filters" do
        test "exact-match combos narrow the set", ctx do
          a = grant(toolset_slug: "alpha", subject: "user-1")
          b = grant(toolset_slug: "alpha", subject: "user-2")
          c = grant(toolset_slug: "beta", subject: "user-1")

          Enum.each([a, b, c], fn record ->
            :ok = put(ctx, "toolset_grants", record.id, record)
          end)

          assert {:ok, found} = list(ctx, "toolset_grants", %{toolset_slug: "alpha"})
          assert MapSet.new(found, & &1.id) == MapSet.new([a.id, b.id])

          assert {:ok, found} =
                   list(ctx, "toolset_grants", %{toolset_slug: "alpha", subject: "user-1"})

          assert [%{id: id}] = found
          assert id == a.id

          assert {:ok, found} =
                   list(ctx, "toolset_grants", %{
                     toolset_slug: "beta",
                     authenticator: "authentik",
                     subject: "user-1"
                   })

          beta_id = c.id
          assert [%{id: ^beta_id}] = found

          assert {:ok, []} = list(ctx, "toolset_grants", %{toolset_slug: "gamma"})
        end

        test "negotiation filters key on tool", ctx do
          deploy = negotiation(tool: "deploy")
          reboot = negotiation(tool: "reboot")

          Enum.each([deploy, reboot], fn record ->
            :ok = put(ctx, "toolset_negotiations", record.id, record)
          end)

          assert {:ok, found} =
                   list(ctx, "toolset_negotiations", %{
                     toolset_slug: "team-tools",
                     authenticator: "authentik",
                     tool: "reboot"
                   })

          reboot_id = reboot.id
          assert [%{id: ^reboot_id}] = found
        end

        test "a filter key the record kind lacks excludes every record", ctx do
          record = negotiation()
          :ok = put(ctx, "toolset_negotiations", record.id, record)

          assert {:ok, []} = list(ctx, "toolset_negotiations", %{subject: "user-1"})
        end
      end

      # ── list order ──────────────────────────────────────────────────────

      describe "conformance: list order" do
        test "inserted_at desc (the negotiation most-recent-wins rule)", ctx do
          now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

          old = grant(inserted_at: DateTime.add(now, -3_600, :second))
          newest = grant(inserted_at: now)
          middle = grant(inserted_at: DateTime.add(now, -60, :second))

          Enum.each([old, newest, middle], fn record ->
            :ok = put(ctx, "toolset_grants", record.id, record)
          end)

          assert {:ok, listed} = list(ctx, "toolset_grants")
          assert Enum.map(listed, & &1.id) == [newest.id, middle.id, old.id]
        end
      end

      # ── validation ──────────────────────────────────────────────────────

      describe "conformance: validation" do
        test "subjects must be JSON scalars", ctx do
          record = grant(subject: %{user: "structured"})
          assert {:error, {:invalid_subject, _}} = put(ctx, "toolset_grants", record.id, record)

          record = grant(subject: [1, 2])
          assert {:error, {:invalid_subject, _}} = put(ctx, "toolset_grants", record.id, record)
        end

        test "effect must be :allow or :deny", ctx do
          record = grant(effect: :maybe)
          assert {:error, {:invalid_effect, _}} = put(ctx, "toolset_grants", record.id, record)
        end

        test "unknown store keys are rejected uniformly", ctx do
          assert {:error, {:unknown_store_key, "nope"}} = put(ctx, "nope", "id", grant())
          assert {:error, {:unknown_store_key, "nope"}} = get(ctx, "nope", "id")
          assert {:error, {:unknown_store_key, "nope"}} = list(ctx, "nope")
          assert {:error, {:unknown_store_key, "nope"}} = delete(ctx, "nope", "id")
          assert {:error, {:unknown_store_key, "nope"}} = version(ctx, "nope")
        end

        test "records of the wrong shape are rejected", ctx do
          assert {:error, {:missing_field, :toolset_slug}} =
                   put(ctx, "toolset_grants", "g", %{id: "g", subject: "user-1", effect: :allow})

          assert {:error, {:invalid_record, "toolset_grants", 42}} =
                   put(ctx, "toolset_grants", "g", 42)
        end
      end
    end
  end
end
