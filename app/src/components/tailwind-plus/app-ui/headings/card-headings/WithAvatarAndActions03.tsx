// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { EnvelopeIcon, PhoneIcon } from '@heroicons/react/20/solid'

export function WithAvatarAndActions03() {
  return (
    <div className="border-b border-gray-200 px-4 py-5 sm:px-6 dark:border-white/10">
      <div className="-mt-4 -ml-4 flex flex-wrap items-center justify-between sm:flex-nowrap">
        <div className="mt-4 ml-4">
          <div className="flex items-center">
            <div className="shrink-0">
              <img
                alt=""
                src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                className="size-12 rounded-full bg-gray-50 dark:bg-gray-800 dark:outline dark:-outline-offset-1 dark:outline-white/10"
              />
            </div>
            <div className="ml-4">
              <h3 className="text-base font-semibold text-gray-900 dark:text-white">Tom Cook</h3>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                <a href="#">@tom_cook</a>
              </p>
            </div>
          </div>
        </div>
        <div className="mt-4 ml-4 flex shrink-0">
          <button
            type="button"
            className="relative inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-xs inset-ring inset-ring-gray-300 hover:bg-gray-50 dark:bg-white/10 dark:text-white dark:shadow-none dark:inset-ring-white/5 dark:hover:bg-white/20"
          >
            <PhoneIcon aria-hidden="true" className="mr-1.5 -ml-0.5 size-5 text-gray-400" />
            <span>Phone</span>
          </button>
          <button
            type="button"
            className="relative ml-3 inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-xs inset-ring inset-ring-gray-300 hover:bg-gray-50 dark:bg-white/10 dark:text-white dark:shadow-none dark:inset-ring-white/5 dark:hover:bg-white/20"
          >
            <EnvelopeIcon aria-hidden="true" className="mr-1.5 -ml-0.5 size-5 text-gray-400" />
            <span>Email</span>
          </button>
        </div>
      </div>
    </div>
  )
}
