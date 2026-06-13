// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck

'use client'

import { useState } from 'react'
import { Dialog, DialogPanel, DialogTitle } from '@headlessui/react'
import { XMarkIcon } from '@heroicons/react/24/outline'
import { LinkIcon, PlusIcon, QuestionMarkCircleIcon } from '@heroicons/react/20/solid'

const team = [
  {
    name: 'Tom Cook',
    email: 'tom.cook@example.com',
    href: '#',
    imageUrl:
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
  },
  {
    name: 'Whitney Francis',
    email: 'whitney.francis@example.com',
    href: '#',
    imageUrl:
      'https://images.unsplash.com/photo-1517365830460-955ce3ccd263?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
  },
  {
    name: 'Leonard Krasner',
    email: 'leonard.krasner@example.com',
    href: '#',
    imageUrl:
      'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
  },
  {
    name: 'Floyd Miles',
    email: 'floyd.miles@example.com',
    href: '#',
    imageUrl:
      'https://images.unsplash.com/photo-1463453091185-61582044d556?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
  },
  {
    name: 'Emily Selman',
    email: 'emily.selman@example.com',
    href: '#',
    imageUrl:
      'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
  },
]

export function WideCreateProjectFormExample06a() {
  const [open, setOpen] = useState(true)

  return (
    <div>
      <button
        onClick={() => setOpen(true)}
        className="rounded-md bg-gray-950/5 px-2.5 py-1.5 text-sm font-semibold text-gray-900 hover:bg-gray-950/10 dark:bg-white/10 dark:text-white dark:inset-ring dark:inset-ring-white/5 dark:hover:bg-white/20"
      >
        Open drawer
      </button>
      <Dialog open={open} onClose={setOpen} className="relative z-10">
        <div className="fixed inset-0" />

        <div className="fixed inset-0 overflow-hidden">
          <div className="absolute inset-0 overflow-hidden">
            <div className="pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10 sm:pl-16">
              <DialogPanel
                transition
                className="pointer-events-auto w-screen max-w-2xl transform transition duration-500 ease-in-out data-closed:translate-x-full sm:duration-700"
              >
                <form className="relative flex h-full flex-col overflow-y-auto bg-white shadow-xl dark:bg-gray-800 dark:after:absolute dark:after:inset-y-0 dark:after:left-0 dark:after:w-px dark:after:bg-white/10">
                  <div className="flex-1">
                    {/* Header */}
                    <div className="bg-gray-50 px-4 py-6 sm:px-6 dark:bg-gray-800/50">
                      <div className="flex items-start justify-between space-x-3">
                        <div className="space-y-1">
                          <DialogTitle className="text-base font-semibold text-gray-900 dark:text-white">
                            New project
                          </DialogTitle>
                          <p className="text-sm text-gray-500 dark:text-gray-400">
                            Get started by filling in the information below to create your new project.
                          </p>
                        </div>
                        <div className="flex h-7 items-center">
                          <button
                            type="button"
                            onClick={() => setOpen(false)}
                            className="relative rounded-md text-gray-400 hover:text-gray-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:hover:text-white dark:focus-visible:outline-indigo-500"
                          >
                            <span className="absolute -inset-2.5" />
                            <span className="sr-only">Close panel</span>
                            <XMarkIcon aria-hidden="true" className="size-6" />
                          </button>
                        </div>
                      </div>
                    </div>

                    {/* Divider container */}
                    <div className="space-y-6 py-6 sm:space-y-0 sm:divide-y sm:divide-gray-200 sm:py-0 dark:sm:divide-white/10">
                      {/* Project name */}
                      <div className="space-y-2 px-4 sm:grid sm:grid-cols-3 sm:gap-4 sm:space-y-0 sm:px-6 sm:py-5">
                        <div>
                          <label
                            htmlFor="project-name"
                            className="block text-sm/6 font-medium text-gray-900 sm:mt-1.5 dark:text-white"
                          >
                            Project name
                          </label>
                        </div>
                        <div className="sm:col-span-2">
                          <input
                            id="project-name"
                            name="project-name"
                            type="text"
                            className="block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-indigo-600 sm:text-sm/6 dark:bg-white/5 dark:text-white dark:outline-white/10 dark:placeholder:text-gray-500 dark:focus:outline-indigo-500"
                          />
                        </div>
                      </div>

                      {/* Project description */}
                      <div className="space-y-2 px-4 sm:grid sm:grid-cols-3 sm:gap-4 sm:space-y-0 sm:px-6 sm:py-5">
                        <div>
                          <label
                            htmlFor="project-description"
                            className="block text-sm/6 font-medium text-gray-900 sm:mt-1.5 dark:text-white"
                          >
                            Description
                          </label>
                        </div>
                        <div className="sm:col-span-2">
                          <textarea
                            id="project-description"
                            name="project-description"
                            rows={3}
                            className="block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-indigo-600 sm:text-sm/6 dark:bg-white/5 dark:text-white dark:outline-white/10 dark:placeholder:text-gray-500 dark:focus:outline-indigo-500"
                            defaultValue={''}
                          />
                        </div>
                      </div>

                      {/* Team members */}
                      <div className="space-y-2 px-4 sm:grid sm:grid-cols-3 sm:items-center sm:gap-4 sm:space-y-0 sm:px-6 sm:py-5">
                        <div>
                          <h3 className="text-sm/6 font-medium text-gray-900 dark:text-white">Team Members</h3>
                        </div>
                        <div className="sm:col-span-2">
                          <div className="flex space-x-2">
                            {team.map((person) => (
                              <a
                                key={person.email}
                                href={person.href}
                                className="shrink-0 rounded-full hover:opacity-75"
                              >
                                <img
                                  alt={person.name}
                                  src={person.imageUrl}
                                  className="inline-block size-8 rounded-full bg-gray-100 outline -outline-offset-1 outline-black/5 dark:bg-gray-800 dark:outline-white/10"
                                />
                              </a>
                            ))}

                            <button
                              type="button"
                              className="relative inline-flex size-8 shrink-0 items-center justify-center rounded-full border-2 border-dashed border-gray-200 bg-white text-gray-400 hover:border-gray-300 hover:text-gray-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:border-white/20 dark:bg-gray-800 dark:text-gray-300 dark:hover:border-white/30 dark:hover:text-gray-200 dark:focus-visible:outline-indigo-500"
                            >
                              <span className="absolute -inset-2" />
                              <span className="sr-only">Add team member</span>
                              <PlusIcon aria-hidden="true" className="size-5" />
                            </button>
                          </div>
                        </div>
                      </div>

                      {/* Privacy */}
                      <fieldset className="space-y-2 px-4 sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:space-y-0 sm:px-6 sm:py-5">
                        <legend className="sr-only">Privacy</legend>
                        <div aria-hidden="true" className="text-sm/6 font-medium text-gray-900 dark:text-white">
                          Privacy
                        </div>
                        <div className="space-y-5 sm:col-span-2">
                          <div className="space-y-5 sm:mt-0">
                            <div className="relative flex items-start">
                              <div className="absolute flex h-6 items-center">
                                <input
                                  defaultValue="public"
                                  defaultChecked
                                  id="privacy-public"
                                  name="privacy"
                                  type="radio"
                                  aria-describedby="privacy-public-description"
                                  className="relative size-4 appearance-none rounded-full border border-gray-300 before:absolute before:inset-1 before:rounded-full before:bg-white not-checked:before:hidden checked:border-indigo-600 checked:bg-indigo-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:border-gray-300 disabled:bg-gray-100 disabled:before:bg-gray-400 dark:border-white/20 dark:bg-black/10 dark:checked:border-indigo-500 dark:checked:bg-indigo-500 dark:focus-visible:outline-indigo-500 dark:disabled:border-white/10 dark:disabled:bg-gray-800 dark:disabled:before:bg-white/20 forced-colors:appearance-auto forced-colors:before:hidden"
                                />
                              </div>
                              <div className="pl-7 text-sm/6">
                                <label htmlFor="privacy-public" className="font-medium text-gray-900 dark:text-white">
                                  Public access
                                </label>
                                <p id="privacy-public-description" className="text-gray-500 dark:text-gray-400">
                                  Everyone with the link will see this project.
                                </p>
                              </div>
                            </div>
                            <div className="relative flex items-start">
                              <div className="absolute flex h-6 items-center">
                                <input
                                  defaultValue="private-to-project"
                                  id="privacy-private-to-project"
                                  name="privacy"
                                  type="radio"
                                  aria-describedby="privacy-private-to-project-description"
                                  className="relative size-4 appearance-none rounded-full border border-gray-300 before:absolute before:inset-1 before:rounded-full before:bg-white not-checked:before:hidden checked:border-indigo-600 checked:bg-indigo-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:border-gray-300 disabled:bg-gray-100 disabled:before:bg-gray-400 dark:border-white/20 dark:bg-black/10 dark:checked:border-indigo-500 dark:checked:bg-indigo-500 dark:focus-visible:outline-indigo-500 dark:disabled:border-white/10 dark:disabled:bg-gray-800 dark:disabled:before:bg-white/20 forced-colors:appearance-auto forced-colors:before:hidden"
                                />
                              </div>
                              <div className="pl-7 text-sm/6">
                                <label
                                  htmlFor="privacy-private-to-project"
                                  className="font-medium text-gray-900 dark:text-white"
                                >
                                  Private to project members
                                </label>
                                <p
                                  id="privacy-private-to-project-description"
                                  className="text-gray-500 dark:text-gray-400"
                                >
                                  Only members of this project would be able to access.
                                </p>
                              </div>
                            </div>
                            <div className="relative flex items-start">
                              <div className="absolute flex h-6 items-center">
                                <input
                                  defaultValue="private"
                                  id="privacy-private"
                                  name="privacy"
                                  type="radio"
                                  aria-describedby="privacy-private-to-project-description"
                                  className="relative size-4 appearance-none rounded-full border border-gray-300 before:absolute before:inset-1 before:rounded-full before:bg-white not-checked:before:hidden checked:border-indigo-600 checked:bg-indigo-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:border-gray-300 disabled:bg-gray-100 disabled:before:bg-gray-400 dark:border-white/20 dark:bg-black/10 dark:checked:border-indigo-500 dark:checked:bg-indigo-500 dark:focus-visible:outline-indigo-500 dark:disabled:border-white/10 dark:disabled:bg-gray-800 dark:disabled:before:bg-white/20 forced-colors:appearance-auto forced-colors:before:hidden"
                                />
                              </div>
                              <div className="pl-7 text-sm/6">
                                <label htmlFor="privacy-private" className="font-medium text-gray-900 dark:text-white">
                                  Private to you
                                </label>
                                <p id="privacy-private-description" className="text-gray-500 dark:text-gray-400">
                                  You are the only one able to access this project.
                                </p>
                              </div>
                            </div>
                          </div>
                          <hr className="border-gray-200 dark:border-white/10" />
                          <div className="flex flex-col items-start space-y-4 sm:flex-row sm:items-center sm:justify-between sm:space-y-0">
                            <div>
                              <a
                                href="#"
                                className="group flex items-center space-x-2.5 text-sm font-medium text-indigo-600 hover:text-indigo-900 dark:text-indigo-400 dark:hover:text-indigo-300"
                              >
                                <LinkIcon
                                  aria-hidden="true"
                                  className="size-5 text-indigo-500 group-hover:text-indigo-900 dark:text-indigo-400 dark:group-hover:text-indigo-300"
                                />
                                <span>Copy link</span>
                              </a>
                            </div>
                            <div>
                              <a
                                href="#"
                                className="group flex items-center space-x-2.5 text-sm text-gray-500 hover:text-gray-900 dark:hover:text-gray-300"
                              >
                                <QuestionMarkCircleIcon
                                  aria-hidden="true"
                                  className="size-5 text-gray-400 group-hover:text-gray-500 dark:text-gray-600 dark:group-hover:text-gray-400"
                                />
                                <span>Learn more about sharing</span>
                              </a>
                            </div>
                          </div>
                        </div>
                      </fieldset>
                    </div>
                  </div>

                  {/* Action buttons */}
                  <div className="shrink-0 border-t border-gray-200 px-4 py-5 sm:px-6 dark:border-white/10">
                    <div className="flex justify-end space-x-3">
                      <button
                        type="button"
                        onClick={() => setOpen(false)}
                        className="rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-xs inset-ring inset-ring-gray-300 hover:bg-gray-50 dark:bg-white/10 dark:text-gray-100 dark:shadow-none dark:inset-ring-white/5 dark:hover:bg-white/20"
                      >
                        Cancel
                      </button>
                      <button
                        type="submit"
                        className="inline-flex justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:shadow-none dark:hover:bg-indigo-400 dark:focus-visible:outline-indigo-500"
                      >
                        Create
                      </button>
                    </div>
                  </div>
                </form>
              </DialogPanel>
            </div>
          </div>
        </div>
      </Dialog>
    </div>
  )
}
