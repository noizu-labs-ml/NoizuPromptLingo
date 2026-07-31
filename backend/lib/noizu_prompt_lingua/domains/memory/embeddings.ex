defmodule NoizuPromptLingua.Domains.Memory.Embeddings do
  @moduledoc """
  Text → vector embeddings behind a swappable provider. Default: OpenAI
  (`text-embedding-3-small`, 1536-d) over `req`. A `:deterministic` provider (feature-hashing)
  gives reproducible vectors for tests with no network.

  Not configured (no `OPENAI_API_KEY`, non-deterministic) → `{:error, :not_configured}`.
  """
  require Logger

  @callback embed([String.t()]) :: {:ok, [[float()]]} | {:error, term()}

  def config, do: Application.get_env(:noizu_prompt_lingua, :embeddings, [])
  def provider, do: config()[:provider] || :openai
  def dimensions, do: config()[:dimensions] || 1536
  def model, do: config()[:model] || "text-embedding-3-small"

  def configured? do
    case provider() do
      :deterministic -> true
      _ -> is_binary(config()[:api_key]) and config()[:api_key] != ""
    end
  end

  @doc "Embed a list of (non-blank) texts. Vectors returned in the same order."
  @spec embed([String.t()]) :: {:ok, [[float()]]} | {:error, term()}
  def embed([]), do: {:ok, []}

  def embed(texts) when is_list(texts) do
    case provider() do
      :deterministic -> {:ok, Enum.map(texts, &hash_embed/1)}
      _ -> if configured?(), do: do_embed(texts), else: {:error, :not_configured}
    end
  end

  @spec embed_one(String.t()) :: {:ok, [float()]} | {:error, term()}
  def embed_one(text) when is_binary(text) do
    with {:ok, [vec]} <- embed([text]), do: {:ok, vec}
  end

  defp do_embed(texts) do
    cfg = config()
    url = (cfg[:api_base] || "https://api.openai.com/v1") <> "/embeddings"

    request =
      Req.post(url,
        json: %{model: model(), input: texts},
        auth: {:bearer, cfg[:api_key]},
        receive_timeout: cfg[:timeout_ms] || 8_000
      )

    case request do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} ->
        {:ok, data |> Enum.sort_by(& &1["index"]) |> Enum.map(& &1["embedding"])}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.warning("[Memory.Embeddings] provider returned #{status}: #{inspect(body)}")
        {:error, {:http, status}}

      {:error, reason} ->
        Logger.warning("[Memory.Embeddings] request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Deterministic, offline "embedding" (tests/CI): feature-hash word tokens into `dimensions()`
  # dims and L2-normalize, so texts sharing words get similar vectors.
  defp hash_embed(text) when is_binary(text) do
    dims = dimensions()

    counts =
      text
      |> String.downcase()
      |> String.split(~r/[^a-z0-9]+/u, trim: true)
      |> Enum.reduce(%{}, fn tok, acc ->
        Map.update(acc, :erlang.phash2(tok, dims), 1.0, &(&1 + 1.0))
      end)

    vec = for i <- 0..(dims - 1), do: Map.get(counts, i, 0.0)
    norm = :math.sqrt(Enum.reduce(vec, 0.0, fn x, a -> a + x * x end))
    if norm > 0.0, do: Enum.map(vec, &(&1 / norm)), else: vec
  end

  defp hash_embed(_), do: List.duplicate(0.0, dimensions())
end
