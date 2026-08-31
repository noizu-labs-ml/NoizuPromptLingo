defmodule NoizuPromptLingua.TRP.Config do
  @moduledoc """
  TRP shared-key runtime config.

  Sources (first non-nil wins):
    1. `Application.get_env(:noizu_prompt_lingua, :trp)` — `[:base_url, :shared_key]`
    2. `TRP_API_BASE_URL` / `TRP_SHARED_KEY` env vars

  Missing config is **not** a boot error: un-activated deploys boot fine and the
  first TRP call returns `{:error, :trp_not_configured}`. W8/W9 set the env vars
  at activation.
  """

  def base_url do
    env(:base_url) || System.get_env("TRP_API_BASE_URL")
    |> case do
      url when is_binary(url) -> String.replace_trailing(url, "/", "")
      other -> other
    end
  end

  def shared_key, do: env(:shared_key) || System.get_env("TRP_SHARED_KEY")

  @doc "True only when BOTH base_url and shared_key are set."
  def configured? do
    case {base_url(), shared_key()} do
      {url, key} when is_binary(url) and url != "" and is_binary(key) and key != "" -> true
      _ -> false
    end
  end

  defp env(key) do
    case Application.get_env(:noizu_prompt_lingua, :trp, []) do
      kw when is_list(kw) -> Keyword.get(kw, key)
      _ -> nil
    end
  end
end
