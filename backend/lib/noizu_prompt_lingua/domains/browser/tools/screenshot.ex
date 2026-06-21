defmodule NoizuPromptLingua.Domains.Browser.Tools.Screenshot do
  use Noizu.MCP.Server.Tool,
    name: "Browser.Screenshot",
    description:
      "Capture a screenshot of the connected browser. The image is uploaded to object storage and returned as a viewable media URL (short_id), so it shows up in the org's browser gallery. Optionally capture the full scrollable page or a single element by selector.",
    annotations: [read_only_hint: true],
    category: "Browser"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :full_page, :boolean, required: false, description: "Capture the full scrollable page (default false)"
    field :selector, :string, required: false, description: "CSS selector to capture a single element instead of the viewport"
  end

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    params =
      %{}
      |> maybe_put(:full_page, Args.get(args, :full_page))
      |> maybe_put(:selector, Args.get(args, :selector))

    Browser.capture_screenshot(Args.get(args, :organization), params)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
