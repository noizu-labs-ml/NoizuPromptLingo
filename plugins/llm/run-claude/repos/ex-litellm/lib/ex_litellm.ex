defmodule ExLiteLLM do
  @moduledoc """
  ex-litellm — an interface-identical Elixir reimplementation of the LiteLLM
  proxy, plus run-claude's front-proxy routing tier folded into one app.

  One unified gateway (`ExLiteLLM.Gateway`, dev :4445 → prod :4443) serves both:

    * the OpenAI-compatible multi-provider inference + admin surface (the
      LiteLLM proxy), and
    * the runtime-alterable front-proxy routing/auth-swap layer (Anthropic
      passthrough, master-key swap) — folded into the same server, so there is
      no separate front-proxy process.

  SQLite by default (a single file), Postgres optional. Launched via the
  `ex-litellm` CLI (`ExLiteLLM.CLI`) with the same `--host/--port/--config`
  contract as the Python `litellm` binary.
  """

  @version Mix.Project.config()[:version]

  @doc "The ex-litellm version string (reported by health/readiness)."
  @spec version() :: String.t()
  def version, do: @version
end
