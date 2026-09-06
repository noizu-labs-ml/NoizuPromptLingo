defmodule NoizuPromptLinguaWeb.AssetControllerTest do
  @moduledoc """
  Asset generate endpoint — ticket 2989d130. Generation with no configured provider
  returns a clean 503 ("not available yet"), NOT a 500; the placeholder path
  (llm_generate:false) still returns 201. Mirrors the chat controller test pattern.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Assets

  # Hermetic provider stubs: the 503/201 generate branches depend on the configured
  # MediaToolRunner, and the default CLI shell-out succeeds on any workstation that
  # has `generate-media-prompt` on PATH (env-dependent, so the 503 test flapped).
  # Tests swap in a stub via the documented `:media_tool_runner` config instead.
  defmodule NoProviderStub do
    @behaviour NoizuPromptLingua.Domains.Assets.MediaToolRunner

    @impl true
    def run(_prompt_path, _tmp_dir, _opts), do: {:error, :no_provider_stub}
  end

  defmodule HappyStub do
    @behaviour NoizuPromptLingua.Domains.Assets.MediaToolRunner

    @impl true
    def run(_prompt_path, tmp_dir, _opts) do
      path = Path.join(tmp_dir, "generated.png")
      File.write!(path, <<0x89, "PNG-stub">>)
      {:ok, %{output_path: path, mime: "image/png"}}
    end
  end

  defp with_runner(mod) do
    prev = Application.get_env(:noizu_prompt_lingua, :media_tool_runner)
    Application.put_env(:noizu_prompt_lingua, :media_tool_runner, mod)

    on_exit(fn ->
      if prev,
        do: Application.put_env(:noizu_prompt_lingua, :media_tool_runner, prev),
        else: Application.delete_env(:noizu_prompt_lingua, :media_tool_runner)
    end)
  end

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    slug = "asset-org-#{System.unique_integer([:positive])}"

    created =
      post(auth_conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Asset Org"}})

    org_id = json_response(created, 201)["organization"]["id"]

    # Seed the TRP stub org so Projects.get_project lookups resolve
    # (provision_org warns+skips in tests).
    NoizuPromptLingua.TRP.TestStub.seed_org(org_id, slug, "Asset Org")
    NoizuPromptLingua.TRP.Cache.clear()

    {:ok, entry} =
      Assets.create(%{
        organization_id: org_id,
        slug: "asset-#{System.unique_integer([:positive])}",
        title: "Test Asset",
        asset_type: "document",
        prompt_yaml: "name: example"
      })

    base = "/api/v1/organizations/#{org_id}/assets/#{entry.id}/generate"
    {:ok, conn: auth_conn, org_id: org_id, entry_id: entry.id, base: base}
  end

  test "generate with no provider available -> 503, not 500", %{conn: conn, base: base} do
    with_runner(NoProviderStub)

    conn = post(conn, base, %{provider: "openai"})
    assert conn.status == 503
    assert json_response(conn, 503)["error"] =~ "not available"
  end

  test "generate with a resolved provider -> 201 binary output", %{conn: conn, base: base} do
    with_runner(HappyStub)

    assert json_response(post(conn, base, %{provider: "openai"}), 201)["output"]
  end

  test "generate with llm_generate:false -> 201 placeholder output", %{conn: conn, base: base} do
    assert json_response(post(conn, base, %{llm_generate: false}), 201)["output"]
  end

  test "generate with explicit content -> 201", %{conn: conn, base: base} do
    assert json_response(post(conn, base, %{content: "rendered"}), 201)["output"]
  end

  test "generate for an unknown asset -> 404", %{conn: conn, org_id: org_id} do
    bogus = "/api/v1/organizations/#{org_id}/assets/#{Ecto.UUID.generate()}/generate"
    assert json_response(post(conn, bogus, %{llm_generate: false}), 404)
  end

  # ─────────────────────────────────────────────────────────────────────────
  # cov-w2d: full controller surface (index/create/show/update/delete,
  # outputs/history/accept/reject/set_active, auth matrix). generate/ was
  # already covered above; the LLM/media boundary stays stubbed the same way.
  # ─────────────────────────────────────────────────────────────────────────

  defp assets_url(org_id), do: "/api/v1/organizations/#{org_id}/assets"

  defp create_asset(conn, org_id, attrs \\ %{}) do
    payload =
      Map.merge(
        %{
          "slug" => "asset-#{System.unique_integer([:positive])}",
          "title" => "Asset",
          "asset_type" => "document",
          "prompt_yaml" => "name: example\ntext: hello"
        },
        attrs
      )

    resp = post(conn, assets_url(org_id), %{"asset" => payload})
    {resp.status, resp}
  end

  defp placeholder_output(conn, org_id, entry_id) do
    resp =
      post(conn, "/api/v1/organizations/#{org_id}/assets/#{entry_id}/generate", %{
        llm_generate: false
      })

    json_response(resp, 201)["output"]["id"]
  end

  describe "index" do
    test "empty + type/status catalog present", %{conn: conn, org_id: org_id} do
      fresh_org =
        post(conn, "/api/v1/organizations", %{
          organization: %{
            slug: "asset-empty-#{System.unique_integer([:positive])}",
            name: "Empty"
          }
        })
        |> json_response(201)
        |> get_in(["organization", "id"])

      body = json_response(get(conn, assets_url(fresh_org)), 200)
      assert body["assets"] == []
      assert is_list(body["asset_types"]) and body["asset_types"] != []
      assert is_list(body["statuses"]) and body["statuses"] != []
    end

    test "filters: asset_type, status, tag, project_id", %{conn: conn, org_id: org_id} do
      {201, _} =
        create_asset(conn, org_id, %{
          "asset_type" => "image",
          "status" => "published",
          "tags" => ["hero"],
          "title" => "Filtered"
        })

      {201, _} = create_asset(conn, org_id, %{"asset_type" => "document", "status" => "draft"})

      # 3 = the two created here + the setup fixture entry
      assert length(json_response(get(conn, assets_url(org_id)), 200)["assets"]) == 3

      assert [%{"title" => "Filtered"}] =
               json_response(
                 get(conn, assets_url(org_id) <> "?asset_type=image&status=published&tag=hero"),
                 200
               )[
                 "assets"
               ]

      assert [] =
               json_response(get(conn, assets_url(org_id) <> "?asset_type=video"), 200)["assets"]

      assert [] =
               json_response(
                 get(conn, assets_url(org_id) <> "?project_id=#{Ecto.UUID.generate()}"),
                 200
               )["assets"]
    end
  end

  describe "create" do
    test "201 echoes fields; project scoping", %{conn: conn, org_id: org_id} do
      project =
        post(conn, "/api/v1/organizations/#{org_id}/projects", %{
          "project" => %{"name" => "P", "slug" => "ap-#{System.unique_integer([:positive])}"}
        })
        |> json_response(201)
        |> get_in(["project", "id"])

      {201, resp} =
        create_asset(conn, org_id, %{
          "project_id" => project,
          "quality" => "high",
          "tags" => ["a", "b"],
          "product_targets" => ["web"]
        })

      asset = json_response(resp, 201)["asset"]
      assert asset["organization_id"] == org_id
      assert asset["project_id"] == project
      assert asset["quality"] == "high"
      assert asset["tags"] == ["a", "b"]
      assert asset["status"] == "draft"
    end

    test "422 when required fields missing", %{conn: conn, org_id: org_id} do
      resp = post(conn, assets_url(org_id), %{"asset" => %{"title" => "No yaml"}})
      assert %{"errors" => errors} = json_response(resp, 422)
      assert errors["prompt_yaml"] && errors["slug"]
    end

    test "422 project from another org", %{conn: conn, org_id: org_id} do
      other_org =
        post(conn, "/api/v1/organizations", %{
          organization: %{
            slug: "asset-other-#{System.unique_integer([:positive])}",
            name: "Other"
          }
        })
        |> json_response(201)
        |> get_in(["organization", "id"])

      foreign_project =
        post(conn, "/api/v1/organizations/#{other_org}/projects", %{
          "project" => %{"name" => "F", "slug" => "afp-#{System.unique_integer([:positive])}"}
        })
        |> json_response(201)
        |> get_in(["project", "id"])

      {422, resp} = create_asset(conn, org_id, %{"project_id" => foreign_project})

      assert %{"error" => "Project does not belong to this organization"} =
               json_response(resp, 422)
    end

    @doc "PIN: prompt_yaml is NOT YAML-validated at this boundary — anything stringly goes in."
    test "invalid YAML accepted verbatim (validation lives in ContentGenerator)", %{
      conn: conn,
      org_id: org_id
    } do
      {201, resp} = create_asset(conn, org_id, %{"prompt_yaml" => ": : broken: [oops"})
      asset = json_response(resp, 201)["asset"]
      assert asset["prompt_yaml"] == ": : broken: [oops"
    end
  end

  describe "show / update / delete" do
    test "show 200 with outputs; 404 unknown; 404 cross-org", %{
      conn: conn,
      org_id: org_id,
      entry_id: entry_id
    } do
      placeholder_output(conn, org_id, entry_id)

      body = json_response(get(conn, "#{assets_url(org_id)}/#{entry_id}"), 200)
      assert body["asset"]["id"] == entry_id
      assert length(body["outputs"]) == 1

      assert %{"error" => "Asset not found"} =
               json_response(get(conn, "#{assets_url(org_id)}/#{Ecto.UUID.generate()}"), 404)

      other_org =
        post(conn, "/api/v1/organizations", %{
          organization: %{slug: "asset-x-#{System.unique_integer([:positive])}", name: "X"}
        })
        |> json_response(201)
        |> get_in(["organization", "id"])

      {:ok, foreign} =
        Assets.create(%{
          organization_id: other_org,
          slug: "foreign-#{System.unique_integer([:positive])}",
          title: "F",
          asset_type: "document",
          prompt_yaml: "x: y"
        })

      assert %{"error" => "Asset not found"} =
               json_response(get(conn, "#{assets_url(org_id)}/#{foreign.id}"), 404)
    end

    test "update 200; 422; 404", %{conn: conn, org_id: org_id, entry_id: entry_id} do
      assert %{"asset" => %{"title" => "Renamed", "status" => "review", "quality" => "low"}} =
               json_response(
                 put(conn, "#{assets_url(org_id)}/#{entry_id}", %{
                   "asset" => %{"title" => "Renamed", "status" => "review", "quality" => "low"}
                 }),
                 200
               )

      assert %{"errors" => errors} =
               json_response(
                 put(conn, "#{assets_url(org_id)}/#{entry_id}", %{"asset" => %{"title" => ""}}),
                 422
               )

      assert errors["title"]

      assert %{"error" => "Asset not found"} =
               json_response(
                 put(conn, "#{assets_url(org_id)}/#{Ecto.UUID.generate()}", %{
                   "asset" => %{"title" => "x"}
                 }),
                 404
               )
    end

    test "delete 200 then 404", %{conn: conn, org_id: org_id} do
      {201, resp} = create_asset(conn, org_id)
      id = json_response(resp, 201)["asset"]["id"]

      assert %{"message" => "Asset deleted"} =
               json_response(delete(conn, "#{assets_url(org_id)}/#{id}"), 200)

      assert %{"error" => "Asset not found"} =
               json_response(delete(conn, "#{assets_url(org_id)}/#{id}"), 404)
    end
  end

  describe "outputs / history / accept / reject / set_active" do
    test "outputs listing", %{conn: conn, org_id: org_id, entry_id: entry_id} do
      oid = placeholder_output(conn, org_id, entry_id)

      assert [%{"id" => ^oid}] =
               json_response(get(conn, "#{assets_url(org_id)}/#{entry_id}/outputs"), 200)[
                 "outputs"
               ]

      assert %{"error" => "Asset not found"} =
               json_response(
                 get(conn, "#{assets_url(org_id)}/#{Ecto.UUID.generate()}/outputs"),
                 404
               )
    end

    test "history records create + generated", %{conn: conn, org_id: org_id, entry_id: entry_id} do
      placeholder_output(conn, org_id, entry_id)

      actions =
        json_response(get(conn, "#{assets_url(org_id)}/#{entry_id}/history"), 200)["history"]
        |> Enum.map(& &1["action"])

      assert "generated" in actions

      assert %{"error" => "Asset not found"} =
               json_response(
                 get(conn, "#{assets_url(org_id)}/#{Ecto.UUID.generate()}/history"),
                 404
               )
    end

    test "accept then set_active; unknown output 404", %{
      conn: conn,
      org_id: org_id,
      entry_id: entry_id
    } do
      oid = placeholder_output(conn, org_id, entry_id)
      out_base = "#{assets_url(org_id)}/#{entry_id}/outputs/#{oid}"

      assert %{"output" => %{"id" => ^oid}} =
               json_response(post(conn, out_base <> "/accept"), 200)

      assert %{"asset" => %{"active_output_id" => ^oid}} =
               json_response(
                 post(conn, "#{assets_url(org_id)}/#{entry_id}/active", %{"output_id" => oid}),
                 200
               )

      assert %{"error" => "Asset not found"} =
               json_response(
                 post(
                   conn,
                   "#{assets_url(org_id)}/#{entry_id}/outputs/#{Ecto.UUID.generate()}/accept"
                 ),
                 404
               )

      # BUG PIN (cov-w2d): set_active does NOT verify the output belongs to this
      # entry — any UUID is accepted and stored as active_output_id.
      assert %{"asset" => %{"active_output_id" => bogus}} =
               json_response(
                 post(conn, "#{assets_url(org_id)}/#{entry_id}/active", %{
                   "output_id" => Ecto.UUID.generate()
                 }),
                 200
               )

      assert bogus
    end

    test "reject", %{conn: conn, org_id: org_id, entry_id: entry_id} do
      oid = placeholder_output(conn, org_id, entry_id)

      assert %{"output" => %{"id" => ^oid}} =
               json_response(
                 post(conn, "#{assets_url(org_id)}/#{entry_id}/outputs/#{oid}/reject"),
                 200
               )
    end

    @doc "PIN: llm_generate:false materializes prompt_yaml verbatim (no YAML parse at this layer)."
    test "placeholder output carries raw prompt_yaml", %{conn: conn, org_id: org_id} do
      {201, resp} = create_asset(conn, org_id, %{"prompt_yaml" => "KEEP: raw-yaml-123"})
      id = json_response(resp, 201)["asset"]["id"]

      # The generated artifact's content is the raw prompt string.
      body = json_response(get(conn, "#{assets_url(org_id)}/#{id}"), 200)
      assert body["asset"]["prompt_yaml"] == "KEEP: raw-yaml-123"
    end
  end

  describe "auth matrix" do
    test "unauthenticated -> 401", %{org_id: org_id} do
      assert get(build_conn(), assets_url(org_id)).status == 401
    end

    test "non-member -> 403", %{org_id: org_id} do
      %{access_token: other_token} = setup_user_and_token()

      assert %{"error" => "Not a member of this organization"} =
               json_response(
                 get(authenticated_conn(build_conn(), other_token), assets_url(org_id)),
                 403
               )
    end

    test "viewer reads but cannot write", %{conn: conn, org_id: org_id} do
      %{access_token: vtok, user: vuser} = setup_user_and_token()

      assert {:ok, _} =
               NoizuPromptLingua.Authz.ScopedMemberships.add_member(
                 "organization",
                 org_id,
                 vuser.id,
                 "viewer"
               )

      vconn = authenticated_conn(build_conn(), vtok)
      assert %{"assets" => _} = json_response(get(vconn, assets_url(org_id)), 200)

      assert %{"error" => "Insufficient permissions"} =
               json_response(
                 post(vconn, assets_url(org_id), %{"asset" => %{"title" => "x"}}),
                 403
               )
    end
  end
end
