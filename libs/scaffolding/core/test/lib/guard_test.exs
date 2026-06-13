# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.GuardTest do
  use ExUnit.Case, async: false

  defmodule Foo do
    defstruct vsn: 1.0
  end

  require Logger
  import Noizu.ElixirCore.Guards

  def obscure_hint(value), do: Application.get_env(:invalid_scope_noizu, :nnnn, value)

  @tag :guards
  test "is_ref guard" do
    assert is_ref({:ref, :module, 1234})
    assert !is_ref({:bannana, :module, 1234})
    assert !is_ref(%Foo{})
    assert !is_ref("ref.module.1234")
  end

  @tag :guards
  test "is_sref guard" do
    assert !is_sref({:ref, :module, 1234})
    assert !is_sref("raz.henry.1234")
    assert is_sref("ref.henry.1234")
  end

  @tag :guards
  test "entity_ref guard" do
    assert entity_ref(obscure_hint({:ref, :module, 1234}))
    assert entity_ref(obscure_hint("ref.henry.1234"))
    assert entity_ref(obscure_hint(%Foo{}))
    assert !entity_ref(obscure_hint("apple"))
    assert !entity_ref(obscure_hint(1234))
  end

  @tag :guards
  test "is_admin_caller guard" do
    assert is_admin_caller(Noizu.ElixirCore.CallingContext.admin())
    assert !is_admin_caller(Noizu.ElixirCore.CallingContext.system())
    assert !is_admin_caller(obscure_hint(nil))
  end

  @tag :guards
  test "is_system_caller guard" do
    assert is_system_caller(Noizu.ElixirCore.CallingContext.admin())
    assert is_system_caller(Noizu.ElixirCore.CallingContext.system())
    assert !is_system_caller(Noizu.ElixirCore.CallingContext.internal())
    assert !is_system_caller(obscure_hint(nil))
  end

  @tag :guards
  test "is_internal_caller guard" do
    assert is_internal_caller(Noizu.ElixirCore.CallingContext.admin())
    assert is_internal_caller(Noizu.ElixirCore.CallingContext.system())
    assert is_internal_caller(Noizu.ElixirCore.CallingContext.internal())
    assert !is_internal_caller(obscure_hint(%Noizu.ElixirCore.CallingContext{}))
    assert !is_internal_caller(obscure_hint(nil))
  end

  @tag :guards
  test "is_restricted_caller guard" do
    assert !is_restricted_caller(Noizu.ElixirCore.CallingContext.admin())
    assert !is_restricted_caller(Noizu.ElixirCore.CallingContext.system())
    assert !is_restricted_caller(Noizu.ElixirCore.CallingContext.internal())
    assert is_restricted_caller(Noizu.ElixirCore.CallingContext.restricted())
    assert is_restricted_caller(obscure_hint(%Noizu.ElixirCore.CallingContext{}))
    assert is_restricted_caller(obscure_hint(nil))
  end

  @tag :guards
  test "has_permission? guard" do
    c = %Noizu.ElixirCore.CallingContext{
      auth: %{permissions: %{:foobar => true, :boo => true, :orange => 2, {:a, :b} => true}}
    }

    assert permission?(c, :foobar)
    assert permission?(c, {:a, :b})
    assert !permission?(c, {:a, :c})
    assert permission?(c, :boo)
    assert !permission?(c, :buz)
    assert permission?(c, :orange, 2)
    assert !permission?(c, :orange, 3)
  end

  @tag :guards
  test "caller_set_reason? guard" do
    assert has_call_reason?(%Noizu.ElixirCore.CallingContext{reason: "Hello"})
    assert !has_call_reason?(%Noizu.ElixirCore.CallingContext{reason: nil})
    assert !has_call_reason?(obscure_hint(nil))
  end
end
