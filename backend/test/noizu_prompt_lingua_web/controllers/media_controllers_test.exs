defmodule NoizuPromptLinguaWeb.MediaControllersTest do
  @moduledoc """
  Coverage for the media pair beyond the 503-degradation regressions already
  pinned by `media_presign_test.exs`:

    * `MediaController` — happy SigV4 presign/download shapes, filename
      sanitization, extension inference, and the register (201/422) surface.
    * `MediaServeController` — visibility/access matrix (404 / 401 / 403),
      public redirect vs. 503, and the non-public fetch paths (storage error
      → 500, transform error → 422) driven against a deterministic
      connection-refused endpoint (no real S3 traffic).

  NB: the Storage app-env slice is process-global — each test pins the slice
  it needs and restores it on_exit (same recipe as media_presign_test).
  """

  # async: false — the Storage app-env slice is process-global and this module
  # races media_presign_test's own flips if run concurrently.
  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Media.Asset
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.Storage

  @configured [
    bucket: "test-bucket",
    region: "us-east-1",
    host: "s3.amazonaws.com",
    scheme: "https://",
    access_key_id: "AKIA-test",
    secret_access_key: "secret-test"
  ]

  # Deterministic "S3 is down" slice: static creds (no AuthCache round-trip)
  # pointed at a closed local port — ExAws fails fast, no external traffic.
  @refused [
    bucket: "test-bucket",
    region: "us-east-1",
    host: "127.0.0.1",
    port: 1,
    scheme: "http://",
    access_key_id: "AKIA-test",
    secret_access_key: "secret-test"
  ]

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    original = Application.get_env(:noizu_prompt_lingua, Storage)
    on_exit(fn -> Application.put_env(:noizu_prompt_lingua, Storage, original) end)

    {:ok, conn: auth, user: user}
  end

  defp storage_slice(slice), do: Application.put_env(:noizu_prompt_lingua, Storage, slice)

  # ── MediaController.presign / download ────────────────────────────────────

  describe "POST /api/v1/media/presign" do
    test "happy path returns a SigV4 URL and the storage key", %{conn: conn, user: user} do
      storage_slice(@configured)

      resp =
        conn
        |> post("/api/v1/media/presign", %{filename: "cat photo.png", content_type: "image/png"})
        |> json_response(200)

      assert resp["upload_url"] =~ "test-bucket"
      assert resp["upload_url"] =~ "X-Amz-Signature"

      # uploads/<user_id>/<uuid>/<sanitized name>
      assert [up, owner, _uuid, name] = String.split(resp["key"], "/", parts: 4)
      assert up == "uploads"
      assert owner == user.id
      assert name == "cat_photo.png"
    end

    test "missing content_type -> 400 fallback", %{conn: conn} do
      storage_slice(@configured)

      conn =
        conn |> post("/api/v1/media/presign", %{filename: "a.png"})

      assert conn.status == 400
      assert json_response(conn, 400)["error"] =~ "required"
    end
  end

  describe "POST /api/v1/media/download" do
    test "happy path returns a presigned download URL", %{conn: conn} do
      storage_slice(@configured)

      resp =
        conn
        |> post("/api/v1/media/download", %{key: "uploads/x/y.png"})
        |> json_response(200)

      assert resp["download_url"] =~ "test-bucket"
      assert resp["download_url"] =~ "X-Amz-Signature"
    end
  end

  # ── MediaController.register ──────────────────────────────────────────────

  describe "POST /api/v1/media/register" do
    test "registers an asset (201) and infers the file_type from the filename", %{conn: conn} do
      storage_slice(@configured)

      resp =
        conn
        |> post("/api/v1/media/register", %{
          "key" => "uploads/u/1/photo.PNG",
          "filename" => "photo.PNG"
        })
        |> json_response(201)

      assert resp["id"]
      assert resp["key"] == "uploads/u/1/photo.PNG"
      assert resp["visibility"] == "private"
    end

    test "invalid visibility -> 422 changeset arm", %{conn: conn} do
      storage_slice(@configured)

      conn =
        conn
        |> post("/api/v1/media/register", %{
          "key" => "uploads/u/1/x.png",
          "filename" => "x.png",
          "visibility" => "bogus"
        })

      assert conn.status == 422
      assert json_response(conn, 422)["errors"]["visibility"]
    end
  end

  # ── MediaServeController ──────────────────────────────────────────────────

  describe "GET /media/:short_id" do
    test "unknown short_id -> 404", %{conn: conn} do
      assert json_response(get(conn, "/media/no-such-short-id"), 404)["error"] =~ "not found"
    end

    test "public asset + storage unconfigured -> 503 (no oracle, degraded)", %{conn: conn} do
      storage_slice([])
      asset = insert_asset(visibility: "public")

      conn = get(conn, "/media/#{asset.short_id}")

      assert conn.status == 503
      assert json_response(conn, 503)["error"] == "storage not configured"
    end

    test "public asset + storage configured -> 302 to the presigned URL", %{conn: conn} do
      storage_slice(@configured)
      asset = insert_asset(visibility: "public")

      conn = get(conn, "/media/#{asset.short_id}")

      assert conn.status == 302
      assert hd(get_resp_header(conn, "location")) =~ "test-bucket"
      assert hd(get_resp_header(conn, "cache-control")) =~ "max-age=3600"
    end

    test "private asset + no bearer -> 401", %{conn: conn} do
      storage_slice(@configured)
      asset = insert_asset(visibility: "private")

      # No Authorization header at all.
      conn = get(Plug.Conn.delete_req_header(conn, "authorization"), "/media/#{asset.short_id}")

      assert conn.status == 401
    end

    test "private asset + authenticated non-permitted caller -> 403", %{conn: conn} do
      storage_slice(@configured)
      asset = insert_asset(visibility: "private", owner_type: "organization")

      conn = get(conn, "/media/#{asset.short_id}")

      assert conn.status == 403
    end

    test "org asset + member viewer passes access, storage down -> 500 fetch arm", %{
      conn: conn,
      user: user
    } do
      storage_slice(@refused)

      asset =
        insert_asset(visibility: "org", owner_type: "organization", owner_id: owner_org(user))

      conn = get(conn, "/media/#{asset.short_id}")

      assert conn.status == 500
      assert json_response(conn, 500)["error"] =~ "Failed to fetch"
    end

    test "image asset with transform params + storage down -> 422 transform arm", %{conn: conn} do
      storage_slice(@refused)
      asset = insert_asset(visibility: "public", media_type: :image)

      conn = get(conn, "/media/#{asset.short_id}?w=64")

      assert conn.status == 422
      assert json_response(conn, 422)["error"] =~ "Transform failed"
    end

    test "cached variant + public -> 302 to the presigned variant (immutable cache)", %{
      conn: conn
    } do
      storage_slice(@configured)
      asset = insert_asset(visibility: "public", media_type: :image)

      # Pre-warm the variant cache so get_or_create_variant/2 short-circuits
      # (no S3 round-trip on this path).
      Repo.insert!(%NoizuPromptLingua.Schema.Media.Variant{
        media_id: asset.id,
        variant_key: "variants/#{asset.short_id}/w=64.png",
        params: "w=64",
        file_size: 10,
        content_type: "image/png"
      })

      conn = get(conn, "/media/#{asset.short_id}?w=64")

      assert conn.status == 302
      assert hd(get_resp_header(conn, "location")) =~ "variants/#{asset.short_id}"
      assert hd(get_resp_header(conn, "cache-control")) =~ "immutable"
    end

    test "cached variant + public + storage unconfigured -> 503", %{conn: conn} do
      storage_slice([])
      asset = insert_asset(visibility: "public", media_type: :image)

      Repo.insert!(%NoizuPromptLingua.Schema.Media.Variant{
        media_id: asset.id,
        variant_key: "variants/#{asset.short_id}/w=64.png",
        params: "w=64",
        file_size: 10,
        content_type: "image/png"
      })

      conn = get(conn, "/media/#{asset.short_id}?w=64")

      assert conn.status == 503
    end
  end

  # ── fixtures ──────────────────────────────────────────────────────────────

  defp insert_asset(opts) do
    # short_id is varchar(12) — take a 12-char slice of a dash-less UUID.
    short_id =
      Ecto.UUID.generate() |> String.replace("-", "") |> binary_part(0, 12)

    Repo.insert!(%Asset{
      media_type: Keyword.get(opts, :media_type, :image),
      file_type: :png,
      file: "uploads/test/#{Ecto.UUID.generate()}.png",
      short_id: short_id,
      visibility: Keyword.fetch!(opts, :visibility),
      # owner_type column is resource_type_enum ("user" is not a member).
      owner_type: Keyword.get(opts, :owner_type, "organization"),
      owner_id: Keyword.get(opts, :owner_id, Ecto.UUID.generate())
    })
  end

  # An org whose membership record makes the caller a viewer — the org
  # visibility branch of check_access/2 authorizes via Authz.
  defp owner_org(user) do
    # UUID-suffixed slug: slug→id positives-cache outlives the test VM (cf.
    # tool_set_gateway_test).
    org =
      Repo.insert!(%Organization{
        name: "Media Org",
        slug: "media-org-" <> Ecto.UUID.generate()
      })

    {:ok, _} = ScopedMemberships.add_member("organization", org.id, user.id, "viewer")
    org.id
  end
end
