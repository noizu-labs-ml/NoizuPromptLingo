// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { EllipsisVerticalIcon } from '@heroicons/react/20/solid'

const projects = [
  { name: 'Graph API', initials: 'GA', href: '#', members: 16, bgColor: 'bg-pink-600 dark:bg-pink-700' },
  { name: 'Component Design', initials: 'CD', href: '#', members: 12, bgColor: 'bg-purple-600 dark:bg-purple-700' },
  { name: 'Templates', initials: 'T', href: '#', members: 16, bgColor: 'bg-yellow-500 dark:bg-yellow-600' },
  { name: 'React Components', initials: 'RC', href: '#', members: 8, bgColor: 'bg-green-500 dark:bg-green-600' },
]

function classNames(...classes) {
  return classes.filter(Boolean).join(' ')
}

export function SimpleCards03() {
  return (
    <div>
      <h2 className="text-sm font-medium text-gray-500 dark:text-gray-400">Pinned Projects</h2>
      <ul role="list" className="mt-3 grid grid-cols-1 gap-5 sm:grid-cols-2 sm:gap-6 lg:grid-cols-4">
        {projects.map((project) => (
          <li key={project.name} className="col-span-1 flex rounded-md shadow-xs dark:shadow-none">
            <div
              className={classNames(
                project.bgColor,
                'flex w-16 shrink-0 items-center justify-center rounded-l-md text-sm font-medium text-white',
              )}
            >
              {project.initials}
            </div>
            <div className="flex flex-1 items-center justify-between truncate rounded-r-md border-t border-r border-b border-gray-200 bg-white dark:border-white/10 dark:bg-gray-800/50">
              <div className="flex-1 truncate px-4 py-2 text-sm">
                <a
                  href={project.href}
                  className="font-medium text-gray-900 hover:text-gray-600 dark:text-white dark:hover:text-gray-200"
                >
                  {project.name}
                </a>
                <p className="text-gray-500 dark:text-gray-400">{project.members} Members</p>
              </div>
              <div className="shrink-0 pr-2">
                <button
                  type="button"
                  className="inline-flex size-8 items-center justify-center rounded-full text-gray-400 hover:text-gray-500 focus:outline-2 focus:outline-offset-2 focus:outline-indigo-600 dark:hover:text-white dark:focus:outline-white"
                >
                  <span className="sr-only">Open options</span>
                  <EllipsisVerticalIcon aria-hidden="true" className="size-5" />
                </button>
              </div>
            </div>
          </li>
        ))}
      </ul>
    </div>
  )
}
