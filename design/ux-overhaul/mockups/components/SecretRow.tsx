import type { SecretKey } from "@/lib/fixtures";
import { fmtDate } from "@/lib/fixtures";

export function SecretRow({ secret }: { secret: SecretKey }) {
  return (
    <tr>
      <td>{secret.label || "(unnamed key)"}</td>
      <td className="chip">{secret.scope}</td>
      <td>{secret.revealed ? "sk_live_••••1234 (shown once)" : "•••• (reveal-once)"}</td>
      <td>{fmtDate(secret.lastUsed)}</td>
      <td>
        <button type="button">Reveal once</button> <button type="button">Rotate</button>{" "}
        <button type="button">Revoke</button>
      </td>
    </tr>
  );
}
