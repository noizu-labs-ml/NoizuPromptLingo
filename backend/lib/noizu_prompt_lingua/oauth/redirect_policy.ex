defmodule NoizuPromptLingua.OAuth.RedirectPolicy do
  @moduledoc """
  Allowlisted redirect URI patterns for OAuth clients (Claude, ChatGPT, loopback).

  Exact match against the client's registered `redirect_uris` is required first;
  for Dynamic Client Registration, registration itself is gated by these patterns.
  """

  @default_patterns [
    ~r/^https:\/\/claude\.ai\//,
    ~r/^https:\/\/([a-z0-9-]+\.)?claude\.ai\//,
    ~r/^https:\/\/chatgpt\.com\//,
    ~r/^https:\/\/chat\.openai\.com\//,
    ~r/^https:\/\/platform\.openai\.com\//,
    ~r/^http:\/\/(127\.0\.0\.1|localhost)(:\d+)?\//,
    ~r/^http:\/\/(127\.0\.0\.1|localhost)(:\d+)?$/
  ]

  def allowed_for_registration?(uri) when is_binary(uri) do
    Enum.any?(patterns(), &Regex.match?(&1, uri))
  end

  def allowed_for_registration?(_), do: false

  def registered?(client_uris, redirect_uri)
      when is_list(client_uris) and is_binary(redirect_uri) do
    redirect_uri in client_uris
  end

  def registered?(_, _), do: false

  defp patterns do
    case Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
         |> Keyword.get(:redirect_uri_patterns) do
      list when is_list(list) and list != [] -> list
      _ -> @default_patterns
    end
  end
end
