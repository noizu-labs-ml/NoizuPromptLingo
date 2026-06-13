defmodule Noizu.MCP.UriTemplate do
  @moduledoc """
  Minimal RFC 6570 (level 1) URI template support: simple `{var}` expressions.

      iex> Noizu.MCP.UriTemplate.match("db://{table}/schema", "db://users/schema")
      {:ok, %{table: "users"}}

      iex> Noizu.MCP.UriTemplate.match("db://{table}/schema", "db://users/data")
      :nomatch
  """

  @doc "Match a URI against a template; returns captured variables atom-keyed."
  @spec match(String.t(), String.t()) :: {:ok, map()} | :nomatch
  def match(template, uri) when is_binary(template) and is_binary(uri) do
    {regex, variables} = compile(template)

    case Regex.run(regex, uri, capture: :all_but_first) do
      nil ->
        :nomatch

      captures ->
        {:ok,
         variables
         |> Enum.zip(captures)
         |> Map.new(fn {variable, value} -> {variable, URI.decode(value)} end)}
    end
  end

  @doc "Variable names (atoms) appearing in a template, in order."
  @spec variables(String.t()) :: [atom()]
  def variables(template) do
    Regex.scan(~r/\{([a-zA-Z0-9_]+)\}/, template, capture: :all_but_first)
    |> Enum.map(fn [name] -> String.to_atom(name) end)
  end

  @doc "Expand a template with the given variables."
  @spec expand(String.t(), map()) :: String.t()
  def expand(template, vars) do
    Regex.replace(~r/\{([a-zA-Z0-9_]+)\}/, template, fn _, name ->
      value = Map.get(vars, String.to_existing_atom(name)) || Map.get(vars, name) || ""
      URI.encode_www_form(to_string(value))
    end)
  end

  defp compile(template) do
    variables = variables(template)

    pattern =
      template
      |> String.split(~r/\{[a-zA-Z0-9_]+\}/, include_captures: true)
      |> Enum.map_join(fn part ->
        if part =~ ~r/^\{[a-zA-Z0-9_]+\}$/ do
          "([^/]+)"
        else
          Regex.escape(part)
        end
      end)

    {Regex.compile!("^" <> pattern <> "$"), variables}
  end
end
