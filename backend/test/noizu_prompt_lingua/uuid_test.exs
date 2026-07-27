defmodule NoizuPromptLingua.UUIDTest do
  @moduledoc """
  The id-or-slug discriminator. Regression coverage for a 404-on-an-existing-
  record bug that, in this app, locked any organization with a 16-character
  slug out of the entire multi-tenant API.
  """
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.UUID

  describe "uuid?/1" do
    test "accepts the canonical 36-character string" do
      assert UUID.uuid?(Ecto.UUID.generate())
      assert UUID.uuid?("b504ea61-b4bc-4fc8-bad6-300dd51fa1e0")
    end

    test "REJECTS a 16-character slug" do
      # The whole bug in one assertion. `Ecto.UUID.cast/1` also accepts a raw
      # 16-byte binary, so it reads these as UUIDs — see the misparse pinned
      # below. Every id-or-slug resolver then takes the `id ==` branch against
      # a value that is really a slug, matches nothing, and 404s on a record
      # that exists. Only at exactly sixteen characters; fifteen and seventeen
      # are fine, which is why it looked like flakiness rather than a bug.
      assert byte_size("acme-corporation") == 16
      refute UUID.uuid?("acme-corporation")
      refute UUID.uuid?("sixteen-char-abc")
      refute UUID.uuid?("0123456789abcdef")
    end

    test "rejects slugs either side of sixteen characters, for symmetry" do
      assert byte_size("acme-corporatio") == 15
      assert byte_size("acme-corporations") == 17
      refute UUID.uuid?("acme-corporatio")
      refute UUID.uuid?("acme-corporations")
    end

    test "rejects ordinary slugs, empty strings and non-binaries" do
      refute UUID.uuid?("my-organization")
      refute UUID.uuid?("")
      refute UUID.uuid?(nil)
      refute UUID.uuid?(42)
      refute UUID.uuid?(:atom)
    end

    test "rejects a 36-character string that is not actually a UUID" do
      # Right length, wrong content — length alone is not the test.
      assert byte_size(String.duplicate("z", 36)) == 36
      refute UUID.uuid?(String.duplicate("z", 36))
    end
  end

  describe "cast/1" do
    test "passes through the canonical 36-character string" do
      uuid = Ecto.UUID.generate()
      assert UUID.cast(uuid) == {:ok, uuid}
    end

    test "REJECTS the 16-character slug that Ecto.UUID.cast/1 accepts" do
      assert UUID.cast("acme-corporation") == :error
    end

    test "rejects ordinary slugs and non-binaries" do
      assert UUID.cast("my-organization") == :error
      assert UUID.cast(nil) == :error
      assert UUID.cast(42) == :error
    end
  end

  describe "the upstream behaviour this module exists to correct" do
    test "Ecto.UUID.cast/1 really does reinterpret a 16-character slug" do
      # Pinned so that if Ecto ever tightens cast/1, this test tells us the
      # guard has become redundant rather than silently keeping dead code.
      # This is the exact misparse that produced the production 404s.
      assert Ecto.UUID.cast("acme-corporation") ==
               {:ok, "61636d65-2d63-6f72-706f-726174696f6e"}

      # ...and that the neighbours really are rejected, which is why the bug
      # presented as an intermittent flake rather than a systematic failure.
      assert Ecto.UUID.cast("acme-corporatio") == :error
      assert Ecto.UUID.cast("acme-corporations") == :error
    end
  end
end
