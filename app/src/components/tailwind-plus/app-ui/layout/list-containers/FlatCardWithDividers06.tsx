// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const items = [{ id: 1 }, { id: 2 }, { id: 3 }]

export function FlatCardWithDividers06() {
  return (
    <div className="overflow-hidden rounded-md border border-gray-300 bg-white dark:border-white/10 dark:bg-gray-900">
      <ul role="list" className="divide-y divide-gray-300 dark:divide-white/10">
        {items.map((item) => (
          <li key={item.id} className="px-6 py-4">
            {/* Your content */}
          </li>
        ))}
      </ul>
    </div>
  )
}
