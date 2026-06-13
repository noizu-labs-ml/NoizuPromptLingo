defmodule NoizuPromptLingua.Domains.Tickets.Queues do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{TicketQueue, Ticket}

  def create(attrs) do
    %TicketQueue{}
    |> TicketQueue.changeset(attrs)
    |> Repo.insert()
  end

  def get(slug) when is_binary(slug) do
    Repo.get_by(TicketQueue, slug: slug)
  end

  def get_by_id(id) do
    Repo.get(TicketQueue, id)
  end

  def list do
    TicketQueue
    |> order_by([q], asc: q.name)
    |> Repo.all()
  end

  def status_counts(queue_id) do
    Ticket
    |> where([t], t.queue_id == ^queue_id)
    |> group_by([t], t.status)
    |> select([t], {t.status, count(t.id)})
    |> Repo.all()
    |> Map.new()
  end
end
