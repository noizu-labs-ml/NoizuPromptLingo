defmodule NoizuPromptLingua.Domains.MockMCP.ModelsTest do
  use ExUnit.Case, async: true

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
end
