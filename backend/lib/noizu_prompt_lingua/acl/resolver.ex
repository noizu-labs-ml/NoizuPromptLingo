defmodule NoizuPromptLingua.Acl.Resolver do
  @moduledoc """
  Pure effective-permission resolver for the ACL library — no Repo, no HTTP,
  no process state, fully unit-testable.

  Given the applicable rules (already fetched), the subject candidate refs
  (subject + expanded group refs), the action and the resource ref, decide
  allow/deny:

  1. Keep `active` rules only.
  2. Scope: a rule with a `scope` applies only when the requested scope equals
     it; `nil`-scoped rules apply everywhere.
  3. Subject: rule `subject_ref` must equal one of the candidate refs.
  4. Action: rule action must equal the requested action or be the `"*"`
     wildcard.
  5. Resource: exact ref equality, kind wildcard (`{:ref, Type, :any}`), or
     global wildcard (`{:ref, :any, :any}`).
  6. Precedence: **deny wins** — any matching deny beats every matching allow,
     regardless of priority. Priority only ranks the reported decision among
     the winning effect's matches.
  7. No match → the configured default (`:deny` unless `default: :allow`).
  """

  alias NoizuPromptLingua.Acl.ERPRef
  alias NoizuPromptLingua.Schema.Acl.Rule

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  @wildcard :any
  @action_wildcard Rule.action_wildcard()

  @doc """
  Resolve to `{:allow, rule | :default}` / `{:deny, rule | :default}`.
  `rules` may be `Rule` structs or plain maps with the rule fields.
  """
  def evaluate(rules, subjects, action, resource_ref, opts \\ []) do
    default = Keyword.get(opts, :default, :deny)
    scope = Keyword.get(opts, :scope)

    subjects_n = normalize_all(subjects)
    resource = normalize(resource_ref)

    matched =
      rules
      |> Enum.filter(&active?/1)
      |> Enum.filter(&scope_match?(&1, scope))
      |> Enum.filter(&subject_match?(&1, subjects_n))
      |> Enum.filter(&action_match?(&1, action))
      |> Enum.filter(&(&1 |> resource_match?(resource) == :ok))
      |> Enum.map(&normalize_rule/1)

    denies = Enum.filter(matched, &(&1.effect == "deny"))
    allows = Enum.filter(matched, &(&1.effect == "allow"))

    cond do
      denies != [] -> {:deny, top(denies)}
      allows != [] -> {:allow, top(allows)}
      default == :allow -> {:allow, :default}
      true -> {:deny, :default}
    end
  end

  @doc "Boolean convenience over `evaluate/5`."
  def allowed?(rules, subjects, action, resource_ref, opts \\ []) do
    case evaluate(rules, subjects, action, resource_ref, opts) do
      {:allow, _} -> true
      {:deny, _} -> false
    end
  end

  @doc """
  Full explanation:
  `%{verdict: :allow | :deny, reason: rule | :default,
     matched: %{allow: [...], deny: [...], default: :deny | :allow}}`.
  """
  def explain(rules, subjects, action, resource_ref, opts \\ []) do
    matched = match_detail(rules, subjects, action, resource_ref, opts)

    verdict =
      cond do
        matched.deny != [] -> :deny
        matched.allow != [] -> :allow
        matched.default == :allow -> :allow
        true -> :deny
      end

    reason =
      cond do
        verdict == :deny and matched.deny != [] -> top(matched.deny)
        verdict == :allow and matched.allow != [] -> top(matched.allow)
        true -> :default
      end

    %{verdict: verdict, reason: reason, matched: matched}
  end

  # ── filters ────────────────────────────────────────────────────────

  defp active?(rule), do: Map.get(rule, :status, "active") in [nil, "active"]

  # A nil-scope rule applies everywhere; a scoped rule only when the request
  # names that scope. A nil-scope REQUEST therefore sees global rules only.
  defp scope_match?(%{scope: nil}, _requested), do: true
  defp scope_match?(%{scope: s}, requested), do: not is_nil(requested) and s == requested

  defp subject_match?(_rule, [] = _subjects), do: false

  defp subject_match?(%{subject_ref: sr}, subjects) do
    case normalize(sr) do
      nil -> false
      s -> s in subjects
    end
  end

  defp action_match?(%{action: a}, action) when is_binary(a), do: a == action or a == @action_wildcard
  defp action_match?(_, _), do: false

  @doc """
  Resource match verdict for one rule: `:ok` (rule applies) or `:skip`.
  Wildcards: `{:ref, :any, :any}` global; `{:ref, Type, :any}` kind-wide.
  """
  def resource_match?(%{resource_ref: rr}, resource) do
    case normalize(rr) do
      R.ref(module: @wildcard, id: @wildcard) ->
        :ok

      R.ref(module: kind, id: @wildcard) ->
        case resource do
          R.ref(module: ^kind, id: _) -> :ok
          _ -> :skip
        end

      exact ->
        if exact == resource, do: :ok, else: :skip
    end
  end

  def resource_match?(_, _), do: :skip

  # ── helpers ────────────────────────────────────────────────────────

  defp match_detail(rules, subjects, action, resource_ref, opts) do
    default = Keyword.get(opts, :default, :deny)
    scope = Keyword.get(opts, :scope)
    subjects_n = normalize_all(subjects)
    resource = normalize(resource_ref)

    matched =
      rules
      |> Enum.filter(&active?/1)
      |> Enum.filter(&scope_match?(&1, scope))
      |> Enum.filter(&subject_match?(&1, subjects_n))
      |> Enum.filter(&action_match?(&1, action))
      |> Enum.filter(&(&1 |> resource_match?(resource) == :ok))
      |> Enum.map(&normalize_rule/1)

    %{
      allow: Enum.filter(matched, &(&1.effect == "allow")),
      deny: Enum.filter(matched, &(&1.effect == "deny")),
      default: default
    }
  end

  defp top(rules), do: Enum.max_by(rules, &Map.get(&1, :priority, 0))

  defp normalize_rule(%{} = rule) do
    rule
    |> Map.put(:subject_ref, normalize(Map.get(rule, :subject_ref)))
    |> Map.put(:resource_ref, normalize(Map.get(rule, :resource_ref)))
  end

  defp normalize_all(refs), do: Enum.reject(Enum.map(refs, &normalize/1), &is_nil/1)

  defp normalize(nil), do: nil

  defp normalize(ref) do
    case ERPRef.cast(ref) do
      {:ok, R.ref() = canonical} -> canonical
      _ -> nil
    end
  end
end
