defmodule NoizuPromptLinguaWeb.MediaServeControllerTest do
  @moduledoc """
  Public media serving (/media/:short_id, auth checked inline): visibility
  ladder (public / org / private), the 401/403/404 arms, transform params on
  non-image assets falling through to the original, and the storage seams —
  presign redirect when S3 is configured, 503 when it is not, and byte-serving
  of private assets against a local Bandit S3 stub (ExAws path- or
  virtual-host style both land on the key's last segment).
  """

  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.MockMCPStub
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Media.Asset

  @etag_key "uploads/w5a/m1.png"

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "media-org-#{System.unique_integer([:positive])}"

    org_id =
      auth
      |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "Media Org"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    %{access_token: outsider_token} = setup_user_and_token()

    # Storage env untouched by default => the not-configured arms.
    {:ok, auth: auth, user: user, org_id: org_id, outsider_token: outsider_token}
  end

  defp insert_asset(org_id, attrs) do
    short_id = "m#{System.unique_integer([:positive])}"

    {:ok, asset} =
      Repo.insert(
        %Asset{
          media_type: :image,
          file_type: :png,
          file: @etag_key,
          short_id: short_id,
          visibility: "public",
          owner_type: "organization",
          owner_id: org_id
        }
        |> struct(attrs)
      )

    asset
  end

  defp configure_storage do
    original = Application.get_env(:noizu_prompt_lingua, NoizuPromptLingua.Storage)

    stub = MockMCPStub.start()
    on_exit(fn -> MockMCPStub.stop(stub) end)

    Application.put_env(:noizu_prompt_lingua, NoizuPromptLingua.Storage,
      bucket: "test-bucket",
      access_key_id: "test",
      secret_access_key: "test",
      region: "us-east-1",
      scheme: "http://",
      host: "127.0.0.1",
      port: stub.port
    )

    on_exit(fn ->
      if original,
        do: Application.put_env(:noizu_prompt_lingua, NoizuPromptLingua.Storage, original),
        else: Application.delete_env(:noizu_prompt_lingua, NoizuPromptLingua.Storage)
    end)

    stub
  end

  describe "visibility + auth arms" do
    test "unknown short_id -> 404", %{conn: conn} do
      assert %{"error" => "Media not found"} =
               json_response(get(conn, "/media/nope-nope"), 404)
    end

    test "org media without a token -> 401", %{conn: conn, org_id: org_id} do
      asset = insert_asset(org_id, visibility: "org")

      assert %{"error" => "Authentication required"} =
               json_response(get(conn, "/media/#{asset.short_id}"), 401)
    end

    test "org media as a non-member -> 403", %{
      conn: conn,
      org_id: org_id,
      outsider_token: t
    } do
      asset = insert_asset(org_id, visibility: "org")

      assert %{"error" => "Insufficient permissions"} =
               json_response(authenticated_conn(conn, t) |> get("/media/#{asset.short_id}"), 403)
    end

    test "private media with a signed-in caller surfaces S3 fetch failures", %{
      auth: auth,
      org_id: org_id
    } do
      # NB: the permissive fallback arm (check_access/2 catch-all) is
      # unreachable through the DB — chk_media_visibility pins the column to
      # public/org/private. The private path always goes to S3: configure the
      # stub and fail the fetch to pin the 500 arm without touching real AWS.
      stub = configure_storage()
      MockMCPStub.seq(stub, "m1.png", [{:status, 500, "boom"}])

      asset = insert_asset(org_id, visibility: "private")

      assert %{"error" => "Failed to fetch media"} =
               json_response(get(auth, "/media/#{asset.short_id}"), 500)
    end
  end

  describe "public assets + storage seams" do
    test "public media with storage unconfigured -> 503", %{conn: conn, org_id: org_id} do
      asset = insert_asset(org_id, visibility: "public")

      assert %{"error" => "storage not configured"} =
               json_response(get(conn, "/media/#{asset.short_id}"), 503)
    end

    test "public media with storage configured redirects to the presigned URL", %{
      conn: conn,
      org_id: org_id
    } do
      configure_storage()
      asset = insert_asset(org_id, visibility: "public")

      conn = get(conn, "/media/#{asset.short_id}")

      assert conn.status == 302
      assert get_resp_header(conn, "cache-control") |> hd() =~ "public"

      [location] = get_resp_header(conn, "location")
      assert location =~ @etag_key
    end

    test "org media for a member streams bytes from the S3 stub", %{
      auth: auth,
      org_id: org_id
    } do
      stub = configure_storage()
      MockMCPStub.seq(stub, "m1.png", [{:raw, "PNGDATA-BYTES"}])

      asset = insert_asset(org_id, visibility: "org")

      conn = get(auth, "/media/#{asset.short_id}")

      assert conn.status == 200
      assert conn.resp_body == "PNGDATA-BYTES"
      assert get_resp_header(conn, "cache-control") == ["private, no-store"]
    end

    test "content-type mapping covers the file_type ladder", %{auth: auth, org_id: org_id} do
      stub = configure_storage()

      expected = [
        {:jpg, "pic.jpg", "JPG", "image/jpeg"},
        {:svg, "icon.svg", "SVG", "image/svg+xml"},
        {:mp4, "clip.mp4", "MP4", "video/mp4"},
        {:other, "blob.bin", "BIN", "application/octet-stream"}
      ]

      for {ft, segment, body, content_type} <- expected do
        MockMCPStub.seq(stub, segment, [{:raw, body}])

        {:ok, asset} =
          Repo.insert(%Asset{
            media_type: :other,
            file_type: ft,
            file: "uploads/w5a/#{segment}",
            short_id: "c#{System.unique_integer([:positive])}",
            visibility: "org",
            owner_type: "organization",
            owner_id: org_id
          })

        conn = get(auth, "/media/#{asset.short_id}")

        assert conn.status == 200
        assert get_resp_header(conn, "content-type") |> hd() =~ content_type
      end
    end

    test "a cached variant is served directly (stream + S3 failure arms)", %{
      auth: auth,
      org_id: org_id
    } do
      stub = configure_storage()

      asset = insert_asset(org_id, visibility: "org")

      {:ok, _} =
        Repo.insert(%NoizuPromptLingua.Schema.Media.Variant{
          media_id: asset.id,
          params: "h=64,w=64",
          variant_key: "uploads/w5a/variants/m1_64.png",
          content_type: "image/png"
        })

      # Variant key's last segment drives the stub response.
      MockMCPStub.seq(stub, "m1_64.png", [{:raw, "VARIANT-BYTES"}])

      conn = get(auth, "/media/#{asset.short_id}?w=64&h=64")
      assert conn.status == 200
      assert conn.resp_body == "VARIANT-BYTES"

      # S3 failure on the variant fetch -> typed 500.
      MockMCPStub.seq(stub, "m1_64.png", [{:status, 500, "boom"}])

      assert %{"error" => "Failed to fetch variant"} =
               json_response(get(auth, "/media/#{asset.short_id}?w=64&h=64"), 500)
    end

    test "transform params on a non-image asset fall through to the original", %{
      auth: auth,
      org_id: org_id
    } do
      stub = configure_storage()
      MockMCPStub.seq(stub, "doc1.pdf", [{:raw, "PDF-BYTES"}])

      {:ok, asset} =
        Repo.insert(%Asset{
          media_type: :document,
          file_type: :pdf,
          file: "uploads/w5a/doc1.pdf",
          short_id: "d#{System.unique_integer([:positive])}",
          visibility: "org",
          owner_type: "organization",
          owner_id: org_id
        })

      conn = get(auth, "/media/#{asset.short_id}?w=100&h=100")

      assert conn.status == 200
      assert conn.resp_body == "PDF-BYTES"
    end

    test "transform params on an image hit the variant path (transform failure -> 422)", %{
      auth: auth,
      org_id: org_id
    } do
      stub = configure_storage()
      MockMCPStub.seq(stub, "m1.png", [{:raw, "PNGDATA-BYTES"}])

      asset = insert_asset(org_id, visibility: "org")

      # No cached variant; the transform itself fails against raw bytes
      # (not a real PNG) -> the typed transform-failure response.
      assert %{"error" => error} =
               json_response(get(auth, "/media/#{asset.short_id}?w=64&h=64"), 422)

      assert error =~ "Transform failed"
    end
  end
end
