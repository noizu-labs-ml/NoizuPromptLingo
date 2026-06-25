defmodule NoizuPromptLingua.Domains.Memory.Agents do
  @moduledoc """
  Call-sign registry for memory-owning agent identities: the `weego` (orchestrator) and ephemeral
  `team_member` sub-agents. Each is org-scoped with a unique, memorable `call_sign` (caller-supplied
  or auto-generated). Personas own memory directly via `personas.id`, so they are NOT registered
  here — `resolve_scope/3` bridges the persona case to the personas domain.
  """
  import Ecto.Query

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Memory.AgentCallSign
  alias NoizuPromptLingua.Domains.Personas

  # Aviation/NATO-flavored handles for auto-generation.
  @handles ~w(maverick viper ghost raven falcon cobra nomad echo nova phoenix talon zephyr
              specter saber comet drift ranger vortex onyx ember halo jet kilo lynx orca
              rogue sage tundra wraith zenith aria atlas bishop cinder)

  @doc """
  Register (or fetch) an agent identity. `kind` is `:weego | :team_member`. Opts:
    * `:call_sign`    — desired handle (unique per org); auto-generated if omitted
    * `:display_name` — human label
    * `:persona_id`   — optional link to a persona
  """
  def register(org_id, kind, opts \\ []) when kind in [:weego, :team_member] do
    call_sign = normalize(opts[:call_sign]) || generate_call_sign(org_id)

    %AgentCallSign{}
    |> AgentCallSign.changeset(%{
      organization_id: org_id,
      kind: kind,
      call_sign: call_sign,
      display_name: opts[:display_name],
      persona_id: opts[:persona_id],
      metadata: opts[:metadata] || %{}
    })
    |> Repo.insert()
  end

  @doc "Resolve a UUID or (org-scoped) call sign to an `AgentCallSign`."
  def resolve(org_id, id_or_call_sign) do
    case Ecto.UUID.cast(id_or_call_sign) do
      {:ok, uuid} ->
        Repo.get(AgentCallSign, uuid) ||
          Repo.get_by(AgentCallSign, organization_id: org_id, call_sign: to_string(id_or_call_sign))

      :error ->
        Repo.get_by(AgentCallSign, organization_id: org_id, call_sign: normalize(id_or_call_sign))
    end
  end

  @doc """
  Resolve a `{scope_type, ref}` to a scope map `%{organization_id, scope_type, scope_id}` usable as
  the memory engine context. `ref` is a call sign (weego/team_member) or persona slug/uuid; for the
  `weego` scope it may be omitted to mean the org's weego identity.
  """
  def resolve_scope(org_id, :persona, ref) do
    case Personas.resolve(org_id, ref) do
      nil -> {:error, :persona_not_found}
      persona -> {:ok, scope(org_id, :persona, persona.id)}
    end
  end

  def resolve_scope(org_id, :weego, ref) when ref in [nil, ""] do
    case Repo.one(
           from a in AgentCallSign,
             where: a.organization_id == ^org_id and a.kind == :weego and a.status == "active",
             order_by: [asc: a.inserted_at],
             limit: 1
         ) do
      nil -> {:error, :agent_not_found}
      %{id: id} -> {:ok, scope(org_id, :weego, id)}
    end
  end

  def resolve_scope(org_id, kind, ref) when kind in [:weego, :team_member] do
    case resolve(org_id, ref) do
      nil -> {:error, :agent_not_found}
      %{id: id} -> {:ok, scope(org_id, kind, id)}
    end
  end

  def resolve_scope(_org, type, _ref), do: {:error, {:bad_scope_type, type}}

  @doc """
  Resolve a unified agent slug to a scope, trying (1) the call-sign registry (weego/team_member),
  then (2) personas. The literal "weego" (or blank) resolves to the org's weego identity.
  """
  def resolve_agent(org_id, slug) when slug in ["weego", nil, ""] do
    resolve_scope(org_id, :weego, nil)
  end

  def resolve_agent(org_id, slug) do
    case resolve(org_id, slug) do
      %{id: id, kind: kind} ->
        {:ok, scope(org_id, kind, id)}

      nil ->
        case Personas.resolve(org_id, slug) do
          nil -> {:error, :agent_not_found}
          p -> {:ok, scope(org_id, :persona, p.id)}
        end
    end
  end

  defp scope(org_id, scope_type, scope_id),
    do: %{organization_id: org_id, scope_type: scope_type, scope_id: scope_id}

  def list(org_id, opts \\ []) do
    AgentCallSign
    |> where([a], a.organization_id == ^org_id)
    |> maybe_filter(:kind, opts[:kind])
    |> maybe_filter(:status, opts[:status])
    |> order_by([a], asc: a.call_sign)
    |> limit(^(opts[:limit] || 200))
    |> Repo.all()
  end

  def archive(id) do
    case Repo.get(AgentCallSign, id) do
      nil -> {:error, :not_found}
      cs -> cs |> AgentCallSign.changeset(%{status: "archived"}) |> Repo.update()
    end
  end

  # ── call-sign generation ────────────────────────────────────────
  defp generate_call_sign(org_id), do: generate_call_sign(org_id, 0)

  defp generate_call_sign(_org_id, attempts) when attempts > 50 do
    # Extremely unlikely; fall back to a uuid-suffixed handle.
    "agent-" <> (Ecto.UUID.generate() |> String.slice(0, 8))
  end

  defp generate_call_sign(org_id, attempts) do
    base = Enum.at(@handles, :rand.uniform(length(@handles)) - 1)
    candidate = if attempts == 0, do: base, else: "#{base}-#{:rand.uniform(99)}"

    if taken?(org_id, candidate) do
      generate_call_sign(org_id, attempts + 1)
    else
      candidate
    end
  end

  defp taken?(org_id, call_sign) do
    Repo.exists?(from a in AgentCallSign, where: a.organization_id == ^org_id and a.call_sign == ^call_sign)
  end

  defp normalize(nil), do: nil
  defp normalize(s) when is_binary(s), do: s |> String.trim() |> String.downcase()

  defp maybe_filter(query, _field, nil), do: query
  defp maybe_filter(query, field, value), do: where(query, [a], field(a, ^field) == ^value)
end
