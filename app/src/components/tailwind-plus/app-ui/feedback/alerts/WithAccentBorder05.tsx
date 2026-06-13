// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { ExclamationTriangleIcon } from '@heroicons/react/20/solid'

export function WithAccentBorder05() {
  return (
    <div className="border-l-4 border-yellow-400 bg-yellow-50 p-4 dark:border-yellow-500 dark:bg-yellow-500/10">
      <div className="flex">
        <div className="shrink-0">
          <ExclamationTriangleIcon aria-hidden="true" className="size-5 text-yellow-400 dark:text-yellow-500" />
        </div>
        <div className="ml-3">
          <p className="text-sm text-yellow-700 dark:text-yellow-300">
            You have no credits left.{' '}
            <a
              href="#"
              className="font-medium text-yellow-700 underline hover:text-yellow-600 dark:text-yellow-300 dark:hover:text-yellow-200"
            >
              Upgrade your account to add more credits.
            </a>
          </p>
        </div>
      </div>
    </div>
  )
}
