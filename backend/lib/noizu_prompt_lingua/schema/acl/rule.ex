defmodule NoizuPromptLingua.Schema.Acl.Rule do
  @moduledoc """
  An ACL rule (Liquibase 081): `subject_ref` (a user, persona, api key, or a
  group's ref) grants or denies `action` on `resource_ref`. Subject and
  resource are ERP `{:ref, Type, id}` records (JSONB via
  `NoizuPromptLingua.Acl.ERPRef`) so rules attach to any arbitrary entity.

  Wildcards:

    * `action: "*"` — matches every action.
    * `resource_ref: {:ref, Type, :any}` — matches every resource of that kind.
    * `resource_ref: {:ref, :any, :any}` — global rule, matches all resources.

  `scope` is an opaque tag (e.g. `\"mcp\"`, `\"wiki\"`); a rule with a scope only
  applies to resolution requests for that scope, `nil` applies everywhere.

  Evaluation semantics (deny-wins) live in `NoizuPromptLingua.Acl.Resolver`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias NoizuPromptLingua.Acl.ERPRef

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "acl_rules" do
    field :subject_ref, ERPRef
    field :resource_ref, ERPRef
    field :action, :string
    field :effect, :string
    field :scope, :string
    field :priority, :integer, default: 0
    field :status, :string, default: "active"
    field :metadata, :map, default: %{}
    timestamps(type: :utc_datetime_usec)
  end

  @effects ~w(allow deny)
  @statuses ~w(active archived)
  @action_wildcard "*"

  def changeset(rule, attrs) do
    rule
    |> cast(attrs, [:subject_ref, :resource_ref, :action, :effect, :scope, :priority, :status, :metadata])
    |> validate_required([:subject_ref, :resource_ref, :action, :effect])
    |> validate_inclusion(:effect, @effects)
    |> validate_inclusion(:status, @statuses)
    |> validate_length(:action, min: 1, max: 255)
    |> validate_length(:scope, max: 255)
  end

  @doc "The action wildcard value."
  def action_wildcard, do: @action_wildcard
end
