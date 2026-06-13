defmodule Codefresh.EnterpriseTest do
  use Codefresh.DataCase, async: true

  alias Codefresh.Enterprise
  import Codefresh.Fixtures

  # Helper: insert a raw audit event row directly via Repo
  # UUID strings must be decoded to 16-byte binaries for insert_all on raw tables.
  defp uuid_bin(str), do: Ecto.UUID.dump!(str)

  defp insert_audit_event(org_id, attrs) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    defaults = %{
      id: uuid_bin(Ecto.UUID.generate()),
      organization_id: uuid_bin(org_id),
      actor_user_id: nil,
      action: "test.action",
      subject_type: "script",
      subject_id: nil,
      subject_slug: "slug-#{System.unique_integer([:positive])}",
      diff: nil,
      metadata: %{},
      timestamp: now,
      inserted_at: now
    }

    merged =
      defaults
      |> Map.merge(attrs)
      |> then(fn m ->
        # If caller passed a string org_id override, decode it too
        case Map.get(m, :organization_id) do
          <<_::128>> = bin when byte_size(bin) == 16 -> m
          str when is_binary(str) -> Map.put(m, :organization_id, uuid_bin(str))
          _ -> m
        end
      end)

    # Serialize audit inserts across parallel test suites — the audit_events
    # TimescaleDB hypertable deadlocks on chunk-catalog locks when two
    # sandbox transactions insert concurrently. Must match the key used by
    # `Codefresh.Review`'s audit writer.
    Codefresh.Repo.query!("SELECT pg_advisory_xact_lock($1)", [0xA7D17EFE])
    Codefresh.Repo.insert_all("audit_events", [merged])
  end

  # ---------------------------------------------------------------------------
  # configure_sso / get_sso_config (US-142)
  # ---------------------------------------------------------------------------

  describe "configure_sso/2" do
    test "inserts a new SAML config for an org" do
      %{organization: org} = org_with_owner()

      attrs = %{
        "provider" => "saml",
        "enabled" => true,
        "metadata" => %{
          "idp_metadata_url" => "https://idp.example.com/metadata",
          "entity_id" => "https://codefre.sh"
        }
      }

      assert {:ok, config} = Enterprise.configure_sso(org.id, attrs)
      assert config.provider == "saml"
      assert config.enabled == true
      assert config.organization_id == org.id
    end

    test "updates existing config on second call (upsert)" do
      %{organization: org} = org_with_owner()

      attrs = %{
        "provider" => "saml",
        "enabled" => false,
        "metadata" => %{
          "idp_metadata_url" => "https://idp.example.com/metadata",
          "entity_id" => "https://codefre.sh"
        }
      }

      {:ok, _first} = Enterprise.configure_sso(org.id, attrs)

      {:ok, second} =
        Enterprise.configure_sso(org.id, Map.put(attrs, "enabled", true))

      assert second.enabled == true
    end

    test "returns error changeset when SAML metadata missing required fields" do
      %{organization: org} = org_with_owner()

      attrs = %{
        "provider" => "saml",
        "metadata" => %{"idp_metadata_url" => "https://idp.example.com/metadata"}
        # entity_id intentionally missing
      }

      assert {:error, cs} = Enterprise.configure_sso(org.id, attrs)
      assert cs.errors[:metadata] != nil
    end

    test "rejects unknown provider" do
      %{organization: org} = org_with_owner()

      attrs = %{"provider" => "kerberos", "metadata" => %{}}
      assert {:error, cs} = Enterprise.configure_sso(org.id, attrs)
      assert cs.errors[:provider] != nil
    end
  end

  describe "get_sso_config/1" do
    test "returns nil when no config exists" do
      %{organization: org} = org_with_owner()
      assert is_nil(Enterprise.get_sso_config(org.id))
    end

    test "returns config after configure_sso" do
      %{organization: org} = org_with_owner()

      attrs = %{
        "provider" => "saml",
        "metadata" => %{
          "idp_metadata_url" => "https://idp.example.com/metadata",
          "entity_id" => "https://codefre.sh"
        }
      }

      {:ok, _} = Enterprise.configure_sso(org.id, attrs)
      assert %{provider: "saml"} = Enterprise.get_sso_config(org.id)
    end

    test "cross-org isolation: org A config not visible to org B" do
      %{organization: org_a} = org_with_owner()
      %{organization: org_b} = org_with_owner()

      attrs = %{
        "provider" => "saml",
        "metadata" => %{
          "idp_metadata_url" => "https://idp.example.com/metadata",
          "entity_id" => "https://codefre.sh"
        }
      }

      {:ok, _} = Enterprise.configure_sso(org_a.id, attrs)
      assert is_nil(Enterprise.get_sso_config(org_b.id))
    end
  end

  # ---------------------------------------------------------------------------
  # export_audit_log_csv (US-143)
  # ---------------------------------------------------------------------------

  # Extract accumulated chunk body from Plug.Test adapter state.
  defp chunked_body(%Plug.Conn{adapter: {_, state}}), do: Map.fetch!(state, :chunks)

  describe "export_audit_log_csv/3" do
    test "streams CSV with correct headers and one row per audit event" do
      %{organization: org} = org_with_owner()
      insert_audit_event(org.id, %{action: "prompt.create", subject_type: "prompt"})
      insert_audit_event(org.id, %{action: "script.publish", subject_type: "script"})

      conn =
        Plug.Test.conn(:get, "/")
        |> Plug.Conn.send_chunked(200)

      result_conn = Enterprise.export_audit_log_csv(conn, org.id)
      body = chunked_body(result_conn)

      lines = String.split(body, "\n", trim: true)
      # First line is the CSV header
      assert hd(lines) =~ "id,actor_user_id,action"
      # Header + 2 data rows
      assert length(lines) >= 3
    end

    test "CSV export respects cross-org isolation" do
      %{organization: org_a} = org_with_owner()
      %{organization: org_b} = org_with_owner()
      insert_audit_event(org_a.id, %{action: "prompt.create", subject_type: "prompt"})

      conn =
        Plug.Test.conn(:get, "/")
        |> Plug.Conn.send_chunked(200)

      result_conn = Enterprise.export_audit_log_csv(conn, org_b.id)
      body = chunked_body(result_conn)

      lines = String.split(body, "\n", trim: true)
      # Only header line, no data rows for org_b
      assert length(lines) == 1
    end
  end
end
