// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function InputsWithInsetLabelsAndSharedBorders17() {
  return (
    <div className="-space-y-px">
      <div className="rounded-t-md bg-white px-3 pt-2.5 pb-1.5 outline-1 -outline-offset-1 outline-gray-300 focus-within:relative focus-within:outline-2 focus-within:-outline-offset-2 focus-within:outline-indigo-600 dark:bg-white/5 dark:outline-gray-700 dark:focus-within:outline-indigo-500">
        <label htmlFor="name" className="block text-xs font-medium text-gray-900 dark:text-gray-200">
          Name
        </label>
        <input
          id="name"
          name="name"
          type="text"
          placeholder="Jane Smith"
          className="block w-full text-gray-900 placeholder:text-gray-400 focus:outline-none sm:text-sm/6 dark:bg-transparent dark:text-white dark:placeholder:text-gray-500"
        />
      </div>
      <div className="rounded-b-md bg-white px-3 pt-2.5 pb-1.5 outline-1 -outline-offset-1 outline-gray-300 focus-within:relative focus-within:outline-2 focus-within:-outline-offset-2 focus-within:outline-indigo-600 dark:bg-white/5 dark:outline-gray-700 dark:focus-within:outline-indigo-500">
        <label htmlFor="job-title" className="block text-xs font-medium text-gray-900 dark:text-gray-200">
          Job title
        </label>
        <input
          id="job-title"
          name="job-title"
          type="text"
          placeholder="Head of Tomfoolery"
          className="block w-full text-gray-900 placeholder:text-gray-400 focus:outline-none sm:text-sm/6 dark:bg-transparent dark:text-white dark:placeholder:text-gray-500"
        />
      </div>
    </div>
  )
}
