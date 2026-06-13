defmodule Codefresh.Agents.Adapters.Bedrock do
  @moduledoc """
  AWS Bedrock adapter. Stage-4 stub: accepts any well-formed config with a
  `:model` and `:auth_ref`; no API call is made. Real invocation lands post-MVP.
  """

  @behaviour Codefresh.Agents.Adapters.Behaviour

  alias Codefresh.Agents.Adapters.OpenAI

  @impl true
  def validate_config(config), do: OpenAI.validate_config(config)

  @impl true
  def health_check(_config), do: {:ok, :not_implemented}

  @impl true
  def invoke(config, request),
    do: Codefresh.Agents.Adapters.Stub.invoke("bedrock", config, request)
end
