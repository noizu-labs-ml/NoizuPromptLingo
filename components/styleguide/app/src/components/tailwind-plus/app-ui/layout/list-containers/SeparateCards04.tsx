// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const items = [{ id: 1 }, { id: 2 }, { id: 3 }]

export function SeparateCards04() {
  return (
    <ul role="list" className="space-y-3">
      {items.map((item) => (
        <li
          key={item.id}
          className="overflow-hidden rounded-md bg-white px-6 py-4 shadow-sm dark:bg-gray-800/50 dark:shadow-none dark:outline dark:-outline-offset-1 dark:outline-white/10"
        >
          {/* Your content */}
        </li>
      ))}
    </ul>
  )
}
