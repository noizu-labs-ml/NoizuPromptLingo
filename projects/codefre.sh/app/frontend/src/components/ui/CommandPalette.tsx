"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface CommandItem {
  id: string;
  label: string;
  hint?: string;
  shortcut?: string;
  group?: string;
  onSelect: () => void;
}

export interface CommandPaletteProps {
  open: boolean;
  onClose: () => void;
  items: CommandItem[];
  placeholder?: string;
  className?: string;
  cy?: string;
}

/**
 * ⌘K command palette — hand-rolled (no `cmdk` dependency). Filters by label
 * substring, arrow keys navigate, Enter activates, Esc closes.
 *
 * @example
 * <CommandPalette open={open} onClose={close} items={[
 *   {id:"new-script", label:"New Script", shortcut:"c", onSelect: create}
 * ]} />
 */
export function CommandPalette({
  open,
  onClose,
  items,
  placeholder = "Type a command or search…",
  className,
  cy = "command-palette",
}: CommandPaletteProps) {
  const [query, setQuery] = React.useState("");
  const [selectedIndex, setSelectedIndex] = React.useState(0);
  const inputRef = React.useRef<HTMLInputElement>(null);

  const filtered = React.useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return items;
    return items.filter((it) => it.label.toLowerCase().includes(q));
  }, [query, items]);

  React.useEffect(() => {
    if (!open) return;
    setQuery("");
    setSelectedIndex(0);
    const t = window.setTimeout(() => inputRef.current?.focus(), 0);
    return () => window.clearTimeout(t);
  }, [open]);

  React.useEffect(() => {
    if (!open) return;
    const handleKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        e.preventDefault();
        onClose();
        return;
      }
      if (e.key === "ArrowDown") {
        e.preventDefault();
        setSelectedIndex((i) => Math.min(i + 1, filtered.length - 1));
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        setSelectedIndex((i) => Math.max(i - 1, 0));
      } else if (e.key === "Enter" && filtered[selectedIndex]) {
        e.preventDefault();
        filtered[selectedIndex].onSelect();
        onClose();
      }
    };
    document.addEventListener("keydown", handleKey);
    return () => document.removeEventListener("keydown", handleKey);
  }, [open, filtered, selectedIndex, onClose]);

  if (!open) return null;

  return (
    <>
      <div className="sg-overlay" onClick={onClose} aria-hidden="true" />
      <div
        role="dialog"
        aria-label="Command palette"
        className={["sg-palette", className || ""].filter(Boolean).join(" ")}
        {...cyAttrs({ cy })}
      >
        <input
          ref={inputRef}
          type="text"
          value={query}
          placeholder={placeholder}
          onChange={(e) => {
            setQuery(e.target.value);
            setSelectedIndex(0);
          }}
          className="sg-palette__input"
          aria-label="Command search"
          {...cyAttrs({ cy: "palette-input" })}
        />
        <ul className="sg-palette__list" role="listbox">
          {filtered.length === 0 ? (
            <li
              className="sg-palette__item"
              aria-disabled="true"
              style={{ color: "var(--text-tertiary)" }}
            >
              No results
            </li>
          ) : (
            filtered.map((item, i) => {
              const isSelected = i === selectedIndex;
              return (
                <li
                  key={item.id}
                  role="option"
                  aria-selected={isSelected}
                  className={[
                    "sg-palette__item",
                    isSelected ? "sg-palette__item--selected" : "",
                  ]
                    .filter(Boolean)
                    .join(" ")}
                  onMouseEnter={() => setSelectedIndex(i)}
                  onClick={() => {
                    item.onSelect();
                    onClose();
                  }}
                  {...cyAttrs({ cy: "palette-item", cyId: item.id })}
                >
                  <span>
                    {item.group ? (
                      <span
                        style={{
                          color: "var(--text-tertiary)",
                          fontSize: "var(--text-caption)",
                          marginRight: 8,
                          textTransform: "uppercase",
                          letterSpacing: "0.05em",
                        }}
                      >
                        {item.group}
                      </span>
                    ) : null}
                    {item.label}
                  </span>
                  {item.shortcut ? (
                    <span className="sg-palette__shortcut">
                      {item.shortcut}
                    </span>
                  ) : null}
                </li>
              );
            })
          )}
        </ul>
      </div>
    </>
  );
}
