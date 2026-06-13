// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function ShortToggle02() {
  return (
    <div className="group relative inline-flex h-5 w-10 shrink-0 items-center justify-center rounded-full outline-offset-2 outline-indigo-600 has-focus-visible:outline-2 dark:outline-indigo-500">
      <span className="absolute mx-auto h-4 w-9 rounded-full bg-gray-200 inset-ring inset-ring-gray-900/5 transition-colors duration-200 ease-in-out group-has-checked:bg-indigo-600 dark:bg-gray-800/50 dark:inset-ring-white/10 dark:group-has-checked:bg-indigo-500" />
      <span className="absolute left-0 size-5 rounded-full border border-gray-300 bg-white shadow-xs transition-transform duration-200 ease-in-out group-has-checked:translate-x-5 dark:shadow-none" />
      <input
        name="setting"
        type="checkbox"
        aria-label="Use setting"
        className="absolute inset-0 size-full appearance-none focus:outline-hidden"
      />
    </div>
  )
}
