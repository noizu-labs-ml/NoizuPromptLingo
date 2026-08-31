defmodule ExLiteLLM.FrontProxy.Bootstrap do
  @moduledoc """
  `GET /api/claude_cli/bootstrap` support — port of the Python front proxy's
  bootstrap handler.

  Claude CLI calls this to discover available models. We read the LiteLLM tier's
  registered deployments (directly, in-process) and return them as
  `additional_model_options`. Since both tiers share the node, this reads the
  Router registry directly rather than round-tripping HTTP.
  """

  alias ExLiteLLM.Deployments

  @doc "Build the bootstrap response body Claude CLI expects."
  @spec model_options() :: map()
  def model_options do
    options =
      Deployments.all()
      |> Enum.map(& &1["model_name"])
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()
      |> Enum.map(fn name ->
        %{model: name, name: name, description: "via ex-litellm proxy"}
      end)

    %{
      client_data: nil,
      additional_model_options: nilify_empty(options)
    }
  end

  defp nilify_empty([]), do: nil
  defp nilify_empty(list), do: list
end
