defmodule CodefreshSdk do
  @moduledoc """
  Elixir SDK for the CodeFresh eval platform (US-092).

  ## Quickstart

      client = CodefreshSdk.new(token: "cf_...", api_url: "https://api.codefre.sh")

      {:ok, runs} = CodefreshSdk.Runs.list(client, organization_id: org_id)
      {:ok, run} = CodefreshSdk.Runs.create(client, org_id, script_id: "...", agent_id: "...")

  ## Webhook signature verification (US-144)

      signature = get_req_header(conn, "x-codefresh-signature") |> List.first()

      case CodefreshSdk.verify_webhook_signature(secret, body, signature) do
        :ok -> handle_event(Jason.decode!(body))
        {:error, :invalid_signature} -> send_resp(conn, 401, "")
      end
  """

  alias __MODULE__.{Client, Error}

  defdelegate new(opts \\ []), to: Client

  # ──────────────────────────────────────────────────────────────────────────
  # Webhook HMAC verification
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Constant-time verification of the `X-Codefresh-Signature` header.

  The backend emits `sha256=<hex>`; this recomputes the MAC and compares.
  Returns `:ok` on match, `{:error, :invalid_signature}` otherwise.
  """
  @spec verify_webhook_signature(binary(), binary(), binary() | nil) ::
          :ok | {:error, :invalid_signature}
  def verify_webhook_signature(secret, body, "sha256=" <> hex)
      when is_binary(secret) and is_binary(body) do
    expected = :crypto.mac(:hmac, :sha256, secret, body) |> Base.encode16(case: :lower)

    if Plug.Crypto.secure_compare(expected, hex) do
      :ok
    else
      {:error, :invalid_signature}
    end
  rescue
    # Allow callers who don't have :plug_crypto to still verify (fall back to
    # constant-time compare via :crypto).
    UndefinedFunctionError -> fallback_compare(secret, body, hex)
  end

  def verify_webhook_signature(_secret, _body, _sig), do: {:error, :invalid_signature}

  defp fallback_compare(secret, body, hex) do
    expected = :crypto.mac(:hmac, :sha256, secret, body) |> Base.encode16(case: :lower)

    if byte_size(expected) == byte_size(hex) and
         :crypto.hash_equals(expected, hex) do
      :ok
    else
      {:error, :invalid_signature}
    end
  rescue
    _ -> {:error, :invalid_signature}
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Client struct + HTTP plumbing
  # ──────────────────────────────────────────────────────────────────────────

  defmodule Client do
    @moduledoc false
    @enforce_keys [:api_url, :token]
    defstruct [:api_url, :token, :req_opts]

    @doc """
    Build a client. Token defaults to `System.get_env("CODEFRESH_API_TOKEN")`.
    """
    def new(opts \\ []) do
      token = Keyword.get(opts, :token) || System.get_env("CODEFRESH_API_TOKEN")
      api_url = Keyword.get(opts, :api_url, "https://api.codefre.sh")

      if is_nil(token), do: raise("missing CODEFRESH_API_TOKEN")

      %__MODULE__{
        api_url: String.trim_trailing(api_url, "/"),
        token: token,
        req_opts: Keyword.get(opts, :req_opts, [])
      }
    end

    @doc false
    def request(%__MODULE__{} = c, method, path, body \\ nil) do
      url = c.api_url <> path
      headers = [{"authorization", "Bearer " <> c.token}, {"content-type", "application/json"}]

      opts = Keyword.merge([method: method, url: url, headers: headers], c.req_opts)
      opts = if is_nil(body), do: opts, else: Keyword.put(opts, :json, body)

      case Req.request(opts) do
        {:ok, %{status: s, body: b}} when s in 200..299 -> {:ok, b}
        {:ok, %{status: s, body: b}} -> {:error, CodefreshSdk.Error.from_response(s, b)}
        {:error, reason} -> {:error, %CodefreshSdk.Error{kind: :transport, detail: reason}}
      end
    end
  end

  defmodule Error do
    @moduledoc "Typed SDK error. `kind` is one of :auth | :not_found | :validation | :rate_limited | :cost_cap | :server | :transport."
    defstruct [:kind, :status, :detail]

    @type t :: %__MODULE__{kind: atom(), status: integer() | nil, detail: any()}

    def from_response(status, body) do
      kind =
        cond do
          status in [401, 403] -> :auth
          status == 404 -> :not_found
          status == 422 -> :validation
          status == 429 -> :rate_limited
          status == 402 -> :cost_cap
          status >= 500 -> :server
          true -> :server
        end

      %__MODULE__{kind: kind, status: status, detail: body}
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Resource modules
  # ──────────────────────────────────────────────────────────────────────────

  defmodule Runs do
    @moduledoc false
    alias CodefreshSdk.Client

    def list(%Client{} = c, organization_id: org_id) do
      Client.request(c, :get, "/api/v1/organizations/#{org_id}/runs")
    end

    def get(%Client{} = c, org_id, run_id) do
      Client.request(c, :get, "/api/v1/organizations/#{org_id}/runs/#{run_id}")
    end

    def create(%Client{} = c, org_id, opts) do
      body = Map.new(opts)
      Client.request(c, :post, "/api/v1/organizations/#{org_id}/runs", body)
    end
  end

  defmodule Scripts do
    @moduledoc false
    alias CodefreshSdk.Client

    def list(%Client{} = c, org_id),
      do: Client.request(c, :get, "/api/v1/organizations/#{org_id}/scripts")

    def import_yaml(%Client{} = c, org_id, yaml) when is_binary(yaml) do
      Client.request(c, :post, "/api/v1/organizations/#{org_id}/scripts/import", %{yaml: yaml})
    end
  end

  defmodule Webhooks do
    @moduledoc false
    alias CodefreshSdk.Client

    def list(%Client{} = c, org_id),
      do: Client.request(c, :get, "/api/v1/organizations/#{org_id}/webhooks")

    @doc """
    Create a webhook. The response includes `"secret"` — store immediately,
    it won't be shown again.
    """
    def create(%Client{} = c, org_id, attrs) when is_map(attrs) do
      Client.request(c, :post, "/api/v1/organizations/#{org_id}/webhooks", %{webhook: attrs})
    end
  end
end
