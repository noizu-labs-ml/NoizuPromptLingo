defmodule NoizuPromptLingua.TRP.Error do
  @moduledoc """
  Typed error for the TRP shared-key plane (docs/api/shared-key-api.md §1.5).

  Returned as `{:error, %NoizuPromptLingua.TRP.Error{}}`; never raised from the
  client unless the caller opts in (`Exception.message/1` renders a human line).
  """

  defexception [:status, :reason, :message, :errors, :retry_after]

  @type t :: %__MODULE__{
          status: pos_integer() | nil,
          reason: atom() | nil,
          message: String.t() | nil,
          errors: map() | nil,
          retry_after: pos_integer() | nil
        }

  @known_reasons ~w(org_not_in_key_scope project_not_in_key_scope
                    project_required_by_key_scope admin_required
                    shared_keys_cannot_mint_jwt)a

  @doc "Build from an HTTP status + decoded (string-keyed) error body per spec §1.5."
  def from_response(status, body) when is_integer(status) do
    body = body || %{}

    base = %__MODULE__{status: status}

    cond do
      status == 401 ->
        %{base | message: fetch(body, "error") || "unauthorized"}

      status == 403 ->
        # Whitelist match — never String.to_atom/1 on wire data.
        reason = parse_reason(fetch(body, "reason"))
        %{base | message: fetch(body, "error") || "forbidden", reason: reason}

      status == 404 ->
        %{base | message: fetch(body, "error") || "not found"}

      status == 422 ->
        %{base | message: "validation failed", errors: fetch(body, "errors") || body}

      status == 429 ->
        %{base | message: fetch(body, "error") || "rate_limited", retry_after: fetch(body, "retry_after")}

      status >= 500 ->
        %{base | message: fetch(body, "error") || "trp_server_error"}

      true ->
        %{base | message: fetch(body, "error") || "trp_error"}
    end
  end

  # Bodies arrive either raw-string-keyed (transport JSON) or atomized
  # (Client.decode) — read both key styles.
  defp fetch(body, key) when is_map(body) do
    Map.get(body, key) || Map.get(body, String.to_existing_atom(key))
  rescue
    ArgumentError -> Map.get(body, key)
  end

  defp fetch(_, _), do: nil

  defp parse_reason(r) when is_binary(r) do
    Enum.find(@known_reasons, fn a -> Atom.to_string(a) == r end)
  end

  defp parse_reason(_), do: nil

  @impl true
  def message(%__MODULE__{} = e) do
    reason_part = if e.reason, do: " (#{e.reason})", else: ""
    "TRP request failed#{reason_part}: #{e.status} #{e.message}"
  end
end
