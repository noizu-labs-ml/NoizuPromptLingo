// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { ChevronRightIcon } from '@heroicons/react/20/solid'

const deployments = [
  {
    id: 1,
    href: '#',
    projectName: 'ios-app',
    teamName: 'Planetaria',
    status: 'offline',
    statusText: 'Initiated 1m 32s ago',
    description: 'Deploys from GitHub',
    environment: 'Preview',
  },
  {
    id: 2,
    href: '#',
    projectName: 'mobile-api',
    teamName: 'Planetaria',
    status: 'online',
    statusText: 'Deployed 3m ago',
    description: 'Deploys from GitHub',
    environment: 'Production',
  },
  {
    id: 3,
    href: '#',
    projectName: 'tailwindcss.com',
    teamName: 'Tailwind Labs',
    status: 'offline',
    statusText: 'Deployed 3h ago',
    description: 'Deploys from GitHub',
    environment: 'Preview',
  },
  {
    id: 4,
    href: '#',
    projectName: 'api.protocol.chat',
    teamName: 'Protocol',
    status: 'error',
    statusText: 'Failed to deploy 6d ago',
    description: 'Deploys from GitHub',
    environment: 'Preview',
  },
]

export function NarrowWithBadges17() {
  return (
    <ul role="list" className="divide-y divide-gray-100 dark:divide-white/5">
      {deployments.map((deployment) => (
        <li key={deployment.id} className="relative flex items-center space-x-4 py-4">
          <div className="min-w-0 flex-auto">
            <div className="flex items-center gap-x-3">
              {deployment.status === 'offline' ? (
                <div className="flex-none rounded-full bg-gray-100/10 p-1 text-gray-500 dark:bg-white/10">
                  <div className="size-2 rounded-full bg-current" />
                </div>
              ) : null}
              {deployment.status === 'online' ? (
                <div className="flex-none rounded-full bg-green-100 p-1 text-green-500 dark:bg-green-400/20 dark:text-green-400">
                  <div className="size-2 rounded-full bg-current" />
                </div>
              ) : null}
              {deployment.status === 'error' ? (
                <div className="flex-none rounded-full bg-rose-100 p-1 text-rose-500 dark:bg-rose-400/20 dark:text-rose-400">
                  <div className="size-2 rounded-full bg-current" />
                </div>
              ) : null}
              <h2 className="min-w-0 text-sm/6 font-semibold text-gray-900 dark:text-white">
                <a href={deployment.href} className="flex gap-x-2">
                  <span className="truncate">{deployment.teamName}</span>
                  <span className="text-gray-500 dark:text-gray-400">/</span>
                  <span className="whitespace-nowrap">{deployment.projectName}</span>
                  <span className="absolute inset-0" />
                </a>
              </h2>
            </div>
            <div className="mt-3 flex items-center gap-x-2.5 text-xs/5 text-gray-500 dark:text-gray-400">
              <p className="truncate">{deployment.description}</p>
              <svg viewBox="0 0 2 2" className="size-0.5 flex-none fill-gray-500 dark:fill-gray-300">
                <circle r={1} cx={1} cy={1} />
              </svg>
              <p className="whitespace-nowrap">{deployment.statusText}</p>
            </div>
          </div>
          {deployment.environment === 'Preview' ? (
            <div className="flex-none rounded-full bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 inset-ring inset-ring-gray-500/10 dark:bg-gray-400/10 dark:text-gray-400 dark:inset-ring-gray-400/20">
              {deployment.environment}
            </div>
          ) : null}
          {deployment.environment === 'Production' ? (
            <div className="flex-none rounded-full bg-indigo-50 px-2 py-1 text-xs font-medium text-indigo-700 inset-ring inset-ring-indigo-700/10 dark:bg-indigo-400/10 dark:text-indigo-400 dark:inset-ring-indigo-400/30">
              {deployment.environment}
            </div>
          ) : null}
          <ChevronRightIcon aria-hidden="true" className="size-5 flex-none text-gray-400" />
        </li>
      ))}
    </ul>
  )
}
