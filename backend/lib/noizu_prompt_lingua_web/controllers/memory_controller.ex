defmodule NoizuPromptLinguaWeb.MemoryController do
  @moduledoc """
  Org-authenticated REST surface for the agent-memory browser. Memory is addressed per agent:
  `/api/organization/:org_id/agent/:agent_slug/memory/*`. The `:org_id` path segment is an org slug
  or uuid; `agent_slug` resolves within it to a scope — a call sign (weego/team_member) or a persona slug, with
  the literal "weego" meaning the org's weego. Visibility is enforced by the engine
  (persona/team_member see only their own; weego sees its org).

  The org `:agents` listing (scope selector) lives at `/api/organization/:org_id/agents`.
  """
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Memory
  alias NoizuPromptLingua.Domains.Memory.Agents
  alias NoizuPromptLingua.Domains.Memory.Tools.Scope, as: MemView
  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.MCP.Resolve

  @doc "GET /api/organization/:org_id/agents — scope selector options (personas + call signs)."
  def agents(conn, params) do
    case Resolve.organization_id(params["org_id"]) do
      nil ->
        not_found(conn)

      org_id ->
        personas =
          Personas.list(organization_id: org_id, status: "active")
          |> Enum.map(fn p ->
            %{scope_type: "persona", scope_id: p.id, slug: p.slug, label: p.name || p.slug}
          end)

        signs =
          Agents.list(org_id, status: "active")
          |> Enum.map(fn a ->
            %{
              scope_type: to_string(a.kind),
              scope_id: a.id,
              slug: a.call_sign,
              label: a.display_name || a.call_sign
            }
          end)

        json(conn, %{agents: personas ++ signs})
    end
  end

  @doc "GET /api/organization/:org_id/agent/:agent_slug/memory — recent memories for the agent."
  def list(conn, params) do
    with {:ok, context} <- build_context(params) do
      {:ok, %{results: results}} = Memory.recent([limit: limit(params)], context)
      json(conn, %{results: Enum.map(results, &MemView.memory_view/1)})
    else
      err -> error(conn, err)
    end
  end

  @doc "POST /api/organization/:org_id/agent/:agent_slug/memory/recall — active multi-path recall by text query."
  def recall(conn, params) do
    with {:ok, context} <- build_context(params) do
      {:ok, %{results: results}} =
        Memory.recall(params["query"] || "", [limit: limit(params)], context)

      json(conn, %{results: Enum.map(results, &MemView.memory_view/1)})
    else
      err -> error(conn, err)
    end
  end

  @doc "POST /api/organization/:org_id/agent/:agent_slug/memory/recall_by_emotion — emotional-resonance recall."
  def recall_by_emotion(conn, params) do
    with {:ok, context} <- build_context(params) do
      mp = params["mood"] || %{}

      mood = %{
        valence: num(mp["valence"], 0.0),
        arousal: num(mp["arousal"], 0.5),
        dominance: num(mp["dominance"], 0.5)
      }

      {:ok, %{results: results}} =
        Memory.recall_by_emotion(%{mood: mood}, [limit: limit(params)], context)

      json(conn, %{results: Enum.map(results, &MemView.memory_view/1)})
    else
      err -> error(conn, err)
    end
  end

  @doc "GET /api/organization/:org_id/agent/:agent_slug/memory/:id/associations — association edges of a memory."
  def associations(conn, %{"id" => memory_id} = params) do
    with {:ok, context} <- build_context(params) do
      edges =
        Memory.associations(memory_id, context)
        |> Enum.map(fn e ->
          %{
            id: e.id,
            source_memory_id: e.source_memory_id,
            target_memory_id: e.target_memory_id,
            edge_type: to_string(e.edge_type),
            weight: e.weight,
            reason: e.reason
          }
        end)

      json(conn, %{edges: edges})
    else
      err -> error(conn, err)
    end
  end

  # ── helpers ─────────────────────────────────────────────────────
  # Resolve org (from the :org_id path segment) + agent_slug (path) into the engine context.
  defp build_context(%{"agent_slug" => slug} = params) do
    case Resolve.organization_id(params["org_id"]) do
      nil ->
        {:error, :org_not_found}

      org_id ->
        case Agents.resolve_agent(org_id, slug) do
          {:ok, scope} ->
            {:ok,
             Map.merge(scope, %{requester_id: to_string(scope.scope_id), source_agent: "web"})}

          {:error, _} ->
            {:error, :agent_not_found}
        end
    end
  end

  defp build_context(_), do: {:error, :agent_not_found}

  defp limit(params), do: trunc(num(params["limit"], 20))

  defp num(nil, default), do: default
  defp num(n, _default) when is_number(n), do: n

  defp num(s, default) when is_binary(s) do
    case Float.parse(s) do
      {f, _} -> f
      :error -> default
    end
  end

  defp num(_, default), do: default

  defp error(conn, {:error, :org_not_found}), do: not_found(conn)

  defp error(conn, _),
    do: conn |> put_status(:not_found) |> json(%{error: "agent not found in this organization"})

  defp not_found(conn),
    do: conn |> put_status(:not_found) |> json(%{error: "organization not found"})
end
