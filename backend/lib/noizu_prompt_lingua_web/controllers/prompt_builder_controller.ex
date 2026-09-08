defmodule NoizuPromptLinguaWeb.PromptBuilderController do
  use NoizuPromptLinguaWeb, :controller

  @moduledoc """
  Web NPL Prompt Builder endpoints.

  Auth model: the /keyboard page is public (proxy.ts only gates /app/*), so the
  endpoint is public with mandatory per-key limits — every caller is keyed by
  client_ip + client-supplied opaque session_id (hashed; never stored raw).
  Logged-in callers simply send the same payload; a future session-auth tier
  only needs to swap the key derivation.

  Rejections: 422 with a friendly message for non-prompt-construction input or
  rejected output; 429 (with reset hints) for rate/budget limits; 503 when an
  admin disabled the builder.

  LOGGING CONSENT: accepted builds are persisted to prompt_logs (the fine-tuning
  corpus + public showcase source). The builder UI shows the notice —
  "Prompts you submit are logged and may be used for fine-tuning, evaluation,
  and as public showcase examples." — and /api/prompt-builder/status carries it
  for API consumers.
  """

  alias NoizuPromptLingua.PromptBuilder
  alias NoizuPromptLingua.PromptBuilder.Service

  # POST /api/prompt-builder/build
  def build(conn, params) do
    ip = client_ip(conn)
    session_id = params["session_id"]
    description = params["description"]
    context = params["context"]

    case Service.build(ip, description, context, session_id) do
      {:ok, result} ->
        json(conn, result)

      {:error, :disabled} ->
        conn |> put_status(:service_unavailable) |> json(%{error: "The prompt builder is temporarily disabled."})

      {:error, :empty_input} ->
        conn |> put_status(422) |> json(%{error: "Describe the prompt you want built."})

      {:error, :input_too_long} ->
        conn |> put_status(422) |> json(%{error: "That description is too long — keep it under the character limit."})

      {:error, :not_prompt_request} ->
        conn
        |> put_status(422)
        |> json(%{
          error:
            "This tool only builds NPL prompts. Describe the prompt you want constructed — " <>
              "what the agent should do, its tone, constraints — and Build will compose it."
        })

      {:error, :output_rejected} ->
        conn
        |> put_status(422)
        |> json(%{error: "The model didn't return a valid NPL prompt for that. Try rephrasing as a prompt description."})

      {:error, {:generator, _reason}} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "The prompt compiler is unavailable right now. Try again shortly."})

      {:error, {:rate_limited, retry_after}} ->
        conn
        |> put_resp_header("retry-after", Integer.to_string(retry_after))
        |> put_status(429)
        |> json(%{error: "Rate limit reached — try again in #{retry_after} seconds."})

      {:error, {:budget_exceeded, resets_at}} ->
        conn
        |> put_resp_header("retry-after", Integer.to_string(reset_seconds(resets_at)))
        |> put_status(429)
        |> json(%{error: "Daily build budget reached. Resets at #{DateTime.to_iso8601(resets_at)}."})
    end
  end

  # GET /api/prompt-builder/status — lets the page show remaining quota without
  # consuming any (no model call, no bucket charge).
  def status(conn, params) do
    config = PromptBuilder.get_config()
    key = PromptBuilder.key_hash(client_ip(conn), params["session_id"])

    spent = PromptBuilder.today_cost(key)
    remaining = Decimal.max(Decimal.new(0), Decimal.sub(config.daily_cost_cap_usd, spent))

    json(conn, %{
      enabled: config.enabled,
      requests_per_minute: config.requests_per_minute,
      daily_cost_cap_usd: Decimal.to_string(config.daily_cost_cap_usd),
      daily_cost_remaining_usd: Decimal.to_string(remaining),
      resets_at: DateTime.to_iso8601(PromptBuilder.budget_resets_at()),
      notice:
        "Prompts you submit are logged and may be used for fine-tuning, evaluation, and as public showcase examples."
    })
  end

  defp reset_seconds(resets_at), do: max(1, DateTime.diff(resets_at, DateTime.utc_now()))

  defp client_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [forwarded | _] -> forwarded |> String.split(",") |> List.first() |> String.trim()
      [] -> conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end

  # Admin surface: GET/PUT /api/admin/prompt-builder/config (the admin UI page
  # is a follow-up; ops can also use PROMPT_BUILDER_* env or direct SQL).

  # GET /api/prompt-builder/showcase — public gallery data (OP vs NPL entries).
  def showcase_index(conn, params) do
    entries = PromptBuilder.Showcase.list_entries(limit: parse_limit(params["limit"]))

    json(conn, %{
      entries: Enum.map(entries, &showcase_view/1),
      notice:
        "Showcase entries are built from logged (consented) builder prompts. " <>
          "Prompts you submit are logged and may be used for fine-tuning, evaluation, and as public showcase examples."
    })
  end

  # POST /api/v1/admin/prompt-builder/showcase/process — run a showcase batch
  # over pending logged prompts (system budget, never user quota).
  def showcase_process(conn, params) do
    limit = parse_limit(params["limit"]) |> min(50)

    case PromptBuilder.Showcase.process_batch(limit) do
      {:ok, stats} ->
        json(conn, Map.merge(stats, %{pending: PromptBuilder.Showcase.pending_count()}))

      {:error, reason} ->
        conn |> put_status(422) |> json(%{error: inspect(reason)})
    end
  end

  defp parse_limit(nil), do: 5

  defp parse_limit(raw) when is_binary(raw) do
    case Integer.parse(raw) do
      {n, _} -> max(1, min(n, 100))
      :error -> 5
    end
  end

  defp parse_limit(n) when is_integer(n), do: max(1, min(n, 100))

  defp showcase_view(e) do
    %{
      id: e.id,
      log_id: e.log_id,
      original_prompt: e.original_prompt,
      original_output: e.original_output,
      npl_prompt: e.npl_prompt,
      npl_output: e.npl_output,
      score_original: e.score_original,
      score_npl: e.score_npl,
      winner: e.winner,
      context_sizes: %{
        original: %{chars: e.ctx_original_chars, tokens: e.ctx_original_tokens},
        npl: %{chars: e.ctx_npl_chars, tokens: e.ctx_npl_tokens}
      },
      rubric: e.rubric,
      difference_analysis: e.difference_analysis,
      inserted_at: e.inserted_at
    }
  end

  # ── admin: GET config ──
  def admin_show(conn, _params) do
    config = PromptBuilder.get_config()
    json(conn, %{config: config_view(config)})
  end

  # ── admin: PUT config ──
  def admin_update(conn, params) do
    attrs = params["config"] || params

    case PromptBuilder.update_config(attrs) do
      {:ok, config} ->
        json(conn, %{config: config_view(config)})

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> json(%{
          error: "Invalid config",
          details:
            Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
              Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
                opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
              end)
            end)
        })
    end
  end

  defp config_view(config) do
    %{
      enabled: config.enabled,
      provider: config.provider,
      model: config.model,
      requests_per_minute: config.requests_per_minute,
      tokens_per_minute: config.tokens_per_minute,
      tokens_per_hour: config.tokens_per_hour,
      daily_cost_cap_usd: Decimal.to_string(config.daily_cost_cap_usd),
      input_price_per_1k_usd: Decimal.to_string(config.input_price_per_1k_usd),
      output_price_per_1k_usd: Decimal.to_string(config.output_price_per_1k_usd),
      max_input_chars: config.max_input_chars,
      showcase_daily_cost_cap_usd: Decimal.to_string(config.showcase_daily_cost_cap_usd)
    }
  end
end
