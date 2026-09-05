defmodule NoizuPromptLingua.MCP.VFS.Jobs.Browser do
  @moduledoc """
  The `browser` group's runner shim (§3.8): executes browser job requests
  against the org's local Playwright controller via
  `NoizuPromptLingua.Domains.Browser` (the Relay correlation hub).

  The real Playwright transport runs host-side in the user's local controller;
  cloud-side this is pure Relay dispatch, so offline test controllers
  (`Relay.register/2` + `Relay.reply/2` — the `browser_domain_test` pattern)
  exercise the full job pipeline.

  Request shape (authored at `…/session/{id}/jobs/{job-id}/request.json`):

      {"tool": "click", "args": {"selector": "#submit"}}

  `organization` and `session` ride in from the path (the backend enriches the
  request before submit). Supported tools mirror the domain's sync surface —
  navigate · getstate · click · fill · screenshot · record_start · record_stop.

  Session memory: successful navigate/state runs record the page url in a
  `:persistent_term` registry keyed `{org, session}` — the file plane's
  `session/{id}/url` read and `state.json` render draw from it (v1: one
  controller per org, sessions are named views over it).
  """

  @behaviour NoizuPromptLingua.MCP.VFS.Jobs.Runner

  alias NoizuPromptLingua.Domains.Browser

  @impl true
  def backend, do: NoizuPromptLingua.MCP.VFS.Browser

  @impl true
  def group, do: "browser"

  # request tool → the canonical MCP tool the backend ToolGuard-checks.
  @impl true
  def tools do
    %{
      "navigate" => "Browser.Navigate",
      "getstate" => "Browser.GetState",
      "click" => "Browser.Click",
      "fill" => "Browser.Fill",
      "screenshot" => "Browser.Screenshot",
      "record_start" => "Browser.RecordStart",
      "record_stop" => "Browser.RecordStop"
    }
  end

  @impl true
  def run(%{"tool" => tool, "organization" => org, "session" => session} = request, _ctx) do
    args = request["args"] || %{}

    case tool do
      "navigate" ->
        url = args["url"]

        with {:ok, data} <- Browser.run(org, "navigate", %{url: url}) do
          put_session_url(org, session, url)
          {:ok, data}
        end

      "getstate" ->
        with {:ok, data} <- Browser.run(org, "state", %{include_text: !!args["include_text"]}) do
          if is_binary(data["url"]), do: put_session_url(org, session, data["url"])
          {:ok, data}
        end

      "click" ->
        Browser.run(org, "click", %{selector: args["selector"]})

      "fill" ->
        Browser.run(org, "fill", %{selector: args["selector"], value: args["value"]})

      "screenshot" ->
        # B1 discipline: only capture METADATA crosses the VFS. If the
        # controller fell back to inline base64, strip the bytes out.
        case Browser.capture_screenshot(org) do
          {:ok, %{image: _b64} = inline} ->
            {:ok, %{stored: false, width: inline[:width], height: inline[:height]}}

          {:ok, stored} ->
            {:ok, stored}

          {:error, _} = error ->
            error
        end

      "record_start" ->
        Browser.record_start(org)

      "record_stop" ->
        Browser.record_stop(org)

      other ->
        {:error, "unknown browser job tool '#{other}'"}
    end
  end

  def run(%{"tool" => other}, _ctx),
    do: {:error, "malformed browser job request (tool: #{inspect(other)})"}

  def run(_request, _ctx), do: {:error, "malformed browser job request"}

  # ── session memory (org × session named views over the org controller) ────

  @registry :npl_vfs_browser_sessions

  @doc "The last url a navigate/state job landed on for `{org, session}` (or nil)."
  @spec session_url(String.t(), String.t()) :: String.t() | nil
  def session_url(org, session) do
    :persistent_term.get({@registry, org, session}, nil)
  end

  @doc "Record the session's current url (runner-side; public for tests)."
  @spec put_session_url(String.t(), String.t(), String.t() | nil) :: :ok
  def put_session_url(org, session, url) when is_binary(url) do
    :persistent_term.put({@registry, org, session}, url)
    :ok
  end

  def put_session_url(_org, _session, _), do: :ok

  @doc "Sessions with recorded urls for an org — the `session/` readdir projection."
  @spec sessions(String.t()) :: [String.t()]
  def sessions(org) do
    for {{@registry, ^org, session}, _url} <- :persistent_term.get(),
        is_binary(session) do
      session
    end
    |> Enum.uniq()
    |> Enum.sort()
  rescue
    _ -> []
  end

  @doc "Forget session memory (test seam; also the documented restart semantics)."
  @spec reset :: :ok
  def reset do
    for {{@registry, _org, _session} = key, _url} <- :persistent_term.get() do
      :persistent_term.erase(key)
    end

    :ok
  end
end
