// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck

'use client'

import {
  Combobox,
  ComboboxInput,
  ComboboxOption,
  ComboboxOptions,
  Dialog,
  DialogPanel,
  DialogBackdrop,
} from '@headlessui/react'
import { UsersIcon } from '@heroicons/react/24/outline'
import { useState } from 'react'

const people = [
  { id: 1, name: 'Leslie Alexander', url: '#' },
  // More people...
]

export function SimpleWithPadding02() {
  const [query, setQuery] = useState('')
  const [open, setOpen] = useState(true)

  const filteredPeople =
    query === ''
      ? []
      : people.filter((person) => {
          return person.name.toLowerCase().includes(query.toLowerCase())
        })

  return (
    <Dialog
      className="relative z-10"
      open={open}
      onClose={() => {
        setOpen(false)
        setQuery('')
      }}
    >
      <DialogBackdrop
        transition
        className="fixed inset-0 bg-gray-500/25 transition-opacity data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in dark:bg-gray-900/50"
      />

      <div className="fixed inset-0 z-10 w-screen overflow-y-auto p-4 sm:p-6 md:p-20">
        <DialogPanel
          transition
          className="mx-auto max-w-xl transform rounded-xl bg-white p-2 shadow-2xl outline-1 outline-black/5 transition-all data-closed:scale-95 data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in dark:bg-gray-900 dark:-outline-offset-1 dark:outline-white/10"
        >
          <Combobox
            onChange={(person) => {
              if (person) {
                window.location = person.url
              }
            }}
          >
            <ComboboxInput
              autoFocus
              className="w-full rounded-md bg-gray-100 px-4 py-2.5 text-gray-900 outline-hidden placeholder:text-gray-500 sm:text-sm dark:bg-white/5 dark:text-white dark:placeholder:text-gray-400"
              placeholder="Search..."
              onChange={(event) => setQuery(event.target.value)}
              onBlur={() => setQuery('')}
            />

            {filteredPeople.length > 0 && (
              <ComboboxOptions
                static
                className="-mb-2 max-h-72 scroll-py-2 overflow-y-auto py-2 text-sm text-gray-800 dark:text-gray-200"
              >
                {filteredPeople.map((person) => (
                  <ComboboxOption
                    key={person.id}
                    value={person}
                    className="cursor-default rounded-md px-4 py-2 select-none data-focus:bg-indigo-600 data-focus:text-white data-focus:outline-hidden dark:data-focus:bg-indigo-500"
                  >
                    {person.name}
                  </ComboboxOption>
                ))}
              </ComboboxOptions>
            )}

            {query !== '' && filteredPeople.length === 0 && (
              <div className="px-4 py-14 text-center sm:px-14">
                <UsersIcon className="mx-auto size-6 text-gray-400 dark:text-gray-500" aria-hidden="true" />
                <p className="mt-4 text-sm text-gray-900 dark:text-gray-200">No people found using that search term.</p>
              </div>
            )}
          </Combobox>
        </DialogPanel>
      </div>
    </Dialog>
  )
}
