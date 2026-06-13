// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function FlatPillWithDot11() {
  return (
    <>
      <span className="inline-flex items-center gap-x-1.5 rounded-full bg-gray-100 px-2 py-1 text-xs font-medium text-gray-600 dark:bg-gray-400/10 dark:text-gray-400">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-gray-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-full bg-red-100 px-2 py-1 text-xs font-medium text-red-700 dark:bg-red-400/10 dark:text-red-400">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-red-500 dark:fill-red-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-full bg-yellow-100 px-2 py-1 text-xs font-medium text-yellow-800 dark:bg-yellow-400/10 dark:text-yellow-500">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-yellow-500 dark:fill-yellow-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-full bg-green-100 px-2 py-1 text-xs font-medium text-green-700 dark:bg-green-400/10 dark:text-green-400">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-green-500 dark:fill-green-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-full bg-blue-100 px-2 py-1 text-xs font-medium text-blue-700 dark:bg-blue-400/10 dark:text-blue-400">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-blue-500 dark:fill-blue-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-full bg-indigo-100 px-2 py-1 text-xs font-medium text-indigo-700 dark:bg-indigo-400/10 dark:text-indigo-400">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-indigo-500 dark:fill-indigo-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-full bg-purple-100 px-2 py-1 text-xs font-medium text-purple-700 dark:bg-purple-400/10 dark:text-purple-400">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-purple-500 dark:fill-purple-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
      <span className="inline-flex items-center gap-x-1.5 rounded-full bg-pink-100 px-2 py-1 text-xs font-medium text-pink-700 dark:bg-pink-400/10 dark:text-pink-400">
        <svg viewBox="0 0 6 6" aria-hidden="true" className="size-1.5 fill-pink-500 dark:fill-pink-400">
          <circle r={3} cx={3} cy={3} />
        </svg>
        Badge
      </span>
    </>
  )
}
