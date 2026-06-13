// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { BookmarkIcon } from '@heroicons/react/20/solid'

export function WithStat03() {
  return (
    <span className="isolate inline-flex rounded-md shadow-xs dark:shadow-none">
      <button
        type="button"
        className="relative inline-flex items-center gap-x-1.5 rounded-l-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-gray-300 ring-inset hover:bg-gray-50 focus:z-10 dark:bg-white/10 dark:text-white dark:ring-gray-700 dark:hover:bg-white/20"
      >
        <BookmarkIcon aria-hidden="true" className="-ml-0.5 size-5 text-gray-400 dark:text-gray-500" />
        Bookmark
      </button>
      <button
        type="button"
        className="relative -ml-px inline-flex items-center rounded-r-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-gray-300 ring-inset hover:bg-gray-50 focus:z-10 dark:bg-white/10 dark:text-white dark:ring-gray-700 dark:hover:bg-white/20"
      >
        12k
      </button>
    </span>
  )
}
