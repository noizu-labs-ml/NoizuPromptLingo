// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import {
  AcademicCapIcon,
  BanknotesIcon,
  CheckBadgeIcon,
  ClockIcon,
  ReceiptRefundIcon,
  UsersIcon,
} from '@heroicons/react/24/outline'

const actions = [
  {
    title: 'Request time off',
    href: '#',
    icon: ClockIcon,
    iconForeground: 'text-teal-700 dark:text-teal-400',
    iconBackground: 'bg-teal-50 dark:bg-teal-500/10',
  },
  {
    title: 'Benefits',
    href: '#',
    icon: CheckBadgeIcon,
    iconForeground: 'text-purple-700 dark:text-purple-400',
    iconBackground: 'bg-purple-50 dark:bg-purple-500/10',
  },
  {
    title: 'Schedule a one-on-one',
    href: '#',
    icon: UsersIcon,
    iconForeground: 'text-sky-700 dark:text-sky-400',
    iconBackground: 'bg-sky-50 dark:bg-sky-500/10',
  },
  {
    title: 'Payroll',
    href: '#',
    icon: BanknotesIcon,
    iconForeground: 'text-yellow-700 dark:text-yellow-400',
    iconBackground: 'bg-yellow-50 dark:bg-yellow-500/10',
  },
  {
    title: 'Submit an expense',
    href: '#',
    icon: ReceiptRefundIcon,
    iconForeground: 'text-rose-700 dark:text-rose-400',
    iconBackground: 'bg-rose-50 dark:bg-rose-500/10',
  },
  {
    title: 'Training',
    href: '#',
    icon: AcademicCapIcon,
    iconForeground: 'text-indigo-700 dark:text-indigo-400',
    iconBackground: 'bg-indigo-50 dark:bg-indigo-500/10',
  },
]

function classNames(...classes) {
  return classes.filter(Boolean).join(' ')
}

export function ActionsWithSharedBorders05() {
  return (
    <div className="divide-y divide-gray-200 overflow-hidden rounded-lg bg-gray-200 shadow-sm sm:grid sm:grid-cols-2 sm:divide-y-0 dark:divide-white/10 dark:bg-gray-900 dark:shadow-none dark:outline dark:-outline-offset-1 dark:outline-white/20">
      {actions.map((action, actionIdx) => (
        <div
          key={action.title}
          className={classNames(
            actionIdx === 0 ? 'rounded-tl-lg rounded-tr-lg sm:rounded-tr-none' : '',
            actionIdx === 1 ? 'sm:rounded-tr-lg' : '',
            actionIdx === actions.length - 2 ? 'sm:rounded-bl-lg' : '',
            actionIdx === actions.length - 1 ? 'rounded-br-lg rounded-bl-lg sm:rounded-bl-none' : '',
            'group relative border-gray-200 bg-white p-6 focus-within:outline-2 focus-within:-outline-offset-2 focus-within:outline-indigo-600 sm:odd:not-nth-last-2:border-b sm:even:border-l sm:even:not-last:border-b dark:border-white/10 dark:bg-gray-800/50 dark:focus-within:outline-indigo-500',
          )}
        >
          <div>
            <span className={classNames(action.iconBackground, action.iconForeground, 'inline-flex rounded-lg p-3')}>
              <action.icon aria-hidden="true" className="size-6" />
            </span>
          </div>
          <div className="mt-8">
            <h3 className="text-base font-semibold text-gray-900 dark:text-white">
              <a href={action.href} className="focus:outline-hidden">
                {/* Extend touch target to entire panel */}
                <span aria-hidden="true" className="absolute inset-0" />
                {action.title}
              </a>
            </h3>
            <p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
              Doloribus dolores nostrum quia qui natus officia quod et dolorem. Sit repellendus qui ut at blanditiis et
              quo et molestiae.
            </p>
          </div>
          <span
            aria-hidden="true"
            className="pointer-events-none absolute top-6 right-6 text-gray-300 group-hover:text-gray-400 dark:text-gray-500 dark:group-hover:text-gray-200"
          >
            <svg fill="currentColor" viewBox="0 0 24 24" className="size-6">
              <path d="M20 4h1a1 1 0 00-1-1v1zm-1 12a1 1 0 102 0h-2zM8 3a1 1 0 000 2V3zM3.293 19.293a1 1 0 101.414 1.414l-1.414-1.414zM19 4v12h2V4h-2zm1-1H8v2h12V3zm-.707.293l-16 16 1.414 1.414 16-16-1.414-1.414z" />
            </svg>
          </span>
        </div>
      ))}
    </div>
  )
}
