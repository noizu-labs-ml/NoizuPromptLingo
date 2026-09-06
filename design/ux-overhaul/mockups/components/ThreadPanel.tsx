import type { ChatMessage } from "@/lib/fixtures";
import { fmtDate } from "@/lib/fixtures";

export function ThreadPanel({ rootMessage, replies }: { rootMessage: ChatMessage | null; replies: ChatMessage[] }) {
  return (
    <div>
      <h2>Thread</h2>
      {rootMessage ? (
        <div>
          <p>
            <strong>{rootMessage.author ?? "(deleted user)"}</strong> — {fmtDate(rootMessage.at)}
          </p>
          <p>{rootMessage.body || "(empty message)"}</p>
        </div>
      ) : (
        <p>Select a message to open its thread.</p>
      )}
      <ul>
        {replies.map((r) => (
          <li key={r.id}>
            <strong>{r.author ?? "(deleted user)"}</strong>: {r.body || "(empty message)"}
          </li>
        ))}
      </ul>
      <h3>Pinned</h3>
      <p className="chip">Pins render here from the room's pinned set.</p>
      <h3>Controls</h3>
      <p>
        <label>
          <input type="checkbox" /> Mute this room
        </label>
      </p>
      <details>
        <summary>Schedule send</summary>
        <form>
          <label>
            Send at <input type="datetime-local" />
          </label>
          <button type="submit">Schedule</button>
        </form>
      </details>
    </div>
  );
}
