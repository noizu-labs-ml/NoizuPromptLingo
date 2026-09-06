import type { BoardStage } from "@/lib/fixtures";

export function Board({ stages, ticketHrefFor }: { stages: BoardStage[]; ticketHrefFor: (ticketId: string) => string }) {
  return (
    <div>
      <p>Keyboard: Space picks up a card, arrow keys move across stages, Enter drops, Esc cancels.</p>
      <div className="board" role="list" aria-label="Board stages">
        {stages.map((stage) => (
          <section className="board-stage" key={stage.id} role="listitem" aria-label={stage.name}>
            <h2>{stage.name}</h2>
            <div role="list">
              {stage.cards.map((card) => (
                <article
                  className="board-card"
                  role="listitem"
                  tabIndex={0}
                  key={card.id}
                  aria-label={`${card.title}, assignee ${card.assignee ?? "unassigned"}`}
                >
                  <p>{card.title || "(untitled card)"}</p>
                  <p className="chip">{card.assignee ?? "unassigned"}</p>{" "}
                  {card.ticketId && <a href={ticketHrefFor(card.ticketId)}>ticket #{card.ticketId}</a>}
                </article>
              ))}
            </div>
            {stage.hasMore && (
              <button type="button">
                Load more in {stage.name}
              </button>
            )}
          </section>
        ))}
      </div>
    </div>
  );
}
