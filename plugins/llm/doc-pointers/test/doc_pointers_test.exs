defmodule DocPointersTest do
  use ExUnit.Case

  alias DocPointers.{UUID5, Hieroglyph}

  test "end-to-end: UUID5 → hieroglyph golden vector" do
    uuid_bytes = UUID5.generate("doc-pointers:TestPointer")
    assert UUID5.to_string(uuid_bytes) == "5c692577-ad0c-51f1-992c-759b5e5fffb5"
    assert Hieroglyph.encode(uuid_bytes) == "𓳔𔐮𔘟𔄵"
  end
end
