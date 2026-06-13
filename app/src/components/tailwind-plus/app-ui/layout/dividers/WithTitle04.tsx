// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function WithTitle04() {
  return (
    <div className="flex items-center">
      <div aria-hidden="true" className="w-full border-t border-gray-300 dark:border-white/15" />
      <div className="relative flex justify-center">
        <span className="bg-white px-3 text-base font-semibold text-gray-900 dark:bg-gray-900 dark:text-white">
          Projects
        </span>
      </div>
      <div aria-hidden="true" className="w-full border-t border-gray-300 dark:border-white/15" />
    </div>
  )
}
