defmodule NoizuPromptLinguaWeb.OAuthConsentTest do
  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.OAuth.{Clients, ConsentManifest, Grants}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User

  @redirect_uri "http://127.0.0.1:9876/callback"
  @resource "https://tobor.locker/mcp"

  setup do
    NoizuPromptLingua.OAuthTestSchema.ensure!()

    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "consent-#{uniq}@example.com",
        user_name: "consent#{uniq}",
        handle: "consent#{uniq}",
        status: :active,
        verified: true,
        flagged: false
      }
      |> Repo.insert!()

    {:ok, reg} =
      Clients.register(%{
        "client_name" => "consent-web-cli-#{uniq}",
        "redirect_uris" => [@redirect_uri],
        "token_endpoint_auth_method" => "none"
      })

    client = Clients.get_active(reg["client_id"])

    verifier = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    challenge = :crypto.hash(:sha256, verifier) |> Base.url_encode64(padding: false)

    conn =
      build_conn()
      |> put_req_header("x-forwarded-for", "10.7.#{rem(uniq, 250)}.#{rem(uniq, 251)}")

    %{
      user: user,
      client: client,
      conn: conn,
      challenge: challenge,
      verifier: verifier,
      uniq: uniq
    }
  end

  defp authorize_params(client, challenge) do
    %{
      "response_type" => "code",
      "client_id" => client.client_id,
      "redirect_uri" => @redirect_uri,
      "code_challenge" => challenge,
      "code_challenge_method" => "S256",
      "state" => "st-123"
    }
  end

  defp signed_in(conn, user), do: Plug.Test.init_test_session(conn, %{"oauth_user_id" => user.id})

  describe "standing consent (legacy grants)" do
    test "existing grant re-authorizes silently — no consent manifest, no toolset change", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge
    } do
      _grant = Grants.approve!(user.id, client.client_id, @resource, "mcp")

      conn =
        conn
        |> signed_in(user)
        |> get("/oauth/authorize", authorize_params(client, challenge))

      assert conn.status == 302
      assert conn.resp_body =~ @redirect_uri
      assert conn.resp_body =~ "code="

      # Silent path: redirect body only, manifest never rendered.
      refute conn.resp_body =~ "allow_group"
      refute conn.resp_body =~ "consent-section"

      # Legacy grant never touches the client's toolset_config.
      assert Clients.get_active(client.client_id).toolset_config == %{}
    end
  end

  describe "fresh consent renders the tool manifest" do
    test "authorize shows sections + per-tool toggles pre-checked", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge
    } do
      conn =
        conn
        |> signed_in(user)
        |> get("/oauth/authorize", authorize_params(client, challenge))

      assert conn.status == 200
      assert conn.resp_body =~ "Requested tool access"
      assert conn.resp_body =~ "allow_group["
      assert conn.resp_body =~ "allow_tool["
      # Toggles render pre-checked to the client's request.
      assert conn.resp_body =~ "checked data-group"
      assert conn.resp_body =~ "value=\"on\" checked"
    end
  end

  describe "consent POST persists narrowing" do
    test "blocked group/tool lands in toolset_config, code still issued", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge
    } do
      sections = ConsentManifest.sections()

      # Allow the chat group with only its first tool; omit every other group
      # checkbox (unchecked = blocked). Required groups excluded by design.
      chat = Enum.find(sections, &(&1.group == "chat"))
      [allowed_tool | blocked_tools] = chat.tools

      form =
        authorize_params(client, challenge)
        |> Map.drop(["response_type", "code_challenge_method"])
        |> Map.merge(%{
          "decision" => "approve",
          "allow_group" => %{"chat" => "on"},
          "allow_tool" => %{"chat" => %{allowed_tool => "on"}}
        })

      conn =
        conn
        |> signed_in(user)
        |> post("/oauth/consent", form)

      assert conn.status == 302
      assert conn.resp_body =~ "code="

      config = Clients.get_active(client.client_id).toolset_config
      groups = config["groups"]

      # Allowed tool absent from the narrowing; blocked tools flagged.
      refute Map.has_key?(groups["chat"]["tools"] || %{}, allowed_tool)

      for blocked <- blocked_tools do
        assert groups["chat"]["tools"][blocked] == %{"disabled" => true}
      end

      # Omitted optional groups are blocked at group level.
      for %{group: gid, required: false} <- sections, gid != "chat" do
        assert groups[gid]["disabled"] == true
        assert groups[gid]["tools"] == %{}
      end

      # Required groups never narrowed.
      for %{group: gid, required: true} <- sections do
        refute Map.has_key?(groups, gid)
      end
    end

    test "deny decision persists nothing", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge
    } do
      form =
        authorize_params(client, challenge)
        |> Map.drop(["response_type", "code_challenge_method"])
        |> Map.merge(%{"decision" => "deny", "allow_group" => %{"chat" => "on"}})

      conn = conn |> signed_in(user) |> post("/oauth/consent", form)

      assert conn.status == 302
      assert Clients.get_active(client.client_id).toolset_config == %{}
    end
  end
end
