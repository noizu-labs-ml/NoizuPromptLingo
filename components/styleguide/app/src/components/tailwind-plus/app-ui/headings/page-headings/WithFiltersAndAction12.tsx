// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { PlusSmallIcon } from '@heroicons/react/20/solid'

export function WithFiltersAndAction12() {
  return (
    <div>
      <div className="flex flex-wrap items-center gap-6 px-4 sm:flex-nowrap sm:px-6 lg:px-8">
        <h1 className="text-base/7 font-semibold text-gray-900 dark:text-white">Cashflow</h1>
        <div className="order-last flex w-full gap-x-8 text-sm/6 font-semibold sm:order-0 sm:w-auto sm:border-l sm:border-gray-200 sm:pl-6 sm:text-sm/7 dark:sm:border-white/15">
          <a href="#" className="text-indigo-600 dark:text-indigo-400">
            Last 7 days
          </a>
          <a href="#" className="text-gray-700 dark:text-gray-300">
            Last 30 days
          </a>
          <a href="#" className="text-gray-700 dark:text-gray-300">
            All-time
          </a>
        </div>
        <a
          href="#"
          className="ml-auto flex items-center gap-x-1 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:shadow-none dark:hover:bg-indigo-400 dark:focus-visible:outline-indigo-500"
        >
          <PlusSmallIcon aria-hidden="true" className="-ml-1.5 size-5" />
          New invoice
        </a>
      </div>
    </div>
  )
}
