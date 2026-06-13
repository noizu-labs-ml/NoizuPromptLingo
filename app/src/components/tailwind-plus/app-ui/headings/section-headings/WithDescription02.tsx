// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function WithDescription02() {
  return (
    <div className="border-b border-gray-200 pb-5 dark:border-white/10">
      <h3 className="text-base font-semibold text-gray-900 dark:text-white">Job Postings</h3>
      <p className="mt-2 max-w-4xl text-sm text-gray-500 dark:text-gray-400">
        Workcation is a property rental website. Etiam ullamcorper massa viverra consequat, consectetur id nulla tempus.
        Fringilla egestas justo massa purus sagittis malesuada.
      </p>
    </div>
  )
}
