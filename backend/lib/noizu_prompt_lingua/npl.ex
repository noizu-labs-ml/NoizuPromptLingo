defmodule NoizuPromptLingua.NPL do
  @moduledoc """
  Noizu Prompt Lingua (NPL) - A modular, structured framework for advanced
  prompt engineering and agent simulation with context-aware loading capabilities.

  This module provides the base interface and configuration for NPL conventions.
  """

  @spec conventions_dir() :: String.t()
  def conventions_dir do
    Application.get_env(:noizu_prompt_lingua, :npl_conventions_dir) ||
      Path.join(:code.priv_dir(:noizu_prompt_lingua), "conventions")
  end

  @spec version() :: String.t()
  def version do
    case load_npl_yaml() do
      {:ok, npl} -> Map.get(npl, "version", "1.0")
      {:error, _} -> "1.0"
    end
  end

  @spec section_order() :: [String.t()]
  def section_order do
    case load_npl_yaml() do
      {:ok, npl} -> get_in(npl, ["section_order", "components"]) || valid_sections()
      {:error, _} -> valid_sections()
    end
  end

  @spec concepts() :: [map()]
  def concepts do
    case load_npl_yaml() do
      {:ok, npl} -> Map.get(npl, "concepts", [])
      {:error, _} -> []
    end
  end

  @spec description() :: String.t()
  def description do
    case load_npl_yaml() do
      {:ok, npl} -> String.trim(Map.get(npl, "description", ""))
      {:error, _} -> ""
    end
  end

  @spec valid_sections() :: [String.t()]
  def valid_sections do
    ~w(syntax declarations directives prefixes prompt-sections special-sections pumps)
  end

  @doc """
  Alternate section names declared in `npl.yaml` as `section_aliases`
  (e.g. the legacy `fences` section aliasing to `prompt-sections`).
  Reads from the given conventions dir (default: the configured one).
  """
  @spec section_aliases(String.t()) :: %{String.t() => String.t()}
  def section_aliases(dir \\ conventions_dir()) do
    case load_npl_yaml(dir) do
      {:ok, npl} -> normalize_aliases(Map.get(npl, "section_aliases", %{}))
      {:error, _} -> %{}
    end
  end

  defp normalize_aliases(aliases) when is_map(aliases) do
    Map.new(aliases, fn {k, v} -> {to_string(k), to_string(v)} end)
  end

  defp normalize_aliases(_), do: %{}

  defp load_npl_yaml(dir \\ conventions_dir()) do
    npl_path = Path.join(dir, "npl.yaml")

    case File.exists?(npl_path) do
      true ->
        case YamlElixir.read_from_file(npl_path) do
          {:ok, data} -> {:ok, Map.get(data, "/npl", %{})}
          {:error, _} = err -> err
        end

      false ->
        {:error, :not_found}
    end
  end
end
