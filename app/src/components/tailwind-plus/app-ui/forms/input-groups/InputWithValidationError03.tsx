// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { ExclamationCircleIcon } from '@heroicons/react/16/solid'

export function InputWithValidationError03() {
  return (
    <div>
      <label htmlFor="email" className="block text-sm/6 font-medium text-gray-900 dark:text-white">
        Email
      </label>
      <div className="mt-2 grid grid-cols-1">
        <input
          defaultValue="adamwathan"
          id="email"
          name="email"
          type="email"
          placeholder="you@example.com"
          aria-invalid="true"
          aria-describedby="email-error"
          className="col-start-1 row-start-1 block w-full rounded-md bg-white py-1.5 pr-10 pl-3 text-red-900 outline-1 -outline-offset-1 outline-red-300 placeholder:text-red-300 focus:outline-2 focus:-outline-offset-2 focus:outline-red-600 sm:pr-9 sm:text-sm/6 dark:bg-white/5 dark:text-red-400 dark:outline-red-500/50 dark:placeholder:text-red-400/70 dark:focus:outline-red-400"
        />
        <ExclamationCircleIcon
          aria-hidden="true"
          className="pointer-events-none col-start-1 row-start-1 mr-3 size-5 self-center justify-self-end text-red-500 sm:size-4 dark:text-red-400"
        />
      </div>
      <p id="email-error" className="mt-2 text-sm text-red-600 dark:text-red-400">
        Not a valid email address.
      </p>
    </div>
  )
}
