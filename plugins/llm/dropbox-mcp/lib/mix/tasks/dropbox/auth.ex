defmodule Mix.Tasks.Dropbox.Auth do
  @shortdoc "Run the Dropbox OAuth code-grant flow and print tokens (for .envrc)"

  @moduledoc """
  Interactive OAuth helper for connecting a Dropbox account to this MCP server.

  Prereqs (set these before running — or pass as args):
    export DROPBOX_APP_KEY=...      # from https://www.dropbox.com/developers/apps
    export DROPBOX_APP_SECRET=...

  The Dropbox app's Permissions MUST already grant:
    files.content.read, files.content.write, account_info.read,
    sharing.read, sharing.write
  (scopes are frozen at authorize time, so set them first in the dev console.)

  Usage:
      mix dropbox.auth
      mix dropbox.auth --redirect-uri="https://localhost/oauth/callback"
      mix dropbox.auth --app-key=... --app-secret=...   # overrides env

  Flow:
    1. Prints + opens the consent URL (token_access_type: "offline").
    2. You approve in the browser, get redirected to a localhost callback
       (the page won't load — that's fine; copy the full URL from the bar).
    3. Paste that URL (or just the ?code=... value) at the prompt.
    4. Prints the four DROPBOX_* export lines to put in .envrc.

  The printed DROPBOX_ACCESS_TOKEN is short-lived (~4h); the auto-refresh
  hook in noizu_dropbox keeps it alive as long as DROPBOX_REFRESH_TOKEN is set.
  """

  use Mix.Task

  @scopes ~w(files.content.read files.content.write account_info.read sharing.read sharing.write)

  @impl Mix.Task
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        strict: [app_key: :string, app_secret: :string, redirect_uri: :string]
      )

    # Mix tasks don't auto-start app trees; start :noizu_dropbox so its
    # Finch pool (Noizu.Dropbox.Finch) is up for the OAuth token exchange.
    # Do NOT start :dropbox_mcp — it would launch the stdio MCP server and
    # fight this task for stdin.
    {:ok, _} = Application.ensure_all_started(:noizu_dropbox)

    app_key = opts[:app_key] || System.get_env("DROPBOX_APP_KEY")
    app_secret = opts[:app_secret] || System.get_env("DROPBOX_APP_SECRET")
    redirect_uri = opts[:redirect_uri] || "https://localhost/oauth/callback"

    cond do
      is_nil(app_key) or app_key == "" ->
        Mix.shell().error("DROPBOX_APP_KEY not set (export it or pass --app-key=...)")
        exit({:shutdown, 1})

      is_nil(app_secret) or app_secret == "" ->
        Mix.shell().error("DROPBOX_APP_SECRET not set (export it or pass --app-secret=...)")
        exit({:shutdown, 1})

      true ->
        :ok
    end

    client = Noizu.Dropbox.client(app_key: app_key, app_secret: app_secret)

    url =
      Noizu.Dropbox.OAuth.authorize_url(
        client_id: app_key,
        token_access_type: "offline",
        redirect_uri: redirect_uri,
        scope: Enum.join(@scopes, " ")
      )

    Mix.shell().info("\n1) Open this URL and approve:\n\n#{url}\n")

    _ = System.cmd("open", [url], stderr_to_stdout: true)

    raw =
      Mix.shell().prompt(
        "\n2) Paste the full redirect URL (or just the code= value) after approving:"
      )
      |> String.trim()

    code = extract_code(raw)

    if code == "" do
      Mix.shell().error("Could not parse an OAuth code from the input.")
      exit({:shutdown, 1})
    end

    case Noizu.Dropbox.OAuth.token(
           code: code,
           redirect_uri: redirect_uri,
           client: client
         ) do
      {:ok, tokens} ->
        Mix.shell().info("\n✅ Success. Put these in .envrc:\n")
        Mix.shell().info(~s(export DROPBOX_APP_KEY="#{app_key}"))
        Mix.shell().info(~s(export DROPBOX_APP_SECRET="#{app_secret}"))
        Mix.shell().info(~s(export DROPBOX_REFRESH_TOKEN="#{tokens["refresh_token"]}"))
        Mix.shell().info(~s(export DROPBOX_ACCESS_TOKEN="#{tokens["access_token"]}"))

        Mix.shell().info(
          "\naccount_id: #{inspect(tokens["account_id"])}  scope: #{inspect(tokens["scope"])}"
        )

      {:error, err} ->
        Mix.shell().error("Token exchange failed: #{inspect(err, pretty: true)}")
        exit({:shutdown, 1})
    end
  end

  defp extract_code(input) do
    cond do
      String.contains?(input, "code=") ->
        input
        |> String.split("code=")
        |> List.last()
        |> String.split("&")
        |> List.first()
        |> String.trim()

      String.match?(input, ~r/^[A-Za-z0-9_-]+$/) ->
        input

      true ->
        ""
    end
  end
end
