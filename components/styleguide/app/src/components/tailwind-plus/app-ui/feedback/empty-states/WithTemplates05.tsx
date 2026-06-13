// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { ChevronRightIcon } from '@heroicons/react/20/solid'
import { CalendarIcon, CommandLineIcon, MegaphoneIcon } from '@heroicons/react/24/outline'

const items = [
  {
    name: 'Marketing Campaign',
    description: 'I think the kids call these memes these days.',
    href: '#',
    iconColor: 'bg-pink-500',
    icon: MegaphoneIcon,
  },
  {
    name: 'Engineering Project',
    description: 'Something really expensive that will ultimately get cancelled.',
    href: '#',
    iconColor: 'bg-purple-500',
    icon: CommandLineIcon,
  },
  {
    name: 'Event',
    description: 'Like a conference all about you that no one will care about.',
    href: '#',
    iconColor: 'bg-yellow-500',
    icon: CalendarIcon,
  },
]

function classNames(...classes) {
  return classes.filter(Boolean).join(' ')
}

export function WithTemplates05() {
  return (
    <div className="mx-auto max-w-lg">
      <h2 className="text-base font-semibold text-gray-900 dark:text-white">Create your first project</h2>
      <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
        Get started by selecting a template or start from an empty project.
      </p>
      <ul
        role="list"
        className="mt-6 divide-y divide-gray-200 border-y border-gray-200 dark:divide-white/10 dark:border-white/10"
      >
        {items.map((item, itemIdx) => (
          <li key={itemIdx}>
            <div className="group relative flex items-start space-x-3 py-4">
              <div className="shrink-0">
                <span
                  className={classNames(item.iconColor, 'inline-flex size-10 items-center justify-center rounded-lg')}
                >
                  <item.icon aria-hidden="true" className="size-6 text-white" />
                </span>
              </div>
              <div className="min-w-0 flex-1">
                <div className="text-sm font-medium text-gray-900 dark:text-white">
                  <a href={item.href}>
                    <span aria-hidden="true" className="absolute inset-0" />
                    {item.name}
                  </a>
                </div>
                <p className="text-sm text-gray-500 dark:text-gray-400">{item.description}</p>
              </div>
              <div className="shrink-0 self-center">
                <ChevronRightIcon
                  aria-hidden="true"
                  className="size-5 text-gray-400 group-hover:text-gray-500 dark:text-gray-500 dark:group-hover:text-gray-400"
                />
              </div>
            </div>
          </li>
        ))}
      </ul>
      <div className="mt-6 flex">
        <a
          href="#"
          className="text-sm font-medium text-indigo-600 hover:text-indigo-500 dark:text-indigo-400 dark:hover:text-indigo-300"
        >
          Or start from an empty project
          <span aria-hidden="true"> &rarr;</span>
        </a>
      </div>
    </div>
  )
}
