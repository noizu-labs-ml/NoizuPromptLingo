defmodule Starter.Organizations.OrganizationReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Starter.Organizations.Organization
end
