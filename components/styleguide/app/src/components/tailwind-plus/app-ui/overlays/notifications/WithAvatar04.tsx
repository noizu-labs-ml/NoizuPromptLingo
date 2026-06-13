// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck

'use client'

import { useState } from 'react'
import { Transition } from '@headlessui/react'

export function WithAvatar04() {
  const [show, setShow] = useState(true)

  return (
    <>
      {/* Global notification live region, render this permanently at the end of the document */}
      <div
        aria-live="assertive"
        className="pointer-events-none fixed inset-0 flex items-end px-4 py-6 sm:items-start sm:p-6"
      >
        <div className="flex w-full flex-col items-center space-y-4 sm:items-end">
          {/* Notification panel, dynamically insert this into the live region when it needs to be displayed */}
          <Transition show={show}>
            <div className="pointer-events-auto flex w-full max-w-md rounded-lg bg-white shadow-lg outline-1 outline-black/5 transition data-closed:opacity-0 data-enter:transform data-enter:duration-300 data-enter:ease-out data-closed:data-enter:translate-y-2 data-leave:duration-100 data-leave:ease-in data-closed:data-enter:sm:translate-x-2 data-closed:data-enter:sm:translate-y-0 dark:bg-gray-800 dark:-outline-offset-1 dark:outline-white/10">
              <div className="w-0 flex-1 p-4">
                <div className="flex items-start">
                  <div className="shrink-0 pt-0.5">
                    <img
                      alt=""
                      src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2.2&w=160&h=160&q=80"
                      className="size-10 rounded-full bg-gray-100 outline -outline-offset-1 outline-black/5 dark:bg-gray-800 dark:outline-white/10"
                    />
                  </div>
                  <div className="ml-3 w-0 flex-1">
                    <p className="text-sm font-medium text-gray-900 dark:text-white">Emilia Gates</p>
                    <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">Sure! 8:30pm works great!</p>
                  </div>
                </div>
              </div>
              <div className="flex border-l border-gray-200 dark:border-white/10">
                <button
                  type="button"
                  onClick={() => {
                    setShow(false)
                  }}
                  className="flex w-full items-center justify-center rounded-none rounded-r-lg p-4 text-sm font-medium text-indigo-600 hover:text-indigo-500 focus:outline-2 focus:outline-indigo-500 dark:text-indigo-400 dark:hover:text-indigo-300 dark:focus:outline-indigo-400"
                >
                  Reply
                </button>
              </div>
            </div>
          </Transition>
        </div>
      </div>
    </>
  )
}
