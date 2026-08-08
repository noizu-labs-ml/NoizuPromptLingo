defmodule NoizuPromptLingua.Workers.Memory.LinkJob do
  @moduledoc """
  Runs the Weaver for a memory after its embeddings land — creates the association edges
  (temporal/contextual always; emotional/tangent/semantic via Weaviate).
  """
  use Oban.Worker, queue: :memory, max_attempts: 3, unique: [keys: [:memory_id], period: 120]

  alias NoizuPromptLingua.Domains.Memory.Weaver

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"memory_id" => id}}) do
    Weaver.link(id)
    :ok
  end
end
