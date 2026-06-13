// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { XMarkIcon } from '@heroicons/react/20/solid'

export function LeftAligned06() {
  return (
    <div className="relative flex items-center justify-between gap-x-6 bg-gray-900 px-6 py-2.5 sm:pr-3.5 lg:pl-8 dark:bg-gray-800 dark:after:pointer-events-none dark:after:absolute dark:after:inset-x-0 dark:after:bottom-0 dark:after:h-px dark:after:bg-white/10">
      <p className="text-sm/6 text-white">
        <a href="#">
          <strong className="font-semibold">GeneriCon 2023</strong>
          <svg viewBox="0 0 2 2" aria-hidden="true" className="mx-2 inline size-0.5 fill-current">
            <circle r={1} cx={1} cy={1} />
          </svg>
          Join us in Denver from June 7 – 9 to see what’s coming next&nbsp;<span aria-hidden="true">&rarr;</span>
        </a>
      </p>
      <button type="button" className="-m-3 flex-none p-3 focus-visible:-outline-offset-4">
        <span className="sr-only">Dismiss</span>
        <XMarkIcon aria-hidden="true" className="size-5 text-white" />
      </button>
    </div>
  )
}
