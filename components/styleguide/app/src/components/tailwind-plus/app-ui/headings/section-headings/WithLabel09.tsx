// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function WithLabel09() {
  return (
    <div className="border-b border-gray-200 pb-5 dark:border-white/10">
      <div className="-mt-2 -ml-2 flex flex-wrap items-baseline">
        <h3 className="mt-2 ml-2 text-base font-semibold text-gray-900 dark:text-white">Job Postings</h3>
        <p className="mt-1 ml-2 truncate text-sm text-gray-500 dark:text-gray-400">in Engineering</p>
      </div>
    </div>
  )
}
