// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const plans = [
  { id: 'hobby', name: 'Hobby', ram: '8GB', cpus: '4 CPUs', disk: '160 GB SSD disk', price: '$40' },
  { id: 'startup', name: 'Startup', ram: '12GB', cpus: '6 CPUs', disk: '256 GB SSD disk', price: '$80' },
  { id: 'business', name: 'Business', ram: '16GB', cpus: '8 CPUs', disk: '512 GB SSD disk', price: '$160' },
  { id: 'enterprise', name: 'Enterprise', ram: '32GB', cpus: '12 CPUs', disk: '1024 GB SSD disk', price: '$240' },
]

export function StackedCards12() {
  return (
    <fieldset aria-label="Server size">
      <div className="space-y-4">
        {plans.map((plan) => (
          <label
            key={plan.id}
            aria-label={plan.name}
            aria-description={`${plan.ram}, ${plan.cpus}, ${plan.disk}, ${plan.price} per month`}
            className="group relative block rounded-lg border border-gray-300 bg-white px-6 py-4 has-checked:outline-2 has-checked:-outline-offset-2 has-checked:outline-indigo-600 has-focus-visible:outline-3 has-focus-visible:-outline-offset-1 sm:flex sm:justify-between dark:border-white/10 dark:bg-gray-800/50 dark:has-checked:outline-indigo-500"
          >
            <input
              defaultValue={plan.id}
              defaultChecked={plan.id === 'hobby'}
              name="plan"
              type="radio"
              className="absolute inset-0 appearance-none focus:outline-none"
            />
            <span className="flex items-center">
              <span className="flex flex-col text-sm">
                <span className="font-medium text-gray-900 dark:text-white">{plan.name}</span>
                <span className="text-gray-500 dark:text-gray-400">
                  <span className="block sm:inline">
                    {plan.ram} / {plan.cpus}
                  </span>{' '}
                  <span aria-hidden="true" className="hidden sm:mx-1 sm:inline">
                    &middot;
                  </span>{' '}
                  <span className="block sm:inline">{plan.disk}</span>
                </span>
              </span>
            </span>
            <span className="mt-2 flex text-sm sm:mt-0 sm:ml-4 sm:flex-col sm:text-right">
              <span className="font-medium text-gray-900 dark:text-white">{plan.price}</span>
              <span className="ml-1 text-gray-500 sm:ml-0 dark:text-gray-400">/mo</span>
            </span>
          </label>
        ))}
      </div>
    </fieldset>
  )
}
