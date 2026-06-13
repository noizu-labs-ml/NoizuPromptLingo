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
import { DocumentPlusIcon, FolderIcon, FolderPlusIcon, HashtagIcon, TagIcon } from '@heroicons/react/24/outline'
import { useState } from 'react'

const projects = [
  { id: 1, name: 'Workflow Inc. / Website Redesign', url: '#' },
  // More projects...
]
const recent = [projects[0]]
const quickActions = [
  { name: 'Add new file...', icon: DocumentPlusIcon, shortcut: 'N', url: '#' },
  { name: 'Add new folder...', icon: FolderPlusIcon, shortcut: 'F', url: '#' },
  { name: 'Add hashtag...', icon: HashtagIcon, shortcut: 'H', url: '#' },
  { name: 'Add label...', icon: TagIcon, shortcut: 'L', url: '#' },
]

export function WithIcons05() {
  const [query, setQuery] = useState('')
  const [open, setOpen] = useState(true)

  const filteredProjects =
    query === ''
      ? []
      : projects.filter((project) => {
          return project.name.toLowerCase().includes(query.toLowerCase())
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
          className="mx-auto max-w-2xl transform divide-y divide-gray-100 overflow-hidden rounded-xl bg-white shadow-2xl outline-1 outline-black/5 transition-all data-closed:scale-95 data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in dark:divide-white/10 dark:bg-gray-900 dark:-outline-offset-1 dark:outline-white/10"
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

            {(query === '' || filteredProjects.length > 0) && (
              <ComboboxOptions
                static
                as="ul"
                className="max-h-80 scroll-py-2 divide-y divide-gray-100 overflow-y-auto dark:divide-white/10"
              >
                <li className="p-2">
                  {query === '' && (
                    <h2 className="mt-4 mb-2 px-3 text-xs font-semibold text-gray-500 dark:text-gray-400">
                      Recent searches
                    </h2>
                  )}
                  <ul className="text-sm text-gray-700 dark:text-gray-300">
                    {(query === '' ? recent : filteredProjects).map((project) => (
                      <ComboboxOption
                        as="li"
                        key={project.id}
                        value={project}
                        className="group flex cursor-default items-center rounded-md px-3 py-2 select-none data-focus:bg-indigo-600 data-focus:text-white data-focus:outline-hidden dark:data-focus:bg-indigo-500"
                      >
                        <FolderIcon
                          className="size-6 flex-none text-gray-400 group-data-focus:text-white dark:text-gray-500 forced-colors:group-data-focus:text-[Highlight]"
                          aria-hidden="true"
                        />
                        <span className="ml-3 flex-auto truncate">{project.name}</span>
                        <span className="ml-3 hidden flex-none text-indigo-100 group-data-focus:inline">
                          Jump to...
                        </span>
                      </ComboboxOption>
                    ))}
                  </ul>
                </li>
                {query === '' && (
                  <li className="p-2">
                    <h2 className="sr-only">Quick actions</h2>
                    <ul className="text-sm text-gray-700 dark:text-gray-300">
                      {quickActions.map((action) => (
                        <ComboboxOption
                          as="li"
                          key={action.shortcut}
                          value={action}
                          className="group flex cursor-default items-center rounded-md px-3 py-2 select-none data-focus:bg-indigo-600 data-focus:text-white data-focus:outline-hidden dark:data-focus:bg-indigo-500"
                        >
                          <action.icon
                            className="size-6 flex-none text-gray-400 group-data-focus:text-white dark:text-gray-500 forced-colors:group-data-focus:text-[Highlight]"
                            aria-hidden="true"
                          />
                          <span className="ml-3 flex-auto truncate">{action.name}</span>
                          <span className="ml-3 flex-none text-xs font-semibold text-gray-400 group-data-focus:text-indigo-100">
                            <kbd className="font-sans">⌘</kbd>
                            <kbd className="font-sans">{action.shortcut}</kbd>
                          </span>
                        </ComboboxOption>
                      ))}
                    </ul>
                  </li>
                )}
              </ComboboxOptions>
            )}

            {query !== '' && filteredProjects.length === 0 && (
              <div className="px-6 py-14 text-center sm:px-14">
                <FolderIcon className="mx-auto size-6 text-gray-400 dark:text-gray-500" aria-hidden="true" />
                <p className="mt-4 text-sm text-gray-900 dark:text-gray-200">
                  We couldn’t find any projects with that term. Please try again.
                </p>
              </div>
            )}
          </Combobox>
        </DialogPanel>
      </div>
    </Dialog>
  )
}
