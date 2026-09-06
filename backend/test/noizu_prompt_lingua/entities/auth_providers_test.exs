defmodule NoizuPromptLingua.AuthProvidersTest do
  use NoizuPromptLingua.DataCase

  @moduledoc """
  Auth provider context (entities/auth/providers.ex): the Noizu.Repo CRUD
  template (attrs / entity / changeset create clauses, update/4, delete/3),
  change/2 mapping, and the deterministic Authentik ref.
  """

  alias NoizuPromptLingua.Auth.Providers

  @ctx Noizu.Context.system()

  defp create_provider!(title) do
    {:ok, provider} =
      Providers.create(
        %{
          "title" => title,
          "description" => "SSO via Authentik",
          "settings" => %{"base_url" => "https://auth.example.com"},
          "unknown" => "dropped"
        },
        @ctx
      )

    provider
  end

  test "create/3 attrs path maps string keys and persists" do
    provider = create_provider!("Attrs Path")

    assert provider.title == "Attrs Path"
    assert provider.settings == %{"base_url" => "https://auth.example.com"}
  end

  test "create/3 entity and changeset clauses" do
    entity = %NoizuPromptLingua.Auth.Providers.Provider{
      id: Ecto.UUID.generate(),
      title: "Entity Path"
    }

    assert {:ok, via_entity} = Providers.create(entity, @ctx)
    assert via_entity.title == "Entity Path"

    cs =
      Providers.change(%NoizuPromptLingua.Auth.Providers.Provider{}, %{
        "id" => Ecto.UUID.generate(),
        "title" => "Changeset Path"
      })

    assert {:ok, via_cs} = Providers.create(cs, @ctx)
    assert via_cs.title == "Changeset Path"
  end

  test "update/4 routes through change/2 and persists" do
    provider = create_provider!("Before")

    assert {:ok, updated} =
             Providers.update(provider, %{"title" => "After", "description" => "d2"}, @ctx, [])

    assert updated.title == "After"
    assert updated.description == "d2"
    assert Providers.get_auth_provider(provider.id, @ctx) |> elem(0) == :ok
  end

  test "delete/3 removes the provider; list/2 reflects it" do
    provider = create_provider!("Doomed")

    assert Enum.any?(Providers.list(@ctx), &(&1.id == provider.id))

    assert {:ok, _} = Providers.delete(provider, @ctx)
    refute Enum.any?(Providers.list(@ctx), &(&1.id == provider.id))
  end

  test "change/2 maps known string keys, atom passthrough, drops unknowns" do
    cs =
      Providers.change(%NoizuPromptLingua.Auth.Providers.Provider{}, %{
        "title" => "T",
        "description" => "D",
        "settings" => %{"a" => 1},
        "id" => Ecto.UUID.generate(),
        "junk" => :x
      })

    assert %Ecto.Changeset{} = cs
    assert cs.changes.title == "T"
    assert cs.changes.description == "D"
    assert cs.changes.settings == %{"a" => 1}
    refute Map.has_key?(cs.changes, :junk)
  end

  test "authentik/0 is a stable, deterministic ref" do
    assert {:ok, ref} = Providers.authentik()
    assert {:ok, ref} == Providers.authentik()
    assert elem(ref, 1) == NoizuPromptLingua.Auth.Providers.Provider
  end
end
