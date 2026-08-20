defmodule NoizuPromptLingua.MCP.DualTokenVerifier do
  @moduledoc """
  MCP bearer verifier that accepts both:

  1. **Phase 0+ asymmetric** MCP JWTs (RS256/EdDSA/ES256) signed by the
     Tobor JWKS keyring (`NoizuPromptLingua.OAuth.Jwks`)
  2. **Legacy** HS256 API-key compound JWTs via `Noizu.MCP.Auth.CompoundJWTVerifier`

  Audience (`aud`) is enforced when present on the token, or when
  `:require_aud` is true. Legacy tokens without `aud` still pass during the
  migration grace window.
  """

  @behaviour Noizu.MCP.Auth.TokenVerifier

  require Logger

  alias NoizuPromptLingua.OAuth.Jwks

  @asymmetric_algs ~w(RS256 ES256 EdDSA PS256)

  @impl true
  def verify(token, conn_info, opts) when is_binary(token) and is_list(opts) do
    case peek_alg(token) do
      alg when alg in @asymmetric_algs ->
        verify_asymmetric(token, conn_info, opts)

      _ ->
        verify_legacy(token, conn_info, opts)
    end
  end

  def verify(_token, _conn_info, _opts), do: {:error, :invalid_token}

  defp verify_asymmetric(token, conn_info, opts) do
    kid = with {:ok, header} <- peek_header(token), do: Map.get(header, "kid")

    result =
      with {:ok, header} <- peek_header(token),
           {:ok, jwk, default_alg} <- Jwks.verify_jwk(Map.get(header, "kid")),
           algs <- [Map.get(header, "alg") || default_alg],
           {true, %JOSE.JWT{fields: claims}, _jws} <- JOSE.JWT.verify_strict(jwk, algs, token),
           :ok <- check_expiry(claims),
           :ok <- check_issuer(claims, Keyword.get(opts, :issuer)),
           :ok <- check_api_key(claims, Keyword.get(opts, :validate_api_key)),
           :ok <- check_aud(claims, conn_info, opts) do
        {:ok, claims}
      else
        # verify_strict/3 returning false is a signature mismatch: the token was
        # signed by a key this instance does not hold under that kid.
        {false, _, _} -> {:error, :bad_signature}
        {:error, reason} -> {:error, reason}
        other -> {:error, {:unexpected, other}}
      end

    case result do
      {:ok, claims} -> {:ok, claims}
      {:error, reason} -> reject(reason, kid, "asymmetric")
    end
  end

  # The MCP transport only understands :invalid_token, so the specific reason
  # would otherwise be lost entirely — log it before collapsing. Without this a
  # revoked API key, a rotated signing key, a wrong issuer and a bad audience
  # are indistinguishable in production logs.
  defp reject(reason, kid, path) do
    Logger.warning(
      "[MCP auth] rejecting #{path} bearer token: #{inspect(reason)} (kid=#{inspect(kid)})"
    )

    {:error, :invalid_token}
  end

  defp verify_legacy(token, conn_info, opts) do
    legacy_opts =
      opts
      |> Keyword.take([:secret, :issuer, :validate_api_key, :algorithms])
      |> Keyword.put_new(:algorithms, ["HS256"])

    case Noizu.MCP.Auth.CompoundJWTVerifier.verify(token, conn_info, legacy_opts) do
      {:ok, claims} ->
        case check_aud(claims, conn_info, opts) do
          :ok -> {:ok, claims}
          {:error, reason} -> reject(reason, nil, "legacy")
        end

      {:error, reason} ->
        reject(reason, nil, "legacy")
    end
  end

  defp check_api_key(%{"api_key_id" => id}, fun) when is_function(fun, 1) do
    if fun.(id), do: :ok, else: {:error, :api_key_revoked}
  end

  defp check_api_key(%{"api_key_id" => _}, _), do: :ok
  # OAuth-minted tokens (later phases) may omit api_key_id.
  defp check_api_key(_claims, _), do: :ok

  defp check_expiry(%{"exp" => exp}) when is_number(exp) do
    if System.system_time(:second) < exp, do: :ok, else: {:error, :expired}
  end

  defp check_expiry(_), do: :ok

  defp check_issuer(_claims, nil), do: :ok
  defp check_issuer(%{"iss" => iss}, expected) when iss == expected, do: :ok

  defp check_issuer(%{"iss" => iss}, expected) when is_list(expected) do
    if iss in expected, do: :ok, else: {:error, :bad_issuer}
  end

  defp check_issuer(_, _), do: {:error, :bad_issuer}

  defp check_aud(claims, conn_info, opts) do
    require_aud? = Keyword.get(opts, :require_aud, false)
    expected = expected_audience(conn_info, opts)
    aud = claims["aud"]

    cond do
      is_nil(aud) and not require_aud? ->
        :ok

      is_nil(aud) and require_aud? ->
        {:error, :missing_aud}

      is_nil(expected) ->
        # No configured resource URL — accept any aud during early rollout.
        :ok

      aud_matches?(aud, expected) ->
        :ok

      true ->
        {:error, :bad_aud}
    end
  end

  defp expected_audience(conn_info, opts) do
    Keyword.get(opts, :expected_audience) ||
      Keyword.get(opts, :resource) ||
      resource_from_host(conn_info, opts)
  end

  defp resource_from_host(%{headers: headers}, opts) when is_list(headers) do
    host =
      Enum.find_value(headers, fn
        {h, v} when h in ["host", "Host"] -> v
        _ -> nil
      end)

    base = Keyword.get(opts, :public_scheme, "https")

    case host do
      h when is_binary(h) and h != "" -> "#{base}://#{h}/mcp"
      _ -> nil
    end
  end

  defp resource_from_host(_, _), do: nil

  defp aud_matches?(aud, expected) when is_binary(aud), do: aud == expected

  defp aud_matches?(aud, expected) when is_list(aud),
    do: expected in aud or to_string(expected) in Enum.map(aud, &to_string/1)

  defp aud_matches?(_, _), do: false

  defp peek_alg(token) do
    case peek_header(token) do
      {:ok, %{"alg" => alg}} -> alg
      _ -> nil
    end
  end

  defp peek_header(token) do
    case String.split(token, ".", parts: 3) do
      [header_b64, _payload, _sig] ->
        case Base.url_decode64(header_b64, padding: false) do
          {:ok, json} -> Jason.decode(json)
          :error -> {:error, :bad_header}
        end

      _ ->
        {:error, :bad_token}
    end
  end
end
