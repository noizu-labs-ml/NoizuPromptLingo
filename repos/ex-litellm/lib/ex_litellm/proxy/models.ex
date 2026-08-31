defmodule ExLiteLLM.Proxy.Models do
  @moduledoc """
  Model-management endpoints — litellm's `model_management_endpoints`.

  This is the surface run-claude drives to register models at runtime (it POSTs
  each profile's models to `/model/new`, reads `/model/info`, and removes them
  via `/model/delete` on `leave`). Implemented against the live `ExLiteLLM.Router`
  registry:

    * `POST /model/new`    — add a deployment `{model_name, litellm_params, model_info}`
    * `POST /model/delete` — remove by `id`
    * `POST /model/update` — edit a deployment's params
    * `GET  /model/info`   — list deployments (api_key redacted)
    * `GET  /v1/models`    — OpenAI-shaped model list

  All are master-key gated by the caller (the endpoint router runs auth first).
  """

  import Plug.Conn

  alias ExLiteLLM.Error
  alias ExLiteLLM.Router

  @doc "POST /model/new — register a deployment."
  def new(conn) do
    body = body(conn)

    case body do
      %{"model_name" => name} when is_binary(name) ->
        {:ok, stored} = Router.add_deployment(normalize(body))

        json(conn, 200, %{
          message: "Model #{name} added successfully",
          model_id: stored["model_id"]
        })

      _ ->
        json(conn, 400, Error.to_body(Error.new(400, "model_name is required", type: "invalid_request_error")))
    end
  end

  @doc "POST /model/delete — remove a deployment by id."
  def delete(conn) do
    body = body(conn)
    id = body["id"] || body["model_id"]

    cond do
      is_nil(id) ->
        json(conn, 400, Error.to_body(Error.new(400, "id is required", type: "invalid_request_error")))

      Router.delete_deployment(id) == :ok ->
        json(conn, 200, %{message: "Model #{id} deleted successfully"})

      true ->
        json(conn, 404, Error.to_body(Error.new(404, "model #{id} not found", type: "not_found_error")))
    end
  end

  @doc "POST /model/update — edit a deployment's params."
  def update(conn) do
    body = body(conn)
    id = body["id"] || body["model_id"]

    case id && Router.update_deployment(id, normalize(Map.drop(body, ["id", "model_id"]))) do
      {:ok, updated} -> json(conn, 200, %{message: "Model #{id} updated", model_id: updated["model_id"]})
      {:error, :not_found} -> json(conn, 404, Error.to_body(Error.new(404, "model #{id} not found", type: "not_found_error")))
      _ -> json(conn, 400, Error.to_body(Error.new(400, "id is required", type: "invalid_request_error")))
    end
  end

  @doc "GET /model/info — deployment list with credentials redacted."
  def info(conn) do
    data = Enum.map(Router.deployments(), &redact/1)
    json(conn, 200, %{data: data})
  end

  # --- helpers ---

  defp normalize(deployment) do
    deployment
    |> Map.put_new("litellm_params", %{})
    |> Map.put_new("model_info", %{})
  end

  # Redact secrets from litellm_params before returning to a client.
  defp redact(%{"litellm_params" => lp} = deployment) when is_map(lp) do
    scrubbed =
      Enum.reduce(["api_key", "aws_secret_access_key", "vertex_credentials"], lp, fn key, acc ->
        if Map.has_key?(acc, key), do: Map.put(acc, key, "****"), else: acc
      end)

    Map.put(deployment, "litellm_params", scrubbed)
  end

  defp redact(deployment), do: deployment

  defp body(conn), do: conn.assigns[:json_body] || %{}

  defp json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
