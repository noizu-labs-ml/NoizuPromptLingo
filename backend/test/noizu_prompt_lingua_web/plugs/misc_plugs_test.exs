defmodule NoizuPromptLinguaWeb.Plugs.MiscPlugsTest do
  @moduledoc """
  Residual branch coverage for the small infra plugs (W4-D): CORS origin echo
  + preflight, RateLimit allow/deny + forwarded-for parsing, and the
  OtelLoggerMetadata trace/span metadata attach.
  """

  use NoizuPromptLinguaWeb.ConnCase, async: true

  import Plug.Conn

  alias NoizuPromptLinguaWeb.Plugs.CORS
  alias NoizuPromptLinguaWeb.Plugs.OtelLoggerMetadata
  alias NoizuPromptLinguaWeb.Plugs.RateLimit

  # ── CORS ─────────────────────────────────────────────────────────

  test "CORS echoes a single origin and passes non-OPTIONS through" do
    conn =
      build_conn(:get, "/x")
      |> put_req_header("origin", "https://app.example.com")
      |> CORS.call([])

    refute conn.halted
    assert get_resp_header(conn, "access-control-allow-origin") == ["https://app.example.com"]
    assert get_resp_header(conn, "access-control-allow-methods") |> hd() =~ "OPTIONS"
    assert get_resp_header(conn, "access-control-max-age") == ["3600"]
  end

  test "CORS falls back to * when no origin header is present" do
    conn = build_conn(:get, "/x") |> CORS.call([])

    assert get_resp_header(conn, "access-control-allow-origin") == ["*"]
  end

  test "CORS short-circuits OPTIONS preflight with 204" do
    conn = build_conn(:options, "/x") |> CORS.call([])

    assert conn.halted
    assert conn.status == 204
  end

  # ── RateLimit ────────────────────────────────────────────────────

  test "RateLimit init resolves known actions and falls back to defaults" do
    assert RateLimit.init(action: :auth) == %{action: :auth, limit: 10, period: 60_000}
    assert RateLimit.init(action: :marketing_signup) |> Map.get(:limit) == 10

    # unknown action → default window
    opts = RateLimit.init(action: :whatever)
    assert %{limit: 10, period: 60_000} = opts
  end

  test "RateLimit allows fresh keys" do
    ip = "198.51.100.#{Integer.mod(System.unique_integer([:positive]), 250) + 1}"

    conn =
      build_conn(:post, "/x")
      |> put_req_header("x-forwarded-for", ip)
      |> RateLimit.call(RateLimit.init(action: :marketing_signup))

    refute conn.halted
  end

  test "RateLimit denies past the limit with a retry-after header" do
    # Use a unique forwarded-for so the counter is isolated per test run.
    ip = "203.0.113.#{Integer.mod(System.unique_integer([:positive]), 250) + 1}"
    opts = RateLimit.init(action: :auth_sensitive)

    conn =
      build_conn(:post, "/x")
      |> put_req_header("x-forwarded-for", "#{ip}, 10.0.0.1")
      |> RateLimit.call(opts)

    if conn.halted do
      # another test in this run already burned this bucket — 429 is valid
      assert conn.status == 429
      assert get_resp_header(conn, "retry-after") == ["60"]
    else
      # hammer the remaining budget, then expect the next call to deny
      denies =
        1..20
        |> Enum.map(fn _ ->
          build_conn(:post, "/x")
          |> put_req_header("x-forwarded-for", ip)
          |> RateLimit.call(opts)
        end)
        |> Enum.any?(& &1.halted)

      assert denies, "expected the bucket to eventually deny"
    end
  end

  # ── OtelLoggerMetadata ───────────────────────────────────────────

  test "OtelLoggerMetadata passes through when no span is active" do
    conn = build_conn(:get, "/x") |> OtelLoggerMetadata.call([])

    refute conn.halted
  end

  test "OtelLoggerMetadata attaches trace/span metadata when a span is active" do
    Application.ensure_all_started(:opentelemetry)
    require OpenTelemetry.Tracer

    Logger.metadata(trace_id: nil, span_id: nil)

    conn =
      OpenTelemetry.Tracer.with_span "w4d-plug-test" do
        OtelLoggerMetadata.call(build_conn(:get, "/x"), [])
      end

    refute conn.halted
    md = Logger.metadata()

    assert is_binary(md[:trace_id]) and byte_size(md[:trace_id]) == 32
    assert is_binary(md[:span_id]) and byte_size(md[:span_id]) == 16
  end
end
