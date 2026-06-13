defmodule Codefresh.AutoFlag.Rule do
  @moduledoc """
  Auto-flagging rule (US-147). Rules are org-scoped deterministic predicates
  evaluated against a completed run's `run_steps` and correlated `otel_spans`
  — matches produce `flagged_captures` rows attributed to the rule
  (`auto_rule_id` set, `flagged_by_user_id = nil`).

  `rule_type` determines the shape of `config`:

    * `"score_threshold"` — `%{"score_below" => 0.3}` fires when any score on
      a run_step is strictly below the threshold
    * `"regex"` — `%{"target" => "response" | "input", "pattern" => "<re>"}`
      fires on a regex match against the run_step's user/agent message
    * `"attribute_equals"` — `%{"attribute" => "error.type",
      "value" => "rate_limit"}` fires when any correlated OTel span has a
      matching `attributes` key/value
    * `"attribute_contains"` — `%{"attribute" => "http.url",
      "substring" => "api.foo"}` substring match on the attribute's string value
    * `"latency_exceeds_ms"` — `%{"threshold_ms" => 5000}` fires on any
      correlated span whose `duration_ns / 1_000_000` >= threshold
    * `"token_count_exceeds"` — `%{"threshold" => 4000}` fires when
      `tokens_in + tokens_out` on a step crosses the threshold

  `default_reason` must be one of `Codefresh.Datasets.FlaggedCapture.valid_reasons/0`.
  Soft-deletion (`soft_deleted_at`) hides the rule without dropping its
  match history.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @rule_types ~w(score_threshold regex attribute_equals attribute_contains latency_exceeds_ms token_count_exceeds)
  @valid_reasons Codefresh.Datasets.FlaggedCapture.valid_reasons()

  schema "auto_flag_rules" do
    field :name, :string
    field :rule_type, :string
    field :config, :map, default: %{}
    field :default_reason, :string
    field :default_tags, {:array, :string}, default: []
    field :enabled, :boolean, default: true
    field :soft_deleted_at, :utc_datetime
    field :match_count, :integer, default: 0

    belongs_to :organization, Codefresh.Organizations.Organization

    timestamps(type: :utc_datetime)
  end

  def rule_types, do: @rule_types
  def valid_reasons, do: @valid_reasons

  def create_changeset(rule, attrs) do
    rule
    |> cast(attrs, [
      :organization_id,
      :name,
      :rule_type,
      :config,
      :default_reason,
      :default_tags,
      :enabled
    ])
    |> validate_required([:organization_id, :name, :rule_type, :default_reason])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_inclusion(:rule_type, @rule_types)
    |> validate_inclusion(:default_reason, @valid_reasons)
    |> validate_config()
    |> foreign_key_constraint(:organization_id)
  end

  def update_changeset(rule, attrs) do
    rule
    |> cast(attrs, [:name, :config, :default_reason, :default_tags, :enabled])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_inclusion(:default_reason, @valid_reasons)
    |> validate_config()
  end

  def soft_delete_changeset(rule) do
    change(rule, soft_deleted_at: DateTime.utc_now() |> DateTime.truncate(:second))
  end

  def bump_match_count_changeset(rule, by \\ 1) when is_integer(by) and by > 0 do
    change(rule, match_count: rule.match_count + by)
  end

  # ─ config shape validation per rule_type ───────────────────────────────
  defp validate_config(changeset) do
    type = get_field(changeset, :rule_type)
    config = get_field(changeset, :config) || %{}
    validate_config_shape(changeset, type, config)
  end

  defp validate_config_shape(cs, "score_threshold", cfg) do
    case fetch_numeric(cfg, ["score_below"]) do
      {:ok, n} when n >= 0.0 and n <= 1.0 -> cs
      {:ok, _} -> add_error(cs, :config, "score_below must be in 0..1")
      :error -> add_error(cs, :config, "score_threshold requires score_below (0..1)")
    end
  end

  defp validate_config_shape(cs, "regex", cfg) do
    target = Map.get(cfg, "target") || Map.get(cfg, :target) || "response"
    pattern = Map.get(cfg, "pattern") || Map.get(cfg, :pattern)

    cond do
      target not in ["response", "input"] ->
        add_error(cs, :config, "target must be 'response' or 'input'")

      not is_binary(pattern) or pattern == "" ->
        add_error(cs, :config, "regex requires a non-empty pattern")

      true ->
        case Regex.compile(pattern) do
          {:ok, _} -> cs
          {:error, {msg, _}} -> add_error(cs, :config, "invalid regex: #{msg}")
        end
    end
  end

  defp validate_config_shape(cs, "attribute_equals", cfg) do
    attr = Map.get(cfg, "attribute") || Map.get(cfg, :attribute)
    value = Map.get(cfg, "value") || Map.get(cfg, :value)

    cond do
      not is_binary(attr) or attr == "" ->
        add_error(cs, :config, "attribute_equals requires attribute")

      is_nil(value) ->
        add_error(cs, :config, "attribute_equals requires value")

      true ->
        cs
    end
  end

  defp validate_config_shape(cs, "attribute_contains", cfg) do
    attr = Map.get(cfg, "attribute") || Map.get(cfg, :attribute)
    sub = Map.get(cfg, "substring") || Map.get(cfg, :substring)

    cond do
      not is_binary(attr) or attr == "" ->
        add_error(cs, :config, "attribute_contains requires attribute")

      not is_binary(sub) or sub == "" ->
        add_error(cs, :config, "attribute_contains requires non-empty substring")

      true ->
        cs
    end
  end

  defp validate_config_shape(cs, "latency_exceeds_ms", cfg) do
    case fetch_numeric(cfg, ["threshold_ms"]) do
      {:ok, n} when n >= 0 -> cs
      _ -> add_error(cs, :config, "latency_exceeds_ms requires threshold_ms >= 0")
    end
  end

  defp validate_config_shape(cs, "token_count_exceeds", cfg) do
    case fetch_numeric(cfg, ["threshold"]) do
      {:ok, n} when n >= 0 -> cs
      _ -> add_error(cs, :config, "token_count_exceeds requires threshold >= 0")
    end
  end

  defp validate_config_shape(cs, _unknown_or_nil, _), do: cs

  defp fetch_numeric(cfg, keys) when is_list(keys) do
    Enum.reduce_while(keys, :error, fn k, acc ->
      case Map.get(cfg, k) || Map.get(cfg, String.to_atom(k)) do
        nil -> {:cont, acc}
        v when is_number(v) -> {:halt, {:ok, v}}
        v when is_binary(v) ->
          case Float.parse(v) do
            {f, ""} -> {:halt, {:ok, f}}
            _ -> {:cont, acc}
          end

        _ ->
          {:cont, acc}
      end
    end)
  end
end
