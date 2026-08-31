defmodule NoizuPromptLingua.Components do
  @moduledoc """
  Lit component registry for the W7 component-exchange plane (tobor.locker).

  Keyed external hosts (e.g. the TRP Next.js embed) fetch components here:

    * `GET /api/v1/components` — list (per-key `toolset_config` governs which
      components are discoverable; group id `components`, component name as
      the tool key)
    * `GET /api/v1/components/:name/bundle` — the committed dist bundle
      (immutable per version; `cache-control: public, max-age=31536000,
      immutable`)

  Bundles are committed under `priv/components/<name>/` — synced from the
  authored package at `frontend/packages/<name>/dist/` (see
  `priv/components/README.md`). Serving from `priv/` keeps the files present
  in releases.
  """

  @typedoc "A registered component's metadata."
  @type t :: %{
          required(:name) => String.t(),
          required(:version) => String.t(),
          required(:description) => String.t(),
          required(:content_type) => String.t(),
          required(:entry) => String.t()
        }

  @registry [
    %{
      name: "npl-queue-board",
      version: "0.1.0",
      description:
        "Self-contained Lit web component rendering NPL ticket queue boards " <>
          "(stage columns + ticket cards). Pair with createLockerProvider data " <>
          "fetches over /api/v1/organizations/:org_id/boards + /tickets.",
      content_type: "text/javascript",
      entry: "npl-queue-board.js"
    }
  ]

  @bundle_dir "priv/components"

  @spec list :: [t()]
  def list, do: @registry

  @spec get(String.t()) :: t() | nil
  def get(name) when is_binary(name), do: Enum.find(@registry, &(&1.name == name))
  def get(_), do: nil

  @doc "Absolute path of a component's bundle, or nil when not shipped on disk."
  @spec bundle_path(t()) :: String.t() | nil
  def bundle_path(component) do
    path =
      Application.app_dir(
        :noizu_prompt_lingua,
        Path.join([@bundle_dir, component.name, component.entry])
      )

    if File.exists?(path), do: path, else: nil
  end

  @doc "Bundle bytes, or nil when the component is not shipped on disk."
  @spec bundle(t()) :: binary() | nil
  def bundle(component) do
    case bundle_path(component) do
      nil -> nil
      path -> File.read!(path)
    end
  end
end
