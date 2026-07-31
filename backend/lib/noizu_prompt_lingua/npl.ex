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
    ~w(syntax declarations directives prefixes prompt-sections special-sections pumps fences)
  end

  defp load_npl_yaml do
    npl_path = Path.join(conventions_dir(), "npl.yaml")

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
