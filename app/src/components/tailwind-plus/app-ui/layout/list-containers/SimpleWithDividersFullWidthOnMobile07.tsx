// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const items = [{ id: 1 }, { id: 2 }, { id: 3 }]

export function SimpleWithDividersFullWidthOnMobile07() {
  return (
    <ul role="list" className="divide-y divide-gray-200 dark:divide-white/10">
      {items.map((item) => (
        <li key={item.id} className="px-4 py-4 sm:px-0">
          {/* Your content */}
        </li>
      ))}
    </ul>
  )
}
