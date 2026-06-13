// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const items = [{ id: 1 }, { id: 2 }, { id: 3 }]

export function CardWithDividersFullWidthOnMobile03() {
  return (
    <div className="overflow-hidden bg-white shadow-sm sm:rounded-md dark:bg-gray-800/50 dark:shadow-none dark:outline dark:-outline-offset-1 dark:outline-white/10">
      <ul role="list" className="divide-y divide-gray-200 dark:divide-white/10">
        {items.map((item) => (
          <li key={item.id} className="px-4 py-4 sm:px-6">
            {/* Your content */}
          </li>
        ))}
      </ul>
    </div>
  )
}
