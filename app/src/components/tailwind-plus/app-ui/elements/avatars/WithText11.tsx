// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function WithText11() {
  return (
    <a href="#" className="group block shrink-0">
      <div className="flex items-center">
        <div>
          <img
            alt=""
            src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
            className="inline-block size-9 rounded-full outline -outline-offset-1 outline-black/5 dark:outline-white/10"
          />
        </div>
        <div className="ml-3">
          <p className="text-sm font-medium text-gray-700 group-hover:text-gray-900 dark:text-gray-300 group-hover:dark:text-white">
            Tom Cook
          </p>
          <p className="text-xs font-medium text-gray-500 group-hover:text-gray-700 dark:text-gray-400 group-hover:dark:text-gray-300">
            View profile
          </p>
        </div>
      </div>
    </a>
  )
}
