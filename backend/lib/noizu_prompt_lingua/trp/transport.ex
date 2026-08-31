defmodule NoizuPromptLingua.TRP.Transport do
  @moduledoc """
  HTTP transport behaviour for the TRP client.

  The default impl is `NoizuPromptLingua.TRP.Transport.Req` (uses `Req` on a
  dedicated `Finch` pool). Tests stub this via
  `Application.put_env(:noizu_prompt_lingua, :trp_transport, StubModule)`.
  """

  @callback request(method :: atom(), base_url :: String.t(), path :: String.t(), headers :: [{String.t(), String.t()}], body :: nil | map() | binary(), opts :: keyword()) ::
              {:ok, status :: pos_integer(), body :: binary() | nil}
              | {:error, term()}
end
