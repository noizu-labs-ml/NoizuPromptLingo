defmodule Starter.Projects.ProjectReference do
  use Noizu.Entity.ReferenceBehaviour,
    identifier_type: :uuid,
    entity: Starter.Projects.Project
end
