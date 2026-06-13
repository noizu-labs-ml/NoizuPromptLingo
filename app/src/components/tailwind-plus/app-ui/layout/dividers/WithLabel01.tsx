// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function WithLabel01() {
  return (
    <div className="flex items-center">
      <div aria-hidden="true" className="w-full border-t border-gray-300 dark:border-white/15" />
      <div className="relative flex justify-center">
        <span className="bg-white px-2 text-sm text-gray-500 dark:bg-gray-900 dark:text-gray-400">Continue</span>
      </div>
      <div aria-hidden="true" className="w-full border-t border-gray-300 dark:border-white/15" />
    </div>
  )
}
