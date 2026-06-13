defmodule Codefresh.Agents.Adapters.HTTP do
  @moduledoc """
  Generic HTTP/webhook adapter (US-063). Points at an arbitrary URL and
  expresses the request payload via `request_template` + pulls the response
  text via `response_jsonpath`.

  Required config:
    * `:endpoint_url` — must be http(s)://
    * `:auth_ref` — secret_ref OR `%{"type" => "none"}` if truly unauthenticated
    * `:response_jsonpath` — non-empty string (e.g. `$.choices[0].text`)

  Optional:
    * `:headers` — map of string → string
    * `:request_template` — map; `streaming` boolean supported
  """

  @behaviour Codefresh.Agents.Adapters.Behaviour

  @impl true
  def validate_config(config) do
    with :ok <- validate_endpoint(config),
         :ok <- validate_auth(config),
         :ok <- validate_headers(config),
         :ok <- validate_jsonpath(config),
         :ok <- validate_streaming(config) do
      :ok
    end
  end

  @impl true
  def health_check(config) do
    case validate_config(config) do
      :ok -> {:ok, :config_valid}
      {:error, _} = e -> e
    end
  end

  @impl true
  def invoke(config, request),
    do: Codefresh.Agents.Adapters.Stub.invoke("http", config, request)

  defp validate_endpoint(config) do
    case fetch(config, :endpoint_url) do
      url when is_binary(url) ->
        if Regex.match?(~r{^https?://.+}, url),
          do: :ok,
          else: {:error, "endpoint_url must start with http:// or https://"}

      _ ->
        {:error, "endpoint_url is required"}
    end
  end

  defp validate_auth(config) do
    case fetch(config, :auth_ref) do
      %{} = m ->
        t = Map.get(m, "type") || Map.get(m, :type)

        cond do
          t == "none" ->
            :ok

          t == "secret_ref" ->
            r = Map.get(m, "ref") || Map.get(m, :ref)

            if is_binary(r) and r != "",
              do: :ok,
              else: {:error, "auth_ref.ref must be non-empty"}

          true ->
            {:error, "auth_ref.type must be 'secret_ref' or 'none'"}
        end

      _ ->
        {:error, "auth_ref is required ({type: 'none'} permitted for open endpoints)"}
    end
  end

  defp validate_headers(config) do
    case fetch(config, :headers) do
      nil -> :ok
      %{} = h -> if Enum.all?(h, &header_pair?/1), do: :ok, else: {:error, "headers must be string → string"}
      _ -> {:error, "headers must be a map"}
    end
  end

  defp header_pair?({k, v}), do: is_binary(k) and is_binary(v)

  defp validate_jsonpath(config) do
    case fetch(config, :response_jsonpath) do
      s when is_binary(s) and s != "" -> :ok
      _ -> {:error, "response_jsonpath is required"}
    end
  end

  defp validate_streaming(config) do
    tmpl = fetch(config, :request_template) || %{}

    case Map.get(tmpl, "streaming") || Map.get(tmpl, :streaming) do
      nil -> :ok
      b when is_boolean(b) -> :ok
      _ -> {:error, "request_template.streaming must be boolean"}
    end
  end

  defp fetch(config, key) when is_atom(key),
    do: Map.get(config, key) || Map.get(config, to_string(key))
end
