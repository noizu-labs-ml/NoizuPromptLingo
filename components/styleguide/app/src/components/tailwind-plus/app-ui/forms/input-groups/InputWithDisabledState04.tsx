// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function InputWithDisabledState04() {
  return (
    <div>
      <label htmlFor="email" className="block text-sm/6 font-medium text-gray-900 dark:text-white">
        Email
      </label>
      <div className="mt-2">
        <input
          defaultValue="you@example.com"
          id="email"
          name="email"
          type="email"
          disabled
          placeholder="you@example.com"
          className="block w-full rounded-md bg-white px-3 py-1.5 text-gray-900 outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 disabled:cursor-not-allowed disabled:bg-gray-50 disabled:text-gray-500 disabled:outline-gray-200 sm:text-sm/6 dark:bg-white/5 dark:text-gray-300 dark:outline-white/10 dark:placeholder:text-gray-500 dark:focus:outline-indigo-500 dark:disabled:bg-white/10 dark:disabled:text-gray-500 dark:disabled:outline-white/5"
        />
      </div>
    </div>
  )
}
