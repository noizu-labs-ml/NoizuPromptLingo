defmodule NoizuPromptLingua.NPL.Loader do
  @moduledoc false

  alias NoizuPromptLingua.NPL.Parser
  alias NoizuPromptLingua.NPL.Resolver
  alias NoizuPromptLingua.NPL.Layout

  @spec load(String.t(), keyword()) :: {:ok, String.t()} | {:error, String.t()}
  def load(expression, opts \\ []) do
    npl_dir = Keyword.get(opts, :npl_dir, NoizuPromptLingua.NPL.conventions_dir())
    layout = Keyword.get(opts, :layout, :yaml_order)
    skip = Keyword.get(opts, :skip, nil)

    # Section aliases (npl.yaml `section_aliases`) are resolved to canonical
    # section names before any file lookup, so output always uses canonicals.
    aliases = NoizuPromptLingua.NPL.section_aliases(npl_dir)

    with {:ok, parsed} <- Parser.parse(expression, aliases),
         {:ok, parsed} <- fold_skip(parsed, skip, aliases),
         resolver = Resolver.new(npl_dir),
         {:ok, components} <- Resolver.resolve(resolver, parsed) do
      {:ok, Layout.format(components, layout)}
    end
  end

  defp fold_skip(parsed, nil, _aliases), do: {:ok, parsed}
  defp fold_skip(parsed, [], _aliases), do: {:ok, parsed}

  defp fold_skip(parsed, skip, aliases) when is_binary(skip) do
    fold_skip(parsed, [skip], aliases)
  end

  defp fold_skip(parsed, skip_terms, aliases) when is_list(skip_terms) do
    Enum.reduce_while(skip_terms, {:ok, parsed}, fn term, {:ok, acc} ->
      term = String.trim(term)

      if term == "" do
        {:cont, {:ok, acc}}
      else
        case Parser.parse(term, aliases) do
          {:ok, skip_parsed} ->
            new_subs = acc.subtractions ++ skip_parsed.additions
            {:cont, {:ok, %{acc | subtractions: new_subs}}}

          {:error, _} = err ->
            {:halt, err}
        end
      end
    end)
  end
end
