"use client";

import clsx from "clsx";
import { Listbox, ListboxButton, ListboxOptions, ListboxOption } from "@headlessui/react";
import { ChevronUpDownIcon, CheckIcon } from "@heroicons/react/20/solid";

export interface FilterOption {
  value: string;
  label: string;
}

export interface FilterListboxProps {
  label: string;
  options: FilterOption[];
  selected: string[];
  onChange: (values: string[]) => void;
}

export function FilterListbox({
  label,
  options,
  selected,
  onChange,
}: FilterListboxProps) {
  const selectedCount = selected.length;

  return (
    <div className="relative">
      <Listbox value={selected} onChange={onChange} multiple>
        <ListboxButton
          className={clsx(
            "flex items-center gap-2 rounded-md border border-border bg-surface-sunken",
            "px-3 py-2 text-sm text-foreground",
            "hover:border-border-strong focus:outline-none focus:border-accent transition-colors"
          )}
        >
          <span className="text-muted">{label}</span>
          {selectedCount > 0 && (
            <span className="rounded-full bg-accent/20 text-accent px-1.5 py-0.5 text-xs font-medium">
              {selectedCount}
            </span>
          )}
          <ChevronUpDownIcon className="h-4 w-4 text-muted ml-auto" />
        </ListboxButton>

        <ListboxOptions
          className={clsx(
            "absolute z-20 mt-1 min-w-[180px] w-full",
            "rounded-lg border border-border bg-surface-raised shadow-lg",
            "py-1 focus:outline-none"
          )}
        >
          {options.map((opt) => (
            <ListboxOption
              key={opt.value}
              value={opt.value}
              className={({ focus }: { focus: boolean }) =>
                clsx(
                  "flex items-center gap-2 px-3 py-2 text-sm cursor-pointer select-none",
                  focus ? "bg-surface text-foreground" : "text-foreground"
                )
              }
            >
              {({ selected: isSelected }: { selected: boolean }) => (
                <>
                  <span
                    className={clsx(
                      "flex h-4 w-4 items-center justify-center rounded border",
                      isSelected
                        ? "border-accent bg-accent/20 text-accent"
                        : "border-border"
                    )}
                  >
                    {isSelected && <CheckIcon className="h-3 w-3" />}
                  </span>
                  {opt.label}
                </>
              )}
            </ListboxOption>
          ))}
        </ListboxOptions>
      </Listbox>
    </div>
  );
}
