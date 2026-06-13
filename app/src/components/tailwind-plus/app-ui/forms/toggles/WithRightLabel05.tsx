// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function WithRightLabel05() {
  return (
    <div className="flex items-center justify-between gap-3">
      <div className="group relative inline-flex w-11 shrink-0 rounded-full bg-gray-200 p-0.5 inset-ring inset-ring-gray-900/5 outline-offset-2 outline-indigo-600 transition-colors duration-200 ease-in-out has-checked:bg-indigo-600 has-focus-visible:outline-2 dark:bg-white/5 dark:inset-ring-white/10 dark:outline-indigo-500 dark:has-checked:bg-indigo-500">
        <span className="size-5 rounded-full bg-white shadow-xs ring-1 ring-gray-900/5 transition-transform duration-200 ease-in-out group-has-checked:translate-x-5" />
        <input
          id="annual-billing"
          name="annual-billing"
          type="checkbox"
          aria-labelledby="annual-billing-label"
          aria-describedby="annual-billing-description"
          className="absolute inset-0 size-full appearance-none focus:outline-hidden"
        />
      </div>

      <div className="text-sm">
        <label id="annual-billing-label" className="font-medium text-gray-900 dark:text-white">
          Annual billing
        </label>{' '}
        <span id="annual-billing-description" className="text-gray-500 dark:text-gray-400">
          (Save 10%)
        </span>
      </div>
    </div>
  )
}
