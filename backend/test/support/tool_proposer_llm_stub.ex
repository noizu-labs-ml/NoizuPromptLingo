defmodule NoizuPromptLingua.TestSupport.ToolProposerLLMStub do
  @moduledoc """
  Scripted LLM runner stub for PRD-020 (FR-3) `ToolProposer` tests — plugs into
  the `:llm {mod, fun}` opt or the `:tool_proposer_llm` app-env seam. No
  network, no OpenAI keys.

  Runner contract (FR-3): `run(messages, opts) :: {:ok, String.t()} |
  {:error, term()}` — the ok text is a JSON object.

  Script entries are returned from `run/2` in order; a fresh Agent is started
  per test via `start_supervised!({__MODULE__, script: [entries...]})`. Useful
  entry shapes:

    {:ok, Jason.encode!(%{"questions" => [%{"prompt" => "...", "kind" => "single",
                                            "options" => ["A", "B"]} | ...]})}
        # questions payload (server mints r1-*/r2-* ids, converts kind to atom)

    {:ok, Jason.encode!(%{"summary" => "...",
                          "tools" => [%{"name" => "Ticket_Create",
                                        "rationale" => "..."} | ...]})}
        # proposal payload. `group` is intentionally NOT (or falsely) supplied:
        # per FR-3 the group is always server-resolved from the catalog.

    {:error, :timeout} | {:error, :boom}   # runner failure paths
    {:ok, "not json at all"}               # unusable payload
    {:ok, ~s({"unexpected": true})}        # schema-invalid payload

  An exhausted script returns `{:error, :script_exhausted}` (itself a valid
  llm_unavailable trigger) so a 422-vs-200 assertion still works when the
  implementation wrongly calls the LLM on a validation path.
  """

  use Agent

  def start_link(opts) do
    script = Keyword.get(opts, :script, [])
    Agent.start_link(fn -> {script, []} end, name: __MODULE__)
  end

  @doc "Runner contract entry point: `apply(mod, fun, [messages, opts])`."
  def run(messages, _opts) do
    Agent.get_and_update(__MODULE__, fn
      {[entry | rest], seen} -> {entry, {rest, [messages | seen]}}
      {[], seen} -> {{:error, :script_exhausted}, {[], [messages | seen]}}
    end)
  end

  @doc "Replace the remaining script (for multi-phase tests)."
  def set_script(script), do: Agent.update(__MODULE__, fn {_, seen} -> {script, seen} end)

  @doc "Number of runner invocations so far (round-cap assertions)."
  def calls, do: Agent.get(__MODULE__, fn {_, seen} -> length(seen) end)

  @doc "Messages from the most recent runner invocation (for prompt-hygiene asserts)."
  def last_messages,
    do: Agent.get(__MODULE__, fn {_, [last | _]} -> last; {_, []} -> nil end)
end
