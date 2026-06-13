// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { PlusIcon } from '@heroicons/react/20/solid'

export function WithTitleAndButton07() {
  return (
    <div className="relative flex items-center justify-between">
      <span className="bg-white pr-3 text-base font-semibold text-gray-900 dark:bg-gray-900 dark:text-white">
        Projects
      </span>
      <div className="flex w-full items-center">
        <div aria-hidden="true" className="w-full border-t border-gray-300 dark:border-white/15" />
        <button
          type="button"
          className="inline-flex items-center gap-x-1.5 rounded-full bg-white px-3 py-1.5 text-sm font-semibold whitespace-nowrap text-gray-900 shadow-xs inset-ring inset-ring-gray-300 hover:bg-gray-50 dark:bg-white/10 dark:text-white dark:shadow-none dark:inset-ring-white/5 dark:hover:bg-white/20"
        >
          <PlusIcon aria-hidden="true" className="-mr-0.5 -ml-1 size-5 text-gray-400" />
          <span>Button text</span>
        </button>
      </div>
    </div>
  )
}
