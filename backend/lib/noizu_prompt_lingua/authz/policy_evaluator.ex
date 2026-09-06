defmodule NoizuPromptLingua.Authz.PolicyEvaluator do
  @moduledoc false

  import Bitwise

  @type evaluation_result :: %{
          allowed: boolean(),
          reason: :explicit_allow | :explicit_deny | :implicit_deny,
          matching_statements: [map()]
        }

  @doc "Evaluate policies for a user's permission on a resource."
  @spec evaluate(list(map()), String.t(), String.t(), String.t(), String.t(), map()) ::
          evaluation_result()
  def evaluate(policies, action, resource_type, resource_id, role, context \\ %{}) do
    resource_urn = "#{resource_type}:#{resource_id}"

    substitutions = %{
      "resource_type" => resource_type,
      "resource_id" => resource_id,
      "scope_type" => resource_type,
      "scope_id" => resource_id,
      "role" => role,
      "user_id" => Map.get(context, :user_id, "")
    }

    {allows, denies} =
      policies
      |> Enum.flat_map(&policy_statements/1)
      |> Enum.reduce({[], []}, fn statement, {allows, denies} ->
        if matches_statement?(statement, action, resource_urn, substitutions, context) do
          case statement["effect"] do
            "deny" -> {allows, [statement | denies]}
            "allow" -> {[statement | allows], denies}
            _ -> {allows, denies}
          end
        else
          {allows, denies}
        end
      end)

    cond do
      denies != [] ->
        %{allowed: false, reason: :explicit_deny, matching_statements: Enum.reverse(denies)}

      allows != [] ->
        %{allowed: true, reason: :explicit_allow, matching_statements: Enum.reverse(allows)}

      true ->
        %{allowed: false, reason: :implicit_deny, matching_statements: []}
    end
  end

  # Policies arrive in two shapes: string-keyed wrappers (JSON-loaded policy
  # documents, the validated storage shape) and atom-keyed wrappers (Ecto
  # selects in Authz.get_effective_policies/3 and Groups build
  # %{policy_document: doc, ...}). Accept both so explain paths see real
  # statements; anything malformed contributes none (deny-by-default).
  defp policy_statements(%{"policy_document" => %{"statements" => statements}})
       when is_list(statements),
       do: statements

  defp policy_statements(%{policy_document: %{"statements" => statements}})
       when is_list(statements),
       do: statements

  defp policy_statements(_), do: []

  defp matches_statement?(statement, action, resource_urn, substitutions, context) do
    actions = statement["actions"] || []
    resources = statement["resources"] || []
    conditions = statement["conditions"] || %{}

    action_matches?(actions, action) &&
      resource_matches?(resources, resource_urn, substitutions) &&
      conditions_match?(conditions, context)
  end

  # Action matching with wildcards
  defp action_matches?(actions, action) do
    Enum.any?(actions, fn pattern ->
      wildcard_match?(pattern, action)
    end)
  end

  # Resource matching with variable substitution + wildcards
  defp resource_matches?(resources, resource_urn, substitutions) do
    Enum.any?(resources, fn pattern ->
      expanded = substitute_variables(pattern, substitutions)
      wildcard_match?(expanded, resource_urn)
    end)
  end

  # Variable substitution: ${var_name} -> value
  defp substitute_variables(pattern, substitutions) do
    Regex.replace(~r/\$\{(\w+)\}/, pattern, fn _match, var_name ->
      Map.get(substitutions, var_name, "${#{var_name}}")
    end)
  end

  # Wildcard matching (fnmatch-style: * matches any sequence)
  defp wildcard_match?("*", _string), do: true

  defp wildcard_match?(pattern, string) do
    regex_str =
      pattern
      |> Regex.escape()
      |> String.replace("\\*", ".*")
      |> then(&("^" <> &1 <> "$"))

    case Regex.compile(regex_str) do
      {:ok, regex} -> Regex.match?(regex, string)
      _ -> false
    end
  end

  # Condition evaluation (AND logic -- all conditions must match)
  defp conditions_match?(conditions, _context) when map_size(conditions) == 0, do: true

  defp conditions_match?(conditions, context) do
    Enum.all?(conditions, fn {operator, checks} ->
      Enum.all?(checks, fn {context_key, expected} ->
        actual = Map.get(context, String.to_atom(context_key)) || Map.get(context, context_key)
        evaluate_condition(operator, actual, expected)
      end)
    end)
  end

  defp evaluate_condition("StringEquals", actual, expected) when is_list(expected),
    do: actual in expected

  defp evaluate_condition("StringEquals", actual, expected),
    do: actual == expected

  defp evaluate_condition("StringNotEquals", actual, expected) when is_list(expected),
    do: actual not in expected

  defp evaluate_condition("StringNotEquals", actual, expected),
    do: actual != expected

  defp evaluate_condition("StringLike", actual, expected) when is_binary(actual) do
    patterns = if is_list(expected), do: expected, else: [expected]
    Enum.any?(patterns, &wildcard_match?(&1, actual))
  end

  defp evaluate_condition("NumericEquals", actual, expected),
    do: to_number(actual) == to_number(expected)

  defp evaluate_condition("NumericLessThan", actual, expected),
    do: to_number(actual) < to_number(expected)

  defp evaluate_condition("NumericGreaterThan", actual, expected),
    do: to_number(actual) > to_number(expected)

  defp evaluate_condition("DateLessThan", actual, expected),
    do: compare_dates(actual, expected) == :lt

  defp evaluate_condition("DateGreaterThan", actual, expected),
    do: compare_dates(actual, expected) == :gt

  defp evaluate_condition("Bool", actual, expected),
    do: to_boolean(actual) == to_boolean(expected)

  defp evaluate_condition("IpAddress", actual, expected) when is_binary(actual) do
    cidrs = if is_list(expected), do: expected, else: [expected]
    Enum.any?(cidrs, &ip_in_cidr?(actual, &1))
  end

  defp evaluate_condition("NotIpAddress", actual, expected) when is_binary(actual) do
    cidrs = if is_list(expected), do: expected, else: [expected]
    not Enum.any?(cidrs, &ip_in_cidr?(actual, &1))
  end

  defp evaluate_condition(_operator, _actual, _expected), do: false

  defp to_number(val) when is_number(val), do: val

  defp to_number(val) when is_binary(val) do
    case Float.parse(val) do
      {num, ""} -> num
      _ -> 0
    end
  end

  defp to_number(_), do: 0

  defp to_boolean(true), do: true
  defp to_boolean("true"), do: true
  defp to_boolean(1), do: true
  defp to_boolean(_), do: false

  defp compare_dates(a, b) when is_binary(a) and is_binary(b) do
    with {:ok, da, _} <- DateTime.from_iso8601(a),
         {:ok, db, _} <- DateTime.from_iso8601(b) do
      DateTime.compare(da, db)
    else
      _ -> :error
    end
  end

  defp compare_dates(_, _), do: :error

  defp ip_in_cidr?(ip_str, cidr_str) do
    with {:ok, ip} <- parse_ip(ip_str),
         {network, prefix_len} <- parse_cidr(cidr_str) do
      mask = bsl(0xFFFFFFFF, 32 - prefix_len) |> band(0xFFFFFFFF)
      band(ip, mask) == band(network, mask)
    else
      _ -> false
    end
  end

  defp parse_ip(ip_str) do
    case :inet.parse_address(String.to_charlist(ip_str)) do
      {:ok, {a, b, c, d}} -> {:ok, bsl(a, 24) + bsl(b, 16) + bsl(c, 8) + d}
      _ -> :error
    end
  end

  defp parse_cidr(cidr_str) do
    case String.split(cidr_str, "/") do
      [ip, prefix] ->
        case {parse_ip(ip), Integer.parse(prefix)} do
          {{:ok, network}, {prefix_len, ""}} when prefix_len >= 0 and prefix_len <= 32 ->
            {network, prefix_len}

          _ ->
            :error
        end

      _ ->
        :error
    end
  end
end
