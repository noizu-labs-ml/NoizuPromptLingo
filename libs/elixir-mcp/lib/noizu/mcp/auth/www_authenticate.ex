defmodule Noizu.MCP.Auth.WWWAuthenticate do
  @moduledoc """
  Parse and format `WWW-Authenticate` challenges (RFC 9110 §11.6.1), as used
  by the MCP authorization spec to point clients at protected-resource
  metadata and signal `insufficient_scope` step-up.
  """

  @type t :: %__MODULE__{scheme: String.t(), params: %{optional(String.t()) => String.t()}}
  defstruct scheme: "Bearer", params: %{}

  @doc ~S"""
  Parse a challenge header value.

      iex> Noizu.MCP.Auth.WWWAuthenticate.parse(
      ...>   ~s(Bearer resource_metadata="https://x/.well-known/oauth-protected-resource", error="invalid_token")
      ...> )
      %Noizu.MCP.Auth.WWWAuthenticate{
        scheme: "Bearer",
        params: %{
          "resource_metadata" => "https://x/.well-known/oauth-protected-resource",
          "error" => "invalid_token"
        }
      }
  """
  @spec parse(String.t() | nil) :: t() | nil
  def parse(nil), do: nil

  def parse(header) when is_binary(header) do
    case String.split(header, " ", parts: 2) do
      [scheme] ->
        %__MODULE__{scheme: scheme}

      [scheme, params] ->
        parsed =
          ~r/([a-zA-Z0-9_]+)=(?:"([^"]*)"|([^,\s]+))/
          |> Regex.scan(params)
          |> Map.new(fn
            [_, key, quoted] -> {key, quoted}
            [_, key, "", bare] -> {key, bare}
          end)

        %__MODULE__{scheme: scheme, params: parsed}
    end
  end

  @doc "Format a challenge header value. `params` is an enumerable of name/value pairs."
  @spec format(String.t(), [{String.t() | atom(), String.t()}] | map()) :: String.t()
  def format(scheme \\ "Bearer", params) do
    case Enum.map_join(params, ", ", fn {key, value} -> ~s(#{key}="#{value}") end) do
      "" -> scheme
      rendered -> "#{scheme} #{rendered}"
    end
  end
end
