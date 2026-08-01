defmodule NoizuPromptLingua.Clients do
  @moduledoc """
  Host dual-path for Clients (always-on pm_core).
  No local clients table — all ops go through Noizu.PM.Clients when configured.
  """

  def get(id) do
    case NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Clients.get(id) end) do
      {:legacy, _} -> nil
      other -> other
    end
  end

  def create(attrs, user_id \\ nil) do
    case NoizuPromptLingua.PMCore.with_pm(fn ->
           # Ensure org + user exist on pm_core for FKs.
           ensure_identity(attrs, user_id)
           Noizu.PM.Clients.create(attrs, user_id)
         end) do
      {:legacy, _} ->
        {:error, :pm_core_required}

      other ->
        other
    end
  end

  def update(id, attrs) do
    case NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Clients.update(id, attrs) end) do
      {:legacy, _} -> {:error, :pm_core_required}
      other -> other
    end
  end

  def list_for_org(organization_id, opts \\ []) do
    case NoizuPromptLingua.PMCore.with_pm(fn ->
           Noizu.PM.Clients.list_for_org(organization_id, opts)
         end) do
      {:legacy, _} -> []
      list when is_list(list) -> list
      _ -> []
    end
  end

  def resolve(organization_id, slug_or_uuid) do
    case NoizuPromptLingua.PMCore.with_pm(fn ->
           Noizu.PM.Clients.resolve(organization_id, slug_or_uuid)
         end) do
      {:legacy, _} -> nil
      other -> other
    end
  end

  def archive(id) do
    case NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Clients.archive(id) end) do
      {:legacy, _} -> {:error, :pm_core_required}
      other -> other
    end
  end

  defp ensure_identity(attrs, user_id) do
    org_id = Map.get(attrs, :organization_id) || Map.get(attrs, "organization_id")

    if user_id do
      case NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.Users.User, user_id) do
        nil ->
          Noizu.PM.Users.ensure(%{id: user_id, email: "user-#{user_id}@tobor.locker"})

        u ->
          Noizu.PM.Users.ensure(%{
            id: u.id,
            email: u.email,
            user_name: u.user_name,
            handle: u.handle,
            status: u.status,
            role: u.role
          })
      end
    end

    if org_id do
      case NoizuPromptLingua.Repo.get(
             NoizuPromptLingua.Schema.Organizations.Organization,
             org_id
           ) do
        nil ->
          Noizu.PM.Organizations.ensure(%{id: org_id})

        o ->
          Noizu.PM.Organizations.ensure(%{
            id: o.id,
            slug: o.slug,
            name: o.name,
            settings: o.settings
          })
      end
    end

    :ok
  end
end
