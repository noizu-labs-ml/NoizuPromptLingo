// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function WithBorderAndDot03() {
  return (
    <>
      <span className="inline-flex items-center gap-x-1.5 rounded-md px-2 py-1 text-xs font-medium text-gray-900 inset-ring inset-ring-gray-200 dark:text-white dark:inset-ring-white/10">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-red-500 dark:fill-red-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-md px-2 py-1 text-xs font-medium text-gray-900 inset-ring inset-ring-gray-200 dark:text-white dark:inset-ring-white/10">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-yellow-500 dark:fill-yellow-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-md px-2 py-1 text-xs font-medium text-gray-900 inset-ring inset-ring-gray-200 dark:text-white dark:inset-ring-white/10">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-green-500 dark:fill-green-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-md px-2 py-1 text-xs font-medium text-gray-900 inset-ring inset-ring-gray-200 dark:text-white dark:inset-ring-white/10">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-blue-500 dark:fill-blue-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-md px-2 py-1 text-xs font-medium text-gray-900 inset-ring inset-ring-gray-200 dark:text-white dark:inset-ring-white/10">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-indigo-500 dark:fill-indigo-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-md px-2 py-1 text-xs font-medium text-gray-900 inset-ring inset-ring-gray-200 dark:text-white dark:inset-ring-white/10">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-purple-500 dark:fill-purple-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-md px-2 py-1 text-xs font-medium text-gray-900 inset-ring inset-ring-gray-200 dark:text-white dark:inset-ring-white/10">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-pink-500 dark:fill-pink-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
    </>
  )
}
