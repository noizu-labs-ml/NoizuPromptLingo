defmodule NoizuPromptLingua.UsersContextTest do
  use NoizuPromptLingua.DataCase

  @moduledoc """
  Direct coverage of the Users context (entities/users.ex): name/handle
  validation helpers, handle generation with collision suffixing, change_user
  attribute mapping, and the Noizu.Repo list/get paths.

  NOTE (documented bug, not exercised): the `{"name", value}` branch of
  `change_user/2` calls `Versioned.Names.change_versioned_name/2`, which does
  not exist anywhere in the codebase — that branch would raise
  UndefinedFunctionError. Tests pin every other branch and leave the dead
  branch alone (report filed with the campaign lead).
  """

  alias NoizuPromptLingua.Users
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

  @ctx Noizu.Context.system()

  defp uniq, do: System.unique_integer([:positive])

  defp insert_user!(overrides \\ %{}) do
    n = uniq()

    %UserSchema{
      email: "uc-#{n}@example.com",
      user_name: "uc_user#{n}",
      handle: "uc_h#{n}",
      status: :active
    }
    |> Map.merge(overrides)
    |> Repo.insert!()
  end

  # ── valid_user_name? ─────────────────────────────────────────────

  test "valid_user_name? accepts letters/digits/underscore/dash up to 32 chars" do
    assert :valid = Users.valid_user_name?("keith_b-2")
    assert :valid = Users.valid_user_name?(String.duplicate("a", 32))
  end

  test "valid_user_name? rejects nil, empty, over-long and invalid characters" do
    assert {:error, {:user_name, :required}} = Users.valid_user_name?(nil)
    assert {:error, {:user_name, :required}} = Users.valid_user_name?("")
    assert {:error, {:user_name, :invalid}} = Users.valid_user_name?(String.duplicate("a", 33))
    assert {:error, {:user_name, :invalid}} = Users.valid_user_name?("bad name!")
    assert {:error, {:user_name, :invalid}} = Users.valid_user_name?("no.dots")
  end

  # ── valid_name? ──────────────────────────────────────────────────

  test "valid_name? requires first and last, allows nil middle" do
    assert :valid = Users.valid_name?("Ada", nil, "Lovelace")

    assert {:error, {:name, {:first, :required}}} = Users.valid_name?(nil, nil, "Last")
    assert {:error, {:name, {:first, :required}}} = Users.valid_name?("", nil, "Last")
    assert {:error, {:name, {:last, :required}}} = Users.valid_name?("Ada", nil, nil)
    assert {:error, {:name, {:last, :required}}} = Users.valid_name?("Ada", nil, "")
  end

  test "valid_name? middle list must hold only non-empty strings" do
    assert :valid = Users.valid_name?("Ada", ["M", "Q"], "Lovelace")

    assert {:error, {:name, {:middle, :invalid}}} = Users.valid_name?("Ada", "", "Lovelace")
    assert {:error, {:name, {:middle, :invalid}}} = Users.valid_name?("Ada", 42, "Lovelace")
  end

  # ── by_handle / user_name_available? ─────────────────────────────

  test "by_handle resolves an existing handle to {:ok, entity} and nil on a miss" do
    user = insert_user!()

    assert {:ok, entity} = Users.by_handle(user.handle, @ctx)
    assert entity.id == user.id

    assert nil == Users.by_handle("no-such-handle-#{uniq()}", @ctx)
  end

  test "user_name_available? flags registered names and accepts free ones" do
    user = insert_user!()

    assert {:error, {:user_name, :registered}} = Users.user_name_available?(user.user_name, @ctx)
    assert :valid = Users.user_name_available?("free_name#{uniq()}", @ctx)
  end

  # ── generate_handle ──────────────────────────────────────────────

  test "generate_handle builds first-initial + last and uniquifies on collision" do
    first = "Uc#{uniq()}"
    last = "Collision"
    base = String.slice(first, 0..1) <> String.slice(last, 0..32)

    assert {:ok, ^base} = Users.generate_handle({first, last}, @ctx)

    # Occupy the base handle; the next generation must suffix 000.
    insert_user!(%{handle: base})
    assert {:ok, suffixed} = Users.generate_handle({first, last}, @ctx)
    assert suffixed == base <> "000"
  end

  # ── change_user ──────────────────────────────────────────────────

  test "change_user maps string keys to entity changes and drops unknowns" do
    entity = struct(NoizuPromptLingua.Users.User, id: Ecto.UUID.generate(), user_name: "old")

    cs =
      Users.change_user(entity, %{
        "user_name" => "new_name",
        "handle" => "new_handle",
        "status" => "suspended",
        "verified" => "true",
        "flagged" => "false",
        "id" => entity.id,
        :bio => "from atom key",
        "totally_unknown" => "dropped"
      })

    assert %Ecto.Changeset{} = cs
    assert cs.changes.user_name == "new_name"
    assert cs.changes.handle == "new_handle"
    # NOTE: :email is NOT in the entity's changeset_fields meta — a change_user
    # email key is silently dropped (pinned current behavior).
    assert cs.changes.verified == true
    assert cs.changes.flagged == false
    assert cs.changes.bio == "from atom key"
    refute Map.has_key?(cs.changes, :totally_unknown)
  end

  test "change_user stringifies status via existing atoms" do
    entity = %NoizuPromptLingua.Users.User{}
    cs = Users.change_user(entity, %{"status" => "waitlist"})
    assert cs.changes.status == :waitlist
  end

  # ── Noizu.Repo list/get paths ────────────────────────────────────

  test "list/2 returns entities for every row" do
    user = insert_user!()
    entities = Users.list(@ctx)
    assert Enum.any?(entities, &(&1.id == user.id))
  end

  test "get_user resolves by id and misses cleanly" do
    user = insert_user!()

    assert {:ok, entity} = Users.get_user(user.id, @ctx)
    assert entity.id == user.id

    refute match?({:ok, _}, Users.get_user(Ecto.UUID.generate(), @ctx))
  end
end
