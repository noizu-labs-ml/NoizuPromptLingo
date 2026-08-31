defmodule ExLiteLLM.Config.LoaderTest do
  use ExUnit.Case, async: true

  alias ExLiteLLM.Config
  alias ExLiteLLM.Config.Loader

  describe "from_map/1" do
    test "parses the four canonical sections + front_proxy" do
      {:ok, %Config{} = cfg} =
        Loader.from_map(%{
          "model_list" => [%{"model_name" => "gpt-4o"}],
          "litellm_settings" => %{"drop_params" => true},
          "router_settings" => %{"routing_strategy" => "simple-shuffle"},
          "general_settings" => %{"master_key" => "sk-abc"},
          "front_proxy" => %{"mode" => "standard"}
        })

      assert cfg.model_list == [%{"model_name" => "gpt-4o"}]
      assert cfg.litellm_settings["drop_params"] == true
      assert cfg.router_settings["routing_strategy"] == "simple-shuffle"
      assert cfg.general_settings["master_key"] == "sk-abc"
      assert cfg.front_proxy["mode"] == "standard"
    end

    test "resolves os.environ/ interpolation via the secret resolver" do
      System.put_env("EX_LITELLM_TEST_KEY", "resolved-secret")

      {:ok, cfg} =
        Loader.from_map(%{
          "model_list" => [
            %{"model_name" => "m", "litellm_params" => %{"api_key" => "os.environ/EX_LITELLM_TEST_KEY"}}
          ]
        })

      assert [%{"litellm_params" => %{"api_key" => "resolved-secret"}}] = cfg.model_list
    after
      System.delete_env("EX_LITELLM_TEST_KEY")
    end

    test "rejects a non-map config" do
      assert {:error, :config_not_a_map} = Loader.from_map("not a map")
    end
  end

  describe "Config helpers" do
    test "drop_params?/0 reads the active snapshot" do
      Config.put(%Config{litellm_settings: %{"drop_params" => true}})
      assert Config.drop_params?()
    end
  end
end
