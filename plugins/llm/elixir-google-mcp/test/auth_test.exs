defmodule Noizu.Google.MCP.AuthTest do
  use ExUnit.Case, async: false

  alias Noizu.Google.MCP.Auth
  alias Noizu.Google.Error

  test "wrap ok passes through" do
    assert {:ok, %{a: 1}} = Auth.wrap({:ok, %{a: 1}})
  end

  test "wrap error formats Google.Error" do
    err = %Error{tag: :config, message: "missing token", body: nil}
    assert {:error, msg} = Auth.wrap({:error, err})
    assert msg =~ "config"
    assert msg =~ "missing token"
  end

  test "client fails without credentials" do
    clear_auth_env()

    assert {:error, msg} = Auth.client()
    assert is_binary(msg)
  end

  test "client rejects invalid GOOGLE_SERVICE_ACCOUNT_JSON" do
    clear_auth_env()
    System.put_env("GOOGLE_SERVICE_ACCOUNT_JSON", "not-json")
    on_exit(fn -> System.delete_env("GOOGLE_SERVICE_ACCOUNT_JSON") end)

    assert {:error, msg} = Auth.client()
    assert msg =~ "not valid JSON"
  end

  test "client mints a token from GOOGLE_APPLICATION_CREDENTIALS" do
    clear_auth_env()
    path = write_temp_sa!()
    System.put_env("GOOGLE_APPLICATION_CREDENTIALS", path)

    on_exit(fn ->
      System.delete_env("GOOGLE_APPLICATION_CREDENTIALS")
      File.rm(path)
      Application.delete_env(:noizu_google, :request_fun)
    end)

    Application.put_env(:noizu_google, :request_fun, fn req ->
      assert to_string(req.url) =~ "oauth2.googleapis.com"
      body = if is_map(req.body), do: "", else: to_string(req.body || "")
      form = URI.decode_query(body)
      assert form["grant_type"] == "urn:ietf:params:oauth:grant-type:jwt-bearer"
      assert is_binary(form["assertion"]) and form["assertion"] != ""

      {:ok,
       %Finch.Response{
         status: 200,
         body: Jason.encode!(%{"access_token" => "mcp-sa-token", "expires_in" => 3600}),
         headers: [{"content-type", "application/json"}]
       }}
    end)

    assert {:ok, client} = Auth.client()
    assert client.access_token == "mcp-sa-token"
  end

  defp clear_auth_env do
    Enum.each(
      [
        "GOOGLE_ACCESS_TOKEN",
        "GOOGLE_MARKETING_ACCESS_TOKEN",
        "GOOGLE_REFRESH_TOKEN",
        "GOOGLE_MARKETING_REFRESH_TOKEN",
        "GOOGLE_APPLICATION_CREDENTIALS",
        "GOOGLE_CREDENTIALS_FILE",
        "GOOGLE_SERVICE_ACCOUNT_FILE",
        "GOOGLE_SERVICE_ACCOUNT_JSON",
        "GOOGLE_SCOPES",
        "GOOGLE_SUBJECT",
        "GOOGLE_IMPERSONATE"
      ],
      &System.delete_env/1
    )

    Application.put_env(:noizu_google, :access_token, nil)
    Application.put_env(:noizu_google, :refresh_token, nil)
    Application.put_env(:noizu_google, :credentials_file, nil)
    Application.put_env(:noizu_google, :service_account, nil)
  end

  defp write_temp_sa! do
    rsa = :public_key.generate_key({:rsa, 2048, 65537})
    entry = :public_key.pem_entry_encode(:RSAPrivateKey, rsa)
    pem = :public_key.pem_encode([entry])

    creds = %{
      "type" => "service_account",
      "project_id" => "test-project",
      "private_key" => pem,
      "client_email" => "sa@test-project.iam.gserviceaccount.com",
      "token_uri" => "https://oauth2.googleapis.com/token"
    }

    path =
      Path.join(
        System.tmp_dir!(),
        "noizu-google-mcp-sa-#{System.unique_integer([:positive])}.json"
      )

    File.write!(path, Jason.encode!(creds))
    path
  end
end
