defmodule ExLiteLLM.RouterTest do
  # Not async: mutates the shared Router GenServer + persistent_term registry.
  use ExUnit.Case, async: false

  alias ExLiteLLM.Router
  alias ExLiteLLM.Router.CooldownCache

  setup do
    # Start from a clean registry for each test.
    Router.set_deployments([])
    :ok
  end

  describe "add/delete/update lifecycle" do
    test "add assigns a model_id and makes the deployment selectable" do
      {:ok, stored} =
        Router.add_deployment(%{
          "model_name" => "m1",
          "litellm_params" => %{"model" => "openai/gpt-4o"}
        })

      assert is_binary(stored["model_id"])
      assert {:ok, %{"model_name" => "m1"}} = Router.select("m1")
    end

    test "delete removes it" do
      {:ok, stored} = Router.add_deployment(%{"model_name" => "m2", "litellm_params" => %{}})
      assert :ok = Router.delete_deployment(stored["model_id"])
      assert {:error, :no_deployment} = Router.select("m2")
    end

    test "delete of unknown id → not_found" do
      assert {:error, :not_found} = Router.delete_deployment("nope")
    end

    test "update merges litellm_params" do
      {:ok, stored} =
        Router.add_deployment(%{"model_name" => "m3", "litellm_params" => %{"model" => "x", "api_base" => "a"}})

      {:ok, updated} =
        Router.update_deployment(stored["model_id"], %{"litellm_params" => %{"api_base" => "b"}})

      assert updated["litellm_params"]["api_base"] == "b"
      assert updated["litellm_params"]["model"] == "x"
    end
  end

  describe "selection + cooldown" do
    test "select returns the sole deployment in a group" do
      Router.add_deployment(%{"model_name" => "solo", "litellm_params" => %{}})
      assert {:ok, %{"model_name" => "solo"}} = Router.select("solo")
    end

    test "cooled-down deployments are skipped when alternatives exist" do
      {:ok, a} = Router.add_deployment(%{"model_name" => "g", "litellm_params" => %{"model" => "a"}})
      {:ok, _b} = Router.add_deployment(%{"model_name" => "g", "litellm_params" => %{"model" => "b"}})

      CooldownCache.add(a["model_id"], :boom, 60_000)

      # Every selection should avoid the cooled-down "a" and return "b".
      for _ <- 1..10 do
        {:ok, picked} = Router.select("g")
        assert picked["litellm_params"]["model"] == "b"
      end

      CooldownCache.clear(a["model_id"])
    end

    test "when all are cooled down, selection still returns one (fail-open)" do
      {:ok, a} = Router.add_deployment(%{"model_name" => "solo2", "litellm_params" => %{}})
      CooldownCache.add(a["model_id"], :boom, 60_000)

      assert {:ok, %{"model_name" => "solo2"}} = Router.select("solo2")
      CooldownCache.clear(a["model_id"])
    end
  end
end
