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
import { ExclamationTriangleIcon, FolderIcon, LifebuoyIcon } from '@heroicons/react/24/outline'
import { useState } from 'react'

const projects = [
  { id: 1, name: 'Workflow Inc. / Website Redesign', category: 'Projects', url: '#' },
  // More projects...
]

const users = [
  {
    id: 1,
    name: 'Leslie Alexander',
    url: '#',
    imageUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
  },
  // More users...
]

function classNames(...classes) {
  return classes.filter(Boolean).join(' ')
}

export function WithFooter09() {
  const [open, setOpen] = useState(true)
  const [rawQuery, setRawQuery] = useState('')
  const query = rawQuery.toLowerCase().replace(/^[#>]/, '')

  const filteredProjects =
    rawQuery === '#'
      ? projects
      : query === '' || rawQuery.startsWith('>')
        ? []
        : projects.filter((project) => project.name.toLowerCase().includes(query))

  const filteredUsers =
    rawQuery === '>'
      ? users
      : query === '' || rawQuery.startsWith('#')
        ? []
        : users.filter((user) => user.name.toLowerCase().includes(query))

  return (
    <Dialog
      className="relative z-10"
      open={open}
      onClose={() => {
        setOpen(false)
        setRawQuery('')
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
                onChange={(event) => setRawQuery(event.target.value)}
                onBlur={() => setRawQuery('')}
              />
              <MagnifyingGlassIcon
                className="pointer-events-none col-start-1 row-start-1 ml-4 size-5 self-center text-gray-400 dark:text-gray-500"
                aria-hidden="true"
              />
            </div>

            {(filteredProjects.length > 0 || filteredUsers.length > 0) && (
              <ComboboxOptions
                static
                as="ul"
                className="max-h-80 transform-gpu scroll-py-10 scroll-pb-2 space-y-4 overflow-y-auto p-4 pb-2"
              >
                {filteredProjects.length > 0 && (
                  <li>
                    <h2 className="text-xs font-semibold text-gray-900 dark:text-white">Projects</h2>
                    <ul className="-mx-4 mt-2 text-sm text-gray-700 dark:text-gray-300">
                      {filteredProjects.map((project) => (
                        <ComboboxOption
                          as="li"
                          key={project.id}
                          value={project}
                          className="group flex cursor-default items-center px-4 py-2 select-none data-focus:bg-indigo-600 data-focus:text-white data-focus:outline-hidden dark:data-focus:bg-indigo-500"
                        >
                          <FolderIcon
                            className="size-6 flex-none text-gray-400 group-data-focus:text-white dark:text-gray-500 forced-colors:group-data-focus:text-[Highlight]"
                            aria-hidden="true"
                          />
                          <span className="ml-3 flex-auto truncate">{project.name}</span>
                        </ComboboxOption>
                      ))}
                    </ul>
                  </li>
                )}
                {filteredUsers.length > 0 && (
                  <li>
                    <h2 className="text-xs font-semibold text-gray-900 dark:text-white">Users</h2>
                    <ul className="-mx-4 mt-2 text-sm text-gray-700 dark:text-gray-300">
                      {filteredUsers.map((user) => (
                        <ComboboxOption
                          as="li"
                          key={user.id}
                          value={user}
                          className="flex cursor-default items-center px-4 py-2 select-none data-focus:bg-indigo-600 data-focus:text-white dark:data-focus:bg-indigo-500"
                        >
                          <img
                            src={user.imageUrl}
                            alt=""
                            className="size-6 flex-none rounded-full bg-gray-100 outline -outline-offset-1 outline-black/5 dark:bg-gray-800 dark:outline-white/10"
                          />
                          <span className="ml-3 flex-auto truncate">{user.name}</span>
                        </ComboboxOption>
                      ))}
                    </ul>
                  </li>
                )}
              </ComboboxOptions>
            )}

            {rawQuery === '?' && (
              <div className="px-6 py-14 text-center text-sm sm:px-14">
                <LifebuoyIcon className="mx-auto size-6 text-gray-400 dark:text-gray-500" aria-hidden="true" />
                <p className="mt-4 font-semibold text-gray-900 dark:text-white">Help with searching</p>
                <p className="mt-2 text-gray-500 dark:text-gray-400">
                  Use this tool to quickly search for users and projects across our entire platform. You can also use
                  the search modifiers found in the footer below to limit the results to just users or projects.
                </p>
              </div>
            )}

            {query !== '' && rawQuery !== '?' && filteredProjects.length === 0 && filteredUsers.length === 0 && (
              <div className="px-6 py-14 text-center text-sm sm:px-14">
                <ExclamationTriangleIcon className="mx-auto size-6 text-gray-400" aria-hidden="true" />
                <p className="mt-4 font-semibold text-gray-900 dark:text-white">No results found</p>
                <p className="mt-2 text-gray-500 dark:text-gray-400">
                  We couldn’t find anything with that term. Please try again.
                </p>
              </div>
            )}

            <div className="flex flex-wrap items-center bg-gray-50 px-4 py-2.5 text-xs text-gray-700 dark:bg-gray-800/50 dark:text-gray-300">
              Type{' '}
              <kbd
                className={classNames(
                  'mx-1 flex size-5 items-center justify-center rounded-sm border bg-white font-semibold sm:mx-2 dark:bg-gray-800',
                  rawQuery.startsWith('#')
                    ? 'border-indigo-600 text-indigo-600 dark:border-indigo-500 dark:text-indigo-500'
                    : 'border-gray-400 text-gray-900 dark:border-white/10 dark:text-white',
                )}
              >
                #
              </kbd>{' '}
              <span className="sm:hidden">for projects,</span>
              <span className="hidden sm:inline">to access projects,</span>
              <kbd
                className={classNames(
                  'mx-1 flex size-5 items-center justify-center rounded-sm border bg-white font-semibold sm:mx-2 dark:bg-gray-800',
                  rawQuery.startsWith('>')
                    ? 'border-indigo-600 text-indigo-600 dark:border-indigo-500 dark:text-indigo-500'
                    : 'border-gray-400 text-gray-900 dark:border-white/10 dark:text-white',
                )}
              >
                &gt;
              </kbd>{' '}
              for users, and{' '}
              <kbd
                className={classNames(
                  'mx-1 flex size-5 items-center justify-center rounded-sm border bg-white font-semibold sm:mx-2 dark:bg-gray-800',
                  rawQuery === '?'
                    ? 'border-indigo-600 text-indigo-600 dark:border-indigo-500 dark:text-indigo-500'
                    : 'border-gray-400 text-gray-900 dark:border-white/10 dark:text-white',
                )}
              >
                ?
              </kbd>{' '}
              for help.
            </div>
          </Combobox>
        </DialogPanel>
      </div>
    </Dialog>
  )
}
