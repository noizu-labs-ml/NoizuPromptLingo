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
      if prev, do: Application.put_env(:noizu_prompt_lingua, :media_tool_runner, prev),
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
end
