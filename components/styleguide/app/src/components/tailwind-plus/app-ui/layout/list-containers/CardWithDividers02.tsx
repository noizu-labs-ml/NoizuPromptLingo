// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const items = [{ id: 1 }, { id: 2 }, { id: 3 }]

export function CardWithDividers02() {
  return (
    <div className="overflow-hidden rounded-md bg-white shadow-sm dark:bg-gray-800/50 dark:shadow-none dark:outline dark:-outline-offset-0 dark:outline-white/10">
      <ul role="list" className="divide-y divide-gray-200 dark:divide-white/10">
        {items.map((item) => (
          <li key={item.id} className="px-6 py-4">
            {/* Your content */}
          </li>
        ))}
      </ul>
    </div>
  )
}
