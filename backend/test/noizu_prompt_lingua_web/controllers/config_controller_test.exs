defmodule NoizuPromptLinguaWeb.ConfigControllerTest do
  @moduledoc """
  Client-config surface: the feature-flag document and the three build-artifact
  download endpoints (happy path via the packaged tarball + the not-packaged
  404s with their make-target hints, staged by temporarily moving the real
  archives out of the build's priv/downloads dir).
  """

  use NoizuPromptLinguaWeb.ConnCase

  @archive "noizu-local-mcp.tar.gz"
  @browser "noizu-browser-controller.tar.gz"
  @remote "noizu-remote-access-client.tar.gz"

  # /config/* rides the :rate_limited_auth pipeline (Hammer) — unique IP per test.
  setup %{conn: conn} do
    uniq = System.unique_integer([:positive])

    conn =
      put_req_header(conn, "x-forwarded-for", "10.21.#{rem(uniq, 250)}.#{rem(uniq, 251)}")

    {:ok, conn: conn}
  end

  defp downloads_dir do
    Application.app_dir(:noizu_prompt_lingua, "priv/static/downloads")
  end

  describe "GET /api/v1/config/features" do
    test "returns the feature flag document", %{conn: conn} do
      conn = get(conn, "/api/v1/config/features")

      body = json_response(conn, 200)
      assert Map.has_key?(body, "features")
      assert body["features"] != nil
    end
  end

  describe "artifact downloads" do
    test "serves the packaged local-mcp archive as a download", %{conn: conn} do
      dir = downloads_dir()
      File.mkdir_p!(dir)
      path = Path.join(dir, @archive)
      pre_existing = File.exists?(path)

      unless pre_existing, do: File.write!(path, "fake-tarball-bytes")
      on_exit(fn -> if pre_existing, do: :ok, else: File.rm(path) end)

      conn = get(conn, "/api/v1/config/local-mcp/download")

      assert conn.status == 200
      assert byte_size(conn.resp_body) > 0
      assert get_resp_header(conn, "content-type") |> hd() =~ "gzip"
    end

    test "unpackaged archives return 404 with the make hint", %{conn: conn} do
      dir = downloads_dir()
      File.mkdir_p!(dir)

      # The dev build ships both archives — move them aside for the request.
      for name <- [@browser, @remote] do
        src = Path.join(dir, name)

        if File.exists?(src), do: File.rename!(src, src <> ".w5a-bak")
      end

      on_exit(fn ->
        for name <- [@browser, @remote] do
          bak = Path.join(dir, name <> ".w5a-bak")
          if File.exists?(bak), do: File.rename!(bak, Path.join(dir, name))
        end
      end)

      assert %{"error" => "browser-controller archive not packaged", "hint" => hint1} =
               json_response(get(conn, "/api/v1/config/browser-controller/download"), 404)

      assert hint1 =~ "browser-controller-package"

      assert %{"error" => "remote-access-client archive not packaged", "hint" => hint2} =
               json_response(get(conn, "/api/v1/config/remote-access-client/download"), 404)

      assert hint2 =~ "remote-access-client-package"
    end
  end
end
