// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const steps = [
  { name: 'Step 1', href: '#', status: 'complete' },
  { name: 'Step 2', href: '#', status: 'current' },
  { name: 'Step 3', href: '#', status: 'upcoming' },
  { name: 'Step 4', href: '#', status: 'upcoming' },
]

export function Bullets03() {
  return (
    <nav aria-label="Progress" className="flex items-center justify-center">
      <p className="text-sm font-medium text-gray-900 dark:text-white">
        Step {steps.findIndex((step) => step.status === 'current') + 1} of {steps.length}
      </p>
      <ol role="list" className="ml-8 flex items-center space-x-5">
        {steps.map((step) => (
          <li key={step.name}>
            {step.status === 'complete' ? (
              <a
                href={step.href}
                className="block size-2.5 rounded-full bg-indigo-600 hover:bg-indigo-900 dark:bg-indigo-500 dark:hover:bg-indigo-400"
              >
                <span className="sr-only">{step.name}</span>
              </a>
            ) : step.status === 'current' ? (
              <a href={step.href} aria-current="step" className="relative flex items-center justify-center">
                <span aria-hidden="true" className="absolute flex size-5 p-px">
                  <span className="size-full rounded-full bg-indigo-200 dark:bg-indigo-900" />
                </span>
                <span
                  aria-hidden="true"
                  className="relative block size-2.5 rounded-full bg-indigo-600 dark:bg-indigo-500"
                />
                <span className="sr-only">{step.name}</span>
              </a>
            ) : (
              <a
                href={step.href}
                className="block size-2.5 rounded-full bg-gray-200 hover:bg-gray-400 dark:bg-white/15 dark:hover:bg-white/25"
              >
                <span className="sr-only">{step.name}</span>
              </a>
            )}
          </li>
        ))}
      </ol>
    </nav>
  )
}
