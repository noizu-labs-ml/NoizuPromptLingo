defmodule Codefresh.Agents.Adapters.Vertex do
  @moduledoc """
  Google Vertex AI adapter. Stage-4 stub — same shape as Bedrock; real
  invocation lands post-MVP.
  """

  @behaviour Codefresh.Agents.Adapters.Behaviour

  alias Codefresh.Agents.Adapters.OpenAI

  @impl true
  def validate_config(config), do: OpenAI.validate_config(config)

  @impl true
  def health_check(_config), do: {:ok, :not_implemented}

  @impl true
  def invoke(config, request),
    do: Codefresh.Agents.Adapters.Stub.invoke("vertex", config, request)
end
