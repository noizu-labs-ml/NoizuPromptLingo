defmodule NoizuPromptLingua.EntityUIDConcurrencyTest do
  use NoizuPromptLingua.DataCase

  @moduledoc """
  Regression for noizu_labs_entities <= 0.3.1, whose only UID provider
  (`Noizu.Entity.UID.Stub`) returned `{ms, 0}`: two `id(:uuid)` entities of the
  same repo minted in the same millisecond got the same id and the second insert
  hit `versioned_strings_pkey`. 0.3.2 defaults to `Noizu.Entity.UID.Default`
  (timestamp + random + monotonic index); 0.3.4 also makes the ids round-trip.
  """

  alias NoizuPromptLingua.Versioned.Strings

  @ctx Noizu.Context.system()
  @count 50

  test "concurrent entity creates all succeed with unique ids" do
    # Shared sandbox (DataCase is not async here), so spawned tasks use the
    # test's connection; inserts still mint ids concurrently in the same ms.
    results =
      1..@count
      |> Task.async_stream(fn i -> Strings.create(%{"content" => "uid-race-#{i}"}, @ctx) end,
        max_concurrency: @count,
        ordered: false
      )
      |> Enum.map(fn {:ok, result} -> result end)

    assert Enum.all?(results, &match?({:ok, _}, &1)),
           inspect(Enum.reject(results, &match?({:ok, _}, &1)))

    ids = Enum.map(results, fn {:ok, string} -> string.id end)
    assert length(Enum.uniq(ids)) == @count

    # Round trip: 0.3.2 minted an uppercase uuid tail, so the id an entity was
    # created with differed from the (lowercase) id Postgres hands back.
    for {:ok, created} <- results do
      assert {:ok, fetched} = Strings.get_versioned_string(created.id, @ctx)
      assert fetched.id == created.id
    end

    listed = MapSet.new(Strings.list(@ctx), & &1.id)
    assert Enum.all?(ids, &MapSet.member?(listed, &1))
  end
end
