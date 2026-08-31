defmodule NoizuPromptLinguaWeb.ComponentControllerTest do
  @moduledoc """
  W7 component registry: keyed list + bundle fetch.

  Semantics under test (per-key `toolset_config`, group id `components`):

    * default (no config)          — listed, fetch 200
    * group/tool `hidden: true`    — omitted from listing, fetch 404
    * group/tool `disabled: true`  — still listed, fetch 403
    * no/invalid key               — 401
  """

  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.MCPApiKeys

  @component "npl-queue-board"
  @bundle_path "priv/components/npl-queue-board/npl-queue-board.js"

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()
    {:ok, conn: authenticated_conn(conn, token), user: user}
  end

  defp key_for(user, opts \\ []) do
    {:ok, _key, raw_key} = MCPApiKeys.generate_api_key(user.id, "embed", opts)
    raw_key
  end

  defp key_conn(conn, raw_key) do
    put_req_header(conn, "authorization", "Bearer #{raw_key}")
  end

  describe "GET /api/v1/components" do
    test "401 without a key", %{conn: conn} do
      conn = conn |> get("/api/v1/components") |> response(401)
      assert conn =~ "Authentication required"
    end

    test "401 with an invalid key", %{conn: _conn} do
      build_conn()
      |> put_req_header("authorization", "Bearer not-a-real-key")
      |> get("/api/v1/components")
      |> response(401)
    end

    test "lists npl-queue-board with bundle_url for a default key", %{conn: conn, user: user} do
      raw = key_for(user)

      body =
        conn
        |> key_conn(raw)
        |> get("/api/v1/components")
        |> json_response(200)

      component = Enum.find(body["components"], &(&1["name"] == @component))
      assert component
      assert component["version"] == "0.1.0"
      assert component["bundle_url"] == "/api/v1/components/#{@component}/bundle"
    end

    test "accepts a minted MCP JWT as well as the raw key", %{conn: conn, user: user} do
      {:ok, key, raw} = MCPApiKeys.generate_api_key(user.id, "embed")
      user_attrs = %{id: user.id, email: user.email, name: user.user_name}

      {:ok, jwt, _exp} = NoizuPromptLingua.Token.mint(user_attrs, key)

      body =
        conn
        |> key_conn(jwt)
        |> get("/api/v1/components")
        |> json_response(200)

      assert Enum.any?(body["components"], &(&1["name"] == @component))

      # The raw key still works too (independent verification paths).
      conn
      |> key_conn(raw)
      |> get("/api/v1/components")
      |> json_response(200)
    end

    test "also lists the mirrored trp-item-timeline component (W7 v2)", %{conn: conn, user: user} do
      raw = key_for(user)

      body =
        conn
        |> key_conn(raw)
        |> get("/api/v1/components")
        |> json_response(200)

      component = Enum.find(body["components"], &(&1["name"] == "trp-item-timeline"))
      assert component
      assert component["version"] == "0.1.0"
    end

    test "hidden component is omitted from the listing", %{conn: conn, user: user} do
      raw =
        key_for(user,
          toolset_config: %{"groups" => %{"components" => %{"hidden" => true}}}
        )

      body =
        conn
        |> key_conn(raw)
        |> get("/api/v1/components")
        |> json_response(200)

      refute Enum.any?(body["components"], &(&1["name"] == @component))
    end
  end

  describe "GET /api/v1/components/:name/bundle" do
    test "401 without a key", %{conn: _conn} do
      build_conn()
      |> get("/api/v1/components/#{@component}/bundle")
      |> response(401)
    end

    test "serves the bundle with immutable caching", %{conn: conn, user: user} do
      raw = key_for(user)

      conn = conn |> key_conn(raw) |> get("/api/v1/components/#{@component}/bundle")

      assert response(conn, 200) == File.read!(Path.join(Application.app_dir(
               :noizu_prompt_lingua
             ), @bundle_path))

      assert get_resp_header(conn, "content-type") |> List.first() =~ "text/javascript"
      assert get_resp_header(conn, "cache-control") == ["public, max-age=31536000, immutable"]
    end

    test "hidden component fetch 404s (no existence disclosure)", %{conn: conn, user: user} do
      raw =
        key_for(user,
          toolset_config: %{
            "groups" => %{
              "components" => %{"tools" => %{@component => %{"hidden" => true}}}
            }
          }
        )

      conn
      |> key_conn(raw)
      |> get("/api/v1/components/#{@component}/bundle")
      |> response(404)
    end

    test "disabled component fetch 403s but stays listed", %{conn: conn, user: user} do
      raw =
        key_for(user,
          toolset_config: %{
            "groups" => %{
              "components" => %{"tools" => %{@component => %{"disabled" => true}}}
            }
          }
        )

      listing =
        conn
        |> key_conn(raw)
        |> get("/api/v1/components")
        |> json_response(200)

      assert Enum.any?(listing["components"], &(&1["name"] == @component))

      conn
      |> key_conn(raw)
      |> get("/api/v1/components/#{@component}/bundle")
      |> response(403)
    end

    test "unknown component 404s", %{conn: conn, user: user} do
      raw = key_for(user)

      conn
      |> key_conn(raw)
      |> get("/api/v1/components/nope/bundle")
      |> response(404)
    end
  end

  describe "embedded-component data plane (boards/tickets key acceptance)" do
    test "boards + tickets listings answer a raw MCP key without a session", %{
      conn: conn,
      user: user
    } do
      raw = key_for(user)

      slug = "embed-org-#{System.unique_integer([:positive])}"

      org_id =
        json_response(post(conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Embed Org"}}), 201)[
          "organization"
        ]["id"]

      base = "/api/v1/organizations/#{org_id}"

      boards =
        conn
        |> key_conn(raw)
        |> get("#{base}/boards")
        |> json_response(200)

      assert is_list(boards["boards"])

      tickets =
        conn
        |> key_conn(raw)
        |> get("#{base}/tickets")
        |> json_response(200)

      assert is_list(tickets["tickets"])
    end

    test "a key whose owner is not an org member is rejected by the role check", %{
      conn: conn,
      user: user
    } do
      raw = key_for(user)

      slug = "embed-other-#{System.unique_integer([:positive])}"

      org_id =
        json_response(post(conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Other Org"}}), 201)[
          "organization"
        ]["id"]

      uniq = System.unique_integer([:positive])

      stranger =
        %NoizuPromptLingua.Schema.Users.User{
          id: Ecto.UUID.generate(),
          email: "embed-#{uniq}@example.com",
          user_name: "embed#{uniq}",
          handle: "e#{uniq}",
          status: :active
        }
        |> NoizuPromptLingua.Repo.insert!()

      {:ok, _key, stranger_raw} = MCPApiKeys.generate_api_key(stranger.id, "embed")

      conn =
        build_conn()
        |> key_conn(stranger_raw)
        |> get("/api/v1/organizations/#{org_id}/boards")

      assert json_response(conn, 403)
    end
  end
end
