defmodule DocPointers.UUID5Test do
  use ExUnit.Case, async: true

  alias DocPointers.UUID5

  describe "generate/2" do
    test "golden test vector — matches Rust CLI pact" do
      name = "doc-pointers:TestPointer"
      uuid_bytes = UUID5.generate(name)
      uuid_string = UUID5.to_string(uuid_bytes)

      assert uuid_string == "5c692577-ad0c-51f1-992c-759b5e5fffb5"
    end

    test "produces version 5 UUID" do
      <<_::48, version::4, _::76>> = UUID5.generate("anything")
      assert version == 5
    end

    test "produces RFC 4122 variant" do
      <<_::64, variant::2, _::62>> = UUID5.generate("anything")
      assert variant == 2
    end

    test "deterministic — same input produces same output" do
      a = UUID5.generate("test-input")
      b = UUID5.generate("test-input")
      assert a == b
    end

    test "different inputs produce different outputs" do
      a = UUID5.generate("input-a")
      b = UUID5.generate("input-b")
      refute a == b
    end
  end

  describe "to_string/1 and from_string/1" do
    test "round-trips" do
      uuid_bytes = UUID5.generate("round-trip-test")
      uuid_string = UUID5.to_string(uuid_bytes)
      assert byte_size(uuid_string) == 36
      assert UUID5.from_string(uuid_string) == uuid_bytes
    end

    test "produces lowercase hyphenated format" do
      uuid_string = UUID5.to_string(UUID5.generate("format-test"))
      assert uuid_string =~ ~r/^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/
    end
  end

  describe "build_name/3" do
    test "basic name" do
      assert UUID5.build_name("MyFunction") == "doc-pointers:MyFunction"
    end

    test "with salt" do
      assert UUID5.build_name("MyFunction", "salt1") == "doc-pointers:MyFunction:salt1"
    end

    test "with attempt" do
      assert UUID5.build_name("MyFunction", nil, 3) == "doc-pointers:MyFunction:3"
    end

    test "with salt and attempt" do
      assert UUID5.build_name("MyFunction", "s", 2) == "doc-pointers:MyFunction:s:2"
    end

    test "nil salt is omitted" do
      assert UUID5.build_name("F", nil, 0) == "doc-pointers:F"
    end
  end

  describe "build_annotation_name/2" do
    test "formats as file_path::function_name" do
      assert UUID5.build_annotation_name("lib/auth.ex", "login") == "lib/auth.ex::login"
    end
  end
end
