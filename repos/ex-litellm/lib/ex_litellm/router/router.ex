defmodule ExLiteLLM.Router do
  @moduledoc """
  The deployment router — ex-litellm's `litellm.Router`.

  Holds the live model list as mutable state (seeded from the loaded
  `config.yaml`, then mutated at runtime by `/model/new|update|delete` — which is
  how run-claude registers models with `STORE_MODEL_IN_DB=True`). Responsibilities:

    * **registry** — the authoritative set of deployments, each with a stable
      `model_id`. `Deployments` reads through here.
    * **selection** — given a requested `model_name`, resolve `model_group_alias`,
      collect the matching group, filter out cooled-down deployments, and pick
      one per the configured routing strategy (default `simple-shuffle`).
    * **cooldowns** — on a deployment failure, cool it down for `cooldown_time`
      so selection skips it (via `ExLiteLLM.Router.CooldownCache`).

  A single GenServer owns the deployment list; selection reads a snapshot and
  applies the (pure) strategy so hot-path calls don't serialize on the server.
  """
  use GenServer

  alias ExLiteLLM.Config
  alias ExLiteLLM.Router.{CooldownCache, Strategy}

  @name __MODULE__

  # --- client API ---

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, @name))
  end

  @doc "All deployments currently registered."
  @spec deployments() :: [map()]
  def deployments, do: :persistent_term.get(pt_key(), [])

  @doc "Deployments in a model group (after alias resolution)."
  @spec group(String.t()) :: [map()]
  def group(model_name) do
    resolved = resolve_alias(model_name)
    Enum.filter(deployments(), &(&1["model_name"] == resolved))
  end

  @doc "Distinct visible model_names (hidden aliases excluded)."
  @spec model_names() :: [String.t()]
  def model_names do
    deployments()
    |> Enum.map(& &1["model_name"])
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  @doc """
  Select one deployment for a requested model. Applies alias resolution,
  cooldown filtering, and the routing strategy. Returns `{:ok, deployment}` or
  `{:error, :no_deployment}`.
  """
  @spec select(String.t()) :: {:ok, map()} | {:error, :no_deployment}
  def select(model_name) do
    case group(model_name) do
      [] ->
        {:error, :no_deployment}

      candidates ->
        available = Enum.reject(candidates, &CooldownCache.cooled_down?(&1["model_id"]))
        pool = if available == [], do: candidates, else: available
        {:ok, Strategy.pick(strategy(), pool)}
    end
  end

  @doc "Register (add) a deployment. Assigns a model_id if absent. Returns the stored deployment."
  @spec add_deployment(map()) :: {:ok, map()}
  def add_deployment(deployment), do: GenServer.call(@name, {:add, deployment})

  @doc "Delete a deployment by model_id. Returns :ok or {:error, :not_found}."
  @spec delete_deployment(String.t()) :: :ok | {:error, :not_found}
  def delete_deployment(model_id), do: GenServer.call(@name, {:delete, model_id})

  @doc "Update a deployment by model_id (merges litellm_params/model_info)."
  @spec update_deployment(String.t(), map()) :: {:ok, map()} | {:error, :not_found}
  def update_deployment(model_id, changes), do: GenServer.call(@name, {:update, model_id, changes})

  @doc "Replace the entire deployment set (used when config reloads)."
  @spec set_deployments([map()]) :: :ok
  def set_deployments(list), do: GenServer.call(@name, {:set, list})

  @doc "Mark a deployment failed → cool it down."
  @spec cool_down(String.t(), term()) :: :ok
  def cool_down(model_id, reason), do: CooldownCache.add(model_id, reason, cooldown_time())

  # --- server ---

  @impl true
  def init(_opts) do
    seed = Config.get().model_list |> Enum.map(&ensure_id/1)
    publish(seed)
    {:ok, %{deployments: seed}}
  end

  @impl true
  def handle_call({:add, deployment}, _from, state) do
    stored = ensure_id(deployment)
    deployments = state.deployments ++ [stored]
    publish(deployments)
    {:reply, {:ok, stored}, %{state | deployments: deployments}}
  end

  def handle_call({:delete, model_id}, _from, state) do
    case Enum.split_with(state.deployments, &(&1["model_id"] == model_id)) do
      {[], _} ->
        {:reply, {:error, :not_found}, state}

      {_removed, kept} ->
        publish(kept)
        {:reply, :ok, %{state | deployments: kept}}
    end
  end

  def handle_call({:update, model_id, changes}, _from, state) do
    case Enum.find(state.deployments, &(&1["model_id"] == model_id)) do
      nil ->
        {:reply, {:error, :not_found}, state}

      dep ->
        updated = deep_merge(dep, changes)
        deployments = Enum.map(state.deployments, &if(&1["model_id"] == model_id, do: updated, else: &1))
        publish(deployments)
        {:reply, {:ok, updated}, %{state | deployments: deployments}}
    end
  end

  def handle_call({:set, list}, _from, state) do
    seed = Enum.map(list, &ensure_id/1)
    publish(seed)
    {:reply, :ok, %{state | deployments: seed}}
  end

  # --- helpers ---

  defp publish(deployments), do: :persistent_term.put(pt_key(), deployments)
  defp pt_key, do: {__MODULE__, :deployments}

  defp ensure_id(%{"model_info" => %{"id" => id}} = d) when is_binary(id) do
    Map.put(d, "model_id", id)
  end

  defp ensure_id(%{"model_id" => id} = d) when is_binary(id), do: d

  defp ensure_id(d) do
    id = 16 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)

    d
    |> Map.put("model_id", id)
    |> Map.update("model_info", %{"id" => id}, &Map.put(&1, "id", id))
  end

  defp resolve_alias(model_name) do
    case Config.get().router_settings["model_group_alias"] do
      %{} = aliases ->
        case Map.get(aliases, model_name) do
          alias_target when is_binary(alias_target) -> alias_target
          %{"model" => real} -> real
          _ -> model_name
        end

      _ ->
        model_name
    end
  end

  defp strategy do
    Config.get().router_settings["routing_strategy"] || "simple-shuffle"
  end

  defp cooldown_time do
    case Config.get().router_settings["cooldown_time"] do
      n when is_number(n) -> round(n * 1000)
      _ -> 60_000
    end
  end

  defp deep_merge(base, changes) do
    Map.merge(base, changes, fn
      _k, %{} = v1, %{} = v2 -> deep_merge(v1, v2)
      _k, _v1, v2 -> v2
    end)
  end
end
