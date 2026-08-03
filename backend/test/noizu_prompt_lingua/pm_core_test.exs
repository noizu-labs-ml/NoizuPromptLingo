defmodule NoizuPromptLingua.PMCoreTest do
  @moduledoc """
  Unit coverage for the dual-path gate used by Project List/Get and Resolve.

  These exercise the real `PMCore` module (no mocks): `enabled?/0`,
  `repo_configured?/0`, `with_pm/1`, and `ticket_attrs_to_item/1`.
  """
  use ExUnit.Case, async: false

  alias NoizuPromptLingua.PMCore

  setup do
    prev_pm_core = Application.get_env(:noizu_prompt_lingua, :pm_core)
    prev_pm_repo = Application.get_env(:noizu_labs_pm, Noizu.PM.Repo)
    prev_url = System.get_env("PM_CORE_DATABASE_URL")

    on_exit(fn ->
      restore_env(:noizu_prompt_lingua, :pm_core, prev_pm_core)
      restore_env(:noizu_labs_pm, Noizu.PM.Repo, prev_pm_repo)
      restore_system_env("PM_CORE_DATABASE_URL", prev_url)
    end)

    :ok
  end

  describe "enabled?/0" do
    test "defaults to true when unset or non-false" do
      Application.delete_env(:noizu_prompt_lingua, :pm_core)
      assert PMCore.enabled?()

      Application.put_env(:noizu_prompt_lingua, :pm_core, enabled: true)
      assert PMCore.enabled?()

      Application.put_env(:noizu_prompt_lingua, :pm_core, enabled: "true")
      assert PMCore.enabled?()
    end

    test "false / \"false\" / \"0\" / 0 disable" do
      for value <- [false, "false", "0", 0] do
        Application.put_env(:noizu_prompt_lingua, :pm_core, enabled: value)
        refute PMCore.enabled?(), "expected enabled?=false for #{inspect(value)}"
      end
    end
  end

  describe "repo_configured?/0" do
    test "true when PM_CORE_DATABASE_URL is a non-empty string" do
      System.put_env("PM_CORE_DATABASE_URL", "ecto://example/pm_core")
      Application.put_env(:noizu_labs_pm, Noizu.PM.Repo, types: Noizu.PM.PostgrexTypes)
      assert PMCore.repo_configured?()
    end

    test "true when Application config has :url or :database" do
      System.delete_env("PM_CORE_DATABASE_URL")

      Application.put_env(:noizu_labs_pm, Noizu.PM.Repo, url: "ecto://example/pm")
      assert PMCore.repo_configured?()

      Application.put_env(:noizu_labs_pm, Noizu.PM.Repo, database: "pm_core_test")
      assert PMCore.repo_configured?()
    end

    test "false when URL empty and config has neither :url nor :database" do
      System.delete_env("PM_CORE_DATABASE_URL")
      Application.put_env(:noizu_labs_pm, Noizu.PM.Repo, types: Noizu.PM.PostgrexTypes)
      refute PMCore.repo_configured?()
    end
  end

  describe "with_pm/1" do
    test "returns {:legacy, :pm_core_disabled} without calling fun when disabled" do
      Application.put_env(:noizu_prompt_lingua, :pm_core, enabled: false)
      System.put_env("PM_CORE_DATABASE_URL", "ecto://example/pm")

      assert {:legacy, :pm_core_disabled} =
               PMCore.with_pm(fn ->
                 flunk("fun must not run when pm_core is disabled")
               end)
    end

    test "returns {:legacy, :pm_core_unconfigured} without calling fun when unconfigured" do
      Application.put_env(:noizu_prompt_lingua, :pm_core, enabled: true)
      System.delete_env("PM_CORE_DATABASE_URL")
      Application.put_env(:noizu_labs_pm, Noizu.PM.Repo, types: Noizu.PM.PostgrexTypes)

      assert {:legacy, :pm_core_unconfigured} =
               PMCore.with_pm(fn ->
                 flunk("fun must not run when pm_core is unconfigured")
               end)
    end

    test "runs fun and returns its value when enabled and configured" do
      Application.put_env(:noizu_prompt_lingua, :pm_core, enabled: true)
      System.put_env("PM_CORE_DATABASE_URL", "ecto://example/pm")

      assert {:ok, :from_pm} = PMCore.with_pm(fn -> {:ok, :from_pm} end)
      assert [1, 2, 3] = PMCore.with_pm(fn -> [1, 2, 3] end)
    end
  end

  describe "ticket_attrs_to_item/1" do
    test "maps ticket_type to item_type and drops ticket_type keys" do
      assert %{item_type: "bug", title: "x"} =
               PMCore.ticket_attrs_to_item(%{ticket_type: "bug", title: "x"})

      assert %{item_type: "story", title: "y"} =
               PMCore.ticket_attrs_to_item(%{"ticket_type" => "story", title: "y"})
    end

    test "defaults item_type to task when no type keys present" do
      assert %{item_type: "task", title: "z"} =
               PMCore.ticket_attrs_to_item(%{title: "z"})
    end

    test "preserves existing item_type when ticket_type absent" do
      assert %{item_type: "epic"} = PMCore.ticket_attrs_to_item(%{item_type: "epic"})
      assert %{item_type: "epic"} = PMCore.ticket_attrs_to_item(%{"item_type" => "epic"})
    end
  end

  defp restore_env(app, key, nil), do: Application.delete_env(app, key)
  defp restore_env(app, key, value), do: Application.put_env(app, key, value)

  defp restore_system_env(name, nil), do: System.delete_env(name)
  defp restore_system_env(name, value), do: System.put_env(name, value)
end
