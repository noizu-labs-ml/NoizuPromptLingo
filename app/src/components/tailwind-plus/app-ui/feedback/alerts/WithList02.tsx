// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { XCircleIcon } from '@heroicons/react/20/solid'

export function WithList02() {
  return (
    <div className="rounded-md bg-red-50 p-4 dark:bg-red-500/15 dark:outline dark:outline-red-500/25">
      <div className="flex">
        <div className="shrink-0">
          <XCircleIcon aria-hidden="true" className="size-5 text-red-400" />
        </div>
        <div className="ml-3">
          <h3 className="text-sm font-medium text-red-800 dark:text-red-200">
            There were 2 errors with your submission
          </h3>
          <div className="mt-2 text-sm text-red-700 dark:text-red-200/80">
            <ul role="list" className="list-disc space-y-1 pl-5">
              <li>Your password must be at least 8 characters</li>
              <li>Your password must include at least one pro wrestling finishing move</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}
