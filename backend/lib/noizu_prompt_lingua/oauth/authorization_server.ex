defmodule NoizuPromptLingua.OAuth.AuthorizationServer do
  @moduledoc """
  RFC 8414 Authorization Server Metadata and issuer URL helpers.
  """

  def issuer_url do
    Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
    |> Keyword.get(:issuer_url) ||
      System.get_env("MCP_ISSUER_URL") ||
      default_issuer_url()
  end

  def metadata do
    base = issuer_url() |> String.trim_trailing("/")

    %{
      "issuer" => base,
      "authorization_endpoint" => "#{base}/oauth/authorize",
      "token_endpoint" => "#{base}/oauth/token",
      "registration_endpoint" => "#{base}/oauth/register",
      "revocation_endpoint" => "#{base}/oauth/revoke",
      "jwks_uri" => "#{base}/.well-known/jwks.json",
      "response_types_supported" => ["code"],
      "grant_types_supported" => [
        "authorization_code",
        "refresh_token",
        "urn:ietf:params:oauth:grant-type:token-exchange"
      ],
      "code_challenge_methods_supported" => ["S256"],
      "token_endpoint_auth_methods_supported" => ["none", "client_secret_post", "client_secret_basic"],
      "scopes_supported" => ["openid", "mcp", "offline_access"],
      "subject_types_supported" => ["public"],
      "service_documentation" => "#{base}/",
      "ui_locales_supported" => ["en"]
    }
  end

  # JWT `iss` claim — accept both legacy short form and full issuer URL.
  def jwt_issuers do
    short =
      Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
      |> Keyword.get(:issuer, "tobor-locker")

    [short, issuer_url()] |> Enum.uniq()
  end

  defp default_issuer_url do
    case Application.get_env(:noizu_prompt_lingua, :frontend_url) do
      url when is_binary(url) and url != "" ->
        url
        |> String.replace_trailing("/", "")
        |> then(fn u ->
          # frontend may be same host as API on tobor.locker
          u
        end)

      _ ->
        "https://tobor.locker"
    end
  end
end
