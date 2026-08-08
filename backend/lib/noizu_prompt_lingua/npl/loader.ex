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

    with {:ok, parsed} <- Parser.parse(expression),
         {:ok, parsed} <- fold_skip(parsed, skip),
         resolver = Resolver.new(npl_dir),
         {:ok, components} <- Resolver.resolve(resolver, parsed) do
      {:ok, Layout.format(components, layout)}
    end
  end

  defp fold_skip(parsed, nil), do: {:ok, parsed}
  defp fold_skip(parsed, []), do: {:ok, parsed}

  defp fold_skip(parsed, skip) when is_binary(skip) do
    fold_skip(parsed, [skip])
  end

  defp fold_skip(parsed, skip_terms) when is_list(skip_terms) do
    Enum.reduce_while(skip_terms, {:ok, parsed}, fn term, {:ok, acc} ->
      term = String.trim(term)

      if term == "" do
        {:cont, {:ok, acc}}
      else
        case Parser.parse(term) do
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
