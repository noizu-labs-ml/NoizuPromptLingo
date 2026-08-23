defmodule NoizuPromptLingua.OAuth.Jwks do
  @moduledoc """
  MCP JWT signing keyring and JWKS document.

  The **active** key signs new mints; **retired** keys stay in the keyring for
  verification only, so rotating the signing key does not invalidate tokens
  that are still inside their TTL.

  Key material comes from config/env:

    * `MCP_JWT_PRIVATE_KEY` — active private key. Accepts a raw PEM, a
      base64-encoded PEM, or a PEM with literal `\\n` escapes (secret stores
      and env plumbing mangle real newlines, so all three are tolerated).
    * `MCP_JWT_PREVIOUS_KEYS` — comma- or newline-separated retired keys, each
      in any of the above encodings, optionally prefixed `<kid>=` to pin the
      kid a retired key was published under.
    * `MCP_JWT_KID` — pins the active kid. **Prefer leaving this unset**: the
      kid is then the RFC 7638 thumbprint of the key itself, so a key change
      always produces a new kid and stale tokens fail as `:unknown_kid`
      (diagnosable) rather than as an opaque bad signature.

  When no key is configured an ephemeral RSA key is generated and cached in
  `:persistent_term`. That is **fatal in production** — an ephemeral key is
  regenerated on every boot, silently invalidating every token ever minted,
  even at a single replica. Set `MCP_ALLOW_EPHEMERAL_JWT_KEY=true` to override
  (dev/test only).
  """

  require Logger

  @pt_key {__MODULE__, :keyring}

  @type entry :: %{
          kid: String.t(),
          alg: String.t(),
          jwk: JOSE.JWK.t(),
          source: :configured | :retired | :ephemeral
        }

  @type keyring :: %{active: entry(), verify: %{String.t() => [entry()]}}

  @doc "Public JWKS document (`{\"keys\": [...]}`) — active key first, then retired."
  def document do
    {keys, _seen} =
      Enum.reduce(all_candidates(), {[], MapSet.new()}, fn entry, {acc, seen} ->
        pub = public_key_map(entry)
        kid = if MapSet.member?(seen, pub["kid"]), do: thumbprint_kid(entry.jwk), else: pub["kid"]
        pub = Map.put(pub, "kid", kid)
        {acc ++ [pub], MapSet.put(seen, kid)}
      end)

    %{"keys" => keys}
  end

  @doc "Signing entry used for new MCP access tokens."
  def signing_entry, do: keyring().active

  @doc """
  Resolve a verification JWK by kid.

  An empty/missing kid falls back to the active key (legacy mints predate the
  kid header). An unrecognized kid is an explicit `:unknown_kid` — that is the
  signal that the token was signed by a key this instance no longer holds.
  """
  def verify_jwk(kid) when is_binary(kid) and kid != "" do
    case verify_candidates(kid) do
      {:ok, [entry | _]} -> {:ok, JOSE.JWK.to_public(entry.jwk), entry.alg}
      {:error, _} = err -> err
    end
  end

  def verify_jwk(_) do
    active = signing_entry()
    {:ok, JOSE.JWK.to_public(active.jwk), active.alg}
  end

  @doc """
  Every verification entry published under `kid`.

  A pinned kid (`MCP_JWT_KID=mcp-1`) can label both the active key and a
  retired key. Returning a list — active first — lets the verifier try them
  in order instead of treating a rotation as a bad signature.
  """
  def verify_candidates(kid) when is_binary(kid) and kid != "" do
    %{active: active, verify: verify} = keyring()

    case Map.get(verify, kid, []) do
      [] when kid == active.kid -> {:ok, [active]}
      [] -> {:error, :unknown_kid}
      entries -> {:ok, put_active_first(entries, active)}
    end
  end

  def verify_candidates(_), do: {:ok, [signing_entry()]}

  @doc "Active key first, then every retired key (including same-kid duplicates)."
  def all_candidates do
    %{active: active, verify: verify} = keyring()

    rest =
      verify
      |> Map.values()
      |> List.flatten()
      |> Enum.reject(&same_key?(&1, active))
      |> Enum.sort_by(& &1.kid)

    [active | rest]
  end

  @doc "The full keyring (active + verification keys), cached in `:persistent_term`."
  def keyring do
    case :persistent_term.get(@pt_key, :undefined) do
      :undefined ->
        ring = load_keyring()
        :persistent_term.put(@pt_key, ring)
        ring

      ring ->
        ring
    end
  end

  @doc "True when the active key is a throwaway generated at boot."
  def ephemeral?, do: signing_entry().source == :ephemeral

  @doc "Forget cached keyring (tests)."
  def reset! do
    :persistent_term.erase(@pt_key)
    :ok
  end

  # ── loading ────────────────────────────────────────────────────────────────

  defp load_keyring do
    cfg = Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
    alg = Keyword.get(cfg, :signing_alg, "RS256")

    active = load_active(cfg, alg)

    retired =
      cfg
      |> Keyword.get(:previous_key_pems)
      |> Kernel.||(System.get_env("MCP_JWT_PREVIOUS_KEYS"))
      |> parse_retired(alg)

    grouped = Enum.group_by(retired, & &1.kid)

    verify =
      Map.update(grouped, active.kid, [active], fn existing ->
        [active | Enum.reject(existing, &same_key?(&1, active))]
      end)

    %{active: active, verify: verify}
  end

  defp load_active(cfg, alg) do
    raw = Keyword.get(cfg, :private_key_pem) || System.get_env("MCP_JWT_PRIVATE_KEY")

    case normalize_pem(raw) do
      {:ok, pem} ->
        jwk = jwk_from_pem!(pem, "MCP_JWT_PRIVATE_KEY")
        %{kid: resolve_kid(cfg, jwk), alg: alg, jwk: jwk, source: :configured}

      :none ->
        ephemeral_entry(reason: :not_configured)

      {:error, why} ->
        # A present-but-unusable value is the dangerous case: it looks
        # configured from the outside while behaving as ephemeral.
        ephemeral_entry(reason: why)
    end
  end

  defp ephemeral_entry(reason: reason) do
    unless allow_ephemeral?() do
      raise """
      MCP JWT signing key is not usable (#{inspect(reason)}) and this node is \
      running in production.

      Falling back to an ephemeral key would regenerate the signing key on every \
      boot, invalidating every previously minted MCP token (this is true even at \
      a single replica). Set MCP_JWT_PRIVATE_KEY to a stable RSA private key \
      (raw PEM, base64-encoded PEM, or \\n-escaped PEM).

      To override for local/dev use only: MCP_ALLOW_EPHEMERAL_JWT_KEY=true
      """
    end

    Logger.warning(
      "[Jwks] no usable MCP_JWT_PRIVATE_KEY (#{inspect(reason)}) — generating an " <>
        "EPHEMERAL signing key. All minted tokens die on restart."
    )

    jwk = JOSE.JWK.generate_key({:rsa, 2048})
    %{kid: thumbprint_kid(jwk), alg: "RS256", jwk: jwk, source: :ephemeral}
  end

  defp parse_retired(nil, _alg), do: []

  defp parse_retired(raw, alg) when is_binary(raw) do
    raw
    |> split_key_specs()
    |> Enum.flat_map(&parse_retired_entry(&1, alg))
  end


  defp parse_retired(_, _alg), do: []

  # Raw PEMs are themselves multi-line, so newline is only a separator for
  # single-line (base64 / escaped) entries. When the blob carries PEM banners,
  # split on the banners instead of shredding each key into its own lines.
  defp split_key_specs(raw) do
    if String.contains?(raw, "-----BEGIN") do
      ~r/-----BEGIN[\s\S]*?-----END[^-]*-----/
      |> Regex.scan(raw)
      |> Enum.map(fn [match] -> match end)
    else
      raw
      |> String.split([",", "\n"], trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
    end
  end

  defp parse_retired_entry(spec, alg) do
    {pinned_kid, encoded} =
      case String.split(spec, "=", parts: 2) do
        # `<kid>=<pem>` — but a bare base64 blob can contain `=` padding, so a
        # kid must look like a kid, not like key material.
        [kid, rest] when byte_size(kid) > 0 ->
          if kid_like?(kid), do: {kid, rest}, else: {nil, spec}

        _ ->
          {nil, spec}
      end

    with {:ok, pem} <- normalize_pem(encoded),
         {:ok, jwk} <- safe_jwk_from_pem(pem) do
      [%{kid: pinned_kid || thumbprint_kid(jwk), alg: alg, jwk: jwk, source: :retired}]
    else
      _ ->
        Logger.warning("[Jwks] skipping unparseable entry in MCP_JWT_PREVIOUS_KEYS")
        []
    end
  end

  defp kid_like?(kid), do: Regex.match?(~r/\A[A-Za-z0-9._:-]{1,64}\z/, kid)

  # Accepts raw PEM, base64-encoded PEM, or PEM with literal `\n` escapes.
  defp normalize_pem(nil), do: :none
  defp normalize_pem(""), do: :none

  defp normalize_pem(raw) when is_binary(raw) do
    trimmed = String.trim(raw)

    cond do
      trimmed == "" ->
        :none

      String.contains?(trimmed, "-----BEGIN") ->
        {:ok, unescape_newlines(trimmed)}

      true ->
        case Base.decode64(strip_whitespace(trimmed), padding: false) do
          {:ok, decoded} ->
            if String.contains?(decoded, "-----BEGIN"),
              do: {:ok, unescape_newlines(decoded)},
              else: {:error, :not_a_pem}

          :error ->
            {:error, :not_a_pem}
        end
    end
  end

  defp normalize_pem(_), do: {:error, :not_a_pem}

  defp unescape_newlines(pem), do: String.replace(pem, "\\n", "\n")
  defp strip_whitespace(s), do: String.replace(s, ~r/\s/, "")

  defp jwk_from_pem!(pem, source) do
    case safe_jwk_from_pem(pem) do
      {:ok, jwk} -> jwk
      {:error, why} -> raise "#{source} is not a usable private key (#{inspect(why)})"
    end
  end

  defp safe_jwk_from_pem(pem) do
    case JOSE.JWK.from_pem(pem) do
      %JOSE.JWK{} = jwk -> {:ok, jwk}
      other -> {:error, {:bad_pem, other}}
    end
  rescue
    e -> {:error, {:bad_pem, Exception.message(e)}}
  end

  # Explicit kid wins (compatibility with already-published keys); otherwise the
  # kid is derived from the key, so a rotation is always visible to clients.
  defp resolve_kid(cfg, jwk) do
    case Keyword.get(cfg, :kid) || System.get_env("MCP_JWT_KID") do
      kid when is_binary(kid) and kid != "" -> kid
      _ -> thumbprint_kid(jwk)
    end
  end

  defp thumbprint_kid(jwk), do: JOSE.JWK.thumbprint(jwk)

  defp same_key?(a, b), do: thumbprint_kid(a.jwk) == thumbprint_kid(b.jwk)

  defp put_active_first(entries, active) do
    {match, rest} = Enum.split_with(entries, &same_key?(&1, active))
    match ++ rest
  end

  defp public_key_map(entry) do
    {_kty, key_map} = entry.jwk |> JOSE.JWK.to_public() |> JOSE.JWK.to_map()

    key_map
    |> Map.put("kid", entry.kid)
    |> Map.put("alg", entry.alg)
    |> Map.put("use", "sig")
  end

  defp allow_ephemeral? do
    cond do
      System.get_env("MCP_ALLOW_EPHEMERAL_JWT_KEY") in ["true", "1"] -> true
      Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])[:allow_ephemeral_key] == true -> true
      true -> Application.get_env(:noizu_prompt_lingua, :env) != :prod
    end
  end
end
