defmodule NoizuPromptLingua.PromptBuilder do
  @moduledoc """
  Config + usage plumbing for the web NPL Prompt Builder.

  Config resolution order: DB row (`prompt_builder_configs`, id "default")
  ← env overrides (PROMPT_BUILDER_*, set at boot; ops lever without DB access)
  ← schema defaults. Spend accounting accumulates in `prompt_builder_usage`
  keyed by the same hash the rate limiter uses.
  """

  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{PromptBuilderConfig, PromptBuilderUsage}

  @config_id "default"

  @env_overrides [
    {:enabled, :boolean, "PROMPT_BUILDER_ENABLED"},
    {:provider, :string, "PROMPT_BUILDER_PROVIDER"},
    {:model, :string, "PROMPT_BUILDER_MODEL"},
    {:requests_per_minute, :int, "PROMPT_BUILDER_RPM"},
    {:tokens_per_minute, :int, "PROMPT_BUILDER_TPM"},
    {:tokens_per_hour, :int, "PROMPT_BUILDER_TPH"},
    {:daily_cost_cap_usd, :decimal, "PROMPT_BUILDER_DAILY_CAP_USD"},
    {:input_price_per_1k_usd, :decimal, "PROMPT_BUILDER_INPUT_PRICE_PER_1K"},
    {:output_price_per_1k_usd, :decimal, "PROMPT_BUILDER_OUTPUT_PRICE_PER_1K"},
    {:max_input_chars, :int, "PROMPT_BUILDER_MAX_INPUT_CHARS"}
  ]

  @doc "Effective config: DB row with PROMPT_BUILDER_* env overrides applied."
  @spec get_config() :: PromptBuilderConfig.t()
  def get_config do
    row =
      try do
        Repo.get(PromptBuilderConfig, @config_id)
      rescue
        _ -> nil
      end

    row = row || %PromptBuilderConfig{id: @config_id}
    apply_env_overrides(row)
  end

  @doc "Admin update path (PUT /api/admin/prompt-builder/config)."
  @spec update_config(map()) :: {:ok, PromptBuilderConfig.t()} | {:error, Ecto.Changeset.t()}
  def update_config(attrs) do
    row = Repo.get!(PromptBuilderConfig, @config_id)

    row
    |> PromptBuilderConfig.changeset(attrs)
    |> Repo.update()
  end

  defp apply_env_overrides(config) do
    Enum.reduce(@env_overrides, config, fn {field, type, env}, acc ->
      case System.get_env(env) do
        nil -> acc
        raw -> Map.put(acc, field, cast_env(raw, type, Map.get(acc, field)))
      end
    end)
  end

  defp cast_env(raw, :string, _default), do: raw

  defp cast_env(raw, :int, default) when is_integer(default),
    do: Integer.parse(raw) |> elem(0)

  defp cast_env(raw, :decimal, default) when is_struct(default, Decimal),
    do: Decimal.new(String.trim(raw))

  defp cast_env(raw, :boolean, default) when is_boolean(default),
    do: raw in ["true", "1", "yes"]

  defp cast_env(_raw, _type, default), do: default

  @doc """
  sha256(ip <> ":" <> session_id), hex-truncated. Same key for limiter + budget;
  no raw IP or session id is ever stored.
  """
  @spec key_hash(String.t(), String.t() | nil) :: String.t()
  def key_hash(ip, session_id) do
    :crypto.hash(:sha256, "#{ip}:#{session_id || "anon"}")
    |> Base.encode16(case: :lower)
    |> binary_part(0, 32)
  end

  @doc "Today's (UTC) usage row for a key; not_found when the key hasn't called today."
  @spec today_usage(String.t()) :: {:ok, PromptBuilderUsage.t()} | {:error, :not_found}
  def today_usage(key_hash) do
    case Repo.one(from u in PromptBuilderUsage, where: u.key_hash == ^key_hash and u.day == ^utc_today()) do
      nil -> {:error, :not_found}
      usage -> {:ok, usage}
    end
  end

  @doc "Estimated spend so far today (USD) for a key."
  @spec today_cost(String.t()) :: Decimal.t()
  def today_cost(key_hash) do
    case today_usage(key_hash) do
      {:ok, usage} -> usage.est_cost_usd
      _ -> Decimal.new(0)
    end
  end

  @doc """
  Record one build attempt. `tokens`/`cost` are zero for rejected requests;
  rejections only bump `rejected_count` (count only — no request content is
  ever persisted).
  """
  @spec record(String.t(), keyword()) :: :ok
  def record(key_hash, opts \\ []) do
    tokens_in = Keyword.get(opts, :tokens_in, 0)
    tokens_out = Keyword.get(opts, :tokens_out, 0)
    cost = Keyword.get(opts, :cost, Decimal.new(0))
    rejected? = Keyword.get(opts, :rejected, false)
    day = utc_today()

    Repo.transaction(fn ->
      usage =
        case today_usage(key_hash) do
          {:ok, usage} -> usage
          _ -> %PromptBuilderUsage{key_hash: key_hash, day: day}
        end

      usage
      |> PromptBuilderUsage.changeset(%{
        request_count: usage.request_count + 1,
        rejected_count: usage.rejected_count + if(rejected?, do: 1, else: 0),
        tokens_in: usage.tokens_in + tokens_in,
        tokens_out: usage.tokens_out + tokens_out,
        est_cost_usd: Decimal.add(usage.est_cost_usd, cost)
      })
      |> Repo.insert_or_update()
    end)

    :ok
  end

  @doc "429 reset hint: next UTC midnight."
  @spec budget_resets_at() :: DateTime.t()
  def budget_resets_at do
    now = DateTime.utc_now()
    DateTime.new!(Date.add(now |> DateTime.to_date(), 1), ~T[00:00:00], "Etc/UTC")
  end

  @doc "chars/4 estimate when the provider doesn't return usage counts."
  @spec estimate_tokens(binary()) :: pos_integer()
  def estimate_tokens(text), do: max(1, div(String.length(text), 4))

  defp utc_today, do: DateTime.utc_now() |> DateTime.to_date()
end
