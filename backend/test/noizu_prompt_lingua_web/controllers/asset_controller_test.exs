defmodule NoizuPromptLinguaWeb.AssetControllerTest do
  @moduledoc """
  Asset generate endpoint — ticket 2989d130. Generation with no configured provider
  returns a clean 503 ("not available yet"), NOT a 500; the placeholder path
  (llm_generate:false) still returns 201. Mirrors the chat controller test pattern.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Assets

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    slug = "asset-org-#{System.unique_integer([:positive])}"

    created =
      post(auth_conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Asset Org"}})

    org_id = json_response(created, 201)["organization"]["id"]

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

  test "generate with no provider configured -> 503, not 500", %{conn: conn, base: base} do
    prev = System.get_env("OPENAI_API_KEY")
    System.put_env("OPENAI_API_KEY", "")

    on_exit(fn ->
      if prev,
        do: System.put_env("OPENAI_API_KEY", prev),
        else: System.delete_env("OPENAI_API_KEY")
    end)

    conn = post(conn, base, %{provider: "openai"})
    assert conn.status == 503
    assert json_response(conn, 503)["error"] =~ "not available"
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
end
