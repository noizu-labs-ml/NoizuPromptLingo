defmodule NoizuPromptLingua.NPL do
  @moduledoc false

  @spec conventions_dir() :: String.t()
  def conventions_dir do
    Application.get_env(:noizu_prompt_lingua, :npl_conventions_dir) ||
      Path.join(:code.priv_dir(:noizu_prompt_lingua), "conventions")
  end
end
