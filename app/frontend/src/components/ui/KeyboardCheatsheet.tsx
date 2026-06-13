"use client";
import * as React from "react";
import { Modal } from "./Modal";
import { cyAttrs } from "@/utils/cypress";

export interface KeyboardCheatsheetProps {
  open: boolean;
  onClose: () => void;
}

interface Row {
  keys: string;
  /** Stable id used for data-cy — usually the keys string slug-ified. */
  cyId: string;
  label: string;
}

interface Group {
  heading: string;
  rows: Row[];
}

const GROUPS: Group[] = [
  {
    heading: "Navigation",
    rows: [
      { keys: "g p", cyId: "g-p", label: "Go to Prompts" },
      { keys: "g r", cyId: "g-r", label: "Go to Runs" },
      { keys: "g s", cyId: "g-s", label: "Go to Scripts" },
      { keys: "g a", cyId: "g-a", label: "Go to Agents" },
      { keys: "g e", cyId: "g-e", label: "Go to Review" },
    ],
  },
  {
    heading: "Search",
    rows: [
      { keys: "⌘ K", cyId: "cmd-k", label: "Open command palette" },
      { keys: "/", cyId: "slash", label: "Focus search on current page" },
    ],
  },
  {
    heading: "Create",
    rows: [
      { keys: "c", cyId: "c", label: "Context-aware create (on current section)" },
    ],
  },
  {
    heading: "List navigation",
    rows: [
      { keys: "j", cyId: "j", label: "Move selection down" },
      { keys: "k", cyId: "k", label: "Move selection up" },
      { keys: "Enter", cyId: "enter", label: "Open selected row" },
      { keys: "Esc", cyId: "esc", label: "Close overlay or clear selection" },
    ],
  },
  {
    heading: "Help",
    rows: [{ keys: "?", cyId: "question", label: "Show this cheat sheet" }],
  },
];

/**
 * Cheat-sheet modal rendering the current keymap as a grouped
 * two-column table (shortcut / description).
 */
export function KeyboardCheatsheet({ open, onClose }: KeyboardCheatsheetProps) {
  return (
    <Modal open={open} onClose={onClose} title="Keyboard shortcuts" cy="cheatsheet">
      <div {...cyAttrs({ cy: "cheatsheet-body" })} className="sg-cheatsheet">
        {GROUPS.map((g) => (
          <section key={g.heading} className="sg-cheatsheet__group">
            <h3 className="sg-cheatsheet__heading">{g.heading}</h3>
            <table className="sg-cheatsheet__table" role="presentation">
              <tbody>
                {g.rows.map((r) => (
                  <tr
                    key={r.cyId}
                    className="sg-cheatsheet__row"
                    {...cyAttrs({ cy: "cheatsheet-row", cyId: r.cyId })}
                  >
                    <th scope="row" className="sg-cheatsheet__keys">
                      <kbd className="sg-cheatsheet__kbd">{r.keys}</kbd>
                    </th>
                    <td className="sg-cheatsheet__label">{r.label}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </section>
        ))}
      </div>
    </Modal>
  );
}
