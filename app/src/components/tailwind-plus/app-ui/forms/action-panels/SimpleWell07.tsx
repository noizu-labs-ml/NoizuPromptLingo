// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function SimpleWell07() {
  return (
    <div className="bg-gray-50 sm:rounded-lg dark:bg-gray-800/50">
      <div className="px-4 py-5 sm:p-6">
        <h3 className="text-base font-semibold text-gray-900 dark:text-white">Need more bandwidth?</h3>
        <div className="mt-2 max-w-xl text-sm text-gray-500 dark:text-gray-400">
          <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatibus praesentium tenetur pariatur.</p>
        </div>
        <div className="mt-5">
          <button
            type="button"
            className="inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-xs ring-1 ring-gray-300 ring-inset hover:bg-gray-50 dark:bg-white/10 dark:text-white dark:shadow-none dark:ring-white/5 dark:hover:bg-white/20"
          >
            Contact sales
          </button>
        </div>
      </div>
    </div>
  )
}
