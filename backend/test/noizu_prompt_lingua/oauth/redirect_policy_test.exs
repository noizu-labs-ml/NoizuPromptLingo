defmodule NoizuPromptLingua.OAuth.RedirectPolicyTest do
  @moduledoc """
  `OAuth.RedirectPolicy` — gap coverage beyond pkce_and_redirect_test:
  custom-pattern override, bare-loopback shape, and the guard clauses.
  """

  use ExUnit.Case, async: false

  alias NoizuPromptLingua.OAuth.RedirectPolicy

  setup do
    prev = Application.get_env(:noizu_prompt_lingua, :mcp_oauth)

    on_exit(fn ->
      if prev,
        do: Application.put_env(:noizu_prompt_lingua, :mcp_oauth, prev),
        else: Application.delete_env(:noizu_prompt_lingua, :mcp_oauth)
    end)

    Application.delete_env(:noizu_prompt_lingua, :mcp_oauth)
    :ok
  end

  test "bare loopback (no trailing slash) is allowed for registration" do
    assert RedirectPolicy.allowed_for_registration?("http://localhost:8080")
    assert RedirectPolicy.allowed_for_registration?("http://127.0.0.1")
  end

  test "subdomain Claude.ai origins are allowed" do
    assert RedirectPolicy.allowed_for_registration?("https://console.claude.ai/oauth/callback")
  end

  test "non-allowlisted and non-binary URIs are rejected" do
    refute RedirectPolicy.allowed_for_registration?("https://evil.example/callback")
    refute RedirectPolicy.allowed_for_registration?("http://10.0.0.1:3000/")
    refute RedirectPolicy.allowed_for_registration?(nil)
    refute RedirectPolicy.allowed_for_registration?(42)
  end

  test "custom redirect_uri_patterns override the defaults entirely" do
    Application.put_env(:noizu_prompt_lingua, :mcp_oauth, redirect_uri_patterns: [~r/whatever/])

    assert RedirectPolicy.allowed_for_registration?("whatever://anything")
    refute RedirectPolicy.allowed_for_registration?("https://claude.ai/callback")
  end

  test "an empty custom pattern list falls back to the defaults" do
    Application.put_env(:noizu_prompt_lingua, :mcp_oauth, redirect_uri_patterns: [])
    assert RedirectPolicy.allowed_for_registration?("https://chatgpt.com/agent")
  end

  test "registered? guards: non-list client URIs or non-binary redirect are false" do
    assert RedirectPolicy.registered?(["https://x/y"], "https://x/y")
    refute RedirectPolicy.registered?([], "https://x/y")
    refute RedirectPolicy.registered?(nil, "https://x/y")
    refute RedirectPolicy.registered?(["https://x/y"], 42)
  end
end
