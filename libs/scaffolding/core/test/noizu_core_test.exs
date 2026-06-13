defmodule Noizu.CoreTest do
  use ExUnit.Case
  require Noizu.Context.Records
  import Noizu.Context.Records
  
  test "new context" do
    a = context() = Noizu.Context.system()
  end
  
  test "context option" do
    sut = Noizu.Context.system()
        |> Noizu.Context.with_option(:apple, 5)
    actual = Noizu.Context.option(sut, :apple)
    assert {:ok, 5} == actual
    
    actual = Noizu.Context.option(sut, :bapple, 7)
    assert {:ok, 7} == actual
  end
  
  
end
