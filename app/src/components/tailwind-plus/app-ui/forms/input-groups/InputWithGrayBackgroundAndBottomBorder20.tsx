// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function InputWithGrayBackgroundAndBottomBorder20() {
  return (
    <div>
      <label htmlFor="name" className="block text-sm/6 font-medium text-gray-900 dark:text-white">
        Name
      </label>
      <div className="relative mt-2">
        <input
          id="name"
          name="name"
          type="text"
          placeholder="Jane Smith"
          className="peer block w-full bg-gray-50 px-3 py-1.5 text-gray-900 placeholder:text-gray-500 focus:outline-none sm:text-sm/6 dark:bg-white/5 dark:text-white dark:placeholder:text-gray-500"
        />
        <div
          aria-hidden="true"
          className="absolute inset-x-0 bottom-0 border-t border-gray-300 peer-focus:border-t-2 peer-focus:border-indigo-600 dark:border-white/20 dark:peer-focus:border-indigo-500"
        />
      </div>
    </div>
  )
}
