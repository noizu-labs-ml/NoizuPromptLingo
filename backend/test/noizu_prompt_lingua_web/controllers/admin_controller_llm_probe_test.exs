defmodule NoizuPromptLinguaWeb.AdminControllerLlmProbeTest do
  # Drives AdminController's provider introspection endpoints against a local
  # Bandit stub so the private Req-based helpers run without egress. Not async:
  # it mutates provider API-key env vars for deterministic key lookup branches.
  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.Repo

  @admin "/api/v1/admin"

  defmodule Stub do
    @behaviour Plug
    import Plug.Conn

    @impl true
    def init(opts), do: opts

    @impl true
    def call(conn, _opts) do
      case conn.path_info do
        # plain 200 JSON: models list / chat completion / anthropic message
        ["v1", "models"] ->
          send_json(conn, 200, %{"data" => [%{"id" => "stub-model"}]})

        ["v1", "chat", "completions"] ->
          send_json(conn, 200, %{
            "choices" => [%{"message" => %{"role" => "assistant", "content" => "ok"}}]
          })

        ["v1", "messages"] ->
          send_json(conn, 200, %{"id" => "msg_1"})

        # error shapes
        ["err401", "v1", "chat", "completions"] ->
          send_json(conn, 401, %{"error" => %{"message" => "bad key"}})

        ["boom", "v1", "chat", "completions"] ->
          send_json(conn, 500, %{"error" => %{"message" => "kaput"}})

        ["rawtext", "v1", "chat", "completions"] ->
          send_resp(conn, 500, "oops")

        ["rawjson", "v1", "chat", "completions"] ->
          send_json(conn, 500, %{"message" => "plain-message"})

        ["rawtext", "v1", "messages"] ->
          send_resp(conn, 500, "oops")

        ["rawok", "v1", "chat", "completions"] ->
          send_resp(conn, 200, "hello")

        _ ->
          send_json(conn, 404, %{"error" => %{"message" => "no route"}})
      end
    end

    defp send_json(conn, status, body) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(body))
    end
  end

  @provider_keys ~w(OPENAI_API_KEY ANTHROPIC_API_KEY GROQ_API_KEY OPENROUTER_API_KEY CEREBRAS_API_KEY DEEPSEEK_API_KEY)

  setup_all do
    original = Map.new(@provider_keys, &{&1, System.get_env(&1)})

    # Stub-routed providers get fake keys; key-only providers get "" (truthy but
    # valueless) so their "configured" branches are deterministic with no egress.
    System.put_env("OPENAI_API_KEY", "stub-key")
    System.put_env("ANTHROPIC_API_KEY", "stub-key")
    System.put_env("GROQ_API_KEY", "")
    System.put_env("OPENROUTER_API_KEY", "")
    System.put_env("CEREBRAS_API_KEY", "")
    System.put_env("DEEPSEEK_API_KEY", "")

    {:ok, srv} = Bandit.start_link(plug: {Stub, []}, ip: {127, 0, 0, 1}, port: 0)
    {:ok, {_ip, port}} = ThousandIsland.listener_info(srv)

    on_exit(fn ->
      Enum.each(original, fn
        {k, nil} -> System.delete_env(k)
        {k, v} -> System.put_env(k, v)
      end)
    end)

    %{base: "http://127.0.0.1:#{port}", port: port}
  end

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()
    Repo.get!(User, user.id) |> Ecto.Changeset.change(role: :admin) |> Repo.update!()
    {:ok, conn: authenticated_conn(conn, token)}
  end

  defp post_test(conn, base, path_segments, provider, params) do
    conn
    |> post(
      "#{@admin}/llm-providers/#{provider}/test",
      Map.merge(params, %{endpoint: "#{base}/#{path_segments}"})
    )
  end

  test "openai connection succeeds against the stub", %{conn: conn, base: base} do
    body =
      post_test(conn, base, "v1", "openai", %{model: "stub-model"})
      |> json_response(200)

    assert body["valid"] == true
    assert body["result"]["status"] == "connected"
    assert body["result"]["provider"] == "openai"
  end

  test "openai 401 maps to Invalid API key", %{conn: conn, base: base} do
    body =
      post_test(conn, base, "err401/v1", "openai", %{model: "stub-model"})
      |> json_response(422)

    assert body["valid"] == false
    assert body["error"] == "Invalid API key"
  end

  test "openai provider error message is surfaced", %{conn: conn, base: base} do
    body =
      post_test(conn, base, "boom/v1", "openai", %{model: "stub-model"})
      |> json_response(422)

    assert body["error"] == "kaput"
  end

  test "openai non-JSON error body falls back to HTTP code", %{conn: conn, base: base} do
    body =
      post_test(conn, base, "rawtext/v1", "openai", %{model: "stub-model"})
      |> json_response(422)

    assert body["error"] == "HTTP 500"
  end

  test "openai message-style error body is surfaced", %{conn: conn, base: base} do
    body =
      post_test(conn, base, "rawjson/v1", "openai", %{model: "stub-model"})
      |> json_response(422)

    assert body["error"] == "plain-message"
  end

  test "openai 200 with a non-JSON body reports invalid JSON", %{conn: conn, base: base} do
    body =
      post_test(conn, base, "rawok/v1", "openai", %{model: "stub-model"})
      |> json_response(422)

    assert body["error"] == "Invalid JSON response"
  end

  test "anthropic connection succeeds and surfaces error bodies", %{conn: conn, base: base} do
    body =
      post_test(conn, base, "v1", "anthropic", %{model: "stub-model"})
      |> json_response(200)

    assert body["valid"] == true
    assert body["result"]["provider"] == "anthropic"

    err =
      post_test(conn, base, "rawtext/v1", "anthropic", %{model: "stub-model"})
      |> json_response(422)

    assert err["error"] == "HTTP 500"
  end

  test "key-only providers report configured status without egress", %{conn: conn} do
    for provider <- ["groq", "openrouter", "cerebras", "deepseek"] do
      body =
        conn
        |> post("#{@admin}/llm-providers/#{provider}/test", %{model: "m"})
        |> json_response(200)

      assert body["valid"] == true
      assert body["result"]["provider"] == provider
    end
  end

  test "cerebras + deepseek fetch static catalogs", %{conn: conn} do
    cerebras = conn |> get("#{@admin}/llm-providers/cerebras/models") |> json_response(200)
    assert "llama-3.3-70b" in cerebras["models"]

    deepseek = conn |> get("#{@admin}/llm-providers/deepseek/models") |> json_response(200)
    assert "deepseek-chat" in deepseek["models"]
  end

  test "unknown provider is rejected for fetch and test", %{conn: conn} do
    conn
    |> get("#{@admin}/llm-providers/notaprovider/models")
    |> json_response(422)
    |> then(&assert(&1["error"] =~ "not supported"))

    conn
    |> post("#{@admin}/llm-providers/notaprovider/test", %{model: "m"})
    |> json_response(200)
    |> then(&assert(&1["valid"] == true))
  end

  test "test requires a model name and custom endpoints for custom/ollama", %{conn: conn} do
    conn
    |> post("#{@admin}/llm-providers/openai/test", %{})
    |> json_response(422)
    |> then(&assert(&1["error"] =~ "Model name is required"))

    conn
    |> post("#{@admin}/llm-providers/custom/test", %{model: "m"})
    |> json_response(422)
    |> then(&assert(&1["error"] =~ "Custom endpoint URL is required"))
  end

  test "custom provider with endpoint validates without live testing", %{conn: conn} do
    body =
      conn
      |> post("#{@admin}/llm-providers/custom/test", %{
        model: "m",
        endpoint: "http://127.0.0.1:9"
      })
      |> json_response(200)

    assert body["valid"] == true
  end

  test "ollama refused connection reports not running", %{conn: conn} do
    body =
      conn
      |> post("#{@admin}/llm-providers/ollama/test", %{
        model: "llama3",
        endpoint: "http://127.0.0.1:1"
      })
      |> json_response(422)

    assert body["error"] =~ "not running"
  end
end
