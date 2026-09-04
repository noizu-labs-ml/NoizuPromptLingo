defmodule NoizuPromptLingua.Domains.MockMCP.ModelsTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.MockMCP.Models

  test "all/0 returns selectable models with required keys" do
    models = Models.all()
    assert length(models) > 0

    Enum.each(models, fn m ->
      assert is_binary(m.id)
      assert is_binary(m.label)
      assert is_binary(m.provider)
      assert is_binary(m.model)
    end)
  end

  test "default_id/0 is a provider:model string" do
    assert Models.default_id() =~ ~r/^[a-z0-9_]+:.+/
  end

  test "resolve/1 maps a registry id to a GenAI model struct" do
    model = Models.resolve("anthropic:claude-sonnet-4-6")
    assert model.provider == GenAI.Provider.Anthropic
    assert model.model == "claude-sonnet-4-6"
  end

  test "resolve/3 maps provider/model pairs (openai + fallback)" do
    openai = Models.resolve("openai", "gpt-4o", nil)
    assert openai.provider == GenAI.Provider.OpenAI
    assert openai.model == "gpt-4o"

    # Unknown providers fall back to the OpenAI (chat/completions) shape.
    local = Models.resolve("local", "my-local-model", "http://localhost:1234")
    assert local.provider == GenAI.Provider.OpenAI
    assert local.model == "my-local-model"
  end

  test "resolve/1 falls back to the configured default for blank input" do
    assert %GenAI.Model{} = Models.resolve(nil)
    assert %GenAI.Model{} = Models.resolve("")
  end

  # ── editable catalog (llm_models table) ───────────────────────────────────

  defp valid_entry_attrs(suffix) do
    %{
      provider: "acme",
      model: "model-#{suffix}",
      label: "Acme · Model #{suffix}",
      sort_order: 99
    }
  end

  describe "catalog CRUD" do
    test "create/get/list/update/delete round trip" do
      attrs = valid_entry_attrs(System.unique_integer([:positive]))

      assert {:ok, entry} = Models.create_catalog_entry(attrs)
      assert entry.provider == "acme"
      assert Models.get_catalog_entry(entry.id).id == entry.id
      assert Enum.any?(Models.catalog(), &(&1.id == entry.id))

      assert {:ok, updated} = Models.update_catalog_entry(entry.id, %{label: "Renamed"})
      assert updated.label == "Renamed"

      assert {:ok, _} = Models.delete_catalog_entry(entry.id)
      assert Models.get_catalog_entry(entry.id) == nil
    end

    test "create rejects missing required fields" do
      assert {:error, cs} = Models.create_catalog_entry(%{provider: "acme"})
      refute cs.valid?
    end

    test "update/delete on unknown ids -> {:error, :not_found}" do
      assert {:error, :not_found} =
               Models.update_catalog_entry(Ecto.UUID.generate(), %{label: "x"})

      assert {:error, :not_found} = Models.delete_catalog_entry(Ecto.UUID.generate())
    end

    test "duplicate provider:model is rejected" do
      attrs = valid_entry_attrs(System.unique_integer([:positive]))
      assert {:ok, _} = Models.create_catalog_entry(attrs)
      assert {:error, cs} = Models.create_catalog_entry(attrs)
      refute cs.valid?
    end
  end

  test "all/0 serves the editable catalog when it has enabled rows" do
    attrs = valid_entry_attrs(System.unique_integer([:positive]))
    assert {:ok, entry} = Models.create_catalog_entry(attrs)

    ids = Enum.map(Models.all(), & &1.id)
    assert "#{entry.provider}:#{entry.model}" in ids
  end

  test "all/0 falls back to the seed list when no enabled rows exist" do
    attrs = valid_entry_attrs(System.unique_integer([:positive]))
    assert {:ok, entry} = Models.create_catalog_entry(attrs)
    assert {:ok, _} = Models.update_catalog_entry(entry.id, %{enabled: false})

    # the only catalog row is disabled -> seed fallback
    assert Enum.any?(Models.all(), &(&1.id == "openai:gpt-4o"))
  end

  test "resolve/3 maps every known provider to its genai module" do
    pairs = [
      {"anthropic", GenAI.Provider.Anthropic},
      {"openai", GenAI.Provider.OpenAI},
      {"deepseek", GenAI.Provider.DeepSeek},
      {"zai", GenAI.Provider.ZAI},
      {"cerebras", GenAI.Provider.Cerebras},
      {"gemini", GenAI.Provider.Gemini},
      {"xai", GenAI.Provider.XAI},
      {"groq", GenAI.Provider.Groq},
      {"litellm", GenAI.Provider.LiteLLM},
      {"openrouter", GenAI.Provider.OpenRouter},
      {"qwen", GenAI.Provider.Qwen}
    ]

    Enum.each(pairs, fn {provider, mod} ->
      model = Models.resolve(provider, "model-x", nil)
      assert model.provider == mod, "provider #{provider}"
      assert model.model == "model-x"
    end)
  end

  test "resolve/3 aliases grok to xai and unknown providers to OpenAI" do
    assert Models.resolve("grok", "grok-4", nil).provider == GenAI.Provider.XAI
    assert Models.resolve("mystery", "m1", "http://x").provider == GenAI.Provider.OpenAI
  end

  test "resolve/3 falls back to the configured default for blank models" do
    default = Models.default_id()
    [default_provider, default_model] = String.split(default, ":", parts: 2)

    model = Models.resolve("openai", "", nil)
    assert model.provider == GenAI.Provider.OpenAI
    assert model.model in [default_model, default_provider]

    assert %GenAI.Model{} = Models.resolve(nil, nil, nil)
  end

  test "provider_module/1 maps each provider string" do
    pairs = [
      {"anthropic", GenAI.Provider.Anthropic},
      {"deepseek", GenAI.Provider.DeepSeek},
      {"zai", GenAI.Provider.ZAI},
      {"cerebras", GenAI.Provider.Cerebras},
      {"gemini", GenAI.Provider.Gemini},
      {"xai", GenAI.Provider.XAI},
      {"grok", GenAI.Provider.XAI},
      {"groq", GenAI.Provider.Groq},
      {"litellm", GenAI.Provider.LiteLLM},
      {"openrouter", GenAI.Provider.OpenRouter},
      {"qwen", GenAI.Provider.Qwen},
      {"who-knows", GenAI.Provider.OpenAI}
    ]

    Enum.each(pairs, fn {provider, mod} ->
      assert Models.provider_module(provider) == mod, "provider #{provider}"
    end)
  end
end
