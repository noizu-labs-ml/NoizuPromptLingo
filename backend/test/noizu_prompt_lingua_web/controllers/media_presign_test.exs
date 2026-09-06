defmodule NoizuPromptLinguaWeb.MediaPresignTest do
  @moduledoc """
  Regression (fix/error-family B4, stage log c6320): `POST /api/v1/media/presign`
  with S3 unconfigured crashed — `{:ok, url} = ExAws.S3.presigned_url(...)` became
  a MatchError (after an ExAws AuthCache exit). Storage now returns typed errors
  and the endpoints degrade to 503 "storage not configured".

  NB: the Storage app-env slice is process-global, so each test pins the slice
  it needs explicitly (ExUnit order is random) and restores it on_exit.
  """

  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Storage

  @configured [
    bucket: "test-bucket",
    region: "us-east-1",
    host: "s3.amazonaws.com",
    scheme: "https://",
    access_key_id: "AKIA-test",
    secret_access_key: "secret-test"
  ]

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    original = Application.get_env(:noizu_prompt_lingua, Storage)
    on_exit(fn -> Application.put_env(:noizu_prompt_lingua, Storage, original) end)

    {:ok, conn: auth}
  end

  test "POST presign answers 503 when storage is unconfigured", %{conn: conn} do
    Application.put_env(:noizu_prompt_lingua, Storage, [])

    conn =
      post(conn, "/api/v1/media/presign", %{filename: "a.png", content_type: "image/png"})

    assert json_response(conn, 503)["error"] == "storage not configured"
  end

  test "POST presign download answers 503 when storage is unconfigured", %{conn: conn} do
    Application.put_env(:noizu_prompt_lingua, Storage, [])

    conn = post(conn, "/api/v1/media/download", %{key: "some/key.png"})
    assert json_response(conn, 503)["error"] == "storage not configured"
  end

  test "Storage.presigned_upload_url/2 returns {:ok, url} with a full config" do
    Application.put_env(:noizu_prompt_lingua, Storage, @configured)

    assert {:ok, url} = Storage.presigned_upload_url("uploads/x/y.png", "image/png")
    assert is_binary(url)
    assert String.contains?(url, "test-bucket")
    assert String.contains?(url, "X-Amz-Signature")
  end

  test "presign helpers return typed errors, never raise, with a partial config" do
    Application.put_env(:noizu_prompt_lingua, Storage, bucket: "test-bucket")

    assert {:error, :storage_not_configured} =
             Storage.presigned_upload_url("k", "image/png")

    assert {:error, :storage_not_configured} = Storage.presigned_download_url("k")
  end
end
