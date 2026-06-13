// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { ChevronDownIcon } from '@heroicons/react/16/solid'

const tabs = [
  { name: 'My Account', href: '#', current: false },
  { name: 'Company', href: '#', current: false },
  { name: 'Team Members', href: '#', current: true },
  { name: 'Billing', href: '#', current: false },
]

export function Simple09() {
  return (
    <div className="bg-white px-4 py-6 sm:px-6 lg:px-8 dark:bg-gray-900">
      <div className="mx-auto max-w-7xl">
        <div className="grid grid-cols-1 sm:hidden">
          {/* Use an "onChange" listener to redirect the user to the selected tab URL. */}
          <select
            defaultValue={tabs.find((tab) => tab.current).name}
            aria-label="Select a tab"
            className="col-start-1 row-start-1 w-full appearance-none rounded-md bg-white py-2 pr-8 pl-3 text-base text-gray-900 outline-1 -outline-offset-1 outline-gray-300 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 dark:bg-white/5 dark:text-gray-100 dark:outline-white/10 dark:*:bg-gray-800 dark:focus:outline-indigo-500"
          >
            {tabs.map((tab) => (
              <option key={tab.name}>{tab.name}</option>
            ))}
          </select>
          <ChevronDownIcon
            aria-hidden="true"
            className="pointer-events-none col-start-1 row-start-1 mr-2 size-5 self-center justify-self-end fill-gray-500 dark:fill-gray-400"
          />
        </div>
        <div className="hidden sm:block">
          <nav className="flex border-b border-gray-200 py-4 dark:border-white/10">
            <ul
              role="list"
              className="flex min-w-full flex-none gap-x-8 px-2 text-sm/6 font-semibold text-gray-500 dark:text-gray-400"
            >
              {tabs.map((tab) => (
                <li key={tab.name}>
                  <a
                    href={tab.href}
                    className={
                      tab.current ? 'text-indigo-600 dark:text-indigo-400' : 'hover:text-gray-700 dark:hover:text-white'
                    }
                  >
                    {tab.name}
                  </a>
                </li>
              ))}
            </ul>
          </nav>
        </div>
      </div>
    </div>
  )
}
