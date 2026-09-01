defmodule NoizuPromptLingua.MCP.Urls do
  @moduledoc """
  Canonical custom-scope URL builders (contract §2 / W1 shapes):

      scope_url(scope)  # https://tobor.locker/org/:org_slug/custom/:slug/mcp  (preferred)
      user_url(scope)   # https://tobor.locker/user/:slug/mcp    (account-level sharing, W2)
      legacy_url(scope) # https://tobor.locker/custom/:slug/mcp  (permanent alias)

  Old hex-handle `/custom/:hex` URLs resolve forever (W1 aliases, never
  renames — clients bake them in), which is why `legacy_url` stays first-class.
  `scope_url/2` falls back to the legacy shape when the scope has no
  resolvable org slug; pass `org_slug:` to skip the DB lookup.
  """

  alias NoizuPromptLingua.MCPServers
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  @doc "Preferred URL: org-scoped path when the org (slug) is resolvable, else legacy."
  def scope_url(scope, opts \\ []) do
    case org_slug(scope, opts) do
      org_slug when is_binary(org_slug) and org_slug != "" ->
        build(opts, "org/#{org_slug}/custom/#{slug(scope)}/mcp")

      _ ->
        legacy_url(scope, opts)
    end
  end

  @doc "Account-level sharing path (W2): `/user/:scope_slug/mcp`."
  def user_url(scope, opts \\ []), do: build(opts, "user/#{slug(scope)}/mcp")

  @doc "Permanent legacy alias: `/custom/:scope_slug/mcp`."
  def legacy_url(scope, opts \\ []), do: build(opts, "custom/#{slug(scope)}/mcp")

  @doc """
  Human-facing chat room URL (frontend route): `/app/:org_slug/chat/:room_id`.
  Returns nil when the room's org slug cannot be resolved.
  """
  def chat_room_url(room, opts \\ []) do
    case org_slug(room, opts) do
      org_slug when is_binary(org_slug) and org_slug != "" ->
        build(opts, "app/#{org_slug}/chat/#{id(room)}")

      _ ->
        nil
    end
  end

  defp build(opts, path) do
    host = opts[:host] || MCPServers.default_host()
    "https://#{host}/#{path}"
  end

  defp org_slug(scope, opts) do
    opts[:org_slug] || org_slug_from_record(scope)
  end

  defp org_slug_from_record(%{organization_id: org_id}) when is_binary(org_id) do
    case Repo.get(Organization, org_id) do
      %{slug: slug} when is_binary(slug) and slug != "" -> slug
      _ -> nil
    end
  rescue
    _ -> nil
  end

  defp org_slug_from_record(_), do: nil

  defp slug(scope) do
    case scope do
      %{slug: slug} when is_binary(slug) -> slug
      %{"slug" => slug} when is_binary(slug) -> slug
      slug when is_binary(slug) -> slug
      _ -> raise ArgumentError, "Urls: scope slug required, got: #{inspect(scope)}"
    end
  end

  defp id(room) do
    case room do
      %{id: id} when is_binary(id) -> id
      %{"id" => id} when is_binary(id) -> id
      _ -> raise ArgumentError, "Urls: room id required, got: #{inspect(room)}"
    end
  end
end
