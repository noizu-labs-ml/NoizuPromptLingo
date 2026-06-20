defmodule NoizuPromptLingua.Domains.MockMCP.InternalOpsTest do
  @moduledoc """
  The agent's PRIVATE data ops. Redis is exercised for real (it's up in the test
  env); the DB path is checked for the unprovisioned guard (provisioning creates a
  real database, exercised in live smoke rather than the unit suite).
  """
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.Domains.MockMCP.InternalOps

  defp def_(provisioned? \\ false) do
    %{slug: "iops-#{System.unique_integer([:positive])}", db_provisioned: provisioned?, db_name: nil}
  end

  test "op?/1 recognises the data ops" do
    for op <- ~w(redis_get redis_set redis_del redis_keys db_query db_execute) do
      assert InternalOps.op?(op)
    end
    refute InternalOps.op?("echo")
  end

  test "available/1 reflects DB provisioning" do
    refute InternalOps.available(def_(false)) =~ "db_query"
    assert InternalOps.available(def_(false)) =~ "redis_get"
    assert InternalOps.available(def_(true)) =~ "db_query"
  end

  test "redis ops round-trip against the mock keyspace" do
    d = def_()
    key = "k-#{System.unique_integer([:positive])}"

    assert {:ok, %{"ok" => true}} = InternalOps.exec(d, "redis_set", %{"key" => key, "value" => "v1"})
    assert {:ok, %{"result" => "v1"}} = InternalOps.exec(d, "redis_get", %{"key" => key})
    assert {:ok, %{"result" => keys}} = InternalOps.exec(d, "redis_keys", %{"pattern" => "*"})
    assert key in keys
    assert {:ok, _} = InternalOps.exec(d, "redis_del", %{"key" => key})
    assert {:ok, %{"result" => nil}} = InternalOps.exec(d, "redis_get", %{"key" => key})
  end

  test "db ops error when no database is provisioned" do
    assert {:error, msg} = InternalOps.exec(def_(false), "db_query", %{"sql" => "SELECT 1"})
    assert msg =~ "no database provisioned"
  end

  test "unknown op is rejected" do
    assert {:error, _} = InternalOps.exec(def_(), "frobnicate", %{})
  end
end
