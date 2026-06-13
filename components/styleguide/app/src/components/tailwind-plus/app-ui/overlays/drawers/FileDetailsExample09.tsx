// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck

'use client'

import { useState } from 'react'
import { Dialog, DialogBackdrop, DialogPanel, TransitionChild } from '@headlessui/react'
import { HeartIcon, XMarkIcon } from '@heroicons/react/24/outline'
import { PencilIcon, PlusIcon } from '@heroicons/react/20/solid'

export function FileDetailsExample09() {
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
        <DialogBackdrop
          transition
          className="fixed inset-0 bg-gray-500/75 transition-opacity duration-500 ease-in-out data-closed:opacity-0 dark:bg-gray-900/50"
        />

        <div className="fixed inset-0 overflow-hidden">
          <div className="absolute inset-0 overflow-hidden">
            <div className="pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10 sm:pl-16">
              <DialogPanel
                transition
                className="pointer-events-auto relative w-96 transform transition duration-500 ease-in-out data-closed:translate-x-full sm:duration-700"
              >
                <TransitionChild>
                  <div className="absolute top-0 left-0 -ml-8 flex pt-4 pr-2 duration-500 ease-in-out data-closed:opacity-0 sm:-ml-10 sm:pr-4">
                    <button
                      type="button"
                      onClick={() => setOpen(false)}
                      className="relative rounded-md text-gray-300 hover:text-white focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:text-gray-400 dark:hover:text-white dark:focus-visible:outline-indigo-500"
                    >
                      <span className="absolute -inset-2.5" />
                      <span className="sr-only">Close panel</span>
                      <XMarkIcon aria-hidden="true" className="size-6" />
                    </button>
                  </div>
                </TransitionChild>
                <div className="relative h-full overflow-y-auto bg-white p-8 dark:bg-gray-800 dark:after:absolute dark:after:inset-y-0 dark:after:left-0 dark:after:w-px dark:after:bg-white/10">
                  <div className="space-y-6 pb-16">
                    <div>
                      <img
                        alt=""
                        src="https://images.unsplash.com/photo-1582053433976-25c00369fc93?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=512&q=80"
                        className="block aspect-10/7 w-full rounded-lg bg-gray-100 object-cover outline -outline-offset-1 outline-black/5 dark:bg-gray-800 dark:outline-white/10"
                      />
                      <div className="mt-4 flex items-start justify-between">
                        <div>
                          <h2 className="text-base font-semibold text-gray-900 dark:text-white">
                            <span className="sr-only">Details for </span>IMG_4985.HEIC
                          </h2>
                          <p className="text-sm font-medium text-gray-500 dark:text-gray-400">3.9 MB</p>
                        </div>
                        <button
                          type="button"
                          className="relative ml-4 flex size-8 items-center justify-center rounded-full text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus-visible:outline-2 focus-visible:outline-indigo-600 dark:hover:bg-white/5 dark:hover:text-white dark:focus-visible:outline-indigo-500"
                        >
                          <span className="absolute -inset-1.5" />
                          <HeartIcon aria-hidden="true" className="size-6" />
                          <span className="sr-only">Favorite</span>
                        </button>
                      </div>
                    </div>
                    <div>
                      <h3 className="font-medium text-gray-900 dark:text-white">Information</h3>
                      <dl className="mt-2 divide-y divide-gray-200 border-t border-b border-gray-200 dark:divide-white/10 dark:border-white/10">
                        <div className="flex justify-between py-3 text-sm font-medium">
                          <dt className="text-gray-500 dark:text-gray-400">Uploaded by</dt>
                          <dd className="text-gray-900 dark:text-white">Marie Culver</dd>
                        </div>
                        <div className="flex justify-between py-3 text-sm font-medium">
                          <dt className="text-gray-500 dark:text-gray-400">Created</dt>
                          <dd className="text-gray-900 dark:text-white">June 8, 2020</dd>
                        </div>
                        <div className="flex justify-between py-3 text-sm font-medium">
                          <dt className="text-gray-500 dark:text-gray-400">Last modified</dt>
                          <dd className="text-gray-900 dark:text-white">June 8, 2020</dd>
                        </div>
                        <div className="flex justify-between py-3 text-sm font-medium">
                          <dt className="text-gray-500 dark:text-gray-400">Dimensions</dt>
                          <dd className="text-gray-900 dark:text-white">4032 x 3024</dd>
                        </div>
                        <div className="flex justify-between py-3 text-sm font-medium">
                          <dt className="text-gray-500 dark:text-gray-400">Resolution</dt>
                          <dd className="text-gray-900 dark:text-white">72 x 72</dd>
                        </div>
                      </dl>
                    </div>
                    <div>
                      <h3 className="font-medium text-gray-900 dark:text-white">Description</h3>
                      <div className="mt-2 flex items-center justify-between">
                        <p className="text-sm text-gray-500 italic dark:text-gray-400">
                          Add a description to this image.
                        </p>
                        <button
                          type="button"
                          className="relative -mr-2 flex size-8 items-center justify-center rounded-full text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus-visible:outline-2 focus-visible:outline-indigo-600 dark:hover:bg-white/5 dark:hover:text-white dark:focus-visible:outline-indigo-500"
                        >
                          <span className="absolute -inset-1.5" />
                          <PencilIcon aria-hidden="true" className="size-5" />
                          <span className="sr-only">Add description</span>
                        </button>
                      </div>
                    </div>
                    <div>
                      <h3 className="font-medium text-gray-900 dark:text-white">Shared with</h3>
                      <ul
                        role="list"
                        className="mt-2 divide-y divide-gray-200 border-t border-b border-gray-200 dark:divide-white/10 dark:border-white/10"
                      >
                        <li className="flex items-center justify-between py-3">
                          <div className="flex items-center">
                            <img
                              alt=""
                              src="https://images.unsplash.com/photo-1502685104226-ee32379fefbe?ixlib=rb-=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=3&w=1024&h=1024&q=80"
                              className="size-8 rounded-full bg-gray-100 outline -outline-offset-1 outline-black/5 dark:bg-gray-800 dark:outline-white/10"
                            />
                            <p className="ml-4 text-sm font-medium text-gray-900 dark:text-white">Aimee Douglas</p>
                          </div>
                          <button
                            type="button"
                            className="ml-6 rounded-md text-sm font-medium text-indigo-600 hover:text-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:text-indigo-400 dark:hover:text-indigo-300 dark:focus-visible:outline-indigo-500"
                          >
                            Remove<span className="sr-only"> Aimee Douglas</span>
                          </button>
                        </li>
                        <li className="flex items-center justify-between py-3">
                          <div className="flex items-center">
                            <img
                              alt=""
                              src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixqx=oilqXxSqey&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                              className="size-8 rounded-full bg-gray-100 outline -outline-offset-1 outline-black/5 dark:bg-gray-800 dark:outline-white/10"
                            />
                            <p className="ml-4 text-sm font-medium text-gray-900 dark:text-white">Andrea McMillan</p>
                          </div>
                          <button
                            type="button"
                            className="ml-6 rounded-md text-sm font-medium text-indigo-600 hover:text-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:text-indigo-400 dark:hover:text-indigo-300 dark:focus-visible:outline-indigo-500"
                          >
                            Remove<span className="sr-only"> Andrea McMillan</span>
                          </button>
                        </li>
                        <li className="flex items-center justify-between py-2">
                          <button
                            type="button"
                            className="group -ml-1 flex items-center rounded-md p-1 focus-visible:outline-2 focus-visible:outline-indigo-600 dark:focus-visible:outline-indigo-500"
                          >
                            <span className="flex size-8 items-center justify-center rounded-full border-2 border-dashed border-gray-300 text-gray-400 dark:border-white/20">
                              <PlusIcon aria-hidden="true" className="size-5" />
                            </span>
                            <span className="ml-4 text-sm font-medium text-indigo-600 group-hover:text-indigo-500 dark:text-indigo-400 dark:group-hover:text-indigo-300">
                              Share
                            </span>
                          </button>
                        </li>
                      </ul>
                    </div>
                    <div className="flex">
                      <button
                        type="button"
                        className="flex-1 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:shadow-none dark:hover:bg-indigo-400 dark:focus-visible:outline-indigo-500"
                      >
                        Download
                      </button>
                      <button
                        type="button"
                        className="ml-3 flex-1 rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-xs inset-ring inset-ring-gray-300 hover:bg-gray-50 dark:bg-white/10 dark:text-gray-100 dark:shadow-none dark:inset-ring-white/5 dark:hover:bg-white/20"
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                </div>
              </DialogPanel>
            </div>
          </div>
        </div>
      </Dialog>
    </div>
  )
}
