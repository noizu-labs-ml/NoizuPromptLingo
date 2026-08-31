defmodule DocPointers.HieroglyphTest do
  use ExUnit.Case, async: true

  alias DocPointers.{Hieroglyph, UUID5}

  describe "encode/1" do
    test "golden test vector — matches Rust CLI pact" do
      uuid_bytes = UUID5.generate("doc-pointers:TestPointer")
      token = Hieroglyph.encode(uuid_bytes)

      assert token == "𓳔𔐮𔘟𔄵"
    end

    test "produces exactly 4 characters" do
      uuid_bytes = UUID5.generate("any-name")
      token = Hieroglyph.encode(uuid_bytes)

      assert String.length(token) == 4
    end

    test "all characters are in valid hieroglyph ranges" do
      uuid_bytes = UUID5.generate("range-check")
      token = Hieroglyph.encode(uuid_bytes)

      for <<cp::utf8 <- token>> do
        assert in_valid_range?(cp),
               "Codepoint U+#{Integer.to_string(cp, 16)} not in any valid range"
      end
    end

    test "deterministic — same input produces same token" do
      a = Hieroglyph.encode(UUID5.generate("same"))
      b = Hieroglyph.encode(UUID5.generate("same"))
      assert a == b
    end

    test "different UUIDs produce different tokens (usually)" do
      a = Hieroglyph.encode(UUID5.generate("alpha"))
      b = Hieroglyph.encode(UUID5.generate("beta"))
      refute a == b
    end
  end

  describe "token_size/0" do
    test "returns 5744" do
      assert Hieroglyph.token_size() == 5744
    end
  end

  describe "marker/1" do
    test "wraps token in bracket pair" do
      assert Hieroglyph.marker("𓳔𔐮𔘟𔄵") == "⟦𓳔𔐮𔘟𔄵⟧"
    end
  end

  describe "declaration/3" do
    test "formats declaration line" do
      result = Hieroglyph.declaration("𓳔𔐮𔘟𔄵", "login", "Authenticates users")
      assert result == "⟦𓳔𔐮𔘟𔄵⟧ login :: Authenticates users"
    end
  end

  defp in_valid_range?(cp) do
    (cp >= 0x10980 and cp <= 0x1099F) or
      (cp >= 0x13000 and cp <= 0x1342F) or
      (cp >= 0x13460 and cp <= 0x143FF) or
      (cp >= 0x14400 and cp <= 0x1467F)
  end
end
