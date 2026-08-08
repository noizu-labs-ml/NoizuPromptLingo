defmodule NoizuPromptLingua.AuthzRoleRanksTest do
  @moduledoc """
  Drift guard for the ordinal role ladder (ADR-015). The Elixir @role_ranks map and the
  role_name_enum DB type MUST carry the same role names — a role present in one but not
  the other silently denies (authorize/4 ranks an unknown name at 99 = deny). This test
  fails loudly if they drift (e.g. a new tier added to one side only).
  """
  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.Authz

  @moduletag :db

  test "@role_ranks keys exactly match role_name_enum DB values" do
    %{rows: rows} =
      Repo.query!(
        "SELECT enumlabel FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid " <>
          "WHERE t.typname = 'role_name_enum'"
      )

    enum_values = rows |> List.flatten() |> MapSet.new()
    rank_keys = Authz.role_ranks() |> Map.keys() |> MapSet.new()

    assert rank_keys == enum_values,
           "role_name_enum #{inspect(MapSet.to_list(enum_values))} and @role_ranks " <>
             "#{inspect(MapSet.to_list(rank_keys))} have drifted"
  end

  test "'lead' ranks strictly between admin and member (ADR-015)" do
    r = Authz.role_ranks()
    assert r["owner"] < r["admin"]
    assert r["admin"] < r["lead"]
    assert r["lead"] < r["member"]
    assert r["member"] < r["viewer"]
  end
end
