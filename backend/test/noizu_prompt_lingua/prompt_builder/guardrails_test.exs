defmodule NoizuPromptLingua.PromptBuilder.GuardrailsTest do
  @moduledoc """
  Purpose-lock guardrails: input heuristic + model-judge gate and the output
  validator. Judge replies are scripted through the Stub generator queue.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.PromptBuilder.Guardrails

  @npl_prompt """
  ⌜NPL@1.0⌝
  :persona: "Senior Elixir Reviewer"
  :syntax
  @directive: review the module
  ⌞NPL@1.0⌟
  """

  describe "classify_input/1" do
    test "rejects blank and tiny inputs outright" do
      assert Guardrails.classify_input(nil) == :reject
      assert Guardrails.classify_input("") == :reject
      assert Guardrails.classify_input("   ") == :reject
      assert Guardrails.classify_input("hi") == :reject
    end

    test "flags question-shaped input for the judge" do
      assert Guardrails.classify_input("What is the capital of France?") == :needs_judge
      assert Guardrails.classify_input("Tell me a joke") == :needs_judge
    end

    test "prompt-shaped input still goes to the judge (defense in depth)" do
      assert Guardrails.classify_input("Build a prompt for a code reviewer agent") == :needs_judge
    end
  end

  describe "is_prompt_request?/1 — model judge with strict JSON" do
    test "accepts when the judge verdict is true" do
      Process.put(:pb_stub_replies, [{:text, ~s({"prompt_request": true, "reason": "builds a prompt"})}])
      assert {:ok, :prompt_request} = Guardrails.is_prompt_request?("Build a reviewer prompt")
    end

    test "rejects when the judge verdict is false" do
      Process.put(:pb_stub_replies, [{:text, ~s({"prompt_request": false, "reason": "general question"})}])
      assert {:error, :not_prompt_request} = Guardrails.is_prompt_request?("What is NPL?")
    end

    test "fails closed on unparseable judge output" do
      Process.put(:pb_stub_replies, [{:text, "I think this is a great prompt request!"}])
      assert {:error, {:judge_failed, :unparseable_verdict}} = Guardrails.is_prompt_request?("Build a prompt")
    end

    test "fails closed on judge transport errors" do
      Process.put(:pb_stub_replies, [{:error, :boom}])
      assert {:error, {:judge_failed, :boom}} = Guardrails.is_prompt_request?("Build a prompt")
    end

    test "rejects obviously conversational input without spending the judge" do
      assert {:error, :not_prompt_request} = Guardrails.is_prompt_request?("")
      # No stub queued — if the judge were consulted it would fall back to the
      # echo reply (still not JSON → fail-closed), so assert nothing queued is
      # consumed by construction: short input is pre-rejected.
    end
  end

  describe "validate_output/1" do
    test "accepts NPL-structured prompts" do
      assert {:ok, _} = Guardrails.validate_output(@npl_prompt)
    end

    test "strips code fences around an NPL prompt" do
      fenced = "```text\n" <> @npl_prompt <> "```"
      assert {:ok, body} = Guardrails.validate_output(fenced)
      assert body =~ "⌜NPL@1.0⌝"
    end

    test "rejects refusals" do
      assert {:error, :invalid_output} = Guardrails.validate_output("I'm sorry, I can't help with that.")
      assert {:error, :invalid_output} = Guardrails.validate_output("As an AI language model, I cannot do that.")
    end

    test "rejects plain conversational answers with no NPL structure" do
      assert {:error, :invalid_output} =
               Guardrails.validate_output("The capital of France is Paris, a city known for its art.")
    end

    test "strips a chatty opener and keeps the NPL body" do
      chatty = "Sure, here's a prompt for you:\n" <> @npl_prompt
      assert {:ok, body} = Guardrails.validate_output(chatty)
      assert body =~ "⌜NPL@1.0⌝"
    end

    test "rejects empty output" do
      assert {:error, :invalid_output} = Guardrails.validate_output("   ")
    end
  end

  test "retry_system_suffix instructs prompt-only output" do
    assert Guardrails.retry_system_suffix() =~ "ONLY the NPL prompt text"
  end

  test "judge adapter crash fails closed (no raise to 422 upstream)" do
    original = Application.get_env(:noizu_prompt_lingua, :prompt_builder)

    Application.put_env(:noizu_prompt_lingua, :prompt_builder,
      generator: NoizuPromptLingua.PromptBuilder.Generator.DoesNotExist
    )

    try do
      assert {:error, {:judge_failed, _}} = Guardrails.is_prompt_request?("Build a reviewer prompt")
    after
      if original,
        do: Application.put_env(:noizu_prompt_lingua, :prompt_builder, original),
        else: Application.delete_env(:noizu_prompt_lingua, :prompt_builder)
    end
  end
end
