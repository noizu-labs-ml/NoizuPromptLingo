defmodule NoizuPromptLinguaWeb.PromptBuilderControllerTest do
  @moduledoc """
  POST /api/prompt-builder/build + GET status + admin config endpoints against
  the Stub generator (judge + build replies scripted per test).
  """
  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.PromptBuilder
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User

  @base "/api/prompt-builder"
  @admin "/api/v1/admin/prompt-builder/config"

  @npl_reply "⌜NPL@1.0⌝\n:persona: \"Reviewer\"\n@directive: review code\n⌞NPL@1.0⌟"
  @judge_yes ~s({"prompt_request": true, "reason": "prompt build"})
  @judge_no ~s({"prompt_request": false, "reason": "chat question"})

  setup do
    on_exit(fn -> Process.delete(:pb_stub_replies) end)
    :ok
  end

  defp queue(replies), do: Process.put(:pb_stub_replies, replies)

  # ── happy path ──────────────────────────────────────────────────────────

  test "build returns a composed NPL prompt", %{conn: conn} do
    queue([{:text, @judge_yes}, {:text, @npl_reply}])

    conn =
      post(conn, "#{@base}/build", %{
        "description" => "A prompt for a senior Elixir code reviewer",
        "session_id" => "sess-abc"
      })

    assert %{"prompt" => prompt} = json_response(conn, 200)
    assert prompt =~ "⌜NPL@1.0⌝"
    assert %{"tokens_in" => 100, "tokens_out" => 50} = json_response(conn, 200)
  end

  test "build trues up usage accounting", %{conn: conn} do
    queue([{:text, @judge_yes}, {:text, @npl_reply}])

    post(conn, "#{@base}/build", %{"description" => "Build me a reviewer prompt", "session_id" => "s1"})

    key = PromptBuilder.key_hash("127.0.0.1", "s1")
    assert {:ok, usage} = PromptBuilder.today_usage(key)
    assert usage.request_count == 1
    assert usage.rejected_count == 0
    assert usage.tokens_in == 100
  end

  # ── purpose-lock rejections ────────────────────────────────────────────

  test "build 422s non-prompt-construction input", %{conn: conn} do
    queue([{:text, @judge_no}])

    conn =
      post(conn, "#{@base}/build", %{"description" => "What is the capital of France?", "session_id" => "s2"})

    assert %{"error" => error} = json_response(conn, 422)
    assert error =~ "only builds NPL prompts"
  end

  test "build 422s when output validation fails after the retry", %{conn: conn} do
    chatty = "The capital of France is Paris, famous for its art and history."

    queue([{:text, @judge_yes}, {:text, chatty}, {:text, chatty}])

    conn = post(conn, "#{@base}/build", %{"description" => "Build a geography quiz prompt", "session_id" => "s3"})

    assert json_response(conn, 422)["error"] =~ "didn't return a valid NPL prompt"
    key = PromptBuilder.key_hash("127.0.0.1", "s3")
    assert {:ok, usage} = PromptBuilder.today_usage(key)
    assert usage.rejected_count == 1
  end

  test "build 422s blank input without a model call", %{conn: conn} do
    conn = post(conn, "#{@base}/build", %{"description" => "   "})
    assert json_response(conn, 422)
  end

  # ── budget + rate limits ────────────────────────────────────────────────

  test "build 429s once the daily budget cap is spent", %{conn: conn} do
    key = PromptBuilder.key_hash("127.0.0.1", "budget-sess")
    :ok = PromptBuilder.record(key, cost: Decimal.new("0.99"))

    # Spend meets the cap (checked BEFORE any model call → no stub queue).
    set_cap("0.990000")

    conn = post(conn, "#{@base}/build", %{"description" => "Build a prompt for X", "session_id" => "budget-sess"})
    assert %{"error" => error} = json_response(conn, 429)
    assert error =~ "Daily build budget reached"
  end

  test "build 429s on requests-per-minute after the configured count", %{conn: conn} do
    set_rpm(1)
    queue([{:text, @judge_yes}, {:text, @npl_reply}])

    assert json_response(post(conn, "#{@base}/build", %{"description" => "Build a prompt for tests", "session_id" => "rpm"}), 200)

    # Second request in the same minute: request bucket full → 429.
    queue([{:text, @judge_yes}])
    conn = post(conn, "#{@base}/build", %{"description" => "Build another prompt", "session_id" => "rpm"})
    assert %{"error" => error} = json_response(conn, 429)
    assert error =~ "Rate limit reached"
  end

  # ── status + disabled ──────────────────────────────────────────────────

  test "status reports remaining budget without consuming quota", %{conn: conn} do
    conn = get(conn, "#{@base}/status?session_id=status-sess")
    %{"enabled" => true, "daily_cost_remaining_usd" => remaining} = json_response(conn, 200)
    assert remaining == "1.0" or Decimal.eq?(Decimal.new(remaining), Decimal.new("1.00"))
  end

  test "build 503s when disabled", %{conn: conn} do
    Repo.get!(NoizuPromptLingua.Schema.PromptBuilderConfig, "default")
    |> Ecto.Changeset.change(enabled: false)
    |> Repo.update!()

    conn = post(conn, "#{@base}/build", %{"description" => "Build a prompt please", "session_id" => "off"})
    assert json_response(conn, 503)["error"] =~ "temporarily disabled"
  end

  # ── admin config surface ────────────────────────────────────────────────

  test "admin can read + update the config; non-admin is blocked", %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()
    make_admin(user)

    assert %{"config" => config} =
             conn
             |> authenticated_conn(token)
             |> get(@admin)
             |> json_response(200)

    assert config["model"] == "openai/gpt-oss-120b"

    assert %{"config" => updated} =
             conn
             |> authenticated_conn(token)
             |> put(@admin, %{"config" => %{"daily_cost_cap_usd" => "2.50"}})
             |> json_response(200)

    assert Decimal.eq?(Decimal.new(updated["daily_cost_cap_usd"]), Decimal.new("2.50"))

    # Non-admin → blocked by the :admin pipeline.
    %{access_token: plain_token} = setup_user_and_token()

    conn =
      build_conn()
      |> authenticated_conn(plain_token)
      |> get(@admin)

    refute conn.status == 200
    assert user.id
  end

  # ── helpers ─────────────────────────────────────────────────────────────

  defp make_admin(user) do
    Repo.get!(User, user.id) |> Ecto.Changeset.change(role: :admin) |> Repo.update!()
  end

  defp set_cap(value) do
    Repo.get!(NoizuPromptLingua.Schema.PromptBuilderConfig, "default")
    |> Ecto.Changeset.change(daily_cost_cap_usd: Decimal.new(value))
    |> Repo.update!()
  end

  defp set_rpm(n) do
    Repo.get!(NoizuPromptLingua.Schema.PromptBuilderConfig, "default")
    |> Ecto.Changeset.change(requests_per_minute: n)
    |> Repo.update!()
  end

  # ── adapter-failure regression (live-smoke bug) ────────────────────────
  # A broken/misconfigured adapter must 503 (or 422 via the fail-closed judge),
  # never 500. The original bug: Generator.impl/0 fell back to a non-existent
  # bare `LLM` alias → UndefinedFunctionError → 500 on every /build.

  test "broken adapter → 503, not 500", %{conn: _conn} do
    original = Application.get_env(:noizu_prompt_lingua, :prompt_builder)

    Application.put_env(:noizu_prompt_lingua, :prompt_builder,
      generator: NoizuPromptLingua.PromptBuilder.Generator.DoesNotExist
    )

    try do
      conn =
        build_conn()
        |> post("#{@base}/build", %{"description" => "Build a prompt for X", "session_id" => "broken-adapter"})

      # The fail-closed judge crashes first → 422; a crash on the build call
      # itself → 503. Either way: never a 500.
      assert conn.status in [422, 503]
    after
      if original,
        do: Application.put_env(:noizu_prompt_lingua, :prompt_builder, original),
        else: Application.delete_env(:noizu_prompt_lingua, :prompt_builder)
    end
  end
end
