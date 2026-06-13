// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function CardWithGrayBody07() {
  return (
    <div className="overflow-hidden rounded-lg bg-white shadow-sm dark:divide-white/10 dark:bg-gray-800/50 dark:shadow-none dark:outline dark:-outline-offset-1 dark:outline-white/10">
      <div className="px-4 py-5 sm:px-6">
        {/* Content goes here */}
        {/* We use less vertical padding on card headers on desktop than on body sections */}
      </div>
      <div className="bg-gray-50 px-4 py-5 sm:p-6 dark:bg-gray-800/50">{/* Content goes here */}</div>
    </div>
  )
}
