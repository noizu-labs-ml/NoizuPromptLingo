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
import { ChevronRightIcon, MagnifyingGlassIcon } from '@heroicons/react/20/solid'
import { UsersIcon } from '@heroicons/react/24/outline'
import { useState } from 'react'

const people = [
  {
    id: 1,
    name: 'Leslie Alexander',
    phone: '1-493-747-9031',
    email: 'lesliealexander@example.com',
    role: 'Co-Founder / CEO',
    url: 'https://example.com',
    profileUrl: '#',
    imageUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
  },
  // More people...
]

const recent = [people[5], people[4], people[2], people[10], people[16]]

function classNames(...classes) {
  return classes.filter(Boolean).join(' ')
}

export function WithPreview03() {
  const [query, setQuery] = useState('')
  const [open, setOpen] = useState(true)

  const filteredPeople =
    query === ''
      ? []
      : people.filter((person) => {
          return person.name.toLowerCase().includes(query.toLowerCase())
        })

  return (
    <>
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
            className="mx-auto max-w-3xl transform divide-y divide-gray-100 overflow-hidden rounded-xl bg-white shadow-2xl outline-1 outline-black/5 transition-all data-closed:scale-95 data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in dark:divide-white/10 dark:bg-gray-900 dark:-outline-offset-1 dark:outline-white/10"
          >
            <Combobox
              onChange={(person) => {
                if (person) {
                  window.location = person.url
                }
              }}
            >
              {({ activeOption }) => (
                <>
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

                  {(query === '' || filteredPeople.length > 0) && (
                    <ComboboxOptions
                      as="div"
                      static
                      hold
                      className="flex transform-gpu divide-x divide-gray-100 dark:divide-white/10"
                    >
                      <div
                        className={classNames(
                          'max-h-96 min-w-0 flex-auto scroll-py-4 overflow-y-auto px-6 py-4',
                          activeOption && 'sm:h-96',
                        )}
                      >
                        {query === '' && (
                          <h2 className="mt-2 mb-4 text-xs font-semibold text-gray-500 dark:text-gray-400">
                            Recent searches
                          </h2>
                        )}
                        <div className="-mx-2 text-sm text-gray-700 dark:text-gray-300">
                          {(query === '' ? recent : filteredPeople).map((person) => (
                            <ComboboxOption
                              as="div"
                              key={person.id}
                              value={person}
                              className="group flex cursor-default items-center rounded-md p-2 select-none data-focus:bg-gray-100 data-focus:text-gray-900 data-focus:outline-hidden dark:data-focus:bg-white/5 dark:data-focus:text-white"
                            >
                              <img
                                src={person.imageUrl}
                                alt=""
                                className="size-6 flex-none rounded-full bg-gray-100 outline -outline-offset-1 outline-black/5 dark:bg-gray-800 dark:outline-white/10"
                              />
                              <span className="ml-3 flex-auto truncate">{person.name}</span>
                              <ChevronRightIcon
                                className="ml-3 hidden size-5 flex-none text-gray-400 group-data-focus:block dark:text-gray-500"
                                aria-hidden="true"
                              />
                            </ComboboxOption>
                          ))}
                        </div>
                      </div>

                      {activeOption && (
                        <div className="hidden h-96 w-1/2 flex-none flex-col divide-y divide-gray-100 overflow-y-auto sm:flex dark:divide-white/10">
                          <div className="flex-none p-6 text-center">
                            <img
                              src={activeOption.imageUrl}
                              alt=""
                              className="mx-auto size-16 rounded-full bg-gray-100 outline -outline-offset-1 outline-black/5 dark:bg-gray-800 dark:outline-white/10"
                            />
                            <h2 className="mt-3 font-semibold text-gray-900 dark:text-white">{activeOption.name}</h2>
                            <p className="text-sm/6 text-gray-500 dark:text-gray-400">{activeOption.role}</p>
                          </div>
                          <div className="flex flex-auto flex-col justify-between p-6">
                            <dl className="grid grid-cols-1 gap-x-6 gap-y-3 text-sm text-gray-700 dark:text-gray-300">
                              <dt className="col-end-1 font-semibold text-gray-900 dark:text-white">Phone</dt>
                              <dd>{activeOption.phone}</dd>
                              <dt className="col-end-1 font-semibold text-gray-900 dark:text-white">URL</dt>
                              <dd className="truncate">
                                <a href={activeOption.url} className="text-indigo-600 underline dark:text-indigo-400">
                                  {activeOption.url}
                                </a>
                              </dd>
                              <dt className="col-end-1 font-semibold text-gray-900 dark:text-white">Email</dt>
                              <dd className="truncate">
                                <a
                                  href={`mailto:${activeOption.email}`}
                                  className="text-indigo-600 underline dark:text-indigo-400"
                                >
                                  {activeOption.email}
                                </a>
                              </dd>
                            </dl>
                            <button
                              type="button"
                              className="mt-6 w-full rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:hover:bg-indigo-400 dark:focus-visible:outline-indigo-500"
                            >
                              Send message
                            </button>
                          </div>
                        </div>
                      )}
                    </ComboboxOptions>
                  )}

                  {query !== '' && filteredPeople.length === 0 && (
                    <div className="px-6 py-14 text-center text-sm sm:px-14">
                      <UsersIcon className="mx-auto size-6 text-gray-400 dark:text-gray-500" aria-hidden="true" />
                      <p className="mt-4 font-semibold text-gray-900 dark:text-white">No people found</p>
                      <p className="mt-2 text-gray-500 dark:text-gray-400">
                        We couldn’t find anything with that term. Please try again.
                      </p>
                    </div>
                  )}
                </>
              )}
            </Combobox>
          </DialogPanel>
        </div>
      </Dialog>
    </>
  )
}
