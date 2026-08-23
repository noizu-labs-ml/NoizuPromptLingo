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
    kid =
      case peek_header(token) do
        {:ok, header} -> Map.get(header, "kid")
        _ -> nil
      end

    result =
      with {:ok, header} <- peek_header(token),
           {:ok, claims} <- verify_signed(token, header),
           :ok <- check_expiry(claims),
           :ok <- check_issuer(claims, Keyword.get(opts, :issuer)),
           :ok <- check_api_key(claims, Keyword.get(opts, :validate_api_key)),
           :ok <- check_aud(claims, conn_info, opts) do
        {:ok, claims}
      else
        {false, _, _} -> {:error, :bad_signature}
        {:error, reason} -> {:error, reason}
        other -> {:error, {:unexpected, other}}
      end

    case result do
      {:ok, claims} -> {:ok, claims}
      {:error, reason} -> reject(reason, kid, "asymmetric")
    end
  end

  # Try kid-matched keys first, then the rest of the ring. A pinned kid
  # (`mcp-1`) after a rotation otherwise verifies only against the new key
  # and reports a generic bad signature for every still-valid old token.
  defp verify_signed(token, header) do
    algs = [Map.get(header, "alg") || "RS256"]
    kid = Map.get(header, "kid")

    candidates =
      case Jwks.verify_candidates(kid) do
        {:ok, found} -> uniq_entries(found ++ Jwks.all_candidates())
        {:error, :unknown_kid} -> Jwks.all_candidates()
      end

    Enum.find_value(candidates, {:error, :bad_signature}, fn entry ->
      jwk = JOSE.JWK.to_public(entry.jwk)

      case JOSE.JWT.verify_strict(jwk, algs, token) do
        {true, %JOSE.JWT{fields: claims}, _} -> {:ok, claims}
        _ -> nil
      end
    end)
  end

  defp uniq_entries(entries) do
    Enum.uniq_by(entries, fn entry -> JOSE.JWK.thumbprint(entry.jwk) end)
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
    # CompoundJWTVerifier only accepts a scalar `iss == expected`. Production
    # passes `jwt_issuers()` (a list). Forwarding that list made every HS256
    # token fail `:bad_issuer`. DualTokenVerifier applies the list-aware check.
    legacy_opts =
      opts
      |> Keyword.take([:secret, :validate_api_key, :algorithms])
      |> Keyword.put_new(:algorithms, ["HS256"])
      |> maybe_put_scalar_issuer(Keyword.get(opts, :issuer))

    case Noizu.MCP.Auth.CompoundJWTVerifier.verify(token, conn_info, legacy_opts) do
      {:ok, claims} ->
        with :ok <- check_issuer(claims, Keyword.get(opts, :issuer)),
             :ok <- check_aud(claims, conn_info, opts) do
          {:ok, claims}
        else
          {:error, reason} -> reject(reason, nil, "legacy")
        end

      {:error, reason} ->
        reject(reason, nil, "legacy")
    end
  end

  defp maybe_put_scalar_issuer(opts, issuer) when is_binary(issuer),
    do: Keyword.put(opts, :issuer, issuer)

  defp maybe_put_scalar_issuer(opts, _), do: opts

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
        case decode_b64url(header_b64) do
          {:ok, json} -> Jason.decode(json)
          :error -> {:error, :bad_header}
        end

      _ ->
        {:error, :bad_token}
    end
  end

  defp decode_b64url(s) do
    case Base.url_decode64(s, padding: false) do
      {:ok, _} = ok ->
        ok

      :error ->
        pad = rem(4 - rem(byte_size(s), 4), 4)
        Base.url_decode64(s <> String.duplicate("=", pad))
    end
  end
end
