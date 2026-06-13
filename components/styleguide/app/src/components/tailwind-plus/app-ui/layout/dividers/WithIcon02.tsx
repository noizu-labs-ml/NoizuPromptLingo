// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { PlusIcon } from '@heroicons/react/20/solid'

export function WithIcon02() {
  return (
    <div className="flex items-center">
      <div aria-hidden="true" className="w-full border-t border-gray-300 dark:border-white/15" />
      <div className="relative flex justify-center">
        <span className="bg-white px-2 text-gray-500 dark:bg-gray-900 dark:text-gray-400">
          <PlusIcon aria-hidden="true" className="size-5 text-gray-500 dark:text-gray-400" />
        </span>
      </div>
      <div aria-hidden="true" className="w-full border-t border-gray-300 dark:border-white/15" />
    </div>
  )
}
