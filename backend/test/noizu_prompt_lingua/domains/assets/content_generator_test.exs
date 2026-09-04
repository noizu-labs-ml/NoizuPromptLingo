defmodule NoizuPromptLingua.Domains.Assets.ContentGeneratorTest do
  @moduledoc """
  ContentGenerator — .media.prompt YAML -> LLM content generation.

  The provider boundary is the `:httpc.request` call inside `do_call_llm`; it is
  stubbed at that boundary with a local Bandit/Plug OpenAI-compatible endpoint
  (no stub libs in the repo, bandit ships with Phoenix). The stub server runs on
  an ephemeral 127.0.0.1 port; tests select behavior via the URL path and the
  `/echo` mode bounces the request body + auth headers back as the completion
  content so the exact payload the generator builds can be asserted on.

  FIM reference loading is exercised against the real priv/skills
  content-generator references; provider resolution against System env keys
  (put/delete with on_exit restore; async: false because env is global).
  """

  use ExUnit.Case, async: false

  alias NoizuPromptLingua.Domains.Assets.ContentGenerator

  # Minimal OpenAI-compatible completions endpoint. Behavior by path segment:
  #   /ok        200 + valid choices payload ("GENERATED", padded to test trim)
  #   /echo      200 + content = JSON of the request body and auth headers
  #   /badjson   200 + unexpected JSON shape (no choices)
  #   /status500 500 + body "kaboom"
  defmodule StubLLM do
    def init(opts), do: opts

    def call(conn, _opts) do
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      headers = Map.new(conn.req_headers)

      case List.last(conn.path_info) do
        "ok" ->
          json(conn, 200, %{"choices" => [%{"message" => %{"content" => "  GENERATED  "}}]})

        "echo" ->
          content =
            Jason.encode!(%{
              "body" => Jason.decode!(body),
              "authorization" => headers["authorization"],
              "x_api_key" => headers["x-api-key"],
              "anthropic_version" => headers["anthropic-version"]
            })

          json(conn, 200, %{"choices" => [%{"message" => %{"content" => content}}]})

        "badjson" ->
          json(conn, 200, %{"nope" => true})

        "status500" ->
          conn
          |> Plug.Conn.put_resp_content_type("text/plain")
          |> Plug.Conn.resp(500, "kaboom")
      end
    end

    defp json(conn, status, payload) do
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(status, Jason.encode!(payload))
    end
  end

  setup do
    for key <- ["OPENAI_API_KEY", "ANTHROPIC_API_KEY", "XAI_API_KEY"] do
      System.put_env(key, "test-key-#{String.downcase(key)}")
      on_exit(fn -> System.delete_env(key) end)
    end

    {:ok, port} = start_stub_server()
    {:ok, base: "http://127.0.0.1:#{port}", port: port}
  end

  # Bind to an ephemeral port, then hand it to Bandit. Tiny TOCTOU window is
  # acceptable for a local test server.
  defp start_stub_server do
    {:ok, sock} = :gen_tcp.listen(0, ip: {127, 0, 0, 1})
    {:ok, port} = :inet.port(sock)
    :gen_tcp.close(sock)

    {:ok, pid} =
      Bandit.start_link(plug: StubLLM, scheme: :http, ip: {127, 0, 0, 1}, port: port)

    on_exit(fn ->
      if Process.alive?(pid), do: Process.exit(pid, :shutdown)
    end)

    {:ok, port}
  end

  # ---------------------------------------------------------------------------
  # generate/2 — YAML parsing
  # ---------------------------------------------------------------------------

  describe "generate/2 yaml parsing" do
    test "invalid YAML -> yaml_parse_error" do
      assert {:error, {:yaml_parse_error, _}} = ContentGenerator.generate("{ not: [valid")
    end

    test "valid YAML routes into generation (error from provider surfaces unchanged)" do
      # Type unknown to FIM maps -> empty context; unknown provider -> localhost
      # fallback; the refused connection error propagates as request_failed.
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"
      assert {:error, {:request_failed, _}} = ContentGenerator.generate(yaml, endpoint: dead_url())
    end
  end

  # ---------------------------------------------------------------------------
  # generate/2 — provider resolution (all resolve_provider clauses)
  # ---------------------------------------------------------------------------

  describe "generate/2 provider resolution" do
    test "unknown provider falls back to keyless localhost-compatible endpoint", %{base: base} do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"
      opts = [provider: "local-model", endpoint: base <> "/echo", model: "llama-local"]

      assert {:ok, content} = ContentGenerator.generate(yaml, opts)
      assert %{"body" => body, "authorization" => nil, "x_api_key" => nil} = Jason.decode!(content)
      assert body["model"] == "llama-local"
    end

    test "unknown provider without model defaults model to 'default', endpoint to localhost" do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"

      # No endpoint opt: default localhost:1234 (not running) -> connection refused.
      assert {:error, {:request_failed, {:failed_connect, _}}} =
               ContentGenerator.generate(yaml, provider: "local-model")
    end

    test "openai provider sends bearer auth and defaults the model", %{base: base} do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"
      opts = [provider: "openai", endpoint: base <> "/echo"]

      assert {:ok, content} = ContentGenerator.generate(yaml, opts)
      decoded = Jason.decode!(content)
      assert decoded["authorization"] == "Bearer test-key-openai_api_key"
      assert decoded["body"]["model"] == "gpt-4o-mini"
    end

    test "openai-prefixed provider names share the openai clause", %{base: base} do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"
      opts = [provider: "openai-compatible", endpoint: base <> "/echo", model: "m1"]

      assert {:ok, content} = ContentGenerator.generate(yaml, opts)
      assert %{"body" => %{"model" => "m1"}} = Jason.decode!(content)
    end

    test "gemini provider routes through the OpenAI-compatible clause", %{base: base} do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"
      opts = [provider: "gemini", endpoint: base <> "/echo"]

      assert {:ok, content} = ContentGenerator.generate(yaml, opts)
      decoded = Jason.decode!(content)
      assert decoded["authorization"] == "Bearer test-key-openai_api_key"
      assert decoded["body"]["model"] == "gpt-4o-mini"
    end

    test "anthropic provider sends x-api-key + version headers", %{base: base} do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"
      opts = [provider: "anthropic", endpoint: base <> "/echo"]

      assert {:ok, content} = ContentGenerator.generate(yaml, opts)
      decoded = Jason.decode!(content)
      assert decoded["x_api_key"] == "test-key-anthropic_api_key"
      assert decoded["anthropic_version"] == "2023-06-01"
      assert decoded["body"]["model"] == "claude-sonnet-4-20250514"
    end

    test "z.ai provider uses XAI_API_KEY and defaults to grok-3", %{base: base} do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"
      opts = [provider: "z.ai", endpoint: base <> "/echo"]

      assert {:ok, content} = ContentGenerator.generate(yaml, opts)
      decoded = Jason.decode!(content)
      assert decoded["authorization"] == "Bearer test-key-xai_api_key"
      assert decoded["body"]["model"] == "grok-3"
    end

    test "configured provider without a key fails fast with missing_api_key" do
      System.delete_env("OPENAI_API_KEY")
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"
      assert {:error, :missing_api_key} = ContentGenerator.generate(yaml, provider: "openai")
      assert {:error, :missing_api_key} = ContentGenerator.generate(yaml, provider: "gemini")
    end

    test "anthropic without a key fails fast" do
      System.delete_env("ANTHROPIC_API_KEY")
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"
      assert {:error, :missing_api_key} = ContentGenerator.generate(yaml, provider: "anthropic")
    end

    test "z.ai without a key fails fast" do
      System.delete_env("XAI_API_KEY")
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"
      assert {:error, :missing_api_key} = ContentGenerator.generate(yaml, provider: "z.ai")
    end

    test "config service field selects the provider when no opt overrides" do
      System.delete_env("OPENAI_API_KEY")
      yaml = "type: unknown-type\nservice: openai\nprompt:\n  text: hi\n"
      assert {:error, :missing_api_key} = ContentGenerator.generate(yaml)
    end
  end

  # ---------------------------------------------------------------------------
  # generate/2 — request shaping (system prompt, temperature, max_tokens)
  # ---------------------------------------------------------------------------

  describe "generate/2 request shaping" do
    test "default system prompt includes type + output format and FIM references", %{base: base} do
      yaml = """
      type: diagram
      prompt:
        text: a sequence diagram
      """

      opts = [provider: "local", endpoint: base <> "/echo"]

      assert {:ok, content} = ContentGenerator.generate(yaml, opts)
      assert %{"body" => %{"messages" => messages}} = Jason.decode!(content)

      assert [%{"role" => "system", "content" => system}, %{"role" => "user", "content" => text}] =
               messages

      assert text == "a sequence diagram"
      assert system =~ "content generator specialized in producing diagram content"
      assert system =~ "Output format: text"
      assert system =~ "--- FORMAT REFERENCE ---"
      assert system =~ "Use-Case Guide (diagram-generation)"
      assert system =~ "Solution Reference (mermaid)"
      assert system =~ "--- END FORMAT REFERENCE ---"
      assert system =~ "Do NOT wrap output in markdown code fences"
    end

    test "custom system prompt replaces the default and opts override temperature/max_tokens", %{
      base: base
    } do
      yaml = """
      type: unknown-type
      prompt:
        system: You are a custom generator.
        provider_options:
          temperature: 0.9
          max_tokens: 256
      """

      opts = [provider: "local", endpoint: base <> "/echo"]

      assert {:ok, content} = ContentGenerator.generate(yaml, opts)
      assert %{"body" => body} = Jason.decode!(content)
      assert [%{"role" => "system", "content" => system}] = body["messages"] |> Enum.take(1)
      assert system == "You are a custom generator."
      refute system =~ "FORMAT REFERENCE"
      assert body["temperature"] == 0.9
      assert body["max_tokens"] == 256
    end

    test "output.formats drives the declared output format", %{base: base} do
      yaml = """
      type: unknown-type
      output:
        formats:
          - format: svg_js
      prompt:
        text: hi
      """

      assert {:ok, content} =
               ContentGenerator.generate(yaml, provider: "local", endpoint: base <> "/echo")

      assert %{"body" => %{"messages" => [%{"content" => system} | _]}} = Jason.decode!(content)
      assert system =~ "Output format: svg_js"
    end

    test "output.text_format drives the output format when formats is absent", %{base: base} do
      yaml = """
      type: unknown-type
      output:
        text_format: markdown
      prompt:
        text: hi
      """

      assert {:ok, content} =
               ContentGenerator.generate(yaml, provider: "local", endpoint: base <> "/echo")

      assert %{"body" => %{"messages" => [%{"content" => system} | _]}} = Jason.decode!(content)
      assert system =~ "Output format: markdown"
    end

    test "output.diagram_type drives the output format", %{base: base} do
      yaml = """
      type: diagram
      output:
        diagram_type: graphviz-dot
      prompt:
        text: hi
      """

      assert {:ok, content} =
               ContentGenerator.generate(yaml, opts_base(base))

      assert %{"body" => %{"messages" => [%{"content" => system} | _]}} = Jason.decode!(content)
      assert system =~ "Output format: graphviz-dot"
      assert system =~ "Solution Reference (graphviz-dot)"
    end

    test "missing config type defaults to document", %{base: base} do
      yaml = "prompt:\n  text: hi\n"

      assert {:ok, content} = ContentGenerator.generate(yaml, opts_base(base))

      assert %{"body" => %{"messages" => [%{"content" => system} | _]}} = Jason.decode!(content)
      assert system =~ "specialized in producing document content"
    end

    test "opts model/provider override config values", %{base: base} do
      yaml = """
      type: unknown-type
      service: openai
      model: from-config
      prompt:
        text: hi
      """

      opts = [provider: "local", model: "from-opts", endpoint: base <> "/echo"]

      assert {:ok, content} = ContentGenerator.generate(yaml, opts)
      assert %{"body" => %{"model" => "from-opts"}} = Jason.decode!(content)
    end

    test "yaml provider_options default to 0.3 / 8192", %{base: base} do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"

      assert {:ok, content} = ContentGenerator.generate(yaml, opts_base(base))
      assert %{"body" => %{"temperature" => 0.3, "max_tokens" => 8192}} = Jason.decode!(content)
    end
  end

  # ---------------------------------------------------------------------------
  # generate/2 — HTTP outcome normalization
  # ---------------------------------------------------------------------------

  describe "generate/2 http outcomes" do
    test "200 + valid choices returns trimmed content", %{base: base} do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"
      url = base <> "/ok"

      assert {:ok, "GENERATED"} =
               ContentGenerator.generate(yaml, provider: "local", endpoint: url)
    end

    test "200 + unexpected shape -> unexpected_response", %{base: base} do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"

      assert {:error, {:unexpected_response, %{"nope" => true}}} =
               ContentGenerator.generate(yaml, provider: "local", endpoint: base <> "/badjson")
    end

    test "non-200 -> http_error with status + body", %{base: base} do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"

      assert {:error, {:http_error, 500, "kaboom"}} =
               ContentGenerator.generate(yaml, provider: "local", endpoint: base <> "/status500")
    end

    test "connection refused -> request_failed" do
      yaml = "type: unknown-type\nprompt:\n  text: hi\n"

      assert {:error, {:request_failed, {:failed_connect, _}}} =
               ContentGenerator.generate(yaml, provider: "local", endpoint: dead_url())
    end
  end

  # ---------------------------------------------------------------------------
  # FIM reference loading (public helpers)
  # ---------------------------------------------------------------------------

  describe "build_fim_context/2" do
    test "loads use-case + solution references in solution-then-usecase order" do
      assert [{uc_title, uc_body}, {sol_title, sol_body}] =
               ContentGenerator.build_fim_context("diagram", "mermaid")

      assert uc_title == "Use-Case Guide (diagram-generation)"
      assert sol_title == "Solution Reference (mermaid)"
      assert is_binary(uc_body) and uc_body != ""
      assert is_binary(sol_body) and sol_body != ""
    end

    test "unknown asset type -> empty context" do
      assert ContentGenerator.build_fim_context("unknown-type", nil) == []
    end

    test "known type with no solution hint -> use-case only" do
      assert [{title, body}] = ContentGenerator.build_fim_context("document", nil)
      assert title == "Use-Case Guide (document-processing)"
      assert body != ""
    end

    test "missing solution file degrades to use-case only" do
      assert [{title, _}] = ContentGenerator.build_fim_context("diagram", "no-such-solution")
      assert title == "Use-Case Guide (diagram-generation)"
    end
  end

  describe "reference listings" do
    test "list_solutions/1 returns the solution list for a known type" do
      assert "mermaid" in ContentGenerator.list_solutions("diagram")
      assert ContentGenerator.list_solutions("bogus") == []
    end

    test "list_use_cases/0 returns the type -> use-case map" do
      use_cases = ContentGenerator.list_use_cases()
      assert use_cases["diagram"] == "diagram-generation"
      assert use_cases["voice"] == "media-processing"
      assert map_size(use_cases) == 10
    end

    test "get_solution_reference/1 hits the file and misses gracefully" do
      assert {:ok, body} = ContentGenerator.get_solution_reference("mermaid")
      assert body != ""
      assert :error = ContentGenerator.get_solution_reference("no-such-solution")
    end

    test "get_use_case_reference/1 hits the file and misses gracefully" do
      assert {:ok, body} = ContentGenerator.get_use_case_reference("diagram-generation")
      assert body != ""
      assert :error = ContentGenerator.get_use_case_reference("no-such-use-case")
    end
  end

  # ---------------------------------------------------------------------------

  defp opts_base(base), do: [provider: "local", endpoint: base <> "/echo"]

  defp dead_url do
    {:ok, sock} = :gen_tcp.listen(0, [])
    {:ok, port} = :inet.port(sock)
    :gen_tcp.close(sock)
    "http://127.0.0.1:#{port}/ok"
  end
end
