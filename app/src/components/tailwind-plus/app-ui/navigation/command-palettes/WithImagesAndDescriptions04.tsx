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
import { MagnifyingGlassIcon } from '@heroicons/react/20/solid'
import {
  Bars4Icon,
  CalendarIcon,
  CodeBracketIcon,
  DocumentIcon,
  ExclamationCircleIcon,
  LinkIcon,
  PencilSquareIcon,
  PhotoIcon,
  TableCellsIcon,
  VideoCameraIcon,
  ViewColumnsIcon,
} from '@heroicons/react/24/outline'
import { useState } from 'react'

const items = [
  {
    id: 1,
    name: 'Text',
    description: 'Add freeform text with basic formatting options.',
    url: '#',
    color: 'bg-indigo-500',
    icon: PencilSquareIcon,
  },
  // More items...
]

function classNames(...classes) {
  return classes.filter(Boolean).join(' ')
}

export function WithImagesAndDescriptions04() {
  const [query, setQuery] = useState('')
  const [open, setOpen] = useState(true)

  const filteredItems =
    query === ''
      ? []
      : items.filter((item) => {
          return item.name.toLowerCase().includes(query.toLowerCase())
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
          className="mx-auto max-w-xl transform divide-y divide-gray-100 overflow-hidden rounded-xl bg-white shadow-2xl outline-1 outline-black/5 transition-all data-closed:scale-95 data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in dark:divide-white/10 dark:bg-gray-900 dark:-outline-offset-1 dark:outline-white/10"
        >
          <Combobox
            onChange={(item) => {
              if (item) {
                window.location = item.url
              }
            }}
          >
            <div className="grid grid-cols-1">
              <ComboboxInput
                autoFocus
                className="col-start-1 row-start-1 h-12 w-full pr-4 pl-11 text-base text-gray-900 outline-hidden placeholder:text-gray-400 sm:text-sm dark:bg-gray-900 dark:text-white dark:placeholder:text-gray-500"
                placeholder="Search..."
                onChange={(event) => setQuery(event.target.value)}
                onBlur={() => setQuery('')}
              />
              <MagnifyingGlassIcon
                className="pointer-events-none col-start-1 row-start-1 ml-4 size-5 self-center text-gray-400 dark:text-gray-500"
                aria-hidden="true"
              />
            </div>

            {filteredItems.length > 0 && (
              <ComboboxOptions static className="max-h-96 transform-gpu scroll-py-3 overflow-y-auto p-3">
                {filteredItems.map((item) => (
                  <ComboboxOption
                    key={item.id}
                    value={item}
                    className="group flex cursor-default rounded-xl p-3 select-none data-focus:bg-gray-100 data-focus:outline-hidden dark:data-focus:bg-white/5"
                  >
                    <div
                      className={classNames(
                        'flex size-10 flex-none items-center justify-center rounded-lg',
                        item.color,
                      )}
                    >
                      <item.icon className="size-6 text-white" aria-hidden="true" />
                    </div>
                    <div className="ml-4 flex-auto">
                      <p className="text-sm font-medium text-gray-700 group-data-focus:text-gray-900 dark:text-gray-300 dark:group-data-focus:text-white">
                        {item.name}
                      </p>
                      <p className="text-sm text-gray-500 group-data-focus:text-gray-700 dark:text-gray-400 dark:group-data-focus:text-gray-300">
                        {item.description}
                      </p>
                    </div>
                  </ComboboxOption>
                ))}
              </ComboboxOptions>
            )}

            {query !== '' && filteredItems.length === 0 && (
              <div className="px-6 py-14 text-center text-sm sm:px-14">
                <ExclamationCircleIcon
                  type="outline"
                  name="exclamation-circle"
                  className="mx-auto size-6 text-gray-400 dark:text-gray-500"
                />
                <p className="mt-4 font-semibold text-gray-900 dark:text-white">No results found</p>
                <p className="mt-2 text-gray-500 dark:text-gray-400">
                  No components found for this search term. Please try again.
                </p>
              </div>
            )}
          </Combobox>
        </DialogPanel>
      </div>
    </Dialog>
  )
}
