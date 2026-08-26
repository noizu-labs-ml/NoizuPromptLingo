defmodule NoizuPromptLingua.Authz.PMBackfill do
  @moduledoc """
  One-time pm_core reconciliation (post pm-core cutover / b2a5237 regression):

  USER memberships that exist only on the app DB — pre-cutover rows never
  re-written to pm, and ETL-collapsed users whose pm member_id is a different
  uuid — must be backfilled into pm_core scoped_memberships so pm reads are
  self-sufficient. PERSONA rows stay app-DB by design and are never touched.

  `plan/0` is pure and read-only (the dry-run census). For each app-DB USER row
  it resolves the member's pm identity — same uuid first, then normalized email
  (the ETL collapse rule) — and emits the `add_scoped_member` calls that would
  cover it. `execute/2` runs the plan through the PUBLIC write path
  (Noizu.PM.Authz.ScopedMemberships.add_member, sole-owner-aware stored proc),
  logs every insert, and is idempotent: re-planning after a run finds nothing.
  """

  import Ecto.Query
  require Logger

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.ScopedMembership, as: AppSchema

  def plan do
    app_rows = app_user_rows()
    {pm_memberships, pm_users} = pm_state()

    pm_keys =
      MapSet.new(pm_memberships, fn {rt, rid, mid} ->
        {rt, to_string(rid), to_string(mid)}
      end)

    pm_users_by_id = MapSet.new(pm_users, fn {id, _email} -> to_string(id) end)

    pm_id_by_email =
      pm_users
      |> Enum.reject(fn {_id, email} -> not is_binary(email) or email == "" end)
      |> Map.new(fn {id, email} -> {normalize(email), to_string(id)} end)

    {actions, unmatched, already} =
      app_rows
      |> Enum.reduce({[], [], 0}, fn row, {actions, unmatched, already} ->
        rt = row.resource_type
        rid = to_string(row.resource_id)
        mid = to_string(row.member_id)

        cond do
          MapSet.member?(pm_keys, {rt, rid, mid}) ->
            {actions, unmatched, already + 1}

          MapSet.member?(pm_users_by_id, mid) ->
            {[mk_action(row, mid, :id) | actions], unmatched, already}

          pm_id = pm_email_lookup(row, pm_id_by_email) ->
            if MapSet.member?(pm_keys, {rt, rid, pm_id}) do
              {actions, unmatched, already + 1}
            else
              {[mk_action(row, pm_id, :email) | actions], unmatched, already}
            end

          true ->
            {actions,
             [
               row
               |> Map.take([:id, :resource_type, :resource_id, :member_id, :role, :email])
               |> Map.put(:reason, :no_pm_user)
               | unmatched
             ], already}
        end
      end)

    %{
      total_app_user_rows: length(app_rows),
      already_present: already,
      planned: length(actions),
      actions: Enum.reverse(actions),
      unmatched: Enum.reverse(unmatched)
    }
  end

  @doc """
  Execute a plan. Returns {inserted_count, skipped} — every insert goes through
  Noizu.PM.Authz.ScopedMemberships.add_member (sole-owner-aware) and is logged.
  An `already member` outcome counts as skipped, so repeats converge to 0.
  """
  def execute(%{actions: actions}, actor_id) do
    {inserted, skipped, errors} =
      Enum.reduce(actions, {0, 0, []}, fn action, {ins, skip, errs} ->
        case Noizu.PM.Authz.ScopedMemberships.add_member(
               action.resource_type,
               action.resource_id,
               action.pm_user_id,
               action.role,
               actor_id
             ) do
          {:ok, _} ->
            Logger.info(
              "PMBackfill insert: #{action.resource_type} #{action.resource_id} " <>
                "member=#{action.pm_user_id} (via #{action.via}) role=#{action.role} " <>
                "source_membership=#{action.source_membership_id}"
            )

            {ins + 1, skip, errs}

          {:error, :already_member} ->
            {ins, skip + 1, errs}

          {:error, other} ->
            Logger.warning(
              "PMBackfill failed: #{action.resource_type} #{action.resource_id} " <>
                "member=#{action.pm_user_id}: #{inspect(other)}"
            )

            {ins, skip,
             [
               Map.take(action, [:resource_type, :resource_id, :pm_user_id, :role])
               |> Map.put(:error, inspect(other))
               | errs
             ]}
        end
      end)

    %{inserted: inserted, skipped: skipped, errors: Enum.reverse(errors)}
  end

  defp mk_action(row, pm_user_id, via) do
    %{
      resource_type: row.resource_type,
      resource_id: row.resource_id,
      pm_user_id: pm_user_id,
      role: row.role,
      via: via,
      email: row.email,
      source_membership_id: row.id
    }
  end

  defp pm_email_lookup(%{email: email}, pm_id_by_email) when is_binary(email) do
    Map.get(pm_id_by_email, normalize(email))
  end

  defp pm_email_lookup(_, _), do: nil

  defp normalize(email), do: String.downcase(email, :ascii)

  defp app_user_rows do
    from(sm in AppSchema,
      join: g in NoizuPromptLingua.Schema.Authz.Group,
      on: g.id == sm.group_id,
      left_join: u in NoizuPromptLingua.Schema.Users.User,
      on: u.id == sm.member_id,
      where: sm.member_type == "user",
      where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
      select: %{
        id: sm.id,
        resource_type: sm.resource_type,
        resource_id: sm.resource_id,
        member_id: sm.member_id,
        role: g.name,
        email: u.email
      }
    )
    |> Repo.all()
  end

  defp pm_state do
    NoizuPromptLingua.PMCore.with_pm(fn ->
      memberships =
        from(sm in Noizu.PM.Schema.Authz.ScopedMembership,
          where: sm.member_type == "user",
          where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
          select: {sm.resource_type, sm.resource_id, sm.member_id}
        )
        |> Noizu.PM.Repo.all()

      users =
        from(u in Noizu.PM.Schema.Users.User, select: {u.id, u.email})
        |> Noizu.PM.Repo.all()

      {memberships, users}
    end)
  end
end
