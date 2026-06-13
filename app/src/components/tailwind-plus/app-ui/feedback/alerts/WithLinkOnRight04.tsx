// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { InformationCircleIcon } from '@heroicons/react/20/solid'

export function WithLinkOnRight04() {
  return (
    <div className="rounded-md bg-blue-50 p-4 dark:bg-blue-500/10 dark:outline dark:outline-blue-500/20">
      <div className="flex">
        <div className="shrink-0">
          <InformationCircleIcon aria-hidden="true" className="size-5 text-blue-400" />
        </div>
        <div className="ml-3 flex-1 md:flex md:justify-between">
          <p className="text-sm text-blue-700 dark:text-blue-300">
            A new software update is available. See what’s new in version 2.0.4.
          </p>
          <p className="mt-3 text-sm md:mt-0 md:ml-6">
            <a
              href="#"
              className="font-medium whitespace-nowrap text-blue-700 hover:text-blue-600 dark:text-blue-300 dark:hover:text-blue-200"
            >
              Details
              <span aria-hidden="true"> &rarr;</span>
            </a>
          </p>
        </div>
      </div>
    </div>
  )
}
